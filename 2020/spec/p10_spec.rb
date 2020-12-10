require_relative "../p10.rb"

describe "2020 p10" do
  describe JoltOrderer do
    let(:instance) { described_class.new(list) }

    describe "#num_arrangements" do
      subject { instance.num_arrangements }

      context "given example 1" do
        let(:list) { [ 16, 10, 15, 5, 1, 11, 7, 19, 6, 12, 4] }

        # possible arrangements:
        # (0), 1, 4, 5, 6, 7, 10, 11, 12, 15, 16, 19, (22)
        # (0), 1, 4, 5, 6, 7, 10, 12, 15, 16, 19, (22)
        # (0), 1, 4, 5, 7, 10, 11, 12, 15, 16, 19, (22)
        # (0), 1, 4, 5, 7, 10, 12, 15, 16, 19, (22)
        # (0), 1, 4, 6, 7, 10, 11, 12, 15, 16, 19, (22)
        # (0), 1, 4, 6, 7, 10, 12, 15, 16, 19, (22)
        # (0), 1, 4, 7, 10, 11, 12, 15, 16, 19, (22)
        # (0), 1, 4, 7, 10, 12, 15, 16, 19, (22)
        it { is_expected.to eq 8 }
      end

      context "given example 2" do
        let(:list) { [ 28, 33, 18, 42, 31, 14, 46, 20, 48, 47, 24, 23, 49, 45, 19, 38, 39, 11, 1, 32, 25, 35, 8, 17, 7, 9, 4, 2, 34, 10, 3 ] }

        it { is_expected.to eq 19208 }
      end
    end
  end
end
