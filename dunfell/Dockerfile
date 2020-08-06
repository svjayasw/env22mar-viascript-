FROM ubuntu:18.04

RUN LS_COLORS="ow=01;36;40" && export LS_COLORS
ENV NO_PROXY altera.com,intel.com,.intel.com,localhost,127.0.0.1
ENV http_proxy http://proxy-chain.intel.com:912
ENV FTP_PROXY http://proxy-chain.intel.com:912
ENV ftp_proxy http://proxy-chain.intel.com:911
ENV all_proxy http://proxy-chain.intel.com:1080
ENV ALL_PROXY http://proxy-chain.intel.com:1080
ENV socks_proxy http://proxy-chain.intel.com:1080
ENV SOCKS_PROXY http://proxy-chain.intel.com:1080
ENV HTTPS_PROXY http://proxy-chain.intel.com:912
ENV https_proxy http://proxy-chain.intel.com:912
ENV no_proxy altera.com,intel.com,.intel.com,localhost,127.0.0.1
ENV HTTP_PROXY http://proxy-chain.intel.com:912
 
#update apt-get config
RUN printf 'Acquire::http::Proxy "http://proxy-chain.intel.com:912";\n' | tee /etc/apt/apt.conf.d/proxy.conf 
RUN echo 'Acquire::https::Proxy "http://proxy-chain.intel.com:912";' >> /etc/apt/apt.conf.d/proxy.conf 
RUN echo 'Acquire::ftp::Proxy "ftp_proxy=http://proxy-chain.intel.com:912";' >> /etc/apt/apt.conf.d/proxy.conf
RUN apt-get -y --allow-unauthenticated update
 
#install wget and setup config
RUN apt-get install wget -y
RUN sed -i 's+#https_proxy = http://proxy.yoyodyne.com:18023/+https_proxy = http://proxy-chain.intel.com:912/+g' /etc/wgetrc
RUN sed -i 's+#http_proxy = http://proxy.yoyodyne.com:18023/+http_proxy = http://proxy-chain.intel.com:912/+g' /etc/wgetrc
RUN sed -i 's+#ftp_proxy = http://proxy.yoyodyne.com:18023/+ftp_proxy = http://proxy-chain.intel.com:912/+g' /etc/wgetrc
RUN sed -i 's+#use_proxy = on+use_proxy = on+g' /etc/wgetrc


ENV CERTS http://certificates.intel.com/repository/certificates/IntelSHA2RootChain-Base64.zip


RUN apt-get install -y  git && \
    apt-get install -y  tar python gawk git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat cpio python3.7 python3-pip python3-pexpect xz-utils debianutils  iputils-ping libsdl1.2-dev xterm ca-certificates bash-completion locales curl lsb-release vim sudo
	
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 2
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.7 2

RUN locale-gen --purge en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# Certificates for Intel
RUN curl --output /tmp/certs.zip     \
    ${CERTS}		               && \
    mkdir /usr/share/ca-certificates/Intel && \
    cd /usr/share/ca-certificates/	   && \
    unzip -d Intel /tmp/certs.zip          && \
    ls -1 Intel/* >> /etc/ca-certificates.conf &&\
    update-ca-certificates

RUN groupadd -g 1000 jenkins \
    && useradd -c "Jenkins user" -d /home/jenkins -u 1000 -g 1000 -m jenkins \
    && echo "jenkins:jenkins" | chpasswd \
    && adduser jenkins sudo \
	&& echo 'jenkins ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
    && mkdir -p /build \
    && chmod -R 777 /build \
    && chown -R jenkins:jenkins /build \
    && chmod -R 777 /home/jenkins \
    && chown -R jenkins:jenkins /home/jenkins 

  
USER jenkins
RUN mkdir -p /home/jenkins/.ssh
COPY id_rsa /home/jenkins/.ssh
COPY config /home/jenkins/.ssh
RUN sudo chown -R jenkins:jenkins /home/jenkins/.ssh/*
RUN chmod 600 /home/jenkins/.ssh/id_rsa
COPY .bash_aliases /build
COPY bin /home/jenkins
RUN sudo chown -R jenkins:jenkins /build
RUN chmod -R 777 /build
COPY create-linux-distro-poky-dunfell /build
RUN mkdir -p /build/rebeccas/contrib
RUN cat /build/.bash_aliases >> /home/jenkins/.bashrc

RUN cd /build \
    && git clone ssh://git@gitlab.devtools.intel.com:29418/psg-opensource/gsrd-build-bot.git \
	&& mv gsrd-build-bot gsrd-build-automation

RUN mkdir -p /build/yocto-dunfell-socfpga \
    && cd /build/yocto-dunfell-socfpga \
    && git clone -b dunfell https://git.yoctoproject.org/git/poky.git \
	&& git clone -b master https://github.com/kraj/meta-altera.git \
	&& git clone -b master-next ssh://git@gitlab.devtools.intel.com:29418/psg-opensource/meta-altera-refdes.git \
	&& git clone -b dunfell https://git.openembedded.org/meta-openembedded

RUN cd /build/rebeccas/contrib \
    && git clone ssh://git@gitlab.devtools.intel.com:29418/psg-opensource/linux-socfpga.git \
    && git clone http://github.com/altera-opensource/u-boot-socfpga.git
	
CMD ["/bin/bash"]
WORKDIR /build
ENV SHELL /bin/bash
ENV export LC_ALL=en_US.UTF-8 
ENV export LANG=en_US.UTF-8
ENV export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/sbin:/home/jenkins/bin/linux-infra/tools:/home/jenkins/bin:$PATH