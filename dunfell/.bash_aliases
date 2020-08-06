export EDITOR='vim'
export PATH=${PATH}:/sbin:~/bin/linux-infra/tools:~/bin
echo export LANG=en_US.UTF-8
# Intel specific
export http_proxy=http://10.223.4.20:911
export https_proxy=http://10.223.4.20:912
export ftp_proxy=http://10.223.4.20:911
export socks_proxy=http://10.223.4.20:1080
export all_proxy=http://10.223.4.20:1080
export HTTP_PROXY=http://10.223.4.20:911
export HTTPS_PROXY=http://10.223.4.20:912
export FTP_PROXY=http://10.223.4.20:911
export SOCKS_PROXY=http://10.223.4.20:1080
export ALL_PROXY=http://10.223.4.20:1080
export NO_PROXY=altera.com,intel.com,.intel.com,localhost,127.0.0.1
export no_proxy="${NO_PROXY}"
#### CHANGE THIS
export GIT_PROXY_COMMAND="/build/linux-infra/tools/gitproxy"
