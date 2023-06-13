resource "null_resource" "apache" {

  provisioner "local-exec" {
    command = <<-EOT
      sudo apt-get update
      sudo apt-get install -y apache2
      sudo sed -i 's/Listen 80/Listen 8998/g' /etc/apache2/ports.conf
      sudo sed -i 's/<VirtualHost \*:80>/<VirtualHost \*:8998>/g' /etc/apache2/sites-available/000-default.conf
      sudo mkdir /var/www/html/uploads
      sudo chown www-data:www-data /var/www/html/uploads
      sudo chmod 775 /var/www/html/uploads
      sudo sh -c "echo '<Directory /var/www/html/uploads>\n\tOptions Indexes FollowSymLinks\n\tAllowOverride None\n\tRequire all granted\n</Directory>' >> /etc/apache2/apache2.conf"
      sudo systemctl restart apache2
    EOT
  }
}

resource "null_resource" "nfs" {
    provisioner "local-exec" {
        command = <<-EOT
        sudo apt-get update
        sudo apt-get install -y nfs-kernel-server
        sudo mkdir -p /mnt/public-shared
        sudo ln -s /mnt/public-shared /var/www/html/uploads
        sudo chown nobody:nogroup /mnt/public-shared
        sudo chmod 777 /mnt/public-shared
        sudo sh -c "echo '/mnt/public-shared *(rw,sync,no_subtree_check)' >> /etc/exports"
        sudo exportfs -a
        sudo systemctl restart nfs-kernel-server
        EOT
    }
}
