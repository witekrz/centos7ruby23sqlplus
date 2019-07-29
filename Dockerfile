FROM centos:7.6.1810

ENV ORACLE_HOME=/usr/lib/oracle/12.2/client64
ENV PATH=${ORACLE_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${ORACLE_HOME}/lib

RUN yum -y update
RUN yum -y install gcc-c++ patch readline readline-devel zlib zlib-devel \
   libyaml-devel libffi-devel openssl-devel make \
   bzip2 autoconf automake libtool bison iconv-devel sqlite-devel \
   which libaio unzip nc wget java-11-openjdk \
   libreoffice-base libreoffice-calc libreoffice-writer \
   && yum -y reinstall glibc-common \
   && yum -y install git openssh-server ca-certificates \
   && update-ca-trust

RUN yum -y install epel-release
RUN yum -y install curl cabextract xorg-x11-font-utils fontconfig GraphicsMagick
RUN rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

RUN alternatives --set java java-11-openjdk.x86_64

ADD tmp /tmp
RUN chmod +x /tmp/sqlplus_12_2.tar.gz
RUN tar xzvf /tmp/sqlplus_12_2.tar.gz -C /tmp \
    && rm -f sqlplus_12_2.tar.gz

RUN rpm -ihv /tmp/*.rpm
RUN rm -f /tmp/*.rpm

RUN curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
RUN curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -
RUN curl -L get.rvm.io | bash -s stable
RUN /bin/bash -l -c ". /etc/profile.d/rvm.sh && rvm reload && rvm requirements run && rvm install 2.3.3 && rvm install 2.3.3-devel && rvm use 2.3.3 --default"

RUN /bin/bash -l -c "gem install ruby-oci8 -v 2.2.2"
RUN /bin/bash -l -c "gem install rubysl-win32ole -v 0.0.1"
RUN /bin/bash -l -c "gem install roo -v 2.5.1"
RUN /bin/bash -l -c "gem install roo-xls -v 1.0.0"
RUN /bin/bash -l -c "gem install spreadsheet -v 1.1.4"
RUN /bin/bash -l -c "gem install data_objects -v 0.10.17"
RUN /bin/bash -l -c "gem install mdb -v 0.4.1"
RUN /bin/bash -l -c "gem install activerecord-oracle_enhanced-adapter -v 1.6.7"
RUN /bin/bash -l -c "gem install rake -v 11.3.0"

RUN yum clean all \
   && rm -rf /var/cache/yum

CMD ["/bin/bash"]