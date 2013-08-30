# Revert all SDN/OpenFlow configurations of Open vSwitch to default
# L2/L3 switch

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
