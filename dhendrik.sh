#! /bin/bash
#
######################################################
#	Ziel ist es, diese Abfragen täglich für den vorherigen Werktag auszuführen und bereit zu stellen.
#
#	Die Daten können im Idealfall als csv ausgegeben werden, 
#	das Abfragedatum = Dateiname + Name der Abfrage (national,international, international rob); 
#	die Dateien können via mail verschickt werden; 
#	besser wäre sogar ein Ordner im googleDrive. 
#
#	Eine Ablage in lokalen Netzlaufwerken ist nicht erwünscht.
#
#	Die Extentions in Zeile 3 = IDs der Mitarbeiter aus dem InsideSales. 
#	Diese sind variabel, monatlich finden hier Wechsel statt; diese müsste ich selbstständig editieren (hinzufügen/löschen) können.
#
#	Liebe Grüße,
#	Hendrik
######################################################

### Variablen fuer die Functionsaufrufe
	# TELEFONIE-ABFRAGE-international
#	extensions_01="'4001,4003,4004,4006'"
	extensions_01="'4001,4003,4004,4006,4008,4009'"   # 27.06.16 eingetragen

	# TELEFONIE-ABFRAGE-international_ROB
	extensions_02="'4002,4090,4091,4092,4093'"


	# TELEFONIE-ABFRAGE-national
	#extensions_03="'3131,3130,3118,3114,3112,3107,3105,3110,3115,3104,3102,3103,3133,3137,3109,3134,3106,3122,3120,3121,3132,3116,3135,3117'"
	#extensions_03="'3102,3103,3104,3105,3106,3107,3109,3110,3112,3113,3114,3115,3116,3117,3118,3119,3120,3121,3122,3130,3131,3132,3133,3134,3135,3136,3137,3138'"
	#extensions_03="'3102,3103,3104,3105,3106,3107,3109,3110,3111,3112,3113,3114,3115,3116,3117,3118,3119,3120,3121,3122,3127,3130,3131,3132,3133,3134,3135,3136,3137,3138'"
	extensions_03="'3102,3103,3104,3105,3106,3107,3109,3110,3112,3113,3114,3115,3116,3117,3118,3119,3120,3121,3122,3127,3128,3129,3130,3131,3132,3133,3134,3135,3136,3137,3138'"

### Globale Variablen
##
## Mailadressen an denen das Ergebnis versand wird.
v_mailadressen="Andreas.Loos@kaeuferportal.de Hendrik.Daehnert@kaeuferportal.de"
## Testmail
#v_mailadressen="Andreas.Loos@kaeuferportal.de"

## Mail Server Zugangsdaten
mail_pwd='devcatchall2'

## GMAIL
#mail_absender='report-a@kaeuferportal.de'
#mail_server='smtp.gmail.com:587'
#mail_user='mimimu@kaeuferportal.de'

## Alfas Ersatzkonto
mail_absender='minimu@h4d.de'
mail_server='mail.w2d.de'
mail_user='kaeuferportal@h4d.de'


### Wähle einen Server aus auf dem eine kp2_production drauf ist.
##
# Für den 27 Server
#v_server="192.168.2.27 -P 3306"
#v_passwd="kp"
#v_dbuser="root"

# Für den 26 Server
v_server="192.168.2.26 -P 3307"
v_passwd="KP_alfa"
v_dbuser="alfa"


v_path="/data/backup"
v_database="kp2_production"
v_date_von="'"`date -d "-1 day" +%Y-%m-%d`" 00:00:00'"
v_date_bis="'"`date +%Y-%m-%d`" 00:00:00'"
v_date=`date -d "yesterday" +%Y-%m-%d`


## Testdatum und Wartungsdatum
#v_date_von="'2016-09-21 00:00:00'"
#v_date_bis="'2016-09-22 00:00:00'"


sql_conectstring="mysql -h $v_server -u $v_dbuser -p$v_passwd $v_database"

### Varaiblendefinition Ende #############################################


