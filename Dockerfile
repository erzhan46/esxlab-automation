FROM registry.access.redhat.com/ubi7/ubi:7.9

COPY VMware-VCSA-all-7.0.1-17004997.iso /home

COPY vcenter_install.json /home

RUN yum --disableplugin=subscription-manager -y install iputils \
  && yum --disableplugin=subscription-manager clean all

CMD mkdir /media/vsphere \
  && mount -t iso9660 -o loop /home/VMware-VCSA-all-7.0.1-17004997.iso /media/vsphere  \
  && cd /media/vsphere/vcsa-cli-installer/lin64 \
  && ./vcsa-deploy install --accept-eula --acknowledge-ceip --log-dir=/tmp --no-ssl-certificate-verification -v /home/vcenter_install.json
