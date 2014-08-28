require 'spec_helper'
describe 'cron::fragment' do

  let(:title) { 'example' }
  let(:facts) {{
    :osfamily => 'RedHat',
  }}


  context 'create file in /etc/cron.d/ from cron_content' do
    let(:params) {{
      :cron_content => '* * * * * root command',
      :type         => 'd',
      :ensure_cron  => 'present'
    }}

    it { should contain_class('cron') }

    it {
      should contain_file('/etc/cron.d/example').with({
        'ensure' => 'present',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0644',
      })
    }
    it { should contain_file('/etc/cron.d/example').with_content(%{* * * * * root command}) }
  end

  ['daily','weekly','monthly','yearly'].each do |value|
    context "create file in /etc/cron.#{value}/ from cron_content" do
      let(:title) { "example-#{value}" }
      let(:params) {{
        :cron_content => '* * * * * root command',
        :type         => "#{value}",
        :ensure_cron  => 'present',
      }}

      it { should contain_class('cron') }

      it {
        should contain_file("/etc/cron.#{value}/example-#{value}").with({
          'ensure' => 'present',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755',
        })
      }
      it { should contain_file("/etc/cron.#{value}/example-#{value}").with_content(%{* * * * * root command}) }
    end
  end

  context 'with ensure_cron specified as <absent>' do
    let(:params) {{
      :ensure_cron => 'absent',
      :type        => 'd',
    }}

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

  context 'with cron_content specified as invalid boolean <true>' do
    let(:params) {{
      :cron_content => true
    }}

    it 'should fail' do
      expect {
        should contain_class('cron')
      }.to raise_error(Puppet::Error,/is not a string./)
    end
  end

  context 'with type specified as invalid string <biweekly>' do
    let(:params) {{
      :type => 'biweekly'
    }}

    it 'should fail' do
      expect {
        should contain_class('cron')
      }.to raise_error(Puppet::Error,/Valid values are d, daily, weekly, monthly, yearly/)
    end
  end

  ['true',true,'false','delete'].each do |value|
    context "with ensure_cron specified as invalid value <#{value}>" do
      let(:params) {{
        :ensure_cron => value
      }}

      it 'should fail' do
        expect {
          should contain_class('cron')
        }.to raise_error(Puppet::Error,/cron::fragment::ensure_cron is #{value} and must be absent or present/)
      end
    end
  end
end
