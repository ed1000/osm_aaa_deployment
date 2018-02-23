#!/bin/bash

MYSQL_ROOT_PASSWORD='mysql_root_password'
KEYSTONE_DB_PASSWORD='keystone_db_password'
KEYSTONE_ADMIN_PASSWORD='admin_password'

KEYSTONE_SO_PASSWORD='so_password'
KEYSTONE_RO_PASSWORD='ro_password'
KEYSTONE_VCA_PASSWORD='vca_password'

USER_5GINFIRE_PASSWORD='user_5ginfire_password'
ADMIN_5GINFIRE_PASSWORD='admin_5ginfire_password'

KEYSTONE_AUTHENTICATION_USERNAME='authentication'
KEYSTONE_AUTHENTICATION_PASSWORD='authentication_password'

KEYSTONE_AUTHORIZATION_USERNAME='authorization'
KEYSTONE_AUTHORIZATION_PASSWORD='authorization_password'

KEYSTONE_SERVICE_PROJECT='service'
KEYSTONE_ADMIN_PROJECT='admin'

KEYSTONE_USER_DOMAIN_NAME='Default'
KEYSTONE_PROJECT_DOMAIN_NAME='Default'

EXTERNAL_MAPPING_VERIFICATION='False'
EXTERNAL_AUTHENTICATOR_IP=''

AUTHORIZATION_POLICY_FILE='/home/ubuntu/authorization/example_policy.json'

REDIS_URL='localhost'
REDIS_PORT='6379'

SERVICE_ROLE='admin'
SERVICE_PROJECT='service'

echo '>>>>>> Creating Keystone LXC Container'
lxc launch ubuntu:16.04 keystone

echo '>>>>>> Creating Authentication LXC Container'
lxc launch ubuntu:16.04 authentication

echo '>>>>>> Creating Authorization LXC Container'
lxc launch ubuntu:16.04 authorization

echo '>>>>>> Creating Accounting LXC Container'
lxc launch ubuntu:16.04 accounting

echo '>>>>>> Creating Keystone Configuration file from template'
cp templates/configure_keystone.sh.tmpl configure_keystone.sh
sed -i "s/^MYSQL_ROOT_PASSWORD=.*/MYSQL_ROOT_PASSWORD='$MYSQL_ROOT_PASSWORD'/" configure_keystone.sh
sed -i "s/^KEYSTONE_DB_PASSWORD=.*/KEYSTONE_DB_PASSWORD='$KEYSTONE_DB_PASSWORD'/" configure_keystone.sh
sed -i "s/^ADMIN_PASSWORD=.*/ADMIN_PASSWORD='$KEYSTONE_ADMIN_PASSWORD'/" configure_keystone.sh
sed -i "s/^SO_PASSWORD=.*/SO_PASSWORD='$KEYSTONE_SO_PASSWORD'/" configure_keystone.sh
sed -i "s/^RO_PASSWORD=.*/RO_PASSWORD='$KEYSTONE_RO_PASSWORD'/" configure_keystone.sh
sed -i "s/^VCA_PASSWORD=.*/VCA_PASSWORD='$KEYSTONE_VCA_PASSWORD'/" configure_keystone.sh
sed -i "s/^USER_5GINFIRE_PASSWORD=.*/USER_5GINFIRE_PASSWORD='$USER_5GINFIRE_PASSWORD'/" configure_keystone.sh
sed -i "s/^ADMIN_5GINFIRE_PASSWORD=.*/ADMIN_5GINFIRE_PASSWORD='$ADMIN_5GINFIRE_PASSWORD'/" configure_keystone.sh
sed -i "s/^AUTHENTICATION_PASSWORD=.*/AUTHENTICATION_PASSWORD='$KEYSTONE_AUTHENTICATION_PASSWORD'/" configure_keystone.sh
sed -i "s/^AUTHORIZATION_PASSWORD=.*/AUTHORIZATION_PASSWORD='$KEYSTONE_AUTHORIZATION_PASSWORD'/" configure_keystone.sh

echo '>>>>>> Running Keystone Configuration Script'
lxc file push configure_keystone.sh keystone/root/
lxc exec keystone -- ./configure_keystone.sh
lxc exec keystone -- rm configure_keystone.sh

rm configure_keystone.sh

KEYSTONE_LXC_IP=`lxc list | grep keystone | awk '{ print $6 }'`
AUTHENTICATION_LXC_IP=`lxc list | grep authentication | awk '{ print $6 }'`
AUTHORIZATION_LXC_IP=`lxc list | grep authorization | awk '{ print $6 }'`
ACCOUNTING_LXC_IP=`lxc list | grep accounting | awk '{ print $6 }'`

echo '>>>>>> Creating Authentication Configuration file from template'
cp templates/configure_authentication.sh.tmpl configure_authentication.sh
sed -i "s/^KEYSTONE_LXC_IP=.*/KEYSTONE_LXC_IP='$KEYSTONE_LXC_IP'/" configure_authentication.sh
sed -i "s/^AUTHORIZATION_IP=.*/AUTHORIZATION_IP='$AUTHORIZATION_LXC_IP'/" configure_authentication.sh
sed -i "s/^ACCOUNTING_IP=.*/ACCOUNTING_IP='$ACCOUNTING_LXC_IP'/" configure_authentication.sh

