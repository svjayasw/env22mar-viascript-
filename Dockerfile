FROM amr-registry-pre.caas.intel.com/pse-pswe-software-ba/embeded:base

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
    && git clone ssh://git@gitlab.devtools.intel.com:29418/psg-opensource/linux-socfpga.git

USER jenkins

CMD ["/bin/bash"]
WORKDIR /build
ENV SHELL /bin/bash