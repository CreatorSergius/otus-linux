
[vagrant@Disksubsystem ~]$ lsblk 
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   40G  0 disk 
`-sda1   8:1    0   40G  0 part /
sdb      8:16   0  250M  0 disk 
sdc      8:32   0  250M  0 disk 
sdd      8:48   0  250M  0 disk 
sde      8:64   0  250M  0 disk 
sdf      8:80   0  250M  0 disk 
sdg      8:96   0  250M  0 disk 
[vagrant@Disksubsystem ~]$ lsscsi 
[0:0:0:0]    disk    ATA      VBOX HARDDISK    1.0   /dev/sda 
[3:0:0:0]    disk    ATA      VBOX HARDDISK    1.0   /dev/sdb 
[4:0:0:0]    disk    ATA      VBOX HARDDISK    1.0   /dev/sdc 
[5:0:0:0]    disk    ATA      VBOX HARDDISK    1.0   /dev/sdd 
[6:0:0:0]    disk    ATA      VBOX HARDDISK    1.0   /dev/sde 
[7:0:0:0]    disk    ATA      VBOX HARDDISK    1.0   /dev/sdf 
[8:0:0:0]    disk    ATA      VBOX HARDDISK    1.0   /dev/sdg 
[vagrant@Disksubsystem ~]$ sudo mdadm --zero-superblock --verbose /dev/sd{b,c,d,e,f}
mdadm: Unrecognised md component device - /dev/sdb
mdadm: Unrecognised md component device - /dev/sdc
mdadm: Unrecognised md component device - /dev/sdd
mdadm: Unrecognised md component device - /dev/sde
mdadm: Unrecognised md component device - /dev/sdf   
[vagrant@Disksubsystem ~]$ sudo mdadm  --create /dev/md0 --level=5 --raid-device 5 /dev/sd{b,c,d,e,f}
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
[vagrant@Disksubsystem ~]$ lsblk 
NAME   MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda      8:0    0   40G  0 disk  
`-sda1   8:1    0   40G  0 part  /
sdb      8:16   0  250M  0 disk  
`-md0    9:0    0  992M  0 raid5 
sdc      8:32   0  250M  0 disk  
`-md0    9:0    0  992M  0 raid5 
sdd      8:48   0  250M  0 disk  
`-md0    9:0    0  992M  0 raid5 
sde      8:64   0  250M  0 disk  
`-md0    9:0    0  992M  0 raid5 
sdf      8:80   0  250M  0 disk  
`-md0    9:0    0  992M  0 raid5 
sdg      8:96   0  250M  0 disk  
[vagrant@Disksubsystem ~]$ cat /proc/mdstat 
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid5 sdf[5] sde[3] sdd[2] sdc[1] sdb[0]
      1015808 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/5] [UUUUU]
      
unused devices: <none>
[vagrant@Disksubsystem ~]$ sudo mdadm --detail /dev/md0 
/dev/md0:
           Version : 1.2
     Creation Time : Tue Feb 18 18:05:32 2020
        Raid Level : raid5
        Array Size : 1015808 (992.00 MiB 1040.19 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Tue Feb 18 18:05:35 2020
             State : clean 
    Active Devices : 5
   Working Devices : 5
    Failed Devices : 0
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : Disksubsystem:0  (local to host Disksubsystem)
              UUID : 9e1acbd1:1d9ba609:9d936101:67f81188
            Events : 18

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       2       8       48        2      active sync   /dev/sdd
       3       8       64        3      active sync   /dev/sde
       5       8       80        4      active sync   /dev/sdf
       mkdict  mkdir   
[vagrant@Disksubsystem ~]$ sudo mkdir -p /etc/mdadm
[vagrant@Disksubsystem ~]$ sudo echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
-bash: /etc/mdadm/mdadm.conf: Permission denied
[vagrant@Disksubsystem ~]$ sudo -s
[root@Disksubsystem vagrant]# echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
[root@Disksubsystem vagrant]# mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf 
[root@Disksubsystem vagrant]# cat /etc/mdadm/mdadm.conf 
DEVICE partitions
ARRAY /dev/md0 level=raid5 num-devices=5 metadata=1.2 name=Disksubsystem:0 UUID=9e1acbd1:1d9ba609:9d936101:67f81188
#Создаю разделы дисков
[root@Disksubsystem vagrant]# parted -s /dev/md0 mklabel gpt
[root@Disksubsystem vagrant]# parted /dev/md0 mkpart primari ext4 0% 20%
Information: You may need to update /etc/fstab.

[root@Disksubsystem vagrant]# parted /dev/md0 mkpart primari ext4 20% 40%
Information: You may need to update /etc/fstab.

[root@Disksubsystem vagrant]# parted /dev/md0 mkpart primari ext4 40% 60%
Information: You may need to update /etc/fstab.

[root@Disksubsystem vagrant]# parted /dev/md0 mkpart primari ext4 60% 80%
Information: You may need to update /etc/fstab.

[root@Disksubsystem vagrant]# parted /dev/md0 mkpart primari ext4 80% 100%
Information: You may need to update /etc/fstab.

[root@Disksubsystem vagrant]# for i in $(seq 1 5); do mkfs.ext4 /dev/md0p$i; done
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=2048 blocks
50200 inodes, 200704 blocks
10035 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
25 block groups
8192 blocks per group, 8192 fragments per group
2008 inodes per group
Superblock backups stored on blocks: 
  8193, 24577, 40961, 57345, 73729

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done 

mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=2048 blocks
50800 inodes, 202752 blocks
10137 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
25 block groups
8192 blocks per group, 8192 fragments per group
2032 inodes per group
Superblock backups stored on blocks: 
  8193, 24577, 40961, 57345, 73729

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done 

mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=2048 blocks
51200 inodes, 204800 blocks
10240 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
25 block groups
8192 blocks per group, 8192 fragments per group
2048 inodes per group
Superblock backups stored on blocks: 
  8193, 24577, 40961, 57345, 73729

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done 

mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=2048 blocks
50800 inodes, 202752 blocks
10137 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
25 block groups
8192 blocks per group, 8192 fragments per group
2032 inodes per group
Superblock backups stored on blocks: 
  8193, 24577, 40961, 57345, 73729

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done 

mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=2048 blocks
50200 inodes, 200704 blocks
10035 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
25 block groups
8192 blocks per group, 8192 fragments per group
2008 inodes per group
Superblock backups stored on blocks: 
  8193, 24577, 40961, 57345, 73729

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done 

#Подключаю в директорию 
[root@Disksubsystem vagrant]# mkdi
mkdict  mkdir   
[root@Disksubsystem vagrant]# mkdir -p /raid/part{1,2,3,4,5}
[root@Disksubsystem vagrant]# for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done
[root@Disksubsystem vagrant]# ls /raid/part1
lost+found
[root@Disksubsystem vagrant]# ls /raid/part2
lost+found

 #Ломаю диск
[root@Disksubsystem vagrant]# lsblk
NAME      MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda         8:0    0   40G  0 disk  
`-sda1      8:1    0   40G  0 part  /
sdb         8:16   0  250M  0 disk  
`-md0       9:0    0  992M  0 raid5 
  |-md0p1 259:0    0  196M  0 md    /raid/part1
  |-md0p2 259:1    0  198M  0 md    /raid/part2
  |-md0p3 259:2    0  200M  0 md    /raid/part3
  |-md0p4 259:3    0  198M  0 md    /raid/part4
  `-md0p5 259:4    0  196M  0 md    /raid/part5
