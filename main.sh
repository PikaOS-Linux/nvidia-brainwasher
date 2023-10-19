#! /bin/bash
DRIVER=535
DEBIAN_FRONTEND=noninteractive

# Clone Upstream
echo 'Package: *' > /etc/apt/preferences.d/0-a
echo 'Pin: release c=external' >> /etc/apt/preferences.d/0-a
echo 'Pin-Priority: 1000' >> /etc/apt/preferences.d/0-a
apt update -y
apt download nvidia-driver-"$DRIVER"
#wget https://ppa.launchpadcontent.net/graphics-drivers/ppa/ubuntu/pool/main/n/nvidia-graphics-drivers-535/nvidia-driver-535_535.113.01-0ubuntu3_amd64.deb
ar -x ./nvidia-driver-"$DRIVER"*.deb
mkdir -p ./nvidia-driver-"$DRIVER"/DEBIAN
tar -xf ./control.tar.* -C ./nvidia-driver-"$DRIVER"/DEBIAN/
tar -xf ./data.tar.* -C ./nvidia-driver-"$DRIVER"/
sed -i "s#nvidia-dkms-"$DRIVER"#nvidia-pika-kernel-module-"$DRIVER" | nvidia-dkms-"$DRIVER"#" ./nvidia-driver-"$DRIVER"/DEBIAN/control
sed -i "s#$(cat ./nvidia-driver-"$DRIVER"/DEBIAN/control | grep "Version: ")#$(cat ./nvidia-driver-"$DRIVER"/DEBIAN/control | grep "Version: ")-pika1.lunar#" ./nvidia-driver-"$DRIVER"/DEBIAN/control

apt install -y devscripts

# Build package
dpkg-deb --build ./nvidia-driver-"$DRIVER"/

# Move the debs to output
mkdir -p ./output
for i in ./*.deb
do
  mv $i ./output/$i-"$(apt-cache show nvidia-kernel-source-$DRIVER | grep Version: | head -n1 | cut -f2 -d":" | tr -d ' ')".deb
done
