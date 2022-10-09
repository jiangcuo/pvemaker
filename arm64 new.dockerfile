FROM registry.cn-chengdu.aliyuncs.com/bingsin/pve:aarch64-7.2-7

RUN rm /etc/apt/sources.list && \
echo "deb http://mirrors.ustc.edu.cn/debian/ bullseye main contrib non-free" >> /etc/apt/sources.list && \
echo "deb http://mirrors.ustc.edu.cn/debian/ bullseye-updates main contrib non-free" >> /etc/apt/sources.list && \
echo "deb http://mirrors.ustc.edu.cn/debian/ bullseye-backports main contrib non-free" >> /etc/apt/sources.list && \
echo "deb http://mirrors.ustc.edu.cn/debian-security bullseye-security main contrib" >> /etc/apt/sources.list && \
rm /etc/apt/sources.list.d/*

RUN apt update && \
apt install gpgv wget curl -y

RUN curl http://10.13.14.10/proxmox/gpg.key |apt-key add - && \
echo "deb http://10.13.14.10/proxmox bullseye main" >> /etc/apt/sources.list && \
echo "deb http://10.13.14.10/proxmox pvearmdev main" >> /etc/apt/sources.list 

#installed main packages
RUN apt update && \
apt  install -y  cargo dh-cargo devscripts debcargo build-essential librust-openssl-sys-dev git git-email pkg-config debhelper pve-doc-generator  \
cmake bison dwarves flex libdw-dev libelf-dev libiberty-dev lz4 zstd librados-dev \
libtest-mockmodule-perl  check libcmap-dev libcorosync-common-dev libcpg-dev libfuse-dev \
libglib2.0-dev libpve-access-control libpve-apiclient-perl libquorum-dev librrd-dev librrds-perl \
libsqlite3-dev libtest-mockmodule-perl libuuid-perl rrdcached sqlite3  rsync \
libauthen-pam-perl libnet-ldap-perl  libpve-cluster-perl pve-cluster \
libjs-marked pve-eslint esbuild quilt   bash-completion dh-apparmor docbook2x libapparmor-dev libcap-dev \
libgnutls28-dev libseccomp-dev meson=0.61.1-1~bpo11+1  libarchive-dev   libanyevent-perl   dh-python python3-all python3-setuptools python3-docutils \
liblocale-po-perl  help2man libpam0g-dev  libpve-storage-perl lxc-pve  \
libjpeg62-turbo-dev libpng-dev unifont  libspice-protocol-dev libspice-server-dev  libcap-ng-dev \
libio-multiplex-perl libjson-c-dev libpve-guest-common-perl libpve-storage-perl pve-edk2-firmware pve-firewall pve-ha-manager \
libposix-strptime-perl librados2-perl pve-qemu-kvm   zfsutils-linux \
libacl1-dev libaio-dev libattr1-dev libcap-ng-dev  libepoxy-dev libfdt-dev libgbm-dev libglusterfs-dev libiscsi-dev  libjemalloc-dev libjpeg-dev \
libnuma-dev libpixman-1-dev libproxmox-backup-qemu0-dev  librbd-dev \
libsdl1.2-dev    liburing-dev libusb-1.0-0-dev libusbredirparser-dev \
libvirglrenderer-dev libzstd-dev python3-sphinx python3-sphinx-rtd-theme texi2html xfslibs-dev \
abigail-tools libcurl4-openssl-dev libpam0g-dev python3-cffi python3-all-dev groff \
libdbus-1-dev libknet-dev libnozzle-dev libreadline-dev libsnmp-dev libstatgrab-dev libsystemd-dev doxygen graphviz cython3 default-jdk dh-exec golang gperf javahelper \
junit4 libbabeltrace-ctf-dev libbabeltrace-dev libcryptsetup-dev libcunit1-dev \
libfmt-dev  libgoogle-perftools-dev libibverbs-dev librdmacm-dev libkeyutils-dev \
libldap2-dev liblttng-ust-dev liblua5.3-dev liblz4-dev libnss3-dev liboath-dev \
libsnappy-dev libnl-genl-3-dev librabbitmq-dev libre2-dev libutf8proc-dev \
librdkafka-dev luarocks libthrift-dev python3-cherrypy3 python3-natsort python3-venv \
valgrind nasm libbz2-dev 

#install rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs >>rustinit.sh && \
RUSTUP_INIT_SKIP_PATH_CHECK=yes sh rustinit.sh --default-toolchain  nightly  --profile complete -y  

RUN export PATH="$HOME/.cargo/bin:$PATH" && \
rm /usr/bin/cargo* /usr/bin/rust* && \
ln -s ~/.cargo/bin/* /usr/bin/ && \
cp -r ~/.rustup/toolchains/nightly-aarch64-unknown-linux-gnu/ ~/.rustup/toolchains/system && \
rustup default system 

RUN wget http://mirrors.ustc.edu.cn/proxmox/debian/devel/dists/bullseye/main/binary-amd64/dh-cargo_28~bpo11%2Bpve1_all.de && \
dpkg -i dh-cargo_28~bpo11+pve1_all.deb

#install debcargo
RUN cd  /usr/local && \
git clone https://salsa.debian.org/rust-team/debcargo.git && \
cd debcargo && \
cargo build --release  && \
rm /usr/bin/debcargo && \
ln -s /usr/local/debcargo/target/release/debcargo /usr/bin/

RUN apt clean -y && \   
  rm -rf \
  /var/cache/debconf/* \
  /var/lib/apt/lists/* \
  /var/log/* \
  /var/tmp/* \
  && rm -rf /tmp/*

#pve-network need quorum ,so we need pve-cluster healty, use systemd for first init.
CMD [ "/lib/systemd/systemd", "log-level=info", "unit=sysinit.target"]


##fix-cargo