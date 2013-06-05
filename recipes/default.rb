package "build-essential"
package "git"
package "autoconf"
package "python-simplejson"
package "python-qt4"
package "python-twisted-conch"
package "uml-utilities"
package "libtool"
package "pkg-config"

directory node[:openvswitch][:install_dir] do
  owner "root"
  group "root"
  mode 00755
end

directory node[:openvswitch][:conf_dir] do
  owner "root"
  group "root"
  mode 00755
end

if not File.exists?(node[:openvswitch][:init_file])
  bash "install openswitch from code" do
    user "root"
    cwd node[:openvswitch][:install_dir]
    code <<-EOH
    git clone git://openvswitch.org/openvswitch
    cd openvswitch
    git checkout #{node[:openvswitch][:code_version]}
    ./boot.sh
    ./configure --with-linux=/lib/modules/`uname -r`/build \
      --prefix=/usr --localstatedir=/var # default to these libraries
    make -j
    make install
    ovsdb-tool create #{node[:openvswitch][:conf_dir]}/conf.db \
      vswitchd/vswitch.ovsschema
    EOH
  end
end

template node[:openvswitch][:init_file] do
  source "openvswitch.conf.erb"
  owner "root"
  group "root"
  mode 00755
end

service "openvswitch" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :start => true, :stop => true
  action [:enable, :start]
end
