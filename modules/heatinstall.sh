#!/bin/bash
#
# Instalador desatendido para Openstack Havana sobre CENTOS
# Reynaldo R. Martinez P.
# E-Mail: TigerLinux@Gmail.com
# Octubre del 2013
#
# Script de instalacion y preparacion de Heat
#

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

if [ -f ./configs/main-config.rc ]
then
	source ./configs/main-config.rc
	mkdir -p /etc/openstack-control-script-config
else
	echo "No puedo acceder a mi archivo de configuración"
	echo "Revise que esté ejecutando el instalador/módulos en el directorio correcto"
	echo "Abortando !!!!."
	echo ""
	exit 0
fi

if [ -f /etc/openstack-control-script-config/db-installed ]
then
	echo ""
	echo "Proceso de BD verificado - continuando"
	echo ""
else
	echo ""
	echo "Este módulo depende de que el proceso de base de datos"
	echo "haya sido exitoso, pero aparentemente no lo fue"
	echo "Abortando el módulo"
	echo ""
	exit 0
fi

if [ -f /etc/openstack-control-script-config/keystone-installed ]
then
	echo ""
	echo "Proceso principal de Keystone verificado - continuando"
	echo ""
else
	echo ""
	echo "Este módulo depende del proceso principal de keystone"
	echo "pero no se pudo verificar que dicho proceso haya sido"
	echo "completado exitosamente - se abortará el proceso"
	echo ""
	exit 0
fi

if [ -f /etc/openstack-control-script-config/heat-installed ]
then
	echo ""
	echo "Este módulo ya fue ejecutado de manera exitosa - saliendo"
	echo ""
	exit 0
fi

echo "keystone keystone/auth-token password $SERVICE_TOKEN" > /tmp/keystone-seed.txt
echo "keystone keystone/admin-password password $keystoneadminpass" >> /tmp/keystone-seed.txt
echo "keystone keystone/admin-password-confirm password $keystoneadminpass" >> /tmp/keystone-seed.txt
echo "keystone keystone/admin-user string admin" >> /tmp/keystone-seed.txt
echo "keystone keystone/admin-tenant-name string $keystoneadminuser" >> /tmp/keystone-seed.txt
echo "keystone keystone/region-name string $endpointsregion" >> /tmp/keystone-seed.txt
echo "keystone keystone/endpoint-ip string $keystonehost" >> /tmp/keystone-seed.txt
echo "keystone keystone/register-endpoint boolean false" >> /tmp/keystone-seed.txt
echo "keystone keystone/admin-email string $keystoneadminuseremail" >> /tmp/keystone-seed.txt
echo "keystone keystone/admin-role-name string $keystoneadmintenant" >> /tmp/keystone-seed.txt
echo "keystone keystone/configure_db boolean false" >> /tmp/keystone-seed.txt
echo "keystone keystone/create-admin-tenant boolean false" >> /tmp/keystone-seed.txt

debconf-set-selections /tmp/keystone-seed.txt

echo "glance-common glance/admin-password password $glancepass" > /tmp/glance-seed.txt
echo "glance-common glance/auth-host string $keystonehost" >> /tmp/glance-seed.txt
echo "glance-api glance/keystone-ip string $keystonehost" >> /tmp/glance-seed.txt
echo "glance-common glance/paste-flavor select keystone" >> /tmp/glance-seed.txt
echo "glance-common glance/admin-tenant-name string $keystoneadmintenant" >> /tmp/glance-seed.txt
echo "glance-api glance/endpoint-ip string $glancehost" >> /tmp/glance-seed.txt
echo "glance-api glance/region-name string $endpointsregion" >> /tmp/glance-seed.txt
echo "glance-api glance/register-endpoint boolean false" >> /tmp/glance-seed.txt
echo "glance-common glance/admin-user	string $keystoneadminuser" >> /tmp/glance-seed.txt
echo "glance-common glance/configure_db boolean false" >> /tmp/glance-seed.txt
# Nuevos para Havana
echo "glance-common glance/rabbit_host string $messagebrokerhost" >> /tmp/glance-seed.txt
echo "glance-common glance/rabbit_password password $brokerpass" >> /tmp/glance-seed.txt
echo "glance-common glance/rabbit_userid string $brokeruser" >> /tmp/glance-seed.txt

