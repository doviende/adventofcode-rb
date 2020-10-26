
shared_examples "easy test" do |function, example_array|
  let(:klass) { Object }
  context "#{function}" do
    example_array.each do |dict|
      context "example args: #{dict[:args]}" do
        let(:example_args) { Array(dict[:args]) }
        let(:answer) { dict[:answer] }
        subject { klass.send(function, *example_args) }
        it "equals #{dict[:answer]}" do
          expect(subject).to eq answer
        end
      end
    end
  end
end


shared_examples "easy test instance" do |function, example_array|
  let(:klass) { nil }
  # example array has possible keys of:
  #   init: args for creating an instance
  #   args: args for calling function on the instance
  #   answer: the expected result of that call

  context "#{function}" do
    example_array.each do |dict|
      context ".new(#{Array(dict[:init]).join(", ")}).#{function}(#{Array(dict[:args]).join(", ")})" do
        let(:example_args) { Array(dict[:args]) }
        let(:init_args) { Array(dict[:init]) }
        let(:answer) { dict[:answer] }
        let(:instance) { klass.new(*init_args) }
        subject { instance.send(function, *example_args) }
        it "equals #{dict[:answer]}" do
          expect(subject).to eq answer
        end
      end
    end
  end
end
