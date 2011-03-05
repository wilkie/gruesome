require_relative '../../lib/gruesome/z/instruction'
require_relative '../../lib/gruesome/z/operand_type'
require_relative '../../lib/gruesome/z/opcode'
require_relative '../../lib/gruesome/z/memory'
require_relative '../../lib/gruesome/z/processor'

describe Gruesome::Z::Memory do
	before(:each) do
		zork = File.open('test/zork1.z3', 'r')
		@zork_memory = Gruesome::Z::Memory.new(zork.read(zork.size))
		@processor = Gruesome::Z::Processor.new(@zork_memory)
		@stdout = $stdout
	end

	after(:each) do
		$stdout = @stdout
	end

	describe "#execute" do
		describe "jump" do
			it "should update the program counter via a signed offset" do
				@zork_memory.program_counter = 12345
				i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JUMP,
						[Gruesome::Z::OperandType::LARGE],
						[(-12345+65536)], nil, nil, nil, 0)

				@processor.execute(i)
				@zork_memory.program_counter.should eql(0)
			end
		end

		describe "print" do
			it "should print out the string given as an operand to stdout" do
				@zork_memory.program_counter = 12345
				i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::PRINT,
						 [Gruesome::Z::OperandType::STRING],
						 ["Hello World"], nil, nil, nil, 0)

				$stdout = StringIO.new
				@processor.execute(i)
				$stdout.string.should eql("Hello World")

				@zork_memory.program_counter.should eql(12345)
			end
		end

		describe "print_addr" do
			it "should print out the string located at the byte address given by the operand" do
				@zork_memory.program_counter = 12345
				i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::PRINT_ADDR,
							[Gruesome::Z::OperandType::LARGE],
							[0x4291], nil, nil, nil, 0)

				$stdout = StringIO.new
				@processor.execute(i)
				$stdout.string.should eql("grue")

				@zork_memory.program_counter.should eql(12345)
			end
		end

		describe "print_char" do
			it "should print out the Z-character given by the operand" do
				@zork_memory.program_counter = 12345
				i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::PRINT_CHAR,
												 [Gruesome::Z::OperandType::LARGE],
												 [0x0c], nil, nil, nil, 0)

				$stdout = StringIO.new
				@processor.execute(i)
				$stdout.string.should eql("g")

				@zork_memory.program_counter.should eql(12345)
			end
		end

		describe "not" do
			it "should perform a logical negation on the operand and assign to the appropriate variable" do
				@zork_memory.program_counter = 12345
				i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::NOT,
												 [Gruesome::Z::OperandType::LARGE],
												 [12345], 128, nil, nil, 0)

				@processor.execute(i)

				@zork_memory.readv(128).should eql((~12345)+65536)
				@zork_memory.program_counter.should eql(12345)
			end
		end

		describe "add" do
			it "should add two signed shorts together and assign to the appropriate variable" do
				@zork_memory.program_counter = 12345
				i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::ADD,
												 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
												 [-12345+65536, 12344], 128, nil, nil, 0)

				@processor.execute(i)

				@zork_memory.readv(128).should eql(-1+65536)
				@zork_memory.program_counter.should eql(12345)
			end
		end

		describe "sub" do
			it "should subtract two signed shorts together and assign to the appropriate variable" do
				@zork_memory.program_counter = 12345
				i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::SUB,
												 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
												 [-12345+65536, 12344], 128, nil, nil, 0)

				@processor.execute(i)

				@zork_memory.readv(128).should eql(-24689+65536)
				@zork_memory.program_counter.should eql(12345)
			end
		end

		describe "mul" do
			it "should multiply two signed shorts together and assign to the appropriate variable" do
				@zork_memory.program_counter = 12345
				i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::MUL,
												 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
												 [-12345+65536, 12344], 128, nil, nil, 0)

				@processor.execute(i)

				@zork_memory.readv(128).should eql(50056)
				@zork_memory.program_counter.should eql(12345)
			end
		end

		describe "div" do
			it "should divide one negative and one positive short together and assign to the appropriate variable" do
				@zork_memory.program_counter = 12345
				i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::DIV,
												 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
												 [-11+65536, 2], 128, nil, nil, 0)

				@processor.execute(i)

				@zork_memory.readv(128).should eql(-5+65536)
				@zork_memory.program_counter.should eql(12345)
			end

			it "should divide one positive and one negative short together and assign to the appropriate variable" do
				@zork_memory.program_counter = 12345
				i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::DIV,
												 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
												 [11, -2+65536], 128, nil, nil, 0)

				@processor.execute(i)

				@zork_memory.readv(128).should eql(-5+65536)
				@zork_memory.program_counter.should eql(12345)
			end

			it "should divide two positive shorts together and assign to the appropriate variable" do
				@zork_memory.program_counter = 12345
				i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::DIV,
												 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
												 [11, 2], 128, nil, nil, 0)

				@processor.execute(i)

				@zork_memory.readv(128).should eql(5)
				@zork_memory.program_counter.should eql(12345)
			end

			it "should divide two negative shorts together and assign to the appropriate variable" do
				@zork_memory.program_counter = 12345
				i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::DIV,
												 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
												 [-11+65536, -2+65536], 128, nil, nil, 0)

				@processor.execute(i)

				@zork_memory.readv(128).should eql(5)
				@zork_memory.program_counter.should eql(12345)
			end
		end

		describe "mul" do
			it "should modulo one negative and one positive short together and assign to the appropriate variable" do
				@zork_memory.program_counter = 12345
				i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::MOD,
												 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
												 [-13+65536, 5], 128, nil, nil, 0)

				@processor.execute(i)

				@zork_memory.readv(128).should eql(-3+65536)
				@zork_memory.program_counter.should eql(12345)
			end

			it "should modulo one positive and one negative short together and assign to the appropriate variable" do
				@zork_memory.program_counter = 12345
				i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::MOD,
												 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
												 [13, -5+65536], 128, nil, nil, 0)

				@processor.execute(i)

				@zork_memory.readv(128).should eql(3)
				@zork_memory.program_counter.should eql(12345)
			end

			it "should modulo two positive shorts together and assign to the appropriate variable" do
				@zork_memory.program_counter = 12345
				i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::MOD,
												 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
												 [13, 5], 128, nil, nil, 0)

				@processor.execute(i)

				@zork_memory.readv(128).should eql(3)
				@zork_memory.program_counter.should eql(12345)
			end

			it "should modulo two negative shorts together and assign to the appropriate variable" do
				@zork_memory.program_counter = 12345
				i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::MOD,
												 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
												 [-13+65536, -5+65536], 128, nil, nil, 0)

				@processor.execute(i)

				@zork_memory.readv(128).should eql(-3+65536)
				@zork_memory.program_counter.should eql(12345)
			end
		end
	end
end
