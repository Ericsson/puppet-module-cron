# == Class: cron
#
# This module manages cron
#
class cron (
  $enable_cron        = true,
  $package_ensure     = 'present',
  $ensure_state       = 'running',
  $crontab_path       = '/etc/crontab',
  $crontab_owner      = 'root',
  $crontab_group      = 'root',
  $crontab_mode       = '0644',
  $cron_allow         = 'absent',
  $cron_deny          = 'absent',
  $cron_allow_path    = '/etc/cron.allow',
  $cron_allow_owner   = 'root',
  $cron_allow_group   = 'root',
  $cron_allow_mode    = '0644',
  $cron_deny_path     = '/etc/cron.deny',
  $cron_deny_owner    = 'root',
  $cron_deny_group    = 'root',
  $cron_deny_mode     = '0644',
  $cron_d_path        = '/etc/cron.d',
  $cron_hourly_path   = '/etc/cron.hourly',
  $cron_daily_path    = '/etc/cron.daily',
  $cron_weekly_path   = '/etc/cron.weekly',
  $cron_monthly_path  = '/etc/cron.monthly',
  $cron_dir_owner     = 'root',
  $cron_dir_group     = 'root',
  $cron_dir_mode      = '0755',
  $cron_files         = undef,
  $cron_allow_users   = undef,
  $cron_deny_users    = undef,
  $crontab_vars       = undef,
  $crontab_tasks      = undef,
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
    $cron_allow_real='present'
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
  if $crontab_tasks != undef {
    validate_hash($crontab_tasks)
  }
  if $crontab_vars != undef {
    validate_hash($crontab_vars)
  }

  validate_absolute_path($cron_allow_path)
  validate_absolute_path($cron_deny_path)
  validate_absolute_path($crontab_path)
  validate_absolute_path($cron_d_path)
  validate_absolute_path($cron_hourly_path)
  validate_absolute_path($cron_daily_path)
  validate_absolute_path($cron_weekly_path)
  validate_absolute_path($cron_monthly_path)

  if !is_string($crontab_owner) { fail('cron::crontab_owner must be a string') }
  if !is_string($cron_allow_owner) { fail('cron::cron_allow_owner must be a string') }
  if !is_string($cron_deny_owner) { fail('cron::cron_deny_owner must be a string') }
  if !is_string($cron_dir_owner) { fail('cron::cron_dir_owner must be a string') }
  if !is_string($crontab_group) { fail('cron::crontab_group must be a string') }
  if !is_string($cron_allow_group) { fail('cron::cron_allow_group must be a string') }
  if !is_string($cron_deny_group) { fail('cron::cron_deny_group must be a string') }
  if !is_string($cron_dir_group) { fail('cron::cron_dir_group must be a string') }

  validate_re($crontab_mode, '^[0-9][0-9][0-9][0-9]$', 'cron::crontab_mode must use the standard four-digit octal notation')
  validate_re($cron_dir_mode, '^[0-9][0-9][0-9][0-9]$', 'cron::cron_dir_mode must use the standard four-digit octal notation')
  validate_re($cron_allow_mode, '^[0-9][0-9][0-9][0-9]$', 'cron::cron_allow_mode must use the standard four-digit octal notation')
  validate_re($cron_deny_mode, '^[0-9][0-9][0-9][0-9]$', 'cron::cron_deny_mode must use the standard four-digit octal notation')

  # End of validation

  file { 'cron_allow':
    ensure  => $cron_allow_real,
    path    => $cron_allow_path,
    owner   => $cron_allow_owner,
    group   => $cron_allow_group,
    mode    => $cron_allow_mode,
    content => template('cron/cron_allow.erb'),
    require => Package[$package_name],
  }

  file { 'cron_deny':
    ensure  => $cron_deny_real,
    path    => $cron_deny_path,
    owner   => $cron_deny_owner,
    group   => $cron_deny_group,
    mode    => $cron_deny_mode,
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
    owner   => $crontab_owner,
    group   => $crontab_group,
    mode    => $crontab_mode,
    content => template('cron/crontab.erb'),
    require => Package[$package_name],
  }

  file { 'cron_d':
    ensure  => directory,
    path    => $cron_d_path,
    owner   => $cron_dir_owner,
    group   => $cron_dir_group,
    mode    => $cron_dir_mode,
    require => Package[$package_name],
  }

  file { 'cron_hourly':
    ensure  => directory,
    path    => $cron_hourly_path,
    owner   => $cron_dir_owner,
    group   => $cron_dir_group,
    mode    => $cron_dir_mode,
    require => Package[$package_name],
  }

  file { 'cron_daily':
    ensure  => directory,
    path    => $cron_daily_path,
    owner   => $cron_dir_owner,
    group   => $cron_dir_group,
    mode    => $cron_dir_mode,
    require => Package[$package_name],
  }

  file { 'cron_weekly':
    ensure  => directory,
    path    => $cron_weekly_path,
    owner   => $cron_dir_owner,
    group   => $cron_dir_group,
    mode    => $cron_dir_mode,
    require => Package[$package_name],
  }

  file { 'cron_monthly':
    ensure  => directory,
    path    => $cron_monthly_path,
    owner   => $cron_dir_owner,
    group   => $cron_dir_group,
    mode    => $cron_dir_mode,
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
