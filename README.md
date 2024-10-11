![svg xmlns=httpwww w3 org2000svg x=0px y=0px width=100 height=100 viewBox=0 0 48 48 path fill=#424242 d=M44,24c0,11 045-8 955,20-20,20S4,35 045,4,24S12 955,4,24,4S44,12 955,44,24zpathpath fill=#fff (1)](https://github.com/user-attachments/assets/40bd53ca-a68b-450f-aeb4-2e2343f82f14)
# :white_check_mark: AIM 
## *Deploying web-application in a Docker-Container on remote Docker-Host using Jenkins CI/CD and build using Ansible playbook and Dockerfile*
# :arrow_right: STEPS
**1. Launch 3 ubuntu servers on AWS for Jenkins, Ansible, Docker-Host**

--> 1) For Jenkins take T2.Medium server

--> 2) For Ansible take T2.Medium server

--> 3) For Docker-Host take T2.Micro server

**2. Connect all 3 servers to terminal**

--> Configure all 3 servers for ssh

--> Set password on all 3 servers ( set same password on all 3 servers )
```
passwd root
```

**3. Enable Password Authentication on all servers**
```
nano /etc/ssh/sshd_config
```
--> Uncomment permit root login access to yes

--> Password Authentication to yes

--> comment to kbdInteractiveAuthentication

**4. Connect all 3 servers using ssh key sharing**

--> Generate key on Jenkins and Ansible server
```
ssh-keygen
```

```
# do this on jenkins server
ssh-copy-id root@private ip of ansible server
```
```
# do this on Ansible server
ssh-copy-id root@private ip of docker-host
```

--> Doing this we have connected Jenkins server with Ansible server and Ansible server with Docker-Host server

**5. Now on Jenkins Server we have to Install Java, Jenkins.**

--> For this go to Download Jenkins and select ubuntu os and do the give steps on your Jenkins server. and also enable jenkins service
```
systemctl start jenkins
systemctl enable jenkins
systemctl status jenkins
```


**6. On Ansible-server install Ansible using  below commands**
```
apt-add-repository ppa:ansible/ansible
apt-get update
apt-get install ansible -y
```
--> Also Install Docker and Docker.io part on Ansible-server and enable docker service
```
apt-get install docker -y
apt-get install docker.io -y

systemctl start docker
systemctl enable docker
```

**7. Set Host in Ansible Hosts file**
```
nano /etc/ansible/hosts/
```

--> Set Dockerhost with its private ip
```
[dockerhost]
pri.ip of docker
```

**8. On Docker-Host server install Docker & enble services**
**9. Now on Jenkins dashboard install publish-over ssh plugin.**

**10. On Git-Hub create one repository and write one Dockerfile**
```
FROM ubuntu:latest
ARG  DEBIAN_FRONTEND=noninteractive
RUN  apt-get update
RUN  apt-get install -y apache2 curl
COPY index.html /var/www/html/index.html
WORKDIR   /var/www/html
ENTRYPOINT ["/usr/sbin/apache2ctl"]
CMD  ["-D", "FOREGROUND"]
EXPOSE 80
```

**10. Go to Jenkins-Dashboard in manage jenkins**

--> system configuration --> IN the ssh-server section configure Jenkins & Ansible server
```
Name - Jenkins
Hostname - pri.ip of the jenkins
username - root
adv.settings - enter password
# do the same for ansible
```

**11. Go to /opt folder in Ansible server and write one index.html file**
```
cd /opt
nano index.html
```

**12. login docker-hub from  ansible-server and docker-host server using**
```
docker login
```
**13. give access to docker user**
```
sudo usermod -aG $USER
```

**13. Go to Jenkins Dashboard**

--> Create new job devops-project-2

--> go to Configure project

--> paste your Git-Hub repo url in git section

--> Apply

**13. In the build steps**

--> add send files or execute commands over ssh

--> select jenkins

--> on the exec command section enter -
```
rsync -avh /var/lib/jenkins/workspace/devops-project-2/dockerfile root@pri.ip of ansible:/opt/
```

--> add another server 

--> select ansible

--> on the exec command section enter
```
cd /opt
docker image build -t devops-project-2:v1 .
docker image tag devops-project-2:v1  dockehub-id/devops-project-2:v1
docker image tag devops-project-2:v1  dockerhub-id/devops-project-2:latest
docker image push dockerhub-id/devops-project-2:v1
docker image push dockerhub-id/devops-project-2:latest
docker image rmi devops-project-2:v1  dockerhub-id/devops-project-2:v1  dockerhub-id/devops-project-2:latest
```
--> Apply and Save.

**14. Go to Ansible-Server**

--> create one folder
```
mkdir sourcecode
```
--> In sourcecode folder write ansible-playbook
```
nano deployment.yml
```
```
---
- hosts: dockerhost
  tasks:
    - name: stop container if running
      shell: docker container stop mydockercontainer || true
    - name: remove container if exists
      shell: docker container rm mydockercontainer || true
    - name: remove image if exists
      shell: docker image rm vaibhavkhairnar/devops-project-2 || true
    - name: create container
      shell: docker container run -itd --name mydockercontainer -p 9000:80 vaibhavkhairnar/devops-project-2
```
**15. In the Post-build actions**

--> Select send build artifacts over ssh

--> select ansible 

--> In the exec command section enter
```
ansible-playbook /home/ubuntu/sourcecode/deployment.yml
```

--> apply and save.

**16. Start 1st Build**

--> If success, check on the docker-hub image is pushed or not also in the ansible server docker image is created or not, if every thing is success --> then add your docker-host servers public ip in the browser with :9000 port you will see your index.html is application. this how you can do CI/CD automation for you application deployment.
