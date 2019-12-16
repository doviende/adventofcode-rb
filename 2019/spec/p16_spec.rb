
require_relative "../p16.rb"

describe FftCalc do
  let(:instance) { FftCalc.new(input.chars.map(&:to_i)) }
  subject { instance.apply(times); instance }
  context 'first' do
    let(:input) { "12345678" }
    let(:answer) { "48226158" }
    let(:times) { 1 }

    it 'is correct' do
      expect(subject.output).to eq answer
    end
  end

  context 'second' do
    let(:input) {  "48226158" }
    let(:answer) { "34040438" }
    let(:times) { 1 }

    it 'is correct' do
      expect(subject.output).to eq answer
    end
  end

  context 'larger 100x' do
    let(:input) {  "80871224585914546619083218645595" }
    let(:answer) { "24176176" }
    let(:times) { 100 }

    it 'is correct' do
      expect(subject.output[0,8]).to eq answer
    end
  end
end
