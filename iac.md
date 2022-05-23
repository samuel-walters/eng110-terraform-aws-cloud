# Infrastructure as Code (IaC)

Infrastructure as code is the process of managing and provisioning computer data centers through machine-readable definition files, rather than physical hardware configuration or interactive configuration tools. (It is the managing and provisioning of infrastructure - networks, virtual machines, load balancers, and connection topology - through code instead of through manual processes.)

For cloud computing: A process that describes and provisions all the infrastructure resources in a cloud environment using a simple text file. Used to model and provision all the resources needed for your applications across all regions and accounts.

## Diagram

The below diagram details how Terraform and Ansible can be used to form IaC:

![](https://i.imgur.com/ubSImc9.png)

# Benefits of IaC

## IaC boosts productivity through automation

One of the first and most obvious benefits of an infrastructure model like IaC is that it improves the productivity of your operations teams across the IT sector, and allows you to automate all infrastructure processes and changes to save time, money, and minimize the risk of human error. Up until the creation of IaC, infrastructure changes had to be handled and managed through extensive and complex manual work, which would invariably drain resources and sometimes cause setbacks to occur.

## Consistency in configuration and setup

The definition files are a single source of truth. There’s never any confusion about what they do. You execute them repeatedly and get predictable results every time.

## Low Costs

You don’t have to hire a team of professionals to routinely manage resource provisioning, configuration, troubleshooting, hardware setup, and so on. It saves time and money.

## Speed 

IaC automates resource provisioning across environments, from development to deployment, by simply running a script. It drastically accelerates the software development life-cycle and makes your organization more responsive to external challenges.

## Accountability

When you need to trace changes to definition files, you can do it with ease. They are versioned, and therefore all changes are recorded for your review at a later point. So, once again, there’s never any confusion on who did what.

# Tools for IaC

## Terraform

HashiCorp Terraform is the most popular and open-source tool for infrastructure automation. It helps in configuring, provisioning, and managing the infrastructure as code.

## Ansible

Ansible is considered the simplest way to automate the provision, configuration, and management of applications and IT infrastructure. Ansible enables users to execute playbooks to create and manage the required infrastructure resources. It does not use agents and can connect to servers and run commands over SSH. Its code is written in YAML as Ansible Playbooks, making it easy to understand and deploy the configurations. You can even expand the features of Ansible by writing your own Ansible modules and plugins.

## AWS CloudFormation

The models and templates for CloudFormation are written in YAML or JSON format. You just need to code your desired infrastructure from scratch with the suitable template language and use the AWS CloudFormation to provision and manage the stack and resources defined in the template.

# Configuration Orchestration vs. Configuration Management

* Configuration orchestration tools, which include Terraform and AWS CloudFormation, are designed to automate the deployment of servers and other infrastructure.

* Configuration management tools like Chef, Puppet, and Ansible help configure the software and systems on this infrastructure that has already been provisioned.

* Configuration orchestration tools do some level of configuration management, and configuration management tools do some level of orchestration. Companies can and many times use both types of tools together.

### Example

Nightly backups - or commits, is a management task that might be automated using a variety of technologies, including command line scripts or external network management systems. Automating the provisioning of the infrastructure services needed to support an app moving into production – in the right order – is orchestration.

# Use Cases of IaC

There are three major cases where IaC approach can be applied: software development, infrastructure management and cloud monitoring.

* When the environments are uniform across the whole cycle, the chances of bugs arising are much lower, as well as the time required for deployment and configuration of all the required environments. Build, testing, staging and production environment deployments will be repeatable, predictable and error-free.

* Cloud infrastructure management using IaC means that all actions that can be automated will be automated. In this case, multiple scenarios emerge, where provisioning and configuring the system components with Terraform and Kubernetes helps save time, money and effort. All kinds of tasks, from database backups to new feature releases can be done faster and better.

* Finally, cloud monitoring, logging and alerting tools also need to run in some environments and deliver new system components. Solutions like ELK stack, FluentD, SumoLogic, Datadog, Prometheus + Grafana — all of these can be quickly provisioned and configured for your project using IaC best practices.

# General Explanation

Codify whatever we need. Write set of instructions in a form of a script - yaml, python - to update an app, deploy architecture - to avoid the human intervention as much as possible. Don't need all the clicks (security group etc.). 

Orchestration: Create a VPC, create subnets, security groups, Internet Gateway, SNS, cloud watch alarm, --> lots and lots of clicks. Write a set of instructions in a terraform script to automatically do everything listed above.

^ No deployment, though. We need another tool to push the app into the existing architecture. Ansible can configure and provision into the existing architecture - go into this vpc, this ec2 instance, and install node. Then go into the other ec2 instance, and set up Mongodb ---> change this security group, change this environment variable.

With both orchestration and management, you can automate the whole process of setting up architecture and managing it so it can host applications (or whatever it is you are doing).

Mutable - you can change the configuration --> immutable - you **cannot** change the configuration.

## Ansible

Ansible can actually do both orchestration and management.

* Very simple to use.

* Agentless - because everything you need to install only needs to be installed on Ansible. The other server does not need to have Ansible installed. 

provisioning.sh script can do multiple things in **one** server only. yaml script can have numerous instructions for multiple servers.

Example: 500 servers running. Update command for hundred servers. Would have to run the script for every server individually. Ansible: could you go and run this script for all these servers? No issues: it could do it.

Sonar Cube - looks for any potential threats (IPs) - and puts them into the CSV/JSON file - this file is used in the security groups of these servers to block these IPs. How do we block these IPs in 1000s of servers (yes, through security groups - it would take a very long time). --> But it's one single command with ansible - pick up the file (in a playbook - script) - these are the hosts - go and block them. Specify the servers - the family of OS - e.g. check Ubuntu servers first. 


# Difference between pull and push configuration

![](https://i.imgur.com/H4gXedC.png)

There are two methods of IaC: ‘Push’ and ‘Pull’ . The main difference is the manner in which the servers are told how to be configured. In the Pull method the server to be configured will pull its configuration from the controlling server. In the Push method the controlling server pushes the configuration to the destination system.

IaC tools that use the pull model often have an agent running that polls a configuration management server for the latest desired state. If the current state does not match the desired state then the agent takes corrective action. This means that in a pull model the agent is effectively a continuous delivery system. The pull model is best suited for mutable (fried) infrastructure and can be used when you have full access to the systems you're managing. Baremetal desktops and virtual machines are good examples of such systems.

Tools that utilize the push model work differently. They are launched from a controller, which could be your own laptop or a CI/CD system like Jenkins. If the tool in question is declarative the controller reaches out to the systems being managed, then figures out the differences between desired state and current state and runs the commands required to reach the desired state. If the tool is imperative controller just runs commands it is told to or deploys a new pre-baked image. In any case the target systems do not need a dedicated agent to be running. The push model is often only choice when you only have limited (e.g. API) access to the system you're managing: this is the case with public Clouds and SaaS for example.

Terraform is a purely push model tool. This design choice was forced over it, though, because most of the systems it manages are only available through APIs.

In practice pull and push can be combined. For example, some Puppet providers use API calls to push changes to a remote or a local system. Yet those API calls might be triggered by a Puppet Agent that pulls it configurations from a puppetserver.
