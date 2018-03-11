##Devin Dang (ded57)

require_relative 'block'
require_relative 'transaction'
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
	i = 0
	while i < @blockchain.count
		block_partitions = @blockchain[i].split('|')
		# block_partitions[0] = block_number
		# block_partitions[1] = previous_hash
		# block_partitions[2] = sequence_tranactions
		# block_partitions[3] = timestamp
		# block_partitions[4] = current_hash
		@blocks[i] = Block.new(block_partitions[0].to_i, block_partitions[1], block_partitions[2], block_partitions[3], block_partitions[4])
		i += 1
	end
end

def check_transactions
	transactions_semicolon_split = []
	i = 0
	@balance = Hash.new(0)
	while i < @blocks.count
		transactions_semicolon_split = @blocks[i].sequence_tranactions.split(':')
		j = 0
		while j < transactions_semicolon_split.count
			transactions = []
			transaction_partitions = transactions_semicolon_split[j].split(/>|[()]/) 
			transactions[j] = Transaction.new(transaction_partitions[0], transaction_partitions[1], transaction_partitions[2].to_i)
			
			if !transactions[j].from_addr.strip.eql? "SYSTEM"
				@balance[transactions[j].from_addr] -= transactions[j].num_billcoins_sent
			end
			
			@balance[transactions[j].to_addr] +=  transactions[j].num_billcoins_sent
			
			if transactions[j].from_addr.length > 6
				puts "In #{transactions[j].transaction_string} of line #{@blocks[i].block_number}, the from address is too long."
			end
			
			if transactions[j].to_addr.length > 6
				puts "In #{transactions[j].transaction_string} of line #{@blocks[i].block_number}, the to address is too long."
			end
			
			if !transactions[j].from_addr.match(/[[:alpha:]]/)
				puts "In #{transactions[j].transaction_string} of line #{@blocks[i].block_number}, the from address contains an invalid character."
			end
			
			if !transactions[j].to_addr.match(/[[:alpha:]]/)
				puts "In #{transactions[j].transaction_string} of line #{@blocks[i].block_number}, the to address contains an invalid character."
			end
			
			if i == @blocks.count - 1
				if j == transactions_semicolon_split.count - 1
					if !transactions[j].from_addr.strip.eql? "SYSTEM"
						puts "In #{transactions[j].transaction_string} of line #{@blocks[i].block_number}, the last transaction should be from SYSTEM."
					end
					if transactions[j].num_billcoins_sent != 100
						puts "In #{transactions[j].transaction_string} of line #{@blocks[i].block_number}, SYSTEM should have sent 100 billcoins."
					end
				end
			end
			
			j += 1
		end
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

			if timestamp_two_partitions[0] < timestamp_one_partitions[0]
				puts "In line #{@blocks[i].block_number}, the timestamp did not increase."
			end

			if timestamp_two_partitions[0] >= timestamp_one_partitions[0]
				if timestamp_two_partitions[1] <= timestamp_one_partitions[1]
					puts "In line #{@blocks[i].block_number}, the timestamp did not increase."
				end
			end

			i += 1
		end
	end
end

def check_block_number
	i = 0
	while i < @blocks.count
		if i != @blocks[i].block_number
			puts "In line #{@blocks[i].block_number}, the block number did not properly increment by one."
		end
		i += 1
	end
end

def compare_hashes
	if @blocks.count > 1
		i = 0
		while i < @blocks.count
			correct_hash = @blocks[i].hash_block
			if !correct_hash.strip.eql? @blocks[i].current_hash.strip
				puts "In line #{@blocks[i].block_number}, the hash is not correct."
			end
			i += 1
		end
	end
end

def check_previous_hashes
	if !@blocks[0].previous_hash.strip.eql? "0"
		puts "In line #{@blocks[0].block_number}, the hash of the previous block should be 0."
	end
	
	if @blocks.count > 1
		i = 1
		while i < @blocks.count
			if !@blocks[i].previous_hash.strip.eql? @blocks[i-1].current_hash.strip
				puts "In line #{@blocks[0].block_number}, the previous hash is not correct."
			end
			i += 1
		end
	end
end

def print_outcome
	@balance.each do |key, value|
		puts "#{key}: #{value} billcoins"
	end
end


		

start
partition
check_previous_hashes
check_block_number
compare_timestamps
compare_hashes
check_transactions
print_outcome