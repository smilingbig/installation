# TODO
# I'm trying to setup a dockerfile as a test enviroment, but couldn't get the 
# install script to run correctly. It runs, but nothign inside the script are 
# installed correcty.
FROM ubuntu:latest

RUN apt-get update 
RUN apt-get install -y sudo bash openssh-server git
RUN ln -fs /usr/share/zoneinfo/Europe/London /etc/localtime 
RUN apt-get install -yq tzdata 
RUN dpkg-reconfigure -f noninteractive tzdata 

RUN useradd -rm -d /home/test -s /bin/bash -G sudo -u 1000 test 
RUN usermod -aG sudo test
RUN echo 'test:test' | chpasswd

RUN service ssh start
ADD install.sh /
RUN chmod +x /install.sh

EXPOSE 69

CMD ["/usr/sbin/sshd","-D"]
