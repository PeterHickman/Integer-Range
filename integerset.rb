require 'integerrange'

# Creates a set of integers by storing a collection of integer
# ranges. This class is based on the assumption that the data
# will form ranges and is not sparse. If your data does not fit
# this assumption then you might find that this class is not
# the most efficient way to store your data.
#
# *MINIMUM* *CODE* *WARNING*
# This code implements the least functionality required to get
# the job it was written to do done. I do not _presently_ know
# what I will require of this code in the future and even less
# of what your requirements are. I will add it when I get there.
#
# If I could see into the future I would be much richer than I am.
#
# *IMPROVEMENTS*
# * a delete method
#
# Author:: Peter Hickman.
# Copyright:: Copyright (c) 2005 Peter Hickman. All rights reserved.
# License:: Ruby license.

class IntegerSet
	# Create an empty integer set
	def initialize
		@data = Array.new
	end

	# Add a new integer range, defined by bottom and top, to the set. 
	# If the top value is not set it will assume the value of bottom.
	def add(bottom, top)
		add_new_item(IntegerRange.new(bottom,top))
	end

	# Generate all the integers in the set
	def each
		@data.sort{|a,b| a.bottom <=> b.bottom}.each do |i|
			i.each do |j|
				yield j
			end
		end
	end

	def each_range
		@data.sort{|a,b| a.bottom <=> b.bottom}.each do |i|
			yield i
		end
	end

	# Return an array of the integers in the set
	def to_a
		x = Array.new

		@data.sort{|a,b| a.bottom <=> b.bottom}.each do |i|
			x << i.to_a
		end

		return x.flatten
	end

	# Returns the number of ranges in the set. This was 
	# mostly introduced for testing but is useful to me
	def size
		@data.size
	end

	private

	# Add an integer range into the set
	def add_new_item(item)
		if @data.empty?
			# Empty set, just stuff it in
			@data << item
		else
			at = false
			(0...@data.size).each do |i|
				if item.mergeable?(@data[i])
					at = i
					break
				end
			end

			if at == false
				# Nothing to merge with, stuff it in
				@data << item
			else
				# Merge with the existing item, delete
				# the existing item and try and add the
				# new, expanded, range again.
				item.merge(@data[at])
				@data.delete_at(at)
				add_new_item(item)
			end
		end
	end
end
