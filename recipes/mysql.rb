#
# Cookbook Name:: zabbix
# Recipe:: mysql
#
# Copyright 2013, bageljp
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'zabbix::agent'

case node["platform_family"]
when "rhel"
  percona_rpm = File.basename(node['zabbix']['mysql']['url'])

  remote_file "/usr/local/src/#{percona_rpm}" do
    owner "root"
    group "root"
    mode 00644
    source "#{node['zabbix']['mysql']['url']}"
  end

  package "percona-zabbix-templates" do
    action :install
    provider Chef::Provider::Package::Rpm
    source "/usr/local/src/#{percona_rpm}"
  end
end

template '/etc/zabbix/zabbix_agentd.d/userparameter_percona_mysql.conf' do
  owner 'root'
  group 'root'
  mode 00644
  notifies :restart, 'service[zabbix-agent]'
end

template '/var/lib/zabbix/percona/scripts/ss_get_mysql_stats.php' do
  owner 'root'
  group 'root'
  mode 00755
end

