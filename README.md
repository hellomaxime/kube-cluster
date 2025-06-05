
Ce dépôt contient les scripts vagrant permettant de provisionner 4 VMs pour y déployer un bastion et un cluster Kubernetes avec 1 master et 2 workers

## Versions

Vagrant : 2.4.6  
VirtualBox : 7.1.10  
Ubuntu : 20.04  
Kubernetes : 1.33.1-1.1

## Prérequis

Installer vagrant (doc officielle vagrant)

```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg  

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list  

sudo apt update && sudo apt install vagrant
```

Installer VirtualBox (récupérer la dernière version)

```bash
sudo apt update
sudo apt install virtualbox
```

Création de la paire de clé ssh

```bash
mkdir .ssh
ssh-keygen -t rsa -b 4096 -f .ssh/id_rsa -q -N ""
```

## Déploiement

```bash
# lancer les VMs
vagrant up

# arrêter les VMs (éteindre)
vagrant halt

# détruire les VMs
vagrant destroy
```

## Accès au cluster
via la vm control-plane1 (avec rebond sur la VM bastion)
```bash
ssh -F ssh_config_bastion control-plane1
```

via machine hôte avec kubectl
```bash
# récupérer le kubeconfig
ssh -F ssh_config_bastion control-plane1 "cat /home/vagrant/.kube/config" > /tmp/vagrant-vbox-kubeconfig

export KUBECONFIG=/tmp/vagrant-vbox-kubeconfig

# pour tester
kubectl get nodes

# plugin de gestion réseau
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml

# revenir à un ancien cluster
unset KUBECONFIG
```

### Explications

Le Vagrantfile permet de provisionner 4 VMs : 1 bastion, 1 master et 2 workers  

Le script "init_k8s.sh" installe toutes les paquets nécessaires sur les VMs, notamment : docker, kubelet, kubeadm et kubectl  

Le script "init_master.sh" initialise le cluster sur le noeud master en installant etcd, le kubelet, l'apiserver, le controller-manager et le scheduler

Le script "init_worker.sh" permet aux noeuds worker de s'adresser au noeud master afin de récupérer la commande pour rejoindre le cluster

Le script "ssh_restriction.sh" appliqué sur la VM master autorise uniquement les connexions SSH provenant de bastion et des workers  

## Troubleshooting

Les noeuds du cluster sont 'NotReady' et les pods coredns restent en 'Pending' tant que le plugin CNI (calico) n'est pas installé