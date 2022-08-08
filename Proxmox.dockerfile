FROM debian:11
RUN apt update && apt install ca-certificates -y
RUN rm /etc/apt/sources.list && \
echo "deb https://mirrors.ustc.edu.cn/debian/ bullseye main contrib non-free" >> /etc/apt/sources.list && \
echo "deb https://mirrors.ustc.edu.cn/debian/ bullseye-updates main contrib non-free" >> /etc/apt/sources.list && \
echo "deb https://mirrors.ustc.edu.cn/debian/ bullseye-backports main contrib non-free" >> /etc/apt/sources.list && \
echo "deb https://mirrors.ustc.edu.cn/debian-security bullseye-security main contrib" >> /etc/apt/sources.list 
RUN apt install gnupg2 wget -y
RUN wget http://download.proxmox.com/debian/proxmox-release-bullseye.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg
RUN echo "deb https://mirrors.ustc.edu.cn/proxmox/debian bullseye pve-no-subscription" >> /etc/apt/sources.list && \
echo "deb https://mirrors.ustc.edu.cn/proxmox/debian/ceph-pacific bullseye main" >> /etc/apt/sources.list && \
echo "deb https://mirrors.ustc.edu.cn/proxmox/debian/devel bullseye main" >> /etc/apt/sources.list 
RUN apt update && \
apt  install -y devscripts  build-essential librust-openssl-sys-dev git git-email pkg-config debhelper pve-doc-generator cmake bison dwarves flex libdw-dev libelf-dev libiberty-dev lz4 zstd

COPY setup.sh /
CMD ["bash","/setup.sh" ]






