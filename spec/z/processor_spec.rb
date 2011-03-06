require_relative '../../lib/gruesome/z/instruction'
require_relative '../../lib/gruesome/z/operand_type'
require_relative '../../lib/gruesome/z/opcode'
require_relative '../../lib/gruesome/z/memory'
require_relative '../../lib/gruesome/z/processor'

# Note: The Z-Machine implementation, upon execution, 
# already moves the PC to the next instruction

describe Gruesome::Z::Processor do
	describe "#execute" do
		before(:each) do
			zork = File.open('test/zork1.z3', 'r')
			@zork_memory = Gruesome::Z::Memory.new(zork.read(zork.size))
			@processor = Gruesome::Z::Processor.new(@zork_memory)
			@zork_memory.program_counter = 12345
		end

		describe "Branch Instruction" do
			after(:each) do
			end

			describe "jg" do
				it "should branch if the first operand is greater than the second" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JG,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [(-12345+65536), (-23456+65536)], nil, 2000, true, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(12345+2000-2)
				end

				it "should not branch if the first operand is not greater than the second" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JG,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [12345, 12345], nil, 2000, true, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(12345)
				end

				it "should not branch if the first operand is greater than the second and condition is negated" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JG,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [(-12345+65536), (-23456+65536)], nil, 2000, false, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(12345)
				end

				it "should branch if the first operand is not greater than the second and condition is negated" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JG,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [(-12345+65536), 12345], nil, 2000, false, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(12345+2000-2)
				end
			end

			describe "je" do
				it "should branch if the first operand is equal to one of four operands" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JE,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE, 
														 Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [(-12345+65536), 123, 1234, (-12345+65536)], nil, 2000, true, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(12345+2000-2)
				end

				it "should not branch if the first operand is not equal to one of four operands" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JE,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE, 
														 Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [(-123+65536), 123, 1234, (12345+65536)], nil, 2000, true, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(12345)
				end

				it "should not branch if the first operand is equal to one of four operands and condition is negated" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JE,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE, 
														 Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [(-12345+65536), 1234, 123, (-12345+65536)], nil, 2000, false, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(12345)
				end

				it "should branch if the first operand is not equal to one of four operands and condition is negated" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JE,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE, 
														 Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [(-123+65536), 123, 12345, 12344], nil, 2000, false, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(12345+2000-2)
				end

				it "should branch if the first operand is equal to one of three operands" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JE,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [(-12345+65536), 123, (-12345+65536)], nil, 2000, true, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(12345+2000-2)
				end

				it "should not branch if the first operand is not equal to one of three operands" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JE,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [(-123+65536), 123, (12345+65536)], nil, 2000, true, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(12345)
				end

				it "should not branch if the first operand is equal to one of three operands and condition is negated" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JE,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [(-12345+65536), 123, (-12345+65536)], nil, 2000, false, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(12345)
				end

				it "should branch if the first operand is not equal to one of three operands and condition is negated" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JE,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [(-123+65536), 12345, 12344], nil, 2000, false, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(12345+2000-2)
				end

				it "should branch if the first operand is equal to the second of two operands" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JE,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [(-12345+65536), (-12345+65536)], nil, 2000, true, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(12345+2000-2)
				end

				it "should not branch if the first operand is not equal to the second of two operands" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JE,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [(-123+65536), (12345+65536)], nil, 2000, true, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(12345)
				end

				it "should not branch if the first operand is equal to the second of two operands and condition is negated" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JE,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [(-12345+65536), (-12345+65536)], nil, 2000, false, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(12345)
				end

				it "should branch if the first operand is not equal to the second of two operands and condition is negated" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JE,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [(-123+65536), (12345+65536)], nil, 2000, false, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(12345+2000-2)
				end
			end

			describe "jl" do
				it "should branch if the first operand is less than the second" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JL,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [(-23456+65536), (-12345+65536)], nil, 2000, true, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(12345+2000-2)
				end

				it "should not branch if the first operand is not less than the second" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JL,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [12345, 12345], nil, 2000, true, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(12345)
				end

				it "should not branch if the first operand is less than the second and condition is negated" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JL,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [(-23456+65536), (-12345+65536)], nil, 2000, false, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(12345)
				end

				it "should branch if the first operand is not less than the second and condition is negated" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JL,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [12345, (-12345+65536)], nil, 2000, false, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(12345+2000-2)
				end
			end

			describe "jz" do
				it "should branch if the first operand is zero" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JZ,
													 [Gruesome::Z::OperandType::LARGE],
													 [0], nil, 2000, true, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(12345+2000-2)
				end

				it "should not branch if the first operand is not zero" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JZ,
													 [Gruesome::Z::OperandType::LARGE],
													 [12345], nil, 2000, true, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(12345)
				end

				it "should not branch if the first operand is zero and condition is negated" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JZ,
													 [Gruesome::Z::OperandType::LARGE],
													 [0], nil, 2000, false, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(12345)
				end

				it "should branch if the first operand is not zero and condition is negated" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JZ,
													 [Gruesome::Z::OperandType::LARGE],
													 [12345], nil, 2000, false, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(12345+2000-2)
				end
			end

			describe "jump" do
				it "should update the program counter via a signed offset" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JUMP,
													 [Gruesome::Z::OperandType::LARGE],
													 [(-12343+65536)], nil, nil, nil, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(0)
				end
			end
		end

		describe "Store Instruction" do
			after(:each) do
				@zork_memory.program_counter.should eql(12345)
			end
		end

		describe "Output Instruction" do
			before(:each) do
				# We take over stdout so that we can see what it prints
				@stdout = $stdout
				$stdout = StringIO.new
			end

			after(:each) do
				$stdout = @stdout

				# The program counter should not be changed
				@zork_memory.program_counter.should eql(12345)
			end

			describe "print" do
				it "should print out the string given as an operand to stdout" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::PRINT,
													 [Gruesome::Z::OperandType::STRING],
													 ["Hello World"], nil, nil, nil, 0)

					@processor.execute(i)
					$stdout.string.should eql("Hello World")
				end
			end

			describe "print_addr" do
				it "should print out the string located at the byte address given by the operand" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::PRINT_ADDR,
													 [Gruesome::Z::OperandType::LARGE],
													 [0x4291], nil, nil, nil, 0)

					@processor.execute(i)
					$stdout.string.should eql("grue")
				end
			end

			describe "print_char" do
				it "should print out the Z-character given by the operand" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::PRINT_CHAR,
													 [Gruesome::Z::OperandType::LARGE],
													 [0x0c], nil, nil, nil, 0)

					@processor.execute(i)
					$stdout.string.should eql("g")
				end
			end

		end

		describe "Instruction" do
			after(:each) do
				# The program counter should not be changed
				@zork_memory.program_counter.should eql(12345)
			end

			describe "not" do
				it "should perform a logical negation on the operand and assign to the appropriate variable" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::NOT,
													 [Gruesome::Z::OperandType::LARGE],
													 [12345], 128, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readv(128).should eql((~12345)+65536)
				end
			end

			describe "and" do
				it "should bitwise and two signed shorts together and assign to the appropriate variable" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::AND,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [-12345+65536, 12344], 128, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readv(128).should eql((-12345 & 12344) & 65535)
				end
			end

			describe "or" do
				it "should bitwise or two signed shorts together and assign to the appropriate variable" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::OR,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [-12345+65536, 12344], 128, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readv(128).should eql((-12345 | 12344) & 65535)
				end
			end

			describe "add" do
				it "should add two signed shorts together and assign to the appropriate variable" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::ADD,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [-12345+65536, 12344], 128, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readv(128).should eql(-1+65536)
				end
			end

			describe "sub" do
				it "should subtract two signed shorts together and assign to the appropriate variable" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::SUB,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [-12345+65536, 12344], 128, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readv(128).should eql(-24689+65536)
				end
			end

			describe "mul" do
				it "should multiply two signed shorts together and assign to the appropriate variable" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::MUL,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [-12345+65536, 12344], 128, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readv(128).should eql(50056)
				end
			end

			describe "div" do
				it "should divide one negative and one positive short together and assign to the appropriate variable" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::DIV,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [-11+65536, 2], 128, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readv(128).should eql(-5+65536)
				end

				it "should divide one positive and one negative short together and assign to the appropriate variable" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::DIV,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [11, -2+65536], 128, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readv(128).should eql(-5+65536)
				end

				it "should divide two positive shorts together and assign to the appropriate variable" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::DIV,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [11, 2], 128, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readv(128).should eql(5)
				end

				it "should divide two negative shorts together and assign to the appropriate variable" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::DIV,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [-11+65536, -2+65536], 128, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readv(128).should eql(5)
				end
			end

			describe "mul" do
				it "should modulo one negative and one positive short together and assign to the appropriate variable" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::MOD,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [-13+65536, 5], 128, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readv(128).should eql(-3+65536)
				end

				it "should modulo one positive and one negative short together and assign to the appropriate variable" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::MOD,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [13, -5+65536], 128, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readv(128).should eql(3)
				end

				it "should modulo two positive shorts together and assign to the appropriate variable" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::MOD,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [13, 5], 128, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readv(128).should eql(3)
				end

				it "should modulo two negative shorts together and assign to the appropriate variable" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::MOD,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [-13+65536, -5+65536], 128, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readv(128).should eql(-3+65536)
				end
			end

			describe "store" do
				it "should store the value into the variable referenced by the operand" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::STORE,
													 [Gruesome::Z::OperandType::VARIABLE, Gruesome::Z::OperandType::LARGE],
													 [128, -13+65536], nil, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readv(128).should eql(-13+65536)
				end
			end

			describe "store" do
				it "should store the value into the variable referenced by the operand" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::STORE,
													 [Gruesome::Z::OperandType::VARIABLE, Gruesome::Z::OperandType::LARGE],
													 [128, -13+65536], nil, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readv(128).should eql(-13+65536)
				end
			end

			describe "storeb" do
				it "should store the byte given into the byte address given by the operands providing base and offset" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::STOREB,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [2000, 100, 123], nil, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readb(2000+100).should eql(123)
				end
			end

			describe "storew" do
				it "should store the word given into the byte address given by the operands providing base and offset" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::STOREW,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [2000, 100, 12345], nil, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readw(2000+100).should eql(12345)
				end
			end
		end
	end
end
