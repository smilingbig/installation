# TODO
# I'm trying to setup a dockerfile as a test enviroment, but couldn't get the 
# install script to run correctly. It runs, but nothign inside the script are 
# installed correcty.
FROM ubuntu:latest

RUN apt-get update && \
      apt-get -y install sudo bash

RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1000 test 
RUN usermod -aG sudo test
RUN echo 'test:test' | chpasswd

USER test
WORKDIR /home/test

RUN echo 'test' | sudo -S apt-get update 
RUN echo 'test' | sudo -S apt-get install -yq tzdata 
RUN echo 'test' | sudo -S ln -fs /usr/share/zoneinfo/Europe/London /etc/localtime 
RUN echo 'test' | sudo -S dpkg-reconfigure -f noninteractive tzdata 
RUN echo 'test' | sudo -S apt-get install openssh-server git -y

ADD install.sh /
RUN echo 'test' | sudo -S chmod +x /install.sh
RUN echo 'test' | sudo -S bash -c /install.sh

USER root
RUN service ssh start

EXPOSE 69

CMD ["/usr/sbin/sshd","-D"]
