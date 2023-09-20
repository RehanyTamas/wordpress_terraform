#!/bin/bash
# AUTOMATIC WORDPRESS INSTALLER IN AWS Ubuntu Server 20.04 LTS (HVM)

# Variables populated by Terraform template
db_username=${db_username}
db_user_password=${db_user_password}
db_name=${db_name}
db_RDS=${db_RDS}

# Update and upgrade packages
apt update -y
apt upgrade -y

# Install Apache and PHP
apt install -y apache2 php libapache2-mod-php php-{pear,cgi,common,curl,mbstring,gd,mysqlnd,bcmath,json,xml,intl,zip,imap,imagick}

# Install MySQL client
apt install -y mysql-client-core-8.0

# Enable Apache to start at boot
systemctl enable --now apache2

# Change ownership and permissions of directory /var/www
usermod -a -G www-data ubuntu
chown -R ubuntu:www-data /var/www
find /var/www -type d -exec chmod 755 {} \;
find /var/www -type f -exec chmod 644 {} \;

# Download and install WP-CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# Download and configure WordPress
wp core download --path=/var/www/html --allow-root
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sed -i "s/database_name_here/$db_name/g" /var/www/html/wp-config.php
sed -i "s/username_here/$db_username/g" /var/www/html/wp-config.php
sed -i "s/password_here/$db_user_password/g" /var/www/html/wp-config.php
sed -i "s/localhost/$db_RDS/g" /var/www/html/wp-config.php
cat <<EOF >> /var/www/html/wp-config.php
define( 'FS_METHOD', 'direct' );
define('WP_MEMORY_LIMIT', '128M');
define( 'AS3CF_SETTINGS', serialize( array (

    'provider' => 'aws'
) ) );
EOF

# Change ownership and permissions of /var/www/html
chown -R ubuntu:www-data /var/www/html
chmod -R 774 /var/www/html
rm /var/www/html/index.html

# Enable .htaccess files in Apache config
sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride all/' /etc/apache2/apache2.conf
a2enmod rewrite

# Restart Apache
systemctl restart apache2

echo "WordPress Installed"
