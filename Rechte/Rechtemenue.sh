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

### gauge demo ###
gauge() {
    { for I in $(seq 1 100) ; do
        echo $I
        sleep 0.01
      done
    echo 100; } | dialog --backtitle "Dialog - Progress sample" \
                         --gauge "Progress" 6 60 0
}

### Array einlesen ###
array_einlesen() {
       . /opt/scripte/Rechte/pwd_2.201.txt
}

### Füllt die Radioliste ###
listenfueller() {
        array_einlesen
        echo "Positions (max):" $v_POS
        for POS in $v_POS
          do
          v_radio="${v_USER[$POS]}"
#          $POS "$v_radio" off\ 
#          echo "$POS \"$v_radio\" off\ " 
        done
}


#listenfueller1() {
#        01 "erstes Feld" on \
#        02 "zweites Feld" off \
#}


 
### File or Directory selection menu with dialog
file_menu() {
    fileroot=$HOME
    IFS_BAK=$IFS
    IFS=$'\n' # wegen Filenamen mit Blanks
    array=( $(ls $fileroot) )
    n=0
    for item in ${array[@]}
    do
        menuitems="$menuitems $n ${item// /_}" # subst. Blanks with "_"  
        let n+=1
    done
    IFS=$IFS_BAK
    dialog --backtitle "Dialog - Sample menu with variable items" \
           --title "Select a file" --menu \
           "Choose one of the menu points" 16 40 8 $menuitems 2> $_temp
    if [ $? -eq 0 ]; then
        item=`cat $_temp`
        selection=${array[$(cat $_temp)]}
        dialog --msgbox "You choose:\nNo. $item --> $selection" 6 42
    fi
}

### File Select sample 
file_select() {
    dialog --backtitle "Dialog - fselect sample"\
           --begin 3 10 --title " use [blank] key to select "\
           --fselect "$HOME/" 10 60 2>$_temp

    result=`cat $_temp`
    dialog --msgbox "\nYou selected:\n$result" 9 52
}

### create Today's calendar ###
calendar() {
    today=date +"%d %m %Y"
    echo "heute=$today"
    dialog --backtitle "Dialog - Calendar sample" \
           --calendar "choose a date" 2 1 $today 2>$_temp
    datum=`cat $_temp`
    dialog --title " Date selected " --msgbox "\nYour date: $datum" 6 30
}    

### Check List - multi select sample ###
checklist() {
    dialog --backtitle "Dialog - CheckList (multi select) sample" \
           --checklist "tag item(s) to choose" 15 50 8 \
           01 "first item to select" off\
           02 "second item - on by default" on\
           03 "third item" off\
           04 "more items ..." off 2>$_temp
    result=`cat $_temp`
    dialog --title " Item(s) selected " --msgbox "\nYou choose item(s): $result" 6 44
}    

### Radio List - single select sample ###
radiolist() {
    dialog --backtitle "Dialog - RadioList (single select) sample" \
           --radiolist "tag item to choose" 15 50 8 \
           01 "first item to select" off\
           02 "second item - on by default" on\
           03 "third item" off\
           04 "more items ..." off 2>$_temp
    result=`cat $_temp`
    dialog --title " Item(s) selected " --msgbox "\nYou choose item: $result" 6 44
}    

### Input Box sample 
inputbox() {
    dialog --backtitle "Dialog - InputBox sample"\
           --inputbox "Enter a line, please" 8 52 2>$_temp

    result=`cat $_temp`
    dialog --msgbox "\nYou entered:\n$result" 9 52
}

### Message Box sample - show versions 
version() {
    dialog --backtitle "Dialog - MessageBox sample" \
           --msgbox "$PN - Version $VER\na Linux dialog Tutorial\n\nusing:\n$DVER" 9 52
}

### Text Box sample - show file test.txt
textbox() {
    filename="test.txt"
    if [ -e $filename ]; then
        dialog --backtitle "Dialog - TextBox sample - use [up] [down] to scroll"\
               --begin 3 5 --title " viewing File: $filename "\
               --textbox $filename 20 70
    else
        dialog --msgbox "*** ERROR ***\n$filename does not exist" 6 42
    fi
}


### Form für die Rechtegruppen ###
formbox () {
        array_einlesen
        echo "Positions (max):" $v_POS
        for POS in $v_POS
          do
            dialog --backtitle "Dialog - Form sample" \
            --form " Form Test - use [up] [down] to select input field " 21 70 18 \
            "Username"           2 4 "${v_USER[$POS]}"    3 9 55 0\
            "Passwort"           4 4 "${v_PWD[$POS]}"     5 9 55 0\
            "Gültig bis"         6 4 "${v_GKD[$POS]}"     7 9 55 0\
            "Rechtegruppe"       8 4 "${v_PERM[$POS]}"    9 9 55 0\
            "Hosts"             10 4 "${v_HOSTS[$POS]}"  11 9 55 0\
            "Datenbanken"       12 4 "${v_SQL_DB[$POS]}" 13 9 55 0\
            2>$_temp
        
            if [ ${?} -ne 0 ]; then return; fi
          result=`cat $_temp`
          echo "Result=$result"
          dialog --title "Items are separated by \\n" --cr-wrap \
          --msgbox "\nYou entered:\n$result" 12 52
        done
}



### Text Box sample - show file test.txt
tailbox() {
    dialog --backtitle "Dialog - TailBox sample"\
           --begin 3 5 --title " viewing File: /var/log/messages "\
           --tailbox /var/log/messages 18 70
}

### create main menu using dialog
main_menu() {
    dialog --backtitle "Dialog - Linux Shell Tutorial" --title " Main Menu - V. $VER "\
        --cancel-label "Quit" \
        --menu "Move using [UP] [DOWN], [Enter] to select" 19 60 12\
        Form "Show a form"\
        Home_Menu "Show files in \$HOME for selection"\
        Radio "Single select list"\
        Quit "Exit demo program" 2>$_temp
        
    opt=${?}
    if [ $opt != 0 ]; then rm $_temp; exit; fi
    menuitem=`cat $_temp`
    echo "menu=$menuitem"
    case $menuitem in
        Home_Menu) file_menu;;
        Radio) radiolist;;
        Form) formbox;;
        Quit) rm $_temp; exit;;
    esac
}

while true; do
  main_menu
done
