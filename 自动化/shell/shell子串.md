## 基础语法
==支持正则与通配符==
[正则与grep](../../必备命令/正则与grep.md)

1. **提取子串**：
    - `${string}`：返回变量值，是`echo $string`的完整写法
    - `${#string}`：返回变量长度；字符串长度
    - `${string:start}`：提取从指定起始位置到字符串末尾的子串==(从0开始数)==
    - `${string:start:length}`：提取从指定起始位置开始指定长度的子串
2. **删除子串**：从前匹配从前删，从后匹配从后删
    - `${string#substring}`：删除字符串==开头==最短匹配的子串
    - `${string##substring}`：删除字符串==开头==最长匹配的子串
    - `${string%substring}`：删除字符串==末尾==最短匹配的子串
    - `${string%%substring}`：删除字符串==末尾==最长匹配的子串
3. **替换子串**：
    - `${string/substring/replacement}`：将第一个匹配的子串替换为指定的字符串
    - `${string//substring/replacement}`：将所有匹配的子串替换为指定的字符串

```bash
[root@Vue ~]# string="Hello, World!"
[root@Vue ~]# echo ${string}     # 输出 "Hello, World!"
Hello, World!
[root@Vue ~]# echo ${#string}     # 输出 "13"
13
[root@Vue ~]# echo ${string:7}    # 输出 "World!"
World!
[root@Vue ~]# echo ${string:7:5}  # 输出 "World"
World
[root@Vue ~]# echo ${string#Hello}    # 输出 ", World!"
, World!
[root@Vue ~]# echo ${string##H*o}     # 输出 "rld!"
rld!
[root@Vue ~]# echo ${string%!*}       
echo ${string%} 
Hello, World!
[root@Vue ~]# echo ${string%o*}       # 输出 "Hello, W"；最短匹配
Hello, W
[root@Vue ~]# echo ${string%%o*}      # 输出 "Hell"；最长匹配
Hell
[root@Vue ~]# echo ${string/o/123}         # 输出 "Hell123, W123rld!"
Hell123, World!
[root@Vue ~]# echo ${string//o/123}        # 输出 "Hell123, W123rld!"
Hell123, W123rld!
```

---
# 案例：
## 统计命令长度
### 利用`wc`命令统计
```shell
[root@Vue ~]# cat test.txt 
123
123456
123456789
[root@Vue ~]# cat test.txt | wc -l
3
[root@Vue ~]# cat test.txt | wc -L
9
```

>`wc -l`统计文件的行数
>
>`wc -L`统计文件中最长的一行的字符串个数


### 利用数值计算`expr`命令

```shell
[root@Vue ~]# string="Hello, World!"
[root@Vue ~]# expr length "${string}"
13
```

### 使用`awk`命令的length函数

