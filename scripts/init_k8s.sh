#!/bin/bash

KUBE_VERSION="1.33.1-1.1"

# Deploy keys to allow all nodes to connect each others as vagrant
mv /tmp/id_rsa*  /home/vagrant/.ssh/

chmod 400 /home/vagrant/.ssh/id_rsa*
chown vagrant:  /home/vagrant/.ssh/id_rsa*

cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
chmod 400 /home/vagrant/.ssh/authorized_keys
chown vagrant: /home/vagrant/.ssh/authorized_keys

# Install docker
sudo apt-get update
sudo apt-get install -y docker.io

# Start docker
sudo systemctl start docker
sudo systemctl enable docker

# Disable swap
usermod -aG docker vagrant
swapoff -a

# Install dependy packages
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Add repository (https://kubernetes.io/blog/2023/08/15/pkgs-k8s-io-introduction/)
sudo mkdir /etc/apt/keyrings
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Install k8s
sudo apt-get update 
sudo apt-get install -y kubelet kubeadm kubectl

sudo systemctl enable kubelet
sudo systemctl start kubelet