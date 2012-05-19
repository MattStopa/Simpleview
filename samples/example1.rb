require '../lib/simpleview.rb'

sample_template =
  <<-eos
    The persons name is: <b>{person}</b>.
    <h2>he has the following animals:</h2>
    {#animals}
      <b>name:</b> {name}
      species: {species}
      <br>
    {/animals}
  eos

sample_hash =
{
  "person"=>"Matt",
  "animals"=>[
    {
      "name"=>"lady",
      "species"=>"dog"
    },
    {
      "name"=>"skittles",
      "species"=>"cat"
    }
  ]
}

s = Simpleview.new
puts s.parse(sample_hash, sample_template)