function abfrage_01()
	{
	# --- START TELESALES-TELEFONIE-ABFRAGE-international --- #
	echo "	SET @von = $v_date_von;
		SET @bis = $v_date_bis;
		SET @extensions = $1;
	
SELECT * FROM (
select DATE_FORMAT(calldate, '%Y%m%d') as datum, src, count(*) as Anwahlen_Outbound, sum(IF(disposition='ANSWERED',1,0)) as Gespraeche_Outbound,
sum(duration) as Duration_Outbound, sum(billsec) as Billsec_Outbound
from cdr where (calldate BETWEEN @von AND @bis) AND
find_in_set(src, @extensions) AND length(dst) > 4
group by DATE_FORMAT(calldate, '%Y%m%d'), src
) outbound
LEFT JOIN (
select DATE_FORMAT(calldate, '%Y%m%d') as datum, MID(dstchannel,LOCATE('/',dstchannel)+1,4) as dstnew, count(*) as Anwahlen_Inbound, sum(IF(disposition='ANSWERED',1,0)) as Gespraeche_Inbound,
sum(duration) as Duration_Inbound, sum(billsec) as Billsec_Inbound
from cdr where (calldate BETWEEN @von AND @bis) AND
find_in_set(MID(dstchannel,LOCATE('/',dstchannel)+1,4)  , @extensions)
group by DATE_FORMAT(calldate, '%Y%m%d'), MID(dstchannel,LOCATE('/',dstchannel)+1,4)
) inbound
ON (outbound.datum = inbound.datum AND outbound.src = inbound.dstnew)

UNION

SELECT * FROM (
select DATE_FORMAT(calldate, '%Y%m%d') as datum, src, count(*) as Anwahlen_Outbound, sum(IF(disposition='ANSWERED',1,0)) as Gespraeche_Outbound,
sum(duration) as Duration_Outbound, sum(billsec) as Billsec_Outbound
from cdr where (calldate BETWEEN @von AND @bis) AND
find_in_set(src, @extensions) AND length(dst) > 4
group by DATE_FORMAT(calldate, '%Y%m%d'), src
) outbound
RIGHT JOIN (
select DATE_FORMAT(calldate, '%Y%m%d') as datum, MID(dstchannel,LOCATE('/',dstchannel)+1,4) as dstnew, count(*) as Anwahlen_Inbound, sum(IF(disposition='ANSWERED',1,0)) as Gespraeche_Inbound,
sum(duration) as Duration_Inbound, sum(billsec) as Billsec_Inbound
from cdr where (calldate BETWEEN @von AND @bis) AND
find_in_set(MID(dstchannel,LOCATE('/',dstchannel)+1,4)  , @extensions)
group by DATE_FORMAT(calldate, '%Y%m%d'), MID(dstchannel,LOCATE('/',dstchannel)+1,4)   
) inbound
ON (outbound.datum = inbound.datum AND outbound.src = inbound.dstnew)" | $sql_conectstring
	# --- ENDE TELESALES-TELEFONIE-ABFRAGE --- #
}

function abfrage_02()
	{

# --- START TELESALES-TELEFONIE-ABFRAGE-international_ROB --- #
	echo "	SET @von = $v_date_von;
		SET @bis = $v_date_bis;
		SET @extensions = $1;

SELECT * FROM (
select DATE_FORMAT(calldate, '%Y%m%d') as datum, src, count(*) as Anwahlen_Outbound, sum(IF(disposition='ANSWERED',1,0)) as Gespraeche_Outbound,
sum(duration) as Duration_Outbound, sum(billsec) as Billsec_Outbound
from cdr where (calldate BETWEEN @von AND @bis) AND
find_in_set(src, @extensions) AND length(dst) > 4
group by DATE_FORMAT(calldate, '%Y%m%d')
) outbound
LEFT JOIN (
select DATE_FORMAT(calldate, '%Y%m%d') as datum, MID(dstchannel,LOCATE('/',dstchannel)+1,4) as dstnew, count(*) as Anwahlen_Inbound, sum(IF(disposition='ANSWERED',1,0)) as Gespraeche_Inbound,
sum(duration) as Duration_Inbound, sum(billsec) as Billsec_Inbound
from cdr where (calldate BETWEEN @von AND @bis) AND
find_in_set(MID(dstchannel,LOCATE('/',dstchannel)+1,4)  , @extensions)
group by DATE_FORMAT(calldate, '%Y%m%d'), MID(dstchannel,LOCATE('/',dstchannel)+1,4)
) inbound
ON (outbound.datum = inbound.datum AND outbound.src = inbound.dstnew)

UNION

SELECT * FROM (
select DATE_FORMAT(calldate, '%Y%m%d') as datum, src, count(*) as Anwahlen_Outbound, sum(IF(disposition='ANSWERED',1,0)) as Gespraeche_Outbound,
sum(duration) as Duration_Outbound, sum(billsec) as Billsec_Outbound
from cdr where (calldate BETWEEN @von AND @bis) AND
find_in_set(src, @extensions) AND length(dst) > 4
group by DATE_FORMAT(calldate, '%Y%m%d')
) outbound
RIGHT JOIN (
select DATE_FORMAT(calldate, '%Y%m%d') as datum, MID(dstchannel,LOCATE('/',dstchannel)+1,4) as dstnew, count(*) as Anwahlen_Inbound, sum(IF(disposition='ANSWERED',1,0)) as Gespraeche_Inbound,
sum(duration) as Duration_Inbound, sum(billsec) as Billsec_Inbound
from cdr where (calldate BETWEEN @von AND @bis) AND
find_in_set(MID(dstchannel,LOCATE('/',dstchannel)+1,4)  , @extensions)
group by DATE_FORMAT(calldate, '%Y%m%d'), MID(dstchannel,LOCATE('/',dstchannel)+1,4)   
) inbound
ON (outbound.datum = inbound.datum AND outbound.src = inbound.dstnew)" | $sql_conectstring
# --- ENDE TELESALES-TELEFONIE-ABFRAGE --- #
}


