[[正则与grep]]

## 🔔sed使用正则，需要`//`

## 1.sed查找
### 1.1取出文件中的某一行`sed -n '3p'`⭐⭐⭐⭐⭐
```shell
[root@Vue ~]# sed -n '3p' /etc/passwd
daemon:x:2:2:daemon:/sbin:/sbin/nologin
```

### 1.2取出第二行到第五行`sed -n '2,5p'`⭐⭐⭐⭐⭐

```shell
[root@Vue ~]# sed -n '2,5p' /etc/passwd
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
```

### 1.3过滤出`/etc/passwd`中包含`root`的行⭐⭐⭐⭐⭐

```shell
[root@Vue ~]# sed -n '/root/p' /etc/passwd
root:x:0:0:root:/root:/bin/bash
operator:x:11:0:operator:/root:/sbin/nologin
```

筛选出root开头的行

```shell
[root@Vue ~]# sed -n '/^root/p' /etc/passwd
root:x:0:0:root:/root:/bin/bash
```

>sed进行过滤时，需要使用`//`并且里面仅支持基础正则
>
>需要拓展正则，要使用`sed -r`

### 1.4获取范围内的日志⭐⭐⭐⭐⭐

查看特定时间节点的日志
![](attachments/Pasted%20image%2020240525203926.png)

>`sed -n '/start/,/end/p' filename`


### 1.5只显示第3行和第23行
```shell
[root@Vue /var/log]# sed -n '3p;23p' mysqld.log
```

## 2.sed替换修改
### 2.1sed基础替换修改⭐⭐⭐⭐⭐

>替换使用`sed 's#将什么#替换成什么#g' filename`
>
>s代表substitute，g代表global，合起来意思为全局替换
>
>中间的三个#可以替换成任意3个相同的字符，如111，QQQ，@@@，///等等
>
>上面的操作不加`-i`选项，将不会进行实际的替换
>
>`sed -i.backup`选项，可以为sed替换做最后的保险，先备份后替换
```shell
[root@Vue ~]# cat extend.txt
my qq is 123000003

# 将qq替换成weixin
[root@Vue ~]# sed  's#qq#weixin#g' extend.txt
my weixin is 123000003
[root@Vue ~]# sed -i 's#qq#weixin#g' extend.txt
[root@Vue ~]# cat extend.txt
my weixin is 123000003

# 先备份为.backup然后进行替换修改，将微信替换成ins
[root@Vue ~]# sed -i.backup 's#weixin#ins#g' extend.txt
[root@Vue ~]# ls
extend.txt  extend.txt.backup
[root@Vue ~]# cat extend.txt
my ins is 123000003
[root@Vue ~]# cat extend.txt.backup
my weixin is 123000003
```

### 2.2sed进阶替换[sed反向引用](正则与grep.md#^7fa4b4)
>反向引用的格式：
>
>使用替换形式：`s###g`
>
>第1，2个##通过正则与()进行分组
>
>第2，3个##之间通过`\数字`，获取前面分组的内容，如`\1`获取第一组
>
>应用场景：对某一行中部分数据进行处理，提取某一部分数据

#### 基本使用

```shell
将12345679加工成1<2345678>9
[root@Vue ~]# echo 123456789 |sed -r 's#(1)(.*)(9)#\1<\2>\3#g'
1<2345678>9
```

#### 经典案例：调换/etc/passwd文件第一列和最后一列

```shell
[root@Vue ~]# cat passwd
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
```

分析可知，第一列是用户名，第二列是权限，第三组为命令解析器

```shell
# 取出第一列
[root@Vue ~]# sed -r 's#(.*)(:x.*:)(.*)#\1#g' passwd
root
bin

# 第三列
[root@Vue ~]# sed -r 's#(.*)(:x.*:)(.*)#\3#g' passwd
/bin/bash
/sbin/nologin

# 将1，3对换位置
[root@Vue ~]# sed -r 's#(.*)(:x.*:)(.*)#\3\2\1#g' passwd
/bin/bash:x:0:0:root:/root:root
/sbin/nologin:x:1:1:bin:/bin:bin
```

>如果第二个分组中，没有`:x`，根据正则的贪婪性质，第一个分组将会分割到最后一个：
>
>才停止分割，生成第一组。
>
>> ```shell
>> [root@Vue ~]# sed -r 's#(.*)(:.*:)(.*)#\1#g' passwd
>> root:x:0:0:root
>> ```
>


```shell
[root@Vue ~]# sed -r 's#^([a-zA-Z0-9_-]+)(:.*:)(.*)#\1#g' passwd
```

![](attachments/Pasted%20image%2020240526111649.png)

#### 经典案例：取出eth0的IP地址⭐⭐⭐⭐⭐

```shell
[root@Vue ~]# ip add show eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:16:3e:03:5b:35 brd ff:ff:ff:ff:ff:ff
    altname enp0s5
    altname ens5
    inet 172.16.130.168/20 brd 172.16.143.255 scope global dynamic noprefixroute eth0
       valid_lft 314426501sec preferred_lft 314426501sec
    inet6 fe80::216:3eff:fe03:5b35/64 scope link
       valid_lft forever preferred_lft forever

[root@Vue ~]# ip add show eth0| sed -n '5p' | sed -r 's#^(.*et )(.*)(/.*$)#\2#g'
172.16.130.168
[root@Vue ~]# ip add show eth0| sed -n '5p' | sed -r 's#^.*et (.*)/.*$#\1#g'
172.16.130.168
```

>需要取出的数据用()包起来，不需要的数据可以不用()


## 3.sed删除

- sed删除功能依据`行`作为单位

```shell
[root@Vue ~]# cat extend.txt
my ins is 123000003
789789789

# 删除第二行
[root@Vue ~]# sed '2d' extend.txt
my ins is 123000003
[root@Vue ~]# sed -i '2d' extend.txt
```

### 经典案例：排除配置文件中的#注释和空行

```shell
[root@Vue ~]# egrep -v '^$|#' /etc/ssh/sshd_config
[root@Vue ~]# sed -r '/^$|#/d' /etc/ssh/sshd_config
[root@Vue ~]# awk '! /^$|#/' /etc/ssh/sshd_config
```


## 4.sed添加、追加

- 3个选项，cia
	- c：替换
	- i：在指定的行上插入内容
	- a：在指定的行后追加内容