class Simpleview
  attr_accessor :base_file_path

  def parse(hash, template)
    result = ""
    skip_line_count = 0
    scope = hash
    lines = template.class == Array ? template : template.split("\n")
    lines.each_with_index do |line, index|
      if skip_line_count > 0
        skip_line_count -= 1
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
        miniscope = scope[token_value.gsub("#", '')]
        snippet = lines[index+1..lines.length]
        end_location = snippet.find_index { |l| l =~ /{\// } + index - 1
        snippet = lines[index+1, end_location]
        miniscope.each do |s|
          r = parse(s, snippet)
          result += r if r.class == String
        end
        skip_line_count = snippet.length + 1
        next
      end
      result += line.sub(token, scope[token_value]) + "\n" unless scope[token_value].nil?
    end
    result
  end
end
