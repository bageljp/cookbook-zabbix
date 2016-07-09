#
# Cookbook Name:: zabbix
# Recipe:: postfix
#
# Copyright 2013, bageljp
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'zabbix::agent'

%w(
  postfix-perl-scripts
  logcheck
).each do |pkg|
  package pkg do
    options "--enablerepo=epel"
    action :install
  end
end

template '/etc/zabbix/zabbix_agentd.d/userparameter_postfix.conf' do
  owner 'root'
  group 'root'
  mode 00644
  notifies :restart, 'service[zabbix-agent]'
end

template '/etc/zabbix/externalscripts/zabbix-postfix.sh' do
  owner 'root'
  group 'root'
  mode 00755
end

cookbook_file '/etc/cron.d/logcheck' do
  action :delete
end

template '/etc/cron.d/zabbix_postfix' do
  owner 'root'
  group 'root'
  mode 00644
  source 'cron_postfix.erb'
end
