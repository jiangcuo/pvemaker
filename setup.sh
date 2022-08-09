#!/bin/bash

pvepackages=(
corosync-pve
ceph
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
abigail-tools libcurl4-openssl-dev libpam0g-dev python3-cffi python3-all-dev
}

aptsource
basepkg
pvesource
installpackage
installcargo
installdebcargo


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
