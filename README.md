# RasPiBackup

A simple backup system for my home Raspberry Pi-based server, meant to back up all files from the two partitions in the SD card, i.e. `/` and `/boot`.

The main feature of this system is that each backup doesn't take additional space if no files are changed since the last one. Only the new or changed files are stored.

This requires the backups to reside in a filesystem that supports hard links, like ext2/ext3/ext4.

This backup system assumes it's OK to back up files while being used. It's recommended to run a backup when the system isn't doing anything important.

# Usage

First, ensure that `rsync` is installed in the system.

Create a configuration file in `/etc/raspibackup.conf` with the following:

```
BACKUP_ROOT=/path/to/store/your/backups
```

*Note:* The backup path must reside on a different storage than the Pi's SD card.

Now run the following to start the first backup:
```
sudo ./doBackup.sh
```
You may be asked for a password. Admin privileges are needed to copy system files as well as user files.

It will print all files being copied. 
Once finished, you'll find the files in a `backup.0` subdirectory. It will contain two more subdirectories, `boot` and `root`, with all the files on your system.

## Incremental backups and rotation

Older backups will be renamed to `backup.1`, `backup.2` and so on, up to `backup.5`. 5 is the default maximum backup number, but it can be changed by adding `N_BACKUPS=10` to the configuration file.

## Running periodically

The script can back up your system periodically with no user intervention, see [Scheduling tasks with Cron](https://www.raspberrypi.org/documentation/linux/usage/cron.md).

By default, `cron` will send a mail with the script output. Because the script will print all files being copied, you'll get an email listing which new/changed files have been backed up.

## Restore

I don't have general instruction how to restore. Here's what worked for me when some system files got corrupted, I wasn't able to boot my system anymore and a restore was my only option left, YMMV:

1. I made an image of the SD card with `dd`, just in case the restore itself would fail;
2. With the SD card on a laptop running Linux I reformatted the boot and system partitions, with `mkfs.vfat /dev/mmcblk0p1` and `mkfs.ext4 -E nodiscard /dev/mmcblk0p2` respectively;
3. I unplugged the external hard drive keeping my backups from the Pi, and plugged it to the laptop;
4. I mounted both partitions, then copied all files from `boot` and `root` while preserving as much metadata as possible with `cp -av`.
6. I unmounted the patitions and moved the SD card back to the Pi;
7. I unmounted the external hard drive and moved from the laptop back to the Pi;
8. I turned on the Pi, kept my fingers crossed, and watched it going back to life :) 
