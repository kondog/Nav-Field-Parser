#encoding: UTF-8
require "strscan"

class NavParser
  attr_accessor :fields
  def initialize
    @fields = []
  end
  def parse_id( str )
    str.delete(" ").delete(";")
  end
  def parse_name( str )
    scanner = StringScanner.new( str )
    name = ""
    while not scanner.eos?
      tmp_str = scanner.scan_until(/\w+/)
      if not tmp_str.nil?
        name += tmp_str unless tmp_str.include?( ';' )
      else
        return name
      end
    end
  end
  def parse_type( str )
    scanner = StringScanner.new( str )
    return scanner.scan(/\w+/)
  end
  def parse_caption( str )
    scanner = StringScanner.new( str )
    str_include_trash = ""
    while !scanner.check_until(/[;}]/).nil?
      scanner.scan(/\s+/)
      str_include_trash += scanner.scan_until(/[;}]/)
    end
    while str_include_trash[-1] =~ /[\s;}]/
      str_include_trash.slice!(-1)
    end
    str_include_trash
  end

  def parse_fields( fields_str )
    scanner = StringScanner.new( fields_str )
    while !scanner.eos?
      regexp = '\{.*?\}'
      if scanner.check_until(/#{regexp}/m) != nil
        # ?で最小マッチ
        parse_each_fields( scanner.scan_until(/#{regexp}/m))
      else
        break
      end
    end
  end

  def parse_each_fields( field_str )
    scanner = StringScanner.new( field_str )
    scanner.scan_until( /{/ )
    id     = parse_id( scanner.scan_until( /;/ ) )
    enable = scanner.scan_until( /;/ )
    name   = parse_name(scanner.scan_until( /;/ ))
    type   = parse_type(scanner.scan_until( /;/ ))
    caption = nil
    while !scanner.eos?
      str_until_semicolon = scanner.check_until( /[;}]/ )
      case 
      when str_until_semicolon.nil?
        break
      when str_until_semicolon.include?( "CaptionML" )
        str_until_semicolon = scanner.scan_until( /[;}]/ )
        if !scanner.check_until(/[;}]/m).nil?
          caption = parse_caption(str_until_semicolon + scanner.scan_until(/[;}]/m))
        else
          caption = parse_caption(str_until_semicolon)
        end
      else
        str_until_semicolon = scanner.scan_until( /[;}]/ )
      end
    end
    @fields << {:ID => id, :Enable => "", :Name => name, :Type => type, :Caption => caption }
  end

  def parse_file_data( file_str )
    scanner = StringScanner.new( file_str )
    scanner.scan_until(/FIELDS/)
    scanner.scan(/\s+{\s*/)
    scanner.scan_until(/KEYS/)
  end
end

if $0 == __FILE__
  if ARGV[0].nil?
    puts 'Input File Name in 1st argument.'
    exit(1)
  elsif !File.exists? ARGV[0]
    puts "File not exists: #{ARGV[0]}"
    exit(1)
  end
  nav_parser = NavParser.new
  file_data = IO.read(ARGV[0]).encode("UTF-16BE", "UTF-8",
                                      :invalid => :replace,
                                      :undef   => :replace,
                                      :replace => '?').encode("UTF-8")
  file_data_parsed = nav_parser.parse_file_data( file_data )
  nav_parser.parse_fields( file_data_parsed )
end
