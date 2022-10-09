#!/bin/bash
#base config

if [ -z $giturl ];then
giturl="https://git.apqa.cn:8008/pve"
fi

pvedir="/opt/pve-maker"
buildlog="$pvedir/build.log"
pkgdir="/opt/pve-pkg"
mkdir $pvedir $pkgdir -p

mkdir $pvedir/proxmox-acme-rs
#proxmox-acme-rs
cd $pvedir/proxmox-acme-rs
git clone $giturl/proxmox-acme-rs
yes|mk-build-deps --install --remove 
make deb 

#proxmox-perl-rs
mkdir $pvedir/proxmox-perl-rs
cd $pvedir/proxmox-perl-rs/pve-rs
yes|mk-build-deps --install --remove || echo no deps
cd $pvedir/proxmox-perl-rs/pmg-rs
yes|mk-build-deps --install --remove || echo no deps
cd $pvedir/proxmox-perl-rs
make pve-deb
make common-deb




#proxmox-backup

echo " $(date +%Y%m%d-%H:%M:%S) create package" >>$buildlog
find $pvedir -name "*.deb" -exec mv {} $pkgdir/ \;
