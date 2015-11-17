# == Define: cron::fragment
#
# Manage cron jobs in separate files
#
define cron::fragment (
  $ensure_cron  = 'absent',
  $type         = 'daily',
  $cron_content = '',
) {

  include cron

  validate_re($ensure_cron, '^(absent|file|present)$', "cron::fragment::ensure_cron is ${cron::fragment::cron_deny} and must be absent, file or present")
  if is_string($cron_content) == false { fail('cron::fragment::cron_content must be a string') }

  case $type {
    'd': {
      $cron_mode = '0644'
    }
    'daily','weekly','monthly','yearly': {
      $cron_mode = '0755'
    }
    default: {
      fail('Valid values are d, daily, weekly, monthly, yearly')
    }
  }

  file { "/etc/cron.${type}/${name}":
    ensure  => $ensure_cron,
    content => $cron_content,
    force   => true,
    owner   => 'root',
    group   => 'root',
    mode    => $cron_mode,
    require => File[crontab],
  }
}
