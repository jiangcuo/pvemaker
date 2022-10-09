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

<<<<<<< HEAD
#clone pkg
if test -f $srcdir/ready
then
echo "pve-src has existed，do nothing"
=======
buildlog="/var/pve/build.log"
pvedir="/var/pve"

aptsource(){
rm /etc/apt/sources.list 
echo "deb http://mirrors.ustc.edu.cn/debian/ bullseye main contrib non-free" >> /etc/apt/sources.list 
echo "deb http://mirrors.ustc.edu.cn/debian/ bullseye-updates main contrib non-free" >> /etc/apt/sources.list 
echo "deb http://mirrors.ustc.edu.cn/debian/ bullseye-backports main contrib non-free" >> /etc/apt/sources.list 
echo "deb http://mirrors.ustc.edu.cn/debian-security bullseye-security main contrib" >> /etc/apt/sources.list 
}

pvesource(){
echo "deb https://mirrors.ustc.edu.cn/proxmox/debian bullseye pve-no-subscription" >> /etc/apt/sources.list 
echo "deb http://mirrors.ustc.edu.cn/proxmox/debian/ceph-pacific bullseye main" >> /etc/apt/sources.list 
echo "deb http://mirrors.ustc.edu.cn/proxmox/debian/devel bullseye main" >> /etc/apt/sources.list 
wget http://download.proxmox.com/debian/proxmox-release-bullseye.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg
}

basepkg(){
apt update && apt install gpgv wget curl -y
}

installcargo(){
curl https://sh.rustup.rs -sSf >/rustset.sh 
sh /rustset.sh  --default-host x86_64-unknown-linux-gnu --default-toolchain nightly --profile complete -y 
cp -a ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/ ~/.rustup/toolchains/system 
#for arm64
#sh /rustset.sh  --default-host aarch64-unknown-linux-gnu --default-toolchain nightly --profile complete -y 
#cp -a ~/.rustup/toolchains/nightly-aarch64-unknown-linux-gnu/ ~/.rustup/toolchains/system  
ln -s ~/.cargo/bin/* /usr/bin/ 
rustup default system 
}

installdebcargo(){
cd /opt
git clone https://salsa.debian.org/rust-team/debcargo.git
cd /opt/debcargo
cargo build --release 
ln -s /opt/debcargo/target/release/debcargo /usr/bin/
}

installpackage(){
apt update 
apt install -y devscripts  build-essential librust-openssl-sys-dev git git-email pkg-config debhelper pve-doc-generator  \
cmake bison dwarves flex libdw-dev libelf-dev libiberty-dev lz4 zstd librados-dev \
libtest-mockmodule-perl  check libcmap-dev libcorosync-common-dev libcpg-dev libfuse-dev \
libglib2.0-dev libpve-access-control libpve-apiclient-perl libquorum-dev librrd-dev librrds-perl \
libsqlite3-dev libtest-mockmodule-perl libuuid-perl rrdcached sqlite3  rsync \
libauthen-pam-perl libnet-ldap-perl  libpve-cluster-perl pve-cluster \
libjs-marked pve-eslint esbuild quilt   bash-completion dh-apparmor docbook2x libapparmor-dev libcap-dev \
libgnutls28-dev libseccomp-dev meson  libarchive-dev   libanyevent-perl   dh-python python3-all python3-setuptools python3-docutils \
liblocale-po-perl  help2man libpam0g-dev  libpve-storage-perl lxc-pve  \
libjpeg62-turbo-dev libpng-dev unifont  libspice-protocol-dev libspice-server-dev  libcap-ng-dev \
libio-multiplex-perl libjson-c-dev libpve-guest-common-perl libpve-storage-perl pve-edk2-firmware pve-firewall pve-ha-manager \
libposix-strptime-perl librados2-perl pve-qemu-kvm   zfsutils-linux \
libacl1-dev libaio-dev libattr1-dev libcap-ng-dev  libepoxy-dev libfdt-dev libgbm-dev libglusterfs-dev libiscsi-dev  libjemalloc-dev libjpeg-dev \
libnuma-dev libpixman-1-dev libproxmox-backup-qemu0-dev  librbd-dev \
libsdl1.2-dev    liburing-dev libusb-1.0-0-dev libusbredirparser-dev \
libvirglrenderer-dev libzstd-dev python3-sphinx python3-sphinx-rtd-theme texi2html xfslibs-dev \
abigail-tools libcurl4-openssl-dev libpam0g-dev python3-cffi python3-all-dev  groff libdbus-1-dev libknet-dev libnozzle-dev \
libreadline-dev libsnmp-dev libstatgrab-dev libsystemd-dev libxml2-dev doxygen graphviz \
libnl-3-dev libnl-route-3-dev libsctp-dev libbz2-dev liblz4-dev liblzo2-dev libnss3-dev libnspr4-dev \
libu2f-server-dev

}

installpackage_nopve(){
apt update 
apt install -y devscripts  build-essential librust-openssl-sys-dev git git-email pkg-config debhelper   \
cmake bison dwarves flex libdw-dev libelf-dev libiberty-dev lz4 zstd librados-dev \
libtest-mockmodule-perl  check libcmap-dev libcorosync-common-dev libcpg-dev libfuse-dev \
libglib2.0-dev libquorum-dev librrd-dev librrds-perl \
libsqlite3-dev libtest-mockmodule-perl libuuid-perl rrdcached sqlite3  rsync \
libauthen-pam-perl libnet-ldap-perl  \
libjs-marked esbuild quilt   bash-completion dh-apparmor docbook2x libapparmor-dev libcap-dev \
libgnutls28-dev libseccomp-dev meson  libarchive-dev   libanyevent-perl   dh-python python3-all python3-setuptools python3-docutils \
liblocale-po-perl  help2man libpam0g-dev \
libjpeg62-turbo-dev libpng-dev unifont  libspice-protocol-dev libspice-server-dev  libcap-ng-dev \
libio-multiplex-perl libjson-c-dev \
libposix-strptime-perl  \
libacl1-dev libaio-dev libattr1-dev libcap-ng-dev  libepoxy-dev libfdt-dev libgbm-dev libglusterfs-dev libiscsi-dev  libjemalloc-dev libjpeg-dev \
libnuma-dev libpixman-1-dev   librbd-dev \
libsdl1.2-dev    liburing-dev libusb-1.0-0-dev libusbredirparser-dev \
libvirglrenderer-dev libzstd-dev python3-sphinx python3-sphinx-rtd-theme texi2html xfslibs-dev \
abigail-tools libcurl4-openssl-dev libpam0g-dev python3-cffi python3-all-dev \
nodejs pkg-js-tools node-colors node-commander libcrypt-ssleay-perl
#for meson
#wget http://ftp.cn.debian.org/debian/pool/main/m/meson/meson_0.61.1-1~bpo11+1_all.deb && dpkg -i meson_0.61.1-1~bpo11+1_all.deb
}



aptsource
basepkg
pvesource
installpackage
installcargo
installdebcargo

git config --global https.proxy http://192.168.3.163:10809
git config --global http.proxy http://192.168.3.163:10809

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
>>>>>>> 0596e783bd0496c85a8648b9d99b9720883a0dba
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
<<<<<<< HEAD
find $pvedir -name "*.deb" -exec mv {} $pkgdir/ \;

=======
mkdir /var/pve/pkgs
find /var/pve/ -name "*.deb" -exec mv {} $pvedir/pkgs/ \;


#for lxcfs
sed -i "s/x86_64/aarch64/g" debian/rules
>>>>>>> 0596e783bd0496c85a8648b9d99b9720883a0dba
