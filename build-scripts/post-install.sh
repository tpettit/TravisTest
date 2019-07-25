#!/bin/bash

#script to recursively travel a dir of n levels


function traverse() {

for file in `ls $1`
do
    #current=${1}{$file}
    if [ ! -d ${1}${file} ] ; then
    echo ''
    else

        echo -e "${GREEN}==== Deploying TF in ${1}/${file} ====${NC}"
        cd ${1}${file}

        if ls | grep -q .tf;
        then
            terraform init
            terraform plan
            terraform apply -auto-approve
        fi

         echo -e "${GREEN}==== Done deploying TF in ${1}/${file} ====${NC}"
        ls
        echo "Traversing ${1}/${file} next"
        traverse "${1}/${file}"
    fi
done
}


GREEN='\033[0;32m'
NC='\033[0;0m'
export PATH=$PATH:$(pwd)
export AWS_DEFAULT_REGION="eu-west-1"

echo -e "${GREEN}==== Deploying terraform ====${NC}"


cd build-scripts
traverse ../

echo -e "${GREEN}==== Done deploying terraform  ====${NC}"
echo ''

GREEN='\033[0;32m'
NC='\033[0;0m'
export PATH=$PATH:$(pwd)
echo -e "${GREEN}==== Deploying RBAC role ====${NC}"
cd rbac/
for f in $(find ./ -name '*.yaml' -or -name '*.yml'); do kubectl apply -f $f --validate=false --insecure-skip-tls-verify=true; done
echo -e "${GREEN}==== Done deploying RBAC role ====${NC}"
echo -e "${GREEN}==== Deploying iam role ====${NC}"
cd ../kube2iam/
for f in $(find ./ -name '*.yaml' -or -name '*.yml'); do kubectl apply -f $f --validate=false --insecure-skip-tls-verify=true; done
echo -e "${GREEN}==== Done deploying iam role ====${NC}"
echo ''
echo -e "${GREEN}==== Deploying external dns ====${NC}"
cd ../external_dns/
for f in $(find ./ -name '*.yaml' -or -name '*.yml'); do kubectl apply -f $f --validate=false --insecure-skip-tls-verify=true; done
echo -e "${GREEN}==== Done deploying external dns ====${NC}"
echo ''
echo -e "${GREEN}==== Deploying apps ====${NC}"

for d in ../apps/ ; do
    
    for f in $(find $d -name '*.yaml' -or -name '*.yml');
    do
        echo -e "${GREEN}==== Deploying ${f} ====${NC}"
        kubectl apply -f $f --validate=false;
        echo -e "${GREEN}==== Done Deploying ${f} ====${NC}"
    done
done
 
echo -e "${GREEN}==== Done deploying apps ====${NC}"
echo ''
