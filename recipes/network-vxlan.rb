# setup a vxlan network between all nodes in the environment
# in a hub and spoke topology

# must specify node["openvswitch"]["hub_name"] and node["openvswitch"]["vxlan_bridge_ids"]
hub = node["openvswitch"]["hub_name"]
remote_nodes = []
if node.name == hub then
  # I'm the hub, I build a tunnel with everybody else
  query = "chef_environment:#{node.chef_environment}"
  result, _, _ = ::Chef::Search::Query.new.search :node, query
  result.each do |n|
    if n.name != hub then
      remote_nodes << n
    end
  end
else
  # find out the hub and put it in
  query = "name:#{hub} AND chef_environment:#{node.chef_environment}"
  result, _, _ = ::Chef::Search::Query.new.search :node, query
  remote_nodes << result[0]
end

remote_ips = remote_nodes.map{|n| n["ipaddress"]}

node["openvswitch"]["vxlan_bridge_ids"].each do |bridge_id|
  node.default["openvswitch"]["vxlan"][bridge_id] = remote_ips
end

include_recipe "openvswitch::vxlan"

node["openvswitch"]["vxlan_bridge_ids"].each do |bridge_id|
  bridge_name = 'obr' + bridge_id.to_s # obr: Openvswitch BRidge
  eth_name = 'eth' + bridge_id.to_s
  eth_peer_name = eth_name + "p"
  template "/etc/network/interface.#{eth_name}" do
    source "interface.erb"
    owner "root"
    group "root"
    mode 0644
    variables(
              :bridge_name => bridge_name,
              :eth_name => eth_name,
              :eth_peer_name => eth_peer_name
              )
  end
  bash "install and start interface" do
    user "root"
    # not_if "grep #{eth_name} /etc/network/interfaces" # not work properly
    code <<-EOH
      if ! grep #{eth_name} /etc/network/interfaces; then
        cat /etc/network/interface.#{eth_name} >> /etc/network/interfaces
      fi
    EOH
  end
  
  bash "make sure the inside port is in ovs" do
    code <<-EOH
      ifup #{eth_name} || true
      # ovs will remember this after reboot, so we need --may-exist
      ovs-vsctl --may-exist add-port #{bridge_name} #{eth_peer_name}
    EOH
  end
end
