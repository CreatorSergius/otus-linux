#!/bin/bash
#Список команд создания массива и файловой системы.

#Очитска метаданных на дисках 
mdadm --zero-superblock --verbose /dev/sd{b,c,d,e,f}  
#Создание raid1 массива 1 из двух устройств.
mdadm  --create /dev/md0 --level=5 --raid-device 5 /dev/sd{b,c,d,e,f} 
#Создание конфигурационного файла для хранения настроек Raid     
echo "DEVICE partitions" > /etc/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/vamdadm.conf 
#разметка диска и создание файловой системы
parted -s /dev/md0 mklabel gpt
parted /dev/md0 mkpart primari ext4 0% 20%
parted /dev/md0 mkpart primari ext4 20% 40%
parted /dev/md0 mkpart primari ext4 40% 60%
parted /dev/md0 mkpart primari ext4 60% 80%
parted /dev/md0 mkpart primari ext4 80% 100%
for i in $(seq 1 5); do mkfs.ext4 /dev/md0p$i; done
#Создание в корне папки для разделов
mkdir -p /raid/part{1,2,3,4,5}
#Монтирование raid в папку
for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done
#Настройка конфигурационного файла fstab для автоматического монтирования 
for i in $(seq 1 5); do echo /dev/md0p$i /raid/part$i ext4 defaults 0 0 >> /etc/fstab; done
mount -a
#mdadm /dev/md0 --fail /dev/sdf
#mdadm /dev/md0 --remove /dev/sdf
#mdadm /dev/md0 --add /dev/sdgvag	