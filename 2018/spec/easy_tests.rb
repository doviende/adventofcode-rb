
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
