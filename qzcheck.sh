#!/usr/bin/env bash

ver="2022.07.24"
changeLog="IP质量测试(欺诈得分)，由频道 https://t.me/vps_reviews 整理修改"

trap _exit INT QUIT TERM

_red() { echo -e "\033[31m\033[01m$@\033[0m"; }

_green() { echo -e "\033[32m\033[01m$@\033[0m"; }

_yellow() { echo -e "\033[33m\033[01m$@\033[0m"; }

_blue() { echo -e "\033[36m\033[01m$@\033[0m"; }

_exists() {
    local cmd="$1"
    if eval type type > /dev/null 2>&1; then
        eval type "$cmd" > /dev/null 2>&1
    elif command > /dev/null 2>&1; then
        command -v "$cmd" > /dev/null 2>&1
    else
        which "$cmd" > /dev/null 2>&1
    fi
    local rt=$?
    return ${rt}
}

_exit() {
    _red "\n检测到退出操作，脚本终止！\n"
    # clean up
    rm -fr benchtest_*
    exit 1
}


checkroot(){
	[[ $EUID -ne 0 ]] && echo -e "${RED}请使用 root 用户运行本脚本！${PLAIN}" && exit 1
}

checksystem() {
	if [ -f /etc/redhat-release ]; then
	    release="centos"
	elif cat /etc/issue | grep -Eqi "debian"; then
	    release="debian"
	elif cat /etc/issue | grep -Eqi "ubuntu"; then
	    release="ubuntu"
	elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
	    release="centos"
	elif cat /proc/version | grep -Eqi "debian"; then
	    release="debian"
	elif cat /proc/version | grep -Eqi "ubuntu"; then
	    release="ubuntu"
	elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
	    release="centos"
	fi
}


checkupdate(){
	    echo "正在更新包管理源"
	    if [ "${release}" == "centos" ]; then
		    yum update > /dev/null 2>&1
		else
		    apt-get update > /dev/null 2>&1
		fi

}

checkdnsutils() {
	if  [ ! -e '/usr/bin/dnsutils' ]; then
	        echo "正在安装 dnsutils"
	            if [ "${release}" == "centos" ]; then
# 	                    yum update > /dev/null 2>&1
	                    yum -y install dnsutils > /dev/null 2>&1
	                else
# 	                    apt-get update > /dev/null 2>&1
	                    apt-get -y install dnsutils > /dev/null 2>&1
	                fi

	fi
}

checkcurl() {
	if  [ ! -e '/usr/bin/curl' ]; then
	        echo "正在安装 Curl"
	            if [ "${release}" == "centos" ]; then
# 	                yum update > /dev/null 2>&1
	                yum -y install curl > /dev/null 2>&1
	            else
# 	                apt-get update > /dev/null 2>&1
	                apt-get -y install curl > /dev/null 2>&1
	            fi
	fi
}

checkwget() {
	if  [ ! -e '/usr/bin/wget' ]; then
	        echo "正在安装 Wget"
	            if [ "${release}" == "centos" ]; then
# 	                yum update > /dev/null 2>&1
	                yum -y install wget > /dev/null 2>&1
	            else
# 	                apt-get update > /dev/null 2>&1
	                apt-get -y install wget > /dev/null 2>&1
	            fi
	fi
}

print_intro() {
    echo "--------------------- A Bench Script By spiritlhl --------------------"
    echo "                   测评频道: https://t.me/vps_reviews                    "
    echo "版本：$ver"
    echo "更新日志：$changeLog"
}

next() {
    printf "%-70s\n" "-" | sed 's/\s/-/g'
}

print_end_time() {
    end_time=$(date +%s)
    time=$(( ${end_time} - ${start_time} ))
    if [ ${time} -gt 60 ]; then
        min=$(expr $time / 60)
        sec=$(expr $time % 60)
        echo " 总共花费        : ${min} 分 ${sec} 秒"
    else
        echo " 总共花费        : ${time} 秒"
    fi
    date_time=$(date +%Y-%m-%d" "%H:%M:%S)
    echo " 时间          : $date_time"
}

checkpython() {
    ! type -p python3 >/dev/null 2>&1 && yellow "\n Install python3\n" && ${PACKAGE_INSTALL[int]} python3
    # ! type -p pip3 install subprocess >/dev/null 2>&1 && yellow "\n Install pip3\n" && ${PACKAGE_INSTALL[int]} python3-pip
    # pip3 install subprocess
    sleep 0.5
}

checkupdate
checkroot
checkwget
checkcurl
checksystem
checkpython
curl -L https://raw.githubusercontent.com/spiritLHLS/ecs/main/qzcheck.py -o qzcheck.py 
if [ "${release}" == "centos" ]; then
    yum -y install python3.7 > /dev/null 2>&1
else
    apt-get -y install python3.7 > /dev/null 2>&1
fi
export PYTHONIOENCODING=utf-8
! _exists "wget" && _red "Error: wget command not found.\n" && exit 1
! _exists "free" && _red "Error: free command not found.\n" && exit 1
clear
start_time=$(date +%s)
print_intro
echo -e "------------------欺诈分数以及IP质量检测--本频道独创--------------------"
python3 qzcheck.py 
next
print_end_time
next
rm -rf wget-log*
rm -rf qzcheck.py*