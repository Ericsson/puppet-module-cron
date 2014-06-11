#-----------------------------------------------------------------------------#
# Class: cron
#
# This module manages cron
#
# Parameters: none
#
# Actions:
#
#
#
# Sample Usage:
#
# cron::ensure_state: 'running' => ensure the service started, this is
# the default value (can be set to 'stopped')
# cron::enable: 'false' => set the service to start during the server boot,
# default value = 'true'.
#----------------------------------------------------------------------------#

class cron (
  #Default values
  $enable           = true,
  $ensure_state     = 'running',
  $crontab_path     = '/etc/crontab',
  $cron_allow       = absent,
  $cron_deny        = absent,
  $cron_allow_path  = '/etc/cron.allow',
  $cron_deny_path   = '/etc/cron.deny',
  $cron_files       = undef,
  $cron_allow_users = undef,
  $cron_deny_users  = undef,
  $crontab_vars     = '',
  $crontab_tasks    = '',
) {

  # Check the client os to define the package name and service name

  case $::osfamily {
    ubuntu, suse: {$package_name = 'cron' $service_name = 'cron' }
    redhat, centos: {$package_name = 'crontabs' $service_name = 'crond' }
    default: {fail("Module cron does not support osfamily: ${::osfamily}")}
  }
   

  #--------------------------------------------------------------------------#
  # manage /etc/cron.allow and /etc/cron.deny
  # If the file cron.allow exists, only users listed in it are allowed
  # to use cron, and the cron.deny file is ignored.
  #
  # If cron.allow does not exist, users listed in cron.deny are not
  # allowed to use cron.
  #
  # Usage :
  # cron::cron_allow: 'true' => enable the usage of /etc/cron.allow,
  # and create the file (by default it is set to false)
  #
  # cron::cron_allow_users: (This add the users below to /etc/cron.allow)
  #   - user1
  #   - user2
  #
  # cron::cron_deny_users: (This add the users below to /etc/cron.deny)
  #   - user1
  #   - user2
  #--------------------------------------------------------------------------#
  #$cron_allow_users = hiera('cron::cron_allow_users', [])
  
  #$cron_allow_real = $cron_allow ? {
  #true    => 'present',
  #default => 'absent',
  #}
  
  file {'cron_allow':
    ensure  => $cron_allow, 
    path    => $cron_allow_path,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('cron/cron_allow.erb'),
    require => Package[$package_name],
  }


  #$cron_deny_users = hiera('cron::cron_deny_users', [])
  #$cron_deny_real = $cron_deny ? {
  #true    => 'present',
  #default => 'absent',
  #}
  file {'cron_deny':
    ensure  => $cron_deny,
    path    => $cron_deny_path,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('cron/cron_deny.erb'),
    require => Package[$package_name],
  }

  #--------------------------------------------------------------------------#
  # get variables from hiera file
  #
  #  Hiera Usage:
  #  #cron::crontab_vars:
  #  SHELL: /bin/bash
  #  PATH: /sbin:/bin:/usr/sbin:/usr/bin
  #  MAILTO: root
  #  HOME: /root
  #
  #  If the variable above are not provided (crontab_vars is empty),
  #  we will use default value defined template
  #--------------------------------------------------------------------------#

  #$crontab_vars  = hiera('cron::crontab_vars', {})

  #--------------------------------------------------------------------------#
  # get the tasks from hiera
  #
  # Hiera usage
  #
  # cron::crontab_tasks:
  #        'cronjob_task':
  #     - "* * * * * root 'cron_command'"
  #    'cronjob_task':
  #     - "* * * * * root 'cron_command'"
  #
  #--------------------------------------------------------------------------#

  #$crontab_tasks = hiera('cron::crontab_tasks', {})

package {'cron':
    ensure      => 'present',
    name        => $package_name,
  }

file {'crontab':
    ensure  => present,
    path    => $crontab_path,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('cron/crontab.erb'),
    require => Package[$package_name],
}


  service {'cron':
    ensure      => $ensure_state,
    enable      => $enable,
    name        => $service_name,
    require     => File[$crontab_path],
    subscribe   => File['crontab'],

  }


#------------------------------------------------#
# puppet has already cron resource defined
# and below manage cron in /var/spool/cron
#-----------------------------------------------#
#  Usage in manifest (example):
#   cron::cron_spool {"cron_name":
#       ensure =>present,
#       command => 'command to run',
#       minute  => ['0', '15', '30', '45']
#   }
#
#  Usage with Hiera (example):
#  cron::var_spool_cron:
#     cron_name:
#      ensure: 'present'
#      command: 'command to run'
#      minute: [0, 15, 30, 45]
#-----------------------------------------------#



#define cron_spool (
#  $ensure   = 'absent',
#  $target   = 'root',
#  $user     = 'root',
#  $command  = '',
#  $minute   = '*',
#  $hour     = '*',
#  $monthday = '*',
#  $month    = '*',
#  $weekday  = '*',
#) {
#  cron { $name:
#    ensure   => $ensure,
#    command  => $command,
#    minute   => $minute,
#    hour     => $hour,
#    monthday => $monthday,
#    month    => $month,
#    weekday  => $weekday,
#    target   => $target,
#    user     => $user,
#  }
#}# End of cron_spool

# below create cron entry from hiera hash as described above

#$cron_spool = hiera('cron::var_spool_cron', {})
#create_resources(cron_spool,$cron_spool)


  #$cron_files = hiera('cron::cron_files')
  if $cron_files != undef {
  create_resources(cron::fragment,$cron_files)
  }



}

