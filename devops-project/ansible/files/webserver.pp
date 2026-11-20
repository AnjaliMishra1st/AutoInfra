# Puppet manifest: keeps Apache installed, running and serving the right page
class webserver {
  $host = $facts['networking']['hostname']

  package { 'apache2':
    ensure => installed,
  }

  file { '/var/www/html/index.html':
    ensure  => file,
    content => "<h1>DevOps Project - Anjali Mishra (Roll 13)</h1><p>Served by ${host} and managed by Puppet</p>\n",
    require => Package['apache2'],
    notify  => Exec['reload-apache'],
  }

  # Starts Apache if it is not running (self-healing)
  exec { 'start-apache':
    command => 'service apache2 start',
    unless  => 'service apache2 status',
    path    => ['/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    require => Package['apache2'],
  }

  # Reloads Apache only when the web page file changes
  exec { 'reload-apache':
    command     => 'service apache2 reload',
    path        => ['/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    refreshonly => true,
    require     => Exec['start-apache'],
  }
}

include webserver
