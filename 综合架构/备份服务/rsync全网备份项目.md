# 客户端备份脚本
[[正则表达式]]
```shell
[root@web01 /script]# cat backupWeb.sh
#!/bin/bash

# 设置变量
backup_dir="/www"  #备份的路径
time=$(date +%F_%w)    #时间
k8s_backup_file="k8s-${time}.tar.gz"
test_backup_file="test-${time}.tar.gz"
backup_server="192.168.50.245" #远程备份服务器的IP

# 打包 /www/ 目录下的指定文件夹并生成MD5校验文件
tar zcf "${backup_dir}/${k8s_backup_file}" "${backup_dir}/k8s-front-end"
tar zcf "${backup_dir}/${test_backup_file}" "${backup_dir}/test01"

# 生成并合并MD5校验文件
# md5sum "${backup_dir}/${k8s_backup_file}" "${backup_dir}/${test_backup_file}" > "${backup_dir}/fingerprint.md5"
cd "${backup_dir}" || exit
md5sum "$(basename "${k8s_backup_file}")" "$(basename "${test_backup_file}")" > "fingerprint.md5"

# 推送命令——使用前先测试
rsync -a "${backup_dir}/${k8s_backup_file}" "${backup_dir}/${test_backup_file}" "${backup_dir}/fingerprint.md5" rsync_backup@${backup_server}::backupWeb --password-file=/etc/rsync.pass

# 删除本地备份文件
rm -f "${backup_dir}/${k8s_backup_file}" "${backup_dir}/${test_backup_file}" "${backup_dir}/fingerprint.md5"
```

脚本在运行前，每一个变量需要确保是正确的；运行前可以先echo检查一下变量的值

还需要确认推送命令是否正确

```shell
[root@web01 ~]# echo `hostname -I |awk '{print $1}'`
192.168.50.203
```



# 服务端校验脚本并推送至邮箱

```shell
[root@storage /script]# cat checkBackup.sh
#!/bin/bash
# 设置变量
md5_file="/backup/www/fingerprint.md5"  # MD5 校验文件路径
recipient_email="111@qq.com"  # 接收邮件的邮箱地址
md5_dir="$(dirname "${md5_file}")"  # MD5 校验文件所在目录

# 切换到 MD5 文件所在目录
cd "${md5_dir}" || exit

# 执行 MD5 校验并发送邮件
if md5sum -c "$(basename "${md5_file}")" >/dev/null 2>&1; then
    ok_count=$(grep ': OK$' "$(basename "${md5_file}")" | wc -l)
    total_count=$(wc -l < "$(basename "${md5_file}")")
    fail_count=$(grep 'FAILED$' "$(basename "${md5_file}")" | wc -l)
    mail_subject="MD5 校验结果：成功: ${ok_count}, 失败: ${fail_count}, 总数: ${total_count}"
    cat <<EOF | mailx -s "${mail_subject}" "${recipient_email}"
MD5 校验结果如下：
$(md5sum -c "$(basename "${md5_file}")")
EOF
else
    fail_count=$(grep 'FAILED$' "$(basename "${md5_file}")" | wc -l)
    total_count=$(wc -l < "$(basename "${md5_file}")")
    ok_count=$((total_count - fail_count))
    mailx -s "MD5 校验失败，请检查备份文件的完整性！失败: ${fail_count}, 总数: ${total_count}" "${recipient_email}" <<EOF
MD5 校验失败，请检查备份文件的完整性！
$(md5sum -c "$(basename "${md5_file}")")
EOF
fi
```







### 客户端运行脚本报错

##### 报错：权限不足

```shell
rsync: recv_generator: mkdir "172.16.1.213" (in backup) failed: Permission denied (13)
```

##### 现象

客户端运行脚本时，脚本输出：Permission denied 权限不足，无法创建文件夹

##### 解决

初始创建/backup文件夹的时候，权限如下

```shell
[root@backup ~]# ls -ld /backup/
drwxr-xr-x 2 root root 6 Apr  8 20:29 /backup/
```

将所有权更改为用户 `rsync` 和组 `rsync`

```shell
[root@backup ~]# chown -R rsync.rsync /backup/
# 运行上面的命令之后，再次查看权限
[root@backup ~]# ls -ld /backup/
drwxr-xr-x 2 rsync rsync 6 Apr  8 20:29 /backup/
```

用户需要与rsyncd的配置文件保持一致，并且用户需要存在

```shell
uid = rsync
gid = rsync

[root@backup ~]# id rsync
uid=1001(rsync) gid=1001(rsync) groups=1001(rsync)
```
