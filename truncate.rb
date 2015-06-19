#!/usr/bin/env ruby

require 'fileutils'

class LinesMoreThanActual < StandardError
  def initialize(lines_count, error_msg='')
    puts "File has less than #{lines_count} lines "
    super(error_msg)
  end
end

# default options
ORIENT_OPS = ['top', 'bottom']
DEFAULT_LINES = 10

@options = {
  '-o' => 'top', #or 'bottom'
  '-l' => DEFAULT_LINES
}

def print_help_msg
  puts ''
  puts 'options: '
  puts "  -o    orientation. Valid values 'top', 'bottom'. Default 'top' "
  puts "  -l    no of lines to delete. Positive integer. Default #{DEFAULT_LINES}"
  puts ''
  puts "FILE is the name of file to truncate from"
end

def print_usage
  puts "Usage: truncate_hist.rb -o [top|bottom] -l [no_of_lines] FILE"
  puts "Truncate lines from a text file FILE"
end

def proceed_with_defaults?
  prompt = "You haven't give any option. " + 
        "I'll truncate #{DEFAULT_LINES} lines from top of file '#{@filename}'. " + 
        "Proceed? (Y/N)"
  puts prompt
  answer = gets.chomp.downcase
  if answer == 'y'
    return true
  else
    puts "Exited without any truncation"
    return false
  end
end

def error_more_than_actual_lines(no_lines)
  puts "Error: File has less than #{no_lines} lines (total #{@total_lines})"
  exit
end

def error_non_positive_line_count
  puts "Error: You have given non-positive value for line count"
  exit
end

def error_file_not_exists
  puts "Error: File '#{@filename}' doesn't exist"
  print_usage
  exit
end

def error_no_filename_given
  puts "Filename is required"
  print_usage
  print_help_msg
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

def valid_filename?(file)
  unless File.exists?file
    error_file_not_exists
  end
  file # else
end

def set_options(opt_hash)
  @options = opt_hash
  # if more than no of lines given, set max of total lines
  if @options['-l'] > @total_lines
    options['-'] = @total_lines
  end
end

def parse_user_options
  if ARGV.length <= 0 
    return if proceed_with_defaults? # to proceed with default options
  end

  if ARGV.length > 0
    print_usage if not (ARGV.length%2).even?
    opt_hash = Hash[*ARGV]
    unless valid_options?(opt_hash)
      print_usage
    else
      set_options(opt_hash)
    end
  end
end

def read_filename
  @filename = ARGV.pop
  unless @filename.nil?
    @filename = valid_filename?(@filename) 
  else
    error_no_filename_given
  end
end
  
def read_all_lines
  File.open(File.basename @filename, "r") do |file|
    file.readlines
  end
end

def print_lines(lines_arr)
  lines_arr.each_with_index do |line, index|
    puts "#{index}: #{line}"
  end
end

def write_to_file(source, file)
  source.each do |line|
    file.write(line)
  end
end

def truncate_lines(lines)
  line_count = @options['-l']
  orientation = @options['-o']
  temp_file = 'history_new'

  File.open(temp_file, "w") do |file|
    if orientation == 'top'
      write_to_file(lines.drop(line_count), file)
    elsif orientation == 'bottom'
      write_to_file(lines.take(@total_lines - line_count), file)
    end
  end

  FileUtils.mv(temp_file, @filename)
end

if $0 == __FILE__
  read_filename # read into @filename variable
  lines = read_all_lines
  @total_lines = lines.length
  parse_user_options
  truncate_lines(lines)
end