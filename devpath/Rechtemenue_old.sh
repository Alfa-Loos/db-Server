#!/bin/bash

#######################################################################
# Title      :    test_dialog
# Author     :    Bernd Holzhauer {bholz@cc-c.de}
# Date       :    2007-11-02
# Requires   :    dialog
# Category   :    Shell menu tools
#######################################################################
# Description
#   DIALOG test & demo
#   Sample Script without functionality - just to test and demonstrate
#   the usage of the dialog features
# Note:
#   - it draws a small main menu to try different dialog options
#######################################################################

_temp="/tmp/answer.$$"
PN=`basename "$0"`
VER='0.31'
dialog 2>$_temp
DVER=`cat $_temp | head -1`


### Array einlesen ###
array_einlesen() {
	. /opt/scripte/Rechte/pwd_2.201.txt
}

### Füllt die Radioliste ###
listenfueller() {
        array_einlesen
#        echo "Positions (max):" $v_POS
	for POS in $v_POS
          do
          v_radio="${v_USER[$POS]}"                                   
          $POS "$v_radio" off\ 
	  echo "$(POS) \"$(v_radio)\" off\ " 
        done
}



### Radio List - single select sample ###
_radiolist() {
    dialog --backtitle "Dialog - RadioList (single select) sample" \
           --radiolist "tag item to choose" 15 50 8 \
           01 "first item to select" off\
           02 "second item - on by default" on\
           03 "third item" off\
           04 "more items ..." off 2>$_temp
    result=`cat $_temp`
    dialog --title " Item(s) selected " --msgbox "\nYou choose item: $result" 6 44
}    


radiolist() {
    dialog --backtitle "Dialog - RadioList (single select) sample" \
           --radiolist "tag item to choose" 15 50 8 \
           04 "more items ..." off 2>$_temp
    result=`cat $_temp`
    dialog --title " Item(s) selected " --msgbox "\nYou choose item: $result" 6 44
}    


                                                                   


### Form für die Rechtegruppen ###
formbox() {
	array_einlesen
	echo "Positions (max):" $v_POS
	for POS in $v_POS
	  do
	    dialog --backtitle "Dialog - Form sample" \
	    --form " Form Test - use [up] [down] to select input field " 21 70 18 \
	    "Username" 		 2 4 "${v_USER[$POS]}" 	  3 9 55 0\
	    "Passwort" 		 4 4 "${v_PWD[$POS]}" 	  5 9 55 0\
	    "Gültig bis" 	 6 4 "${v_GKD[$POS]}" 	  7 9 55 0\
	    "Rechtegruppe" 	 8 4 "${v_PERM[$POS]}" 	  9 9 55 0\
	    "Hosts" 		10 4 "${v_HOSTS[$POS]}"  11 9 55 0\
	    "Datenbanken" 	12 4 "${v_SQL_DB[$POS]}" 13 9 55 0\
	    2>$_temp
	
	    if [ ${?} -ne 0 ]; then return; fi   
    	  result=`cat $_temp`
	  echo "Result=$result"
	  dialog --title "Items are separated by \\n" --cr-wrap \
	  --msgbox "\nYou entered:\n$result" 12 52
	done
}

### create main menu using dialog
main_menu() {
    dialog --backtitle "Dialog - Linux Shell Tutorial" --title " Main Menu - V. $VER "\
        --cancel-label "Quit" \
        --menu "Move using [UP] [DOWN], [Enter] to select" 17 60 10\
        Form "Show a form"\
	Radiolist "Teste Radiolist"\
        Home_Menu "Show files in \$HOME for selection"\
        Quit "Exit demo program" 2>$_temp

	opt=${?}
    if [ $opt != 0 ]; then rm $_temp; exit; fi
	    menuitem=`cat $_temp`
	    echo "menu=$menuitem"
	    case $menuitem in
	        Home_Menu)	file_menu;;
	        Form)		formbox;;
	        Radiolist)	radiolist;;
	        Quit)		rm $_temp; exit;;
	    esac
}

while true; do
  main_menu
done



}
exit
