#!/usr/bin/ruby

require 'compressip'

s = CompressIP.new()

s.add("130.232.40.0-127")

(0..15).each    {|n| s.add("130.232.#{n}.*") }
(32..39).each   {|n| s.add("130.232.#{n}.*") }
(41..45).each   {|n| s.add("130.232.#{n}.*") }
(48..63).each   {|n| s.add("130.232.#{n}.*") }
(68..79).each   {|n| s.add("130.232.#{n}.*") }
(98..199).each  {|n| s.add("130.232.#{n}.*") }
(192..207).each {|n| s.add("130.232.#{n}.*") }
(224..254).each {|n| s.add("130.232.#{n}.*") }

(192..202).each {|n| s.add("193.143.#{n}.*") }
(205..206).each {|n| s.add("193.143.#{n}.*") }
(208..209).each {|n| s.add("193.143.#{n}.*") }
(215..217).each {|n| s.add("193.143.#{n}.*") }

s.add("130.232.96.*")
s.add("193.167.206.1-126")
s.add("193.143.204.1-31")
s.add("193.143.204.64-128")
s.add("193.143.204.160-191")
s.add("193.143.210.1-15")
s.add("193.143.210.32-255")
s.add("193.143.211.*")
s.add("193.143.213.*")
s.add("193.143.222.32-255")
s.add("193.143.223.*")

s.resolve.each do |i|
    puts i
end