node puppetclient {
  class{'nginx':
      manage_repo => true,
      package_source => 'nginx-stable',
  }

}