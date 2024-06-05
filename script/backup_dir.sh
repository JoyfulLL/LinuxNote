#!/bin/bash

# 变量
source_dir="$1"
custom_backup_dir="$2"
default_backup_dir="/backup"

# ANSI颜色和格式化代码
GREEN='\033[0;32m'
RED='\033[0;31m'
BOLD='\033[1m'
BLUE='\033[0;34m'
RESET='\033[0m'

# 函数：创建备份目录
makedir() {
	mkdir -p "${default_backup_dir}" &>/dev/null
	if [ $? -eq 0 ]; then
		printf "${GREEN}默认备份目录 %s 创建成功${RESET}\n" "${default_backup_dir}"
	else
		printf "${RED}无法创建默认备份目录 %s${RESET}\n" "${default_backup_dir}"
		exit 1
	fi
}

# 如果未提供备份目标路径，则使用默认路径
use_default_dir() {
	local user_name=$(whoami)
	local userhome_dir=""
	if [ "$user_name" != "root" ]; then
		userhome_dir=$(grep "$(whoami)" /etc/passwd | awk -F":" '{print $6}')
		printf "${BLUE}使用默认路径${userhome_dir}作为目的地${RESET}\n"
	else
		printf "${BLUE}使用默认路径${default_backup_dir}作为目的地${RESET}\n"
		# 如果默认备份目录不存在，则创建
		if [ ! -d "${default_backup_dir}" ]; then
			makedir "${default_backup_dir}"
		fi
	fi
	echo "$userhome_dir" # 返回 userhome_dir 的值
}

# 检查源目录是否存在
check_source_dir() {
	if [ ! -d "$source_dir" ]; then
		printf "${RED}源目录 %s 不存在${RESET}\n" "$source_dir"
		printf "${BLUE}请依据下面的格式运行脚本${RESET}\n"
		printf "${BLUE}$0 <备份目录> <备份保存至>${RESET}\n"
		printf "${BLUE}不指定备份目的地，则使用默认备份路径/backup\n${RESET}"
		exit 1
	fi

	echo "源目录"$source_dir
	# 不允许备份根目录
	if [ "$source_dir" = "/" ]; then
		printf "${RED}不允许备份根目录${RESET}\n"
		exit 1
	fi

	if [ "$source_dir" = "$custom_backup_dir" ]; then
		printf "${RED}不允许备份目录与备份保存地址相同${RESET}\n"
		printf "${RED}请修改备份保存地址${RESET}\n"
		exit 1
	fi
}

list_backup_files() {
	local user_name=$(whoami)
	local backup_dir=""
	if [ "$user_name" != "root" ]; then
		backup_dir="$userhome_dir"
	else
		if [ $# -eq 1 ]; then
			backup_dir="$default_backup_dir"
		else
			backup_dir="$custom_backup_dir"
		fi
	fi

	printf "${GREEN}备份已保存到目的目录 ${backup_dir} ：${RESET}\n"
	printf "${GREEN}绝对路径 $1 ${RESET}\n"
}

# 开始备份
begin_backup() {
	local source_dir_name=$(echo "$source_dir" | sed 's#/#_#g')
	local backup_target=""
	if [ -z "$custom_backup_dir" ]; then
		backup_target="${default_backup_dir}/${source_dir_name}-$(date +%F).tar.gz"
	else
		backup_target="${custom_backup_dir}/${source_dir_name}-$(date +%F).tar.gz"
	fi
	tar zcf "$backup_target" "$source_dir"
	if [ $? -eq 0 ]; then
		printf "${GREEN}%s备份完成\n${RESET}" "$source_dir"
		# 调用函数
		list_backup_files "$backup_target"
		exit 0
	else
		printf "${RED}压缩源目录失败${RESET}\n"
		printf "${RED}可能原因：${RESET}\n"
		printf "${RED}1.非root用户尝试修改家目录的其他地方${RESET}\n"
		printf "${RED}2.非root用户无权限压缩某些文件${RESET}\n"
		# 调用函数
		list_backup_files
		exit 1
	fi
}

main() {
	# 如果只有一个参数被传入，则没有指定备份目标路径
	if [ $# -eq 1 ]; then
		printf "${RED}${BOLD}没有指定目的地${RESET}\n"
		use_default_dir
	fi
	# 确保有源目录且不为根
	check_source_dir
	if [ $? -eq 0 ]; then
		printf "${BLUE}开始备份 $source_dir${RESET}\n"
		begin_backup
	fi
}

main "$@"
