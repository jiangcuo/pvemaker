FROM debian:11
RUN apt update && apt install ca-certificates -y

RUN rm /etc/apt/sources.list && \
echo "deb https://mirrors.ustc.edu.cn/debian/ bullseye main contrib non-free" >> /etc/apt/sources.list && \
echo "deb https://mirrors.ustc.edu.cn/debian/ bullseye-updates main contrib non-free" >> /etc/apt/sources.list && \
echo "deb https://mirrors.ustc.edu.cn/debian/ bullseye-backports main contrib non-free" >> /etc/apt/sources.list && \
echo "deb https://mirrors.ustc.edu.cn/debian-security bullseye-security main contrib" >> /etc/apt/sources.list 

RUN apt update && \
apt install gpgv wget curl -y

RUN wget http://download.proxmox.com/debian/proxmox-release-bullseye.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg

RUN echo "deb https://mirrors.ustc.edu.cn/proxmox/debian bullseye pve-no-subscription" >> /etc/apt/sources.list && \
echo "deb https://mirrors.ustc.edu.cn/proxmox/debian/ceph-pacific bullseye main" >> /etc/apt/sources.list && \
echo "deb https://mirrors.ustc.edu.cn/proxmox/debian/devel bullseye main" >> /etc/apt/sources.list 

RUN  curl https://sh.rustup.rs -sSf >/rustset.sh && \
sh /rustset.sh  --default-host x86_64-unknown-linux-gnu --default-toolchain nightly --profile complete -y && \
cp -a ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/ ~/.rustup/toolchains/system && \
ln -s ~/.cargo/bin/* /usr/bin/ && \
rustup default system 

RUN apt update && \
apt  install -y devscripts  build-essential librust-openssl-sys-dev git git-email pkg-config debhelper pve-doc-generator  \
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


COPY setup.sh /
CMD ["bash","/setup.sh" ]






