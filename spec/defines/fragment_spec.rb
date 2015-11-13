require 'spec_helper'
describe 'cron::fragment' do

  let(:title) { 'example' }
  let(:facts) { { :osfamily => 'RedHat' } }

  context 'with default values for parameters on valid OS' do
    it { should compile.with_all_deps }
    it { should contain_class('cron') }
    it {
      should contain_file('/etc/cron.daily/example').with({
        'ensure'  => 'absent',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0755',
        'content' => '',
        'require' => 'File[crontab]',
      })
    }
  end

  context 'with optional parameters set' do
    context 'with cron_content set to <0 0 2 4 2 root command>' do
      let(:params) { { :cron_content => '0 0 2 4 2 root command' } }
      it { should contain_file('/etc/cron.daily/example').with_content('0 0 2 4 2 root command') }
    end

    context 'with ensure_cron set to <present>' do
      let(:params) { { :ensure_cron => 'present' } }
      it { should contain_file('/etc/cron.daily/example').with_ensure('present') }
    end

    ['d','daily','monthly','weekly','yearly'].each do |interval|
      context "when type is set to <#{interval}>" do
        let (:params) { { :type => "#{interval}"} }

        if interval == 'd'
          filemode = '0644'
        else
          filemode = '0755'
        end
        it { should contain_file("/etc/cron.#{interval}/example").with_mode(filemode) }
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
      'regex_file_ensure' => {
        :name    => ['ensure_cron'],
        :valid   => ['present','absent'],
        :invalid => ['invalid','directory','link',['array'],a={'ha'=>'sh'},3,2.42,true,false,nil],
        :message => 'must be absent or present',
      },
      'regex_type' => {
        :name    => ['type'],
        :valid   => ['d','daily','monthly','weekly','yearly'],
        :invalid => ['biweekly','hourly',['array'],a={'ha'=>'sh'},3,2.42,true,false,nil],
        :message => 'Valid values are d, daily, weekly, monthly, yearly',
      },
      'string' => {
        :name    => ['cron_content'],
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