function abfrage_03()
        {
        
        # --- START TELESALES-TELEFONIE-ABFRAGE-national --- #
                echo "  SET @von = $v_date_von;
			SET @bis = $v_date_bis;
			SET @extensions = $1;

SELECT * FROM (
select DATE_FORMAT(calldate, '%Y%m%d') as datum, src As 'Nummer', count(*) as Anwahlen_Outbound, sum(IF(disposition='ANSWERED',1,0)) as Gespraeche_Outbound, SUM(duration) As 'Duration_Outbound', SUM(billsec) As 'Billsec_Outbound'
from cdr 
where calldate between @von AND @bis 
AND find_in_set(src, @extensions)
AND LENGTH(dst) > 4
GROUP BY src
) outbound
LEFT JOIN (
select DATE_FORMAT(calldate, '%Y%m%d') as datum, MID(dstchannel,LOCATE('/',dstchannel)+1,4) As 'Nummer', Count(duration) As 'Gespraeche_Inbound', SUM(duration) As 'Duration_Inbound', SUM(billsec) As 'Billsec_Inbound'
from cdr 
where calldate between @von AND @bis 
AND ((dst IN (200, 210) AND find_in_set(MID(dstchannel,LOCATE('/',dstchannel)+1,4), @extensions )) OR (find_in_set(dst, @extensions) AND dcontext != 'from-queue-exten-only' ))
AND disposition = 'Answered'
group by MID(dstchannel,LOCATE('/',dstchannel)+1,4)  , @extensions)
inbound
ON (outbound.datum = inbound.datum AND outbound.Nummer = inbound.Nummer)

UNION

SELECT * FROM (
select DATE_FORMAT(calldate, '%Y%m%d') as datum, src As 'Nummer', count(*) as Anwahlen_Outbound, sum(IF(disposition='ANSWERED',1,0)) as Gespraeche_Outbound, SUM(duration) As 'Duration_Outbound', SUM(billsec) As 'Billsec_Outbound'
from cdr 
where calldate between @von AND @bis 
AND find_in_set(src, @extensions)
AND LENGTH(dst) > 4
GROUP BY src
) outbound
RIGHT JOIN (
select DATE_FORMAT(calldate, '%Y%m%d') as datum, MID(dstchannel,LOCATE('/',dstchannel)+1,4) As 'Nummer', Count(duration) As 'Gespraeche_Inbound', SUM(duration) As 'Duration_Inbound', SUM(billsec) As 'Billsec_Inbound'
from cdr 
where calldate between @von AND @bis 
AND ((dst IN (200, 210) AND find_in_set(MID(dstchannel,LOCATE('/',dstchannel)+1,4), @extensions )) OR (find_in_set(dst, @extensions) AND dcontext != 'from-queue-exten-only' ))
AND disposition = 'Answered'
group by MID(dstchannel,LOCATE('/',dstchannel)+1,4)  , @extensions)
inbound
ON (outbound.datum = inbound.datum AND outbound.Nummer = inbound.Nummer)"  | $sql_conectstring
# --- ENDE TELESALES-TELEFONIE-ABFRAGE --- #
}


function mailversand()
        {
	## Zusammenkopieren der Abfrageergebnisse.
	cat /tmp/Abfrage_01.txt > /tmp/$v_date.txt
	cat /tmp/Abfrage_02.txt >> /tmp/$v_date.txt
	cat /tmp/Abfrage_03.txt >> /tmp/$v_date.txt

	for mail in $v_mailadressen
	  do
		sendEmail -f $mail_absender -t $mail -u Telefonreport -m Report ist vom $v_date -s $mail_server -xu $mail_user -xp $mail_pwd -o tls=no -a "/tmp/$v_date.txt"
	done	  
	##sendEmail -f report-a@kaeuferportal.de -t Andreas.Loos@kaeuferportal.de -u Test -m Telefonreporting.  -s smtp.gmail.com:587 -xu mimimu@kaeuferportal.de -xp devcatchall2 -o tls=yes -a "/tmp/$v_date.txt"
	##sendEmail -f report-a@kaeuferportal.de -t Hendrik.Daehnert@kaeuferportal.de -u Test -m Telefonreporting.  -s smtp.gmail.com:587 -xu mimimu@kaeuferportal.de -xp devcatchall2 -o tls=yes -a "/tmp/$v_date.txt"
}

### Main ###
	echo "Die Abfrage beginnt mit dem Datum: $v_date_von"  > /tmp/Abfrage_01.txt
	echo "und geht bis zum: $v_date_bis"  >> /tmp/Abfrage_01.txt

	echo ""  >> /tmp/Abfrage_01.txt
	echo "Telefoniereporting international" >> /tmp/Abfrage_01.txt
	abfrage_01 $extensions_01 >> /tmp/Abfrage_01.txt

	echo "" > /tmp/Abfrage_02.txt
	echo "Telefoniereporting international Rob" >> /tmp/Abfrage_02.txt
	abfrage_02 $extensions_02 >> /tmp/Abfrage_02.txt

	echo "" > /tmp/Abfrage_03.txt
	echo "Telefoniereporting national" >> /tmp/Abfrage_03.txt
	abfrage_03 $extensions_03 >> /tmp/Abfrage_03.txt

	mailversand
## Test
#        cat /tmp/Abfrage_01.txt
#        cat /tmp/Abfrage_02.txt
#        cat /tmp/Abfrage_03.txt
                        
exit

