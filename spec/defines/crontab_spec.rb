require 'spec_helper'
describe 'cron::user::crontab' do

  let(:title) { 'operator' }
  let(:facts) do
    {
      :osfamily               => 'RedHat',
      :operatingsystemrelease => '6.7',
    }
  end

  context 'with parameters set' do
    context 'when ensure, owner, group and mode are set' do
      let (:params) do
        {
          :ensure  => 'file',
          :owner   => 'operator',
          :group   => 'operator',
          :mode    => '0242',
        }
      end
      
      it {
        should contain_file('/var/spool/cron/operator').with({
          'ensure'  => 'file',
          'owner'   => 'operator',
          'group'   => 'operator',
          'mode'    => '0242',
        })
      }      
    end
    
    context 'with entries set' do
      let (:params) do
        {
          :ensure  => 'file',
          :owner   => 'operator',
          :group   => 'operator',
          :mode    => '0242',
          :content => "# Echo Hello World\n* 1 * * * $MYECHO \"Hello World!\" 2>&1", 
        }
      end
      
      it { should contain_file('/var/spool/cron/operator').with_content("# Echo Hello World\n* 1 * * * $MYECHO \"Hello World!\" 2>&1") }
      
    end
    
    context 'with vars set' do
      let (:params) do
        {
          :ensure  => 'file',
          :owner   => 'operator',
          :group   => 'operator',
          :mode    => '0242',
          :content => 'SHELL=/bin/bash',
        }
      end
      
      it { should contain_file('/var/spool/cron/operator').with_content("SHELL=/bin/bash") }    
    end      
  end      

end
