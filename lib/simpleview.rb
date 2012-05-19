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
      full_value = line[start..stop+start]
      value = full_value[1..full_value.length-2]
      if value[0] == "#"
        miniscope = scope[value[1..full_value.length]]
        snippet = lines[index+1..lines.length]
        end_location = snippet.find_index { |l| l =~ /{\// }
        end_location += index - 1
        snippet = lines[index+1, end_location]
        miniscope.each do |s|
          r = parse(s, snippet)
          result += r if r.class == String
        end
        skip_line_count = snippet.length + 1
        next
      end
      result += line.sub(full_value, scope[value]) + "\n" unless scope[value].nil?
    end
    result
  end
end
