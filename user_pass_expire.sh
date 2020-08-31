#!/bin/bash

# Variables
AD_USER='ad_user'                 # Username for connecting to AD
AD_USER_PASS='pass_for_ad_user'   # Password from ad_user
DC_ADDRESS='192.168.0.1'          # IP address or DNS name of the domain controller
SLD='example'                     # Second level of AD domain name, for example domain example.com
TLD='com'                         # First level of AD domain name, for example domain example.com

# Get a list of users with expiring passwords
USERS_LIST=$(ldapsearch -h $DC_ADDRESS -D "$AD_USER@$SLD" -x -w "$AD_USER_PASS" -b "DC=$SLD,DC=$TLD" -s sub "(&(userAccountControl=512))" | grep -e sAMAccountName | cut -d " " -f 2)

# Get password lifetime from AD group policies
MAX_PWD_AGE=$(ldapsearch -s base -h $DC_ADDRESS -D "$AD_USER@$SLD" -x -w "$AD_USER_PASS" -b "DC=$SLD,DC=$TLD" maxPwdAge | grep maxPwdAge: | cut -d "-" -f 2)

for USER in $USERS_LIST
do
# Get the time of the last change of the user's password
PWD_LAST_SET=$(ldapsearch -h $DC_ADDRESS -D "$AD_USER@$SLD" -x -w "$AD_USER_PASS" -b "DC=$SLD,DC=$TLD" -s sub "(&(objectCategory=person)(objectClass=user)(sAMAccountName=$USER))" | grep -e pwdLastSet | cut -d " " -f 2)

# Calculate the number of days until a user's password expires
TIME_TO_EXPIRATION=$(bc <<< "(($PWD_LAST_SET+$MAX_PWD_AGE)/10000000-11644473600-$(date +%s))/3600/24")

# Get user e-mail
MAIL=$(ldapsearch -h $DC_ADDRESS -D "$AD_USER@$SLD" -x -w "$AD_USER_PASS" -b "DC=$SLD,DC=$TLD" -s sub "(&(objectCategory=person)(objectClass=user)(sAMAccountName=$USER))" | grep mail | cut -d " " -f 2)

# If the number of days before the password expires is less than or equal to 0, then send an email that the password has expired
if [ "$TIME_TO_EXPIRATION" -le "0" ]
then
    echo "The password for user $USER has expired! Contact your system administrator to restore access." | mutt -F /root/.muttrc_pass_exp -s "Password expired!!!" $MAIL

# If the number of days before the password expires is less than or equal to 15, then send a letter about the imminent password expiration
elif [ "$TIME_TO_EXPIRATION" -le "15" ]
then
    echo "The password for user $USER will expire in $TIME_TO_EXPIRATION days\days! Emails will stop arriving when the password is changed." | mutt -F /root/.muttrc_pass_exp -s "You need to change your password!" $MAIL
fi
done
