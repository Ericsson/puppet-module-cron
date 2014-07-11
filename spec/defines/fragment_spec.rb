require 'spec_helper'
describe 'cron::fragment' do

  context 'create file from content' do
    let(:title) { 'example' }
    let(:params) {
      { :cron_content => '* * * * * root command',
        :type    => 'd',
        :ensure_cron => 'present'
      }
    }
    let(:facts) {
      {
        :osfamily          => 'RedHat',
      }
    }

    it { should contain_class('cron') }

    it {
      should contain_file('/etc/cron.d/example').with({
        'ensure'  => 'present',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
      })
    }
    it { should contain_file('/etc/cron.d/example').with_content(%{* * * * * root command})
    }
  end

  context 'with content specified as invalid string' do
    let(:title) { 'example' }
    let(:facts) {
      { :osfamily          => 'RedHat',
        :lsbmajdistrelease => '6',
      }
    }
    let(:params) {
      { :content => true
      }
    }

    it 'should fail' do
      expect {
        should contain_class('cron')
      }.to raise_error(Puppet::Error)
    end
  end

  context 'with ensure specified as absent' do
    let(:title) { 'example' }
    let(:facts) {
      { :osfamily          => 'RedHat',
        :lsbmajdistrelease => '6',
      }
    }

    let(:params) {
      { :ensure_cron => 'absent',
        :type        => 'd',
      }
    }

    it { should contain_class('cron') }

    it {
      should contain_file('/etc/cron.d/example').with({
        'ensure'  => 'absent',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
      })
    }
  end

  ['true',true,'present'].each do |value|
    context "with ensure specified as invalid value (#{value})" do
      let(:title) { 'example' }
      let(:facts) {
        { :osfamily          => 'RedHat',
          :lsbmajdistrelease => '6',
        }
      }
      let(:params) { { :ensure => value } }

      it 'should fail' do
        expect {
          should contain_class('cron')
        }.to raise_error(Puppet::Error)
      end
    end
  end
end

