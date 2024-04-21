# Ansible优化

**性能优化**

- ssh连接速度优化,关闭UseDNS,GSSAPIAuthcation
- 不要让ansible运行交互式的命令,非要用使用命令的非交互模式，
- 需要yum安装本地安装.(自建yum源,自己制作的rpm包)
- 调整ansible并发数量(-f 调整并发数量 默认是5   ansible.cfq forks=5,实际调整根据负载情况·)
- 给ansible配置缓存（redis），队列
- 给主机进行分组操作
- 不使用facts变量，可以将gather_facts关闭。剧本中：gather_facts: false  配置文件：gathering = explicit



**安全** ::star:

- 配置sudo用户   被管理端添加ansible用户，输入visudo编辑文件，添加
- ansible ALL=(ALL)   NOPASSWD:ALL

![image-20240421173519782](C:\Users\ljf13\AppData\Roaming\Typora\typora-user-images\image-20240421173519782.png)

```shell
管理端
[root@m1 /]# egrep -v '^$|#' /etc/ansible/ansible.cfg 
[defaults]
sudo_user      = ansible  ##被管理端上具有sudo权限的用户  nopasswd: ALL
remote_user    = ansible  ##被管理端使用的用户
remote_port    = 22       ##被管理端SSH端口号
host_key_checking = False
log_path = /var/log/ansible.log
[inventory]
[privilege_escalation]
become=True               ##开启sudo功能
become_method=sudo        ##使用sudo命令
become_user=root          ##普通用户切换为root
[paramiko_connection]
[ssh_connection]
[persistent_connection]
[accelerate]
[selinux]
[colors]
[diff]
```

配置完成，需要将密钥发送给ansible

```shell
[root@m1 /]# ssh-copy-id ansible@web
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/root/.ssh/id_rsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
ansible@web's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'ansible@web'"
and check to make sure that only the key(s) you wanted were added.
```

