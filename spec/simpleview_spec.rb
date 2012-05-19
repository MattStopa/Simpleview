require './lib/simpleview.rb'

describe "SimpleView" do
  describe "#parse" do
    context "with basic inputs" do
      let(:template) { "Hi, {name}!" }
      let(:hash) { { "name" => "John" } }
      subject { Simpleview.new.parse(hash, template) }
      it { should == "Hi, John!\n" }
    end
  end
end