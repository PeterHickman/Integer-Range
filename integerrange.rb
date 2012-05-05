# Represent an integer range as a pair of integers, bottom and top.
# Can be merged with other IntegerRange objects and provides the
# each and to_a methods to extract the members of a range.
#
# *MINIMUM* *CODE* *WARNING*
# This code implements the least functionality required to get
# the job it was written to do done. I do not _presently_ know
# what I will require of this code in the future and even less
# of what your requirements are. I will add it when I get there.
#
# If I could see into the future I would be much richer than I am.
#
# Author:: Peter Hickman.
# Copyright:: Copyright (c) 2005 Peter Hickman. All rights reserved.
# License:: Ruby license.

class IntegerRange
	# Given two values set both ends of the range. If the top value 
	# is missing it will be set to the value of bottom
	def initialize(bottom, top=nil)
		top ||= bottom

		if bottom < top
			@bottom = bottom
			@top = top
		else
			@bottom = top
			@top = bottom
		end
	end

	# The inclusive bottom of the range
	attr_reader :bottom

	# The inclusive top of the range
	attr_reader :top

	# Two IntegerRange objects can be merged if they overlap, enclose or abut.
	def mergeable?(other)
		if (@top + 1) == other.bottom
			return true
		elsif (@bottom - 1) == other.top
			return true
		elsif (@bottom <= other.bottom) and (other.bottom <= @top)
			return true
		elsif (other.bottom <= @bottom) and (@bottom <= other.top)
			return true
		end

		return false
	end

	# Merge the other IntegerRange into the current one if the other is
	# mergeable? Otherwise raise an ArgumentError
	def merge(other)
		raise ArgumentError, "The ranges cannot be merged" unless mergeable?(other)

		@bottom = (@bottom < other.bottom) ? @bottom : other.bottom
		@top = (@top < other.top) ? other.top : @top
	end

	# Generate all the integers in the range
	def each
		(@bottom..@top).each {|i| yield i}
	end

	# Return an array of the integers in the range
	def to_a
		(@bottom..@top).to_a
	end
end
