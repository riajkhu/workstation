# install SDN controller on the controller node and start service

directory node[:openvswitch][:sdn_install_dir] do
  owner "root"
  group "root"
  mode 00755
end

if not File.exists?(node[:openvswitch][:sdn_init_file]) then
  bash "install SDN controller" do
    user "root"
    cwd node[:openvswitch][:sdn_install_dir]
    code <<-EOH
      git clone -b #{node[:openvswitch][:sdn_repo_branch]} \
        #{node[:openvswitch][:sdn_repo]}
    EOH
  end
end

# construct ip_prefix used by for SDN controller
l = node[:ipaddress].split('.') 
node[:openvswitch][:ip_prefix] = '%s.%s' % [l[0], l[1]]
template node[:openvswitch][:sdn_init_file] do
  source "openvswitch_sdn.conf.erb"
  owner "root"
  group "root"
  mode 00755
end

service "openvswitch_sdn" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :start => true, :stop => true
  action [:enable, :start]
end
