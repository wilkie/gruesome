require_relative '../../lib/gruesome/z/instruction'
require_relative '../../lib/gruesome/z/operand_type'
require_relative '../../lib/gruesome/z/opcode'
require_relative '../../lib/gruesome/z/memory'
require_relative '../../lib/gruesome/z/processor'
require_relative '../../lib/gruesome/z/abbreviation_table'
require_relative '../../lib/gruesome/z/object_table'

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

		# Note: The decoder already gets the exact branch address
		# which is why we don't specify an offset here
		describe "Branch Instruction" do
			after(:each) do
			end

			# not necessarily a branch
			describe "call" do
				it "should branch to the routine with two local variables given as first operand and store result in destination variable" do
					# set up a routine at address $2000
					@zork_memory.force_writeb(0x2000, 2)
					@zork_memory.force_writew(0x2001, 0)
					@zork_memory.force_writew(0x2003, 0)

					# The packed address is 0x2000 / 2
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::CALL,
													 [Gruesome::Z::OperandType::LARGE],
													 [0x1000], 128, nil, nil, 0)
					@processor.execute(i)
					@zork_memory.program_counter.should eql(0x2005)
				end

				it "should simply set the destination variable to false when routine address is 0" do
					@zork_memory.writev(128, 12345)
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::CALL,
													 [Gruesome::Z::OperandType::LARGE],
													 [0], 128, nil, nil, 0)
					@processor.execute(i)
					@zork_memory.readv(128).should eql(0)
					@zork_memory.program_counter.should eql(12345)
				end
				
				it "should create a stack with only the return address when no arguments or local variables are used" do
					# set up a routine at address $2000 with no locals
					@zork_memory.force_writeb(0x2000, 0)

					# The packed address is 0x2000 / 2
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::CALL,
													 [Gruesome::Z::OperandType::LARGE],
													 [0x1000], 128, nil, nil, 0)
					@processor.execute(i)
					@zork_memory.program_counter.should eql(0x2001)
					@zork_memory.readv(0).should eql(12345)
				end
	
				it "should create a stack with only the return address and all arguments copied to locals" do
					# set up a routine at address $2000 with two locals
					@zork_memory.force_writeb(0x2000, 2)
					@zork_memory.force_writew(0x2001, 345)
					@zork_memory.force_writew(0x2003, 456)

					# The packed address is 0x2000 / 2
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::CALL,
													 [Gruesome::Z::OperandType::LARGE],
													 [0x1000], 128, nil, nil, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(0x2005)
					@zork_memory.readv(0).should eql(456)
					@zork_memory.readv(0).should eql(345)
					@zork_memory.readv(0).should eql(12345)
				end
			end

			# not necessarily a branch
			describe "call_1n" do
				it "should branch to the routine with two local variables given as first operand" do
					# set up a routine at address $2000
					@zork_memory.force_writeb(0x2000, 2)
					@zork_memory.force_writew(0x2001, 0)
					@zork_memory.force_writew(0x2003, 0)

					# The packed address is 0x2000 / 2
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::CALL_1N,
													 [Gruesome::Z::OperandType::LARGE],
													 [0x1000], nil, nil, nil, 0)
					@processor.execute(i)
					@zork_memory.program_counter.should eql(0x2005)
				end

				it "should simply do nothing when routine address is 0" do
					@zork_memory.writev(128, 12345)
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::CALL_1N,
													 [Gruesome::Z::OperandType::LARGE],
													 [0], nil, nil, nil, 0)
					@processor.execute(i)
					@zork_memory.program_counter.should eql(12345)
				end
				
				it "should create a stack with only the return address when no arguments or local variables are used" do
					# set up a routine at address $2000 with no locals
					@zork_memory.force_writeb(0x2000, 0)

					# The packed address is 0x2000 / 2
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::CALL_1N,
													 [Gruesome::Z::OperandType::LARGE],
													 [0x1000], nil, nil, nil, 0)
					@processor.execute(i)
					@zork_memory.program_counter.should eql(0x2001)
					@zork_memory.readv(0).should eql(12345)
				end
			end

			# not necessarily a branch
			describe "ret" do
				it "should return to the routine that called it" do
					# set up a routine at address $2000
					@zork_memory.force_writeb(0x2000, 2)
					@zork_memory.force_writew(0x2001, 0)
					@zork_memory.force_writew(0x2003, 0)

					# The packed address is 0x2000 / 2
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::CALL,
													 [Gruesome::Z::OperandType::LARGE],
													 [0x1000], 128, nil, nil, 0)

					@processor.execute(i)

					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::RET,
													 [Gruesome::Z::OperandType::LARGE],
													 [123], nil, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.program_counter.should eql(12345)
				end

				it "should set the variable indicated by the call with the return value as an immediate" do
					# set up a routine at address $2000
					@zork_memory.force_writeb(0x2000, 2)
					@zork_memory.force_writew(0x2001, 0)
					@zork_memory.force_writew(0x2003, 0)

					# The packed address is 0x2000 / 2
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::CALL,
													 [Gruesome::Z::OperandType::LARGE],
													 [0x1000], 128, nil, nil, 0)

					@processor.execute(i)

					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::RET,
													 [Gruesome::Z::OperandType::LARGE],
													 [123], nil, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readv(128).should eql(123)
				end

				it "should be able to push the result (given as an immediate) to the stack if the call requests variable 0" do
					# set up a routine at address $2000
					@zork_memory.force_writeb(0x2000, 2)
					@zork_memory.force_writew(0x2001, 0)
					@zork_memory.force_writew(0x2003, 0)

					# The packed address is 0x2000 / 2
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::CALL,
													 [Gruesome::Z::OperandType::LARGE],
													 [0x1000], 0, nil, nil, 0)

					@processor.execute(i)

					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::RET,
													 [Gruesome::Z::OperandType::LARGE],
													 [123], nil, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readv(0).should eql(123)
				end
			end

			# not necessarily a branch
			describe "ret_popped" do
				it "should return to the routine that called it" do
					# set up a routine at address $2000
					@zork_memory.force_writeb(0x2000, 2)
					@zork_memory.force_writew(0x2001, 0)
					@zork_memory.force_writew(0x2003, 0)

					# The packed address is 0x2000 / 2
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::CALL,
													 [Gruesome::Z::OperandType::LARGE],
													 [0x1000], 128, nil, nil, 0)

					@processor.execute(i)

					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::RET_POPPED,
													 [Gruesome::Z::OperandType::LARGE],
													 [123], nil, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.program_counter.should eql(12345)
				end
				
				it "should be able to push top of callee stack to the stack of the caller" do
					# set up a routine at address $2000
					@zork_memory.force_writeb(0x2000, 2)
					@zork_memory.force_writew(0x2001, 0)
					@zork_memory.force_writew(0x2003, 0)
					@zork_memory.writev(0, 11111)

					# The packed address is 0x2000 / 2
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::CALL,
													 [Gruesome::Z::OperandType::LARGE],
													 [0x1000], 0, nil, nil, 0)

					@processor.execute(i)
					@zork_memory.writev(0, 22222)
					@zork_memory.writev(0, 23456)

					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::RET_POPPED,
													 [Gruesome::Z::OperandType::LARGE],
													 [123], nil, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readv(0).should eql(23456)
					@zork_memory.readv(0).should eql(11111)
				end
			end

			# not necessarily a branch
			describe "rfalse" do
				it "should set the variable indicated by the call with 0" do
					# set up a routine at address $2000
					@zork_memory.force_writeb(0x2000, 2)
					@zork_memory.force_writew(0x2001, 0)
					@zork_memory.force_writew(0x2003, 0)

					# The packed address is 0x2000 / 2
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::CALL,
													 [Gruesome::Z::OperandType::LARGE],
													 [0x1000], 128, nil, nil, 0)

					@processor.execute(i)

					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::RFALSE,
													 [], [], nil, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readv(128).should eql(0)
				end

				it "should push 0 to the caller's stack when indicated" do
					# set up a routine at address $2000
					@zork_memory.force_writeb(0x2000, 2)
					@zork_memory.force_writew(0x2001, 0)
					@zork_memory.force_writew(0x2003, 0)

					# The packed address is 0x2000 / 2
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::CALL,
													 [Gruesome::Z::OperandType::LARGE],
													 [0x1000], 0, nil, nil, 0)

					@processor.execute(i)

					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::RFALSE,
													 [], [], nil, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readv(0).should eql(0)
				end
			end

			# not necessarily a branch
			describe "rtrue" do
				it "should set the variable indicated by the call with 1" do
					# set up a routine at address $2000
					@zork_memory.force_writeb(0x2000, 2)
					@zork_memory.force_writew(0x2001, 0)
					@zork_memory.force_writew(0x2003, 0)

					# The packed address is 0x2000 / 2
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::CALL,
													 [Gruesome::Z::OperandType::LARGE],
													 [0x1000], 128, nil, nil, 0)

					@processor.execute(i)

					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::RTRUE,
													 [], [], nil, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readv(128).should eql(1)
				end

				it "should push 1 to the caller's stack when indicated" do
					# set up a routine at address $2000
					@zork_memory.force_writeb(0x2000, 2)
					@zork_memory.force_writew(0x2001, 0)
					@zork_memory.force_writew(0x2003, 0)

					# The packed address is 0x2000 / 2
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::CALL,
													 [Gruesome::Z::OperandType::LARGE],
													 [0x1000], 0, nil, nil, 0)

					@processor.execute(i)

					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::RTRUE,
													 [], [], nil, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readv(0).should eql(1)
				end
			end

			describe "jg" do
				it "should branch if the first operand is greater than the second" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JG,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [(-12345+65536), (-23456+65536)], nil, 2000, true, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(2000)
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
					@zork_memory.program_counter.should eql(2000)
				end
			end

			describe "je" do
				it "should branch if the first operand is equal to one of four operands" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JE,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE, 
														 Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [(-12345+65536), 123, 1234, (-12345+65536)], nil, 2000, true, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(2000)
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
					@zork_memory.program_counter.should eql(2000)
				end

				it "should branch if the first operand is equal to one of three operands" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JE,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [(-12345+65536), 123, (-12345+65536)], nil, 2000, true, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(2000)
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
					@zork_memory.program_counter.should eql(2000)
				end

				it "should branch if the first operand is equal to the second of two operands" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JE,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [(-12345+65536), (-12345+65536)], nil, 2000, true, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(2000)
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
					@zork_memory.program_counter.should eql(2000)
				end
			end

			describe "jl" do
				it "should branch if the first operand is less than the second" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JL,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [(-23456+65536), (-12345+65536)], nil, 2000, true, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(2000)
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
					@zork_memory.program_counter.should eql(2000)
				end
			end

			describe "jz" do
				it "should branch if the first operand is zero" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JZ,
													 [Gruesome::Z::OperandType::LARGE],
													 [0], nil, 2000, true, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(2000)
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
					@zork_memory.program_counter.should eql(2000)
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

			describe "piracy" do
				it "should simply act as a jump and update the program counter via a signed offset" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::PIRACY,
													 [Gruesome::Z::OperandType::LARGE],
													 [(-12343+65536)], nil, nil, nil, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(0)
				end
			end

			describe "test" do
				it "should branch if the first operand has all bits set that the second has set" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::TEST,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [0b1000110110111101, 0b1000100010001000], nil, 2000, true, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(2000)
				end

				it "should not branch if the first operand does not have all bits set that the second has set" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::TEST,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [0b1000110110111101, 0b1111100010001000], nil, 2000, true, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(12345)
				end

				it "should not branch if the first operand has all bits set that the second has set and condition is negated" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::TEST,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [0b1000110110111101, 0b1000100010001000], nil, 2000, false, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(12345)
				end

				it "should branch if the first operand does not have all bits set that the second has set and condition is negated" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::TEST,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [0b1000110110111101, 0b1111100010001000], nil, 2000, false, 0)

					@processor.execute(i)
					@zork_memory.program_counter.should eql(2000)
				end
			end
		end

		describe "Store Instruction" do
			before(:each) do
				@zork_memory.writev(128, 0)
			end

			after(:each) do
				# instructions should not affect PC
				@zork_memory.program_counter.should eql(12345)
			end

			describe "art_shift" do
				it "should shift left when places is positive" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::ART_SHIFT,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [1234, 2], 128, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readv(128).should eql(((1234 << 2) & 65535))
				end

				it "should shift right when places is positive and sign extend" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::ART_SHIFT,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [-123+65536, -2+65536], 128, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readv(128).should eql((-123 >> 2) & 65535)
				end
			end

			describe "load" do
				it "should store the value of the variable into the result" do
					@zork_memory.writev(128, 30)
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::LOAD,
													 [Gruesome::Z::OperandType::VARIABLE],
													 [128], 130, nil, nil, 0)
					@processor.execute(i)
					@zork_memory.readv(130).should eql(30)
				end
				
				it "should not pop the value off of the stack if variable %00 is used" do
					@zork_memory.writev(0, 11111)
					@zork_memory.writev(0, 12345)
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::LOAD,
													 [Gruesome::Z::OperandType::VARIABLE],
													 [0], 130, nil, nil, 0)
					@processor.execute(i)
					@zork_memory.readv(130).should eql(12345)
					@zork_memory.readv(0).should eql(12345)
					@zork_memory.readv(0).should eql(11111)
				end
			end

			describe "loadb" do
				it "should store the value of the byte at the location given by the base and offset into the result" do
					@zork_memory.writeb(2589+200, 127)
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::LOADB,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [2589, 200], 130, nil, nil, 0)
					@processor.execute(i)
					@zork_memory.readv(130).should eql(127)
				end
			end

			describe "loadw" do
				it "should store the value of the word at the location given by the base and offset into the result" do
					@zork_memory.writew(2480+200, 12345)
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::LOADW,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [2480, 100], 130, nil, nil, 0)
					@processor.execute(i)
					@zork_memory.readv(130).should eql(12345)
				end
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

			describe "new_line" do
				it "should print a carriage return" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::NEW_LINE,
													 [], [], nil, nil, nil, 0)
					@processor.execute(i)
					$stdout.string.should eql("\n")
				end
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
					# 'grue' is written at 0x4291
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::PRINT_ADDR,
													 [Gruesome::Z::OperandType::LARGE],
													 [0x4291], nil, nil, nil, 0)

					@processor.execute(i)
					$stdout.string.should eql("grue")
				end
			end

			describe "print_paddr" do
				it "should print out the string located at the packed address given by the operand" do
					# 'ZORK I: The Great Underground Empire' is written at 0x6ee4 (packed: 0x3772)
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::PRINT_PADDR,
													 [Gruesome::Z::OperandType::LARGE],
													 [0x3772], nil, nil, nil, 0)

					@processor.execute(i)
					$stdout.string[/(.*)\n/,1].should eql("ZORK I: The Great Underground Empire")
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

			describe "log_shift" do
				it "should shift left when places is positive" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::LOG_SHIFT,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [-12345+65536, 2], 128, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readv(128).should eql((((-12345+65536) << 2) & 65535))
				end

				it "should shift right when places is positive and not sign extend" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::LOG_SHIFT,
													 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
													 [-123+65536, -2+65536], 128, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readv(128).should eql(((-123+65536) >> 2))
				end
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
		end

		describe "Object" do
			before(:each) do
				# Build object table
				@zork_memory.force_writew(0x0a, 0x200)

				# Build property defaults (for versions 1-3)
				# Each property will have the default value as
				# equally the property number (remember properties
				# start counting at 1)
				31.times do |i|
					@zork_memory.force_writew(0x200 + (i*2), i+1)
				end
				addr = 0x200 + (31 * 2)

				# Build a couple of objects

				# Object #1

				# Attributes: 2, 3, 10, 31
				# Parent: nil
				# Sibling: nil
				# Child: #2

				@zork_memory.force_writeb(addr+0, 0b00110000)
				@zork_memory.force_writeb(addr+1, 0b00100000)
				@zork_memory.force_writeb(addr+2, 0b00000000)
				@zork_memory.force_writeb(addr+3, 0b00000001)

				@zork_memory.force_writeb(addr+4, 0)
				@zork_memory.force_writeb(addr+5, 0)
				@zork_memory.force_writeb(addr+6, 2)

				@zork_memory.force_writew(addr+7, 0x300)

				addr += 9

				# Object #2

				# Attributes: 5, 7, 11, 18, 25
				# Parent: #1
				# Sibling: #3
				# Child: nil

				@zork_memory.force_writeb(addr+0, 0b00000101)
				@zork_memory.force_writeb(addr+1, 0b00010000)
				@zork_memory.force_writeb(addr+2, 0b00100000)
				@zork_memory.force_writeb(addr+3, 0b01000001)

				@zork_memory.force_writeb(addr+4, 1)
				@zork_memory.force_writeb(addr+5, 3)
				@zork_memory.force_writeb(addr+6, 0)

				@zork_memory.force_writew(addr+7, 0x300)

				addr += 9

				# Object #3

				# Attributes: 0
				# Parent: #1
				# Sibling: #2
				# Child: nil

				@zork_memory.force_writeb(addr+0, 0b10000000)
				@zork_memory.force_writeb(addr+1, 0b00000000)
				@zork_memory.force_writeb(addr+2, 0b00000000)
				@zork_memory.force_writeb(addr+3, 0b00000000)

				@zork_memory.force_writeb(addr+4, 1)
				@zork_memory.force_writeb(addr+5, 2)
				@zork_memory.force_writeb(addr+6, 0)

				@zork_memory.force_writew(addr+7, 0x4290)

				addr += 9

				# Properties Table
				#
				# 'grue' is written at 0x4291
				# So, lets abuse that
				#
				# Give the short-name a length of 4
				@zork_memory.force_writeb(0x4290, 2)

				# Now the property list
				written_size = (2 - 1) << 5
				property_number = 15
				@zork_memory.force_writeb(0x4295, written_size + property_number)
				@zork_memory.force_writew(0x4296, 34567)

				written_size = (1 - 1) << 5
				property_number = 20
				@zork_memory.force_writeb(0x4298, written_size + property_number)
				@zork_memory.force_writeb(0x4299, 123)

				# End list
				@zork_memory.force_writeb(0x429a, 0)

				@object_table = Gruesome::Z::ObjectTable.new(@zork_memory)

				# need to reinstantiate the processor
				@processor = Gruesome::Z::Processor.new(@zork_memory)
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

				describe "print_obj" do
					it "should print to stdout out the short name of the object whose index is given as an operand" do
						i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::PRINT_OBJ,
														 [Gruesome::Z::OperandType::LARGE],
														 [3], nil, nil, nil, 0)

						@processor.execute(i)
						$stdout.string.should eql("grue")
					end
				end
			end

			describe "Branch Instruction" do
				describe "get_child" do
					# Note:
					#  - Object 1 has one child: Object 2
					#  - Object 2 has no children

					it "should not branch if the child object index of the requested object is 0" do
						i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::GET_CHILD,
														 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
														 [2], 128, 2000, true, 0)

						@processor.execute(i)
						@zork_memory.program_counter.should eql(12345)
					end

					it "should branch if the child object index exists for the requested object" do
						i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::GET_CHILD,
														 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
														 [1], 128, 2000, true, 0)
						@processor.execute(i)
						@zork_memory.program_counter.should eql(2000)
					end

					it "should branch if the child object index of the requested object is 0 and condition is negated" do
						i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::GET_CHILD,
														 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
														 [2], 128, 2000, false, 0)

						@processor.execute(i)
						@zork_memory.program_counter.should eql(2000)
					end

					it "should not branch if the child object index exists for the requested object and condition is negated" do
						i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::GET_CHILD,
														 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
														 [1], 128, 2000, false, 0)
						@processor.execute(i)
						@zork_memory.program_counter.should eql(12345)
					end


					it "should store the child object index to the destination variable" do
						i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::GET_CHILD,
														 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
														 [1], 128, 2000, true, 0)
						@processor.execute(i)
						@zork_memory.readv(128).should eql(2)
					end
				end

				describe "get_sibling" do
					# Note:
					#  - Object 1 has no siblings
					#  - Object 2 has one sibling: Object 3

					it "should not branch if the sibling object index of the requested object is 0" do
						i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::GET_SIBLING,
														 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
														 [1], 128, 2000, true, 0)

						@processor.execute(i)
						@zork_memory.program_counter.should eql(12345)
					end

					it "should branch if the sibling object index exists for the requested object" do
						i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::GET_SIBLING,
														 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
														 [2], 128, 2000, true, 0)
						@processor.execute(i)
						@zork_memory.program_counter.should eql(2000)
					end

					it "should branch if the sibling object index of the requested object is 0 and condition is negated" do
						i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::GET_SIBLING,
														 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
														 [1], 128, 2000, false, 0)

						@processor.execute(i)
						@zork_memory.program_counter.should eql(2000)
					end

					it "should not branch if the sibling object index exists for the requested object and condition is negated" do
						i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::GET_SIBLING,
														 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
														 [2], 128, 2000, false, 0)
						@processor.execute(i)
						@zork_memory.program_counter.should eql(12345)
					end


					it "should store the sibling object index to the destination variable" do
						i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::GET_SIBLING,
														 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
														 [2], 128, 2000, true, 0)
						@processor.execute(i)
						@zork_memory.readv(128).should eql(3)
					end
				end

				describe "get_parent" do
					# Note:
					#  - Object 1 has no parents
					#  - Object 2 has a parent: Object 1

					it "should store the parent object index to the destination variable" do
						i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::GET_PARENT,
														 [Gruesome::Z::OperandType::LARGE],
														 [2], 128, 2000, true, 0)
						@processor.execute(i)
						@zork_memory.readv(128).should eql(1)
					end
				end

				describe "jin" do
					# Note:
					#  - Object 1 has no parents
					#  - Object 2 has a parent: Object 1

					it "should not branch if the given object is not a child of the other" do
						i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JIN,
														 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
														 [1, 2], 128, 2000, true, 0)

						@processor.execute(i)
						@zork_memory.program_counter.should eql(12345)
					end

					it "should branch if the given object is a child of the other" do
						i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JIN,
														 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
														 [2,1], 128, 2000, true, 0)
						@processor.execute(i)
						@zork_memory.program_counter.should eql(2000)
					end

					it "should branch if the given object is not a child of the other and condition is negated" do
						i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JIN,
														 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
														 [1, 2], 128, 2000, false, 0)

						@processor.execute(i)
						@zork_memory.program_counter.should eql(2000)
					end

					it "should not branch if the given object is a child of the other and condition is negated" do
						i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::JIN,
														 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
														 [2,1], 128, 2000, false, 0)
						@processor.execute(i)
						@zork_memory.program_counter.should eql(12345)
					end
				end

				describe "test_attr" do
					it "should branch if the object has the attribute set" do
						@object_table.object_has_attribute?(1, 10).should eql(true)
						i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::TEST_ATTR,
														 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
														 [1, 10], nil, 2000, true, 0)

						@processor.execute(i)
						@zork_memory.program_counter.should eql(2000)
					end

					it "should not branch if the object does not have the attribute set" do
						@object_table.object_has_attribute?(1, 11).should eql(false)
						i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::TEST_ATTR,
														 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
														 [1, 11], nil, 2000, true, 0)

						@processor.execute(i)
						@zork_memory.program_counter.should eql(12345)
					end

					it "should not branch if the first operand has all bits set that the second has set and condition is negated" do
						@object_table.object_has_attribute?(1, 10).should eql(true)
						i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::TEST_ATTR,
														 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
														 [1, 10], nil, 2000, false, 0)

						@processor.execute(i)
						@zork_memory.program_counter.should eql(12345)
					end

					it "should branch if the first operand does not have all bits set that the second has set and condition is negated" do
						@object_table.object_has_attribute?(1, 11).should eql(false)
						i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::TEST_ATTR,
														 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
														 [1, 11], nil, 2000, false, 0)

						@processor.execute(i)
						@zork_memory.program_counter.should eql(2000)
					end

				end
			end

			describe "Instruction" do
				after(:each) do
					# The program counter should not be changed
					@zork_memory.program_counter.should eql(12345)
				end

				describe "get_prop" do
					it "should retrieve the property in the object's list when it is a byte" do
						i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::GET_PROP,
														 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
														 [3, 20], 128, nil, nil, 0)
						@processor.execute(i)
						@zork_memory.readv(128).should eql(123)
					end

					it "should retrieve the property in the object's list when it is a word" do
						i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::GET_PROP,
														 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
														 [3, 15], 128, nil, nil, 0)
						@processor.execute(i)
						@zork_memory.readv(128).should eql(34567)
					end

					it "should retrieve the default property when the object list does not have the property listed" do
						i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::GET_PROP,
														 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
														 [3, 28], 128, nil, nil, 0)
						@processor.execute(i)
						@zork_memory.readv(128).should eql(28)
					end
				end

				describe "insert_obj" do
					it "should insert the object given as the child of the other object given" do
						@object_table.object_get_child(2).should eql(0)
						i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::INSERT_OBJ,
														 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
														 [3, 2], nil, nil, nil, 0)
						@processor.execute(i)

						@object_table.object_get_child(2).should eql(3)
					end

					it "should set the sibling of the given object as the previous child of the other object given" do
						@object_table.object_get_sibling(3).should eql(2)
						i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::INSERT_OBJ,
														 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
														 [3, 2], nil, nil, nil, 0)
						@processor.execute(i)

						@object_table.object_get_sibling(3).should eql(0)
					end
				end

				describe "remove_obj" do
					it "should clear the parent of the given object" do
						@object_table.object_get_parent(2).should eql(1)
						i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::REMOVE_OBJ,
														 [Gruesome::Z::OperandType::LARGE],
														 [2], nil, nil, nil, 0)
						@processor.execute(i)

						@object_table.object_get_parent(2).should eql(0)
					end
				end


				describe "clear_attr" do
					it "should clear the attribute when it exists in the object attribute list without altering other attributes" do
						@object_table.object_has_attribute?(2, 25).should eql(true)
						i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::CLEAR_ATTR,
														 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
														 [2, 25], nil, nil, nil, 0)
						@processor.execute(i)

						@object_table.object_has_attribute?(2, 25).should eql(false)
						@object_table.object_has_attribute?(2, 31).should eql(true)
					end

					it "should do nothing when the attribute is already cleared" do
						@object_table.object_has_attribute?(2, 26).should eql(false)
						i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::CLEAR_ATTR,
														 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
														 [2, 26], nil, nil, nil, 0)
						@processor.execute(i)

						@object_table.object_has_attribute?(2, 26).should eql(false)
						@object_table.object_has_attribute?(2, 31).should eql(true)
					end
				end

				describe "set_attr" do
					it "should set the attribute when it exists in the object attribute list without altering other attributes" do
						@object_table.object_has_attribute?(2, 26).should eql(false)
						i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::SET_ATTR,
														 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
														 [2, 26], nil, nil, nil, 0)
						@processor.execute(i)

						@object_table.object_has_attribute?(2, 26).should eql(true)
						@object_table.object_has_attribute?(2, 31).should eql(true)
					end

					it "should do nothing when the attribute is already set" do
						@object_table.object_has_attribute?(2, 25).should eql(true)
						i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::SET_ATTR,
														 [Gruesome::Z::OperandType::LARGE, Gruesome::Z::OperandType::LARGE],
														 [2, 25], nil, nil, nil, 0)
						@processor.execute(i)

						@object_table.object_has_attribute?(2, 25).should eql(true)
						@object_table.object_has_attribute?(2, 31).should eql(true)
					end
				end
			end
		end

		describe "Instruction" do
			after(:each) do
				# The program counter should not be changed
				@zork_memory.program_counter.should eql(12345)
			end

			describe "store" do
				it "should store the value into the variable referenced by the operand" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::STORE,
													 [Gruesome::Z::OperandType::VARIABLE, Gruesome::Z::OperandType::LARGE],
													 [128, -13+65536], nil, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readv(128).should eql(-13+65536)
				end

				it "should write to the stack in-place when variable %00 is used" do
					@zork_memory.writev(0, 11111)
					@zork_memory.writev(0, 12345)
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::STORE,
													 [Gruesome::Z::OperandType::VARIABLE, Gruesome::Z::OperandType::LARGE],
													 [0, -13+65536], nil, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readv(0).should eql(-13+65536)
					@zork_memory.readv(0).should eql(11111)
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

					@zork_memory.readw(2000+200).should eql(12345)
				end
			end

			describe "pull" do
				it "should pop the value from the stack that was most recently pushed" do
					@zork_memory.writev(0, 23456)
					@zork_memory.writev(0, 34567)
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::PULL, 
													 [Gruesome::Z::OperandType::VARIABLE], [128], nil, nil, nil, 0)

					@processor.execute(i)
					@zork_memory.readv(128).should eql(34567)
					@zork_memory.readv(0).should eql(23456)
				end

				it "should not change the stack if the given variable is %00" do
					@zork_memory.writev(0, 23456)
					@zork_memory.writev(0, 34567)
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::PULL, 
													 [Gruesome::Z::OperandType::VARIABLE], [0], nil, nil, nil, 0)

					@processor.execute(i)
					@zork_memory.readv(0).should eql(34567)
					@zork_memory.readv(0).should eql(23456)
				end
			end

			describe "push" do
				it "should push the value on the stack such that a read of variable %00 will yield that value" do
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::PUSH,
													 [Gruesome::Z::OperandType::LARGE],
													 [23456], nil, nil, nil, 0)

					@processor.execute(i)

					@zork_memory.readv(0).should eql(23456)
				end
			end

			describe "pop" do
				it "should throw away the most recently pushed item on the stack" do
					@zork_memory.writev(0, 23456)
					@zork_memory.writev(0, 34567)
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::POP, 
													 [], [], nil, nil, nil, 0)

					@processor.execute(i)
					@zork_memory.readv(0).should eql(23456)
				end
			end

			describe "dec" do
				it "should decrement the value in the variable given as the operand" do
					@zork_memory.writev(128, 12345)
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::DEC,
													 [Gruesome::Z::OperandType::VARIABLE],
													 [128], nil, nil, nil, 0)
					@processor.execute(i)
					@zork_memory.readv(128).should eql(12344)
				end

				it "should consider the value signed and decrement 0 to -1" do
					@zork_memory.writev(128, 0)
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::DEC,
													 [Gruesome::Z::OperandType::VARIABLE],
													 [128], nil, nil, nil, 0)
					@processor.execute(i)
					@zork_memory.readv(128).should eql(-1+65536)
				end

				it "should edit the value on the stack in place" do
					@zork_memory.writev(0, 11111)
					@zork_memory.writev(0, 12345)
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::DEC,
													 [Gruesome::Z::OperandType::VARIABLE],
													 [0], nil, nil, nil, 0)
					@processor.execute(i)
					@zork_memory.readv(0).should eql(12344)
					@zork_memory.readv(0).should eql(11111)
				end
			end

			describe "inc" do
				it "should increment the value in the variable given as the operand" do
					@zork_memory.writev(128, 12345)
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::INC,
													 [Gruesome::Z::OperandType::VARIABLE],
													 [128], nil, nil, nil, 0)
					@processor.execute(i)
					@zork_memory.readv(128).should eql(12346)
				end

				it "should consider the value signed and increment -1 to 0" do
					@zork_memory.writev(128, -1+65536)
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::INC,
													 [Gruesome::Z::OperandType::VARIABLE],
													 [128], nil, nil, nil, 0)
					@processor.execute(i)
					@zork_memory.readv(128).should eql(0)
				end

				it "should edit the value on the stack in place" do
					@zork_memory.writev(0, 11111)
					@zork_memory.writev(0, 12345)
					i = Gruesome::Z::Instruction.new(Gruesome::Z::Opcode::INC,
													 [Gruesome::Z::OperandType::VARIABLE],
													 [0], nil, nil, nil, 0)
					@processor.execute(i)
					@zork_memory.readv(0).should eql(12346)
					@zork_memory.readv(0).should eql(11111)
				end
			end
		end
	end
end
