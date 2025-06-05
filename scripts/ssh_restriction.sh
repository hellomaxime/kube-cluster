#!/bin/bash

# Avec l'ajout de Bastion, le control-plane doit uniquement
# accepter les connexions SSH provenant de bastion et bloquer
# toutes les autres.

iptables -F

# Authorize SSH from bastion
iptables -A INPUT -p tcp --dport 22 -s 192.168.50.8 -j ACCEPT

# Authorize SSH from worker1 and worker2
iptables -A INPUT -p tcp --dport 22 -s 192.168.50.21 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -s 192.168.50.22 -j ACCEPT

# Block remaining inputs
iptables -A INPUT -p tcp --dport 22 -j DROP