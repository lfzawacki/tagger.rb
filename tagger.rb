#!/usr/bin/ruby
#
#  Fill out music files ID3 tags based on file names,
#  directory name or given information
#
#   ./tagger [DIR] -f [FILE PATTERN] -d [DIR PATTERN] -i [INCODITIONAL PATTERN]
#
# = Extra options
#       -s:
#          Only simulate and print what id3v2 will run
#       -h:
#          Print this help text
#       -c:
#          Capitalize all text
# = Patterns
#       %a,   Set the artist information
#       %A,   Set the album title information
#       %t,   Set the song title information
#       %g,   Set the genre number
#       %y,   Set the year
#       %T,   Set the track number
#       %*,   Ignore this part of the string

# TODO
#
# More testing
#  * Move files as requested using ID3 tags
#  * Rename files using ID3 tags
#  * GUI and nautilus (semi) integration

require 'getoptlong'
require 'rdoc/usage'
require 'utils'

OPTIONS = {
    :simulate => false,
    :extension => '.mp3'
}

opts = GetoptLong.new(
   [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
   [ '--simulate', '-s', GetoptLong::NO_ARGUMENT],
   [ '--directory', '-d', GetoptLong::REQUIRED_ARGUMENT],
   [ '--file', '-f', GetoptLong::REQUIRED_ARGUMENT],
   [ '--inconditional', '-i', GetoptLong::REQUIRED_ARGUMENT],
   [ '--capitalize', '-c', GetoptLong::NO_ARGUMENT],
   [ '--extension', '-e', GetoptLong::REQUIRED_ARGUMENT]
)

opts.each do |opt, arg|
    case opt
        when '--help'
            RDoc::usage
        when '--simulate'
            OPTIONS[:simulate] = true
        when '--directory'
            OPTIONS[:dir_expr] = arg
        when '--file'
            OPTIONS[:file_expr] = arg
        when '--inconditional'
            OPTIONS[:inconditional_expr] = arg
        when '--capitalize'
            OPTIONS[:capitalize] = true
        when '--extension'
            OPTIONS[:extension] = '.' + arg
    end
end

# If there's no params show doc and bail
if ARGV.size < 1 then RDoc::usage end

path = File.join(ARGV[0], '*' + OPTIONS[:extension])
files = Dir.glob(path)

# List the files in the directory
files.map! do |f|
    fpath = f.split('/')[-1].remove_extension OPTIONS[:extension]
end

# Prepare the file expression
expr = ""
if OPTIONS[:file_expr]
    expr = OPTIONS[:file_expr].dup
    expr.escape! ['[',']', '.', '(',')']
    expr.gsub! "%*", ".*?"
    parts = expr.scan(/%./).map { |x| x.sub('%','-') }
    expr.gsub!(/%./, "(.*?)")
    expr << "$"
end

#Prepare the dir expression
dir_expr = ""
if OPTIONS[:dir_expr]
    dir_expr = OPTIONS[:dir_expr].dup
    dir_expr.escape! ['[',']','.','(',')']
    dir_expr.gsub! "%*", ".*?"
    dir_parts = dir_expr.scan(/%./).map { |x| x.sub('%','-') }
    dir_expr.gsub!(/%./, "(.*?)")
    dir_expr << "$"

    dir = Dir.pwd.split('/')[-1]
    m = dir.match(dir_expr)
    if m
        dir_captures = m.captures.map { |x| x.quote }
        dir_patterns = dir_parts.interleave(dir_captures)
    end
end

#Prepare inconditional expression
if OPTIONS[:inconditional_expr]
    inconditional = []

    clause = OPTIONS[:inconditional_expr].dup
    clause.split(';').each do |x|
        type , value = x.split(':')
        inconditional << type.sub('%','-')
        inconditional << value.quote
    end
end

# Try to apply it in each file
files.each do |f|
    m = f.match(expr)

    args = []

    if m
        captures = m.captures

        if OPTIONS[:capitalize]
            captures.map! do |c|
                c.split.map(&:capitalize).join(' ')
            end
        end

        captures.map!(&:quote)

        args += parts.interleave(captures) if parts
        args += dir_patterns if dir_patterns
        args += inconditional if inconditional
    end

    # This really runs the script
    if not args.empty?
        # For the moment it's using id3v2 tagger
        run_string = "id3v2 #{(f + OPTIONS[:extension]).quote} #{args.join(' ')}"

        if OPTIONS[:simulate]
            puts run_string
        else
            system run_string
        end
    end
end

