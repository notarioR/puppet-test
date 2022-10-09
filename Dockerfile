FROM ubuntu:20.04
WORKDIR /home/user

RUN apt-get update -y

RUN apt-get install -y vim

#Tools I may need
RUN apt-get install -y wget
RUN apt install -y curl 
RUN apt install -y iputils-ping
RUN apt install -y systemd

#Puppet server and client
RUN wget https://apt.puppetlabs.com/puppet7-release-focal.deb
RUN dpkg -i puppet7-release-focal.deb
RUN apt-get update -y
RUN apt-get install -y puppetserver
RUN apt-get install -y puppet-agent
RUN apt-get install -y ca-certificates

CMD ["sleep", "infinity"]