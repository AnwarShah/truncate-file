class LinesMoreThanActual < StandardError
  def initialize(lines_count, error_msg='')
    puts "File has less than #{lines_count} lines "
    super(error_msg)
  end
end

# default options
ORIENT_OPS = ['top', 'bottom']

@options = {
  '-o' => 'top', #or 'bottom'
  '-l' => 1000
}

def print_help_msg
  puts ''
  puts 'options: '
  puts "  -o    orientation. Valid values 'top', 'bottom'. Default 'top' "
  puts "  -l    no of lines to delete. Positive integer. Default 1000"
end

def give_usage_hint
  puts "usage: truncate_hist.rb -o [top|bottom] -l no_of_lines"
  puts "Truncate lines from bash history file"
  print_help_msg
  exit
end

def error_more_than_actual_lines(no_lines)
  puts "Error: File has less than #{no_lines} lines (total #{@total_lines})"
  exit
end

def error_non_positive_line_count
  puts "Error: You have given non-positive value for line count"
  exit
end

def valid_options?(opt_hash)
  opt_hash.each_key do |key|
    case key
    when '-o'
      return false unless ORIENT_OPS.include?(opt_hash[key])
    when '-l'
      begin
        no_lines = Integer( opt_hash[key] )
        opt_hash[key] = no_lines # set the integerized value 
        if no_lines > @total_lines
          error_more_than_actual_lines(no_lines)
        elsif no_lines < 1
          error_non_positive_line_count
        end
      rescue ArgumentError => e
        return false
      end
    end
  end
  true #otherwise true
end

def set_options(opt_hash)
  @options = opt_hash
  # if more than no of lines given, set max of total lines
  p @options
  if @options['-l'] > @total_lines
    options['-'] = @total_lines
  end
end

def parse_user_options
  if ARGV.length <= 0 
    give_usage_hint
  end

  if ARGV.length > 0
    give_usage_hint if not (ARGV.length%2).even?
    opt_hash = Hash[*ARGV]
    unless valid_options?(opt_hash)
      give_usage_hint
    else
      set_options(opt_hash)
    end
  end
  
end
  
def read_all_lines
  File.open(File.basename "~/history_copy", "r") do |file|
    file.readlines
  end
end

def print_lines(lines_arr)
  lines_arr.each_with_index do |line, index|
    puts "#{index}: #{line}"
  end
end

def write_to_file(source, from, to, file)
  from.upto(to) do |lineno|
    file.write(source[lineno])
  end
end

def truncate_lines(lines)
  line_count = @options['-l']
  orientation = @options['-o']
  temp_file = 'history_new'

  File.open(temp_file, "w") do |file|
    if orientation == 'top'
      write_to_file(lines, 0, line_count-1, file)
    elsif orientation == 'bottom'

    end
  end

end

lines = read_all_lines
@total_lines = lines.length
parse_user_options()
# print_lines(lines)
truncate_lines(lines)