provides 'etc', 'current_user'

require 'etc'

def parse_passwd_line(line)
  line.chomp!
  if line[0] == '#'
    return {}
  end
  entry = Mash.new
  parsed_line = line.split(':')
  name = fix_encoding(parsed_line[0])
  entry[:uid] = parsed_line[2].to_i
  entry[:gid] = parsed_line[3].to_i
  entry[:gecos] = parsed_line[4]
  entry[:dir] = parsed_line[5]
  entry[:shell] = parsed_line[6]
  { name => entry }
end

def parse_group_line(line)
  line.chomp!
  if line[0] == '#'
    return {}
  end
  entry = Mash.new
  parsed_line = line.split(':')
  name = fix_encoding(parsed_line[0])
  entry[:gid] = parsed_line[2].to_i
  entry[:members] = parsed_line[3].to_s.split(",").map { |u| fix_encoding(u) }
  { name => entry }
end


# Use the same fix_encoding function
# as used in the "real" passwd plugin
def fix_encoding(str)
  str.force_encoding(Encoding.default_external) if str.respond_to?(:force_encoding)
  str
end

unless etc
  etc Mash.new
  etc[:passwd] = Hash.new
  etc[:group] = Hash.new

  File.open("/etc/passwd", "r") do |f|
    f.each_line do |line|
      etc[:passwd].merge!(parse_passwd_line(line))
    end
  end

  File.open("/etc/group", "r") do |f|
    f.each_line do |line|
      etc[:group].merge!(parse_group_line(line))
    end
  end
end

unless current_user
  current_user fix_encoding(Etc.getlogin)
end
