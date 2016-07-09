#
# Cookbook Name:: zabbix
# Recipe:: default
#
# Copyright 2013, bageljp
#
# All rights reserved - Do Not Redistribute
#

case node["platform_family"]
when "rhel"
  remote_file "/usr/local/src/#{node['zabbix']['repo']['file']}" do
    owner "root"
    group "root"
    mode 00644
    source "#{node['zabbix']['repo']['url']}"
    #notifies :install, "rpm_package[zabbix-release]", :immediately
  end

  #rpm_package "zabbix-release" do
  #  action :nothing
  #  source "/usr/local/src/#{node['zabbix']['repo']['file']}"
  #end

  package "zabbix-release" do
    action :install
    provider Chef::Provider::Package::Rpm
    source "/usr/local/src/#{node['zabbix']['repo']['file']}"
  end
end

