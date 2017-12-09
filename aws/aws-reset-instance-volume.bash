#!/bin/bash

# scilinux6
InstanceID=i-0fd4c69ce9e967c51
SnapshotID=snap-0755e697da228a7d0
TAG=scilinux6

# scilinux7
InstanceID=i-07ca3a35c38c71d4b
SnapshotID=snap-07aa908d5919bb51c
TAG=scilinux7

aws ec2 stop-instances --instance-id $InstanceID

sleep 60

echo "Getting VolumeID"
VolumeID=$(aws ec2 describe-instances --instance-ids $InstanceID | jq -r .Reservations[0].Instances[0].BlockDeviceMappings[0].Ebs.VolumeId)
echo "Volume found " $VolumeID

echo "Detaching Volume"
aws ec2 detach-volume --instance-id $InstanceID --volume-id $VolumeID
echo "Volume Detached"

sleep 20

# aws ec2 describe-volume-status --volume-id $VolumeID

echo "Deleting Volume"
aws ec2 delete-volume --volume-id $VolumeID
echo "Volume Deleted"

sleep 20

echo "Creating New Volume"
VolumeID=$(aws ec2 create-volume --availability-zone ca-central-1a --size 20 --volume-type gp2 --snapshot-id $SnapshotID --tag-specifications "ResourceType=volume,Tags=[{Key=Name,Value=$TAG}]" | jq -r .VolumeId)
echo "Volume Created " $VolumeID

sleep 20

echo "Attaching New Volume"
aws ec2 attach-volume --device /dev/sda1 --instance-id $InstanceID --volume-id $VolumeID
echo "New Volume Attached"

sleep 20

echo "Starting Instance"
aws ec2 start-instances --instance-id $InstanceID
