## Devin Dang (ded57)

require 'minitest/autorun'

require_relative 'block'
require_relative 'transaction'
require_relative 'verifier'

class VerifierTest < Minitest::Test
	def setup
		@v = Verifier::new
	end

	# This tests that the Transaction class is working by testing a Transaction is a Transaction.
	def test_transaction_is_transaction
		transaction = Transaction::new "Devin", "Friend", 10
		assert transaction.is_a?(Transaction)
	end

	# This tests that the Block class is working by testing a Block is a Block.
	def test_block_is_block
		block = Block::new 0, "0", "SYSTEM>Henry(100)", "1518892051.737141000", "1c12"
		assert block.is_a?(Block)
	end

	# This tests that the From Address is a valid length. If it returns 1, it is valid. If it returns -1, it is invalid.
	def test_from_addr_length_valid
		block = Block::new 0, "0", "SYSTEM>Henry(100)", "1518892051.737141000", "1c12"
		transaction = Transaction::new "SYSTEM", "Henry", 100
		assert_equal 1, Verifier.check_from_addr_length(block, transaction)
	end

	# This tests that the From Address is an invalid length. If it returns 1, it is valid. If it returns -1, it is invalid.
	def test_from_addr_length_invalid
		block = Block::new 0, "0", "SYSTEMS>Henry(100)", "1518892051.737141000", "1c12"
		transaction = Transaction::new "SYSTEMS", "Henry", 100
		assert_equal -1, Verifier.check_from_addr_length(block, transaction)
	end

	# This tests that the To Address is a valid length. If it returns 1, it is valid. If it returns -1, it is invalid.
	def test_to_addr_length_valid
		block = Block::new 0, "0", "SYSTEM>Devin(100)", "1518892051.737141000", "1c12"
		transaction = Transaction::new "SYSTEM", "Devin", 100
		assert_equal 1, Verifier.check_to_addr_length(block, transaction)
	end

	# This tests that the To Address is an invalid length. If it returns 1, it is valid. If it returns -1, it is invalid.
	def test_to_addr_length_invalid
		block = Block::new 0, "0", "SYSTEM>DevinDang(100)", "1518892051.737141000", "1c12"
		transaction = Transaction::new "SYSTEM", "DevinDang", 100
		assert_equal -1, Verifier.check_to_addr_length(block, transaction)
	end

	# This tests that the From Address contains invalid characters. If it returns 1, it is valid. If it returns -1, it is invalid.
	def test_from_addr_char_invalid
		block = Block::new 0, "0", "1234>Devin(100)", "1518892051.737141000", "1c12"
		transaction = Transaction::new "1234", "Devin", 100
		assert_equal -1, Verifier.check_from_addr_invalid_char(block, transaction)
	end

	# This tests that the To Address contains invalid characters. If it returns 1, it is valid. If it returns -1, it is invalid.
	def test_from_addr_char_invalid
		block = Block::new 0, "0", "SYSTEM>H 2 P(100)", "1518892051.737141000", "1c12"
		transaction = Transaction::new "SYSTEM", "H 2 P", 100
		assert_equal -1, Verifier.check_to_addr_invalid_char(block, transaction)
	end

	# This tests that the timestamp (seconds) did not increment. If it returns 1, it is valid. If it returns -1, it is invalid.
	def test_timestamp_second_invalid
		block1 = Block::new 7, "949", "Louis>Louis(1):George>Edward(15):Sheba>Wu(1):Henry>James(12):Amina>Pakal(22):SYSTEM>Kublai(100)", "1518892053.799497000", "f944"
		block2 = Block::new 8, "f944", "SYSTEM>Tang(100)", "1518892051.812065000", "775a"
		assert_equal -1, Verifier.compare_timestamps(block1, block2)
	end

	# This tests that the timestamp (seconds) did increment correctly. If it returns 1, it is valid. If it returns -1, it is invalid.
	def test_timestamp_second_valid
		block1 = Block::new 6, "d072", "Wu>Edward(16):SYSTEM>Amina(100)", "1518892051.793695000", "949"
		block2 = Block::new 7, "949", "Louis>Louis(1):George>Edward(15):Sheba>Wu(1):Henry>James(12):Amina>Pakal(22):SYSTEM>Kublai(100)", "1518892053.799497000", "f944"
		assert_equal 1, Verifier.compare_timestamps(block1, block2)
	end

	# This tests that the timestamp (nanoseconds) did not increment. If it returns 1, it is valid. If it returns -1, it is invalid.
	def test_timestamp_nanosecond_invalid
		block1 = Block::new 6, "d072", "Wu>Edward(16):SYSTEM>Amina(100)", "1518892051.793695000", "949"
		block2 = Block::new 7, "949", "Louis>Louis(1):George>Edward(15):Sheba>Wu(1):Henry>James(12):Amina>Pakal(22):SYSTEM>Kublai(100)", "1518892051.199497000", "1e5c"
		assert_equal -1, Verifier.compare_timestamps(block1, block2)
	end

	# This tests that the timestamp (nanoseconds) did increment correctly. If it returns 1, it is valid. If it returns -1, it is invalid.
	def test_timestamp_nanosecond_valid
		block1 = Block::new 5, "97df", "Henry>Edward(23):Rana>Alfred(1):James>Rana(1):SYSTEM>George(100)", "1518892051.783448000", "d072"
		block2 = Block::new 6, "d072", "Wu>Edward(16):SYSTEM>Amina(100)", "1518892051.793695000", "949"
		assert_equal 1, Verifier.compare_timestamps(block1, block2)
	end

	# This tests that the current hash of the block is correct. If it returns 1, it is valid. If it returns -1, it is invalid.
	def test_compare_hashes_valid
		block = Block::new 5, "97df", "Henry>Edward(23):Rana>Alfred(1):James>Rana(1):SYSTEM>George(100)", "1518892051.783448000", "d072"
		assert_equal 1, Verifier.compare_hashes(block)
	end

	# This tests that the current hash of the block is incorrect. If it returns 1, it is valid. If it returns -1, it is invalid.
	def test_compare_hashes_invalid
		block = Block::new 5, "97df", "Henry>Edward(23):Rana>Alfred(1):James>Rana(1):SYSTEM>George(100)", "1518892051.783448000", "-1"
		assert_equal -1, Verifier.compare_hashes(block)
	end

	# This tests that the previous hash of the block is correct. If it returns 1, it is valid. If it returns -1, it is invalid.
	def test_previous_hashes_valid
		block1 = Block::new 5, "97df", "Henry>Edward(23):Rana>Alfred(1):James>Rana(1):SYSTEM>George(100)", "1518892051.783448000", "d072"
		block2 = Block::new 6, "d072", "Wu>Edward(16):SYSTEM>Amina(100)", "1518892051.793695000", "949"
		assert_equal 1, Verifier.check_previous_hashes(block1, block2)
	end

	# This tests that the previous hash of the block is incorrect. If it returns 1, it is valid. If it returns -1, it is invalid.
	def test_previous_hashes_invalid
		block1 = Block::new 5, "97df", "Henry>Edward(23):Rana>Alfred(1):James>Rana(1):SYSTEM>George(100)", "1518892051.783448000", "d072"
		block2 = Block::new 6, "1", "Wu>Edward(16):SYSTEM>Amina(100)", "1518892051.793695000", "949"
		assert_equal -1, Verifier.check_previous_hashes(block1, block2)
	end

	# This tests that for the first line the previous line will be 0. If it returns 1, it is valid. If it returns -1, it is invalid.
	def test_zero_previous_hash_valid
		block = Block::new 0, "0", "SYSTEM>Henry(100)", "1518892051.737141000", "1c12"
		assert_equal 1, Verifier.check_zero_previous_hash(block)
	end

	# This tests that for the first line the previous line will be 0. This checks what happens when a negative number is hashed. If it returns 1, it is valid. If it returns -1, it is invalid.
	def test_zero_previous_hash_negative
		block = Block::new 0, "-5", "SYSTEM>Devin(100)", "1518892051.737141000", "1c12"
		assert_equal -1, Verifier.check_zero_previous_hash(block)
	end

	# This tests that for the first line the previous line will be 0. This checks what happens when an invalind number is entered. If it returns 1, it is valid. If it returns -1, it is invalid.
	def test_zero_previous_hash_invalid
		block = Block::new 0, "2", "SYSTEM>Devin(100)", "1518892051.737141000", "1c12"
		assert_equal -1, Verifier.check_zero_previous_hash(block)
	end

end