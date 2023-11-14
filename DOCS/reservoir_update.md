# notes for updating reservoir

Since we've added a reboot to the reservoir deploy playbook the following playbooks should be run make sure NFS accounts are exported to aegypti:

1. ansible-playbook -kK deploy-reservoir.yml
   * Enter compute server pw when prompted
1. ansible-playbook -kK setup-nfs.yml
1. ansible-playbook -kK update-accounts.yml
