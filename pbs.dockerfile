FROM debian:11

RUN rm /etc/apt/sources.list && \
echo "deb http://mirrors.ustc.edu.cn/debian/ bullseye main contrib non-free" >> /etc/apt/sources.list && \
echo "deb http://mirrors.ustc.edu.cn/debian/ bullseye-updates main contrib non-free" >> /etc/apt/sources.list && \
echo "deb http://mirrors.ustc.edu.cn/debian/ bullseye-backports main contrib non-free" >> /etc/apt/sources.list && \
echo "deb http://mirrors.ustc.edu.cn/debian-security bullseye-security main contrib" >> /etc/apt/sources.list 

RUN apt-get update && \
apt-get install wget sudo systemctl  curl gnupg  ca-certificates -y

RUN echo "deb https://foxi.buduanwang.vip/pan/foxi/Virtualization/proxmox/foxi/ pbsarm main" >>/etc/apt/sources.list.d/pbs.list && \
curl -L https://foxi.buduanwang.vip/pan/foxi/Virtualization/proxmox/foxi/gpg.key |apt-key add - 

RUN apt-get update && \
DEBIAN_FRONTEND=noninteractiv apt-get --no-install-recommends  install proxmox-backup-server -y

RUN echo "root:root"|chpasswd 

COPY pbssetup.sh /
RUN chmod a+x /pbssetup.sh
STOPSIGNAL SIGINT
CMD ["bash","/pbssetup.sh"]



# for amd64

FROM debian:11

RUN rm /etc/apt/sources.list && \
echo "deb http://mirrors.ustc.edu.cn/debian/ bullseye main contrib non-free" >> /etc/apt/sources.list && \
echo "deb http://mirrors.ustc.edu.cn/debian/ bullseye-updates main contrib non-free" >> /etc/apt/sources.list && \
echo "deb http://mirrors.ustc.edu.cn/debian/ bullseye-backports main contrib non-free" >> /etc/apt/sources.list && \
echo "deb http://mirrors.ustc.edu.cn/debian-security bullseye-security main contrib" >> /etc/apt/sources.list 

RUN apt-get update && \
apt-get install wget sudo systemctl  curl gnupg  ca-certificates -y

RUN echo "deb  https://mirrors.ustc.edu.cn/proxmox/debian/pbs bullseye  main pbs-no-subscription  " >>/etc/apt/sources.list.d/pbs.list && \
curl http://mirrors.ustc.edu.cn/proxmox/debian/proxmox-release-bullseye.gpg|apt-key add -

RUN apt-get update && \
DEBIAN_FRONTEND=noninteractiv apt-get --no-install-recommends  install proxmox-backup-server -y

RUN echo "root:root"|chpasswd

COPY pbssetup.sh /
RUN chmod a+x /pbssetup.sh
STOPSIGNAL SIGINT
CMD ["bash","/pbssetup.sh"]