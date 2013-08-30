# Setup each OVS bridge to OpenFlow/SDN mode, and point them to the
# controller

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
  bridge_name = 'obr' + bridge_id.to_s # obr: Openvswitch BRidge
  Chef::Log.info("bridge_name=#{bridge_name}")

  bash "setup OVS bridge into OpenFlow mode" do
    user "root"
    code <<-EOH
      # Connect the OVS to the controller
      ovs-vsctl set-controller #{bridge_name} tcp:#{controller_ip}:6633

      # Configure the controller to be out of band.  With controller "in
      # band", Open vSwitch sets up special "hidden" flows to make sure that
      # traffic can make it back and forth between OVS and the controller.
      # These hidden flows are removed when controller is set "out of band"
      ovs-vsctl set controller #{bridge_name} connection-mode=out-of-band

      # Set fail-mode to secure so that when the connection to the
      # controller is lost, OVS will not perform normal (traditional) L2/L3
      # functionality
      ovs-vsctl set bridge #{bridge_name} fail-mode=secure

      # Disable STP
       ovs-vsctl set Bridge #{bridge_name} stp_enable=false
    EOH
  end
end
