# jenkins

## 说明

- 根据官方：jenkins:lts 镜像进行二次构建，添加内置node+npm

## 1、直接获取镜像 https://cloud.docker.com/u/shaozeming/repository/docker/shaozeming/jenknis

```
docker pull  shaozeming/jenknis:node
```

## 2、自己构建镜像

```bash
 docker build -t shaozeming/jenknis:node .
```


## docker-compose启动 jenkins

```bash

  docker-compose build
  docker-compose up -d

```
