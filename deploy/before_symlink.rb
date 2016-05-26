Chef::Log.info("Running deploy/before_symlink.rb...")
#@ todo - add configuration for user deploy (aws keys for s3) or encrypt builds

execute "get s3 file" do
   cwd "#{release_path}"
   command "mv /tmp/build.zip #{release_path} && unzip build.zip"
end

execute "get s3 file" do
   cwd "#{release_path}"
   command "rm build.zip"
end

#execute "mkdir" do
#  command "mkdir #{release_path}/data/ip2location"
#end

execute "link on IP-COUNTRY.BIN" do
  command "ln -s /opt/IP-COUNTRY.BIN #{release_path}/data/ip2location/IP-COUNTRY.BIN"
end

execute "mv parameters.yml" do
  command "mv /srv/www/web/shared/parameters.yml #{release_path}/app/config/parameters.yml"
end

execute "merge parameters" do
   cwd "#{release_path}"
   command "php composer.phar run-script post-install-cmd -n"
end

execute "rm old cache" do
   cwd "#{release_path}"
   command "rm -rf app/cache/*"
end

execute "clear cache" do
   cwd "#{release_path}"
   command "app/console cache:clear"
end

if node[:opsworks][:instance][:layers].include? "cron"
    if node['migrate'] == 'false'
      Chef::Log.info("Skipping migrations")
    else
            Chef::Log.info("Running migrations")
	    execute "Run migrations" do
  	       cwd "#{release_path}"
	       command "php app/console doctrine:migrations:migrate --no-interaction --ansi"
            end
    end
end

execute "warmup cache" do
  cwd "#{release_path}"
  command "php app/console cache:warmup --env=prod --no-debug --ansi"
end

Chef::Log.info("Finishing before_symlink. Done.")

