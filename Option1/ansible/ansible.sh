#! /bin/bash
sudo apt update
sudo apt install ansible -y
sudo systemctl start ansible
sudo systemctl enable ansible
cd ~/.ssh
echo -e "\n\n\n" | ssh-keygen -t rsa
eval `ssh-agent`
ssh-add ~/.ssh/id_rsa