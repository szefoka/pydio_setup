MYSL_ROOT_PASS=$1
PYDIO_ADMIN_PASS=$2
LOCAL_IP=$3
REMOTE_IP=$4
SHARED_DIR=$5

if [ -z "$1" ]; then
  echo MYSQL root password is missing
  exit
fi

if [ -z "$2" ]; then
  echo Pydio password is missing
  exit
fi


if [ -z "$3" ]; then
  echo Local IP address is missing
  exit
fi

if [ -z "$4" ]; then
  echo Remote IP address is missing
  exit
fi

if [ -z "$5" ]; then
  echo Remote directory path is missing
  exit
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update
debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSL_ROOT_PASS"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSL_ROOT_PASS"
apt-get -y install mysql-server-5.7
	
echo "deb https://download.pydio.com/pub/linux/debian/ xenial main" > /etc/apt/sources.list.d/pydio.list
wget -qO - https://download.pydio.com/pub/linux/debian/key/pubkey | sudo apt-key add -
sudo apt-get update

sudo apt-get install -y pydio
sudo apt-get install -y pydio-all

mysql -u root -p$1 -e "create database pydio"
mysql -u root -p$1 -e "grant all privileges on pydio.* TO 'pydio'@'localhost' identified by '$PYDIO_ADMIN_PASS';"
mysql -u root -p$1 -e "FLUSH PRIVILEGES;"

echo Pydio is running on http://$(curl -s ipinfo.io/ip)/pydio

#NFS SETUP
ssh node2 -o "StrictHostKeyChecking no" "bash -s" < ./nfs_host_setup.sh $LOCAL_IP $SHARED_DIR

./nfs_client_setup.sh $REMOTE_IP $SHARED_DIR
