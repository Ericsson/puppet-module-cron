require 'spec_helper'
describe 'cron' do

  file_with_no_entries = File.read(fixtures('file_with_no_entries'))

  platforms = {
    'RedHat 6' =>
      {
        :osfamily     => 'RedHat',
        :osrelease    => '6.7',
        :package_name => 'crontabs',
        :service_name => 'crond',
      },
    'Suse 11' =>
      {
        :osfamily     => 'Suse',
        :osrelease    => '11.3',
        :package_name => 'cron',
        :service_name => 'cron',
      },
    'Suse 12' =>
      {
        :osfamily     => 'Suse',
        :osrelease    => '12.1',
        :package_name => 'cronie',
        :service_name => 'cron',
      },
    'Debian 7' =>
      {
        :osfamily     => 'Debian',
        :osrelease    => '7.9',
        :package_name => 'cron',
        :service_name => 'cron',
      },
  }

  describe 'with default values for parameters' do
    platforms.sort.each do |k,v|
      context "running on #{k}" do
        let :facts do
          {
            :osfamily               => v[:osfamily],
            :operatingsystemrelease => v[:osrelease],
          }
        end

        it {
          should contain_file('cron_allow').with({
            'ensure'  => 'absent',
            'path'    => '/etc/cron.allow',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
            'require' => "Package[#{v[:package_name]}]",
          })
        }

        it {
          should contain_file('cron_deny').with({
            'ensure'  => 'present',
            'path'    => '/etc/cron.deny',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
            'require' => "Package[#{v[:package_name]}]",
          })
        }

        it {
          should contain_package("#{v[:package_name]}").with({
            'ensure' => 'installed',
            'name'   => v[:package_name],
          })
        }

        it {
          should contain_file('crontab').with({
            'ensure'  => 'present',
            'path'    => '/etc/crontab',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
            'require' => "Package[#{v[:package_name]}]",
          })
        }

        it {
          should contain_file('cron_d').with({
            'ensure'  => 'directory',
            'path'    => '/etc/cron.d',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0755',
            'require' => "Package[#{v[:package_name]}]",
          })
        }

        it {
          should contain_file('cron_hourly').with({
            'ensure'  => 'directory',
            'path'    => '/etc/cron.hourly',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0755',
            'require' => "Package[#{v[:package_name]}]",
          })
        }

        it {
          should contain_file('cron_daily').with({
            'ensure'  => 'directory',
            'path'    => '/etc/cron.daily',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0755',
            'require' => "Package[#{v[:package_name]}]",
          })
        }

        it {
          should contain_file('cron_weekly').with({
            'ensure'  => 'directory',
            'path'    => '/etc/cron.weekly',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0755',
            'require' => "Package[#{v[:package_name]}]",
          })
        }

        it {
          should contain_file('cron_monthly').with({
            'ensure'  => 'directory',
            'path'    => '/etc/cron.monthly',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0755',
            'require' => "Package[#{v[:package_name]}]",
          })
        }

        it {
          should contain_service('cron').with({
            'ensure'    => 'running',
            'enable'    => true,
            'name'      => v[:service_name],
            'require'   => 'File[crontab]',
            'subscribe' => 'File[crontab]',
          })
        }

      end
    end
  end

  describe 'with optional parameters set' do
    platforms.sort.each do |k,v|
      context "running on #{k}" do
        let :facts do
          {
            :osfamily               => v[:osfamily],
            :operatingsystemrelease => v[:osrelease],
          }
        end

        context 'where enable_cron is <false>' do
          let :params do
            {
              :enable_cron => 'false',
            }
          end

          it {
            should contain_service('cron').with({
              'ensure'  => 'running',
              'enable'  => false,
              'name'    => v[:service_name],
              'require'   => 'File[crontab]',
              'subscribe' => 'File[crontab]',
            })
          }
        end

        context 'where service_name is set' do
          let :params do
            {
              :service_name => 'cron2',
            }
          end

          it {
            should contain_service('cron').with({
              'ensure'    => 'running',
              'enable'    => true,
              'name'      => 'cron2',
              'require'   => 'File[crontab]',
              'subscribe' => 'File[crontab]',
            })
          }
        end

        context 'where package_ensure is <absent>' do
          let :params do
            {
              :package_ensure => 'absent',
            }
          end

          it {
            should contain_package("#{v[:package_name]}").with({
              'ensure' => 'absent',
              'name'   => v[:package_name],
            })
          }
        end

        context 'where package_name is set' do
          let :params do
            {
              :package_name => 'cron2',
            }
          end

          it {
            should contain_package('cron2').with({
              'ensure' => 'installed',
            })
          }

          ['cron_allow','cron_deny','crontab','cron_d','cron_hourly','cron_daily','cron_weekly','cron_monthly'].each do |filename|
            it { should contain_file(filename).with_require('Package[cron2]') }
          end
        end

        context 'where ensure_state is <stopped>' do
          let :params do
            {
              :ensure_state => 'stopped',
            }
          end

          it {
            should contain_service('cron').with({
              'ensure'    => 'stopped',
              'enable'    => true,
              'name'      => v[:service_name],
              'require'   => 'File[crontab]',
              'subscribe' => 'File[crontab]',
            })
          }
        end

        context 'where crontab_path is </somewhere/else>' do
          let :params do
            {
              :crontab_path => '/somewhere/else',
            }
          end

          it {
            should contain_file('crontab').with({
              'ensure'  => 'present',
              'path'    => '/somewhere/else',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'require' => "Package[#{v[:package_name]}]",
            })
          }
        end

        context 'where crontab file attributes are specified' do
          let :params do
            {
              :crontab_owner => 'other',
              :crontab_group => 'other',
              :crontab_mode => '0640',
            }
          end

          it {
            should contain_file('crontab').with({
              'ensure'  => 'present',
              'path'    => '/etc/crontab',
              'owner'   => 'other',
              'group'   => 'other',
              'mode'    => '0640',
              'require' => "Package[#{v[:package_name]}]",
            })
          }
        end

        context 'where cron_allow is <present>' do
          let :params do
            {
              :cron_allow => 'present',
            }
          end

          it {
            should contain_file('cron_allow').with({
              'ensure'  => 'present',
              'path'    => '/etc/cron.allow',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'require' => "Package[#{v[:package_name]}]",
            })
          }

          it { should contain_file('cron_allow').with_content(file_with_no_entries) }
        end

        context 'where cron_allow is <absent>' do
          let :params do
            {
              :cron_allow => 'absent',
            }
          end

          it {
            should contain_file('cron_allow').with({
              'ensure'  => 'absent',
              'path'    => '/etc/cron.allow',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'require' => "Package[#{v[:package_name]}]",
            })
          }
        end

        context 'where cron_deny is <present>' do
          let :params do
            {
              :cron_deny => 'present',
            }
          end

          it {
            should contain_file('cron_deny').with({
              'ensure'  => 'present',
              'path'    => '/etc/cron.deny',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'require' => "Package[#{v[:package_name]}]",
            })
          }

          it { should contain_file('cron_deny').with_content(file_with_no_entries) }
        end

        context 'where cron_deny is <absent>' do
          let :params do
            {
              :cron_deny => 'absent',
            }
          end

          it {
            should contain_file('cron_deny').with({
              'ensure'  => 'absent',
              'path'    => '/etc/cron.deny',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'require' => "Package[#{v[:package_name]}]",
            })
          }
        end

        context 'where cron_allow_path is </somwhere/else/allow>' do
          let :params do
            {
              :cron_allow_path => '/somwhere/else/allow',
            }
          end

          it {
            should contain_file('cron_allow').with({
              'ensure'  => 'absent',
              'path'    => '/somwhere/else/allow',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'require' => "Package[#{v[:package_name]}]",
            })
          }
        end

        context 'where cron_allow file attributes are specified' do
          let :params do
            {
              :cron_allow_owner => 'other',
              :cron_allow_group => 'other',
              :cron_allow_mode => '0640',
            }
          end

          it {
            should contain_file('cron_allow').with({
              'ensure'  => 'absent',
              'path'    => '/etc/cron.allow',
              'owner'   => 'other',
              'group'   => 'other',
              'mode'    => '0640',
              'require' => "Package[#{v[:package_name]}]",
            })
          }
        end

        context 'where cron_deny_path is </somewhere/else/deny>' do
          let :params do
            {
              :cron_deny_path => '/somewhere/else/deny',
            }
          end

          it {
            should contain_file('cron_deny').with({
              'ensure'  => 'present',
              'path'    => '/somewhere/else/deny',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'require' => "Package[#{v[:package_name]}]",
            })
          }
        end

        context 'where cron_deny file attributes are specified' do
          let :params do
            {
              :cron_deny_owner => 'other',
              :cron_deny_group => 'other',
              :cron_deny_mode => '0640',
            }
          end
          it {
            should contain_file('cron_deny').with({
              'ensure'  => 'present',
              'path'    => '/etc/cron.deny',
              'owner'   => 'other',
              'group'   => 'other',
              'mode'    => '0640',
              'require' => "Package[#{v[:package_name]}]",
            })
          }
        end

        context 'where cron.d file attributes are specified' do
          let :params do
            {
              :cron_d_path  => '/other/cron.d',
              :cron_dir_owner => 'other',
              :cron_dir_group => 'other',
              :cron_dir_mode  => '0750',
            }
          end

          it {
            should contain_file('cron_d').with({
              'ensure'  => 'directory',
              'path'    => '/other/cron.d',
              'owner'   => 'other',
              'group'   => 'other',
              'mode'    => '0750',
              'require' => "Package[#{v[:package_name]}]",
            })
          }
        end

        context 'where cron.hourly file attributes are specified' do
          let :params do
            {
              :cron_hourly_path  => '/other/cron.hourly',
              :cron_dir_owner => 'other',
              :cron_dir_group => 'other',
              :cron_dir_mode  => '0750',
            }
          end

          it {
            should contain_file('cron_hourly').with({
              'ensure'  => 'directory',
              'path'    => '/other/cron.hourly',
              'owner'   => 'other',
              'group'   => 'other',
              'mode'    => '0750',
              'require' => "Package[#{v[:package_name]}]",
            })
          }
        end

        context 'where cron.daily file attributes are specified' do
          let :params do
            {
              :cron_daily_path  => '/other/cron.daily',
              :cron_dir_owner => 'other',
              :cron_dir_group => 'other',
              :cron_dir_mode  => '0750',
            }
          end

          it {
            should contain_file('cron_daily').with({
              'ensure'  => 'directory',
              'path'    => '/other/cron.daily',
              'owner'   => 'other',
              'group'   => 'other',
              'mode'    => '0750',
              'require' => "Package[#{v[:package_name]}]",
            })
          }
        end

        context 'where cron.weekly file attributes are specified' do
          let :params do
            {
              :cron_weekly_path  => '/other/cron.weekly',
              :cron_dir_owner => 'other',
              :cron_dir_group => 'other',
              :cron_dir_mode  => '0750',
            }
          end

          it {
            should contain_file('cron_weekly').with({
              'ensure'  => 'directory',
              'path'    => '/other/cron.weekly',
              'owner'   => 'other',
              'group'   => 'other',
              'mode'    => '0750',
              'require' => "Package[#{v[:package_name]}]",
            })
          }
        end

        context 'where cron.monthly file attributes are specified' do
          let :params do
            {
              :cron_monthly_path  => '/other/cron.monthly',
              :cron_dir_owner => 'other',
              :cron_dir_group => 'other',
              :cron_dir_mode  => '0750',
            }
          end

          it {
            should contain_file('cron_monthly').with({
              'ensure'  => 'directory',
              'path'    => '/other/cron.monthly',
              'owner'   => 'other',
              'group'   => 'other',
              'mode'    => '0750',
              'require' => "Package[#{v[:package_name]}]",
            })
          }
        end

