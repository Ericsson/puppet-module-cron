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

define cron::var_spool_cron (
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
}# End of var_spool_cron

