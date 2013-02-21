# setup vxlan according to given bridge and interface info
# e.g.,
# default[:openvswitch][:vxlan][:br1] = ['10.1.56.42', '10.1.56.45'] 
# default[:openvswitch][:vxlan][:br2] = ['10.1.56.55']

node[:openvswitch][:vxlan].each do |br, remote_ips|
  bash "create bridge" do
    user "root"
    code <<-EOH
      # create if not exist, idempotence
      if ! echo `ovs-vsctl list-br` | egrep -q #{br}; then
        ovs-vsctl add-br #{br}
      fi
    EOH
  end
  remote_ips.each do |remote_ip|
    # alternatively, using hash: .hash.to_s(16)
    tunnel_id = br + '_' + remote_ip
    bash "create tunnel" do
      user "root"
      code <<-EOH
        # create if not exist, idempotence
        if ! echo `ovs-vsctl list-ports #{br}` | egrep -q "#{tunnel_id}"; then
          ovs-vsctl add-port #{br} #{tunnel_id} \
            -- set interface #{tunnel_id} type=vxlan \
            options:remote_ip=#{remote_ip} # options:key=flow    
        fi
      EOH
    end
  end
end
