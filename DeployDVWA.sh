#!/bin/bash

# Update system packages
sudo apt-get update

# Install Apache, MySQL, PHP, and other required packages
sudo apt install apache2 mysql-server php php-mysqli php-gd libapache2-mod-php -y

# Start Apache and MySQL services
sudo systemctl start apache2
sudo systemctl start mysql

# Secure MySQL installation (You'll be prompted to set root password, remove anonymous users, disallow root login remotely, and remove test database)

# Assume you set your desired MySQL root password here
MYSQL_ROOT_PASSWORD='P@ssw0rd1234'

# Apply security improvements equivalent to what mysql_secure_installation does
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"
sudo mysql -e "DELETE FROM mysql.user WHERE User=''"
sudo mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
sudo mysql -e "DROP DATABASE IF EXISTS test"
sudo mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"
sudo mysql -e "FLUSH PRIVILEGES"


# Download DVWA
cd /var/www/html
rm index.html
sudo git clone https://github.com/digininja/DVWA.git
sudo chown -R www-data:www-data DVWA

# Copy DVWA config
sudo cp DVWA/config/config.inc.php.dist DVWA/config/config.inc.php

# Configure DVWA database
sudo mysql -u root -pP@ssw0rd1234 -e "CREATE DATABASE dvwa; CREATE USER 'dvwa'@'localhost' IDENTIFIED BY 'P@ssw0rd1234'; GRANT ALL PRIVILEGES ON dvwa.* TO 'dvwa'@'localhost'; FLUSH PRIVILEGES;"

 Edit the DVWA config file - set up database connection
sudo sed -i "s/\[ 'db_password' \] = 'p@ssw0rd';/\[ 'db_password' \] = 'P@ssw0rd1234';/g" /var/www/html/DVWA/config/config.inc.php




# Configre PHP
cd /etc/php/8.1/apache2/
sudo sed -i 's/allow_url_include = Off/allow_url_include = On/g' php.ini
sudo sed -i 's/display_errors = Off/display_errors = On/g' php.ini


# Restart Apache to apply changes
sudo systemctl restart apache2
echo "DVWA is now deployed. Access it at http://localhost/DVWA/setup.php to complete the setup."