[awk取行](../../必备命令/三剑客之awk.md#awk取行)

```shell
[root@Vue ~]# echo ${string} | awk '{print length($0)}'
13
```

>`$0`表示第一行

### 最快统计字符串长度的方法
```shell
[root@Vue ~]# echo ${#string}
13
```

## 统计命令执行时间
### for循环语法
```shell
[root@Vue ~]# for n in {1..3};do char=`seq -s ":" 10`;echo ${char};done
1:2:3:4:5:6:7:8:9:10
1:2:3:4:5:6:7:8:9:10
1:2:3:4:5:6:7:8:9:10
```

### 结合time命令 ，使用内置命令`${#string}`，统计字符串长度
命令执行时间为15S
```shell
[root@Vue ~]# time for n in {1..10000};do char=`seq -s "abig" 100`;echo ${#char} &>/dev/null; done

real	0m15.217s    # 实际运行耗时
user	0m5.223s     # 用户态执行耗时 
sys	0m9.890s         # 内核态执行耗时 

# 可以将一条命令改写成shell脚本，去掉;即可
[root@Vue ~]# cat time.sh 
time for n in {1..10000}
do char=`seq -s "abig" 100`
	echo ${#char} &>/dev/null
done
[root@Vue ~]# bash time.sh 

real	0m12.457s
user	0m4.415s
sys	0m7.910s
```

### 使用`wc -L`
命令执行时间为31S
```shell
[root@Vue ~]# time for n in {1..10000};do char=`seq -s "abig" 100`;echo ${char} | wc -L &>/dev/null; done

real	0m31.001s
user	0m11.821s
sys	0m23.582s
```

>因为使用了管道符，所以执行时间必然增加

### 使用expr的length函数
命令执行时间为29S
```shell
[root@Vue ~]# time for n in {1..10000};do char=`seq -s "abig" 100`;expr length "${char}" &>/dev/null; done

real	0m28.626s
user	0m9.566s
sys	0m19.065s
```

### 使用awk命令统计字符串长度
命令执行时间为41秒

```shell
[root@Vue ~]# time for n in {1..10000};do char=`seq -s "abig" 100`; echo $char | awk '{print length($)}' &>/dev/null; done

real	0m41.021s
user	0m16.911s
sys	0m28.135s
```

### 小结
shell编程中，命令执行效率最高的是Linux的内置命令、内置操作、内置函数。编程中尽量使用内置的
尽可能减少管道符操作


## 子串截取删除
### 截取删除案例

```shell
[root@Vue ~]# char=abc123ABC123abc
[root@Vue ~]# echo ${char%a*c}
abc123ABC123
[root@Vue ~]# echo ${char%%a*c}

[root@Vue ~]# echo ${char#a*c}
123ABC123abc
[root@Vue ~]# echo ${char##a*c}

[root@Vue ~]# 
[root@Vue ~]# echo ${char%a*1}
abc123ABC123abc
[root@Vue ~]# echo ${char%%a*1}
abc123ABC123abc
[root@Vue ~]# echo ${char%%a*b}
abc123ABC123abc
[root@Vue ~]# echo ${char%%ab}
abc123ABC123abc
[root@Vue ~]# echo ${char%%ac}
abc123ABC123abc
[root@Vue ~]# echo ${char%%c}
abc123ABC123ab
[root@Vue ~]# echo ${char%%1*c}
abc
[root@Vue ~]# echo ${char%%1*b}
abc123ABC123abc
```

>对于末尾匹配，`%%`的结尾必须是最后一个字符，否则匹配不上


## 批量修改文件名
创建测试文件
```shell
touch abig{1..5}_finished.jpg
touch abig{1..5}_finished.png

ll
-rw-r--r-- 1 root root 0 Jun  2 15:55 abig1_finished.jpg
-rw-r--r-- 1 root root 0 Jun  2 15:55 abig1_finished.png
-rw-r--r-- 1 root root 0 Jun  2 15:55 abig2_finished.jpg
-rw-r--r-- 1 root root 0 Jun  2 15:55 abig2_finished.png
-rw-r--r-- 1 root root 0 Jun  2 15:55 abig3_finished.jpg
-rw-r--r-- 1 root root 0 Jun  2 15:55 abig3_finished.png
-rw-r--r-- 1 root root 0 Jun  2 15:55 abig4_finished.jpg
-rw-r--r-- 1 root root 0 Jun  2 15:55 abig4_finished.png
-rw-r--r-- 1 root root 0 Jun  2 15:55 abig5_finished.jpg
-rw-r--r-- 1 root root 0 Jun  2 15:55 abig5_finished.png
```

### 1.修改单个文件的文件名
```shell
[root@Vue /tmp]# mv abig1_finished.jpg abig1.jpg
[root@Vue /tmp]# ll
total 0
-rw-r--r-- 1 root root 0 Jun  2 15:55 abig1_finished.png
-rw-r--r-- 1 root root 0 Jun  2 15:55 abig1.jpg
```
### 2.利用变量的子串功能，去掉字符信息
```shell
[root@Vue /tmp]# f=abig1_finished.png
[root@Vue /tmp]# echo ${f//_finished/}
abig1.png
# 仅为模拟，并未真是改变文件名
[root@Vue /tmp]# echo $f
abig1_finished.png
```
### 3.利用反引号
```shell
[root@Vue /tmp]# echo $f
abig1_finished.png
[root@Vue /tmp]# mv $f `echo ${f//_finished/}`
[root@Vue /tmp]# ll
total 0
-rw-r--r-- 1 root root 0 Jun  2 15:55 abig1.jpg
-rw-r--r-- 1 root root 0 Jun  2 15:55 abig1.png
-rw-r--r-- 1 root root 0 Jun  2 15:55 abig2_finished.jpg
-rw-r--r-- 1 root root 0 Jun  2 15:55 abig2_finished.png
-rw-r--r-- 1 root root 0 Jun  2 15:55 abig3_finished.jpg
-rw-r--r-- 1 root root 0 Jun  2 15:55 abig3_finished.png
-rw-r--r-- 1 root root 0 Jun  2 15:55 abig4_finished.jpg
-rw-r--r-- 1 root root 0 Jun  2 15:55 abig4_finished.png
-rw-r--r-- 1 root root 0 Jun  2 15:55 abig5_finished.jpg
-rw-r--r-- 1 root root 0 Jun  2 15:55 abig5_finished.png
```

>反引号内实现了第2步的效果，去掉了字符信息，然后将更改后的字符信息作为新文件名

### 4.去掉所有png后缀的`_finished`字符
```shell
# 筛选出带有_finished的png文件
[root@Vue /tmp]# ls *fin*.png
abig2_finished.png  abig3_finished.png  abig4_finished.png  abig5_finished.png
[root@Vue /tmp]# for file_name in `ls *fin*.png`; do mv $file_name `echo ${file_name//_finished/}` ;done
[root@Vue /tmp]# ls *.png
abig1.png  abig2.png  abig3.png  abig4.png  abig5.png
```

可以转换成脚本去执行，但是只有一个for循环，且并不复杂；可以但没必要。
```bash
#! /bin/bash

for file_name in `ls *fin*.png`
do mv $file_name `echo ${file_name//_finished/}` 
done
```

>注意！
>
>执行mv操作的时候，不能去掉反引号内的echo，否则会报错，提示没有这个命令。
>

![](attachments/Pasted%20image%2020240602162018.png)