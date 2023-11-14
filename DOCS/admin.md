# Documentation for administration tasks

## adding new users

1. make a dev branch in eha-servers
1. generate passwords for the new users
  1. allowed symbols: !@#$%^&*()_+-=[]{}|
1. add users to secure.yml
  1. to genereate the password hash: echo 'mypasswd' | mkpasswd -s --method=sha-512
  1. make sure uid isn't already used in the file
  1. may new entry in the same format as a previous non-admin user.
1. from local eha-servers directory run: ansible-playbook -kK update-accounts-base.yml
1. from local eha-servers run: ansible-playbook -kK update-accounts.yml
1. there seems to be an order issue with the above scripts, so you may get an error when you try to add users.  Just run both playbooks a second time in the same order and it should work.
1. give user their password in slack after trying their credentials
1. if you need to add to #eha-servers slack channel as single-channel guest:
  1. go to Slack app window and select EHA pull-down menu at the top.
  1. select invite people to join and select single-channel guest.
1. after user confirms they have access, merge dev branch with master branch of eha-servers
1. point new users to doc: https://hackmd.io/@ecohealthalliance/eha-servers-readme

