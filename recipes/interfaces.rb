# setup /etc/network/interfaces and put eth interfaces into OVS

include_recipe "openvswitch::gen-worker-ips"

seq = 0
node[:openvswitch][:vxlan_bridge_ids].each do |bridge_id|
  bridge_name = 'obr' + bridge_id.to_s # obr: Openvswitch BRidge
  eth_name = 'eth' + bridge_id.to_s
  eth_peer_name = eth_name + "p"
  netmask = node[:openvswitch][:netmask]
  address = node[:openvswitch][:addresses][node.name][seq]
  seq += 1
  template "/etc/network/interface.#{eth_name}" do
    source "interface.erb"
    owner "root"
    group "root"
    mode 0644
    variables(
              :bridge_name => bridge_name,
              :eth_name => eth_name,
              :eth_peer_name => eth_peer_name,
              :address => address,
              :netmask => netmask
              )
  end
  bash "install and start interface" do
    user "root"
    # not_if "grep #{eth_name} /etc/network/interfaces" # not work
    code <<-EOH
      if ! grep #{eth_name} /etc/network/interfaces; then
        cat /etc/network/interface.#{eth_name} >> /etc/network/interfaces
      fi
    EOH
  end
  
  bash "make sure the inside port is in ovs" do
    code <<-EOH
      ifup #{eth_name} || true
      # Not exist: 1st time; Exist: afterwards
      ovs-vsctl --may-exist add-port #{bridge_name} #{eth_peer_name}
    EOH
  end
end
