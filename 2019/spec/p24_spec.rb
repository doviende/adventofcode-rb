
require_relative '../p24.rb'
require 'pry'

describe BugBoard do
  let(:instance) { described_class.new }

  context "single board" do
    let(:example1) do
      [
        "....#",
        "#..#.",
        "#..##",
        "..#..",
        "#...."
      ].map { |r| r.chars.map { |x| x == "#" } }
    end
    let(:example1_2) do
      [
        "#..#.",
        "####.",
        "##..#",
        "##.##",
        ".##.."
      ].map { |r| r.chars.map { |x| x == "#" } }
    end

    let(:result2) do
      foo = described_class.new
      foo.set_board! example1_2
      foo
    end
      
    subject do
      instance.set_board!(example1)
      instance.calc_next
      instance.set_next
      instance
    end

    it do
      subject.zip(example1_2).each do |a,b|
        expect(a).to eq b
      end
    end
    it do
      expect(subject.to_s).to eq result2.to_s
    end
  end

  context "2 layers simple" do
    let(:example1_L1) do
      [
        ".....",
        ".....",
        ".....",
        "..#..",
        "....."
      ].map { |r| r.chars.map { |x| x == "#" } }
    end
    let(:example1_L2) do
      [
        ".....",
        ".....",
        "#....",
        ".....",
        "....."
      ].map { |r| r.chars.map { |x| x == "#" } }
    end
    let(:board1) do
      foo = described_class.new
      foo.set_board! example1_L1
      foo
    end
    let(:board2) do
      foo = described_class.new
      foo.set_board! example1_L2
      foo
    end
    let(:example1_L1_2) do
      [
        ".....",
        ".....",
        ".#...",
        ".#.#.",
        "..#.."
      ].map { |r| r.chars.map { |x| x == "#" } }
    end
    let(:example1_L2_2) do
      [
        ".....",
        "#....",
        ".#...",
        "#....",
        "#####"
      ].map { |r| r.chars.map { |x| x == "#" } }
    end
    let(:board1_2) do
      foo = described_class.new
      foo.set_board! example1_L1_2
      foo
    end
    let(:board2_2) do
      foo = described_class.new
      foo.set_board! example1_L2_2
      foo
    end

    it 'works with inner board' do
      board1.inner = board2
      board2.outer = board1
      board1.calc_next
      board2.calc_next
      board1.set_next
      board2.set_next
      expect(board1.to_s).to eq board1_2.to_s
      expect(board2.to_s).to eq board2_2.to_s
    end
  end
  
end
