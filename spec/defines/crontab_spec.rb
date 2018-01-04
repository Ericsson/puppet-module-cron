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
