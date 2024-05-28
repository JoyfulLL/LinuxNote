1. 服务端安装rpcbind 以及 nfs-utils
   
   ```shell
   # 服务端执行
   yum install -y rpcbind nfs-utils
   ```

2. 启动rpcbind并开启 开机自启
   
   ```shell
   # 启动
   [root@storage ~]# systemctl start rpcbind
   # 开机自启
   [root@storage ~]# systemctl enable rpcbind
   
   # 检查状态
   [root@storage ~]# rpcinfo -p
      program vers proto   port  service
       100000    4   tcp    111  portmapper
       100000    3   tcp    111  portmapper
       100000    2   tcp    111  portmapper
       100000    4   udp    111  portmapper
       100000    3   udp    111  portmapper
       100000    2   udp    111  por
   ```

3. 开启nfs 并 启动
   
   ```shell
   必须先 enable 再 start
   [root@storage ~]# systemctl enable nfs
   [root@storage ~]# systemctl start nfs
   
   [root@storage ~]# rpcinfo -p
      program vers proto   port  service
       100000    4   tcp    111  portmapper
       100000    3   tcp    111  portmapper
       100000    2   tcp    111  portmapper
       100000    4   udp    111  portmapper
       100000    3   udp    111  portmapper
       100000    2   udp    111  portmapper
       100024    1   udp  47279  status
       100024    1   tcp  46205  status
       100005    1   udp  20048  mountd
       100005    1   tcp  20048  mountd
       100005    2   udp  20048  mountd
       100005    2   tcp  20048  mountd
       100005    3   udp  20048  mountd
       100005    3   tcp  20048  mountd
       100003    3   tcp   2049  nfs
       100003    4   tcp   2049  nfs
       100227    3   tcp   2049  nfs_acl
       100003    3   udp   2049  nfs
       100003    4   udp   2049  nfs
       100227    3   udp   2049  nfs_acl
   ```

4. nfs服务端配置
   
   ```shell
   [root@storage ~]# cat /etc/exports
   /data/    172.16.1.0/24(rw)
   需要共享的位置   允许读写/data/的IP网段
   ```
   
   重启nfs
   [root@storage ~]# systemctl reload nfs

```
5. 创建共享文件夹并修改权限

```shell
[root@storage ~]# mkdir -p /data/
[root@storage /]# ll -d /data/
drwxr-xr-x 2 root root 6 Apr 10 19:10 /data/

nfsnobody用户为nfs自动创建；
将共享文件及的权限给nfsnobody；
[root@storage /]# id nfsnobody
uid=65534(nfsnobody) gid=65534(nfsnobody) groups=65534(nfsnobody)

更改权限
[root@storage /]# chown -R nfsnobody.nfsnobody /data/
[root@storage /]# ll -d /data/
drwxr-xr-x 2 nfsnobody nfsnobody 6 Apr 10 19:10 /data/
```

6. 服务端本地测试

7.    客户端永久挂载
   
   方式1.  挂载命令写到 /etc/rc.local
   
   ```shell
   chmod +x /etc/rc.d/rc.local
   ```

        方式2. 按照 /etc/fstab格式书写

        设备                 挂载点    文件系统类型   挂载参数   是否检查  是否备份
     172.16.1.214:/data/   /upload/     nfs       defaults    0       0

>  配置了客户端永久挂载，必须检查nfs服务端是否已经启动；必须先启动服务端再启动客户端，否则会出现异常！！！

NFS配置文件选项

| 配置选项  | 说明                                             |
| ----- | ---------------------------------------------- |
| rw    | 可以读写                                           |
| ro    | 只读 read only                                   |
| sync  | 同步，只要用户上传，就把数据写到磁盘上.                           |
| async | 异步,用户上传的数据,nfs先临时存放到内存中,过一段时间写入到磁盘。 并发高,数据可能丢失 |

```shell
/nfsdata/ 172.16.1.0/24(rw,all_squash,anonuid=9999,anongid=9999)
```