sdc         8:32   0  250M  0 disk  
`-md0       9:0    0  992M  0 raid5 
  |-md0p1 259:0    0  196M  0 md    /raid/part1
  |-md0p2 259:1    0  198M  0 md    /raid/part2
  |-md0p3 259:2    0  200M  0 md    /raid/part3
  |-md0p4 259:3    0  198M  0 md    /raid/part4
  `-md0p5 259:4    0  196M  0 md    /raid/part5
sdd         8:48   0  250M  0 disk  
`-md0       9:0    0  992M  0 raid5 
  |-md0p1 259:0    0  196M  0 md    /raid/part1
  |-md0p2 259:1    0  198M  0 md    /raid/part2
  |-md0p3 259:2    0  200M  0 md    /raid/part3
  |-md0p4 259:3    0  198M  0 md    /raid/part4
  `-md0p5 259:4    0  196M  0 md    /raid/part5
sde         8:64   0  250M  0 disk  
`-md0       9:0    0  992M  0 raid5 
  |-md0p1 259:0    0  196M  0 md    /raid/part1
  |-md0p2 259:1    0  198M  0 md    /raid/part2
  |-md0p3 259:2    0  200M  0 md    /raid/part3
  |-md0p4 259:3    0  198M  0 md    /raid/part4
  `-md0p5 259:4    0  196M  0 md    /raid/part5
