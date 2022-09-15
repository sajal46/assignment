#! /bin/bash
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install python3.8 -y
sudo pip3 install boto3 
sudo apt install ansible -y
sudo systemctl start ansible
sudo systemctl enable ansible
cd ~/.ssh
echo -e "\n\n\n" | ssh-keygen -t rsa
eval `ssh-agent`
ssh-add ~/.ssh/id_rsa   