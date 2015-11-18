# == Define: cron::fragment
#
# Manage cron jobs in separate files
#
define cron::fragment (
  $ensure       = 'absent',
  $content      = '',
  $type         = 'daily',
) {

  include cron

  validate_re($ensure, '^(absent|file|present)$', "cron::fragment::ensure is ${ensure} and must be absent, file or present")
  if is_string($content) == false { fail('cron::fragment::content must be a string') }

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
    ensure  => $ensure,
    content => $content,
    force   => true,
    owner   => 'root',
    group   => 'root',
    mode    => $cron_mode,
    require => File[crontab],
  }
}
