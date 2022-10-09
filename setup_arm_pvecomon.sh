#!/bin/bash
#base config

if [ -z $giturl ];then
giturl="https://git.apqa.cn:8008/pve"
fi

pvedir="/opt/pve-maker"
buildlog="$pvedir/build.log"
pkgdir="/opt/pve-pkg"
srcdir="/opt/pve-src"
mkdir $pvedir $pkgdir $srcdir -p

# pvepackage
# delete:  
pvepackages=( 
corosync-pve
extjs
framework7
ifupdown2
ksm-control-daemon
libanyevent-http-perl
libarchive-perl
libjs-qrcodejs
libpve-u2f-server-perl
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
pve-eslint
pve-firewall
pve-firmware
pve-guest-common
pve-ha-manager
pve-http-server
pve-jslint
pve-manager
pve-network
pve-storage
pve-zsync
qemu-server 
smartmontools
spiceterm
vncterm
pve-qemu
pve-docs
proxmox-backup-meta
)

#clone pkg
if test -f $srcdir/ready
then
echo "pve-src has existed，do nothing"
else
rm $srcdir/*
for pvepackage in ${pvepackages[@]};
    do 
        cd $srcdir
        git clone $giturl/$pvepackage.git
done
touch $srcdir/ready
fi


for pvepackage in ${pvepackages[@]};
    do 
        cd $pvedir
        cp -r $srcdir/$pvepackage ./
        cd $pvedir/$pvepackage
        #check mk-dep/
        yes|mk-build-deps --install --remove || echo no deps
        mkdeb=`grep ".PHONY: deb" Makefile`
        make clean 
        if [  -z "$mkdeb" ];then
                make || echo "$(date +%Y%m%d-%H:%M:%S) $pvepackage build failed" >>$buildlog
            else
                make deb || echo "$(date +%Y%m%d-%H:%M:%S) $pvepackage build failed" >>$buildlog
        fi;
done



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

#pve-lxc-syscalld
sed -i 's/i8/libc::c_char/g' src/sys_quotactl.rs

#criu
cd criu
git clone https://git.proxmox.com/git/criu.git
apt install asciidoc libnet1-dev libprotobuf-c-dev libprotobuf-dev \
protobuf-c-compiler protobuf-compiler python-all
sed -i "s/3.11-2/3.15-2/g" Makefile
make download
make deb

echo " $(date +%Y%m%d-%H:%M:%S) create package" >>$buildlog
find $pvedir -name "*.deb" -exec mv {} $pkgdir/ \;
