
require_relative "../p5.rb"

describe "2018 p5" do
  context "react?" do
    context "same letter" do
      it "not if same" do
        expect(react?("X", "X")).to be false
        expect(react?("x", "x")).to be false
      end
      
      it "true in success case" do
        expect(react?("a", "A")).to be true
        expect(react?("A", "a")).to be true
      end
    end

    it "not if different letters" do
      expect(react?("a", "B")).to be false
      expect(react?("A", "b")).to be false
      expect(react?("A", "B")).to be false
      expect(react?("a", "b")).to be false
    end
  end

  context "do_react" do
    $stderr.reopen("/dev/null")
    shared_examples :reacting do
      let(:example) { nil }
      let(:answer) { nil }

      it "matches" do
        expect(do_react(example.chars)*'').to eq answer
      end
    end
    
    it_behaves_like :reacting do
      let(:example) { "dabAcCaCBAcCcaDA" }
      let(:answer) { "dabCBAcaDA" }
    end

    [
      ["aA", ""],
      ["abBA", ""],
      ["abBa", "aa"],
      ["aabAAB", "aabAAB"],
      ["sSSsIUusSoOFfXxVvqQeETOpPotiYCclLaaAVvAoOHhPmMGvVgpCchvVtTJjxEetTPpRrXyYyuUvVEeYyfFYHZzontTNbBOt",
       "Yt"],
      ["DheEMNnmeQqEHdgtIiyYQdDorRNnhHDdWwjJdQcCGgGgqQqXxqQUhHudNnDNnVGgNDuUUumMdnfDOxXodmMiIFcaACtTyYoJjYyUuOkbBgGVKlLw",
       "gtQodVkVKw"],
      ["czYyZQMzZmSsBbqCUufFrrREeKkXxAqQMmardDIiVRcCXxrvmMQeEqVFzZfvEeRRaApPSsuqNnQIiipPkKIYyrIiRqQKkp",
       "up"],
    ].each do |q,a|
      it_behaves_like :reacting do
        let(:example) { q }
        let(:answer) { a }
      end
    end
  end
end
