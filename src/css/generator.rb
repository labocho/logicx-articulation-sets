require "json"
require "yaml"
require "fileutils"
require "open3"
require "tmpdir"

def sh(*args)
  o, e, s = Open3.capture3(*args)
  unless s.success?
    $stderr.puts e
    exit s.to_i
  end
  o
end

C4 = 60

class ArticulationSetGenerator
  NOTE_NAME = %w(C C# D D# E F F# G G# A A# B)

  def self.parse(name, hash)
    new.parse(name, hash)
  end

  def parse(name, hash)
    a = []

    articulation_register, type_register = hash["Registers"].map {|r| parse_register(r) }

    hash["Articulations"].each {|note_a_str, types|
      note_a = parse_note(note_a_str)
      types.each do |note_b_str, name|
        note_b = parse_note(note_b_str)

        id = generate_id(note_a, note_b)
        h = {
          ArticulationID: id,
          ID: generate_articulation_id(id),
          Name: name,
          Output: [
            {
              MB1: articulation_register + note_a,
              Status: "Note ON",
              ValueLow: 0,
            }
          ]
        }

        if note_b
          h[:Output] << {
            MB1: type_register + note_b,
            Status: "Note On",
            ValueLow: 0,
          }
        end

        a << h
      end
    }

    if (default = hash["Default"])
      a.unshift(a.find {|a| a[:Name] == default }.merge(Name: "(default)", ID: 0, ArticulationID: 0))
    end

    {
      Articulations: a,
      MultipleOutputsActive: true,
      Name: name,
      Switches: [],
    }
  end

  def parse_register(s)
    raise "Invalid note name: #{s}" unless s.to_s =~ /\AC([0-9])\z/

    i = $~.captures[0].to_i
    C4 + (12 * (i - 4))
  end

  def parse_note(s)
    NOTE_NAME.index(s.to_s)
  end

  def generate_id(note_a, note_b)
    note_a * 12 + note_b.to_i + 1
  end

  def generate_articulation_id(id)
    1000 + id
  end
end

DEST_DIR = "#{__dir__}/../../build/css"
FileUtils.mkdir_p DEST_DIR

ARGV.each do |yaml|
  name = File.basename(yaml).gsub(File.extname(yaml), "")
  set = ArticulationSetGenerator.parse(name, YAML.load_file(yaml))
  dest = "#{DEST_DIR}/#{name}.plist"
  File.write(dest, JSON.pretty_generate(set))
  sh "plutil", "-convert", "xml1", dest
end
