require 'test/unit'

require_relative '../integerset'

class IntegerSetTestWrapper < Test::Unit::TestCase
	##
	## As ranges are added they should merge
	##

	def test_add_items
		s = IntegerSet.new()

		s.add(1,2)
		assert_equal(1,s.size)

		s.add(4,5)
		assert_equal(2,s.size)

		s.add(3,3)
		assert_equal(1,s.size)

		s.add(2,7)
		assert_equal(1,s.size)
	end

	##
	## Merge lots of individual ranges
	##

	def test_add_many
		s = IntegerSet.new()

		(1..100).each do |value|
			x = value * 2
			s.add(x,x)
		end
		assert_equal(100,s.size)

		(1..100).each do |value|
			x = value * 2 + 1
			s.add(x,x)
		end
		assert_equal(1,s.size)
	end

	def test_add_bigger
		s = IntegerSet.new()

		(1..100).each do |value|
			x = value * 2
			s.add(x,x)
		end
		assert_equal(100,s.size)

		s.add(1,200)
		assert_equal(1,s.size)
	end

	##
	## Do the arrays come out in order
	##

	def test_to_a_1
		s = IntegerSet.new()
		s.add(1,5)
		s.add(10,20)

		a = ranges_to_a((1..5),(10..20))

		assert_equal(a,s.to_a)
	end

	##
	## Even if they are created out of order
	##

	def test_to_a_2
		s = IntegerSet.new()
		s.add(10,20)
		s.add(1,5)

		a = ranges_to_a((1..5),(10..20))

		assert_equal(a,s.to_a)
	end

	##
	## Just making sure...
	##

	def test_to_a_3
		s = IntegerSet.new()
		s.add(10,20)
		s.add(1,5)
		s.add(2,15)

		a = ranges_to_a((1..20))

		assert_equal(a,s.to_a)
	end

	##
	## Test the each range method
	##

	def test_each_range
		s = IntegerSet.new()
		s.add(1,5)
		s.add(10,20)

		b = IntegerRange.new(1,2)

		a = Array.new()
		s.each_range do |r|
			assert_equal(b.class,r.class)
			a << r
		end

		assert_equal(1,a[0].bottom)
		assert_equal(5,a[0].top)
		assert_equal(10,a[1].bottom)
		assert_equal(20,a[1].top)

		s.add(2,19)

		a = Array.new()
		s.each_range do |r|
			assert_equal(b.class,r.class)
			a << r
		end

		assert_equal(1,a[0].bottom)
		assert_equal(20,a[0].top)
	end

	##
	## Does the each come out in order
	##

	def test_each_1
		s = IntegerSet.new()
		s.add(1,5)
		s.add(10,20)

		a = ranges_to_a((1..5),(10..20))
		b = each_to_a(s)

		assert_equal(a,b)
	end

	##
	## Even if they are created out of order
	##

	def test_each_2
		s = IntegerSet.new()
		s.add(10,20)
		s.add(1,5)

		a = ranges_to_a((1..5),(10..20))
		b = each_to_a(s)

		assert_equal(a,b)
	end

	##
	## Just making sure...
	##

	def test_each_3
		s = IntegerSet.new()
		s.add(10,20)
		s.add(1,5)
		s.add(2,15)

		a = ranges_to_a((1..20))
		b = each_to_a(s)

		assert_equal(a,b)
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

	##
	## Convert ranges into a big array
	##

	def ranges_to_a(*ranges)
		a = Array.new
		ranges.each{|r| a << r.to_a}
		return a.flatten
	end
end
