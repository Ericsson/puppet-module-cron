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

define cron::fragment (
  $ensure_cron  = 'absent',
  $type         = 'daily',
  $cron_content = '',
) {

  include cron

  if ! ($ensure_cron in [ 'present', 'absent' ]) {
    fail("cron::fragment:ensure_cron is ${ensure_cron} and must be absent or present")
  }
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

