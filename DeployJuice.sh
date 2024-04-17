playground@playground:~$ cat DeployJuice.sh
#!/bin/bash

#Update Repository and download required software
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y

#Add Docker’s official GPG key:
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

#Add the Docker repository to APT sources:
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

#Update your package index again and install Docker CE (Community Edition):
sudo apt update
sudo apt install docker-ce -y

#Verify Docker is installed correctly by running the hello-world image:
sudo docker run hello-world

#Download the latest version of Docker Compose:
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
Adjust the version number as needed by checking the latest release on GitHub.

#Make the binary executable:
sudo chmod +x /usr/local/bin/docker-compose

#Verify the installation:
docker-compose --version

#Pull the OWASP Juice Shop Docker image:
sudo docker pull bkimminich/juice-shop

#Run the OWASP Juice Shop container:
sudo docker run -d -p 3000:3000 bkimminich/juice-shop
