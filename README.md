# Local

## Start Virtual Machine

1. $ cd scilinux6
2. $ packer build packer.json
3. $ vagrant up

## Run AUTO demos

1. $ vagrant ssh
2. $ cd auto/07p/demos/ab/
3. $ auto ab.auto

# Cloud

Running virtual machines locally is resourse intensive and time intensive. On the cloud, you can buy resources on demand and run multiple virtual machines in parallel. This reduces a lot of testing time but comes at a cost. It also helps in cleaning a mess created by virtual machines by deleting a whole cloud virtual machine.

## Setup AWS

Following steps require a configured AWS CLI tool.

1. $ aws s3 mb --region ca-central-1a s3://soen6971
2. $ aws iam create-role --role-name vmimport --assume-role-policy-document "file:///`pwd`trust-policy.json"
3. $ aws iam put-role-policy --role-name vmimport --policy-name vmimport --policy-document "file:///`pwd`role-policy.json"

## Create OVA virtual machine for AWS

Following commands will create Scintific Linux 6.9 operating system image file for AWS EC2 and upload it there.

1. $ cd scilinux6
2. $ packer build packer.aws.json

After this you need to create an instance on AWS EC2 with the image. After the instance is up and running, you can connect by SSH

1. $ ssh root@INSTANCE-IP
2. $ /sbin/service vncserver start
3. $ iptables -I INPUT -p tcp --dport 5901 -j ACCEPT

An now you can also connect by VNC client.

Sometimes packer build will take longer than expected without reporting progress. In that case, you can kill packer build and manually upload the file to S3 and import following this guide http://docs.aws.amazon.com/vm-import/latest/userguide/vmimport-image-import.html#import-vm

1. $ aws s3 cp FILENAME.OVA s3://BUCKET_NAME
2. $ cat > containers.json << EOL
        [
          {
            "Description": "Scintific Linux 6.9 OVA",
            "Format": "ova",
            "UserBucket": {
                "S3Bucket": "soen6971",
                "S3Key": "packer-scientific-6.5-x86_64-1512576109-1512576109.ova"
            }
        }]
     EOL
3. $ aws ec2 import-image --license-type BYOL --disk-containers file://containers.json
4. $ watch aws ec2 describe-import-image-tasks --import-task-ids import-ami-fgu4xkq3
