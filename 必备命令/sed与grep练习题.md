[正则与grep](正则与grep.md)
[三剑客之sed](三剑客之sed.md)

### 过滤出/etc/passwd中包含root或nobody的行

```shell
egrep 'root|nobody' /etc/passwd
sed -rn '/root|nobody/p' /etc/passwd
```

### 过滤出/etc/passwd中以root开头的行
```shell
egrep '^root' /etc/passwd
sed -n '/^root/p' /etc/passwd
```

### 在/etc/ssh/sshd_config中过滤出包含permitrootlogin或usedns的行（忽略大小写）
```shell
egrep -i 'permitrootlogin|usedns' /etc/ssh/sshd_config
```
>`egrep -i`忽略大小写

```shell
[root@Vue ~]# sed -rn '/permitrootlogin|noboduy/Ip'  /etc/ssh/sshd_config
```
>sed的`I`用于忽略大小写

### 取出/etc/passwd中以bash结尾的行
```shell
egrep '.*bash$' /etc/passwd
sed -n '/.*bash$/p' /etc/passwd
```

### 显示/etc目录下第一层以conf结尾的文件
```shell
ls /etc/ | grep '\.conf$'
find /etc/ -maxdepth 1 -type f -name "*.conf"
```

>以下find命令会找出/etc下的所有conf文件，并非第一层
>
>需要规定最大深度为1，如上

```shell
find /etc/ -type f -name "*.conf"
```

### 取出/etc/passwd中第一列的用户名
```shell
awk -F: '{print $1}' /etc/passwd

egrep -o '^[a-zA-Z0-9\-]+' /etc/passwd
# [^]取反，取出非：开头的所有
egrep -o '^[^:]+' /etc/passwd

# 找出：后面的所有并抛弃，结果即为第一列的用户名
sed 's#:.*##g' /etc/passwd
sed反向应用
```


### 查看文件1-3行；查看文件最后一行
```shell
# 查看文件1-3行
sed -n '1,3p' num.txt
head -3 num.txt

# 文件查看最后一行
tail -1 num.txt
sed -n '$p' num.txt
```

![](attachments/Pasted%20image%2020240526162333.png)



### 找出/etc下所有以.conf结尾的文件，然后过滤出包含Linux的行
[find与其他命令配合使用](find命令.md#find与其他命令配合使用)

```shell
# 经典写法，find 配合 xargs grep 
find /etc/ -type f -name "*.conf" | xargs grep -i 'linux'
# 反引号优先执行法
grep -i 'linux' ` find /etc/ -type f -name "*.conf"`

grep -i 'linux' $(find /etc/ -type f -name "*.conf")
find /etc/ -type f -name "*.conf" -exec grep -i 'linux' {} \;
```

### 取出/etc/passwd文件中每个字符并统计每个字符出现的次数，取前10名
```shell
[root@Vue ~]# grep -o '.' /etc/passwd | sort | uniq -c | sort -rn | head
    198 :
    133 n
    128 /
    122 s
    119 o
    110 i
     78 e
     70 r
     65 b
     64 l
```


### 取出/etc/passwd文件中每个单词并统计每个字符出现的次数，取前10名
```shell
[root@Vue ~]# egrep -o '[a-Z]+' /etc/passwd | sort | uniq -c | sort -rn | head
     33 x
     33 sbin
     27 nologin
     10 var
      7 usr
      7 bin
      6 User
      6 for
      5 lib
      4 systemd
```
