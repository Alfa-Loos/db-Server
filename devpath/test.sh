#!/bin/bash
#
# Hier werden nur immer neue Functionen getestet
#


function backup_ordner_aufraeumen {
  for file in 2016*
	do
	mv /data/backup/kp2_dev/$file/* /data/backup
	rm -R /data/backup/kp2_dev
  done
}













### main

# backup_ordner_aufraeumen