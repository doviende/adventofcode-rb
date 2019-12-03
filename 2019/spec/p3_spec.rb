require_relative "../p3.rb"

describe "2019 p3" do
  context "expand" do
    let(:example) { "D20" }
    let(:start) { [0,0] }
    subject { expand(example, start) }
    it "has 20 elements" do
      expect(subject.size).to eq 20
    end

    context 'short R' do
      let(:example) { "R2" }
      it "is right" do
        expect(subject).to eq [[1,0], [2,0]]
      end
    end

    context 'short L' do
      let(:example) { "L2" }
      it "is right" do
        expect(subject).to eq [[-1,0], [-2,0]]
      end
    end

    context 'short U' do
      let(:start) { [10,5] }
      let(:example) { "U2" }
      it "is right" do
        expect(subject).to eq [[10,6], [10,7]]
      end
    end
  end

  context "mark1" do
    subject do
      mark1(myhash, wire, "A")
      myhash
    end
    let(:myhash) { {} }
    let(:wire) { ["R2", "U2"] }
    let(:ex) do
      { [1,0] => "A",
        [2,0] => "A",
        [2,1] => "A",
        [2,2] => "A" }
    end

    it "is correct" do
      expect(subject).to eq ex
    end

    context "adding" do
      let(:wire2) { ["U2", "R2"] }
      subject do
        mark1(myhash, wire, "A")
        mark1(myhash, wire2, "B")
        myhash
      end
      let(:ex) do
        { [1,0] => "A",
          [2,0] => "A",
          [2,1] => "A",
          [2,2] => "AB",
          [0,1] => "B",
          [0,2] => "B",
          [1,2] => "B"
        }
      end
      it "is correct" do
        expect(subject).to eq ex
      end
    end
  end

  context "part1" do
    subject { part1(wire1, wire2) }
    context "first example" do
      let(:wire1) { "R75,D30,R83,U83,L12,D49,R71,U7,L72" }
      let(:wire2) { "U62,R66,U55,R34,D71,R55,D58,R83" }

      it "is 159" do
        expect(subject).to eq 159
      end
    end

    context "second example" do
      let(:wire1) { "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51" }
      let(:wire2) { "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7" }
      it "is 135" do
        expect(subject).to eq 135
      end
    end

    context "simple example" do
      let(:wire1) { "R2,U2" }
      let(:wire2) { "U2,R2" }
      it "is 4" do
        expect(subject).to eq 4
      end
    end

    context "next example" do
      let(:wire1) { "R2,U2,R2,U2" }
      let(:wire2) { "U2,R2,U2,R2" }
      it "is 4" do
        expect(subject).to eq 4
      end
    end

    context "next example" do
      let(:wire1) { "R2,U3,L3,D4" }
      let(:wire2) { "U2,R3,D3,L4" }
      it "is 2" do
        expect(subject).to eq 2
      end
    end
  end
end
