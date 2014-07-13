#!/bin/env bash

DATETIME=`date +%Y%m%d-%H%M%S`
HOST=`hostname --short`
DUMPNAME="${HOST}-mysqldump"
BACKUPNAME="${HOST}-mysqlbackup"
DUMPDIR='/srv/dump/mysql/blogs'
STAGEDIR='/srv/backup/stage/mysql'
BACKUPDIR='/srv/backup/mysql'
#DBUSER='username'
#DBPASS='password'
. ./mysql_perms.conf

# Dump ALL databases.
/usr/bin/mysqldump \
   --user=${DBUSER} \
   --password=${DBPASS} \
   --opt \
   --all-databases \
   --flush-logs  \
   --flush-privileges \
   --lock-all-tables \
   > ${BACKUPDIR}/${DUMPNAME}_${DATETIME}.sql

# Get the current binary log.
CURBLOG=`/usr/bin/mysql \
   --user=${DBUSER} \
   --password=${DBPASS} \
   --skip-column-names \
   --batch \
   -e "SHOW MASTER STATUS" \
   | cut -f1`

# Make sure binary logs are all caught up save for the current one.
/usr/bin/rsync -a --exclude=${CURBLOG} ${DUMPDIR}/ ${STAGEDIR}/

# Purge the now backup binary log files.
/usr/local/sbin/mysql_purgeblogs.pl

# Package everything into a tidy tarball.
tar -cvzf ${BACKUPDIR}/${BACKUPNAME}_${DATETIME}.tar.gz -C ${STAGEDIR} . && rm -f ${STAGEDIR}/*

# Move the SQL dump back to stage.
mv ${BACKUPDIR}/${DUMPNAME}_${DATETIME}.sql ${STAGEDIR}/${DUMPNAME}_${DATETIME}.sql
