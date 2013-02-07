
knife_cmd = "#{node[:chef_server_populator][:knife_exec]} " <<
  "-k #{node[:chef_server_populator][:pem]} " <<
  "-u #{node[:chef_server_populator][:user]} " <<
  "-s https://127.0.0.1"
pg_cmd = "/opt/chef-server/embedded/bin/psql -d opscode_chef"

node[:chef_server_populator][:clients].each do |client, pub_key|
  execute "create client: #{client}" do
    command "#{knife_cmd} client create --admin #{client}"
    not_if "#{knife_cmd} client list | tr -d ' ' | grep '^#{client}$'"
  end
  if(pub_key && File.exists?(pub_key))
    execute "set public key for: #{client}" do
      command "#{pg_cmd} -c \"update clients set public_key = E'#{File.read(pub_key)}' where name = '#{client}'\""
      user 'opscode-pgsql'
    end
  end
end
