#!/bin/bash
sudo curl https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb -o puppetlabs-release.deb
sudo dpkg -i puppetlabs-release.deb
sudo apt-get -qq update
#sudo apt-get install -yq puppet-agent
sudo apt-get install -yq puppet-agent=1.8.3-1xenial
sudo /opt/puppetlabs/bin/puppet module install puppet-nginx --version 0.5.0
cat >/tmp/nginx.pp << "EOF"
class{'nginx': }
nginx::resource::vhost{'www.example.com':
    www_root => '/var/www/html/',
  }
EOF
sudo /opt/puppetlabs/bin/puppet apply /tmp/nginx.pp
