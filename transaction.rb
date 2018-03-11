## Devin Dang (ded57)

class Transaction
	attr_accessor :from_addr, :to_addr, :num_billcoins_sent, :transaction_string

	def initialize(from_addr, to_addr, num_billcoins_sent)
		@from_addr = from_addr
		@to_addr = to_addr
		@num_billcoins_sent = num_billcoins_sent
		@transaction_string = "#{from_addr}>#{to_addr}(#{num_billcoins_sent})"
	end
end