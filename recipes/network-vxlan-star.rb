# setup a vxlan network between all nodes in the environment in a hub
# and spoke topology. Must specify node[:openvswitch][:hub_name] and
# node[:openvswitch][:vxlan_bridge_ids]

hub = node[:openvswitch][:hub_name]
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
node[:openvswitch][:vxlan_bridge_ids].each do |bridge_id|
  node.default[:openvswitch][:vxlan][bridge_id] = remote_ips
end

include_recipe "openvswitch::vxlan"

include_recipe "openvswitch::interfaces"
