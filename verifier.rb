##Devin Dang (ded57)

require_relative 'block'
require_relative 'transaction'
#require 'flamegraph'

class Verifier
	attr_accessor :input, :blockchain, :blocks, :balance, :transactions
	
	def self.initialize(blockchain, blocks, balance)
		@blockchain = blockchain
		@blocks = blocks
		@balance = balance
	end

	def self.blockchain=(value)
		@blockchain = value
	end

	def self.blockchain
		@blockchain
	end

	def self.blocks=(value)
		@blocks = value
	end

	def self.blocks
		@blocks
	end



	def self.argscheck
		if ARGV.length != 1
			puts "Please enter only the file name! Program exiting..."
			exit 0
		else
			args = ARGV[0]
		end
		return args
	end

	def self.check_empty_file(args)
		@input = args

		if File.zero?(@input)
			puts "File is empty. Program exiting..."
			exit 0
		else
			blockchain = read_lines(@input)
			blocks = partition(blockchain)
			balance = Hash.new(0)
		end
		initialize(blockchain, blocks, balance)
	end


	def self.read_lines(data_in)
		blockchain_split = []
		blockchain_split = IO.readlines(data_in)
		return blockchain_split
	end

	

	def self.partition(data_in)
		data_out = []
		i = 0
		while i < data_in.count
			block_partitions = data_in[i].split('|')
			# block_partitions[0] = block_number
			# block_partitions[1] = previous_hash
			# block_partitions[2] = sequence_tranactions
			# block_partitions[3] = timestamp
			# block_partitions[4] = current_hash
			data_out[i] = Block.new(block_partitions[0].to_i, block_partitions[1], block_partitions[2], block_partitions[3], block_partitions[4])
			i += 1
		end
		return data_out
	end

	def self.check_transactions
		transactions_semicolon_split = []
		i = 0
		while i < @blocks.count
			transactions_semicolon_split = @blocks[i].sequence_tranactions.split(':')
			j = 0
			while j < transactions_semicolon_split.count
				@transactions = []
				transaction_partitions = transactions_semicolon_split[j].split(/>|[()]/) 
				@transactions[j] = Transaction.new(transaction_partitions[0], transaction_partitions[1], transaction_partitions[2].to_i)
				
				if !@transactions[j].from_addr.strip.eql? "SYSTEM"
					@balance[@transactions[j].from_addr] -= @transactions[j].num_billcoins_sent
				end
				
				@balance[@transactions[j].to_addr] +=  @transactions[j].num_billcoins_sent

				if check_balances(i) == -1
					puts "BLOCKCHAIN INVALID"
					exit 0
				end
				
				if @transactions[j].from_addr.length > 6
					puts "Line #{@blocks[i].block_number}: the from address #{transactions[j].from_addr} is too long."
					return -1
				end
				
				if @transactions[j].to_addr.length > 6
					puts "Line #{@blocks[i].block_number}: the to address #{transactions[j].to_addr} is too long."
					return -1
				end
				
				if !@transactions[j].from_addr.match(/[[:alpha:]]/)
					puts "Line #{@blocks[i].block_number}: the from address #{transactions[j].from_addr} contains an invalid character."
					return -1
				end
				
				if !@transactions[j].to_addr.match(/[[:alpha:]]/)
					puts "Line #{@blocks[i].block_number}: the to address #{transactions[j].to_addr} contains an invalid character."
					return -1
				end
				
				if i == @blocks.count - 1
					if j == transactions_semicolon_split.count - 1
						if !@transactions[j].from_addr.strip.eql? "SYSTEM"
							puts "Line #{@blocks[i].block_number}: the last transaction in #{transactions[j].transaction_string} should be from SYSTEM."
							return -1
						end
						if @transactions[j].num_billcoins_sent != 100
							puts "Line #{@blocks[i].block_number}: the last transaction in #{transactions[j].transaction_string} SYSTEM should have sent 100 billcoins."
							return -1
						end
					end
				end
				
				j += 1
			end
			i += 1
		end
		return 1
	end

	def self.check_balances(i)
		@balance.each do |key, value|
			if value < 0
				puts "Line #{@blocks[i].block_number}: Invalid block, address #{key} has #{value} billcoins!"
				return -1
			end
		end
		return 1
	end

	def self.compare_timestamps
		if @blocks.count > 1
			i = 1
			while i < @blocks.count
				timestamp_one_string_partitions = @blocks[i-1].timestamp.split('.')
				timestamp_two_string_partitions = @blocks[i].timestamp.split('.')

				timestamp_one_partitions = timestamp_one_string_partitions.map(&:to_i)
				timestamp_two_partitions = timestamp_two_string_partitions.map(&:to_i)

				if timestamp_two_partitions[0] < timestamp_one_partitions[0]
					puts "Line #{@blocks[i].block_number}: Previous timestamp #{@blocks[i-1].timestamp} >= new timestamp #{@blocks[i].timestamp}"
					return -1
				end

				if timestamp_two_partitions[0] == timestamp_one_partitions[0]
					if timestamp_two_partitions[1] <= timestamp_one_partitions[1]
						puts "Line #{@blocks[i].block_number}: Previous timestamp #{@blocks[i-1].timestamp} >= new timestamp #{@blocks[i].timestamp}"
						return -1
					end
				end
				i += 1
			end
		end
		return 1
	end

	def self.check_block_number
		i = 0
		while i < @blocks.count
			if i != @blocks[i].block_number
				puts "Invalid block number #{@blocks[i].block_number}, should be #{i}"
				return -1
			end
			i += 1
		end
		return 1
	end

	def self.compare_hashes
		if @blocks.count > 1
			i = 0
			while i < @blocks.count
				correct_hash = @blocks[i].hash_block
				if !correct_hash.strip.eql? @blocks[i].current_hash.strip
					puts "Line #{@blocks[i].block_number}: String '#{@blockchain[i].strip}' hash set to #{@blocks[i].current_hash.strip}, should be #{correct_hash}"
					return -1
				end
				i += 1
			end
		end
		return 1
	end

	def self.check_previous_hashes
		if @blocks.count > 1
			i = 1
			while i < @blocks.count
				if !@blocks[i].previous_hash.strip.eql? @blocks[i-1].current_hash.strip
					puts "Line #{@blocks[i].block_number}: Previous hash was #{@blocks[i].previous_hash.strip}, should be #{@blocks[i-1].current_hash.strip}"
					return -1
				end
				i += 1
			end
			return 1
			puts "Hello."
		end
	end

	def self.check_zero_previous_hash(block)
		if !block.previous_hash.eql? "0"
			puts "Line #{block.block_number}: Previous hash was #{block.previous_hash.strip}, should be 0"
			return -1
		end
		return 1
	end

	def self.print_outcome
		@balance.each do |key, value|
			puts "#{key}: #{value} billcoins"
		end
	end

	def self.run
		Verifier.check_empty_file(argscheck)
		if check_transactions == -1
			puts "BLOCKCHAIN INVALID"
			exit 0
		end
		if check_previous_hashes == -1
			puts "BLOCKCHAIN INVALID"
			exit 0
		end
		if check_block_number == -1
			puts "BLOCKCHAIN INVALID"
			exit 0
		end
		if compare_timestamps == -1
			puts "BLOCKCHAIN INVALID"
			exit 0
		end
		if compare_hashes == -1
			puts "BLOCKCHAIN INVALID"
			exit 0
		end

		if check_zero_previous_hash(@blocks[0]) == -1
			puts "BLOCKCHAIN INVALID"
			exit 0
		end
		print_outcome
	end
end
#Flamegraph.generate('flamegrapher.html') do
	Verifier.run
#end

