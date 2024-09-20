#!/bin/bash

source ./common1.sh

check_root

echo "Please enter DB password:"
read mysql_root_password

dnf module disable nodejs -y &>>$LOGFILE
#VALIDATE $? "Disabling default nodejs"

dnf module enables nodejs:20 -y &>>$LOGFILE
#VALIDATE $? "Enabling nodejs"

dnf install nodejs -y &>>$LOGFILE
#VALIDATE $? "Installing nodejs"

id expense &>>$LOGFILE
if [ $? -ne 0 ]
then
    useradd expense &>>$LOGFILE
    #VALIDATE $? "Creating expense user"
else
    echo -e "Expense user already created...$Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGFILE
#VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
#VALIDATE $? "Downloading backend code"

sudo useradd expense

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOGFILE
#VALIDATE $? "Extracted backend code"

npm install &>>$LOGFILE
#VALIDATE $? "Installing nodejs dependencies"

#check your repo and path
cp /home/ec2-user/expense-shells-1/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
#VALIDATE $? "Copied backend.service"

systemctl daemon-reload &>>$LOGFILE
#VALIDATE $? "Daemon Reload"

systemctl start backend &>>$LOGFILE
#VALIDATE $? "Starting backend"

systemctl enable backend &>>$LOGFILE
#VALIDATE $? "Enabling backend"

dnf install mysql -y &>>$LOGFILE
#VALIDATE $? "Installing MySQL Client"

mysql -h db.neelareddy.store -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
#VALIDATE $? "Schema loading"

systemctl restart backend &>>$LOGFILE
#VALIDATE $? "Restarting backend"