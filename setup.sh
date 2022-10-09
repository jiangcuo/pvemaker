#!/bin/bash
#base config

if [ -z $giturl ];then
giturl="https://git.apqa.cn:8008/pve"
fi

pvedir="/opt/pve-maker"
buildlog="$pvedir/build.log"
pkgdir="/opt/pve-pkg"
srcdir="/opt/pve-src"
mkdir $pvedir $pkgdir $srcdir 

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
pve-container
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
pve-edk2-firmware
pve-qemu 
proxmox-apt
pve-docs
proxmox-backup-meta
proxmox
proxmox-backup
proxmox-acme-rs
proxmox-backup
pve-lxc-syscalld
pathpatterns
proxmox-openid-rs
)

#clone pkg
if test -f $srcdir/ready
then
echo "pve-src has existed，do nothing"
else
rm $srcdir/ 
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
        cp -r $srcdir/$package ./
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


# build proxmox-perl-rs
cd $pvedir/ 
git clone $giturl/proxmox-perl-rs.git
cd $pvedir/proxmox-perl-rs/pve-rs
yes|mk-build-deps --install --remove || echo no deps
cd $pvedir/proxmox-perl-rs/
make pve || echo "$(date +%Y%m%d-%H:%M:%S) proxmox-perl-rs-pve build failed" >>$buildlog
make pve-deb || echo "$(date +%Y%m%d-%H:%M:%S) proxmox-perl-rs-pve-deb build failed" >>$buildlog
make pve-common || echo "$(date +%Y%m%d-%H:%M:%S) proxmox-perl-rs-pve-common build failed" >>$buildlog


# build proxmox-websocket-tunnel
cd $pvedir/   
git clone $giturl/proxmox-websocket-tunnel.git
cd  $giturl/proxmox-websocket-tunnel
apt install -y librust-proxmox-http+client-dev=0.6.2-1 \
librust-proxmox-http+websocket-dev=0.6.2-1 \
librust-proxmox-http-dev=0.6.2-1 \
librust-proxmox-http+futures-dev=0.6.2-1 \
librust-proxmox-http+http-helpers-dev=0.6.2-1 \
librust-proxmox-http+openssl-dev=0.6.2-1 \
librust-proxmox-http+hyper-dev=0.6.2-1 \
librust-proxmox-http+proxmox-sys-dev=0.6.2-1 \
librust-proxmox-http+proxmox-lang-dev=0.6.2-1 \
librust-proxmox-http+base64-dev=0.6.2-1 \
librust-proxmox-http+http-dev=0.6.2-1 \
librust-proxmox-http+hyper-dev=0.6.2-1 \
librust-proxmox-http+tokio-openssl-dev=0.6.2-1 \
librust-proxmox-http+proxmox-sys-dev=0.6.2-1 \
librust-proxmox-sys-0.3+default-dev \
librust-tokio-stream+io-util-dev \
librust-itertools-dev
make deb || echo "$(date +%Y%m%d-%H:%M:%S) proxmox-websocket-tunnel build failed" >>$buildlog

# build  libhttp-daemon-perl
cd $pvedir/ 
git clone $giturl/libhttp-daemon-perl.git
cd $pvedir/libhttp-daemon-perl
dpkg-buildpackage -b -us -uc || echo "$(date +%Y%m%d-%H:%M:%S) libhttp-daemon-perl build failed" >>$buildlog


echo " $(date +%Y%m%d-%H:%M:%S) create package" >>$buildlog
find $pvedir -name "*.deb" -exec mv {} $pkgdir/ \;

