require 'spec_helper'

require 'yamload'

describe Yamload::Loader do
  let(:file)    { :test }
  let(:loader)  { Yamload::Loader.new(file) }
  let(:content)  { loader.content }

  context 'if the directory is not specified' do
    let(:loader) { Yamload::Loader.new(file, nil) }
    specify { expect { content }.to raise_error IOError, 'No yml files directory specified' }
  end

  context 'if the directory is invalid' do
    let(:current_file_dir)  { File.expand_path(File.dirname(__FILE__)) }
    let(:invalid_dir)       { File.join(current_file_dir, 'invalid') }
    let(:loader)            { Yamload::Loader.new(file, invalid_dir) }
    specify { expect { content }.to raise_error IOError, "#{invalid_dir} is not a valid directory" }
  end

  context 'with a non existing file' do
    let(:file) { :non_existing }
    specify { expect(loader).not_to exist }
    specify { expect { content }.to raise_error IOError, 'non_existing.yml could not be found' }
  end

  context 'with an empty file' do
    let(:file) { :empty }
    specify { expect(loader).to exist }
    specify { expect { content }.to raise_error IOError, 'empty.yml is blank' }
  end

  context 'with a file containing ERB' do
    let(:file) { :erb }
    let(:expected_content) { { "erb_var" => "ERB RAN!" } }
    specify { expect(loader).to exist }
    specify { expect(content).to eq expected_content }
  end

  context 'with a file defining an array' do
    let(:file) { :array }
    let(:expected_content) { %w(first second third) }
    specify { expect(loader).to exist }
    specify { expect { content }.not_to raise_error }
    specify { expect(content).to eq expected_content }

    context 'when defaults are defined' do
      let(:defaults) { { test: true } }
      before { loader.defaults = defaults }
      specify {
        expect { content }
          .to raise_error ArgumentError, "#{expected_content} is not a hash"
      }
    end

    context 'when a schema is defined' do
      let(:schema) { { test: true } }
      before { loader.schema = schema }
      specify {
        expect { loader.valid? }
          .to raise_error ArgumentError, "#{expected_content} is not a hash"
      }
    end
  end

  context 'with a file defining a string' do
    let(:file) { :string }
    let(:expected_content) { '1 first 2 second 3 third' }
    specify { expect(loader).to exist }
    specify { expect { content }.not_to raise_error }
    specify { expect(content).to eq expected_content }

    context 'when defaults are defined' do
      let(:defaults) { { test: true } }
      before { loader.defaults = defaults }
      specify {
        expect { content }
          .to raise_error ArgumentError, "#{expected_content} is not a hash"
      }
    end

    context 'when a schema is defined' do
      let(:schema) { { test: true } }
      before { loader.schema = schema }
      specify {
        expect { loader.valid? }
          .to raise_error ArgumentError, "#{expected_content} is not a hash"
      }
    end
  end

  context 'with a file defining a hash' do
    specify { expect(loader).to exist }

    let(:expected_content) {
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

    specify 'deprecated `loaded_hash` still works' do
      expect(loader.loaded_hash).to eq loader.content
    end

    specify { expect(content).to eq expected_content }

    let(:content_obj)  { loader.obj }

    specify { expect(content_obj.test).to eq true }
    specify { expect(content_obj.users[0].first_name).to eq 'Testy' }
    specify { expect(content_obj.users[0].last_name).to eq 'Tester' }
    specify { expect(content_obj.users[0].address.address_line_1).to eq '1 Test Avenue' }
    specify { expect(content_obj.users[0].address.address_line_2).to eq nil }
    specify { expect(content_obj.users[0].address.city).to eq 'Testville' }
    specify { expect(content_obj.users[0].address.state).to eq 'TST' }
    specify { expect(content_obj.users[0].address.post_code).to eq 1234 }
    specify { expect(content_obj.users[0].address.country).to eq 'Testalia' }
    specify { expect(content_obj.users[0].email).to eq 'testy.tester@test.com' }
    specify { expect(content_obj.users[1].first_name).to eq 'Speccy' }
    specify { expect(content_obj.users[1].last_name).to eq 'Speccer' }
    specify { expect(content_obj.users[1].address.address_line_1).to eq 'Unit 1' }
    specify { expect(content_obj.users[1].address.address_line_2).to eq '42 Spec Street' }
    specify { expect(content_obj.users[1].address.city).to eq 'Specwood' }
    specify { expect(content_obj.users[1].address.state).to eq 'SPC' }
    specify { expect(content_obj.users[1].address.post_code).to eq 5678 }
    specify { expect(content_obj.users[1].address.country).to eq 'Specland' }
    specify { expect(content_obj.users[1].email).to eq 'speccy.speccer@spec.com' }
    specify { expect(content_obj.settings.remote_access).to eq true }

    context 'when trying to modify the loaded hash' do
      let(:new_user) { double('new user') }
      specify 'the hash should be immutable' do
        expect { content['users'] << new_user }
          .to raise_error RuntimeError, /can't modify frozen Array/i
        expect(content['users']).not_to include new_user
      end
    end

    context 'when trying to modify the content object' do
      let(:new_user) { double('new user') }
      specify 'the object should be immutable' do
        expect { content_obj.users << new_user }
          .to raise_error RuntimeError, /can't modify frozen Array/i
        expect(content_obj.users).not_to include new_user
      end
    end

    context 'when no schema is defined' do
      specify { expect(loader).to be_valid }
      specify { expect(loader.error).to be_nil }
      specify { expect { loader.validate! }.not_to raise_error }
    end

    context 'when the schema is not a hash' do
      let(:schema) { 'not a hash' }
      specify {
        expect { loader.schema = schema }
          .to raise_error ArgumentError, "#{schema} is not a hash"
      }
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

      before do
        loader.schema = schema
      end

      specify { expect(loader.schema).to eq schema }
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

    context 'when the defaults object is not a hash' do
      let(:defaults) { 'not a hash' }
      specify {
        expect { loader.defaults = defaults }
          .to raise_error ArgumentError, "#{defaults} is not a hash"
      }
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

      specify { expect(loader.defaults).to eq defaults }
      specify { expect(content_obj.settings.remember_user).to eq false }
      specify { expect(content_obj.settings.remote_access).to eq true }
    end

    context 'when reloading' do
      let(:original_hash) { loader.content }
      before do
        original_hash
        loader.reload
      end
      specify { expect(loader.content).not_to be original_hash }
    end
  end
end
