#! /bin/bash
DRIVER=535
DEBIAN_FRONTEND=noninteractive


apt show nvidia-driver-$DRIVER 2>&1 | grep -v "does not have a stable" | grep Version: | head -n1 | cut -f2 -d":" | tr -d ' ' > pika_nvidia.txt

rm -rfv /etc/apt/preferences.d/*
echo 'Pin: release c=external' > /etc/apt/preferences.d/0-a
echo 'Pin-Priority: 1000' >> /etc/apt/preferences.d/0-a
echo 'Package: *' >> /etc/apt/preferences.d/0-a
echo 'Pin: release c=ubuntu' >> /etc/apt/preferences.d/0-a
echo 'Pin-Priority: 1000' >> /etc/apt/preferences.d/0-a
# Clone Upstream
apt update -y
apt download nvidia-driver-"$DRIVER"
#wget https://ppa.launchpadcontent.net/graphics-drivers/ppa/ubuntu/pool/main/n/nvidia-graphics-drivers-545/nvidia-driver-545_545.113.01-0ubuntu3_amd64.deb
ar -x ./nvidia-driver-"$DRIVER"*.deb
mkdir -p ./nvidia-driver-"$DRIVER"/DEBIAN
tar -xf ./control.tar.* -C ./nvidia-driver-"$DRIVER"/DEBIAN/
tar -xf ./data.tar.* -C ./nvidia-driver-"$DRIVER"/
rm -rf ./nvidia-driver-"$DRIVER"*.deb

echo "$(cat ./nvidia-driver-"$DRIVER"/DEBIAN/control | grep "Version: " | cut -f2 -d":" | tr -d ' ')-100pika6" > ./build_version.txt

if cat ./build_version.txt | grep "$(cat ./pika_nvidia.txt)"
then
  echo "driver already built"
  exit 0
fi

sed -i "s#nvidia-dkms-"$DRIVER"#nvidia-pika-kernel-module-"$DRIVER" | nvidia-dkms-"$DRIVER"#" ./nvidia-driver-"$DRIVER"/DEBIAN/control
sed -i "s#$(cat ./nvidia-driver-"$DRIVER"/DEBIAN/control | grep "Version: ")#$(cat ./nvidia-driver-"$DRIVER"/DEBIAN/control | grep "Version: ")-100pika6#" ./nvidia-driver-"$DRIVER"/DEBIAN/control
apt install -y devscripts

# Build package
dpkg-deb --build ./nvidia-driver-"$DRIVER"/

# Move the debs to output
mkdir -p ./output
for i in ./*.deb
do
  mv $i_"$(cat ./build_version.txt)"_fixed.deb
done
