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

      if scope_key = starts_sub_context?(tokenize(line))
        scope_key = strip_to_context_key(scope_key)
        sub_context_lines = grab_subcontext_lines(lines, index)
        sub_scope = hash_scope[scope_key]
        sub_scope.each do |scope|
          sub_context_lines.each do |l|
            result += process_line(l, scope)
          end
        end
        lines_to_skip = sub_context_lines.size + 1
        next
      end
      result += process_line(line, hash_scope)
    end
    result
  end

  def process_line(line, scope)
    tokens = tokenize(line)
    tokens = replace_tokens_with_values(tokens, scope)
    tokens.inject() { |old, n| "#{old}#{n}" } + "\n"
  end

  def strip_to_context_key(token)
    token[2..token.size-2]
  end

  def starts_sub_context?(tokens)
    tokens.detect { |t| t[0..1] == '{#' }
  end

  def ends_sub_context?(tokens)
    tokens.detect { |t| t[0..1] == '{/' }
  end

  def replace_tokens_with_values(tokens, hash_scope)
    tokens.each_with_index do |token, index|
      if token[0] == '{'
        token_value = token[1..token.length-2]
        tokens[index] = hash_scope[token_value]
      end
    end
    tokens
  end

  def tokenize(line)
    results = []
    [].tap do |arr|
      chomped_line = line
      loop do
        results = chomped_line.partition(/{(.*?)}/).reject { |s| s == "" }
        break if results.size == 1
        arr.push(results - [results.last])
        chomped_line = results.last
      end
    end.push(results).flatten
  end

  def grab_subcontext_lines(lines, index)
    snippet = lines[index+1..lines.length]
    end_location = snippet.find_index { |l| l =~ /{\// }
    lines[index+1, end_location]
  end
end
