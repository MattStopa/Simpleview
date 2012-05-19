class Simpleview
  attr_accessor :base_file_path

  def parse(hash, template, offset=0)
    result = ""
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
        result += "#{line}\n"
        next
      end
      full_value = line[start..stop+start]
      value = full_value[1..full_value.length-2]
      if value[0] == "#"
        previous_scope = scope
        miniscope = scope[value[1..full_value.length]]
        miniscope.each do |s|
          r = parse(s, template, index+1)
          result += r if r.class == String
        end
        waiting = true
        next
      elsif value[0] == "/"
        return result
      end
      result += line.sub(full_value, scope[value]) + "\n"
    end
    result
  end
end
