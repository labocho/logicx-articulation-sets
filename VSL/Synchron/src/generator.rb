require "json"

C4 = 60
INSTRUMENTS = {
  "Strings (high)": {
    "Registers": ["C1", "C2"],
    "Articulations": {
      "C": {
        "C": "Staccato",
        "C#": "Detache",
      },
      "C#": {
        "C": "Sustain",
        "C#": "Marcato (w/CC1)",
        "D": "XF tremolo (w/CC20)",
      },
      "D": {
        "C": "Legato",
        "C#": "Legato-sus",
      },
      "D#": {
        "C": "Sforzato",
        "C#": "Sfz XV tremolo (w/CC20)",
      },
      "E": {
        "C": "Tremolo",
        "C#": "Trem. marcato (w/CC1)",
      },
      "F": {
        nil => "Pizzicato"
      },
      "F#": {
        "C": "Custom 1",
        "C#": "Custom 2",
        "D": "Custom 3",
        "D#": "Custom 4",
      },
    },
  },
}

class ArticulationSetGenerator
  NOTE_NAME = %w(C C# D D# E F F# G G# A A# B)

  def self.parse(hash)
    new.parse(hash)
  end

  def parse(hash)
    a = []

    articulation_register, type_register = hash[:Registers].map {|r| parse_register(r) }

    hash[:Articulations].each {|note_a_str, types|
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

    {Articulations: a}
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

INSTRUMENTS.each do |name, hash|
  set = ArticulationSetGenerator.parse(hash)
  File.write("#{__dir__}/../Synchron #{name}.json", JSON.pretty_generate(set))
end
