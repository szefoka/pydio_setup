export DEBIAN_FRONTEND=noninteractive
apt-get update
debconf-set-selections <<< "mysql-server mysql-server/root_password password $1"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $1"
apt-get -y install mysql-server-5.7
	
echo "deb https://download.pydio.com/pub/linux/debian/ xenial main" > /etc/apt/sources.list.d/pydio.list
wget -qO - https://download.pydio.com/pub/linux/debian/key/pubkey | sudo apt-key add -
sudo apt-get update

sudo apt-get install -y pydio
sudo apt-get install -y pydio-all

mysql -u root -p$1 -e "create database pydio"
mysql -u root -p$1 -e "grant all privileges on pydio.* TO 'pydio'@'localhost' identified by '$2';"
mysql -u root -p$1 -e "FLUSH PRIVILEGES;"

echo Pydio is running on http://$(curl -s ipinfo.io/ip)/pydio

#NFS SETUP
SHARED_DIR=/users/szefoka/measurements
ssh node2 -o "StrictHostKeyChecking no" "bash -s" < ./nfs_host_setup.sh 10.10.1.1 $SHARED_DIR

./nfs_client_setup.sh 10.10.1.2 $SHARED_DIR
