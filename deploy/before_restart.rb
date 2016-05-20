  service 'php5-fpm' do
    supports :restart => true
    action :restart
    provider Chef::Provider::Service::Upstart
  end

