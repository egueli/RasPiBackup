#!/bin/bash

# Path to configuration file.
CONFFILE="/etc/raspibackup.conf"

# Default number of backups. Can be overridden in $CONFFILE.
N_BACKUPS=5

if [[ ! -f $CONFFILE ]]; then
    echo "$CONFFILE doesn't exist. Please create one that contains BACKUP_ROOT=/path/to/store/your/backups ." >> /dev/stderr
	exit
fi

. $CONFFILE

if [[ ! -d $BACKUP_ROOT ]]; then
	echo "Backup root directory ($BACKUP_ROOT) not found. Ensure that $CONFFILE contains BACKUP_ROOT=/path/to/store/your/backups ." >> /dev/stderr
	exit
fi

set -e

# Do the real thing or just show the commands without running
runRemote=""
#runRemote="echo "

# delete the oldest backup
for fs in {boot,root}; do 
	set +e
	$runRemote sudo rm -r $BACKUP_ROOT/backup.$N_BACKUPS/$fs
	set -e
done

# shift the backups, starting with the oldest one
for ((src=$N_BACKUPS-1;src>=0;src--)); do
	dst=$((src+1))
	for fs in {boot,root}; do 
		set +e
		$runRemote sudo mv $BACKUP_ROOT/backup.$src/$fs $BACKUP_ROOT/backup.$dst
		set -e
	done
done

# do the actual backup
rsync \
	-avx \
	--delete \
	--link-dest $BACKUP_ROOT/backup.1/boot \
	/boot/ \
	$BACKUP_ROOT/backup.0/boot

rsync \
	-avx \
	--delete \
	--link-dest $BACKUP_ROOT/backup.1/root \
	/ \
	$BACKUP_ROOT/backup.0/root

