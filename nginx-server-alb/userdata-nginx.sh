#!/bin/bash
sudo apt-get update
sudo apt-get install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
echo "Hello World | This is server $(hostname -f)" | sudo tee /var/www/html/index.html

########## To install nginx docker container via Puppet from built docker image #################
sudo apt-get update
sudo wget https://apt.puppetlabs.com/puppet-release-bionic.deb
sudo dpkg -i puppet-release-bionic.deb
sudo apt-get install -y puppetmaster
sudo echo $(hostname -I | cut -d' ' -f1) puppet > /etc/hosts
sudo echo "JAVA_ARGS="-Xms712m Xmx712m"" | sudo tee /etc/default/puppet-master
sudo echo "START=yes" | sudo tee /etc/default/puppet-master
sudo echo "DAEMON_OPTS=""" | sudo tee /etc/default/puppet-master
sudo ufw allow 8140/tcp
sudo systemctl restart puppetmaster.service
sudo apt-get  install -y docker.io
sudo mkdir -p /etc/puppet/code/environments/production/modules/
sudo cd /etc/puppet/code/environments/production/modules/
sudo puppet module install puppetlabs/image_build
sudo cp -r /etc/puppet/code/environments/production/modules/image_build/examples/nginx  /etc/puppet/code/environments/production/modules/
sudo cd /etc/puppet/code/environments/production/modules/nginx
sudo puppet docker build
sudo docker run -d -p 8080:80 puppet/nginx

##################### To install smtp mail server to send mail when service down#################
sudo apt-get install -y ssmtp
sudo apt-get install -y mailutils

##################### To SSH check via console server ###########################################
sudo cat > /usr/local/bin/service-monitor-1.sh <<'endmsg'
#!/bin/bash
smanager=$(ps -p1 | grep "init\|systemd" | awk '{print $4}')
for serv in docker 
do
if (( $(pgrep $serv | wc -l) > 0 ))
then
echo "$serv is running!!!"
elif [ "$smanager" == "init" ]
then
service $serv start
echo "$serv service is UP now.!" | mail -s "$serv service is DOWN and restarted now On $(hostname)" d87senarathna@gmail.com
else
systemctl start $serv
echo "$serv service is UP now.!" | mail -s "$serv service is DOWN and restarted now On $(hostname)" d87senarathna@gmail.com
fi
done

service puppet-master status | grep 'active (running)' > /dev/null 2>&1

if [ $? != 0 ]
then
        sudo service puppet-master restart > /dev/null
	echo "puppet service is UP now.!" | mail -s "puppet service is DOWN and restarted now On $(hostname)" d87senarathna@gmail.com
fi 
	echo "puppet is running!!!"
endmsg
sudo chmod +x /user/local/bin/service-monitor-1.sh

####################  Dasun Ranganath ##############################################################

