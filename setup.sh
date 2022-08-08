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

buildlog=corosyn/etc/apt/czzz
pvedir=




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
rm /var/pve/* -rf
touch /var/pve/build.log
cd /var/pve/
for pvepackage in ${pvepackages[@]} ;
do 
echo "$(date +%Y%m%d-%H:%M:%S) clone $pvepackage" >> build.log
git clone https://git.proxmox.com/git/$pvepackage.git;
echo "$(date +%Y%m%d-%H:%M:%S) clone $pvepackage done" >> build.log
echo "$(date +%Y%m%d-%H:%M:%S) making $pvepackage "  >> build.log
cd /var/www/$pvepackage
yes|mk-build-deps --install --remove || echo "no debian/control"
make clean && make deb && echo "$(date +%Y%m%d-%H:%M:%S) $pvepackage build succes" >>/var/www/build.log ||echo "$(date +%Y%m%d-%H:%M:%S) $pvepackage build failed" >>/var/www/build.log
done
echo " $(date +%Y%m%d-%H:%M:%S) create package" >>/var/www/build.log
mkdir /var/pve/pkgs
find /var/pve/ -name "*.deb" -exec mv {} /var/pve/pkgs/ \;
