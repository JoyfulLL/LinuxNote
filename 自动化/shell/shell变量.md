- 变量定义与赋值，变量与值之间不能有空格
```shell
name="哇"

# bash默认将所有的变量值认为是字符串
```
---
- 变量引用
```shell
echo $name
echo ${name}
```
---
- 变量名规则
	- 只能以字母下划线开头，只能包含数字字母下划线
	- 不能以数字开头，不能包含标点符号
	- 不得引用保留关键字（使用help检查保留关键字）
	- 严格区分大小写

```shell
[root@Vue ~]# _music=wow
[root@Vue ~]# _Music=WOW
[root@Vue ~]# echo $_music
wow
[root@Vue ~]# echo $_Music
WOW
```
---
- 变量作用域
父级shell进程定义的变量，无法给子shell进程使用。

![](attachments/Pasted%20image%2020240530110353.png)

- [环境变量](#环境变量)（全局变量）：有自定义和内置环境变量
```shell
echo $PATH
```

- 局部变量：在`shell脚本`中或是`shell函数`中定义
---
- 位置参数变量：用于传递参数
---
- 特殊状态变量：shell内置的特殊功效变量
	- `$?`
		- 0：上一条命令运行成功
		- 1-255：上一条命令运行失败
	- `$$`
		- 获取当前shell脚本的进程号
	- `$!`
		- 上一次后台进程的PID
	- `$_`
		- 上一次命令传入的最后一个参数

![](attachments/Pasted%20image%2020240530111111.png)



**父子进程面试题**
```shell
[root@Vue ~]# cat test.sh 
user1=`whoami`
[root@Vue ~]# bash test.sh
[root@Vue ~]# echo $user1

[root@Vue ~]# source test.sh
[root@Vue ~]# echo $user1
root
```

为什么第一次运行脚本，无法取得user变量的值？
- 解答：
	- 每次调用bash/sh解释器执行脚本，都会开启一个子shell进程，当这个脚本运行结束，shell子进程就结束，因此不会保留子进程的shell变量。
	- 调用`source`或者`.`号，会在当前的shell环境加载脚本，因此会保留变量



## 环境变量 
- 用户个人配置文件：`~/.bash_profile`；`./bashrc`为远程登录用户特有文件
- 全局配置文件：`/etc/profile`、`/etc/bashrc`
- 依据Linux系统建议，用户自定义的环境变量应当放到`/etc/profile.d`目录下

>变量文件读取顺序：先读取`/etc/profile`，然后读取`/etc/profile.d`。若变量相同，则用变量覆盖全局变量。之后运行用户`$HOME/.bash_profile`，运行`$HOME/.bashrc`

---
**检测系统环境变量**
- set：输出所有变量，包括环境变量，局部变量
- env：只显示全局变量
- declare：与set相同
- export：显示和设置环境变量

**撤销环境变量**
- unset+变量名


**设置只读变量**
```shell
[root@Vue ~]# readonly passwd=123
[root@Vue ~]# echo $passwd
123
[root@Vue ~]# passwd=456
-bash: passwd: readonly variable
```

>只读变量设置后，不可更改，只有shell结束之后，只读变量失效



## 特殊变量
**参数传递**
```bash
[root@Vue ~]# cat special_var.sh 
#! /bin/bash
echo '特殊变量 $0 $1 $2的实践测试'
echo '结果:'   $0 $1 $2

echo '#################'
echo '特殊变量 $# 获取参数总个数'
echo '结果:'   $#

echo '#################'
echo '特殊变量 $*'
echo '结果:'   $*

echo '#################'
echo '特殊变量 $@'
echo '结果:'   $@

[root@Vue ~]# bash special_var.sh ABig 666 wow ovo
特殊变量 $0 $1 $2的实践测试
结果: special_var.sh ABig 666
#################
特殊变量 $# 获取参数总个数
结果: 4
#################
特殊变量 $*
结果: ABig 666 wow ovo
#################
特殊变量 $@
结果: ABig 666 wow ovo
```

>面试题：`$*`与`$@`的区别
>
>当这两个特殊变量不被双引号`""`包围的时候，它们之间没有区别，都是将接收到的每个参数看作一份数据，彼此之间用空格分割
>
>当它们被双引号`""`包起来后，就有区别
>
>`$*`会将所有的参数看出一个整体，而不会将一个个参数分离
>
>`$@`依然将所有的参数看成一个个的个体，彼此独立
>
>例如传递5个参数，对于`"$*"`来说，5个参数会被合在一起看成一个整体形成一份数据
>
>而`"$@"`依旧是5个参数
>
>使用echo无法输出`"$*"`和`"$@"`的区别；可以使用for循环代替
>


```shell
# 测试代码
[root@Vue ~]# cat test.sh 
#! /bin/bash
echo "print each param from \"\$*\""
for var in "$*"
do
	echo "$var"
done

echo "#####################"

echo "print each param from \"\$@\""
for var in "$@"
do
	echo "$var"
done


[root@Vue ~]# bash test.sh Abig 616 111 333
print each param from "$*"
Abig 616 111 333
#####################
print each param from "$@"
Abig
616
111
333
```

