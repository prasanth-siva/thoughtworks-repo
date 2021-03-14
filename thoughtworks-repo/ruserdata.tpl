#!/bin/bash
/bin/echo "userdata executed" >> /tmp/testfile.txt
sudo hostnamectl set-hostname ${hostname}
yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker