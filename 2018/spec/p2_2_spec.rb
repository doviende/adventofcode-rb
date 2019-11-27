
require_relative "../p2_2.rb"

describe 'differ_by_one' do
  it 'true case' do
    expect(differ_by_one(["abc", "abd"])).to be true
  end

  it 'same string' do
    expect(differ_by_one(["abc", "abc"])).to be false
  end

  it 'two differences' do
    expect(differ_by_one(["abc", "ade"])).to be false
  end
end


describe 'subtract_diff' do
  subject { subtract_diff(example_pair) }

  context 'abc and abd' do
    let(:example_pair) { ["abc", "abd"] }
    it 'returns ab' do
      expect(subject).to eq "ab"
    end
  end
end
