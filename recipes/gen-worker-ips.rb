# Generate IPs for workers, e.g., 
# "${PREFIX}-worker1" : ["10.251.0.4", "0.0.0.0", "172.31.0.4"],
# "${PREFIX}-worker2" : ["10.251.0.5", "0.0.0.0", "172.31.0.5"],
# "${PREFIX}-worker3" : ["10.251.0.6", "0.0.0.0", "172.31.0.6"],
# "${PREFIX}-worker4" : ["10.251.0.7", "0.0.0.0", "172.31.0.7"],
# "${PREFIX}-worker5" : ["10.251.0.8", "0.0.0.0", "172.31.0.8"]
# ...

name_prefix = node.name.split('-')[0]
ip_prefix_1 = node[:openvswitch][:addresses][:worker][0]
ip_prefix_2 = node[:openvswitch][:addresses][:worker][1]
ip_prefix_3 = node[:openvswitch][:addresses][:worker][2]

for i in 1..node[:openvswitch][:max_workers]
  name = name_prefix + '-' + 'worker' + i.to_s()
  ip_1 = ip_prefix_1 + (i + 3).to_s()
  ip_2 = ip_prefix_2 + '0'
  ip_3 = ip_prefix_3 + (i + 3).to_s()
  node.set[:openvswitch][:addresses][name] = [ip_1, ip_2, ip_3]
end

Chef::Log.info("node_addresses=#{node[:openvswitch][:addresses][node.name]}")
