[[正则与grep]]
# find命令

基本选项

| 命令选项 | 说明                                                 |
| -------- | ---------------------------------------------------- |
| -type    | 文件类型  f代表文件  d代表目录                       |
| -name    | 文件名                                               |
| -size    | 根据大小找文件  +表示大于 -表示小于  +10k  +10M -10G |
| -mtime   | 依据修改时间查找                                     |

## 基础案例⭐⭐⭐⭐⭐

> 精确查找与模糊查找
>
> find 目录  指定类型   指定名字

```shell
root@server:~# find /etc/ -type f -name 'hostname'
/etc/hostname
```

```shell
模糊查找

# 查找以conf结尾的文件
root@server:~# find /etc/ -type f -name '*.conf'
/etc/initramfs-tools/initramfs.conf
/etc/initramfs-tools/update-initramfs.conf

# 查找文件名包含ansible的文件
[root@manager ~]# find / -type f -name '*ansible*'
/etc/ansible/ansible.cfg.rpmsave
/etc/ansible/ansible.cfg

# 查找文件名为cat开头的文件
root@manager ~]# find / -type f -name 'cat*'
/boot/grub2/i386-pc/cat.mod
/var/lib/snapd/snap/core18/2812/bin/cat
```

> 依据大小查找
>
> -size +10k 大于10k的文件 
>
> -size -10M 小于10MB的文件

```shell
# 查找大于500kb的文件
[root@manager ~]# find /etc/ -type f -size +500k
/etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt
/etc/udev/hwdb.bin
```

> 根据时间查找
>
> 一般根据文件的修改时间进行查找
>
> 主要用于查找系统日志，7天前的文件
>
> -mtime +7 修改时间为7天之前的文件   -mtime -7 最近7天内修改过的
>
> 单位为“天”

```shell
# 查找以conf结尾的，7天之前修改的文件
[abig@manager ~]$ find /etc/ -type f -name '*.conf' -mtime +7
/etc/pki/ca-trust/ca-legacy.conf
/etc/yum/pluginconf.d/fastestmirror.conf

# 查找10年前的文件
[abig@manager ~]$ find /etc/ -type f  -mtime +3650
/etc/logrotate.conf
/etc/exports
```

## 进阶选项

```shell
# 查找的时候指定最多查找几层目录
[abig@manager ~]$ find / -maxdepth 2 -type f -name '*.conf'
/etc/resolv.conf
/etc/asound.conf
/etc/logrotate.conf

# 忽略文件名的大小写 -iname
[abig@manager ~]$ find / -maxdepth 3 -type f -iname '*.conf'
/run/NetworkManager/resolv.conf
/run/NetworkManager/no-stub-resolv.conf
```



# find与其他命令配合使用

- 例子
  - 核心：find+简单命令：find找出想要删除的文件，看详细信息，显示文件内容
  - find+打包压缩： find找出文件后进行打包压缩
  - find+cp/mv： find找出文件后复制或移动



## 案例环境

```shell
[abig@manager ~]$ ls /tmp/test/find/
Hello01.txt  Hello03.txt  Hello05.txt  Hello07.txt  Hello09.txt
Hello02.txt  Hello04.txt  Hello06.txt  Hello08.txt  Hello10.txt
```

### 案例一：核心操作⭐⭐⭐⭐⭐

> find+ls
>
> find+rm
>
> find+cat/head/tail
>
> find+grep
>
> find不能与交互式的命令结合，如find+vim :x:

```shell
[abig@manager /tmp]$ ls -lh `find /tmp/test/find/ -type f -name '*.txt'`
-rw-r--r-- 1 root root 0 May 11 16:59 /tmp/test/find/Hello01.txt
-rw-r--r-- 1 root root 0 May 11 16:59 /tmp/test/find/Hello02.txt

下面的方法无法生效，因为管道后传递的是字符串
[abig@manager ~]$ find /tmp/test/find/ -type f -name '*.txt' | ls -l
total 0

加上xargs后生效，因为转换为了参数，因此生效
[abig@manager ~]$ find /tmp/test/find/ -type f -name '*.txt' | xargs ls -l
-rw-r--r-- 1 root root 0 May 11 16:59 /tmp/test/find/Hello01.txt
-rw-r--r-- 1 root root 0 May 11 16:59 /tmp/test/find/Hello02.txt

！xargs 后面没办法使用 ll 命令
[abig@manager ~]$ find /tmp/test/find/ -type f -name '*.txt' |xargs ll
xargs: ll: Permission denied

[root@manager ~]# find /tmp/test/find/ -type f -name '*.txt' |xargs ll
xargs: ll: No such file or directory

```

> find命令与其他命令结合，可以使用反引号，也可以使用管道
>
> 其他命令也类似，如cat，grep等

