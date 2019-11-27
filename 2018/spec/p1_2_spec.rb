
require_relative "../p1_2.rb"
require 'rspec'

# +1, -1 first reaches 0 twice.
# +3, +3, +4, -2, -4 first reaches 10 twice.
# -6, +3, +8, +5, -6 first reaches 5 twice.
# +7, +7, -2, -7, -4 first reaches 14 twice.

describe 'find_dup' do
  all_tests =
    { test1: {example: ["+1", "-1"], answer: 0},
      test2: {example: ["+3", "+3", "+4", "-2", "-4"], answer: 10},
      test3: {example: ["-6", "+3", "+8", "+5", "-6"], answer: 5},
      test4: {example: ["+7", "+7", "-2", "-7", "-4"], answer: 14},
    }

  subject { find_dup(this_case) }

  shared_examples "regular tests" do
    # this_case, answer
    it "passes" do
      expect(subject).to eq answer
    end
  end

  all_tests.each do |k, v|
    context k do
      it_behaves_like "regular tests" do
        let(:this_case) { v[:example] }
        let(:answer) { v[:answer] }
      end
    end
  end
end
