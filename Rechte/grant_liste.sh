#!/bin/bash
##
#	This script revokes all permissions, and grant all permissions
#	for the database to the standard game user, the maintenance user,
#	the backup user and the ticket user for the ticketoptions-tool
#	if an user doesn't exist this script will create the user
#
#	Andreas Loos
#	Andreas.Loos@kaeuferportal.de
#
#	(c) beko Käuferportal GmbH
#
# IP des Servers einlesen.
# echo -p "Bitte geben sie den Deinamen der pwd.txt ein "
# read Datei
clear
search_dir="/opt/scripte/Rechte"


## Folgende Dateien stehen zur Verfügung
#echo " "                                        
#echo "Folgende Dateien stehen zur Verfügung"
#echo " "

for entry in "$search_dir"/*.txt    # "$work_dir"/*
do
  if [ -f "$entry" ];then
#      echo "$entry"
      echo -n ""
  fi
done


## IP herrausfinden
IP=$(/sbin/ifconfig | sed -n '2 p' | awk '{print $2}' |  sed s/addr://g | sed s/Adresse://g)
echo "Server hat folgende IP:  $IP" 


v_IP=$(/sbin/ifconfig | sed -n '2 p' | awk '{print $2}' | sed s/addr://g | sed s/Adresse://g | sed s/192.168.//g)
Dateiname="$search_dir/pwd_$v_IP.txt"

## Informationen ausgeben
#echo " "
#echo " "                                        
#if [ -f "$Dateiname" ];then
#        echo "Benutze die Passwortdatei:  $Dateiname"
#	sleep 10
#else
#	echo "Dateiname war nicht zu ermitteln oder ist falsch." 
#	echo "Bitte geben sie folgende Datei: $Dateiname ein"
# 	exit
#fi


##
#	Standart user / Passwort / Rechte Array
. $Dateiname

##
# 	Tabellen die read only sind
#
v_READONLY_TABLES=""

##
#	SQL Server
#
v_SQL_IP="localhost"

##
#	get password
#
#printf "password for %s on the local database: " "${v_SQL_DATABASE}"
#read v_SQL_PASS

##
#	bauen des connect string
#
v_CONNECT="mysql  -u${v_SQL_USER} -p${v_SQL_PASS}"

##
#	path to tempfile
#
P_TEMP="/tmp/setDatabasePermissions.tmp"

#########  ENDE der Variablendefinitionen ###########

for POS in $v_POS
	do
	echo "==========================================="
	echo "### Konto: $POS	${v_USER[$POS]}	###"
	echo "Kontobegründung: " ${v_KGB[$POS]}
	echo "Rechtegruppe: " ${v_PERM[$POS]}
	echo "-------------------------------------------"
#	echo -n "## USER:  ${v_USER[$POS]}	"
	zeichenkette=${v_GKD[$POS]}
	v_Datum="${zeichenkette:6:4}-${zeichenkette:3:2}-${zeichenkette:0:2}"
	echo -n "Konto gültig bis: $zeichenkette	" 
#	echo -n " $zeichenkette	" 
	#	echo "Habe es umgewandelt:  $v_Datum"
	v_Datum=$(date -d $v_Datum +%s)
	#	echo "in Unixtime umgewandelt:  $v_Datum"
	v_aktDatum=$(date +%s)
	#	echo "$v_Datum muss groesser sein als $v_aktDatum"
	
	### Prüfen ob das Datum noch gültig ist
	if [ $v_Datum -ge $v_aktDatum  ]
	  then
	        
#		echo -n " -->> "
##		echo -n `date $v_Datum` - `date $vaktDatum` | bc
		echo " (gültig) "
		## Rechte auslesen
		PERM="v_PERM_"${v_PERM[$POS]}
		eval PERM=\${$PERM}
     		v_DB=""
		for DB_default in ${v_SQL_DB[$POS]}
		  do
			#echo " Variable die in die IF Anweisung reingeht:  $DB_default"
			if [ $DB_default = 'default' ]
			  then
#			  v_User="kp_${v_USER[$POS]}"
			  v_DB="$v_DB $DBx" # $v_User"
#			  echo "1 default: $v_User"
                        elif [ $DB_default = 'dbUserName' ]  # ob der Datenbankname für den User angelegt werden soll
			  then
			  v_User="kp_${v_USER[$POS]}"
                          v_DB="$v_DB $v_User"
#			  echo "2 User Datenbank"
			else
			  v_DB="$v_DB $DB_default"
#			  echo "3 eingetragene Datenbanken"
			fi
		done
		

		## Für die Ausgabe der Querrys
		echo "# Rechte für folgende Datenbanken:"
		for DB in $v_DB
		do
			for SERVER in ${v_HOSTS[$POS]}
			do
#				echo "Host:  "$SERVER
			if [[ "$DB" == *"."* ]]; then
				echo "Server: $SERVER		Datenbank: $DB"

			else
				echo "Server: $SERVER		Datenbank: $DB"		
			fi
#				echo ""
			done
		done
	else
		echo " -->> Datum abgelaufen"
	fi
	sleep 0.5
	echo ""
	echo ""
	echo ""
done
echo "FLUSH PRIVILEGES;"  | ${v_CONNECT} mysql

exit

