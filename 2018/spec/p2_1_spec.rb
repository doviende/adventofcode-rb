
require_relative "../p2_1.rb"

describe 'letter_counts' do
  all_tests =
    {
      test1: { example: "abcdef", answer: [0, 0] },
      test2: { example: "bababc", answer: [1, 1] },
      test3: { example: "aabcdd", answer: [1, 0] }
    }
  
  subject { letter_counts(this_case) }

  shared_examples "regular tests" do
    # this_case, answer
    it "passes" do
      expect(subject).to eq answer
    end
  end

  all_tests.each do |k, v|
    context "#{v[:example]} --> #{v[:answer]}" do
      it_behaves_like "regular tests" do
        let(:this_case) { v[:example] }
        let(:answer) { v[:answer] }
      end
    end
  end
end

describe 'list_checksum' do
  let(:example) { ["abcdef", "bababc", "aabcdd", "aaabcd", "abbbcd"] }

  it 'has the right sum' do
    expect(list_checksum(example)).to eq 2*3
  end
end
