#!/bin/bash

source ./common1.sh

check_root

echo "Please enter DB password:"
read mysql_root_password

dnf install mysql-server installing some where -y &>>$LOGFILE
#VALIDATE $? "Installing MySQL server"

systemctl enable mysqld &>>$LOGFILE
#VALIDATE $? "Enabling MySQL"

systemctl start mysqld &>>$LOGFILE
#VALIDATE $? "Starting MySQL"

# mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
# VALIDATE $? "Setting the root password"

mysql -h db.neelareddy.store -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
    #VALIDATE $? "Setting the root password"
else
    echo -e "MySQL root password is already setup...$Y SKIPPING $N"
fi