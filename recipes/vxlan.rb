# setup vxlan according to given/queried bridge and interface info
# e.g.,
# default[:openvswitch][:vxlan][:obr1] = ['10.1.56.42', '10.1.56.45'] 
# default[:openvswitch][:vxlan][:obr2] = ['10.1.56.55']

node[:openvswitch][:vxlan].each do |br_name, remote_ips|
  bash "create bridge" do
    user "root"
    code <<-EOH
      # create if not exist, idempotence
      if ! ovs-vsctl list-br | egrep -q ^#{br_name}$; then
        ovs-vsctl add-br #{br_name}
      fi
    EOH
  end

  remote_ips.each do |remote_ip|
    # interface name must <= 15 Bytes, or use hash: .hash.to_s(16)
    l = remote_ip.split('.') 
    tunnel_name = br_name + '_' + '%s-%s' % [l[2], l[3]]    
    bash "create tunnel" do
      user "root"
      code <<-EOH
        # create if not exist, idempotence
        if ! ovs-vsctl list-ports #{br_name} | egrep -q ^#{tunnel_name}$; then
          ovs-vsctl add-port #{br_name} #{tunnel_name} \
            -- set interface #{tunnel_name} type=vxlan \
            options:remote_ip=#{remote_ip} # options:key=flow    
        fi
      EOH
    end
  end
end
