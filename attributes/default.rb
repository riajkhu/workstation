default[:openvswitch][:install_path] = '/opt/ovs'
default[:openvswitch][:code_version] =  \
   '3b6f2889400fd340b851c2d36356457559ae6e81' # bug-free VXLAN impl
default[:openvswitch][:conf_dir] = '/etc/openvswitch'
default[:openvswitch][:init_file] = '/etc/init/openvswitch.conf'
default[:openvswitch][:pid_dir] = '/var/run/openvswitch'
default[:openvswitch][:mtu] = 1450 # a bit smaller than default 1500, to improve bandwidth performance
