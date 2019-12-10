
require_relative "../intcode"

describe "IntcodeMachine" do
  let(:input_pipe) { IO.pipe }
  let(:output_pipe) { IO.pipe }
  let(:machine) { IntcodeMachine.new(program, input_pipe[0], output_pipe[1]) }
  let(:output) { output_pipe[0].gets.chomp }
  let(:program) { program_string.split(',').map(&:to_i) }
  
  context "large numbers" do
    context "specific number" do
      let(:program_string) { "104,1125899906842624,99" }

      it "outputs a big number" do
        machine.run
        expect(output.to_i).to eq 1125899906842624
      end
    end

    context "just count it" do
      let(:program_string) { "1102,34915192,34915192,7,4,7,99,0" }

      it "outputs another large number" do
        machine.run
        expect(output.size).to eq 16
      end
    end
  end

  context "relative parameters" do
    context "print a copy of itself" do
      let(:program_string) { "109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99" }
      let(:result) { output_pipe[0].readlines(chomp: true).join(',') }
      let(:run) do
        machine.run
        output_pipe[1].close_write
      end

      it "prints itself" do
        run
        expect(result).to eq program_string
      end
    end
  end

  context "arbitrary array" do
    context "assign to an address outside the program" do
      # put the number 3 at position 100 and output
      let(:program_string) { "1,1,2,100,4,100,99" }

      it "allows assignment past the end of program" do
        machine.run
        expect(output).to eq "3"
      end
    end
  end
end
