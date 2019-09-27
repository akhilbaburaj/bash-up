#!/bin/bash
sudo yum install curl jq -y
region=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone/ | sed 's/.$//')

myFinalTag=false;
myIndex=0;

aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name ASG-ofEC2 --region $region> /var/tmp/asgjson.txt
cat /var/tmp/asgjson.txt
asgOutput=($(jq '.AutoScalingGroups[0].Instances[].InstanceId'  /var/tmp/asgjson.txt))
echo ${asgOutput[@]}
aws ec2 describe-tags --filters "Name=resource-id,Values=["$(printf "%s," "${asgOutput[@]}")"]" "Name=key,Values=Name" --region $region> /var/tmp/ec2tag.txt
instanceId=`curl  http://169.254.169.254/latest/meta-data/instance-id/`
quotedId='"'$instanceId'"'
echo $quotedId
InstanceList=($(jq '.Tags[].ResourceId' /var/tmp/ec2tag.txt))
echo ${InstanceList[@]}
usedTags=($(jq '.Tags[].Value' /var/tmp/ec2tag.txt))
echo ${usedTags[@]}
sortedInstanceList=($(printf "%s\n"  ${InstanceList[@]} | sort -n))
echo ${sortedInstanceList[@]}

for((i=0;i<${#sortedInstanceList[@]};i++)); do
        if [[ $quotedId == ${InstanceList[$i]} ]]; then
                myIndex=$i ;
                break;
        fi
done
echo $myIndex;

for((i=0;i<${#usedTags[@]};i++)); do
        checkId="ASGofEC2$i";
        if [[ ! "${usedTags[$i]}" =~ "${checkId}" ]]; then
                availableTags[$i]=true;
        else
    			availableTags[$i]=false;
        fi
done
echo ${availableTags[@]};

if [[ ${availableTags[$myIndex]} == true ]]; then
        myFinalTag=ASGofEC2$myIndex;
        break;
elif [[ $myFinalTag == false  ]]; then
        for((i=$myIndex;$i>=0;i--)); do
                if [[ ${availableTags[$i]}  == true ]]; then
                                myFinalTag=ASGofEC2$i;
                        break;
                fi;
        done;
elif [[ $myFinalTag == false  ]]; then
        for((i=$myIndex;i<=${#usedTags[@]};i++)); do
                if [[ ${availableTags[$i]}  == true ]]; then
                        myFinalTag=ASGofEC2$i;
                        break;
                fi;
        done;
else
        myFinalTag=ASGofEC2$((i+1));
fi
aws ec2 create-tags --resources $instanceId --tags Key=Name,Value=$myFinalTag --region $region