# The hub serves as dnsmasq server
hub = node[:openvswitch][:hub_name]
hub_address = node[:openvswitch][:addresses][hub][0]  # 0: eth1 ops n/w

include_recipe "openvswitch::gen-worker-ips"

# I am the hub, do the following
if node.name == hub then
  # install dnsmasq
  package "dnsmasq"
  # create /etc/hosts from each node
  query = "chef_environment:#{node.chef_environment}"
  nodes, _, _ = ::Chef::Search::Query.new.search :node, query
  nodes.each do |n|
    node_name = n.name
    address = node[:openvswitch][:addresses][node_name][0]  # 0: eth1 ops n/w
    template "/etc/hosts.#{node_name}" do
      source "hosts.erb"
      owner "root"
      group "root"
      mode 00644
      variables(
                :node_name => node_name,
                :address => address
                )
    end
    bash "install hostname" do
      user "root"
      code <<-EOH
        if ! grep #{node_name} /etc/hosts; then
          cat /etc/hosts.#{node_name} >> /etc/hosts
        fi
      EOH
    end    
  end
  # restart dnsmasq service
  service "dnsmasq" do
    provider Chef::Provider::Service::Init
    supports :status => true, :start => true, :stop => true
    action [:restart]
  end

# Everybody else points to the hub as nameserver
else
  template '/etc/resolv.conf' do
    source "resolv.conf.erb"
    owner "root"
    group "root"
    mode 00644
    variables(
              :hub_address => hub_address
              )  
  end
  bash "freeze resolv.conf" do
    user "root"
    code <<-EOH
      chattr +i /etc/resolv.conf
    EOH
  end  
end
