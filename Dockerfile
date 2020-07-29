#指定基础镜像，没有环境会自动拉取镜像,并且必须是第一条指令。如果不以任何镜像为基础，那么写法为：FROM scratch。同时意味着接下来所写的指令将作为镜像的第一层开始
FROM openjdk:8-jdk-alpine
#定义匿名数据卷。在启动容器时忘记挂载数据卷，会自动挂载到匿名卷。
VOLUME /tmp
#定义构建时需要的参数
ARG JAR_FILE
#复制本地工程 至 容器里指定的路径，项目为app.jar
COPY ${JAR_FILE} app.jar
#镜像自身端口，非服务对外端口，需要运行镜像时映射对外端口
EXPOSE 8080
#启动命令及环境变量
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]