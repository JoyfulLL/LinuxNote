[[正则与grep]]

# awk

| 四剑客  | 特点                  | 擅长           |
| ---- | ------------------- | ------------ |
| find | 查找文件                | 查找文件         |
| grep | 过滤速度最快              | 过滤           |
| sed  | 过滤、取行、替换、删除         | 替换，修改文件内容，取行 |
| awk  | 过滤、取行、取列、统计计算、判断、循环 | 取行、取列、统计计算   |

## awk命令格式
```shell
# awk 选项 '条件{动作}' 路径
# 找/etc/passwd的第一行的第一列第三列与最后一列
awk  -F:  'NR==1{print $1,$3,$NF}' /etc/passwd
```

## awk取行

⭐⭐⭐⭐⭐

>NR意思为`Number of Record`行号
>
>`==`表示等于
>
>`{print $0}`输出整行内容，$0表示当前行的内容
>
>仅取行还能简写为`awk 'NR==1' /etc/passwd`

### 取第二行到第五行的内容
```shell
awk  'NR>=2 && NR<=5' /etc/passwd
```


### 过滤出/etc/passwd包含root或nobody的行
```shell
awk  '/root|nobody/' /etc/passwd
```

### 取出从包含root到nobody的行
```shell
awk  '/root/,/nobody/' /etc/passwd
```

### 小结
- awk + NR 取出指定的行，指定范围的行
- awk + // 过滤


## awk取列

⭐⭐⭐⭐⭐

### 取出`ls -lh`的大小列与最后一列
```shell
ls -lh | awk '{print $5,$NF}' | column -t
```

>==column -t==可以用来对齐输出的结果

>awk取列说明
>- $数字：表示取列，$1表示第一列，$0表示这一行
>- $NF：最后一列
>- NF: Number of Field
>- $(NF-1)：取出倒数第二列，-2则为倒数第三列

### 取出日志中最新10行的无效登录IP地址

![](attachments/Pasted%20image%2020240527171211.png)

```shell
grep Invalid secure-20240526 | head | awk '{print $(NF-2)}'
```


### 取出/etc/passwd中的第1列，第3列和最后一列

>由于awk取列时，==默认以空白字符为分隔符==进行分割
>
>空白字符：空格，连续空格，tab键
>
>需要指定分隔符，可以通过`-F`选项指定

```shell
awk -F':' '{print $1,$3,$NF}' /etc/passwd | column -t
# 单个分隔符可以不加单引号
awk -F: '{print $1,$3,$NF}' /etc/passwd | column -t
```

### 精准取出`ip add show eth0`的IP地址

面对不一样的分隔符，可以在`[]`中写入，如果有多个空格，考虑使用+
```shell
ip add show eth0 | awk 'NR==5' | awk -F'[ /]+' '{print $3}'
```

![](attachments/Pasted%20image%2020240527172631.png)

还可以用inet空格跟IP掩码作为分割符，以`inet `为一刀，左边的空格为第一列，右边的IP为第二列

```shell
# 先取第5行，然后取第5行中的IP
ip add show eth0 | awk 'NR==5' | awk -F 'inet |/[0-9]+' '{print $2}'
```

>分割完成数列时，以第一个分隔符出现开始，往后的为第一列，第二列
>
>` 123 456` 如右，若以空格为分隔符，则123为第1列，往后一个空格为第2列，456为第3列
>
>若以` 123`为分隔符，则后面一个空格为第1列，456为第2列


### 小结
- 如果以空格、连续空格、tab键分隔，直接使用awk取列即可，$1  $2  $NF
- 其他分隔符通过`-F`指定和正则实现`[]  []+  |`


## awk取行取列
⭐⭐⭐⭐⭐

```shell
ip add show eth0 | awk 'NR==5' | awk -F 'inet |/[0-9]+' '{print $2}'
# 可以改写为
ip add show eth0 | awk -F 'inet |/[0-9]+' NR==5'{print $2}'
```


### 取出passwd中第3列大于1000的行，取出这些行的第1，3列与最后一列
- 分析
	- 条件：第3列中数值大于1000 -> $3>1000
	- 动作：输出显示这行的第1，3列与最后一列

```shell
# awk 选项  '条件{动作}' /etc/passwd

# 条件
awk -F: '$3>=1000' /etc/passwd | column -t
# 动作
awk -F: '{print $1,$3,$NF}' /etc/passwd | column -t
# 条件+动作
awk -F: '$3>=1000{print $1,$3,$NF}' /etc/passwd | column -t
```

### 取出passwd第4列的数字是以0或1开头的行，输出第1，3，4列
```shell
awk -F: '$4~/^[01]/{print $1,$3,$4}' passwd  | column -t
```

>awk中，可以通过`~`，实现对某一列进行过滤
>
>某一列中含有xxxx内容
>- ~ 表示包含的意思，$1 ~ /root/ 表示第一列中包含root
>- !~表示不包含

### 小结
- 取行（条件）：`NR==1, NR>=1, $3>=100, $3~/ROOT/`
- 取列（动作）：$1 $NF $(NF-1)


## awk统计与计算
