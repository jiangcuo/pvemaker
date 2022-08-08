#!/bin/bash

pvepackages=(
corosync-pve
extjs
framework7
ifupdown2
kronosnet
ksm-control-daemon
libanyevent-http-perl
libarchive-perl
libhttp-daemon-perl
libjs-qrcodejs
libpve-u2f-server-perl
libqb
librados2-perl
libxdgmime-perl
lxc
lxcfs
novnc-pve
proxmox-acme
proxmox-archive-keyring
proxmox-i18n
proxmox-mini-journalreader
proxmox-ve
proxmox-widget-toolkit
pve-access-control
pve-apiclient
pve-cluster
pve-common
pve-container
pve-doc
pve-edk2-firmware
pve-eslint
pve-firewall
pve-firmware
pve-guest-common
pve-ha-manager
pve-http-server
pve-jslint
pve-kernel
pve-kernel-meta
pve-libseccomp2.4-dev
pve-manager
pve-network
pve-qemu
pve-storage
pve-zsync
qemu-server
smartmontools
spiceterm
vncterm
zfsonlinux
)

buildlog="/var/pve/build.log"
pvedir="/var/pve"


if [ -n "$guowai" ];then
rm /etc/apt/sources.list
mv /etc/apt/sources.list.guowai /etc/apt/sources.list
apt update
fi

if [ -n "$proxy" ];then
export http_proxy=$proxy
git config --global https.proxy $proxy
apt update
fi

apt update
#create debianlog
rm $pvedir/* -rf
touch $buildlog
cd $pvedir
for pvepackage in ${pvepackages[@]}
do 
cd $pvedir
#clone
echo "$(date +%Y%m%d-%H:%M:%S) clone $pvepackage" >> $buildlog
git clone https://git.proxmox.com/git/$pvepackage.git;
echo "$(date +%Y%m%d-%H:%M:%S) clone $pvepackage done" >> $buildlog
#make
echo "$(date +%Y%m%d-%H:%M:%S) making $pvepackage "  >> $buildlog
cd $pvedir/$pvepackage
#check mk-dep
if [ -z  "$pvedir/$pvepackage/debian/control" ];then
yes|mk-build-deps --install --remove
else
echo "no debian/control"
fi
make clean && make deb && echo "$(date +%Y%m%d-%H:%M:%S) $pvepackage build succes" >>$buildlog ||echo "$(date +%Y%m%d-%H:%M:%S) $pvepackage build failed" >>$buildlog;
done

echo " $(date +%Y%m%d-%H:%M:%S) create package" >>$buildlog
mkdir /var/pve/pkgs
find /var/pve/ -name "*.deb" -exec mv {} $pvedir/pkgs/ \;
