#!/bin/env bash

DUMP='/srv/dump/mysql/blogs'
STAGE='/srv/backup/stage/mysql'
/usr/bin/rsync -avi ${DUMP}/ ${STAGE}/
