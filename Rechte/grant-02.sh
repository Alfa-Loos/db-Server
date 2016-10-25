!/bin/bash
###
#	This script revokes all permissions, and grant all permissions
#	for the database to the standard game user, the maintenance user,
#	the backup user and the ticket user for the ticketoptions-tool
#	if an user doesn't exist this script will create the user
#
#	Andreas Loos
#	Andreas.Loos@kaeuferportal.de
#
#	(c) beko Käuferportal GmbH
###
clear
search_dir="/opt/scripte/Rechte"

##
#	for debugging use
#	Funktion wird noch nicht unterstützt
v_DEBUG=false

##
# 	Tabellen die read only sind
#
v_READONLY_TABLES=""

##
#	SQL Server
#
v_SQL_IP="localhost"
v_SQL_USER="root"
v_SQL_PASS="kp"
v_SQL_PORT="3307"

##
#	path to tempfile
#
P_TEMP="/tmp/setDatabasePermissions.tmp"

### Welche User nicht gelöscht werden dürfen.
## where NOT (user='root' OR user='cmon' OR user='debian-sys-maint' OR user='reploffice_27' OR user='cluster')
v_SQL_NOT_DEL_USER="user='root' OR user='cmon' OR user='debian-sys-maint' OR user='reploffice_27' OR user='cluster'"


### leere globale Variablen
v_CONNECT=""
v_aktDatum=""
v_Datum=""
Dateiname=""

#########  ENDE der Variablendefinitionen ###########

### Funktionen

function db_connect_string()
	{
	##
	#	Standart user / Passwort / Rechte Array

	##
	#	get password
	#
	#printf "password for %s on the local database: " "${v_SQL_DATABASE}"
	echo "Password für ${v_SQL_USER} auf der localen Databank: " "${v_SQL_DATABASE} ist ${v_SQL_PASS}"
  echo "Verbinde mich mit $v_SQL_IP auf Port $v_SQL_PORT"
	#read v_SQL_PASS
	
	##
	#	bauen des connect string
	#
	v_CONNECT="mysql  -u${v_SQL_USER} -p${v_SQL_PASS} -P$v_SQL_PORT"
}


