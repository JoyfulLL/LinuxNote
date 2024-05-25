[[正则与grep]]

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

### 2.2sed进阶替换[sed反向引用](正则与grep.md#3.%20`()`表示一个整体，用于后向引用（sed反向引用）)
