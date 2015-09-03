# == Class: cron
#
# This module manages cron
#
class cron (
  $enable_cron      = true,
  $package_ensure   = 'present',
  $ensure_state     = 'running',
  $crontab_path     = '/etc/crontab',
  $cron_allow       = 'absent',
  $cron_deny        = 'present',
  $cron_allow_path  = '/etc/cron.allow',
  $cron_deny_path   = '/etc/cron.deny',
  $cron_files       = undef,
  $cron_allow_users = undef,
  $cron_deny_users  = undef,
  $crontab_vars     = undef,
  $crontab_tasks    = undef,
) {

  # Check the client os to define the package name and service name

  case $::osfamily {
    'Debian', 'Suse': {
      $package_name = 'cron'
      $service_name = 'cron'
    }
    'RedHat': {
      $package_name = 'crontabs'
      $service_name = 'crond'
    }
    default: {
      fail("cron supports osfamilies RedHat, Suse and Debian. Detected osfamily is <${::osfamily}>.")
    }
  }

  # Validation
  validate_re($ensure_state, '^(running)|(stopped)$', "cron::ensure_state is ${ensure_state} and must be running or stopped")
  validate_re($package_ensure, '^(present)|(absent)$', "cron::package_ensure is ${package_ensure} and must be absent or present")
  validate_re($cron_allow, '^(present)|(absent)$', "cron::cron_allow is ${cron_allow} and must be absent or present")
  validate_re($cron_deny, '^(present)|(absent)$', "cron::cron_deny is ${cron_deny} and must be absent or present")

  case type3x($enable_cron) {
    'string': {
      validate_re($enable_cron, '^(true|false)$', "cron::enable_cron may be either 'true' or 'false' and is set to <${enable_cron}>")
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
  }
  if $cron_deny_users != undef {
    validate_array($cron_deny_users)
  }
  if $cron_files != undef {
    create_resources(cron::fragment,$cron_files)
  }
  if $crontab_tasks != undef {
    validate_hash($crontab_tasks)
  }
  if $crontab_vars != undef {
    validate_hash($crontab_vars)
  }
  # End of validation

  file { 'cron_allow':
    ensure  => $cron_allow,
    path    => $cron_allow_path,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('cron/cron_allow.erb'),
    require => Package[$package_name],
  }

  file { 'cron_deny':
    ensure  => $cron_deny,
    path    => $cron_deny_path,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('cron/cron_deny.erb'),
    require => Package[$package_name],
  }

  package { $package_name:
    ensure => $package_ensure,
    name   => $package_name,
  }

  file { 'crontab':
    ensure  => present,
    path    => $crontab_path,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('cron/crontab.erb'),
    require => Package[$package_name],
  }

  service { 'cron':
    ensure    => $ensure_state,
    enable    => $enable_cron_real,
    name      => $service_name,
    require   => File['crontab'],
    subscribe => File['crontab'],
  }
}
