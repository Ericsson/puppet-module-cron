# == Define: cron::fragment
#
# Manage cron jobs in separate files
#
define cron::fragment (
  $ensure       = 'absent',
  $content      = '',
  $type         = 'daily',
  # deprecated
  $ensure_cron  = undef,
  $cron_content = undef,
) {

  if $ensure_cron != undef {
    notify { '*** DEPRECATION WARNING***: $cron::fragment::ensure_cron was renamed to $ensure. Please update your configuration. Support for $ensure_cron will be removed in the near future!': }
    $ensure_real = $ensure_cron
  } else {
    $ensure_real = $ensure
  }

  if $cron_content != undef {
    notify { '*** DEPRECATION WARNING***: $cron::fragment::cron_content was renamed to $content. Please update your configuration. Support for $cron_content will be removed in the near future!': }
    $content_real = $cron_content
  } else {
    $content_real = $content
  }

  include cron

  validate_re($ensure_real, '^(absent|file|present)$', "cron::fragment::ensure is ${ensure} and must be absent, file or present")
  if is_string($content_real) == false { fail('cron::fragment::content must be a string') }

  case $type {
    'd': {
      $cron_mode = '0644'
    }
    'daily','weekly','monthly','yearly': {
      $cron_mode = '0755'
    }
    default: {
      fail("cron::fragment::type is ${type} and must be d, daily, monthly, weekly or yearly")
    }
  }

  file { "/etc/cron.${type}/${name}":
    ensure  => $ensure_real,
    content => $content_real,
    force   => true,
    owner   => 'root',
    group   => 'root',
    mode    => $cron_mode,
    require => File[crontab],
  }
}
