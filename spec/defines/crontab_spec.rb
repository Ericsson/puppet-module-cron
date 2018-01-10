require 'spec_helper'
describe 'cron::user::crontab' do

  platforms = {
    'Debian' => {
      :facts_hash => {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '8.0',
      },
      :path_default => '/var/spool/cron/crontabs'
    },
    'RedHat' => {
      :facts_hash => {
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '6.7',
      },
      :path_default => '/var/spool/cron'
    },
    'Suse' => {
      :facts_hash => {
        :osfamily               => 'Suse',
        :operatingsystemrelease => '12.1',
      },
      :path_default => '/var/spool/cron/tabs'
    },
  }

  let(:title) { 'operator' }

  let(:facts) do
    platforms['RedHat'][:facts_hash]
  end

  crontab_default = <<-END.gsub(/^\s+\|/, '')
    |# This file is being maintained by Puppet.
    |# DO NOT EDIT
    |
    |SHELL=/bin/bash
    |PATH=/sbin:/bin:/usr/sbin:/usr/bin
    |MAILTO=root
    |HOME=/
    |# For details see man 4 crontabs
    |
    |# Example of job definition:
    |# .---------------- minute (0 - 59)
    |# |  .------------- hour (0 - 23)
    |# |  |  .---------- day of month (1 - 31)
    |# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
    |# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
    |# |  |  |  |  |
    |# *  *  *  *  * user-name command to be executed
    |
  END

  platforms.sort.each do |osfamily,v|
    describe "with default values for parameters on valid osfamily #{osfamily}" do
      let(:facts) { v[:facts_hash] }

      it { should compile.with_all_deps }
      it { should contain_class('cron') }

      it do
        should contain_file("#{v[:path_default]}/operator").with({
          'ensure'  => 'file',
          'owner'   => 'operator',
          'group'   => 'operator',
          'mode'    => '0600',
          'content' => crontab_default,
          'require' => 'File[crontab]',
        })
      end
    end
  end

  %w(absent file present).each do |value|
    context "with ensure set to valid string #{value}" do
      let(:params) { { :ensure => value } }
      it {  should contain_file('/var/spool/cron/operator').with_ensure(value) }
    end
  end

  context 'with owner set to valid string spectester' do
    let(:params) { { :owner => 'spectester' } }
    it {  should contain_file('/var/spool/cron/operator').with_owner('spectester') }
  end

  context 'with group set to valid string spectester' do
    let(:params) { { :group => 'spectester' } }
    it {  should contain_file('/var/spool/cron/operator').with_group('spectester') }
  end

  context 'with mode set to valid string 0242' do
    let(:params) { { :mode => '0242' } }
    it {  should contain_file('/var/spool/cron/operator').with_mode('0242') }
  end

  context 'with path set to valid string /test' do
    let(:params) { { :path => '/test' } }
    it {  should contain_file('/test/operator') }
  end

  context 'with content set to valid string #test' do
    let(:params) { { :content => '#test' } }
    it {  should contain_file('/var/spool/cron/operator').with_content('#test') }
  end

  context 'with vars set to valid hash that set two variables' do
    let(:params) { { :vars => {'SHELL' => '/bin/sh','MAILTO' => 'tester' } } }
    it { should contain_file('/var/spool/cron/operator').with_content(/^# DO NOT EDIT[\s\S]*MAILTO=tester\nSHELL=\/bin\/sh\n# For details see man 4 crontabs/) }
  end

  context 'with entries set to a valid hash that will create two tasks' do
    let (:params) { { :entries => {'spec' => ['0 0 2 4 2 root /bin/true','1 2 3 4 5 root /bin/false'],'test' => ['5 4 3 2 1 spec /bin/test$'] } } }
    it { should contain_file('/var/spool/cron/operator').with_content(/^# Example of job definition:[\s\S]*# spec\n0 0 2 4 2 root \/bin\/true\n1 2 3 4 5 root \/bin\/false\n# test\n5 4 3 2 1 spec \/bin\/test/) }
  end

  describe 'variable type and content validations' do
    validations = {
      'absolute_path' => {
        :name    => %w(path),
        :valid   => %w(/absolute/filepath /absolute/directory/),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, false, nil],
        :message => 'is not an absolute path',
      },
      'hash' => {
        :name    => %w(entries vars),
        :valid   => [], # valid hashes are to complex for generic testing
        :invalid => ['string', 3, 2.42, %w(array), false, nil],
        :message => 'is not a Hash',
      },
      'regex_ensure' => {
        :name    => %w(ensure),
        :valid   => %w(absent file present),
        :invalid => ['string', %w[array], { 'ha' => 'sh' }, 3, 2.42, false, nil],
        :message => '(must be absent, file or present)',
      },
      'regex_mode' => {
        :name    => %w(mode),
        :valid   => %w(0755 0644 1755 0242),
        :invalid => ['string', '755', 980, '0980', %w(array), { 'ha' => 'sh' }, 3, 2.42, false, nil],
        :message => 'must be a valid four digit mode in octal notation',
      },
      'string' => {
        :name    => %w(content group owner),
        :valid   => ['string'],
        :invalid => [%w(array), { 'ha' => 'sh' }, 3, 2.42, false],
        :message => 'is not a string',
      },
    }

    validations.sort.each do |type, var|
      mandatory_params = {} if mandatory_params.nil?
      var[:name].each do |var_name|
        var[:params] = {} if var[:params].nil?
        var[:valid].each do |valid|
          context "when #{var_name} (#{type}) is set to valid #{valid} (as #{valid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => valid, }].reduce(:merge) }
            it { should compile }
          end
        end

        var[:invalid].each do |invalid|
          context "when #{var_name} (#{type}) is set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => invalid, }].reduce(:merge) }
            it 'should fail' do
              expect { should contain_class(subject) }.to raise_error(Puppet::Error, /#{var[:message]}/)
            end
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'
end
