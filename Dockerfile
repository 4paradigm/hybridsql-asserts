FROM centos:7

# hadolint ignore=DL3031
RUN yum update -y && yum install -y centos-release-scl epel-release && yum clean all

RUN yum install -y devtoolset-8 rh-git218 flex autoconf automake unzip bc expect libtool \
    rh-python38-python-devel gettext byacc xz tcl cppunit-devel rh-python38-python-wheel \
    && yum clean all

ENV PATH=/opt/rh/rh-git218/root/usr/bin:/opt/rh/rh-python38/root/usr/local/bin:/opt/rh/rh-python38/root/usr/bin:/opt/rh/devtoolset-8/root/usr/bin:/opt/maven/bin:/depends/thirdparty/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LD_LIBRARY_PATH=/opt/rh/httpd24/root/usr/lib64:/opt/rh/rh-python38/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib:/opt/rh/devtoolset-8/root/usr/lib64/dyninst
ENV LANG=en_US.UTF-8

CMD [ "/bin/bash" ]
