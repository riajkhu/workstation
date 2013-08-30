# setup a vxlan network between all nodes in the environment in a full
# mesh topology and use SDN controller and OpenFlow. Must specify
# node[:openvswitch][:vxlan_bridge_ids].

remote_nodes = []
# I build a tunnel with everybody else
query = "chef_environment:#{node.chef_environment}"
result, _, _ = ::Chef::Search::Query.new.search :node, query
result.each do |n|
  if n.name != node.name then
    remote_nodes << n
  end
end

remote_ips = remote_nodes.map{|n| n["ipaddress"]}
node[:openvswitch][:vxlan_bridge_ids].each do |bridge_id|
  node.default[:openvswitch][:vxlan][bridge_id] = remote_ips
end

include_recipe "openvswitch::vxlan"

include_recipe "openvswitch::interfaces"
