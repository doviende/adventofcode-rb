require_relative "../p05.rb"

describe "2020 p05" do
  describe SeatAddress do
    let(:instance) { described_class.new(input) }

    context "first example" do
      let(:input) { "FBFBBFFRLR" }

      it "has row 44" do
        expect(instance.row).to eq 44
      end

      it "has column 5" do
        expect(instance.column).to eq 5
      end

      it "has seat_id 357" do
        expect(instance.seat_id).to eq 357
      end
    end
  end
end
