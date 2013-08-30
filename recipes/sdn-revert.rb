# Revert all SDN/OpenFlow configurations of Open vSwitch to default
# L2/L3 switch

controller_name = node[:openvswitch][:sdn_controller_name]
controller_ip = ''
query = "chef_environment:#{node.chef_environment}"
result_nodes, _, _ = ::Chef::Search::Query.new.search :node, query
result_nodes.each do |n|
  if n.name == controller_name then
    controller_ip = n[:ipaddress]
  end
end
if controller_ip == '' then
  raise 'Not found controller IP!'
end
Chef::Log.info("controller_ip=#{controller_ip}")

node[:openvswitch][:vxlan_bridge_ids].each do |bridge_id|
  bridge_name = 'obr' + bridge_id.to_s
  Chef::Log.info("bridge_name=#{bridge_name}")

  bash "revert SDN/OpenFlow configurations" do
    user "root"
    code <<-EOH
      # Deconnect from the controller
      ovs-vsctl del-controller #{bridge_name}

      # Delete fail-mode. When connection to the controller is lost,
      # The virtual switch will act like a traditional switch
      ovs-vsctl del-fail-mode #{bridge_name}

      # enable STP
      ovs-vsctl set Bridge #{bridge_name} stp_enable=true
 
      # Delete all Openflow flows
      ovs-ofctl del-flows #{bridge_name}

      # Add a flow for normal operation
      ovs-ofctl add-flow #{bridge_name} "table=0, actions=NORMAL"
    EOH
  end
end

# stop the SDN controller on the controller node
if node[:ipaddress] == controller_ip then
  service "openvswitch_sdn" do
    provider Chef::Provider::Service::Upstart
    action :stop
  end
end
