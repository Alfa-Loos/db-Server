#! /bin/bash
#
######################################################
# Das Backup von kp2_production von xtrabackup muss 
# im Verzeichnis
#             /data/backup/today
# liegen.
######################################################





### Globale Variablen
v_passwd="kp"
v_dbuser="root"
v_backup_path="/data/backup"
v_backup_database="kp2_production"
v_tables=""


### Übergabe Variablen



function production_to_dev()
	{
	## 
	echo "CREATE DATABASE cms_dev"  | mysql -pkp	
	mysqldump -u root -pkp cms_production | mysql -pkp cms_dev
	echo "DROP DATABASE cms_production"  | mysql -pkp

	## 
	echo "CREATE DATABASE googleloc_dev"  | mysql -pkp
	mysqldump -u root -pkp googleloc_production | mysql -pkp googleloc_dev
	echo "DROP DATABASE googleloc_production"  | mysql -pkp

	## 
	echo "CREATE DATABASE blingbling_dev"  | mysql -pkp
	mysqldump -u root -pkp kp2_blingbling_production | mysql -pkp blingbling_dev
	echo "DROP DATABASE kp2_blingbling_production"  | mysql -pkp

	## little one
	echo "CREATE DATABASE little_dev"  | mysql -pkp
	mysqldump -u root -pkp little_one | mysql -pkp little_dev
	echo "DROP DATABASE little_one"  | mysql -pkp
 }
 
 
function backup_umwandeln()
	{
        if [ -f "$v_backup_path/Stufe_II/kp2_production/leads.exp" ];
	  then
	  	echo "Umwandlung ist bereits erfolgt."
	  else
		## Dateien werden für den Transfer umgewandelt
		innobackupex --apply-log --export $v_backup_path/Stufe_II/
	  fi
}	
	
function anlegen_der_database()
	{	
#	database=$1
	echo $database
	## Nur wenn kein Backup geliefert wird
	if [ -f "$v_backup_path/kp2_today.sql" ];
	    then
	    	echo "habe ein Backup gefunden und werde das Schema verwenden"
	    else
	    	echo "habe kein Backup gefunden, lege erst mal ein neues an und versuche es damit."
		mysqldump -u $v_dbuser -p$v_passwd -d kp_today > $v_backup_path/kp2_today.sql
	fi
	echo "DROP DATABASE IF EXISTS $database;" | mysql -p$v_passwd

(var=" + 1bla") 2>/dev/null || echo "Fehler in Zuweisung"
echo $var
#exit

	echo "CREATE DATABASE $database;" | mysql -p$v_passwd
        cat $v_backup_path/kp2_today.sql  | mysql -p$v_passwd $database
}


function tabellen_auslesen()
	{
#	database=$1
	# Tabellen auslesen
	echo $database
	v_tables=`mysql -u$v_dbuser -p$v_passwd $database -se 'SHOW TABLES'`
}

function entkoppeln_der_datenbank()
	{
#	database=$1
	# Pfad zur Datenbank setzen
	cd /data/mysql/$database/
#	tabellen_auslesen $database
	# Tabellen durchgehen
	for TABLE in $v_tables;
	  do
  echo "entkoppel die Tabelle $TABLE"
  sleep 0.5
	  # Tabellen entkoppeln
	  mysql -u$v_dbuser -p$v_passwd $database -e "ALTER TABLE $TABLE DISCARD TABLESPACE; " > /dev/null
	  # löschen der alten Daten
	  rm -rf $TABLE.ibd
	done
}



function daten_austausch()
	{
#	database=$1 
#	v_tables=$2
        # Pfad zur Datenbank setzen
        cd /data/mysql/$database/  
#	tabellen_auslesen kp2_production
        for TABLE in $v_tables;
          do
	  echo "tausche die Daten für die Tabelle $TABLE aus"
	  cp $v_backup_path/Stufe_II/kp2_production/$TABLE.exp .
	  cp $v_backup_path/Stufe_II/kp2_production/$TABLE.ibd .
	  chown -R mysql:mysql /data/mysql/
	done
}

function neue_daten_einbinden()
	{
#        database=$1
        for TABLE in $v_tables;    
	  do
	  echo "binde jetzt die Tabelle $TABLE in die Datenbank $database ein"
	  mysql -u$v_dbuser -p$v_passwd $database -e "ALTER TABLE $database.$TABLE IMPORT TABLESPACE;" > /dev/null
	done
}

## Die Dateien vom SCP werden in einen definierten PATH verschoben.
## Da das DATUM und die Uhrzeit echt nerven.
function backup_vorbereiten {
  ## Sehe nach ob das backup schon bearbeitet wurde
  if [ -f "/data/backup/Stufe_II/ibdata1" ];
    then
	echo "ibdata1 in Stufe_II gefunden"
	echo "Daten werden nicht mehr kopiert"
   else
	echo "verschiebe jetzt das Backup und bereite es zum Austausch vor"
	mv /data/backup/Stufe_I/2016*/* /data/backup/Stufe_II/
	rm -R /data/backup/Stufe_I/*
  fi
}

function backup_vorbereiten_neu {
  ## sehe nach ob ein neues Backup da liegt
  order=`ls /data/backup/Stufe_I/`
  echo $order
  if [ -z "$order" ];
    then
	order="XXX"
	echo "Habe kein Backup gefunden"
    else
        echo "Habe ein backup gefunden"	
  fi  
  
  ## Sehe nach ob das backup schon bearbeitet wurde
  if [ -d "/data/backup/Stufe_I/$order" ];
    then
	echo "verschiebe jetzt das Backup und bereite es zum Austausch vor"
	rm -R /data/backup/Stufe_II/*
	mv /data/backup/Stufe_I/2016*/* /data/backup/Stufe_II/
	rm -R /data/backup/Stufe_I/*
   else
	echo "kein neues Backup gefunden"
	echo "Daten werden nicht mehr kopiert"
  fi
}


function parameter_uebergabe()
	{
}


### Main ###
database="kp_today"
#v_anzahl=$#
#database="kp_frontend"

#	parameter_uebergabe $v_anzahl					#$1 $2 $3 $4

	ordner="/data/backup/Stufe_II/"
	backup_vorbereiten_neu
	backup_umwandeln    					# muss im Verzeichnis /data/backup/today liegen
	anlegen_der_database 
	tabellen_auslesen
	entkoppeln_der_datenbank
	daten_austausch
	neue_daten_einbinden

	# löschen der alten Daten
	rm -rf /data/mysql/$database/*.exp
  
# ENDE #
