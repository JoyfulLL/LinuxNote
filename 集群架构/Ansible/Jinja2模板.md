# Jinja2模板

首先创建模板文件，文件后缀必须为j2

```shell
[root@m1 /server/scripts/playbook]# cat motd.j2
###########################
主机名: {{ ansible_hostname }}
IP地址: {{ ansible_default_ipv4.address }}
内存大小: {{ ansible_memtotal_mb }}
CPU数量: {{ ansible_processor_vcpus }}
核心总数: {{ ansible_processor_cores }}
发行版本: {{ ansible_distribution }}
```

创建剧本

```yaml
- hosts: all
  tasks:
    - name: 分发motd文件
      template:
        src: motd.j2
        dest: /etc/motd
        backup: yes

    - name: 使用Copy分发motd文件
      copy:
        src: motd.j2
        dest: /tmp/motd
        backup: yes
```



```shell
###########################
主机名: web01
IP地址: 192.168.50.203
内存大小: 1819
CPU数量: 1
核心总数: 1
发行版本: CentOS
[root@web01 ~]# cat /tmp/motd
###########################
主机名: {{ ansible_hostname }}
IP地址: {{ ansible_default_ipv4.address }}
内存大小: {{ ansible_memtotal_mb }}
CPU数量: {{ ansible_processor_vcpus }}
核心总数: {{ ansible_processor_cores }}
发行版本: {{ ansible_distribution }}
```

> 以模板发送的文件可以被解析出来，以copy发送的文件将原封不动，不会解析变量



变量不止ansible的facts，可以自定义变量


