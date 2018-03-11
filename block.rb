## Devin Dang (ded57)

#require_relative 'transaction'


class Block
	attr_accessor :block_number, :previous_hash, :sequence_tranactions, :timestamp, :current_hash, :correct_hash

	def initialize(block_number, previous_hash, sequence_tranactions, timestamp, current_hash)
		@block_number = block_number
		@previous_hash = previous_hash
		@sequence_tranactions = sequence_tranactions
		@timestamp = timestamp
		@current_hash = current_hash
	end

	def hash_block
		string_to_hash = "#{block_number}|#{previous_hash}|#{sequence_tranactions}|#{timestamp}"
		unpacked_string = string_to_hash.unpack('U*')
		sum = 0
		unpacked_string.each do |x|
			x = (x ** 2000) * ((x + 2) ** 21) - ((x + 5) ** 3)
			sum += x
		end
		value = sum % 65536
		value.to_s(16).strip
	end


end
