tunnel_id = 1
node[:openvswitch][:vxlan].each do |br, remote_ips|
  bash "create bridge" do
    user "root"
    code <<-EOH
      ovs-vsctl add-br #{br}
    EOH
  end
  remote_ips.each do |remote_ip|
    bash "create tunnel" do
      user "root"
      code <<-EOH
        ovs-vsctl add-port #{br} tun#{tunnel_id} \
          -- set interface tun#{tunnel_id} type=vxlan \
          options:remote_ip=#{remote_ip} # options:key=flow
      EOH
    tunnel_id += 1
    end
  end
end

# modify /etc/init/failsafe.conf to shorten boot time
# echo "127.0.0.1 `hostname`" >> /etc/hosts
# /etc/init.d/networking restart
# route add default gw <10.1.56.1> eth0
