# Ansible流程控制

## Handler 触发器

一般应用场景：服务的配置文件发生变化后，执行指定操作,，例如重启

```yaml
# 当nginx配置文件修改之后，重启nginx；没修改则不执行后续操作
# reloadNginx.yaml
- hosts: web_nginx
  tasks:
    - name: 分发配置文件
      copy:
        src: nginx.conf
        dest: /etc/nginx
        backup: yes
      notify:
        - 重启
  handlers:
    - name: 重启nginx
      systemd:
        name: nginx
        state: reloaded
```

> 注意事项：handlers 需要放在剧本的最后

## When判断

- 用于给ansible运行的tasks设置条件，达到条件则执行或不执行

- when条件一般与facts变量或register变量一起使用

- 不满足条件的则会提示skip

```yaml
# 为所有主机安装软件
# CentOS系统安装tree
# Ubuntu系统安装lolcat
# ansible_distribution 为 facts的一个变量
- hosts: all
  tasks:
    - name: CentOS安装tree
      yum:
        name: tree
        state: present
      when: ansible_distribution == "CentOS"

    - name: Ubuntu安装lolcat
      apt:
        name: lolcat
        state: present
      when: ansible_distribution == "Ubuntu"
```

> when使用的判断符号
> 
> == 全等于
> 
> != 不等于
> 
> is match  存在、满足、匹配
> 
> is not match  不存在、不满足、不匹配

```shell
# 如果机器名匹配为web或者backup
ansible_hostname is match("web|backup")
ansible_hostname is not match("web|backup")
```

and 与 or 

```yaml
# 为所有主机安装软件
- hosts: all
  tasks:
    - name: CentOS安装tree
      yum:
        name: tree
        state: present
      when: # 条件1与条件2同时成立才执行(and)
        - ansible_distribution == "CentOS"
        - ansible_hostname is match("web|backup")

    - name: Ubuntu安装lolcat
      apt:
        name: lolcat
        state: present
      when: ansible_distribution == "Ubuntu" or ansible_hostname is match("serve")
```

## Loop 或 with_items 循环

```yaml
# 按顺序重启服务，可以使用循环
- hosts: storage
  tasks:
    - name: 重启服务
      systemd:
        name: " {{ item }}"
        state: restarted
      with_items:
        - rpcbind
        - nfs
```

item为固定的写法，with_items可以使用loop代替，结果一样。执行顺序为先重启rpcbind，再重启nfs

```yaml
# 用于批量添加用户
- hosts: all
  gather_facts: no
  tasks:
    - name: 批量添加用户
      user:
        name: "{{item.name}}"
        uid: "{{item.uid}} "
        state: present
      with_items:
        - { name: "abig", uid: "2000"}
        - { name: "uaena", uid: "2001"}
        - { name: "iu", uid: "2003"}
```

> 注意名字不要有空格，否则会报错
> 
> failed: [192.168.50.203] (item={u'name': u'iu', u'uid': u'2003'}) => {"ansible_loop_var": "item", "changed": false, "item": {"name": "iu", "uid": "2003"}, "msg": "useradd: invalid user name ' iu'\n", "name": " iu", "rc": 3}

> changed: [192.168.50.245] => (item={u'name': u'abig', u'uid': u'2000'})
> changed: [192.168.50.203] => (item={u'name': u'abig', u'uid': u'2000'})
> changed: [192.168.50.97] => (item={u'name': u'abig', u'uid': u'2000'})
> changed: [192.168.50.245] => (item={u'name': u'uaena', u'uid': u'2001'})
> changed: [192.168.50.203] => (item={u'name': u'uaena', u'uid': u'2001'})
> changed: [192.168.50.97] => (item={u'name': u'uaena', u'uid': u'2001'})
> changed: [192.168.50.245] => (item={u'name': u'iu', u'uid': u'2003'})
> changed: [192.168.50.97] => (item={u'name': u'iu', u'uid': u'2003'})
> changed: [192.168.50.203] => (item={u'name': u'iu', u'uid': u'2003'})

# 流程控制总结

| 项目          | 应用场景              |
| ----------- | ----------------- |
| handler 触发器 | xx配置变化，需要执行xx操作   |
| when 判断     | 给剧本/脚本执行添加条件      |
| loop 循环     | 进行批量操作：添加/删除用户，复制 |