debconf-set-selections /tmp/glance-seed.txt

echo "cinder-common cinder/admin-password password $cinderpass" > /tmp/cinder-seed.txt
echo "cinder-api cinder/region-name string $endpointsregion" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/configure_db boolean false" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/admin-tenant-name string $keystoneadmintenant" >> /tmp/cinder-seed.txt
echo "cinder-api cinder/register-endpoint boolean false" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/auth-host string $keystonehost" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/start_services boolean false" >> /tmp/cinder-seed.txt
echo "cinder-api cinder/endpoint-ip string $cinderhost" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/volume_group string cinder-volumes" >> /tmp/cinder-seed.txt
echo "cinder-api cinder/keystone-ip string $keystonehost" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/admin-user string $keystoneadminuser" >> /tmp/cinder-seed.txt
# Nuevos para Havana
echo "cinder-common cinder/rabbit_password password $brokerpass" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/rabbit_host string $messagebrokerhost" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/rabbit_userid string $brokeruser" >> /tmp/cinder-seed.txt

debconf-set-selections /tmp/cinder-seed.txt

echo "neutron-common neutron/admin-password password $keystoneadminpass" > /tmp/neutron-seed.txt
echo "neutron-metadata-agent neutron/admin-password password $keystoneadminpass" >> /tmp/neutron-seed.txt
echo "neutron-server neutron/keystone-ip string $keystonehost" >> /tmp/neutron-seed.txt
echo "neutron-plugin-openvswitch neutron-plugin-openvswitch/local_ip string $neutronhost" >> /tmp/neutron-seed.txt
echo "neutron-plugin-openvswitch neutron-plugin-openvswitch/configure_db boolean false" >> /tmp/neutron-seed.txt
echo "neutron-metadata-agent neutron/region-name string $endpointsregion" >> /tmp/neutron-seed.txt
echo "neutron-server neutron/region-name string $endpointsregion" >> /tmp/neutron-seed.txt
echo "neutron-server neutron/register-endpoint boolean false" >> /tmp/neutron-seed.txt
echo "neutron-plugin-openvswitch neutron-plugin-openvswitch/tenant_network_type select vlan" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/admin-user string $keystoneadminuser" >> /tmp/neutron-seed.txt
echo "neutron-metadata-agent neutron/admin-user string $keystoneadminuser" >> /tmp/neutron-seed.txt
echo "neutron-plugin-openvswitch neutron-plugin-openvswitch/tunnel_id_ranges string 0" >> /tmp/neutron-seed.txt
echo "neutron-plugin-openvswitch neutron-plugin-openvswitch/enable_tunneling boolean false" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/auth-host string $keystonehost" >> /tmp/neutron-seed.txt
echo "neutron-metadata-agent neutron/auth-host string $keystonehost" >> /tmp/neutron-seed.txt
echo "neutron-server neutron/endpoint-ip string $neutronhost" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/admin-tenant-name string $keystoneadmintenant" >> /tmp/neutron-seed.txt
echo "neutron-metadata-agent neutron/admin-tenant-name string $keystoneadmintenant" >> /tmp/neutron-seed.txt
echo "openswan openswan/install_x509_certificate boolean false" >> /tmp/neutron-seed.txt
#
# Nuevo para Havana
echo "neutron-common neutron/rabbit_password password $brokerpass" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/rabbit_userid string $brokeruser" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/rabbit_host string $messagebrokerhost" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/tunnel_id_ranges string 1" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/tenant_network_type select vlan" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/enable_tunneling boolean false" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/configure_db boolean false" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/plugin-select select OpenVSwitch" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/local_ip string $neutronhost" >> /tmp/neutron-seed.txt

debconf-set-selections /tmp/neutron-seed.txt

