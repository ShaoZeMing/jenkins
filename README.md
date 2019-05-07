# jenkins

## 说明

- 根据官方：jenkins:lts 镜像进行二次构建，添加内置node+npm

## 生成镜像

```bash
 docker build -t shaozeming/jenknis:node .
```


## docker-compose启动jenkins

```bash

  docker-compose build
  docker-compose up -d

```
