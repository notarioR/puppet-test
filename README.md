
# Puppet test

   

- Create/extend an existing puppet module for Nginx:

  
```
  class{ 'nginx':
    manage_repo => true,
    package_source => 'nginx-stable',
    log_format => {
      'custom' => '$time_local - $scheme - "$remote_addr" [$request_time]'
    },
  }
```
  
- Create a proxy to redirect requests for https://domain.com to 10.10.10.10 and redirect requests for https://domain.com/resoure2 to 20.20.20.20.

 > (Proxy got health-check so it will try to check the servers in the health check list 10.10.10.10 and 20.20.20.20, I added 20.20.20.20 to make a bit real case of use)

```

  nginx::resource::server{ 'domain.com':
    ensure => present,
    listen_port => 443,
    ssl => true,
    ssl_port => 443,
    ssl_cert => '/etc/nginx/self-signed.crt',
    ssl_key => '/etc/nginx/self-signed.key',
    proxy => 'http://health-check',
    access_log => '/var/log/nginx/puppet_access.log',
    error_log => '/var/log/nginx/puppet_error.log'
  }

  nginx::resource::location{'/resource2':
    ensure => present,
    ssl => true,
    ssl_only => true,
    proxy => 'http://20.20.20.20/' ,
    server => 'domain.com'
  }

```

- Create a forward proxy to log HTTP requests going from the internal network to the Internet including: request protocol, remote IP and time take to serve the request.

```

  nginx::resource::server { 'proxy-forward.domain.com':
    ensure => 'present',
    listen_port => 8000,
    proxy => 'https://$http_host$request_uri',
    resolver => ['8.8.8.8'],
    format_log => 'custom',
  }

```

- (Optional) Implement a proxy health check.

  

```

  nginx::resource::upstream { 'health-check':
      ensure => present,
      members => {
        'http://10.10.10.10' => {
          server => '10.10.10.10',
          weight => 3
      },
        'http://20.20.20.20' => {
          server => '20.20.20.20',
          max_fails => 1,
          fail_timeout => '60s',
        }
      },
  }

```

  


  
  

# How to use it

  ## Requirements:

    - Docker

  ## File Scaffolding:

    puppet-client
    - puppet.conf

    puppet-server
    - production
      - common.yaml
    - manifests
      - nginx.pp (nginx funcionalities)
    - modules (puppet-nginx --version 4.0.0, and dependencies)
    - environment.conf
    - hiera.yaml
    - puppet.conf

    source-server
    - entrypoint.sh - Start puppet server service and keep the container running

    web
    - index.html - Example of index.html to check the directive www_root, not needed in this exercise.

    Dockerfile
    docker-compose.yml


## Steps 
  
  1.Clone the repository

  ```
  git clone git@github.com:notarioR/puppet-test.git
  ```

  2.Build and run the containers

  ```
  docker-compose up
  ```

  3.Check if the container are working and get the ids:

  ```
  docker ps
  ```

  4.Run a new command in the containers

  ```
  docker ps
  docker exec -it <container_id> bash
  ```

  5.Get into the client container and request ssl to the server container

  ```
  puppet ssl bootstrap
  ``` 

  6.Then in the server container you will need to sign the client certificate after it made the request

  ```
  puppetserver ca sign --cert puppetclient
  ``` 

  7.Back into the client container we will need to generate self signed certificate in order to work with ssl
    
  ```
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/self-signed.key -out /etc/nginx/self-signed.crt
  ```
   
  8.Finally into puppet client container call the puppet agent to retrieve a catalog from pupper server container and it will be applied.

  ```
  puppet agent -t
  ```

    

  ## Checking proxy-forward

  ```
  curl -L -I http://google.com --proxy http://proxy-forward.domain.com:8000
  ```

  Monitoring log

  ```
  tail -f /var/log/nginx/proxy-forward.domain.com.access.log
  ```

    

  ## Checking proxy and health, (use --insecure flag to skip check certificate)

  ```
  curl --insecure -I https://domain.com
  ```
  ```
  curl --insecure -I https://domain.com/resource2
  ```
  Monitoring:

  ```
  tail -f /var/log/nginx/puppet_error.log
  ```

    

  > Add domain.com and proxy-forward.domain.com to the hosts file in your machine to point them to your docker bridge address in order to reach the puppet client container with nginx.

# References:

http://nginx.org/en/docs/

https://puppet.com/
