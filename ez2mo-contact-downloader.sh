#!/bin/bash

read -p "Username: " USER
read -s -p "Password: " PASS

COOKIE_FILE=ez2mo_cookie
RAW_FILE=contacts_raw
CONTACT_FILE=contacts

if [ -f $CONTACT_FILE ]; then
  rm $CONTACT_FILE
fi
if [ -f $RAW_FILE ]; then
  rm $RAW_FILE
fi

TOTAL_PAGES=$(curl -s -c $COOKIE_FILE -d "login=${USER}" -d "password=${PASS}" http://ez2mo.com/aiocontacts/view/showcontacts.php |  sed -n 's/.*\">\([0-9]\)<\/a>.*/\1/gp')

if [ -z "$TOTAL_PAGES" ];then
  echo "\nInvalid User/Pass"
  exit
else
  echo "\nLogged!\nDownloading contacts..."
  for i in `seq 0 $TOTAL_PAGES`;
  do
    URL='http://ez2mo.com/aiocontacts/view/showcontacts.php?page='$i
    curl -s -b $COOKIE_FILE $URL >> $RAW_FILE
  done
  echo "Processing results..."

  NUMBERS_ARRAY=$(cat $RAW_FILE | sed -n -e '/&nbsp;/!s/<td.*>\(.*\)<\/td>/\1/gp' | sed 's/\([[:digit:]]\)$/\1/g')

  echo $NUMBERS_ARRAY >> $CONTACT_FILE
  rm $RAW_FILE
fi
rm $COOKIE_FILE
echo done!
