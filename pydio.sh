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


#NFS
apt-get install nfs-common 

ssh node2
apt-get update
apt-get install -y nfs-kernel-server 

#use NFSv3
sed -i 's/RPCNFSDCOUNT=8/RPCNFSDCOUNT="8 --no-nfs-version 4"/'  /etc/default/nfs-kernel-server
systemctl restart nfs-kernel-server

mkdir -p /users/szefoka/measurements
chown -R www-data:www-data /users/szefoka/measurements
chown nobody:nogroup /users/szefoka/measurements
export IP=10.10.1.1
export SHARED_DIR=/users/szefoka/measurements
echo "$SHARED_DIR    $IP(rw,sync,no_subtree_check)" > /etc/exports
sudo systemctl restart nfs-kernel-server

#node1:
mkdir -p /var/lib/pydio/data/personal/admin/node2
mount 10.10.1.2:/users/szefoka/measurements /var/lib/pydio/data/personal/admin/node2
