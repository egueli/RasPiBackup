# RasPiBackup

A simple backup system for my home Raspberry Pi-based server. You just need to run `doBackup.sh`. It will copy all files from the two partitions in the SD card, i.e. `/` and `/boot`.

The main feature of this system is that each backup doesn't take additional space if no files are changed since the last one. Only the new or changed files are stored.

This requires the backups to reside in a filesystem that supports hard links, like ext2/ext3/ext4.

This backup system assumes it's OK to back up files while being used. It's recommended to run a backup when the system isn't doing anything important.

# Usage

First, ensure that `rsync` is installed in the system.

Create a configuration file in `/etc/raspibackup.conf` with the following:

```
BACKUP_ROOT=/path/to/store/your/backups
```

Now run the following to start the first backup:
```
doBackup.sh
```
It will run commands with `sudo`, so you may be asked for a password. Admin privileges are needed to copy system files as well as user files.

It will print all files being copied. 
Once finished, you'll find the files in a `backup.0` subdirectory. It will contain two more subdirectories, `boot` and `root`, with all the files on your system.