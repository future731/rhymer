#!/usr/bin/env ruby
require 'rhymer'

def rhymer(line)
  rhymer = Rhymer::Parser.new(line + '\n', { :vibes_threshold => 10, :prefix_length => 2})
  has_rhyme = false
  rhymer_strings = ""
  # 1つだけリプライ
  unless rhymer.rhyme.length == 0
    @rhyme_str = "[" + rhymer.rhyme[0] + "] と [" + rhymer.rhyme[1] + "]は、韻を踏んでいます。"
    puts @rhyme_str
    rhymer_strings += (@rhyme_str + "\n".force_encoding('utf-8'))
  end
end

f = open('test.log', 'r')
for line in f
    rhymer(line)
end
f.close()
