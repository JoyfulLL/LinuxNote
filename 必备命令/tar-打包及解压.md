# tar命令的一些常用参数及其功能：

| 参数             | 功能             |
| -------------- | -------------- |
| -c             | 创建新的归档文件（打包）   |
| -x             | 从归档文件中提取文件（解包） |
| -f <文件名>       | 指定归档文件名        |
| -v             | 显示操作的详细信息      |
| -z             | 通过gzip压缩归档文件   |
| -j             | 通过bzip2压缩归档文件  |
| -C <目录>        | 切换到指定目录        |
| --exclude=<模式> | 排除匹配模式的文件      |
| --list         | 列出归档文件的内容      |
| --help         | 显示帮助信息         |



##### 创建压缩包⭐⭐⭐⭐⭐

```shell
#请把/etc/目录压缩，压缩包放在/tmp/etc.tar.gz
 tar zcf   /tmp/etc.tar.gz /etc/
```

##### 解压压缩包⭐⭐⭐⭐⭐

```shell
# 默认解压到当前目录
tar zxvf /tmp/etc.tar.gz
tar xf /tmp/etc.tar.gz  
# x extract 解压
```

##### 解压到指定目录 ⭐⭐⭐⭐⭐

```shell
解压etc.tar.gz 到/mnt目录下
-C解压到指定目录
tar xf 压缩包路径 -C 解压后的存放目录
tar xf /tmp/etc.tar.gz -C /mnt/

```