echo "nova-common nova/admin-password password $keystoneadminpass" > /tmp/nova-seed.txt
echo "nova-common nova/configure_db boolean false" >> /tmp/nova-seed.txt
echo "nova-consoleproxy nova-consoleproxy/daemon_type select spicehtml5" >> /tmp/nova-seed.txt
echo "nova-common nova/rabbit-host string 127.0.0.1" >> /tmp/nova-seed.txt
echo "nova-api nova/register-endpoint boolean false" >> /tmp/nova-seed.txt
echo "nova-common nova/my-ip string $novahost" >> /tmp/nova-seed.txt
echo "nova-common nova/start_services boolean false" >> /tmp/nova-seed.txt
echo "nova-common nova/admin-user string $keystoneadminuser" >> /tmp/nova-seed.txt
echo "nova-api nova/region-name string $endpointsregion" >> /tmp/nova-seed.txt
echo "nova-common nova/admin-tenant-name string $keystoneadmintenant" >> /tmp/nova-seed.txt
echo "nova-api nova/endpoint-ip string $novahost" >> /tmp/nova-seed.txt
echo "nova-api nova/keystone-ip string $keystonehost" >> /tmp/nova-seed.txt
echo "nova-common nova/active-api multiselect ec2, osapi_compute, metadata" >> /tmp/nova-seed.txt
echo "nova-common nova/auth-host string $keystonehost" >> /tmp/nova-seed.txt
#
# Nuevo para Havana
echo "nova-common nova/rabbit_host string $messagebrokerhost" >> /tmp/nova-seed.txt
echo "nova-common nova/rabbit_password password $brokerpass" >> /tmp/nova-seed.txt
echo "nova-common nova/rabbit_userid string $brokeruser" >> /tmp/nova-seed.txt

debconf-set-selections /tmp/nova-seed.txt


echo ""
echo "Instalando paquetes para Heat"

aptitude -y install heat-api heat-api-cfn heat-engine

echo "Listo"
echo ""

source $keystone_admin_rc_file

echo ""
echo "Configurando Heat"
echo ""

# Temporal - aparentemente el paquete no instala el api-paste.ini

echo "# Heat api-paste.ini" >> /etc/heat/api-paste.ini 

openstack-config --set /etc/heat/api-paste.ini "filter:authtoken" paste.filter_factory "heat.common.auth_token:filter_factory"
openstack-config --set /etc/heat/api-paste.ini "filter:authtoken" auth_host $keystonehost
openstack-config --set /etc/heat/api-paste.ini "filter:authtoken" auth_port 35357
openstack-config --set /etc/heat/api-paste.ini "filter:authtoken" auth_protocol http
openstack-config --set /etc/heat/api-paste.ini "filter:authtoken" admin_tenant_name $keystoneservicestenant
openstack-config --set /etc/heat/api-paste.ini "filter:authtoken" admin_user $heatuser
openstack-config --set /etc/heat/api-paste.ini "filter:authtoken" admin_password $heatpass

echo "# Heat Main Config" >> /etc/heat/heat.conf

case $dbflavor in
"mysql")
	openstack-config --set /etc/heat/heat.conf database connection mysql://$heatdbuser:$heatdbpass@$dbbackendhost:$mysqldbport/$heatdbname
	openstack-config --set /etc/heat/heat.conf DEFAULT sql_connection mysql://$heatdbuser:$heatdbpass@$dbbackendhost:$mysqldbport/$heatdbname
	;;
"postgres")
	openstack-config --set /etc/heat/heat.conf database connection postgresql://$heatdbuser:$heatdbpass@$dbbackendhost:$psqldbport/$heatdbname
	openstack-config --set /etc/heat/heat.conf DEFAULT sql_connection postgresql://$heatdbuser:$heatdbpass@$dbbackendhost:$psqldbport/$heatdbname
	;;
esac

