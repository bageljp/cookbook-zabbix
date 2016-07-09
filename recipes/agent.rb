#
# Cookbook Name:: zabbix
# Recipe:: agent
#
# Copyright 2013, bageljp
#
# All rights reserved - Do Not Redistribute
#

include_recipe "zabbix"

%w(
  zabbix-sender
  zabbix-get
  zabbix-agent
).each do |pkg|
  package pkg
end

template "/etc/zabbix/zabbix_agentd.conf" do
  owner "root"
  group "root"
  mode 00644
  source "zabbix_agentd_#{node['zabbix']['version']['major']}.conf.erb"
  notifies :restart, "service[zabbix-agent]"
end

template "/etc/logrotate.d/zabbix-agent" do
  owner "root"
  group "root"
  mode 00644
  source "zabbix-agent_logrotate.erb"
end

template "/etc/sysconfig/zabbix-agent" do
  owner "root"
  group "root"
  mode 00644
  source "zabbix-agent_sysconfig.erb"
end

directory "/etc/zabbix/externalscripts" do
  owner "root"
  group "root"
  mode 00755
end

%w(
  zapache
  ssl-cert-check
).each do |f|
  cookbook_file "/etc/zabbix/externalscripts/#{f}" do
    owner "root"
    group "root"
    mode 00755
    source "externalscripts/#{f}"
  end
end

service "zabbix-agent" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

