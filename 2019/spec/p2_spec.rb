
require_relative "../p2.rb"

describe "2019 p2" do
  
  context "run" do
    let(:example1) { "1,0,0,0,99" }
    let(:example2) { "2,3,0,3,99" }
    let(:example3) { "2,4,4,5,99,0" }
    let(:example4) { "1,1,1,4,99,5,6,0,99" }
    
    it 'adds' do
      expect(run(example1)).to eq "2,0,0,0,99"
    end

    it 'multiplies' do
      expect(run(example2)).to eq "2,3,0,6,99"
    end

    it 'multiplies 99' do
      expect(run(example3)).to eq "2,4,4,5,99,9801"
    end

    it "doesn't halt yet" do
      expect(run(example4)).to eq "30,1,1,4,2,5,6,0,99"
    end
  end
end
