# VCenter installation

<span style="color:red">**Note: MACOS deployment fails with OVF Tool size mismatch error during vcsa_deploy execution**</span>


This document provides instructions on how to automate vCenter installation on ESX

## Preparation work

Download vCenter ISO, then run the following commands to prepare all artifacts required for installation

```
brew install cdrtools 

mkdir ro_iso vcenter

hdiutil attach -nomount VMware-VCSA-all-7.0.1-17004997.iso

diskutil list

mount -t cd9660 /dev/disk2 ro_iso

cd ro_iso
tar cvf ../tmp.tar *
cd ../vcenter
tar xvf ../tmp.tar
chmod -R u+w *
cd ..
rm tmp.tar

```

It is possible that tar will fail to extract large OVA file in vcsa directory in this case just copy it manually from ro_iso to vcenter directory.

### Prepare JSON file

Copy embedded_vCSA_on_ESXi.json file from vcenter/vcsa-cli-installer/templates/install directory to current directory.
Example file is provided - see vcenter_install.json file

### Run installer

```
cd vcenter/vcsa-cli-installer/mac
./vcsa-deploy install --accept-eula --acknowledge-ceip --no-esx-ssl-verify ../../../vcenter_install.json
```

