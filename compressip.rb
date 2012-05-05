require 'integerset'

# Takes a list of IP addresses and compress them down into 
# the smallest set that they can be.
#
# Valid input patterns are:
#
# 1.1.1.1             => 1.1.1.1
# 1.1.1.*             => 1.1.1.0/24
# 1.1.*.*             => 1.1.0.0/16
# 1.*.*.*             => 1.0.0.0/8
# 1.1.0.0/16          => 1.1.0.0/16
# 1.1.0.0/255.255.0.0 => 1.1.0.0/16
# 1.1.1.1-2.2.2.2     => 1.1.1.1-2.2.2.2
# 1.1.1.1-2           => 1.1.1.1-1.1.1.2
#
# The process represents the addresses as integer ranges
# and stores them into a set. After all the addresses have
# been added a call to resolve will display the results.

class CompressIP
	def initialize
		@data = IntegerSet.new()
	end

	def add(address)
		bottom = ''
		top = ''

	    if m = P1.match(address)
			valid_first(m[1], address)
			valid_rest(m[2..4], address)

			bottom = m[1..4].join('.')
			top = m[1..4].join('.')

	    elsif m = P2.match(address)
			valid_first(m[1], address)
			valid_rest(m[2..3], address)

			bottom = m[1..3].join('.') + ".0"
			top = m[1..3].join('.') + ".255"

	    elsif m = P3.match(address)
			valid_first(m[1], address)
			valid_rest(m[2], address)

			bottom = m[1..2].join('.') + ".0.0"
			top = m[1..2].join('.') + ".255.255"

	    elsif m = P4.match(address)
			valid_first(m[1], address)

			bottom = m[1] + ".0.0.0"
			top = m[1] + ".255.255.255"

	    elsif m = P5.match(address)
			valid_first(m[1], address)
			valid_rest(m[2..4], address)
			valid_simple_netmask(m[5], address)

			bottom, top = address_from_simple_netmask(m[1..4], m[5])

	    elsif m = P6.match(address)
			valid_first(m[1], address)
			valid_rest(m[2..4], address)
			valid_complex_netmask(m[5..8], address)

			bottom, top = address_from_complex_netmask(m[1..4], m[5..8])

		elsif m = P7.match(address)
			valid_first(m[1], address)
			valid_rest(m[2..4], address)
			valid_first(m[5], address)
			valid_rest(m[6..8], address)

			## Validate that the second address comes after the first
			bottom = m[1..4].join('.')
			top = m[5..8].join('.')

	    elsif m = P8.match(address)
			valid_first(m[1], address)
			valid_rest(m[2..4], address)
			valid_first(m[5], address)

			## Validate that m[4] is lower than m[5]
			bottom = m[1..4].join('.')
			top = m[1..3].join('.') + "." + m[5]

	    else
			raise "#{address} matches no known pattern"
	    end

		@data.add(ipToInteger(bottom),ipToInteger(top))
	end

	def resolve
		results = Array.new

		@data.each_range do |i|
			results << resolve_range(i.bottom,i.top)
		end

		return results.flatten
	end

	def each
		@data.each do |i|
			yield integerToIp(i)
		end
	end

	private

    # Pattern 1: 1.1.1.1
    P1 = %r{^(\d+){1,3}\.(\d+){1,3}\.(\d+){1,3}\.(\d+){1,3}$}

    # Pattern 2,3,4: 1.1.1.*,1.1.*.*,1.*.*.*
    P2 = %r{^(\d+){1,3}\.(\d+){1,3}\.(\d+){1,3}\.\*$}
    P3 = %r{^(\d+){1,3}\.(\d+){1,3}\.\*\.\*$}
    P4 = %r{^(\d+){1,3}\.\*\.\*\.\*$}

    # Pattern 5, 6: 1.1.1.1/n, 1.1.1.1/255.255.255.0
    P5 = %r{^(\d+){1,3}\.(\d+){1,3}\.(\d+){1,3}\.(\d+){1,3}/(\d+){1,2}$}
    P6 = %r{^(\d+){1,3}\.(\d+){1,3}\.(\d+){1,3}\.(\d+){1,3}/(\d+){1,3}\.(\d+){1,3}\.(\d+){1,3}\.(\d+){1,3}$}

    # Pattern 7: 1.1.1.1-2.2.2.2
    P7 = %r{^(\d+){1,3}\.(\d+){1,3}\.(\d+){1,3}\.(\d+){1,3}-(\d+){1,3}\.(\d+){1,3}\.(\d+){1,3}\.(\d+){1,3}$}

    # Pattern 8: 1.1.1.1-2
    P8 = %r{^(\d+){1,3}\.(\d+){1,3}\.(\d+){1,3}\.(\d+){1,3}-(\d+){1,3}$}

	# Match a binary netmask
	PM = %r{^1+0*$}

	def resolve_range(bottom,top)
		results = Array.new

		if bottom == top
			results << integerToIp(bottom)
		else
			bbottom = toBinary(bottom)
			btop = toBinary(top)

			breaks_at = false
			zeros = 0
			ones = 0
			(0...bbottom.size).each do |p|
				if breaks_at == false
					if bbottom[p] != btop[p]
						breaks_at = p
					end
				else
					if bbottom[p] == ?0
						zeros += 1
					end
					if btop[p] == ?1
						ones += 1
					end
				end
			end

			breaks_at = breaks_at + 1

			if zeros == ones and zeros == (32 - breaks_at)
				results << "#{integerToIp(bottom)}/#{breaks_at - 1}"
			else
				bottombottom = bottom
				bottomtop = bbottom
				(breaks_at...32).each do |p|
					bottomtop[p] = ?1
				end
				bottomtop = fromBinary(bottomtop)

				topbottom = bottomtop + 1
				toptop = top

				results << resolve_range(bottombottom,bottomtop)
				results << resolve_range(topbottom,toptop)
			end
		end

		return results
	end

	# Convert an unsigned integer into a dotted quad
	def integerToIp(value)
		r = Array.new

		4.times do |t|
			x = value % 256
			r << x
			value /= 256
		end

		r.reverse.join(".")
	end

	# Convert a dotted quad into an unsigned integer
	def ipToInteger(address)
		l = address.split('.')

		value = 0
		l.each do |n|
			value = (value * 256) + n.to_i
		end

		return value
	end

	# Convert an unsigned integer to a binary string
	def toBinary(value)
		sprintf("%032b",value)
	end

	# Convert a binary string back into an unsigned integer
	def fromBinary(value)
		total = 0
		(0...32).each do |p|
			total *= 2
			total += 1 if value[p] == ?1
		end
		return total
	end

	def valid_first(value, address)
		if value.to_i < 1 or value.to_i > 255
			raise "First number of #{address} must be 1 <= x <= 255"
		end
	end

	def valid_rest(values, address)
		values.each do |value|
			if value.to_i < 0 or value.to_i > 255
				raise "The subsequent digits of #{address} must be 0 <= x <= 255"
			end
		end
	end

	def valid_simple_netmask(value, address)
		if value.to_i < 1 or value.to_i > 32
			raise "The netmask of #{address} must be 1 <= x <= 32"
		end
	end

	def valid_complex_netmask(values, address)
		valid_first(values[1], "#{address} netmask")
		valid_rest(values[2..4], "#{address} netmask")

		x = ''
		values.each {|v| x << sprintf("%08b", v)}

		unless m = PM.match(x)
			raise "#{address} is not a valid netmask"
		end
	end

	def address_from_simple_netmask(address, mask)
		bottom = toBinary( ipToInteger( address.join('.') ) )
		top = bottom.clone
		(mask.to_i...32).each do |i|
			bottom[i] = ?0
			top[i] = ?1
		end

		bottom = integerToIp( fromBinary( bottom ) )
		top = integerToIp( fromBinary( top ) )

		return bottom, top
	end

	def address_from_complex_netmask(address, mask)
		x = ''
		mask.each {|v| x << sprintf("%08b", v)}

		x.gsub!(/0/,'')

		bottom, top = address_from_simple_netmask( address, x.length )
	end
end
