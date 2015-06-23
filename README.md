### Bootstrap script

##### Use this bootstrap script with Jenkins, AWS Auto Scaling Group and Load Balancer can help you achieve the following things:
- Use Jenkins to build and deploy a Sinatra project to any number of EC2 instances. (You can tweak Jenkins setup to deploy any code, for example Rails, not only Sinatra)
- When the Auto Scaling Group brings up another EC2 instance (either because old instances are terminated or bacause the servers are under heavy load), Jenkins will be invoked automatically, and a new build is ran, then the code will be deployed to the new EC2 instances. 

This setup also can be used with Jenkins and any other cloud infrastructure, assuming there is a network monitoring mechanism implemented in the cloud infrastructure.

***1 - Setup Jenkins***
Create a Jenkins project with the following things:

Project header:
![alt text](https://raw.githubusercontent.com/linhchauatl/bootstrap_scripts/master/jenkins_project_1.png "Jenkins screen 1")

Project settings:
![alt text](https://raw.githubusercontent.com/linhchauatl/bootstrap_scripts/master/jenkins_project_2.png "Jenkins screen 2")


Code of the Execute Shell
```bash
echo $TARGETS

export PATH=$PATH:/usr/local/bin

ruby -v
gem install bundler
bundle
rake test

if ($DEPLOY_TO_DEV = "true")
then
  cap development deploy targets=$TARGETS
  cap development deploy:stop targets=$TARGETS
  cap development deploy:start targets=$TARGETS
fi
```

The port for git must be open between the Jenkins server and github sever.

***2 - Prepare an EC2 instance and setup bootstrap script to run on the EC2 instance when it is started:***

The EC2 instance must have the following things setup
- RVM setup properly with Ruby 2.2.2 installed.
- Public keys of jenkins server must be added to .ssh/authorized_key
- A password of a valid Jenkins user must be exported as Environment Variable MY_PASSWORD
- The bootstrap script must be put on this EC2 instance, modify the config/jenkins.yml to have correct information.
- Setup the bootstrap script to run when the EC2 instance is restarted.


***3 - Create AMI from the EC2 instance we just setup.***

***4 - Write capistrano deployment code***:
Take a look at this project capistrano code for example: https://github.com/linhchauatl/sinatra_play

***5 - Setup AWS Auto Scaling Group with instances using the AMI we create at step 3.***
All the instances of this Auto Scaling Group must be set to answer a Load Balancer (ELB).


After all the above steps are done, each time an EC2 instance is terminated, another one will be instantiated by Auto Scaling Group. It then connnect to Jenkins server to trigger a build. If the build successes, it will deploy the newest code to the newly created instance.

***6 - A note about target deployment in Jenkins:.***
If you want to use Jenkins to deploy code to existing EC2, you can do so by using Build with Parameters, setting Jenkins parameters TARGETS to specific targets and DEPLOY_TO_DEV to true.

For example if you want to deploy to 2 EC2 instances with IPs 10.100.10.2 and 10.100.10.4, to the user app_user on EC2 instances, your target will be in JSON format:
```json
{"app":["app_user@10.100.10.2", "app_user@10.100.10.4"],"db":["app_user@10.100.10.2"]}
```

Please see the photo belows for example:
![alt text](https://raw.githubusercontent.com/linhchauatl/bootstrap_scripts/master/jenkins_project_3.png "Jenkins screen 3")

Here is a live video about this setting in action:
http://www.mediafire.com/watch/758gu4gi33p94jz/jenkins_deploys_to_ec2.mp4

If you can not watch it online, you can download to your local machine to watch.
It is a movie about using Jenkins to deploy a Sinatra project from github to a newly created EC2 instance within an Auto Scaling Group.