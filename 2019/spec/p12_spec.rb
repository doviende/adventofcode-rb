require_relative '../p12.rb'

describe "2019 p12" do
  context "part 1 examples" do
    let(:example) do
      ["<x=-8, y=-9, z=-7>",
       "<x=-5, y=2, z=-1>",
       "<x=11, y=8, z=-14>",
       "<x=1, y=-4, z=-11>"]
    end
    let(:answer) { 9127 }
    let(:sim) do
      s = Simulator.new
      example.each do |mline|
        s.add_moon(Moon.new(mline))
      end
      s.run(1000)
      s
    end

    it 'is 9127' do
      expect(sim.energy).to eq answer
    end
  end
end
