#Список команд создания массива и файловой системы.

sudo mdadm --zero-superblock --verbose /dev/sd{b,c,d,e,f}  
sudo mdadm  --create /dev/md0 --level=5 --raid-device 5 /dev/sd{b,c,d,e,f}      
sudo mkdir -p /etc/mdadm
sudo -s
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf 
parted -s /dev/md0 mklabel gpt
parted /dev/md0 mkpart primari ext4 0% 20%
parted /dev/md0 mkpart primari ext4 20% 40%
parted /dev/md0 mkpart primari ext4 40% 60%
parted /dev/md0 mkpart primari ext4 60% 80%
parted /dev/md0 mkpart primari ext4 80% 100%
for i in $(seq 1 5); do mkfs.ext4 /dev/md0p$i; done
mkdir -p /raid/part{1,2,3,4,5}
for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done

mdadm /dev/md0 --fail /dev/sdf
mdadm /dev/md0 --remove /dev/sdf
mdadm /dev/md0 --add /dev/sdg