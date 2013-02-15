# modify /etc/init/failsafe.conf to shorten boot time
# echo "127.0.0.1 `hostname`" >> /etc/hosts
# ovs-vsctl add-br br1 # tunnel in this bridge
# /etc/init.d/networking restart
# route add default gw <10.1.56.1> eth0
# ovs-vsctl add-port br1 tun1 -- set interface tun1 \
#    type=vxlan options:remote_ip=<192.168.1.110> \ 
#    options:key=flow

package "git" 
package "build-essential"
package "automake"
package "autoconf"
package "gcc"
package "python-simplejson"
package "python-qt4"
package "python-twisted-conch"
package "uml-utilities"
package "libtool"
package "pkg-config"
package "linux-headers-#{`uname -r`}"

if not File.exists?("/etc/init.d/openvswitchd")
  bash "install openswitch from code" do
    user "root"
    cwd node[:openvswitch][:install_path]
    code <<-EOH
    git clone git://openvswitch.org/openvswitch
    cd openvswitch
    git checkout #{node[:openvswitch][:code_version]}
    ./boot.sh
    ./configure --with-linux=/lib/modules/`uname -r`/build
    make -j
    make install
    touch /usr/local/etc/ovs-vswitchd.conf
    mkdir -p /usr/local/etc/openvswitch
    ovsdb-tool create /usr/local/etc/openvswitch/conf.db vswitchd/vswitch.ovsschema
    EOH
  end
end

template "/etc/init.d/openvswitchd" do
  source "openvswitchd.erb"
  owner "root"
  group "root"
  mode 755
  variable(
           :install_path => node[:openvswitch][:install_path]
           )
end

service "openvswitchd" do
  action [:enable, :start]
end
