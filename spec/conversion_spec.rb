require "spec_helper"

require "yamload/conversion"

describe Yamload::Conversion do
  let(:number) { 42 }
  let(:string) { "a string" }
  let(:array) { [number, string] }
  let(:hash) {
    {
      string: string,
      array: array,
      sub_hash: {something: "else"}
    }
  }

  subject!(:immutable_object) { converter.to_immutable }

  context "when converting a number" do
    let(:converter) { Yamload::Conversion::Object.new(number) }
    specify { is_expected.to eq number }
  end

  context "when converting a string" do
    let(:converter) { Yamload::Conversion::Object.new(string) }
    specify { expect(string).not_to be_frozen }
    specify { is_expected.to be_frozen }
    specify { is_expected.to eq string }
  end

  context "when converting an array" do
    let(:converter) { Yamload::Conversion::Object.new(array) }
    specify { expect(array).not_to be_frozen }
    specify { is_expected.to be_frozen }
    specify { is_expected.to be_an Array }
    specify { expect(immutable_object.size).to eq 2 }
    specify { expect(immutable_object[0]).to eq number }
    specify { expect(immutable_object[1]).to be_frozen }
    specify { expect(immutable_object[1]).to eq string }
  end

  context "when converting a hash" do
    let(:converter) { Yamload::Conversion::Object.new(hash) }
    specify { expect(hash).not_to be_frozen }
    specify { is_expected.to be_frozen }
    specify { expect(immutable_object.string).to eq string }
    specify { expect(immutable_object.array.size).to eq 2 }
    specify { expect(immutable_object.array[0]).to eq number }
    specify { expect(immutable_object.array[1]).to be_frozen }
    specify { expect(immutable_object.array[1]).to eq string }
    specify { expect(immutable_object.sub_hash).to be_frozen }
    specify { expect(immutable_object.sub_hash.something).to be_frozen }
    specify { expect(immutable_object.sub_hash.something).to eq "else" }
  end
end
