# esxlab-automation

All steps are run on the Mac with the homebrew installed.
Linux instructions would be similar.

## Custom ESX ISO

The following steps provide instructions on how to prepare a custom image to automate deployment of ESXi server.

Tested via iDRAC UI - using virtual device 

MYLAB.CFG - Esx installation script

```
brew install cdrtools 

mkdir ro_iso custom

hdiutil attach -nomount VMware-VMvisor-Installer-7.0b-16324942.x86_64.iso

diskutil list

mount -t cd9660 /dev/disk2 ro_iso

cd ro_iso
tar cvf ../tmp.tar .
cd ../custom
tar xvfp ../tmp.tar
cd ..
rm tmp.tar

mkdir custom/KS
cp MYLAB.CFG custom/KS/

```
Modify custom/BOOT.CFG as follows:
```
bootstate=0
title=Loading ESXi installer
timeout=5
prefix=
kernel=/b.b00
kernelopt=cdromBoot runweasel ks=cdrom:/KS/MYLAB.CFG
modules=/jumpstrt.gz --- /useropts.gz --- /features.gz --- /k.b00 --- /uc_intel.b00 --- /uc_amd.b00 --- /uc_hygon.b00 --- /procfs.b00 --- /vmx.v00 --- /vim.v00 --- /tpm.v00 --- /sb.v00 --- /s.v00 --- /bnxtnet.v00 --- /bnxtroce.v00 --- /brcmfcoe.v00 --- /brcmnvme.v00 --- /elxiscsi.v00 --- /elxnet.v00 --- /i40en.v00 --- /i40iwn.v00 --- /iavmd.v00 --- /igbn.v00 --- /iser.v00 --- /ixgben.v00 --- /lpfc.v00 --- /lpnic.v00 --- /lsi_mr3.v00 --- /lsi_msgp.v00 --- /lsi_msgp.v01 --- /lsi_msgp.v02 --- /mtip32xx.v00 --- /ne1000.v00 --- /nenic.v00 --- /nfnic.v00 --- /nhpsa.v00 --- /nmlx4_co.v00 --- /nmlx4_en.v00 --- /nmlx4_rd.v00 --- /nmlx5_co.v00 --- /nmlx5_rd.v00 --- /ntg3.v00 --- /nvme_pci.v00 --- /nvmerdma.v00 --- /nvmxnet3.v00 --- /nvmxnet3.v01 --- /pvscsi.v00 --- /qcnic.v00 --- /qedentv.v00 --- /qedrntv.v00 --- /qfle3.v00 --- /qfle3f.v00 --- /qfle3i.v00 --- /qflge.v00 --- /rste.v00 --- /sfvmk.v00 --- /smartpqi.v00 --- /vmkata.v00 --- /vmkfcoe.v00 --- /vmkusb.v00 --- /vmw_ahci.v00 --- /crx.v00 --- /elx_esx_.v00 --- /btldr.v00 --- /esx_dvfi.v00 --- /esx_ui.v00 --- /esxupdt.v00 --- /tpmesxup.v00 --- /weaselin.v00 --- /loadesx.v00 --- /lsuv2_hp.v00 --- /lsuv2_in.v00 --- /lsuv2_ls.v00 --- /lsuv2_nv.v00 --- /lsuv2_oe.v00 --- /lsuv2_oe.v01 --- /lsuv2_oe.v02 --- /lsuv2_sm.v00 --- /native_m.v00 --- /qlnative.v00 --- /vdfs.v00 --- /vmware_e.v00 --- /vsan.v00 --- /vsanheal.v00 --- /vsanmgmt.v00 --- /tools.t00 --- /xorg.v00 --- /imgdb.tgz --- /imgpayld.tgz
build=7.0.0-1.25.16324942
updated=0
```

Create new ISO:
```
mkisofs -relaxed-filenames -J -R -o custom_esxi.iso -b ISOLINUX.BIN -c BOOT.CAT -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -eltorito-platform efi -b EFIBOOT.IMG -no-emul-boot  ./custom
```



## PXE Boot

Attaching Virtual Media is not suported via redfish on older iDRAC.
It is supported strarting with v.3.30:
https://github.com/dell/iDRAC-Redfish-Scripting/issues/24

It seems that for older iDRAC - only PXE boot is the viable option for remote image.

The following steps assume server configured to use UEFI boot, the availability of TFTP Server, Web Server (for configuration script) and ability to modify DHCP server configuration.
I used the following configuration in my home lab:
- QNAP NAS to host both TFTP server and Web Server 
- OPNSense box serving as a firewall/router/DHCP server

### Prepare TFTP server

