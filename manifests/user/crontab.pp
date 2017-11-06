# == Class: cron::user::crontab
#
#  About:  This class is to manage user crontabs.
#
#  Purpose:  Often application teams or application users
#            have crontabs that must execute as the application user.
#            For example:  DBAs may want to execute crontab entries
#            as the user oracle, mysql, etc.  Same goes with other 
#            commercial and proprietary applications operating in a 
#            Least Required Permissions model.
#
#  Usage:
#      $user_crontabs => {
#          'user1' => {'vars' => [ 'SHELL=/bin/bash', 'MYECHO=$(which echo)' ], 'entries' => [ '# Echo Hello World', '* 1 * * * $MYECHO "Hello World!"' ]},
#          'user2' => {'vars' => [ 'SHELL=/bin/bash', 'MYECHO=$(which echo)' ], 'entries' => [ '# Echo Hello World', '* 3 * * * $MYECHO "Hello user2!"' ]}
#      }
#      create_resources(cron::user::crontab, $user_crontabs)
#
# 
#  Hiera data structure to be used by the parent class cron:
#      cron::user_crontabs:
#        'user1':
#          vars:
#            -  'SHELL=/bin/bash'
#            -  'MYECHO=$(which echo)'
#          entries:
#            '# Echo Hello World': '* 1 * * * $MYECHO "Hello World!" 2>&1'
#        'user2':
#          vars:
#            -  'SHELL=/bin/bash'
#            -  'MYECHO=$(which echo)'
#          entries:
#            '# Echo Hello World': '* 3 * * * $MYECHO "Hello user2!" 2>&1'
#   
#
#
class cron::user::crontabs (
  $ensure  = file,
  $owner   = undef,
  $group   = undef,
  $mode    = '0600',
  $path    = $cron::user_crontab_path,
  $content = template('cron/usercrontab.erb'),
  $vars    = undef,
  $entries = undef,
){
  
  include ::cron
  
  if $owner == undef { $myowner = $name }
  if $group == undef { $mygroup = $name }
  if is_string($owner) == false { fail('cron::fragment::owner must be a string') }
  if is_string($group) == false { fail('cron::fragment::group must be a string') }
      
  validate_absolute_path($path)
  validate_re($ensure, '^(absent|file|present)$', "cron::fragment::ensure is ${ensure} and must be absent, file or present")
  validate_re($mode, '^[0-7]{4}$', "cron::fragment::mode is <${mode}> and must be a valid four digit mode in octal notation.")
      
  file {'${path}/${name}':
    ensure  => file,
    path    => $path,
    owner   => $myowner,
    group   => $mygroup,
    mode    => $mode,
    content => $content,
    require => File[crontab]
  }  
  
}
