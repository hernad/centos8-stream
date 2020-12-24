#!/bin/bash

step1() {

echo step 1
yum install -y epel-release
yum -y install rpmconf yum-utils
rpmconf -a
package-cleanup --leaves
package-cleanup --orphans
yum remove -y libsysfs-2.1.0-16.el7.x86_64 chefdk-4.6.35-1.el7.x86_64
yum -y install dnf
dnf makecache
dnf -y remove yum yum-metadata-parser
rm -Rf /etc/yum
dnf -y upgrade

}

step2() {

sed -i 's#^\(GRUB_CMDLINE_LINUX="console=tty0 crashkernel=auto console=ttyS0,115200\)"$#\1net.ifnames=0"#' /etc/default/grub

dnf install -y  http://mirror.centos.org/centos/8/BaseOS/x86_64/os/Packages/{centos-linux-release-8.3-1.2011.el8.noarch.rpm,centos-gpg-keys-8-2.el8.noarch.rpm,centos-linux-repos-8-2.el8.noarch.rpm}
dnf upgrade -y epel-release

dnf -y remove yum yum-metadata-parser

dnf -y upgrade https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf clean all

dnf -y remove python36

rpm -e --nodeps sysvinit-tools
rpm -e --nodeps gdbm

dnf clean packages
dnf -y upgrade
}

step3() {
rpm -e `rpm -q kernel`
#rpm -e `rpm -q kernel-plus`
dnf -y --releasever=8 --allowerasing --setopt=deltarpm=false distro-sync
dnf -y install kernel-core
grub2-mkconfig -o /boot/grub2/grub.cfg
}

stream() {

dnf -y install centos-release-stream
dnf -y distro-sync
cat /etc/redhat-release

}

yum_install() {

rm -rf /etc/yum
rm -rf /etc/yum.conf
dnf -y install yum

}


elrepo_gpg() {
curl -LO https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
gpg --quiet --with-fingerprint RPM-GPG-KEY-elrepo.org
rpm --import RPM-GPG-KEY-elrepo.org
}

kernel_info() {
echo "grubby kernels:" 
grubby --info=ALL | grep ^kernel
#kernel="/boot/vmlinuz-4.18.0-259.el8.x86_64" 
#kernel="/boot/vmlinuz-4.18.0-240.1.1.el8_3.x86_64" 
#kernel="/vmlinuz-0-rescue-05cb8c7b39fe0f70e3ce97e5beab809d" 

echo "kernel-devel:" 
dnf info kernel-devel | grep Release

echo "kernel current:" 
uname -r
echo "kernel on next boot:" 
grubby --grub2 --default-title

}

install_packages() {

dnf -y install htop vim git firewalld
dnf -y install cockpit cockpit-podman cockpit-system 

systemctl enable --now firewalld
systemctl enable --now cockpit.socket
firewall-cmd --add-service=cockpit --permanent
firewall-cmd --reload


dnf -y install policycoreutils-python-utils

}

git_hernad_switch_repos() {

cd /root
git clone https://github.com/hernad/centos8-stream.git

rm -rf /etc/dnf
rm -rf /etc/yum.repos.d
rsync -av /root/centos8-stream/etc/dnf /etc/
/etc/dnf
rsync -av /root/centos8-stream/etc/yum.repos.d /etc/

dnf -y update
}

wireguard_dkms() {
yum -y config-manager --set-enabled powertools
#yum -y install epel-release
#yum -y copr enable jdoss/wireguard
yum -y install wireguard-dkms wireguard-tools

cp -av ../patches/wireguard/1.0.20201221/compat-asm.h  /usr/src/wireguard-1.0.20201221/compat/compat-asm.h
dkms install wireguard/1.0.20201221 -k $(uname -r)
}

kernel_257() {

dnf install http://ftp.belnet.be/mirror/ftp.centos.org/8-stream/BaseOS/x86_64/os/Packages/kernel-devel-4.18.0-257.el8.x86_64.rpm
dnf install http://ftp.belnet.be/mirror/ftp.centos.org/8-stream/BaseOS/x86_64/os/Packages/kernel-core-4.18.0-257.el8.x86_64.rpm
}

#step1
#step2
#step3
#stream
#yum_install
#elrepo_gpg

#git_hernad_switch_repos
#kernel_257

install_packages
#wireguard_dkms
