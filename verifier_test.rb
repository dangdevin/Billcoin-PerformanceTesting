## Devin Dang (ded57)

require 'minitest/autorun'

require_relative 'block'
require_relative 'transaction'
require_relative 'verifier'

class VerifierTest < Minitest::Test
	def test_transaction_is_transaction
		transaction = Transaction::new "Devin", "Friend", 10
		assert transaction.is_a?(Transaction)
	end

	def test_block_is_block
		block = Block::new 0, "0", "SYSTEM>Henry(100)", "1518892051.737141000", "1c12"
		assert block.is_a?(Block)
	end

	def test_invalid_previous_hash
		@v = Verifier::new
		first_transaction = ["0|1|SYSTEM>Henry(100)|1518892051.737141000|1c12"]
		@v.blockchain = first_transaction
		@v.blocks = Verifier.partition(@v.blockchain)
		a = Verifier.check_zero_previous_hash(@v.blocks[0])
		assert_equal a, -1
	end

	def test_valid_previous_hash
		@v = Verifier::new
		first_transaction = ["0|0|SYSTEM>Henry(100)|1518892051.737141000|1c12"]
		@v.blockchain = first_transaction
		@v.blocks = Verifier.partition(@v.blockchain)
		a = Verifier.check_zero_previous_hash(@v.blocks[0])
		assert_equal a, 1
	end

end