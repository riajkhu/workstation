log_level                :info
log_location             STDOUT
node_name                'chef-workstation'
client_key               '/root/.chef/client.pem'
validation_client_name   'chef-validator'
validation_key           '/etc/chef/validation.pem'
chef_server_url          'http://163.180.116.25:4000'
cache_type               'BasicFile'
cache_options( :path => '/root/.chef/checksums' )
#cookbook_path ["#{current_dir}/../cookbook"]