sdf         8:80   0  250M  0 disk  
`-md0       9:0    0  992M  0 raid5 
  |-md0p1 259:0    0  196M  0 md    /raid/part1
  |-md0p2 259:1    0  198M  0 md    /raid/part2
  |-md0p3 259:2    0  200M  0 md    /raid/part3
  |-md0p4 259:3    0  198M  0 md    /raid/part4
  `-md0p5 259:4    0  196M  0 md    /raid/part5
sdg         8:96   0  250M  0 disk  
[root@Disksubsystem vagrant]# mdadm /dev/md0 --fail /dev/sdf
mdadm: set /dev/sdf faulty in /dev/md0
[root@Disksubsystem vagrant]# cat /proc/mdstat 
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid5 sdf[5](F) sde[3] sdd[2] sdc[1] sdb[0]
      1015808 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/4] [UUUU_]
      
unused devices: <none>
[root@Disksubsystem vagrant]# mdadm --detail /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Tue Feb 18 18:05:32 2020
        Raid Level : raid5
        Array Size : 1015808 (992.00 MiB 1040.19 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Tue Feb 18 18:30:56 2020
             State : clean, degraded 
    Active Devices : 4
   Working Devices : 4
    Failed Devices : 1
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : Disksubsystem:0  (local to host Disksubsystem)
              UUID : 9e1acbd1:1d9ba609:9d936101:67f81188
            Events : 20

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       2       8       48        2      active sync   /dev/sdd
       3       8       64        3      active sync   /dev/sde
       -       0        0        4      removed

       5       8       80        -      faulty   /dev/sdf
[root@Disksubsystem vagrant]# mdadm /dev/md0 --remove /dev/sdf
mdadm: hot removed /dev/sdf from /dev/md0
[root@Disksubsystem vagrant]# mdadm /dev/md0 --add /dev/sdg
mdadm: added /dev/sdg
[root@Disksubsystem vagrant]# cat /proc/mdstat 
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid5 sdg[5] sde[3] sdd[2] sdc[1] sdb[0]
      1015808 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/5] [UUUUU]
      
unused devices: <none>
[root@Disksubsystem vagrant]# mdadm --detail /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Tue Feb 18 18:05:32 2020
        Raid Level : raid5
        Array Size : 1015808 (992.00 MiB 1040.19 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Tue Feb 18 18:34:16 2020
             State : clean 
    Active Devices : 5
   Working Devices : 5
    Failed Devices : 0
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : Disksubsystem:0  (local to host Disksubsystem)
              UUID : 9e1acbd1:1d9ba609:9d936101:67f81188
            Events : 40

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       2       8       48        2      active sync   /dev/sdd
       3       8       64        3      active sync   /dev/sde
       5       8       96        4      active sync   /dev/sdg
[root@Disksubsystem vagrant]#
