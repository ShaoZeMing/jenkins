#!/bin/bash
#需要针对服务器进行配置的变量

OBJECT_ROOT_DIR='/home/deplay/laravel-demo'   #服务器项目部署根目录
LINK_DIRS=('storage')                         #项目下不需要更新替换的静态目录,数组
RELEASES_NUM=3                                #保留几个版本

#创建基础目录
OBJECT_SHARED_DIR=${OBJECT_ROOT_DIR}"/shared"          #静态文件目录
OBJECT_CURRENT_DIR=${OBJECT_ROOT_DIR}"/current"        #项目访问link
OBJECT_RELEASES_DIR=${OBJECT_ROOT_DIR}"/releases"      #项目所有版本目录
RELEASES_ID_DIR=${OBJECT_RELEASES_DIR}"/"${BUILD_ID}   #项目当前执行版本目录
[ -d ${OBJECT_RELEASES_DIR} ] || mkdir -p ${OBJECT_RELEASES_DIR}
[ -d ${OBJECT_SHARED_DIR} ] || mkdir -p ${OBJECT_SHARED_DIR}
[ -d ${RELEASES_ID_DIR} ] || mkdir -p ${RELEASES_ID_DIR}

cd ${OBJECT_ROOT_DIR}
tar -xzf ${BUILD_ID}.tar.gz  -C ${RELEASES_ID_DIR}
rm ${BUILD_ID}.tar.gz

chmod -Rf ug+rwx ${RELEASES_ID_DIR};
cd ${RELEASES_ID_DIR}


#静态目录建立软连接
for LINK_DIR in ${LINK_DIRS};do
if [ -d ${RELEASES_ID_DIR}'/'${LINK_DIR} ]; then
[ -d ${OBJECT_SHARED_DIR}'/'${LINK_DIR} ] || mkdir -p  ${OBJECT_SHARED_DIR}'/'${LINK_DIR};
rsync --progress -e ssh -avzh --delay-updates --exclude "*.logs"  ${RELEASES_ID_DIR}'/'${LINK_DIR}'/'  ${OBJECT_SHARED_DIR}'/'${LINK_DIR}'/' && rm -fr ${RELEASES_ID_DIR}'/'${LINK_DIR}'/';
chmod -Rf ug+rwx ${OBJECT_SHARED_DIR}'/'${LINK_DIR}'/';
ln -nfs  ${OBJECT_SHARED_DIR}'/'${LINK_DIR}  ${RELEASES_ID_DIR}'/'${LINK_DIR}
fi
done



#最新版本目录需要执行的命令
cp .env.development .env
composer install --prefer-dist --no-dev --no-scripts --no-interaction && composer dump-autoload --optimize

php artisan clear-compiled && php artisan optimize
php artisan config:clear && php artisan config:cache
php artisan route:clear && php artisan route:cache



#部署结束后切换软连接
[ -L  ${OBJECT_CURRENT_DIR} ] &&  rm -rf ${OBJECT_CURRENT_DIR}
ln -nfs  ${RELEASES_ID_DIR} ${OBJECT_CURRENT_DIR}



#根据部署个数，删除超过的之前版本，删除文件更改需谨慎===================
#ls -l:目的是按行列出文件
#grep "act-*":筛选出包含act-为开头的文件
#wc -l:统计行数（也就相当于统计有多少个这样的文件）
#-gt :大于
#ls -rt:把文件按从旧到新的顺序排列
#head -n1:选取排列的头两个文件，这个数字2可以任意的改变
#rm -r:移除目录
 cd ${OBJECT_RELEASES_DIR}
 pwd
 if [ $(ls -l | wc -l) -gt ${RELEASES_NUM} ]
 then
     echo "files > ${RELEASES_NUM}"
     rm -r $(ls -rt | head -n1)
 fi