openstack-config --set /etc/heat/heat.conf DEFAULT host $heathost
openstack-config --set /etc/heat/heat.conf DEFAULT debug false
openstack-config --set /etc/heat/heat.conf DEFAULT verbose false
openstack-config --set /etc/heat/heat.conf DEFAULT log_dir /var/log/heat

openstack-config --set /etc/heat/heat.conf keystone_authtoken admin_tenant_name $keystoneservicestenant
openstack-config --set /etc/heat/heat.conf keystone_authtoken admin_user $heatuser
openstack-config --set /etc/heat/heat.conf keystone_authtoken admin_password $heatpass
openstack-config --set /etc/heat/heat.conf keystone_authtoken auth_host $keystonehost
openstack-config --set /etc/heat/heat.conf keystone_authtoken auth_port 35357
openstack-config --set /etc/heat/heat.conf keystone_authtoken auth_protocol http
openstack-config --set /etc/heat/heat.conf keystone_authtoken auth_uri http://$keystonehost:5000/v2.0/
openstack-config --set /etc/heat/heat.conf keystone_authtoken signing_dir /tmp/keystone-signing-heat

openstack-config --set /etc/heat/heat.conf DEFAULT control_exchange openstack

case $brokerflavor in
"qpid")
        openstack-config --set /etc/heat/heat.conf DEFAULT rpc_backend heat.openstack.common.rpc.impl_qpid
        openstack-config --set /etc/heat/heat.conf DEFAULT qpid_reconnect_interval_min 0
        openstack-config --set /etc/heat/heat.conf DEFAULT qpid_username $brokeruser
        openstack-config --set /etc/heat/heat.conf DEFAULT qpid_tcp_nodelay True
        openstack-config --set /etc/heat/heat.conf DEFAULT qpid_protocol tcp
        openstack-config --set /etc/heat/heat.conf DEFAULT qpid_hostname $messagebrokerhost
        openstack-config --set /etc/heat/heat.conf DEFAULT qpid_password $brokerpass
        openstack-config --set /etc/heat/heat.conf DEFAULT qpid_port 5672
        openstack-config --set /etc/heat/heat.conf DEFAULT qpid_topology_version 1
        ;;

"rabbitmq")
        openstack-config --set /etc/heat/heat.conf DEFAULT rpc_backend heat.openstack.common.rpc.impl_kombu
        openstack-config --set /etc/heat/heat.conf DEFAULT rabbit_host $messagebrokerhost
        openstack-config --set /etc/heat/heat.conf DEFAULT rabbit_userid $brokeruser
        openstack-config --set /etc/heat/heat.conf DEFAULT rabbit_password $brokerpass
        openstack-config --set /etc/heat/heat.conf DEFAULT rabbit_port 5672
        openstack-config --set /etc/heat/heat.conf DEFAULT rabbit_use_ssl false
        openstack-config --set /etc/heat/heat.conf DEFAULT rabbit_virtual_host $brokervhost
        ;;
esac

echo ""
echo "Heat Configurado"
echo ""

#
# Se aprovisiona la base de datos
echo ""
echo "Aprovisionando/inicializando BD de HEAT"
echo ""
heat-manage db_sync

echo ""
echo "Listo"
echo ""

echo ""
echo "Aplicando reglas de IPTABLES"

iptables -A INPUT -p tcp -m multiport --dports 8000,8004 -j ACCEPT
/etc/init.d/iptables-persistent save

echo "Listo"

echo ""
echo "Activando Servicios"
echo ""

/etc/init.d/heat-api restart
/etc/init.d/heat-api-cfn restart
/etc/init.d/heat-engine restart
chkconfig heat-api on
chkconfig heat-api-cfn on
chkconfig heat-engine on

testheat=`dpkg -l heat-api 2>/dev/null|tail -n 1|grep -ci ^ii`
if [ $testheat == "0" ]
then
	echo ""
	echo "Falló la instalación de heat - abortando el resto de la instalación"
	echo ""
	exit 0
else
	date > /etc/openstack-control-script-config/heat-installed
	date > /etc/openstack-control-script-config/heat
fi


echo ""
echo "Heat Instalado"
echo ""


