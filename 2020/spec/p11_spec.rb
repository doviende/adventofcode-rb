require_relative "../p11.rb"

describe "2020 p11" do
  describe SeatLife do
    let(:instance) { described_class.new(lines) }
    shared_examples_for "grid check" do |x1, y1, result|
      let(:x) { x1 }
      let(:y) { y1 }

      it { is_expected.to eq result }
    end

    describe "#score" do
      subject { instance.score }
      let(:lines) do
        [
          "#..",
          "#L.",
          "L.#",
        ]
      end

      it "scores properly" do
        expect(subject).to eq 3
      end
    end

    describe "#four_or_more_occupied" do
      subject do
        instance.add_grid
        instance.four_or_more_occupied(x, y)
      end
      let(:lines) do
        [
          "##.",
          "L##",
          ".L#",
        ]
      end

      it_behaves_like "grid check", 1, 1, true
      it_behaves_like "grid check", 0, 0, false
      it_behaves_like "grid check", 0, 2, false

      context "first example first turn" do
        let(:lines) do
          [
            "LL.",
            "LLL",
            "L.L",
          ]
        end

        it_behaves_like "grid check", 1, 0, false
        it_behaves_like "grid check", 1, 1, false
      end

      context "first example full" do
      end
    end

    describe "#neighbours_empty" do
      subject do
        instance.add_grid
        instance.neighbours_empty(x, y)
      end

      context "when empty" do
        let(:lines) do
          [
            "LLL",
            "L#L",
            "LLL",
          ]
        end

        it_behaves_like "grid check", 1, 1, true
        it_behaves_like "grid check", 0, 0, false
        it_behaves_like "grid check", 2, 2, false
      end

      context "when not empty" do
        let(:lines) do
          [
            "LLL",
            "L#L",
            "L#L",
          ]
        end

        it_behaves_like "grid check", 1, 1, false
      end
    end

    describe "#process_turn" do
      let(:lines) do
        [
          "L.LL.LL.LL",
          "LLLLLLL.LL",
          "L.L.L..L..",
          "LLLL.LL.LL",
          "L.LL.LL.LL",
          "L.LLLLL.LL",
          "..L.L.....",
          "LLLLLLLLLL",
          "L.LLLLLL.L",
          "L.LLLLL.LL",
        ]
      end
      let(:second_grid) do
        [
          "#.##.##.##",
          "#######.##",
          "#.#.#..#..",
          "####.##.##",
          "#.##.##.##",
          "#.#####.##",
          "..#.#.....",
          "##########",
          "#.######.#",
          "#.#####.##",
        ]
      end
      let(:third_grid) do
        [
          "#.LL.L#.##",
          "#LLLLLL.L#",
          "L.L.L..L..",
          "#LLL.LL.L#",
          "#.LL.LL.LL",
          "#.LLLL#.##",
          "..L.L.....",
          "#LLLLLLLL#",
          "#.LLLLLL.L",
          "#.#LLLL.##",
        ]
      end
      subject do
        instance.add_grid
        instance.process_turn
        instance
      end

      it "correctly does next turn" do
        aggregate_failures do
          subject.current.each.with_index do |line, y|
            expect(line).to eq second_grid[y]
          end
        end
      end

      context "3rd turn" do
        let(:lines) { second_grid }

        it "correctly does third turn" do
          aggregate_failures do
            subject.current.each.with_index do |line, y|
              expect(line).to eq third_grid[y]
            end
          end
        end
      end
    end
  end
end

