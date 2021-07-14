# Vcenter installation via docker

This document provides instructions on how to deply VCenter VSphere appliance on ESX server using docker.

VCenter cli installation doesn't work [on MacOS](vcenter_install_mac.md) due to issues with mounting VCenter iso file and ovftool errors.
To overcome this issue docker based deployment is documented here.

## VCenter ISO

VCenter ISO file should be downloaded from VMWare web site. File name usein this document is as follows (note that new version of ISO file can have a different name - Dockerfile should be updated as required):
```
VMware-VCSA-all-7.0.1-17004997.iso. (8.5GB)
```

## Pre-requisites

- Docker should be deployed on the Mac used for installation.
- ESX server should be deployed
- Review [Dockerfile](Dockerfile) - update ISO file name as required. Note that ubi:7.9 source image used to avoid issue with libnsl unavailability in ubi8.
- Review [vcenter_install.json](vcenter_install.json) - Update ESX connectivity parameters, Passwords, Network parameters (currently set to static)

## Deploying VCenter
Generate new image by running the following command (note that due to the size of ISO image - the build command might take few minutes to complete):
```
docker build -t vsphere-install:0.1 .
```
Run the following command to deploy VCenter appliance (note that privileged mode is used to allow ISO file mounting):
```
docker run --privileged  vsphere-install:0.1
```
VCenter installation might take up to 30 minutes to complete,
