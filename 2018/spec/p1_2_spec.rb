
require_relative "../p1_2.rb"
require 'rspec'

# +1, -1 first reaches 0 twice.
# +3, +3, +4, -2, -4 first reaches 10 twice.
# -6, +3, +8, +5, -6 first reaches 5 twice.
# +7, +7, -2, -7, -4 first reaches 14 twice.

describe 'find_dup' do
  let(:test1) { ["+1", "-1"] }
  let(:test2) { ["+3", "+3", "+4", "-2", "-4"] }
  let(:test3) { ["-6", "+3", "+8", "+5", "-6"] }
  let(:test4) { ["+7", "+7", "-2", "-7", "-4"] }

  subject { find_dup(this_case) }

  shared_examples "regular tests" do
    # this_case, answer
    it "passes" do
      expect(subject).to eq answer
    end
  end
  
  context "test1" do
    it_behaves_like "regular tests" do
      let(:this_case) { test1 }
      let(:answer) { 0 }
    end
  end

  context "test2" do
    it_behaves_like "regular tests" do
      let(:this_case) { test2 }
      let(:answer) { 10 }
    end
  end

  context "test3" do
    it_behaves_like "regular tests" do
      let(:this_case) { test3 }
      let(:answer) { 5 }
    end
  end

  context "test4" do
    it_behaves_like "regular tests" do
      let(:this_case) { test4 }
      let(:answer) { 14 }
    end
  end

end
