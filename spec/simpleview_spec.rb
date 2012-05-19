require './lib/simpleview.rb'

describe "SimpleView" do
  describe "#parse" do
    context "with a single line" do
      let(:template) { "Hi, {name}!" }
      let(:hash) { { "name" => "John" } }
      subject { Simpleview.new.parse(hash, template) }
      it { should == "Hi, John!\n" }
    end

    context "with two lines" do
      let(:template) { "Hi, {name}!\nWhat do you like about {city}?" }
      let(:hash) { { "name" => "John", "city" => "Atlanta" } }
      subject { Simpleview.new.parse(hash, template) }
      it { should == "Hi, John!\nWhat do you like about Atlanta?\n" }
    end

    context "multiple lines with nested fields" do
      let(:template) { "Hi, {name}!\n{#family}\nHow is your {relationship}:\n{name}\n{/family}" }
      let(:hash)  {
                    {
                      "name"=>"John",
                      "family"=>[
                         { "name" => "Mr. Moocow", "relationship" => "father"},
                         { "name" => "Piglet", "relationship" => "daughter"}
                      ]
                    }
                  }
      subject { Simpleview.new.parse(hash, template) }
      it { should == "Hi, John!\nHow is your father:\nMr. Moocow\nHow is your daughter:\nPiglet\n" }
    end

    context "multiple lines with multiple nested fields" do
      let(:template) { "Hello, {name}.\n Your users are: \n{#users}\n{name}\n{/users}\n Your messages are \n{#messages}\n{message}\n{/messages}" }
      let(:hash)  {
                    {
                      "name"=>"John",
                      "users"=>[
                         { "name" => "Mr. Moocow" },
                         { "name" => "Piglet" }
                      ],
                      "messages"=>[
                         { "message" => "Hi" },
                         { "message" => "Goodbye" }
                       ]
                    }
                  }
      subject { Simpleview.new.parse(hash, template) }
      it { should == "Hello, John.\n Your users are: \nMr. Moocow\nPiglet\n Your messages are \nHi\nGoodbye\n" }
    end
  end

  describe "#generate_snippet" do
    let(:lines) { ["aaa", "bbb", "ccc", "ddd", "eee", "{/}fff", "ggg"]}
    subject { Simpleview.new.generate_snippet(lines, 1) }
    it { should == ["ccc", "ddd", "eee"] }
  end
end