
require_relative "../p10.rb"

describe "2019 p10" do
  describe "Map" do
    let(:map1) { Map.new(example) }
    subject { map1.most_visible }

    context "example1" do
      let(:example) do
        ["......#.#.",
         "#..#.#....",
         "..#######.",
         ".#.#.###..",
         ".#..#.....",
         "..#....#.#",
         "#..#....#.",
         ".##.#..###",
         "##...#..#.",
         ".#....####" ]
      end
      let(:answer) { [[5,8], 33] }

      it 'finds the best spot' do
        expect(subject).to eq answer
      end
    end

    context "example2" do
      let(:example) do
        [ "#.#...#.#.",
          ".###....#.",
          ".#....#...",
          "##.#.#.#.#",
          "....#.#.#.",
          ".##..###.#",
          "..#...##..",
          "..##....##",
          "......#...",
          ".####.###.", ]
      end
      let(:answer) { [[1,2], 35] }

      it 'finds the best spot' do
        expect(subject).to eq answer
      end
    end
  end

  describe "Slope" do
    subject { Slope.new(*args).as_pair }
    context "first" do
      let(:args) { [1,1,0,0] }
      it "is +1 +1" do
        expect(subject).to eq [1,1]
      end
    end

    context "second quadrant" do
      let(:args) { [4,6,5,5] }
      it "is +1 -1" do
        expect(subject).to eq [1, -1]
      end
    end
     
    
  end
  
end
