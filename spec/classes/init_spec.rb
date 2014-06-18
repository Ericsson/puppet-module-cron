require 'spec_helper'
describe 'cron' do

    let :facts do
      {
        :osfamily          => 'RedHat',
      }
    end
    context 'with default params' do
        it {
          should contain_file('crontab').with({
            'ensure'  => 'present',
            'path'    => '/etc/crontab',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
            'require' => 'Package[crontabs]',
          })
        }
        it {
          should contain_file('cron_allow').with({
            'ensure'  => 'absent',
            'path'    => '/etc/cron.allow',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
            'require' => 'Package[crontabs]',
          })
        }
       it {
          should contain_file('cron_deny').with({
            'ensure'  => 'absent',
            'path'    => '/etc/cron.deny',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
            'require' => 'Package[crontabs]',
          })
        }
    end
    context 'crontab_tasks is set to boolean on supported OS' do
    let :facts do
      {
        :osfamily          => 'ubuntu',
      }
    end
    let (:params) { { :cron_tasks => true } }
    it 'should fail' do
    expect {
          should contain_class('cron')
        }.to raise_error(Puppet::Error)
      end
    end
    
    context 'with unsupported osfamily' do
     let(:facts) do
     {  :osfamily => 'Solaris',
     }
     end
      it 'should fail' do
        expect {
          should contain_class('cron')
        }.to raise_error(Puppet::Error,/Module cron does not support osfamily: Solaris/)
     end
    end
   

end
