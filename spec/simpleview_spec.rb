require './lib/simpleview.rb'

describe "SimpleView" do
  describe "#parse" do
    context "with a single line" do
      let(:template) { "Hi, {name}!" }
      let(:hash) { { "name" => "John" } }
      subject { Simpleview.new.parse(hash, template) }
      it { should == "Hi, John!\n" }
    end

    context "with a single line with just a token" do
      let(:template) { "{name}" }
      let(:hash) { { "name" => "John" } }
      subject { Simpleview.new.parse(hash, template) }
      it { should == "John\n" }
    end

    context "with two lines" do
      let(:template) { "Hi, {name}!\nWhat do you like about {city}?" }
      let(:hash) { { "name" => "John", "city" => "Atlanta" } }
      subject { Simpleview.new.parse(hash, template) }
      it { should == "Hi, John!\nWhat do you like about Atlanta?\n" }
    end

    context "with a single line having multiple tags on it" do
      let(:template) { "Hi, {name}! My name is {your_name}." }
      let(:hash) { { "name" => "John", "your_name" => "Matt" } }
      subject { Simpleview.new.parse(hash, template) }
      it { should == "Hi, John! My name is Matt.\n" }
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

  describe "#process_line" do
    context "with no tags" do
      let(:tokens) { "name" }
      let(:scope) { {"name" => "John" } }
      subject { Simpleview.new.process_line(tokens, scope)}
      it { should == "name\n" }
    end

    context "with only a tag and nothing else" do
      let(:tokens) { "{name}" }
      let(:scope) { {"name" => "John" } }
      subject { Simpleview.new.process_line(tokens, scope)}
      it { should == "John\n" }
    end

    context "with a single tag" do
      let(:tokens) { "Have a great day {name}. Life is grande." }
      let(:scope) { {"name" => "John" } }
      subject { Simpleview.new.process_line(tokens, scope)}
      it { should == "Have a great day John. Life is grande.\n" }
    end

    context "with interspersed tags" do
      let(:tokens) { "{greeting} Have a great day {name}. Life is grande. {ending}" }
      let(:scope) { { "greeting" => "Hello!", "name" => "John", "ending" => "See ya later" } }
      subject { Simpleview.new.process_line(tokens, scope)}
      it { should == "Hello! Have a great day John. Life is grande. See ya later\n" }
    end
  end

  describe "#strip_to_context_key" do
    let(:token) { "{#first_key}"}
    subject { Simpleview.new.strip_to_context_key(token) }
    it { should == "first_key" }
  end

  describe "#starts_sub_context?" do
    context "when it does start a sub context" do
      subject { Simpleview.new.starts_sub_context?(tokens) }

      context "when it is the last token" do
        let(:tokens) { ["this", "{#"] }
        it { should_not == nil }
      end

      context "when it is the first token" do
        let(:tokens) { ["{#", "this"] }
        it { should_not == nil }
      end

      context "when it is in the middle of the token stream" do
        let(:tokens) { ["blah", "another_token", "{#", "222", "this"] }
        it { should_not == nil }
      end
    end

    context "when it does not start a sub context" do
      subject { Simpleview.new.starts_sub_context?(tokens) }

      context "when there are no matching tokens" do
        let(:tokens) { ["blah", "another_token", "#--{", "222", "this"] }
        it { should == nil }
      end
    end
  end

  describe "#ends_sub_context?" do
    context "when it does end a sub context" do
      subject { Simpleview.new.ends_sub_context?(tokens) }

      context "when it is the last token" do
        let(:tokens) { ["this", "{/"] }
        it { should_not == nil }
      end

      context "when it is the first token" do
        let(:tokens) { ["{/", "this"] }
        it { should_not == nil }
      end

      context "when it is in the middle of the token stream" do
        let(:tokens) { ["blah", "another_token", "{/", "222", "this"] }
        it { should_not == nil }
      end
    end

    context "when it does not end a sub context" do
      subject { Simpleview.new.ends_sub_context?(tokens) }

      context "when there are no matching tokens" do
        let(:tokens) { ["blah", "another_token", "{#", "222", "this"] }
        it { should == nil }
      end
    end
  end

  describe "#replace_tokens_with_values" do
    context "with no tags" do
      let(:tokens) { ["name"] }
      let(:scope) { {"name" => "John" } }
      subject { Simpleview.new.replace_tokens_with_values(tokens, scope)}
      it { should == ["name"] }
    end

    context "with only a tag and nothing else" do
      let(:tokens) { ["{name}"] }
      let(:scope) { {"name" => "John" } }
      subject { Simpleview.new.replace_tokens_with_values(tokens, scope)}
      it { should == ["John"] }
    end

    context "with a single tag" do
      let(:tokens) { ["Have a great day", "{name}", ". Life is grande."] }
      let(:scope) { {"name" => "John" } }
      subject { Simpleview.new.replace_tokens_with_values(tokens, scope)}
      it { should == ["Have a great day", "John", ". Life is grande."] }
    end

    context "with interspersed tags" do
      let(:tokens) { ["{greeting}", "Have a great day", "{name}", ". Life is grande.", "{ending}"] }
      let(:scope) { { "greeting" => "Hello!", "name" => "John", "ending" => "See ya later" } }
      subject { Simpleview.new.replace_tokens_with_values(tokens, scope)}
      it { should == ["Hello!", "Have a great day", "John", ". Life is grande.", "See ya later"] }
    end
  end

  describe "#tokenize" do
    context "line without a tag" do
      subject { Simpleview.new.tokenize("Hello, what a nice day")}
      it { should == ["Hello, what a nice day"] }
    end

    context "with a single tag" do
      context "with only a tag" do
        subject { Simpleview.new.tokenize("{tag}")}
        it { should == ["{tag}"] }
      end

      context "with a tag at the beginning of a line" do
        subject { Simpleview.new.tokenize("{tag} more text here")}
        it { should == ["{tag}", " more text here"] }
      end

      context "with a tag at the end of a line" do
        subject { Simpleview.new.tokenize("more text here {tag}")}
        it { should == ["more text here ", "{tag}"] }
      end

      context "with a tag in the middle of a line" do
        subject { Simpleview.new.tokenize("more text here {tag} more text after")}
        it { should == ["more text here ", "{tag}", " more text after"] }
      end
    end

    context "with multiple tags on a line" do
      context "with only a tags" do
        subject { Simpleview.new.tokenize("{tag}{other_tag}") }
        it { should == ["{tag}", "{other_tag}"] }
      end

      context "with multiple tags at the beginning of a line" do
        subject { Simpleview.new.tokenize("{tag}{other_tag} more text here")}
        it { should == ["{tag}", "{other_tag}", " more text here"] }
      end

      context "with multiple tags at the end of a line" do
        subject { Simpleview.new.tokenize("more text here {tag}{other_tag}")}
        it { should == ["more text here ", "{tag}","{other_tag}"] }
      end

      context "with multiple tags in the middle of a line" do
        subject { Simpleview.new.tokenize("more text here {tag}{other_tag} more text after")}
        it { should == ["more text here ", "{tag}", "{other_tag}", " more text after"] }
      end
    end

  end

  describe "#grab_subcontext_lines" do
    let(:lines) { ["aaa", "bbb", "ccc", "ddd", "eee", "{/}fff", "ggg"]}
    subject { Simpleview.new.grab_subcontext_lines(lines, 1) }
    it { should == ["ccc", "ddd", "eee"] }
  end
end