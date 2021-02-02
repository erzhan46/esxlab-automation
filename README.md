# esxlab-automation
## Custom ESX ISO

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

## Ansible

```
ansible-galaxy collection install community.general
```

Attaching Virtual Media is not suported via redfish on older iDRAC.
Only strarting with v.3.30 it will be supported:
https://github.com/dell/iDRAC-Redfish-Scripting/issues/24

It seems that for older iDRAC - only PXE boot is the viable option for remote image
