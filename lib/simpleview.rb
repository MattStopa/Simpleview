class Simpleview
  attr_accessor :base_file_path

  def parse(hash, template)
    result = ""
    lines_to_skip = 0
    hash_scope = hash
    lines = template.class == Array ? template : template.split("\n")
    lines.each_with_index do |line, index|
      if lines_to_skip > 0
        lines_to_skip -= 1
        next
      end
      start = line =~ /{/
      stop  = line[start..line.length] =~ /}/ if start != nil
      if start.nil? || stop.nil?
        result += "#{line}\n"
        next
      end
      token = line[start..stop+start]
      token_value = token[1..token.length-2]
      if token_value[0] == "#"
        varscope = hash_scope[token_value.gsub("#", '')]
        snippet = generate_snippet(lines, index)
        varscope.each do |s|
          r = parse(s, snippet)
          result += r if r.class == String
        end
        lines_to_skip = snippet.length + 1
        next
      end
      result += line.sub(token, hash_scope[token_value]) + "\n"
    end
    result
  end

  def generate_snippet(lines, index)
    snippet = lines[index+1..lines.length]
    end_location = snippet.find_index { |l| l =~ /{\// }
    lines[index+1, end_location]
  end
end
