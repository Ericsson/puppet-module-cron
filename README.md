# puppet-module-cron

Manage the cron configuration files.

- /etc/crontab
- /etc/cron.allow
- /etc/cron.deny
- /etc/cron.d/
- /etc/cron.daily
- /etc/cron.weekly
- /etc/cron.monthly
- /etc/cron.yearly


===

# Compatibility

This module has been tested to work on the following systems with Puppet v3
(with and without the future parser) and Puppet v4 with Ruby versions 1.8.7,
1.9.3, 2.0.0 and 2.1.0.

 * EL 5
 * EL 6
 * SLES 10
 * SLES 11
 * Ubuntu 12

Note that SLES patches ISC's cron such that if cron.allow and cron.deny are
both missing, then root will not be able to access the crontabs. This will
cause errors. Please see the Hiera example below.

===

# Parameters
A value of `'undef'` will use the defaults specified by the module.


enable_cron
-----------
Boolean to enable the cron service.

- *Default*: true

package_ensure
--------------
String for the ensure parameter for the cron package. Valid values are 'present', 'absent', 'purged', 'held' and 'latest'.

- *Default*: 'present'

ensure_state
------------
String for the ensure parameter for the cron service. Valid values are 'running' and 'stopped'.

- *Default*: 'running'

crontab_path
------------
String for path to system wide crontab.

- *Default*: '/etc/crontab'

cron_allow
----------
If the file cron.allow exists, only users listed in it are allowed to use cron,
and the cron.deny file is ignored. Valid values are 'present' and 'absent'.

- *Default*: 'absent'

cron_deny
---------
If cron.allow does not exist, users listed in cron.deny are not allowed to use
cron. Valid values are 'present' and 'absent'.

- *Default*: 'present'

cron_allow_path
---------------
Path to cron.allow.

- *Default*: '/etc/cron.allow'

cron_deny_path
--------------
Path to cron.deny.

- *Default*: '/etc/cron.deny'

crontab_vars
------------
Hash that defines the crontab variables SHELL, PATH, MAILTO, HOME. if this variable is undef the module will use the values defined in crontab template which are SHELL=/bin/bash, PATH=/sbin:/bin:/usr/sbin:/usr/bin, MAILTO=root, HOME=/

- *Default*: undef

crontab_tasks
-------------
Hash for crontab tasks.

- *Default*: undef

## Sample usage:

**Work on Suse**
<pre>
cron::cron_allow: 'present'
cron::cron_allow_users:
  - root
</pre>

**Define crontab variables**
<pre>
cron::crontab_vars:
  SHELL: /bin/bash
  PATH: /sbin:/bin:/usr/sbin:/usr/bin
  MAILTO: root
  HOME: /root
</pre>

**Create /etc/cron.daily/daily_task**
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

**Manage /etc/cron.allow**
<pre>
cron::cron_allow: 'present'
cron::cron_allow_users:
     - user1

</pre>

**Manage /etc/cron.deny**
<pre>
cron::cron_deny: 'present'
cron::cron_deny_users:
     - user1
</pre>

**Manage /etc/crontab**
<pre>
cron::crontab_tasks:
   'task1':
    - "* 12 * * 7 username echo 'Hello World'"
    - "2 2 * * 6 username echo 'tes'"
   'task2':
    - "* 6 * * 7 root echo 'test'"
</pre>
