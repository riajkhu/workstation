# setup vxlan according to given/queried bridge and interface info
# bridge_id: integer, up to 16 million
# e.g.,
# default[:openvswitch][:vxlan][:100] = ['10.1.56.42', '10.1.56.45'] 
# default[:openvswitch][:vxlan][:101] = ['10.1.56.55']

node[:openvswitch][:vxlan].each do |bridge_id, remote_ips|
  bridge_name = 'obr' + bridge_id.to_s # obr: Openvswitch BRidge
  bash "create bridge" do
    user "root"
    code <<-EOH
      # create if not exist, idempotence
      if ! ovs-vsctl list-br | egrep -q ^#{bridge_name}$; then
        ovs-vsctl add-br #{bridge_name}
      fi
    EOH
  end

  remote_ips.each do |remote_ip|
    # interface name must <= 15 Bytes, or use hash: .hash.to_s(16)
    l = remote_ip.split('.') 
    tunnel_name = bridge_name + '_' + '%s-%s' % [l[2], l[3]]    
    bash "create tunnel" do
      user "root"
      code <<-EOH
        # create if not exist, idempotence
        if ! ovs-vsctl list-ports #{bridge_name} | egrep -q ^#{tunnel_name}$; then
          ovs-vsctl add-port #{bridge_name} #{tunnel_name} \
            -- set interface #{tunnel_name} type=vxlan \
            options:remote_ip=#{remote_ip} options:key=#{bridge_id}
        fi
      EOH
    end
  end
end
