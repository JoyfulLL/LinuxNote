# 备份服务——Rsync

### rsyncd服务与客户使用流程

| **部署流程** |                       |
| -------- | --------------------- |
| 服务端      | ①配置文件                 |
|          | ②添加虚拟用户               |
|          | ③secret文件，密码文件，修改文件权限 |
|          | ④创建共享目录并修改其权限所有者为虚拟用户 |
|          | ⑤启动或重启，开机自启动。         |
|          | ⑥测试                   |
| 客户端      | ①密码文件以及文件的权限          |
|          | ②客户端命令测试              |

### 

### Rsync 守护进程（服务端配置文件）

```shell
##rsyncd.conf start##
fake super = yes
uid = rsync
gid = rsync
use chroot = no
max connections = 2000
timeout = 600
pid file = /var/run/rsyncd.pid
lock file = /var/run/rsyncd.lock
log file = /var/log/rsyncd.log
ignore errors
read only = false
list = false
auth users = rsync_backup
secrets file = /etc/rsync.password

#########################
[data]
comment = by Abig
path = /data

[backup]
comment = Gather backups
path = /backup/
```

```shell
uid = rsync #rsync使用的用户，默认nobody
gid = rsync #rsync使用的gid 默认nobody
use chroot = no #是否限定在该目录下，默认为true，当有软连接时，需要改为fasle,如果为
 #true就限定为模块默认目录，通常都在内网使用rsync所以不配也可以
max connections = 200 #设置最大连接数timeout = 300 #超时时间 建议300-600
pid file = /var/run/rsyncd.pid #pid文件位置
lock file = /var/run/rsync.lock #指定lock文件用来支持“max connections ”参数使总连接不会超过限制
log file = /var/log/rsyncd.log #日志文件路径
ignore errors #忽略io错误
read only = false #指定客户端是否可以上传文件，默认
truelist = false #是否允许客户端查看可用模块 
hosts allow = 192.168.253.0/24 #允许连接的ip段或个别ip，默认任何人都可以连接
hosts deny = 0.0.0.0/32 #不允许连接的IP段或个别ip
auth users = rsync_backup #指定以空格或逗号分隔用户，他们可以使用这个模块，用户不需要再本
 #系统存在，默认所有用户都可以无密码登录
secrets file = /etc/rsync.password #指定用户名和密码文件 格式： 用户名：密码 密码不超过8位
 #这个是密码文件 全线最好是600

#########################
[backup] comment = "this is a comment" #此参数指定在客户端获取可用模块列表时显示在模块名称旁边的描述字
 ##符串，默认没有这个参数
path = /backup #模块在服务端的绝对路径
```

### 
