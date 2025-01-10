
# maybank-tech-assessment

By: Kurniawan



## Authors

- [@Kurniawan](https://github.com/n00bC0d3)


## Features

- S3 and EC2 web server is served by AWS Cloudfront, which has geographic restriction to ALLOW ONLY users from Indonesia, Malaysia, and Singapore
- MariaDB served by RDS Single AZ with Read Replica in another AZ 
- Bastion Host to access the EC2 WebServer 


## Documentation

To access RDS DB Server or EC2 Web Server, use bastion server + SSM command 

#test port forwarding server asg
aws ssm start-session --target <Bastion server instance id> --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters '{"portNumber":["80"],"localPortNumber":["80"],"host":["<ec2 webserver private ip>"]}'

#test port forwarding DB
aws ssm start-session --target <Bastion server instance id> --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters '{"portNumber":["3306"],"localPortNumber":["<your localport>"],"host":["<rds db endpoint>"]}'