## Folgende Dateien stehen zur Verfügung
function direktory_einlesen()
	{
	echo " "                                        
	echo "Folgende Dateien stehen zur Verfügung"
	echo " "
	for entry in "$search_dir"/*.txt    # "$work_dir"/*
	do
	  if [ -f "$entry" ];then
	      echo "$entry"
	  fi
	done
}

# IP des Servers einlesen.
# echo -p "Bitte geben sie den Deinamen der pwd.txt ein "
# read Datei
function ip_herausfinden()
	{
	## IP herrausfinden
	IP=$(/sbin/ifconfig | sed -n '2 p' | awk '{print $2}' |  sed s/addr://g | sed s/Adresse://g)
	echo5
	echo "Folgende IP wird benutzt:  $IP" 
	v_IP=$(/sbin/ifconfig | sed -n '2 p' | awk '{print $2}' | sed s/addr://g | sed s/Adresse://g | sed s/192.168.//g)
	Dateiname="$search_dir/pwd_$v_IP.txt"
}

## Informationen ausgeben
function datei_ip_infos_ausgeben()
	{
	echo " "
	echo " "                                        
	if [ -f "$Dateiname" ];then
	        echo "Benutze die Passwortdatei:  $Dateiname"
	else
		echo "Dateiname war nicht zu ermitteln oder ist falsch." 
		echo "Bitte geben sie folgende Datei: $Dateiname ein"
 		exit
	fi
}



function default_key_woerter()
	{
	## nachsehen ob eine Datenbank für den User steht
	## Wenn keine Datenbank im Array steht tragen wir die default Datenbanken ein
	## Default einstellungen

	# echo "eingestellte default-Variable: $DBx"
	# echo "Jezt testen wir das ganze auf dem default Vermerk"
	# echo "Variable v_SQL_DB vom User:  ${v_SQL_DB[$POS]} " 
	v_DB=""
	for DB_default in ${v_SQL_DB[$POS]}
	  do
		#echo " Variable die in die IF Anweisung reingeht:  $DB_default"
	    ### default 
	    if [ $DB_default = 'default' ]
		  then
    		     v_User="kp_${v_USER[$POS]}"
	    	     v_DB="$v_DB $DBx" # $v_User"
		     # echo "1 default: $v_User"
	     elif [ $DB_default = 'dbUserName' ]  # ob der Datenbankname für den User angelegt werden soll
		  then
		     v_User="kp_${v_USER[$POS]}"
	             v_DB="$v_DB $v_User"
		     #	echo "2 User Datenbank"
		  else
		     v_DB="$v_DB $DB_default"
		     # echo "3 eingetragene Datenbanken"
	     fi
	done
}


function echo5()
	{
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
}

## Für die Ausgabe der Querrys
function ausgabe_der_grantanweisungen()
	{
	echo "################ GRANT Anweisung #######################"
	for DB in $v_DB
		do
		for SERVER in ${v_HOSTS[$POS]}
			do
			echo "Host:  "$SERVER
			if [[ "$DB" =~ "." ]]
			then
			  echo "Tabelle gefunden"
			  echo "GRANT $PERM ON $DB TO '${v_USER[$POS]}'@'$SERVER' IDENTIFIED BY '${v_PWD[$POS]}'" 
			  echo "GRANT $PERM ON $DB TO '${v_USER[$POS]}'@'$SERVER' IDENTIFIED BY '${v_PWD[$POS]}'" | ${v_CONNECT}
			 else
			  echo "Tabellenangabe nicht gefunden"
			  echo "GRANT $PERM ON $DB.* TO '${v_USER[$POS]}'@'$SERVER' IDENTIFIED BY '${v_PWD[$POS]}'"
			  echo "GRANT $PERM ON $DB.* TO '${v_USER[$POS]}'@'$SERVER' IDENTIFIED BY '${v_PWD[$POS]}'" | ${v_CONNECT} 
			fi
		done
	done
}


### Prüfen ob das Datum noch gültig ist
function datum_checken()
	{
	#echo "Datum Datenbank: $v_Datum     und das aktuelle Datum:  $v_aktDatum"
	if [ $v_Datum -ge $v_aktDatum  ]
	#if [ $v_aktDatum -ge $v_Datum  ]
	  then
		echo " -->> Datum gültig"
		## Rechte auslesen
		PERM="v_PERM_"${v_PERM[$POS]}
		eval PERM=\${$PERM}
		# alle Hosts eintragen
		echo "Welche Hosts sollen eingetragen werden:  ${v_HOSTS[$POS]}"
		default_key_woerter
		ausgabe_der_grantanweisungen	
		sleep 0.5
	else
		echo " -->> Datum abgelaufen" 
	fi
}


#####################################
## Variablen prüfen
## Datum checken
## Wieder reinschreiben aller Rechte

function variablen_checken()
	{
	echo ""
	echo "Positions (max):" $v_POS
	for POS in $v_POS
		do
		echo ""
		echo ""
		echo "###############################"
		echo "aktuelle Position: "$POS
		zeichenkette=${v_GKD[$POS]}
		v_Datum="${zeichenkette:6:4}-${zeichenkette:3:2}-${zeichenkette:0:2}"
		echo  -n "Teste folgendes Datum auf Gültigkeit: $zeichenkette" 
	  ##	echo "Habe es umgewandelt:  $v_Datum"
		v_Datum=$(date -d $v_Datum +%s)
	  ##	echo "in Unixtime umgewandelt:  $v_Datum"
		v_aktDatum=$(date +%s)
	  ##	echo "$v_Datum muss groesser sein als $v_aktDatum"
		datum_checken
	done
}


function ende()
	{
	echo "FLUSH PRIVILEGES;"  | ${v_CONNECT}
	echo5
	exit
}

function user_loeschen()
	{
	echo "Lösche alle Usserrechte"
	sleep 2
	  va_User=$(echo "select user from mysql.user where NOT (${v_SQL_NOT_DEL_USER})" | /usr/bin/mysql -pkp)
	  for user in $va_User
	  do
	  va_host=$(echo "select host from mysql.user where user='$user'" | /usr/bin/$v_CONNECT )
	  for Host in $va_host
		do	
		if  [[ "$Host" != "host" ]]
		  then
		  echo "'$user'@'$Host'"
 		  echo "DROP USER '$user'@'$Host'" | /usr/bin/$v_CONNECT
		fi
	  done
	done
	echo5
}


function point()
	{
	echo "Point  --> $1 <--"
}


##################
###### main ######
direktory_einlesen
ip_herausfinden                                                                
datei_ip_infos_ausgeben                                                        
. $Dateiname    
db_connect_string
user_loeschen 

##################
#direktory_einlesen
#ip_herausfinden

#datei_ip_infos_ausgeben
#. $Dateiname
#echo5

variablen_checken   # ruft datum_checken, default_key_woerter & ausgabe_der_grantanweisungen auf
ende

	
