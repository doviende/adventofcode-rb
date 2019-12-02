require_relative "../p4.rb"
require 'easy_tests'
require 'pry'

date_examples = [
  { args: "1518-08-29 00:30", answer: ["1518-08-29", 30] },
]  

describe "2018 problem 4" do
  context "MyDate" do
    it_behaves_like "easy test", :parse_date, date_examples do
      let(:klass) { MyDate }
    end
  end

  context "SleepInterval" do
    context "accessors" do
      let(:interval) { SleepInterval.new(123, "1518-03-06 00:02", "1518-03-06 00:22") }

      it "has the right date" do
        expect(interval.day).to eq "1518-03-06"
      end

      it "has the right id" do
        expect(interval.id).to eq 123
      end

      it "has a MyDate as start" do
        expect(interval.start.class).to be MyDate
      end

      it "has the right start" do
        expect(interval.start.min).to eq 2
      end

      it "has the right finish" do
        expect(interval.finish.min).to eq 22
      end

      it "has the right total_min" do
        expect(interval.total_min).to eq 20
      end
    end
  end
end
