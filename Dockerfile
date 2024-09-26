FROM centos:7

ARG TARGETARCH

COPY ./patch_yum_repo.sh /
# hadolint ignore=DL3031,DL3033
RUN sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/*.repo && \
    sed -i s/^#.*baseurl=http/baseurl=http/g /etc/yum.repos.d/*.repo && \
    sed -i s/^mirrorlist=http/#mirrorlist=http/g /etc/yum.repos.d/*.repo && \
    yum update -y && yum install -y centos-release-scl epel-release && \
    /patch_yum_repo.sh && \
    yum install -y devtoolset-8 rh-git227 flex autoconf automake unzip bc expect libtool \
    rh-python38-python-devel gettext byacc xz tcl cppunit-devel rh-python38-python-wheel patch \
    && yum clean all && rm /patch_yum_repo.sh

COPY setup_cmake.sh /
RUN /setup_cmake.sh ${TARGETARCH} && rm -f setup_cmake.sh

ENV PATH=/opt/rh/rh-git227/root/usr/bin:/opt/rh/rh-python38/root/usr/local/bin:/opt/rh/rh-python38/root/usr/bin:/opt/rh/devtoolset-8/root/usr/bin:/opt/maven/bin:/depends/thirdparty/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LD_LIBRARY_PATH=/opt/rh/httpd24/root/usr/lib64:/opt/rh/rh-python38/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib:/opt/rh/devtoolset-8/root/usr/lib64/dyninst
ENV LANG=en_US.UTF-8

CMD [ "/bin/bash" ]
