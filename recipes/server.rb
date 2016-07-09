#
# Cookbook Name:: zabbix
# Recipe:: server
#
# Copyright 2013, bageljp
#
# All rights reserved - Do Not Redistribute
#

include_recipe "zabbix"

case node['zabbix']['server']['web']
when "apache"
  %w(
    httpd24
    httpd24-devel
    mod24_ssl
    php55
    php55-devel
    php55-mysqlnd
    php55-bcmath
  ).each do |pkg|
    package pkg
  end
when "nginx"
  %w(
    nginx
    php55
    php55-devel
    php55-mysqlnd
    php55-bcmath
    php55-fpm
  ).each do |pkg|
    package pkg
  end
end

%w(
  zabbix
  zabbix-web-mysql
  zabbix-web
  zabbix-web-japanese
  zabbix-server-mysql
  zabbix-server
).each do |pkg|
  package pkg
end

template "/etc/zabbix/zabbix_server.conf" do
  owner "root"
  group "root"
  mode 00644
  source "zabbix_server_#{node['zabbix']['version']['major']}.conf.erb"
  notifies :restart, "service[zabbix-server]"
end

template "/etc/logrotate.d/zabbix-server" do
  owner "root"
  group "root"
  mode 00644
  source "zabbix-server_logrotate.erb"
end

directory "/etc/zabbix/web" do
  owner "#{node['zabbix']['web']['user']}"
  group "#{node['zabbix']['web']['group']}"
  mode 00750
end

template "/etc/zabbix/web/zabbix.conf.php" do
  owner "#{node['zabbix']['web']['user']}"
  group "#{node['zabbix']['web']['group']}"
  source "zabbix.conf_#{node['zabbix']['version']['major']}.php.erb"
  mode 00644
end

bash "create database" do
  user "root"
  group "root"
  code <<-EOC
    mysql -u #{node['zabbix']['server']['db']['admin']['user']} -p#{node['zabbix']['server']['db']['admin']['password']} -e "create database #{node['zabbix']['server']['db']['name']} character set utf8 collate utf8_bin;"
  EOC
  not_if "mysql -u #{node['zabbix']['server']['db']['admin']['user']} -p#{node['zabbix']['server']['db']['admin']['password']} -s -e 'show databases;' | grep #{node['zabbix']['server']['db']['name']}"
end

bash "create user" do
  user "root"
  group "root"
  code <<-EOC
    mysql -u #{node['zabbix']['server']['db']['admin']['user']} -p#{node['zabbix']['server']['db']['admin']['password']} -e "grant all privileges on #{node['zabbix']['server']['db']['name']}.* to #{node['zabbix']['server']['db']['user']}@localhost identified by '#{node['zabbix']['server']['db']['password']}';"
  EOC
  not_if "mysql -u #{node['zabbix']['server']['db']['admin']['user']} -p#{node['zabbix']['server']['db']['admin']['password']} -e 'show grants for #{node['zabbix']['server']['db']['user']}@localhost;' | grep #{node['zabbix']['server']['db']['user']}@localhost"
end

bash "create schema" do
  user "root"
  group "root"
  cwd "/usr/share/doc/zabbix-server-mysql-#{node['zabbix']['version']['major']}.#{node['zabbix']['version']['minor']}/create"
  code <<-EOC
    mysql -u #{node['zabbix']['server']['db']['user']} -p#{node['zabbix']['server']['db']['password']} #{node['zabbix']['server']['db']['name']}  < schema.sql 
    mysql -u #{node['zabbix']['server']['db']['user']} -p#{node['zabbix']['server']['db']['password']} #{node['zabbix']['server']['db']['name']} < images.sql
    mysql -u #{node['zabbix']['server']['db']['user']} -p#{node['zabbix']['server']['db']['password']} #{node['zabbix']['server']['db']['name']} < data.sql
  EOC
  not_if "mysql -u #{node['zabbix']['server']['db']['user']} -p#{node['zabbix']['server']['db']['password']} #{node['zabbix']['server']['db']['name']} -e 'select * from item_discovery where itemdiscoveryid = 1;' | grep itemdiscoveryid"
end

service "zabbix-server" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end
