##Devin Dang (ded57)

require_relative 'block'
#require_relative 'transaction'
#attr_accessor :input, :blockchain, :block_partitions, :blocks


def start
	input = ARGV[0]

	if ARGV.length != 1
		puts "Please enter only the file name! Program exiting..."
		exit 0
	end

	@blockchain = IO.readlines(input)
end

def partition
	@blocks = []
	@transactions = []
	i = 0
	while i < @blockchain.count
		block_partitions = @blockchain[i].split('|')
		# block_partitions[0] = block_number
		# block_partitions[1] = previous_hash
		# block_partitions[2] = sequence_tranactions
		# block_partitions[3] = timestamp
		# block_partitions[4] = current_hash
		@blocks[i] = Block.new(block_partitions[0], block_partitions[1], block_partitions[2], block_partitions[3], block_partitions[4])
		i += 1
	end
end

def compare_timestamps
	if @blocks.count > 1
		i = 1
		while i < @blocks.count
			timestamp_one_string_partitions = @blocks[i-1].timestamp.split('.')
			timestamp_two_string_partitions = @blocks[i].timestamp.split('.')

			timestamp_one_partitions = timestamp_one_string_partitions.map(&:to_i)
			timestamp_two_partitions = timestamp_two_string_partitions.map(&:to_i)
			
			puts "#{timestamp_one_partitions[0]}.#{timestamp_one_partitions[1]}"
			puts "#{timestamp_two_partitions[0]}.#{timestamp_two_partitions[1]}"

			if timestamp_two_partitions[0] < timestamp_one_partitions[0]
				puts "In line #{@blocks[i].block_number}, the timestamp did not increase."
			end

			if timestamp_two_partitions[0] >= timestamp_one_partitions[0]
				if timestamp_two_partitions[1] <= timestamp_one_partitions[1]
					puts "In line #{@blocks[i].block_number}, the timestamp did not increase."
				end
			end

			puts "Line #{@blocks[i].block_number} compare timestamp success!"
			i += 1
		end
	end
end


def compare_hashes
	if @blocks.count > 1
		i = 0
		while i < @blocks.count
			correct_hash = @blocks[i].hash_block
			if correct_hash.strip.eql? @blocks[i].current_hash.strip
				puts "Line #{@blocks[i].block_number} compare hash success!"
			else
				puts "In line #{@blocks[i].block_number}, the hash is not correct."
			end
			i += 1
		end
	end
end


		

start
partition
#"#{@blocks[0].block_number}|#{@blocks[0].previous_hash}|#{@blocks[0].sequence_tranactions}"
compare_timestamps
compare_hashes
