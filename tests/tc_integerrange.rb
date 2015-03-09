require 'test/unit'

require_relative '../integerrange'

class IntegerRangeTestWrapper < Test::Unit::TestCase
	##
	## Do the bottom and top values get set correctly ...
	##

	def test_bottom_top
		x = IntegerRange.new(1,1000)

		assert_equal(x.bottom,1)
		assert_equal(x.top,1000)
		assert_equal(x.to_a,(1..1000).to_a)

		a = each_to_a(x)

		assert_equal(a,(1..1000).to_a)
	end

	##
	## ... even when they are the wrong way round
	##

	def test_top_bottom
		x = IntegerRange.new(1000,1)

		assert_equal(x.bottom,1)
		assert_equal(x.top,1000)
		assert_equal(x.to_a,(1..1000).to_a)

		a = each_to_a(x)

		assert_equal(a,(1..1000).to_a)
	end

	##
	## Entering a single value
	##

	def test_single_value
		x = IntegerRange.new(42)

		assert_equal(x.bottom,42)
		assert_equal(x.top,42)
		assert_equal(x.to_a,(42..42).to_a)

		a = each_to_a(x)

		assert_equal(a,(42..42).to_a)
	end
	##
	## Could something merge with itself
	##

	def test_self
		x = IntegerRange.new(1,2)

		assert_equal(x.mergeable?(x),true)
	end

	##
	## Disjoint ranges cannot merge
	##

	def test_disjoint
		x = IntegerRange.new(1,2)
		y = IntegerRange.new(4,5)

		assert_equal(x.mergeable?(y),false)
		assert_equal(y.mergeable?(x),false)
	end

	##
	## Merging disjoin ranges raises an error
	##

	def test_failed_merge
		x = IntegerRange.new(1,2)
		y = IntegerRange.new(4,5)

		assert_equal(x.mergeable?(y),false)
		assert_equal(y.mergeable?(x),false)

		assert_raise(ArgumentError) { x.merge(y) }
		assert_raise(ArgumentError) { y.merge(x) }
	end

	##
	## Can merge abutted ranges
	##

	def test_abutting
		x = IntegerRange.new(1,2)
		y = IntegerRange.new(3,4)

		assert_equal(x.mergeable?(y),true)
		assert_equal(y.mergeable?(x),true)
	end

	##
	## Can merge overlaping ranges
	##

	def test_overlaping
		x = IntegerRange.new(1,5)
		y = IntegerRange.new(3,10)

		assert_equal(x.mergeable?(y),true)
		assert_equal(y.mergeable?(x),true)
	end

	##
	## Can merge identical ranges
	##

	def test_identical
		x = IntegerRange.new(1,5)
		y = IntegerRange.new(1,5)

		assert_equal(x.mergeable?(y),true)
		assert_equal(y.mergeable?(x),true)
	end

	##
	## Can merge enclosed ranges
	##

	def test_enclosed
		x = IntegerRange.new(1,10)
		y = IntegerRange.new(3,5)

		assert_equal(x.mergeable?(y),true)
		assert_equal(y.mergeable?(x),true)
	end

	##
	## Check abutting ranges merge...
	##

	def test_merge_abutting_1
		x = IntegerRange.new(1,4)
		y = IntegerRange.new(5,10)

		assert_equal(x.mergeable?(y),true)
		x.merge(y)

		assert_equal(x.bottom,1)
		assert_equal(x.top,10)
		assert_equal(x.to_a,(1..10).to_a)

		a = Array.new
		x.each {|i| a << i}

		assert_equal(a,(1..10).to_a)
	end

	##
	## ... this time the other way round
	##

	def test_merge_abutting_2
		x = IntegerRange.new(1,4)
		y = IntegerRange.new(5,10)

		assert_equal(y.mergeable?(x),true)
		y.merge(x)

		assert_equal(y.bottom,1)
		assert_equal(y.top,10)
		assert_equal(y.to_a,(1..10).to_a)

		a = each_to_a(y)

		assert_equal(a,(1..10).to_a)
	end

	##
	## Can merge overlapping ranges ...
	##

	def test_merge_overlaping_1
		x = IntegerRange.new(1,5)
		y = IntegerRange.new(3,10)

		assert_equal(x.mergeable?(y),true)
		x.merge(y)

		assert_equal(x.bottom,1)
		assert_equal(x.top,10)
		assert_equal(x.to_a,(1..10).to_a)

		a = each_to_a(x)

		assert_equal(a,(1..10).to_a)
	end

	##
	## ... this time the other way round
	##

	def test_merge_overlaping_2
		x = IntegerRange.new(1,5)
		y = IntegerRange.new(3,10)

		assert_equal(y.mergeable?(x),true)
		y.merge(x)

		assert_equal(y.bottom,1)
		assert_equal(y.top,10)
		assert_equal(y.to_a,(1..10).to_a)

		a = each_to_a(y)

		assert_equal(a,(1..10).to_a)
	end

	##
	## Check that enclosing ranges can be merges
	##

	def test_merge_enclosed_1
		x = IntegerRange.new(1,10)
		y = IntegerRange.new(3,5)

		assert_equal(x.mergeable?(y),true)
		x.merge(y)

		assert_equal(x.bottom,1)
		assert_equal(x.top,10)
		assert_equal(x.to_a,(1..10).to_a)

		a = each_to_a(x)

		assert_equal(a,(1..10).to_a)
	end

	##
	## ... this time the other way round
	##

	def test_merge_enclosed_2
		x = IntegerRange.new(1,10)
		y = IntegerRange.new(3,5)

		assert_equal(y.mergeable?(x),true)
		y.merge(x)

		assert_equal(y.bottom,1)
		assert_equal(y.top,10)
		assert_equal(y.to_a,(1..10).to_a)

		a = each_to_a(y)

		assert_equal(a,(1..10).to_a)
	end

	private

	##
	## Repeatedly call each and store the results in an array
	##

	def each_to_a(s)
		a = Array.new
		s.each{|i| a << i}
		return a
	end
end
