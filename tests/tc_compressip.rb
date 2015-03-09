require 'test/unit'

require_relative '../compressip'

class CompressIPTestWrapper < Test::Unit::TestCase
  ##
  ## Test that valid inputs are translated as expected
  ##

  def test_add_pattern_1
    simple_test('1.1.1.1', ['1.1.1.1'])
  end

  def test_add_pattern_2
    simple_test('1.1.1.*', ['1.1.1.0/24'])
  end

  def test_add_pattern_3
    simple_test('1.1.*.*', ['1.1.0.0/16'])
  end

  def test_add_pattern_4
    simple_test('1.*.*.*', ['1.0.0.0/8'])
  end

  def test_add_pattern_5
    simple_test('1.1.1.1/16', ['1.1.0.0/16'])
  end

  def test_add_pattern_6
    simple_test('1.1.1.1/255.255.0.0', ['1.1.0.0/16'])
  end

  def test_add_pattern_7
    simple_test('1.1.0.0-1.1.255.255', ['1.1.0.0/16'])
  end

  def test_add_pattern_8
    simple_test('1.1.1.1-5', ['1.1.1.1', '1.1.1.2/31', '1.1.1.4/31'])
  end

  ##
  ## Test invalid inputs
  ##

  ##
  ## Test consolidation
  ##

  private

  ##
  ## Given an input we should match this output
  ##

  def simple_test(input, output)
    c = CompressIP.new

    c.add(input)

    a = []
    c.resolve.each { |i| a << i }

    assert_equal(output.size, a.size)

    output.each_index do |i|
      assert_equal(output[i], a[i])
    end
  end
end
