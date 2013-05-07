# setup vxlan according to given/queried bridge and interface info
# bridge_id: integer, up to 16 million
# e.g.,
# node[:openvswitch][:vxlan][:100] = ['10.1.56.42', '10.1.56.45']
# node[:openvswitch][:vxlan][:101] = ['10.1.56.55']

node[:openvswitch][:vxlan].each do |bridge_id, remote_ips|
  bridge_name = 'obr' + bridge_id.to_s # obr: Openvswitch BRidge
  bash "create bridge" do
    user "root"
    code <<-EOH
      # Not exist: 1st time; Exist: afterwards
      ovs-vsctl --may-exist add-br #{bridge_name}
      ovs-vsctl set Bridge #{bridge_name} stp_enable=true
    EOH
  end

  remote_ips.each do |remote_ip|
    # interface name must <= 15 Bytes, or use hash: .hash.to_s(16)
    l = remote_ip.split('.') 
    tunnel_name = bridge_name + '_' + '%s-%s' % [l[2], l[3]]    
    bash "create tunnel" do
      user "root"
      code <<-EOH
        # Not exist: 1st time; Exist: afterwards
        ovs-vsctl --may-exist add-port #{bridge_name} #{tunnel_name} \
          -- set interface #{tunnel_name} type=vxlan \
          options:remote_ip=#{remote_ip} options:key=#{bridge_id}
      EOH
    end
  end
end