sed -i "s/^KEYSTONE_USERNAME=.*/KEYSTONE_USERNAME='$KEYSTONE_AUTHENTICATION_USERNAME'/" configure_authentication.sh
sed -i "s/^KEYSTONE_PASSWORD=.*/KEYSTONE_PASSWORD='$KEYSTONE_AUTHENTICATION_PASSWORD'/" configure_authentication.sh
sed -i "s/^KEYSTONE_PROJECT=.*/KEYSTONE_PROJECT='$KEYSTONE_SERVICE_PROJECT'/" configure_authentication.sh
sed -i "s/^KEYSTONE_ADMIN_PROJECT=.*/KEYSTONE_ADMIN_PROJECT='$KEYSTONE_ADMIN_PROJECT'/" configure_authentication.sh
sed -i "s/^KEYSTONE_SERVICE_PROJECT=.*/KEYSTONE_SERVICE_PROJECT='$KEYSTONE_SERVICE_PROJECT'/" configure_authentication.sh
sed -i "s/^KEYSTONE_USER_DOMAIN_NAME=.*/KEYSTONE_USER_DOMAIN_NAME='$KEYSTONE_USER_DOMAIN_NAME'/" configure_authentication.sh
sed -i "s/^KEYSTONE_PROJECT_DOMAIN_NAME=.*/KEYSTONE_PROJECT_DOMAIN_NAME='$KEYSTONE_PROJECT_DOMAIN_NAME'/" configure_authentication.sh

sed -i "s/^EXTERNAL_MAPPING_VERIFICATION=.*/EXTERNAL_MAPPING_VERIFICATION='$EXTERNAL_MAPPING_VERIFICATION'/" configure_authentication.sh
sed -i "s/^EXTERNAL_AUTHENTICATOR_IP=.*/EXTERNAL_AUTHENTICATOR_IP='$EXTERNAL_AUTHENTICATOR_IP'/" configure_authentication.sh

echo '>>>>>> Running Authentication Configuration Script'
lxc file push configure_authentication.sh authentication/root/
lxc exec authentication -- ./configure_authentication.sh
lxc exec authentication -- rm configure_authentication.sh

rm configure_authentication.sh

echo '>>>>>> Creating Authorization Configuration file from template'
cp templates/configure_authorization.sh.tmpl configure_authorization.sh
sed -i "s/^KEYSTONE_LXC_IP=.*/KEYSTONE_LXC_IP='$KEYSTONE_LXC_IP'/" configure_authorization.sh
sed -i "s/^AUTHENTICATION_IP=.*/AUTHENTICATION_IP='$AUTHENTICATION_LXC_IP'/" configure_authorization.sh
sed -i "s/^ACCOUNTING_IP=.*/ACCOUNTING_IP='$ACCOUNTING_LXC_IP'/" configure_authorization.sh

sed -i "s/^AUTHENTICATION_USERNAME=.*/AUTHENTICATION_USERNAME='$KEYSTONE_AUTHORIZATION_USERNAME'/" configure_authorization.sh
sed -i "s/^AUTHENTICATION_PASSWORD=.*/AUTHENTICATION_PASSWORD='$KEYSTONE_AUTHORIZATION_PASSWORD'/" configure_authorization.sh

sed -i "s%^AUTHORIZATION_POLICY_FILE=.*%AUTHORIZATION_POLICY_FILE='$AUTHORIZATION_POLICY_FILE'%" configure_authorization.sh
sed -i "s/^REDIS_URL=.*/REDIS_URL='$REDIS_URL'/" configure_authorization.sh
sed -i "s/^REDIS_PORT=.*/REDIS_PORT='$REDIS_PORT'/" configure_authorization.sh

sed -i "s/^SERVICE_ROLE=.*/SERVICE_ROLE='$SERVICE_ROLE'/" configure_authorization.sh
sed -i "s/^SERVICE_PROJECT=.*/SERVICE_PROJECT='$SERVICE_PROJECT'/" configure_authorization.sh

sed -i "s/^KEYSTONE_USERNAME=.*/KEYSTONE_USERNAME='$KEYSTONE_AUTHORIZATION_USERNAME'/" configure_authorization.sh
sed -i "s/^KEYSTONE_PASSWORD=.*/KEYSTONE_PASSWORD='$KEYSTONE_AUTHORIZATION_PASSWORD'/" configure_authorization.sh
sed -i "s/^KEYSTONE_PROJECT=.*/KEYSTONE_PROJECT='$KEYSTONE_SERVICE_PROJECT'/" configure_authorization.sh
sed -i "s/^KEYSTONE_ADMIN_PROJECT=.*/KEYSTONE_ADMIN_PROJECT='$KEYSTONE_ADMIN_PROJECT'/" configure_authorization.sh
sed -i "s/^KEYSTONE_SERVICE_PROJECT=.*/KEYSTONE_SERVICE_PROJECT='$KEYSTONE_SERVICE_PROJECT'/" configure_authorization.sh
sed -i "s/^KEYSTONE_USER_DOMAIN_NAME=.*/KEYSTONE_USER_DOMAIN_NAME='$KEYSTONE_USER_DOMAIN_NAME'/" configure_authorization.sh
sed -i "s/^KEYSTONE_PROJECT_DOMAIN_NAME=.*/KEYSTONE_PROJECT_DOMAIN_NAME='$KEYSTONE_PROJECT_DOMAIN_NAME'/" configure_authorization.sh

echo '>>>>>> Running Authorization Configuration Script'
lxc file push configure_authorization.sh authorization/root/
lxc exec authorization -- ./configure_authorization.sh
lxc exec authorization -- rm configure_authorization.sh

rm configure_authorization.sh
