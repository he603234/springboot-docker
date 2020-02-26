# springboot-docker
打包springboot项目的同时，同步打包镜像到docker容器中


一、Docker的安装与使用

Docker 要求 CentOS 系统的内核版本高于 3.10 ，查看本页面的前提条件来验证你的CentOS 版本是否支持 Docker 。
通过 uname -r 命令查看你当前的内核版本
[root@runoob ~]# uname -r 3.10.0-327.el7.x86_64

移除旧的版本：
$ sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine


安装一些必要的系统工具：
sudo yum install -y yum-utils device-mapper-persistent-data lvm2

添加软件源信息：
sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

更新 yum 缓存：
sudo yum makecache fast

安装 Docker-ce：
sudo yum -y install docker-ce

启动 Docker 后台服务
sudo systemctl start docker

测试运行 hello-world
[root@runoob ~]# docker run hello-world


开机启动
2.systemctl enable docker.service

删除Docker CE
$ sudo yum remove docker-ce
$ sudo rm -rf /var/lib/docker

二、docker使用
镜像操作
查看运行容器
docker ps

查看所有镜像列表
docekr images

镜像搜索
docker search nginx

镜像下载
docker pull nginx

后台运行指定镜像，-d：后台运行，返回id号
docker –d run [名称/image id]

指定端口运行镜像->启动容器
docker run -p 81:80 -d [nginx/image id]
-p：指定端口 ， 81端口为暴露在外部的端口， 80为nginx自身端口
-d:后台运行

删除指定镜像,(前提是没有使用镜像的容器，容器包括正在运行和已经停止)
docker rmi [image id]

容器操作
查看所有容器，包括已经停用的
docker ps -a

查看正在运行的容器
docker ps

杀死指定容器进程
docker kill  {container id}

删除单个容器
docker rm {container id}

同时删除多个符合筛选条件的容器
docker rm $(docker container ls -f "status=exited" -q)

删除所有容器
docker rm $(docker container ls -aq)

查询相应容器的日志
docker logs 2b1b7a428627



常见问题：
1、docker容器运行后无法访问，报异常WARNING: IPv4 forwarding is disabled. Networking will not work.
解决办法：
# vim  /usr/lib/sysctl.d/00-system.conf
1

添加如下代码：
net.ipv4.ip_forward=1
1

重启network服务
# systemctl restart network




二、Idea打包docker镜像并推送到远程docker容器中


1、windows7安装docker
https://blog.csdn.net/ncdx111/article/details/79984379

2、linux安装docker
见《docker安装与使用.docx》


3、idea打包镜像
采用插件一步打包发布本地的Maven项目为远程主机的Docker镜像，之前的docker-maven-plugin已经被废弃， dockerfile-maven-plugin是其替代，我们将采用最新的dockerfile-maven-plugin插件，正常打包就可以同步打包docker镜像，并上传docker 私有仓库


项目pom中添加如下配置：
<properties>
    <java.version>1.8</java.version>
    <!--docker私服地址-->
    <docker.repostory>192.168.88.135:2375</docker.repostory>
</properties>

<!--docker插件-->
<plugin>
    <groupId>com.spotify</groupId>
    <artifactId>dockerfile-maven-plugin</artifactId>
    <version>1.4.9</version>
    <executions>
        <execution>
            <id>default</id>
            <!--如果package时不想用docker打包,就注释掉这个goal-->
            <goals>
                <goal>build</goal>
                <goal>push</goal>
            </goals>
        </execution>
    </executions>
    <configuration>
        <repository>${docker.repostory}/${project.artifactId}</repository>
        <!--镜像版本-->
        <tag>${project.version}</tag>
        <buildArgs>
            <!--提供参数向Dockerfile传递-->
            <JAR_FILE>target/${project.build.finalName}.jar</JAR_FILE>
        </buildArgs>
    </configuration>
</plugin>


4、添加Dockerfile到项目根目录

内容如下：


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
位置如下：



5、开启docker远程连接

编辑docker文件：
vim /usr/lib/systemd/system/docker.service
修改ExecStart，将内容修改为下面内容
ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix://var/run/docker.sock


6、重启docker及守护服务
systemctl daemon-reload  //重启守护服务
systemctl restart docker //重启docke




7、idea中执行命令，生成docker镜像并推送到远程docker
运行命令：mvn clean package -U
或者点击maven 打包插件 “package”


9、进入docker服务，使用命令docker images查看刚刚上传的镜像，之后运行即可；
