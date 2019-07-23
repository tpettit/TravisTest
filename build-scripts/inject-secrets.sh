#!/bin/bash
mkdir ~/.kube
mv ./build-scripts/kubeconfig ~/.kube/config
 
#decrypt the large secrets
openssl aes-256-cbc -K $encrypted_eb3a8d2f6fc9_key -iv $encrypted_eb3a8d2f6fc9_iv -in large-secrets.txt.enc -out build-scripts/large-secrets.txt -d
 
# run the script to get the secrets as environment variables
source ./build-scripts/large-secrets.txt
export $(cut -d= -f1 ./build-scripts/large-secrets.txt)
 
 
# Set kubernetes secrets
./kubectl config set clusters.cluster.staging-dribot.com.certificate-authority-data $CERTIFICATE_AUTHORITY_DATA
./kubectl config set users.cluster.staging-dribot.com.client-certificate-data "$CLIENT_CERTIFICATE_DATA"
./kubectl config set users.cluster.staging-dribot.com.client-key-data "$CLIENT_KEY_DATA"
./kubectl config set users.cluster.staging-dribot.com.password "$KUBE_PASSWORD"
./kubectl config set users.cluster.staging-dribot.com.net-basic-auth.password "$KUBE_PASSWORD"
 
# set AWS secrets
mkdir ~/.aws
touch ~/.aws/credentials
echo '[default]' >> ~/.aws/credentials
echo "aws_access_key_id = $AWS_KEY">> ~/.aws/credentials
echo "aws_secret_access_key = $AWS_SECRET_KEY" >> ~/.aws/credentials
 
# set AWS region
touch ~/.aws/config
echo '[default]' >> ~/.aws/config
echo "output = json">> ~/.aws/config
echo "region = us-east-2" >> ~/.aws/config
