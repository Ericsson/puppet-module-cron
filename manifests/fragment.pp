# == Class cron::fragment
#
# manage cron jobs in separate files
#
define cron::fragment (
  $ensure_cron  = 'absent',
  $type         = 'daily',
  $cron_content = '',
) {

  include cron

  validate_re($ensure_cron, '^(absent)|(present)$', "cron::fragment::ensure_cron is ${ensure_cron} and must be absent or present")
  validate_string($cron_content)

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
    require => Package[$cron::package_name],
  }


}

