require_relative "../p04.rb"

describe "2020 p4" do
  describe PassportRecord do
    describe PassportRecord::ValidationHelpers do
      context "#valid_byr?" do
        subject { described_class.valid_byr?(value) }

        context "good" do
          let(:value) { "2002" }
          it { is_expected.to eq true }
        end

        context "bad" do
          let(:value) { "2003" }
          it { is_expected.to eq false }
        end
      end

      context "#valid_iyr?" do
      end

      context "#valid_hgt?" do
        subject { described_class.valid_hgt?(value) }

        context "good" do
          let(:value) { "190cm" }
          it { is_expected.to eq true }
        end

        context "no units" do
          let(:value) { "190" }
          it { is_expected.to eq false }
        end

        context "out of range" do
          let(:value) { "190in" }
          it { is_expected.to eq false }
        end
      end
    end

    context "#valid?" do
      subject { instance.valid?(part1: part1) }

      context "valid examples" do
        let(:part1) { false }
        shared_examples_for 'valid passport' do |text|
          let(:instance) { described_class.new(text) }
          it { is_expected.to eq true }
        end

        valid_examples = [
          "pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980 hcl:#623a2f",
          "eyr:2029 ecl:blu cid:129 byr:1989 iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm",
          "hcl:#888785 hgt:164cm byr:2001 iyr:2015 cid:88 pid:545766238 ecl:hzl eyr:2022",
          "iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719",
        ]

        valid_examples.each do |ex|
          it_behaves_like 'valid passport', ex
        end
      end

      context "invalid examples" do
        let(:part1) { false }
        shared_examples_for 'invalid passport' do |text|
          let(:instance) { described_class.new(text) }
          it { is_expected.to eq false }
        end

        invalid_examples = [
          "eyr:1972 cid:100 hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926",
          "iyr:2019 hcl:#602927 eyr:1967 hgt:170cm ecl:grn pid:012533040 byr:1946",
          "hcl:dab227 iyr:2012 ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277",
          "hgt:59cm ecl:zzz eyr:2038 hcl:74454a iyr:2023 pid:3556412378 byr:2007",
        ]

        invalid_examples.each do |ex|
          it_behaves_like 'invalid passport', ex
        end
      end
    end
  end
end
