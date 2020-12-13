require_relative "../p13.rb"

describe "2020 p13" do
  describe MultFinder do
    let(:instance) { described_class.new(input) }

    describe "#find_number" do
      subject { instance.find_number }
      context "first example" do
        let(:input) { "17,x,13,19" }

        it { is_expected.to eq 3417 }
      end

      context "2nd example" do
        let(:input) { "67,7,59,61" }

        it { is_expected.to eq 754018 }
      end

      context "3rd example" do
        let(:input) { "67,x,7,59,61" }

        it { is_expected.to eq 779210 }
      end

      context "4th example" do
        let(:input) { "67,7,x,59,61" }

        it { is_expected.to eq 1261476 }
      end

      context "5th example" do
        let(:input) { "1789,37,47,1889" }

        it { is_expected.to eq 1202161486 }
      end
    end
  end
end
