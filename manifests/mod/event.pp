class apache::mod::event (
  $startservers           = '2',
  $maxclients             = '150',
  $minsparethreads        = '25',
  $maxsparethreads        = '75',
  $threadsperchild        = '25',
  $maxrequestsperchild    = '0',
  $serverlimit            = '25',
  $apache_version         = $::apache::apache_version,
  $threadlimit            = '64',
  $listenbacklog          = '511',
  $maxrequestworkers      = '250',
  $maxconnectionsperchild = '0',
) {
  if defined(Class['apache::mod::itk']) {
    fail('May not include both apache::mod::event and apache::mod::itk on the same node')
  }
  if defined(Class['apache::mod::peruser']) {
    fail('May not include both apache::mod::event and apache::mod::peruser on the same node')
  }
  if defined(Class['apache::mod::prefork']) {
    fail('May not include both apache::mod::event and apache::mod::prefork on the same node')
  }
  if defined(Class['apache::mod::worker']) {
    fail('May not include both apache::mod::event and apache::mod::worker on the same node')
  }
  File {
    owner => 'root',
    group => $::apache::params::root_group,
    mode  => $::apache::file_mode,
  }

  # Template uses:
  # - $startservers
  # - $maxclients
  # - $minsparethreads
  # - $maxsparethreads
  # - $threadsperchild
  # - $maxrequestsperchild
  # - $serverlimit
  file { "${::apache::mod_dir}/event.conf":
    ensure  => file,
    mode    => $::apache::file_mode,
    content => template('apache/mod/event.conf.erb'),
    require => Exec["mkdir ${::apache::mod_dir}"],
    before  => File[$::apache::mod_dir],
    notify  => Class['apache::service'],
  }

  case $::osfamily {
    'redhat': {
      if versioncmp($apache_version, '2.4') >= 0 {
        apache::mpm{ 'event':
          apache_version => $apache_version,
        }
      }
    }
    'debian','freebsd' : {
      apache::mpm{ 'event':
        apache_version => $apache_version,
      }
    }
    'gentoo': {
    }
    default: {
      fail("Unsupported osfamily ${::osfamily}")
    }
  }
}
