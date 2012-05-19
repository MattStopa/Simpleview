class Simpleview
  attr_accessor :base_file_path

  def parse(hash, template, offset=0)
    base = hash
    scope = base
    previous_scope = base
    waiting = false
    template.split("\n").each_with_index do |line, index|
      if waiting
        if (line =~ /{#/).nil?
          next
        else
          waiting = false
          next
        end
      end
      next if index < offset
      start = line =~ /{/
      stop  = line[start..line.length] =~ /}/ if start != nil
      if start == nil || stop == nil
        puts line
        next
      end
      full_value = line[start..stop+start]
      value = full_value[1..full_value.length-2]
      if value[0] == "#"
        previous_scope = scope
        miniscope = scope[value[1..full_value.length]]
        miniscope.each do |s|
          parse(s, template, index+1)
        end
        waiting = true
        next
      elsif value[0] == "/"
        return
      end
      puts line.sub(full_value, scope[value])
    end
  end

  def sample_template
    <<-eos
      The persons name is: <b>{person}</b>.
      <h2>he has the following animals:</h2>
      {#animals}
        <b>name:</b> {name}
        species: {species}
        <br>
      {/animals}
    eos
  end

  def sample_hash
    {
      "person" => "Matt",
      "animals" => [
        { "name" =>  "lady", "species" => "dog" },
        { "name" => "skittles", "species" => "cat" }
               ]
    }

  end
end

s = Simpleview.new
s.parse(s.sample_hash, s.sample_template)

