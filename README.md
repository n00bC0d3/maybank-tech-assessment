
# maybank-tech-assessment

last update: 12 Jan 2025



## Authors

- [@Kurniawan](https://github.com/n00bC0d3)


## Features
All of the resources will be deployed at ap-southeast-1 ( Singapore AWS Region ), please update the code and syntax accordingly if you want to deploy it in another AWS region

```
Terraform

- S3 and EC2 web server is served by AWS Cloudfront, which has geographic restriction to ALLOW ONLY users from Indonesia, Malaysia, and Singapore
- MariaDB served by RDS Single AZ with Read Replica in another AZ 
- Bastion Host to access the EC2 WebServer 

```

```
K8s
- resource in each yaml file
- alternate to use helm

```
## Documentation

To access RDS DB Server or EC2 Web Server, use bastion server + SSM command 

#test port forwarding server asg
aws ssm start-session --target <Bastion server instance id> --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters '{"portNumber":["80"],"localPortNumber":["80"],"host":["<ec2 webserver private ip>"]}'

#test port forwarding DB
aws ssm start-session --target <Bastion server instance id> --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters '{"portNumber":["3306"],"localPortNumber":["<your localport>"],"host":["<rds db endpoint>"]}'


## Installation

Prerequisite : 
```
    need to already install these in your local system : 
    - terraform
    - aws cli ==> please configure your aws credential in the cli
    - kubectl
    - git
    - helm ( optional if you want to deploy using helm instead of k8s )

```

Install the project

```
- Terraform
  terraform init
  terraform plan
  terraform apply 

- k8s
    #please edit the file pv.yaml first and update the value of : 
    spec.csi.volumeHandle in PersistentVolume
    
    #Please deploy AWS EKS and EFS in the region first,
    then do : 
    #set login current aws profile into kubernetes cluster
    aws eks update-kubeconfig --region ap-southeast-1 --name <Cluster-name>
    
    kubectl apply -f <name of yaml> 
    kubectl apply -f pv.yaml



- helm
    cd my-app
    $ helm install bestapp . -n bestapp --create-namespace
    # to upgrade use helm upgrade :
    $ helm upgrade bestapp . -n bestapp  --install

```
    

