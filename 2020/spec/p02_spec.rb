require_relative "../p02.rb"

describe "2020 p2" do
  describe RuleChecker do
    let(:instance) { described_class.new(rule) }

    describe "#parse_rule" do
      subject { instance.parse_rule }
      let(:rule) { "2-5 z" }
      let(:expected_result) { RuleChecker::Rule.new(2, 5, "z") }

      it "parses rules" do
        expect(subject).to eq expected_result
      end
    end

    describe "#satisfy?" do
      subject { instance.satisfy?(str) }
      let(:rule) { "2-5 z" }

      context "good string" do
        let(:str) { "zz" }
        it "matches" do
          is_expected.to eq true
        end
      end

      context "insufficient letters" do
        let(:str) { "za" }

        it { is_expected.to eq false }
      end

      context "too many letters" do
        let(:str) { "zzzzzzzzzzzabc" }

        it { is_expected.to eq false }
      end
    end
  end
end

