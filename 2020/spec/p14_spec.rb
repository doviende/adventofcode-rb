require_relative "../p14.rb"

describe "2020 p14" do
  describe Version2MemoryMachine do
    let(:instance) { described_class.new }
    describe "#sum" do
      subject do
        lines.each { |line| instance.parse_line(line) }
        instance.sum
      end

      context "simple example" do
        let(:lines) do
          [
            "mask = 000000000000000000000000000000X1001X",
            "mem[42] = 100",
            "mask = 00000000000000000000000000000000X0XX",
            "mem[26] = 1",
          ]
        end

        it { is_expected.to eq 208 }
      end
    end
  end
end