```shell
反引号以及管道均可

[abig@manager ~]$ echo hello 09 > /tmp/test/find/Hello09.txt
[abig@manager ~]$ echo hello 10 > /tmp/test/find/Hello10.txt
[abig@manager ~]$ cat `find /tmp/test/find/ -type f -name '*.txt'`
hello 09
Hello 10

[abig@manager ~]$ find /tmp/test/find/ -type f -name '*.txt' | xargs cat
hello 09
Hello 10
```

### 案例二：打包与压缩⭐⭐⭐

```shell
[abig@manager ~]$ tar zcf /tmp/find.tar.gz `find /tmp/test/find/ -type f -name '*.txt'`
tar: Removing leading `/' from member names
[abig@manager ~]$ tar tf /tmp/find.tar.gz
tmp/test/find/Hello01.txt
tmp/test/find/Hello02.txt

[abig@manager ~]$ find /tmp/test/find/ -type f -name '*.txt' | xargs tar zcf /tmp/find-xrags.tar.gz
tar: Removing leading `/' from member names
[abig@manager ~]$ tar tf /tmp/find-xrags.tar.gz
tmp/test/find/Hello01.txt
tmp/test/find/Hello02.txt

[abig@manager ~]$ find /tmp/test/find/ -type f -name '*.txt' -exec tar zcf /tmp/find-exec.tar.gz {} +
tar: Removing leading `/' from member names
[abig@manager ~]$ tar tf /tmp/find-exec.tar.gz
tmp/test/find/Hello01.txt
tmp/test/find/Hello02.txt
# 使用 + 之后，exec会在find找到所有符合条件的文件之后再执行后续的命令（tar）
```

使用-exec的时候，需要注意格式  + 号结尾不需要分号;   \结尾需要加分号;

```shell
与 + 号不同的是，  \; 的意思是每次找到一个文件就执行后面的命令，执行10次
因为压缩包的名字都一样，所以前面的9个都被覆盖，仅剩最后一个，解压的时候里面也只有一个文件
[abig@manager ~]$ find /tmp/test/find/ -type f -name '*.txt' -exec tar zcf /tmp/find-exec.tar.gz {} \;
tar: Removing leading `/' from member names
tar: Removing leading `/' from member names
tar: Removing leading `/' from member names
tar: Removing leading `/' from member names
tar: Removing leading `/' from member names
tar: Removing leading `/' from member names
tar: Removing leading `/' from member names
tar: Removing leading `/' from member names
tar: Removing leading `/' from member names
tar: Removing leading `/' from member names
[abig@manager ~]$ tar tf /tmp/find-exec.tar.gz
tmp/test/find/Hello10.txt

正确的使用-exec进行打包压缩的方法在上面
```

### 案例三：复制或移动

- 方法1：find + ``

```shell
cp 源 源 源 目标

[abig@manager ~]$ cp -a `find /tmp/test/find/ -type f -name '*.txt'`  /tmp/
[abig@manager ~]$ ll /tmp/
total 8
-rwxrwxrwx 1 abig abig  0 May 11 16:59 Hello01.txt
-rwxrwxrwx 1 abig abig  0 May 11 16:59 Hello02.txt
```

- 方法2：find + | xargs

```shell
find xxx  | xargs cp -t /tmp/(要存放的路径)
不加 -t 会报错

[abig@manager ~]$ find /tmp/test/find/ -type f -name '*.txt' | xargs cp -t /tmp/
[abig@manager ~]$ ll /tmp/
total 8
-rwxrwxr-x 1 abig abig  0 May 11 20:17 Hello01.txt
-rwxrwxr-x 1 abig abig  0 May 11 20:17 Hello02.txt
```

> cp命令
>
> ```shell
> 1.原始cp 源文件 源文件 源文件 。。。  目标
> [abig@manager ~]$ cp /etc/hosts /etc/hostname   /tmp/
> [abig@manager ~]$ ll /tmp/
> total 16
> -rw-r--r-- 1 abig abig  8 May 11 20:21 hostname
> -rw-r--r-- 1 abig abig 94 May 11 20:21 hosts
> 
> 2. -t 选项cp -t 目标 源文件 源文件 源文件 。。。
> [abig@manager ~]$ cp -t /tmp/ /etc/hosts /etc/hostname
> ```
>
> 两条命令执行的结果是一致的

- 方法3：find + -exec

```shell
find /path/to/source -name "filename.txt" -exec cp {} /path/to/destination \;

[abig@manager ~]$ find /tmp/test/find/ -type f -name '*.txt' -exec cp {} /tmp/  \;
[abig@manager ~]$ ll /tmp/
total 8
-rwxrwxr-x 1 abig abig  0 May 11 20:27 Hello01.txt
-rwxrwxr-x 1 abig abig  0 May 11 20:27 Hello02.txt
```



# find小结

- find根据类型，名字，大小，修改时间进行查找⭐⭐⭐⭐⭐
- find与常用命令搭配，如：ls，rm，sed⭐⭐⭐⭐⭐
- find与打包压缩
- find与复制或移动



