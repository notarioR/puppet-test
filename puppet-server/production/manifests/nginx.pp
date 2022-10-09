node puppetclient {
  class{'nginx':
      manage_repo => true,
      package_source => 'nginx-stable',
  }

  nginx::resource::server{'domain.com':
    ensure                => present,
    listen_port           => 443,
    ssl                   => true,
    ssl_port              => 443,
    ssl_cert              => '/home/user/localhost.crt',
    ssl_key               => '/home/user/localhost.key',
    proxy                 => 'http://10.10.10.10',
    access_log            => '/var/log/nginx/puppet_access.log',
    error_log             => '/var/log/nginx/puppet_error.log'
  }
 
  nginx::resource::location{'/resource2':
    ensure          => present,
    ssl             => true,
    ssl_only        => true,
    proxy => 'http://20.20.20.20/' ,
    server => 'domain.com'
  }

}