# Introduction

In this project the goal is to write an automation script for the installation of AUTO software on different operating systems and considering the limited time, Scientific Linux 6 and Scientific Linux 7 are two chosen operating systems.

# Local

To run this project on your computer you need a Linux operating system but it will most likey work on MAC and Wwindows as well. You also need VirtualBox, Vagrant and Packer.

## Start Virtual Machine

```bash
$ cd scilinux6
$ packer build packer.json
$ vagrant up
```

## Run AUTO demos

```bash
$ vagrant ssh
$ cd auto/07p/demos/ab/
$ auto ab.auto
```

# Cloud

Running virtual machines locally is resourse intensive and time intensive. On the cloud, you can buy resources on demand and run multiple virtual machines in parallel. This reduces a lot of testing time but comes at a cost. It also helps in cleaning a mess created by virtual machines by deleting a whole cloud virtual machine.

## Setup AWS

Following steps require a configured AWS CLI tool.

```bash
$ aws s3 mb --region ca-central-1a s3://soen6971
$ aws iam create-role --role-name vmimport --assume-role-policy-document "file:///`pwd`/aws/trust-policy.json"
$ aws iam put-role-policy --role-name vmimport --policy-name vmimport --policy-document "file:///`pwd`/aws/role-policy.json"
```

## Create OVA virtual machine for AWS

Following commands will create Scintific Linux 6.9 operating system image file for AWS EC2 and upload it there.

```bash
$ cd scilinux6
$ packer build packer.aws.json
```

After this you need to create an instance on AWS EC2 with the image. After the instance is up and running, you can connect by SSH

```bash
$ ssh root@INSTANCE-IP
$ /sbin/service vncserver start
$ iptables -I INPUT -p tcp --dport 5901 -j ACCEPT
```

An now you can also connect by VNC client.

Now you need to manually upload the file to S3 and import it. For more info visit http://docs.aws.amazon.com/vm-import/latest/userguide/vmimport-image-import.html#import-vm

```bash
$ aws s3 cp FILENAME.OVA s3://BUCKET_NAME
$ cat > aws/import-vm.json << EOL
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
$ aws ec2 import-image --license-type BYOL --disk-containers file:///aws/import-vm.json
$ watch aws ec2 describe-import-image-tasks --import-task-ids import-ami-fgu4xkq3
```
