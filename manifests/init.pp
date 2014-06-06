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
  $enable          = true,
  $ensure_state    = 'running',
  $crontab_path    = '/etc/crontab',
  $cron_allow      = false,
  $cron_allow_path = '/etc/cron.allow',
  $cron_deny_path  = '/etc/cron.deny',
) {

  # Check the client os to define the package name and service name

  case $::operatingsystem {
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
  $cron_allow_users = hiera('cron::cron_allow_users', [])

  file {'cron_allow':
    ensure  => $cron_allow ? {
      true    => present,
      default => absent,
    },
    path    => $cron_allow_path,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('cron/cron_allow.erb'),
    require => Package[$package_name],
  }


  $cron_deny_users = hiera('cron::cron_deny_users', [])
  file {'cron_deny':
    ensure  => present,
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

  $crontab_vars  = hiera('cron::crontab_vars', {})

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

  $crontab_tasks = hiera('cron::crontab_tasks', {})

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



define cron_spool (
  $ensure   = 'absent',
  $target   = 'root',
  $user     = 'root',
  $command  = '',
  $minute   = '*',
  $hour     = '*',
  $monthday = '*',
  $month    = '*',
  $weekday  = '*',
) {
  cron { $name:
    ensure   => $ensure,
    command  => $command,
    minute   => $minute,
    hour     => $hour,
    monthday => $monthday,
    month    => $month,
    weekday  => $weekday,
    target   => $target,
    user     => $user,
  }
}# End of cron_spool

# below create cron entry from hiera hash as described above

$cron_spool = hiera('cron::var_spool_cron', {})
create_resources(cron_spool,$cron_spool)


#--------------------------------------------#
#
# manage cron jobs in separate files
# call with ensure_cron=> absent to delete the job
#
#--------------------------------------------#
#  usage in manifest
#  cron::cron_job_file { "file_name":
#        ensure_cron => present,
#        type        => "d",
#        cron_content    => "script | cron"
#
#
# usage in Hiera
#  cron::cron_files:
#     'file_name':
#       ensure_cron: 'present'
#       type: "daily"
#       cron_content: |-
#            #!/bin/bash
#            # This File is managed by puppet
#            script
#            .
#            .
#            EOF
#-------------------------------------------#

define cron_job_file (
  $ensure_cron  = 'absent',
  $type         = 'daily',
  $cron_content = '',
  $owner        = 'root',
  $group        = 'root',
  $package      = $cron::package_name,
  $service      = $cron::service_name
) {
  file { "/etc/cron.${type}/${name}":
    ensure  => $ensure_cron,
    content => $cron_content,
    force   => true,
    owner   => $owner,
    group   => $group,
    mode    => $type ? {
                  'd'     => 644,
                  default => 755,
                },
    require => $package ? {
                  ''      => undef,
                  default => Package[$package],
                },
    notify  => $type ? {
                  'd'     => Service[$service],
                  default => undef,
                }
  }


}

  $cron_files = hiera('cron::cron_files')
  create_resources(cron_job_file,$cron_files)

}