# TODO: test for cron_files

        context 'where cron_allow is <present> and cron_allow_users is <[ \'Tintin\', \'Milou\' ]>' do
          let :params do
            {
              :cron_allow       => 'present',
              :cron_allow_users => [ 'Tintin', 'Milou', ],
            }
          end

          it {
            should contain_file('cron_allow').with({
              'ensure'  => 'present',
              'path'    => '/etc/cron.allow',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'require' => "Package[#{v[:package_name]}]",
            })
          }
          it { should contain_file('cron_allow').with_content(/^Tintin\nMilou$/) }
        end

        context 'where cron_deny_users is <[ \'nobody\', \'anyone\' ]>' do
          let :params do
            {
              :cron_deny_users => [ 'nobody', 'anyone', ],
            }
          end

          it {
            should contain_file('cron_deny').with({
              'ensure'  => 'present',
              'path'    => '/etc/cron.deny',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'require' => "Package[#{v[:package_name]}]",
            })
          }
          it { should contain_file('cron_deny').with_content(/^nobody\nanyone$/) }
        end

        context 'where crontab_vars is <{ \'MAILTO\' => \'operator\', \'SHELL\' => \'/bin/tcsh\' }>' do
          let :params do
            {
              :crontab_vars => {
                'MAILTO' => 'operator',
                'SHELL'  => '/bin/tcsh',
              }
            }
          end

          it {
            should contain_file('crontab').with({
              'ensure'  => 'present',
              'path'    => '/etc/crontab',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'require' => "Package[#{v[:package_name]}]",
            })
          }
          it { should contain_file('crontab').with_content(/^MAILTO=operator\nSHELL=\/bin\/tcsh$/) }
        end

        context 'where crontab_tasks is <{ spec_test => [ \'42 * * * * nobody echo task1\' ]>' do
          let :params do
            {
              :crontab_tasks => {
                'spec_test' => [ '42 * * * * nobody echo task1' ],
              }
            }
          end

          it {
            should contain_file('crontab').with({
              'ensure'  => 'present',
              'path'    => '/etc/crontab',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'require' => "Package[#{v[:package_name]}]",
            })
          }
          it { should contain_file('crontab').with_content(/^# spec_test\n42 \* \* \* \* nobody echo task1$/) }

        end
      end
    end
  end

  describe 'variable type and content validations' do
    # set needed custom facts and variables
    let(:facts) { {
      :osfamily => 'RedHat',
    } }
    let(:validation_params) { {
#      :param => 'value',
    } }

    validations = {
      'absolute_path' => {
        :name    => ['cron_allow_path','cron_deny_path','crontab_path','cron_d_path','cron_hourly_path','cron_daily_path','cron_weekly_path','cron_monthly_path'],
        :valid   => ['/absolute/filepath','/absolute/directory/'],
        :invalid => ['./invalid',['array'],a={'ha'=>'sh'},3,2.42,true,false,nil],
        :message => 'is not an absolute path',
      },
      'array' => {
        :name    => ['cron_allow_users','cron_deny_users'],
        :valid   => [['array'],['val','id']],
        :invalid => ['string',inv={'al'=>'id'},3,2.42,true,false,nil],
        :message => 'is not an Array',
      },
      # enhancement: validate $cron_files
      'hash' => {
        :name    => ['crontab_tasks','crontab_vars'],
        :valid   => [a={'hash'=>['with','nested','array']} ],
        :invalid => ['string',['array'],3,2.42,true,false,nil],
        :message => 'is not a Hash',
      },
      # enhancement: should also allow 'file'
      'regex_file_ensure' => {
        :name    => ['cron_allow','cron_deny'],
        :valid   => ['present','absent'],
        :invalid => ['invalid','directory','link',['array'],a={'ha'=>'sh'},3,2.42,true,false,nil],
        :message => 'must be absent or present',
      },
      # enhancement: only allow 0-7 instead of 0-9 in regex
      'regex_file_mode' => {
        :name    => ['crontab_mode','cron_dir_mode','cron_allow_mode','cron_deny_mode'],
        :valid   => ['0755','0644','0242'],
        :invalid => ['invalid','755',['array'],a={'ha'=>'sh'},3,2.42,true,false,nil],
        :message => 'must use the standard four-digit octal notation',
      },
      'regex_package_ensure' => {
        :name    => ['package_ensure'],
        :valid   => ['present','installed','absent'],
        :invalid => ['invalid','purged','held','latest',['array'],a={'ha'=>'sh'},3,2.42,true,false,nil],
        :message => 'must be absent, present or installed',
      },
      # enhancement: should be renamed to $service_enable
      #              align error messages
      'regex_service_enable' => {
        :name    => ['enable_cron'],
        :valid   => ['true','false',true,false],
        :invalid => ['invalid',['array'],a={'ha'=>'sh'},3,2.42,nil],
        :message => 'true[\']? or [\']?false',
      },
      # enhancement: should be renamed to $service_ensure
      'regex_service_ensure' => {
        :name    => ['ensure_state'],
        :valid   => ['stopped','running'],
        :invalid => ['invalid','true','false',['array'],a={'ha'=>'sh'},3,2.42,true,false,nil],
        :message => 'must be running or stopped',
      },
      'string' => {
        :name    => ['crontab_owner','cron_allow_owner','cron_deny_owner','cron_dir_owner','crontab_group','cron_allow_group','cron_deny_group','cron_dir_group'],
        :valid   => ['valid'],
        :invalid => [['array'],a={'ha'=>'sh'},3,2.42,true,false],
        :message => 'must be a string',
      },
    }

    validations.sort.each do |type,var|
      var[:name].each do |var_name|

        var[:valid].each do |valid|
          context "with #{var_name} (#{type}) set to valid #{valid} (as #{valid.class})" do
            let(:params) { validation_params.merge({:"#{var_name}" => valid, }) }
            it { should compile }
          end
        end

        var[:invalid].each do |invalid|
          context "with #{var_name} (#{type}) set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { validation_params.merge({:"#{var_name}" => invalid, }) }
            it 'should fail' do
              expect {
                should contain_class(subject)
              }.to raise_error(Puppet::Error,/#{var[:message]}/)
            end
          end
        end

      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'
end
