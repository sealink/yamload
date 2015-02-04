require 'spec_helper'

require 'yamload'

describe Yamload do
  let(:file)    { :test }
  let(:loader)  { Yamload::Loader.new(file) }

  specify { expect(loader).to exist }

  context 'with a non existing file' do
    let(:file) { :non_existing }
    specify { expect(loader).not_to exist }
  end

  let(:config)      { loader.loaded_hash }
  let(:config_obj)  { loader.obj }

  let(:expected_config) {
    {
      'test'  => true,
      'users' => [
        {
          'first_name' => 'Testy',
          'last_name'  => 'Tester',
          'address'    => {
            'address_line_1' => '1 Test Avenue',
            'address_line_2' => nil,
            'city'           => 'Testville',
            'state'          => 'TST',
            'post_code'      => 1234,
            'country'        => 'Testalia'
          },
          'email'      => 'testy.tester@test.com'
        },
        {
          'first_name' => 'Speccy',
          'last_name'  => 'Speccer',
          'address'    => {
            'address_line_1' => 'Unit 1',
            'address_line_2' => '42 Spec Street',
            'city'           => 'Specwood',
            'state'          => 'SPC',
            'post_code'      => 5678,
            'country'        => 'Specland'
          },
          'email'      => 'speccy.speccer@spec.com'
        }
      ],
      'settings' => {
        'remote_access' => true
      }
    }
  }

  specify { expect(config).to eq expected_config }
  specify { expect(config_obj.test).to eq true }
  specify { expect(config_obj.users[0].first_name).to eq 'Testy' }
  specify { expect(config_obj.users[0].last_name).to eq 'Tester' }
  specify { expect(config_obj.users[0].address.address_line_1).to eq '1 Test Avenue' }
  specify { expect(config_obj.users[0].address.address_line_2).to eq nil }
  specify { expect(config_obj.users[0].address.city).to eq 'Testville' }
  specify { expect(config_obj.users[0].address.state).to eq 'TST' }
  specify { expect(config_obj.users[0].address.post_code).to eq 1234 }
  specify { expect(config_obj.users[0].address.country).to eq 'Testalia' }
  specify { expect(config_obj.users[0].email).to eq 'testy.tester@test.com' }
  specify { expect(config_obj.users[1].first_name).to eq 'Speccy' }
  specify { expect(config_obj.users[1].last_name).to eq 'Speccer' }
  specify { expect(config_obj.users[1].address.address_line_1).to eq 'Unit 1' }
  specify { expect(config_obj.users[1].address.address_line_2).to eq '42 Spec Street' }
  specify { expect(config_obj.users[1].address.city).to eq 'Specwood' }
  specify { expect(config_obj.users[1].address.state).to eq 'SPC' }
  specify { expect(config_obj.users[1].address.post_code).to eq 5678 }
  specify { expect(config_obj.users[1].address.country).to eq 'Specland' }
  specify { expect(config_obj.users[1].email).to eq 'speccy.speccer@spec.com' }
  specify { expect(config_obj.settings.remote_access).to eq true }

  context 'when trying to modify the loaded hash' do
    let(:new_user) { double('new user') }
    specify 'the hash should be immutable' do
      expect { config['users'] << new_user }
        .to raise_error RuntimeError, "can't modify frozen Array"
      expect(config['users']).not_to include new_user
    end
  end

  context 'when trying to modify the configuration object' do
    let(:new_user) { double('new user') }
    specify 'the object should be immutable' do
      expect { config_obj.users << new_user }
        .to raise_error RuntimeError, "can't modify frozen Array"
      expect(config_obj.users).not_to include new_user
    end
  end

  context 'when a schema is defined' do
    let(:schema) {
      {
        'test'     => TrueClass,
        'users'    => [
          [
            {
              'first_name' => String,
              'last_name'  => String,
              'address'    => {
                'address_line_1' => String,
                'address_line_2' => [:optional, String, NilClass],
                'city'           => String,
                'state'          => String,
                'post_code'      => Integer,
                'country'        => String
              },
              'email'      => String
            }
          ]
        ],
        'settings' => {
          'remote_access' => TrueClass
        }
      }
    }

    before { loader.schema = schema }

    specify { expect(loader).to be_valid }
    specify { expect(loader.error).to be_nil }
    specify { expect { loader.validate! }.not_to raise_error }

    context 'when the schema is not matched' do
      let(:schema) {
        {
          'users' => [
            [
              {
                'expected_attribute' => String
              }
            ]
          ]
        }
      }

      let(:expected_error) { '"users"[0]["expected_attribute"] is not present' }
      specify { expect(loader).not_to be_valid }
      specify { expect(loader.error).to eq expected_error }
      specify { expect { loader.validate! }.to raise_error Yamload::SchemaError, expected_error }
    end
  end

  context 'when defaults are defined' do
    let(:defaults) {
      {
        'settings' => {
          'remember_user' => false,
          'remote_access' => false
        }
      }
    }

    before do
      loader.defaults = defaults
    end

    specify { expect(config_obj.settings.remember_user).to eq false }
    specify { expect(config_obj.settings.remote_access).to eq true }
  end

  context 'when reloading' do
    let(:original_hash) { loader.loaded_hash }
    before do
      original_hash
      loader.reload
    end
    specify { expect(loader.loaded_hash).not_to be original_hash }
  end
end
