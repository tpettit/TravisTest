#!/bin/bash
GREEN='\033[0;32m'
NC='\033[0;0m'
 
# install kubectl
echo -e "${GREEN}==== INSTALLING KUBECTL ====${NC}"
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
echo -e "${GREEN}==== SUCCESSFULLY INSTALLED KUBECTL ====${NC}"
echo ''
 
# install kops
echo -e "${GREEN}==== INSTALLING KOPS ====${NC}"
curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
chmod +x ./kops-linux-amd64
echo -e "${GREEN}==== SUCCESSFULLY INSTALLED KOPS ====${NC}"
echo ''
 
# install aws
echo -e "${GREEN}==== INSTALLING AWS ====${NC}"
pip install --user awscli
export PATH=$PATH:$HOME/.local/bin
chmod +x ./aws
echo -e "${GREEN}==== SUCCESSFULLY INSTALLED AWS ====${NC}"
echo ''
 
# install terraform
echo -e "${GREEN}==== INSTALLING TERRAFORM ====${NC}"
apt-get install unzip
curl -LO https://releases.hashicorp.com/terraform/0.11.2/terraform_0.11.2_linux_amd64.zip
unzip terraform_0.11.2_linux_amd64.zip -d ./
chmod +x ./terraform
echo -e "${GREEN}==== SUCCESSFULLY INSTALLED TERRAFORM ====${NC}"
echo ''

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
