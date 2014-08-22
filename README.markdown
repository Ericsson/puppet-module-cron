# puppet-module-cron

Manage the cron configuration files : 

/etc/crontab
/etc/cron.allow
/etc/cron.deny
/etc/cron.d/ 
/etc/cron.daily 
/etc/cron.weekly
/etc/cron.monthly
/etc/cron.yearly


===

# Compatability

This module has been tested to work on the following systems with Puppet v3 and Ruby versions 1.8.7, 1.9.3 and 2.0.0.

 * EL 5
 * EL 6
 * SLES 10
 * SLES 11
 * Ubuntu 12

===

# Parameters
A value of `'undef'` will use the defaults specified by the module.


enable_cron
---------------
Boolean to enable the service cron. Valid values are true, false

- *Default*: true

package_ensure
----------------
What state the package should be in. Valid values are 'present', 'absent', 'purged', 'held' and 'latest'.

- *Default*: 'present'

ensure_state
---------------
What state the cron service should be in. Valid values are 'running' and 'stopped'.

- *Default*: 'running'

crontab_path
---------------
crontab's path.

- *Default*: '/etc/crontab'

cron_allow
--------------
If the file cron.allow exists, only users listed in it are allowed to use cron, and the cron.deny file is ignored. Valid values are 'present' and 'absent'.

- *Default*: 'absent'

cron_deny
------------
If cron.allow does not exist, users listed in cron.deny are not allowed to use cron. Valid values are 'present' and 'absent'.

- *Default*: 'absent'

cron_allow_path
---------------
Path of cron.allow.

- *Default*: '/etc/cron.allow'

cron_deny_path
--------------
Path of cron.deny.

- *Default*: '/etc/cron.deny'

crontab_vars
-------------
Defines the crontab variables SHELL, PATH, MAILTO, HOME. if this variable is undef the module will use the values defined in crontab template which are SHELL=/bin/bash, PATH=/sbin:/bin:/usr/sbin:/usr/bin, MAILTO=root, HOME=/, valid value is hash.

- *Default*: undef

crontab_tasks
----------------
Define crontab tasks. valid value is hash.

- *Default*: undef

## Sample usage:

define crontab variables
<pre>
cron::crontab_vars:
  SHELL: /bin/bash
  PATH: /sbin:/bin:/usr/sbin:/usr/bin
  MAILTO: root
  HOME: /root
</pre>
create /etc/cron.daily/daily_task
<pre>
cron::cron_files:
     'daily_task':
       ensure_cron: 'present'
       type: "daily"
       cron_content: |-
            #!/bin/bash
            # This File is managed by puppet
            script
            .
            EOF
</pre>

manage /etc/cron.allow

<pre>
cron::cron_allow: 'true'
cron::cron_allow_users:
     - user1

</pre>

manage /etc/cron.deny
<pre>
cron::cron_deny: 'present'
cron::cron_deny_users:
     - user1
</pre>

manage /etc/crontab
<pre>
cron::crontab_tasks:
   'task1':
    - "* 12 * * 7 username echo 'Hello World'"
    - "2 2 * * 6 username echo 'tes'"
   'task2':
    - "* 6 * * 7 root echo 'test'"
</pre>
