自动备份脚本

```shell
# 1、设置变量
ip=`hostname -I |awk '{print $2}'`
backup_dir=/backup/${ip}  #备份的路径
time=`date +%F_%w`    #时间
backup_file=conf-${time}.tar.gz
backup_server=192.168.50.203 #远程备份服务器的IP

# 2、备份操作
mkdir -p ${backup_dir}  #创建文件夹
# 打包 /etc/ 目录以及/var/spool/cron/
tar zcf ${backup_dir}/${backup_file}     /etc/     /var/spool/cron/
# md5
md5sum ${backup_dir}/${backup_file}  >${backup_dir}/fingerprint.md5

# 3、推送命令——使用前先测试
rsync -a ${backup_dir}  rsync_backup@${backup_server}::backup  --password-file=/etc/rsync.client

# 4、删除旧的备份
find ${backup_dir} -type f -name "*.tar.gz" -mtime +7 |xargs rm -f
```

脚本在运行前，每一个变量需要确保是正确的；运行前可以先echo检查一下变量的值

还需要确认推送命令是否正确

```shell
[root@storage /]# echo `hostname -I |awk '{print $2}'`
172.16.1.213
```

### 客户端运行脚本报错

##### 报错：权限不足

```shell
rsync: recv_generator: mkdir "172.16.1.213" (in backup) failed: Permission denied (13)
```

##### 现象

客户端运行脚本时，脚本输出：Permission denied 权限不足，无法创建文件夹

##### 解决

初始创建/backup文件夹的时候，权限如下

```shell
[root@backup ~]# ls -ld /backup/
drwxr-xr-x 2 root root 6 Apr  8 20:29 /backup/
```

将所有权更改为用户 `rsync` 和组 `rsync`

```shell
[root@backup ~]# chown -R rsync.rsync /backup/
# 运行上面的命令之后，再次查看权限
[root@backup ~]# ls -ld /backup/
drwxr-xr-x 2 rsync rsync 6 Apr  8 20:29 /backup/
```

用户需要与rsyncd的配置文件保持一致，并且用户需要存在

```shell
uid = rsync
gid = rsync

[root@backup ~]# id rsync
uid=1001(rsync) gid=1001(rsync) groups=1001(rsync)
```
