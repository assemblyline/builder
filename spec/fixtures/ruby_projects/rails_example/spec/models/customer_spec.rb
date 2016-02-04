require "rails_helper"

RSpec.describe Customer, type: :model do
  subject { described_class.new(name: "Ed", age: 29, awesome: true) }

  it "has an age" do
    expect(subject.age).to eq 29
  end

  it "has a name" do
    expect(subject.name).to eq "Ed"
  end

  it "is awesome" do
    expect(subject).to be_awesome
  end

  it "can be persisted" do
    subject.save
    expect(described_class.where(name: "Ed").count).to eq 1
    expect(described_class.where(name: "Ed").first.age).to eq 29
  end
end
