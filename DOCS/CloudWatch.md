# CloudWatch for on premises EHA servers
AWS CloudWatch has an Agent application that will run on EC2 instances and on premises servers that will collect various machine and user defined metrics.  Those metrics include disk, CPU, memory and swap usage as well as user defined metrics like scanning log files for specified messages. The presence of metric values over a given threshold will trigger alarms that are sent to admin email accounts and to our Slack channel #aws-notifications.

## Current CloudWatch Alarms set on our on-prem compute servers
You can find a list of the currently set CloudWatch alarms for our on-prem servers by logging into the AWS console, going to the CloudWatch Service section and selecting Alarms -> All alarms from the menu on the left of the screen.  The alarms for our on-prem servers are prefaced with the server name (e.g. ProsperoBackupLogError).  Currently they are:
- Backup log checking on prospero
- Low root disk space on prospero, aegypti & kirby
- Low home disk space on prospero
- High swap space usage on prospero, aegypti & kirby
- High memory usage on prospero, aegypti & kirby
- High CPU usage on kirby

## Viewing the raw CloudWatch metrics for our on-prem compute servers
You can see the available metrics for a given on-prem server by logging into the AWS console, going to the CloudWatch Service section and selecting Metrics -> All metrics from the menu on the left of the screen.  Type the name of the server in the search box under the list of Metrics.  This will give you links to the various available metrics for that server.

## Instructions for installing CloudWatch Agent on on-premises Servers and adding a CloudWatch Log filter and alarms

1. Get cloudwatch agent .deb
   1. `wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb`
1. Get agent signature
   1. `wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb.sig`
1. Verify the signature:
   1. `wget https://s3.amazonaws.com/amazoncloudwatch-agent/assets/amazon-cloudwatch-agent.gpg`
   1. `gpg --import amazon-cloudwatch-agent.gpg`
   1. `gpg --fingerprint <key-value>`
      1. Replace <key-value> above with the key output in step b
   1. `gpg --verify amazon-cloudwatch-agent.deb.sig amazon-cloudwatch-agent.deb`
1. Create CloudWatch IAM user if one doesn’t exist
   1. https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/create-iam-roles-for-cloudwatch-agent.html
   1. We only need to create the IAM user that can transfer data to AWS and not the one that has access to Parameter Store.  We won’t store our config file in Parameter store, but instead we’ll share it with our on-prem servers via our GitHub repo.
1. Create aws identity on host machine:
   1. become root user
   1. `aws configure --profile AmazonCloudWatchAgent`
   1. Answer queries with IAM user creds created in previous step
   1. You should now see `config` and `credentials` files with the values you entered in /root/.aws
1. Install agent with:
   1. `dpkg -i -E ./amazon-cloudwatch-agent.deb`
1. Set CloudWatch configuration file for current on-prem servers
   1. Use wizard:  `/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard`
   1. Or share one created with another host machine.  I’ve stored one in eha-servers/CloudWatch/config.json.  Copy it to /opt/aws/amazon-cloudwatch-agent/bin/config.json on the new server.
      1. Only prospero needs the section for the backup log file.  Omit this section for other on-prem servers
1. Start the CloudWatch Agent
   1. `/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m onPremise -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json`
1. Check CloudWatch Agent status:
   1. `/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m onPremise -a status`
   1. Top line ‘status’ is the important one.  It should be ‘running’
   1. Don’t be concerned if ‘cwoc_status’ is ‘stopped’.  That’s expected.
1. Add filter for backup log file (prospero only)
   1. Go to AWS -> CloudWatch -> Log groups
   1. Select cron.log
   1. Select machine
   1. Go to ‘Metric filters’ tab
   1. ‘Create metric filter’ button
   1. Filter pattern is ‘CloudWatchError’
   1. Filter name: ProsperoBackupLog
   1. Metric namespace: Logs/Prospero
   1. Metric name: ProsperoBackupLog
   1. Metric value: 1
   1. Default value: 0
1. Set alarm for backup log filter (prospero only)
   1. AWS -> CloudWatch -> All metrics
   1. Select ‘Custom namespaces’ -> Logs/Prospero
   1. Under CloudWatch -> All Metrics you should now see a ‘custom namespace’ ‘Logs/Prospero’
      1. If you do not see ‘Logs/Prospero’ it’s probably because there are no ‘CloudWatchError’ messages in the log.  Put a test one in the log, make the alarm and then remove the test message.
   1. Select ‘Logs/Prospero’ -> Metrics with no dimensions
   1. Select checkbox next to ‘ProsperoBackupLog’
   1. Select bell icon to create an alarm when sum of counts is > 0
1. Set alarms for metrics:
   1. Memory
   1. Low space on root (/) and home (/home) partitions
   1. Swap space
1. Add list of software to be installed on base machines for this via ‘apt install’:
   1. awscli

## Running Ansible playbook to install CloudWatch Agent on our on-prem servers

`ansible-playbook -kK install-config-cloudwatch.yml -i inventory.ini`
You will be queried for your sudo and ssh passwords.

## CloudWatch Role
Each EC2 instance or on-premises/physical server will need to have permission to send metrics to AWS.  These need to be generated for each AWS organization account.

If the role has already been created for the current account all you need to do is attach the role to the instance with the following steps:
1. In the AWS console navigate to the proper organization account
1. Go to the EC2 instances section
1. Select the 'Actions' pull-down menu.
1. Select 'Security' from that submenu.
1. Select 'Modify IAM Role' from that submenu.
1. Select CloudWatchAgentServerRole

If this is a new organization account and you need to create the role, please see this AWS document for instructions:
https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/create-iam-roles-for-cloudwatch-agent.html
Be sure to add CloudWatchAgentServerPolicy to CloudWatchAgentServerRole

## CloudWatch Agent Config file
You can modify existing config files which are always stored at `/opt/aws/amazon-cloudwatch-agent/bin/config.json`, but you can also create a new config file using a configuration wizard by running the following command on the instance: `/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard`

## Start the CloudWatch Agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json
The command above is for use on EC2 instances.  For on-prem servers change `ec2` after `-m` to `onPremise`

## Stop the CloudWatch Agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a stop
The command above is for use on EC2 instances.  For on-prem servers change `ec2` after `-m` to `onPremise`

## Get the status of the CloudWatch Agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status
The command above is for use on EC2 instances.  For on-prem servers change `ec2` after `-m` to `onPremise`

## General CloudWatch Troubleshooting
https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/troubleshooting-CloudWatch-Agent.html
