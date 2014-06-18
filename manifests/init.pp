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
  $enable_cron      = true,
  $package_ensure   = 'present',
  $ensure_state     = 'running',
  $crontab_path     = '/etc/crontab',
  $cron_allow       = 'absent',
  $cron_deny        = 'absent',
  $cron_allow_path  = '/etc/cron.allow',
  $cron_deny_path   = '/etc/cron.deny',
  $cron_files       = undef,
  #$var_spool_cron   = undef,
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
   
  # validation
  if ! ($ensure_state in [ running, stopped ]) {
     fail("cron::ensure_state is $ensure_state and must be running or stopped")
  }

  if ! ($package_ensure in [ "present", "absent" ]) {
     fail("cron::package_ensure is $package_ensure and must be absent or present")
  }
  if ! ($cron_allow in [ "present", "absent" ]) {
     fail("cron::cron_allow is $cron_allow and must be absent or present")
  }
  if ! ($cron_deny in [ "present", "absent" ]) {
     fail("cron::cron_deny is $cron_deny and must be absent or present")
  }
  case type($enable_cron) {
   'string': { 
    validate_re($enable_cron, '^(true|false)$', "cron::enable_cron may be either 'true' or 'false' and is set to <$enable_cron>")
    $enable_cron_real = str2bool($enable_cron)
    }
   'boolean': {
    $enable_cron_real = $enable_cron
    }
   default: {
   fail('cron::enable_cron type must be true or false.')
   }
  }
  if $cron_allow_users != undef {
   validate_array($cron_allow_users)
   $cron_allow='present'
  } else { 
   $cron_allow_real=$cron_allow
  }
  if $cron_deny_users != undef {
   validate_array($cron_deny_users)
   $cron_deny_real='present'
  } else {
  $cron_deny_real=$cron_deny
  }
  if $cron_files != undef {
   create_resources(cron::fragment,$cron_files)
  }
  if ($cron_tasks != '') {
   validate_hash($cron_tasks)
  }
  if ($cron_vars != '') {
   validate_hash($cron_vars)
  } 
  
# End of validation

file {'cron_allow':
    ensure  => $cron_allow_real, 
    path    => $cron_allow_path,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('cron/cron_allow.erb'),
    require => Package[$package_name],
 }


 file {'cron_deny':
    ensure  => $cron_deny_real,
    path    => $cron_deny_path,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('cron/cron_deny.erb'),
    require => Package[$package_name],
 }


package {'cron':
    ensure      => $package_ensure,
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
    enable      => $enable_cron_real,
    name        => $service_name,
    require     => File[$crontab_path],
    subscribe   => File['crontab'],

  }

}

