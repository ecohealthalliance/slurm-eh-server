# Documentation related to GitHub runners

## Ansible playbook for deploying GitHub runners as SystemD services
[deploy-github-runner-svc.yml](../deploy-github-runner-svc.yml)

If there's a time when the SystemD runners are down and the automation script isn't working to get them restarted, you can follow the steps in the next section on manually setting up a runner to one going while you debug the issue.  

## Manually set up GitHub runner on aegypti or prospero
For an organization level runner go to base EcoHealthAlliance page on GitHub to perform the following steps.
For a repository level runner to to the repository base page on GitHub to perform the following steps.

1. Select settings button
1. Select Actions in left column links then Runners
1. Click New Runner button
1. On base machine follow instructions (put new dir in /local dir)
1. Run with nohup in the backgroud so it won't drop
  * `nohup ./run.sh </dev/null > runner.log 2>&1 &`
  * see example in Ansible playbook above
1. Name should be onprem-aegypti or -prospero
1. Labels should be defaults and onprem-aegypti or -prospero
