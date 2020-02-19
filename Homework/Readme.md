
Порядок выполнения ДЗ.

1. Создаю дополнительные диски в vagrant.
2. Осматриваюсь какие жесткие диски появильсь, далее удаляю на дисках метанные от raid. 
3. Создаю масив уровня 5 из 5 дисков (отказоустойчивость -1 диск). Проверяю состояния диска в файле mdstat и с помощью утилиты mdadm --detail /dev/md0 .
4. Создаю директорию mdadm в папке /etc. Создаю файл mdadm.conf  для сбора масcива при загрузке.
5. Помечаю массив с разметкой GPT утилитой parted.
6. Разбиваю массив на 5 разделов.
7. Создаю файловую систему на 5 разделах, файловая система EXT4
8. Монтирую разделы в директории /raid/part1, /raid/part2 .. и т.д.
9. Проверяю смотировались ли разделы, ls /raid/part1
10. Ломаю массив, помечаю диск sdf как не исправный,
11. Проверяю какой диск не справный с помойщью утилит как в пукте 3.
12. Почаю диск на удаление.
13. Подключаю новый диск.
14. Проверяю состояние массива.






Список используемой литературы.
http://xgu.ru/wiki/mdadm

https://otus.ru/media-private/0f/c5/%D0%9C%D0%B5%D1%82%D0%BE%D0%B4%D0%B8%D1%87%D0%BA%D0%B0_%D0%94%D0%B8%D1%81%D0%BA%D0%BE%D0%B2%D0%B0%D1%8F_%D0%BF%D0%BE%D0%B4%D1%81%D0%B8%D1%81%D1%82%D0%B5%D0%BC%D0%B0_RAID_Linux-5373-0fc5b2.pdf?hash=A_jv9RTSEexWz6gkb9ei-w&expires=1581970407

https://docs.google.com/document/d/1m4niuv-rxMbLjdQ4qS8xG-UpMlMUA8C5yKRQ3IVEi-M/edit

https://habr.com/ru/post/200194/




















						Список дисков до разметки 
[vagrant@Disksubsystem ~]$ lsblk
sda      8:0    0   40G  0 disk 
`-sda1   8:1    0   40G  0 part /
sdb      8:16   0  250M  0 disk 
sdc      8:32   0  250M  0 disk 
sdd      8:48   0  250M  0 disk 
sde      8:64   0  250M  0 disk 
sdf      8:80   0  250M  0 disk 
sdg      8:96   0  250M  0 disk  

				Список дисков после создания массива уровня 5 
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

								Статус массива
[vagrant@Disksubsystem ~]$ cat /proc/mdstat 
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid5 sdf[5] sde[3] sdd[2] sdc[1] sdb[0]
      1015808 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/5] [UUUUU]

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



[vagrant@Disksubsystem ~]$ ls /raid/part1
lost+found 
[vagrant@Disksubsystem ~]$ ls /raid/part2
lost+found




#Ломаю диск "sdf"
 lsblk
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
 mdadm /dev/md0 --fail /dev/sdf
mdadm: set /dev/sdf faulty in /dev/md0
 cat /proc/mdstat 
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid5 sdf[5](F) sde[3] sdd[2] sdc[1] sdb[0]
      1015808 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/4] [UUUU_]
      
unused devices: <none>
 mdadm --detail /dev/md0
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
 mdadm /dev/md0 --remove /dev/sdf
mdadm: hot removed /dev/sdf from /dev/md0
 mdadm /dev/md0 --add /dev/sdg
mdadm: added /dev/sdg
 cat /proc/mdstat 
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid5 sdg[5] sde[3] sdd[2] sdc[1] sdb[0]
      1015808 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/5] [UUUUU]
      
unused devices: <none>
 mdadm --detail /dev/md0
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
