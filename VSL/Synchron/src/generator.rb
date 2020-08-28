require "json"

C4 = 60
INSTRUMENTS = {
  "Strings (high)": {
    "C1": {
      "C2": "Staccato",
      "C#2": "Detache",
    },
    "C#1": {
      "C2": "Sustain",
      "C#2": "Marcato (w/CC1)",
      "D2": "XF tremolo (w/CC20)",
    },
    "D1": {
      "C2": "Legato",
      "C#2": "Legato-sus",
    },
    "D#1": {
      "C2": "Sforzato",
      "C#2": "Sfz XV tremolo (w/CC20)",
    },
    "E1": {
      "C2": "Tremolo",
      "C#2": "Trem. marcato (w/CC1)",
    },
    "F1": {
      nil => "Pizzicato"
    },
    "F#1": {
      "C2": "Custom 1",
      "C#2": "Custom 2",
      "D2": "Custom 3",
      "D#2": "Custom 4",
    }
  }
}
NOTE_NAME = %w(C C# D D# E F F# G G# A A# B)

def parse_note(s)
  return nil if s.nil?

  raise "Invalid note name: #{s}" unless s =~ /\A([ACDFG]#?|[BE])([0-9])\z/

  name, octave = $~.captures.yield_self {|n, o| [n, o.to_i] }

  n = C4 + (12 * (octave - 4))
  n + NOTE_NAME.index(name)
end

def generate_id(note_a, note_b)
  note_a * 12 + note_b.to_i
end

def generate_articulation_id(id)
  1000 + id
end

INSTRUMENTS.each do |set, articulations|
  a = []
  articulations.each {|note_a_str, types|
    types.each do |note_b_str, name|
      note_a, note_b = parse_note(note_a_str), parse_note(note_b_str)

      id = generate_id(note_a, note_b)
      h = {
        ArticulationID: id,
        ID: generate_articulation_id(id),
        Name: name,
        Output: [
          {
            MB1: note_a,
            Status: "Note ON",
            ValueLow: 0,
          }
        ]
      }

      if note_b
        h[:Output] << {
          MB1: note_b,
          Status: "Note On",
          ValueLow: 0,
        }
      end

      a << h
    end
  }
  File.write("#{__dir__}/../Synchron #{set}.json", JSON.pretty_generate(Articulations: a))
end
