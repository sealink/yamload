require "spec_helper"

require "yamload"

describe Yamload::Loader do
  let(:file) { :test }
  let(:loader) { Yamload::Loader.new(file) }
  let(:content) { loader.content }

  context "if the directory is not specified" do
    let(:loader) { Yamload::Loader.new(file, nil) }
    specify { expect { content }.to raise_error IOError, "No yml files directory specified" }
  end

  context "if the directory is invalid" do
    let(:current_file_dir) { __dir__ }
    let(:invalid_dir) { File.join(current_file_dir, "invalid") }
    let(:loader) { Yamload::Loader.new(file, invalid_dir) }
    specify { expect { content }.to raise_error IOError, "#{invalid_dir} is not a valid directory" }
  end

  context "with a non existing file" do
    let(:file) { :non_existing }
    specify { expect(loader).not_to exist }
    specify { expect { content }.to raise_error IOError, "non_existing.yml could not be found" }
  end

  context "with an empty file" do
    let(:file) { :empty }
    specify { expect(loader).to exist }
    specify { expect { content }.to raise_error IOError, "empty.yml is blank" }
  end

  context "with a file containing ERB" do
    before do
      allow_any_instance_of(Aws::SSM::Client).to receive(:get_parameter)
        .with({name: "ssm_var", with_decryption: true})
        .and_return(double(parameter: double(value: "SSM SUCCESS")))
      allow_any_instance_of(Aws::SecretsManager::Client).to receive(:get_secret_value)
        .with({secret_id: "secret_var"})
        .and_return(double(secret_string: "SECRET SUCCESS"))
    end

    let(:file) { :erb }
    let(:expected_content) { {"erb_var" => "ERB RAN!", "ssm_var" => "SSM SUCCESS", "secret_var" => "SECRET SUCCESS"} }
    specify { expect(loader).to exist }
    specify { expect(content).to eq expected_content }

    context "with bad parameter key" do
      before do
        allow_any_instance_of(Aws::SSM::Client).to receive(:get_parameter)
          .with({name: "bad_key", with_decryption: true})
          .and_raise(Aws::SSM::Errors::ParameterNotFound.new(Seahorse, "bad_key"))
      end
      let(:file) { :erb_bad }
      specify {
        expect { content }.to raise_error Aws::SSM::Errors::ParameterNotFound
      }
    end
  end

  context "with a file defining an array" do
    let(:file) { :array }
    let(:expected_content) { %w[first second third] }
    specify { expect(loader).to exist }
    specify { expect { content }.not_to raise_error }
    specify { expect(content).to eq expected_content }

    context "when defaults are defined" do
      let(:defaults) { {test: true} }
      before { loader.defaults = defaults }
      specify {
        expect { content }
          .to raise_error ArgumentError, "#{expected_content} is not a hash"
      }
    end
  end

  context "with a file defining a string" do
    let(:file) { :string }
    let(:expected_content) { "1 first 2 second 3 third" }
    specify { expect(loader).to exist }
    specify { expect { content }.not_to raise_error }
    specify { expect(content).to eq expected_content }

    context "when defaults are defined" do
      let(:defaults) { {test: true} }
      before { loader.defaults = defaults }
      specify {
        expect { content }
          .to raise_error ArgumentError, "#{expected_content} is not a hash"
      }
    end
  end

  context "with an unsafe configuration" do
    let(:file) { :unsafe }
    let(:expected_content) {
      {
        "defaults" => {"adapter" => "mysql2"},
        "development" => {"adapter" => "sqlite"}
      }
    }

    specify { expect(content).to eq expected_content }
  end

  context "with a file defining a hash" do
    specify { expect(loader).to exist }

    let(:expected_content) {
      {
        "test" => true,
        "users" => [
          {
            "first_name" => "Testy",
            "last_name" => "Tester",
            "address" => {
              "address_line_1" => "1 Test Avenue",
              "address_line_2" => nil,
              "city" => "Testville",
              "state" => "TST",
              "post_code" => 1234,
              "country" => "Testalia"
            },
            "email" => "testy.tester@test.com"
          },
          {
            "first_name" => "Speccy",
            "last_name" => "Speccer",
            "address" => {
              "address_line_1" => "Unit 1",
              "address_line_2" => "42 Spec Street",
              "city" => "Specwood",
              "state" => "SPC",
              "post_code" => 5678,
              "country" => "Specland"
            },
            "email" => "speccy.speccer@spec.com"
          }
        ],
        "settings" => {
          "remote_access" => true
        }
      }
    }

    specify { expect(content).to eq expected_content }

    let(:content_obj) { loader.obj }

    specify { expect(content_obj.test).to eq true }
    specify { expect(content_obj.users[0].first_name).to eq "Testy" }
    specify { expect(content_obj.users[0].last_name).to eq "Tester" }
    specify { expect(content_obj.users[0].address.address_line_1).to eq "1 Test Avenue" }
    specify { expect(content_obj.users[0].address.address_line_2).to eq nil }
    specify { expect(content_obj.users[0].address.city).to eq "Testville" }
    specify { expect(content_obj.users[0].address.state).to eq "TST" }
    specify { expect(content_obj.users[0].address.post_code).to eq 1234 }
    specify { expect(content_obj.users[0].address.country).to eq "Testalia" }
    specify { expect(content_obj.users[0].email).to eq "testy.tester@test.com" }
    specify { expect(content_obj.users[1].first_name).to eq "Speccy" }
    specify { expect(content_obj.users[1].last_name).to eq "Speccer" }
    specify { expect(content_obj.users[1].address.address_line_1).to eq "Unit 1" }
    specify { expect(content_obj.users[1].address.address_line_2).to eq "42 Spec Street" }
    specify { expect(content_obj.users[1].address.city).to eq "Specwood" }
    specify { expect(content_obj.users[1].address.state).to eq "SPC" }
    specify { expect(content_obj.users[1].address.post_code).to eq 5678 }
    specify { expect(content_obj.users[1].address.country).to eq "Specland" }
    specify { expect(content_obj.users[1].email).to eq "speccy.speccer@spec.com" }
    specify { expect(content_obj.settings.remote_access).to eq true }

    context "when trying to modify the loaded hash" do
      let(:new_user) { double("new user") }
      specify "the hash should be immutable" do
        expect { content["users"] << new_user }
          .to raise_error RuntimeError, /can't modify frozen Array/i
        expect(content["users"]).not_to include new_user
      end
    end

    context "when trying to modify the content object" do
      let(:new_user) { double("new user") }
      specify "the object should be immutable" do
        expect { content_obj.users << new_user }
          .to raise_error RuntimeError, /can't modify frozen Array/i
        expect(content_obj.users).not_to include new_user
      end
    end

    context "when the defaults object is not a hash" do
      let(:defaults) { "not a hash" }
      specify {
        expect { loader.defaults = defaults }
          .to raise_error ArgumentError, "#{defaults} is not a hash"
      }
    end

    context "when defaults are defined" do
      let(:defaults) {
        {
          "settings" => {
            "remember_user" => false,
            "remote_access" => false
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

    context "when reloading" do
      let(:original_hash) { loader.content }
      before do
        original_hash
        loader.reload
      end
      specify { expect(loader.content).not_to be original_hash }
    end
  end
end
