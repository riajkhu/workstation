default[:openvswitch][:install_dir] = '/opt/openvswitch'
default[:openvswitch][:code_version] =  \
   '3b6f2889400fd340b851c2d36356457559ae6e81' # bug-free VXLAN impl
default[:openvswitch][:conf_dir] = '/etc/openvswitch'
default[:openvswitch][:init_file] = '/etc/init/openvswitch.conf'
default[:openvswitch][:pid_dir] = '/var/run/openvswitch'
default[:openvswitch][:mtu] = 1450 # a bit smaller than default 1500, 
                                   # to improve bandwidth performance
default[:openvswitch][:sdn_install_dir] = '/opt/openvswitch_sdn'
default[:openvswitch][:sdn_init_file] = '/etc/init/openvswitch_sdn.conf'
default[:openvswitch][:sdn_repo] = 'https://github.com/att/pox.git'
default[:openvswitch][:sdn_repo_branch] = 'master'
default[:openvswitch][:max_workers] = 251 # 256 (2**8) - 1 (.0) - 1
                                          # (broadcast) - 3 (gateway,
                                          # chefserver, controller)
