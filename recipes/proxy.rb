#
# Cookbook Name:: zabbix
# Recipe:: proxy
#
# Copyright 2013, bageljp
#
# All rights reserved - Do Not Redistribute
#

include_recipe "zabbix"

%w(
  zabbix
  zabbix-proxy-mysql
  zabbix-proxy
).each do |pkg|
  package pkg
end

template "/etc/zabbix/zabbix_proxy.conf" do
  owner "root"
  group "root"
  mode 00644
  source "zabbix_proxy_#{node['zabbix']['version']['major']}.conf.erb"
  notifies :restart, "service[zabbix-proxy]"
end

template "/etc/logrotate.d/zabbix-proxy" do
  owner "root"
  group "root"
  mode 00644
  source "zabbix-proxy_logrotate.erb"
end

bash "create database" do
  user "root"
  group "root"
  code <<-EOC
    mysql -u #{node['zabbix']['proxy']['db']['admin']['user']} -p#{node['zabbix']['proxy']['db']['admin']['password']} -e "create database #{node['zabbix']['proxy']['db']['name']} character set utf8 collate utf8_bin;"
  EOC
  not_if "mysql -u #{node['zabbix']['proxy']['db']['admin']['user']} -p#{node['zabbix']['proxy']['db']['admin']['password']} -s -e 'show databases;' | grep -q #{node['zabbix']['proxy']['db']['name']}"
end

bash "create user" do
  user "root"
  group "root"
  code <<-EOC
    mysql -u #{node['zabbix']['proxy']['db']['admin']['user']} -p#{node['zabbix']['proxy']['db']['admin']['password']} -e "grant all privileges on #{node['zabbix']['proxy']['db']['name']}.* to #{node['zabbix']['proxy']['db']['user']}@localhost identified by '#{node['zabbix']['proxy']['db']['password']}';"
  EOC
  not_if "mysql -u #{node['zabbix']['proxy']['db']['admin']['user']} -p#{node['zabbix']['proxy']['db']['admin']['password']} -e 'show grants for #{node['zabbix']['proxy']['db']['user']}@localhost;' | grep -q #{node['zabbix']['proxy']['db']['user']}@localhost"
end

bash "create schema" do
  user "root"
  group "root"
  cwd "/usr/share/doc/zabbix-proxy-mysql-#{node['zabbix']['version']['major']}.#{node['zabbix']['version']['minor']}/create"
  code <<-EOC
    mysql -u #{node['zabbix']['proxy']['db']['user']} -p#{node['zabbix']['proxy']['db']['password']} #{node['zabbix']['proxy']['db']['name']} < schema.sql 
  EOC
  not_if "mysql -u #{node['zabbix']['proxy']['db']['user']} -p#{node['zabbix']['proxy']['db']['password']} #{node['zabbix']['proxy']['db']['name']} -e 'select * from proxy_autoreg_host;' | grep -q #{node['zabbix']['proxy']['hostname']}"
end

service "zabbix-proxy" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end