Extract content of ESXi image to a custom directory:
```
brew install cdrtools 

mkdir ro_iso custom

hdiutil attach -nomount VMware-VMvisor-Installer-7.0b-16324942.x86_64.iso

diskutil list

mount -t cd9660 /dev/disk2 ro_iso

cd ro_iso
tar cvf ../tmp.tar .
cd ../custom
tar xvfp ../tmp.tar
cd ..
rm tmp.tar
```
All files in the custom directory will have names in the upper case - this will cause PXE boot to report errors.
Run the following command to convert all names to lower case:
```
cd custom

for SRC in `find . -depth`
do
    DST=`dirname "${SRC}"`/`basename "${SRC}" | tr '[A-Z]' '[a-z]'`
echo $SRC $DST
if [ "${SRC}" != "${DST}" ]
    then
       mv "${SRC}" "${DST}" || echo "${SRC} was not renamed"
    fi
done
```

Prepare tftp server as follows:
- Create tftpboot directory in tftp root directory 
- Copy custom/efi/boot/bootx64.efi file to tftpboot directory renaming it to mboot.efi
- Create ESXi-7.0b directory in tftp root directory (Directory name is freeform - recommended to match ESXi version)
- Copy conent of custom directory to ESXi-7.0b
- Create boot.cfg file in tftp root directory containing the following:
```
bootstate=0
title=Loading ESXi installer
timeout=5
prefix=ESXi-7.0b
kernel=b.b00
kernelopt=ks=http://webserver.homelab.org/esxi_ksFiles/ks.cfg
modules=jumpstrt.gz --- useropts.gz --- features.gz --- k.b00 --- uc_intel.b00 --- uc_amd.b00 --- uc_hygon.b00 --- procfs.b00 --- vmx.v00 --- vim.v00 --- tpm.v00 --- sb.v00 --- s.v00 --- bnxtnet.v00 --- bnxtroce.v00 --- brcmfcoe.v00 --- brcmnvme.v00 --- elxiscsi.v00 --- elxnet.v00 --- i40en.v00 --- i40iwn.v00 --- iavmd.v00 --- igbn.v00 --- iser.v00 --- ixgben.v00 --- lpfc.v00 --- lpnic.v00 --- lsi_mr3.v00 --- lsi_msgp.v00 --- lsi_msgp.v01 --- lsi_msgp.v02 --- mtip32xx.v00 --- ne1000.v00 --- nenic.v00 --- nfnic.v00 --- nhpsa.v00 --- nmlx4_co.v00 --- nmlx4_en.v00 --- nmlx4_rd.v00 --- nmlx5_co.v00 --- nmlx5_rd.v00 --- ntg3.v00 --- nvme_pci.v00 --- nvmerdma.v00 --- nvmxnet3.v00 --- nvmxnet3.v01 --- pvscsi.v00 --- qcnic.v00 --- qedentv.v00 --- qedrntv.v00 --- qfle3.v00 --- qfle3f.v00 --- qfle3i.v00 --- qflge.v00 --- rste.v00 --- sfvmk.v00 --- smartpqi.v00 --- vmkata.v00 --- vmkfcoe.v00 --- vmkusb.v00 --- vmw_ahci.v00 --- crx.v00 --- elx_esx_.v00 --- btldr.v00 --- esx_dvfi.v00 --- esx_ui.v00 --- esxupdt.v00 --- tpmesxup.v00 --- weaselin.v00 --- loadesx.v00 --- lsuv2_hp.v00 --- lsuv2_in.v00 --- lsuv2_ls.v00 --- lsuv2_nv.v00 --- lsuv2_oe.v00 --- lsuv2_oe.v01 --- lsuv2_oe.v02 --- lsuv2_sm.v00 --- native_m.v00 --- qlnative.v00 --- vdfs.v00 --- vmware_e.v00 --- vsan.v00 --- vsanheal.v00 --- vsanmgmt.v00 --- tools.t00 --- xorg.v00 --- imgdb.tgz --- imgpayld.tgz
build=7.0.0-1.25.16324942
updated=0
```
- Copy MYLAB.CFG file to the Web server matching the kernelopt configuration in boot.cfg file above (renaming it to ks.cfg and placing it to esxi_ksFiles directory)

### Configure DHCP server
- tftp server - IP address or hostname of the tftp server
- boot file: tftpboot/mboot.efi
- Enable network booting pointing to the tftp server
- Uefi filename: mboot.efi

### Boot server
Boot server via PXE (F12 on Dell servers during the boot) - observe the boot process.
Some troubleshooting:
- Enable logging on tftp server - this should help a lot during troubleshooting
- If server gets stuck right after acquiring IP address from DHCP server - check that server is configured for UEFI boot, check that mboot.efi exist in tftpboot directory on tftp server, check that DHCP server configured both for tftp and network booting


## Ansible

```
ansible-galaxy collection install community.general
```
