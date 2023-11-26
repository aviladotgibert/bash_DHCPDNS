#!/bin/bash

# Instalar ISC DHCP Server y BIND9
sudo apt-get update
sudo apt-get install -y isc-dhcp-server bind9

# Configurar ISC DHCP Server
echo "Configuración de ISC DHCP Server"
read -p "Introduce la interfaz de red para DHCP (ej. eth0): " dhcp_interface
read -p "Introduce el rango de direcciones DHCP (ej. 192.168.1.10 192.168.1.50): " dhcp_range

# Configurar BIND9
echo "Configuración de BIND9"
read -p "Introduce la zona DNS (ej. example.com): " dns_zone
read -p "Introduce la dirección IP del servidor DNS (ej. 192.168.1.1): " dns_ip

# Actualizar configuraciones
sudo sed -i "s/INTERFACESv4=\"\"/INTERFACESv4=\"$dhcp_interface\"/" /etc/default/isc-dhcp-server
sudo sed -i "s/^.*range.*$/range $dhcp_range;/" /etc/dhcp/dhcpd.conf
sudo sed -i "s/^.*zone.*$/zone \"$dns_zone\" { type master; file \"/etc/bind/db.$dns_zone\"; };/" /etc/bind/named.conf.local
sudo sed -i "s/^.*allow-query.*$/allow-query { any; };/" /etc/bind/named.conf.options

# Crear la zona DNS
echo "\$TTL    604800
@       IN      SOA     ns1.$dns_zone. admin.$dns_zone. (
                              3 ; Serial
                         604800 ; Refresh
                          86400 ; Retry
                        2419200 ; Expire
                         604800 ); Negative Cache TTL

@       IN      NS      ns1.$dns_zone.
@       IN      A       $dns_ip
ns1     IN      A       $dns_ip" | sudo tee /etc/bind/db.$dns_zone > /dev/null

# Reiniciar servicios
sudo service isc-dhcp-server restart
sudo service bind9 restart

echo "Configuración completada."
