# eha-servers
scripts, docs and issues for EHA research servers

## Ansible prerequisites

1. [Install ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
2. Download required roles from ansible galaxy: `ansible-galaxy install -r requirements.yml`
3. Install [git-crypt](https://www.agwa.name/projects/git-crypt/) (and gpg) and provide Noam or Rob your public key so you can decrypt files.

## Deploying the reservoir container

*NOTE:* credentials are secured via git-crypt.  User's SSH key must be added to the project to unlock.

1. Run the ansible scripts:

```
ansible-playbook -kK deploy-reservoir.yml
ansible-playbook -kK setup-nfs-host.yml
ansible-playbook -kK update-accounts-base.yml
ansible-playbook -kK update-accounts.yml
```
You will be prompted for your become and ssh passwords.  They are probably the same (your ssh password), which is an option you will be given.

## Updating user accounts

1. Specify the accounts to be added/removed in secure.yml. User names should be purely alphanumeric and start with a lowercase letter.

2. Run the ansible script:

```
ansible-playbook -kK update-accounts-base.yml
ansible-playbook -kK update-accounts.yml
```
You may need to run both commands a second time becuase of an intermittent error.

## Restoring from backups

Backups of each use home directory are created using duplicity and stored on Backblaze.

To restore a backup you will need to complete the following prerequisites:

1. Install duplicity version 0.7.19 or greater.
2. Install the python b2 and fasteners packages.
3. Get the EHA backup gpg keys from Nathan or Noam and import them using `gpg --import`.
4. Get the b2_account_id and b2_application_key variables from Nathan or Noam or the secure.yml file.

See the aws-deploy-container.yml playbook for examples of how to do these tasks on an ubuntu system.

To restore an users home directory you will need to use the following command:

`duplicity restore b2://{{ b2_account_id }}:{{ b2_application_key }}@ehahomebackup/backupof{{username}} /home/{{username}} --encrypt-key={{gpg key id}} --sign-key={{gpg key id}} -t {{optional time period}}`

## Deploying an AWS server running the reservoir image.

1. Get the EHA backup gpg keys from Nathan or Noam and place them in the eha-servers base directory.
2. Get the temp-instances.pem key from Nathan or Noam, or create a new key on the EC2 portal and modify the key_name and security_group in aws-deploy-container.yml.  Note that the key must have it's permissions set to user-read only (`chmod 600 the-key-file.pem`)
3. Run the following command. You will be prompted to directories to restore. The server's ip address will be printed after the playbook completes.

```
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook aws-deploy-container.yml --private-key {{path to temp-instances.pem}}
```


*Remember to terminate the server in the EC2 portal when it is no longer needed.*

## Setting up automatic backups

1. Get the EHA backup gpg keys from Nathan or Noam and place them in the eha-servers base directory.
2. Run the create-cronjobs.yml playbook.

## Gurobi Token Server

The aegypti base machine runs a Gurobi token server that provides Gurobi license tokens to the docker containers. The token server was installed using the instructions here: https://github.com/ecohealthalliance/eha-servers/issues/13 and here: https://www.gurobi.com/documentation/8.1/remoteservices/installation.html
The gurobi.lic file in /root was modified so to set the following parameters:
```
PORT=60954
PASSWORD={{gurobi_password in ansible secure.yml file}}
```

## Ports in use in the open 22k range

Port Number | Port Usage
----------- | ----------
22020 | prospero & aegypti base ssh
22022 | prospero & aegypti container ssh
22053 | kirby repel-infrastructure postgres container (dev workflow)
22090 | repel-infrastructure shiny container (local workflow)
22097 | repel-infrastrure scraper container (local workflow)

## Updating Reservior containers 

1. Ensure all users are logged off and no jobs running 
2. Assumption is the containers are are already pushed to container repository
     ### pushing container from local to repository 
        1.  Build the images on local  ```running bash build.sh```
        2.   Follow the guide to authenticate https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-with-a-personal-access-token-classic
        3. Tag the images respectively i.e```docker tag f4295eaa4e5f ghcr.io/ecohealthalliance/reservoir:base``` 
        4 Push the images```docker push ghcr.io/ecohealthalliance/reservoir:base```
3. Run deploy-reservoir ```playbook ansible-playbook -kK deploy-reservoir.yml```
4. Server will restart and run``` ansible-playbook -kK update-accounts-base.yml, ansible-playbook -kK update-accounts ```

Step 4 will be done incase step 3 does not run update account or run into any run failures 
