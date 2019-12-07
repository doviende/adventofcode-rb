
require_relative "../p7.rb"

describe "2019 p7" do
  context "run_with_phases" do
    $stderr.reopen("/dev/null")
    let(:example1) do
      { input: "3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0".split(",").map(&:to_i),
        answer: 43210,
        answer_phases: [4,3,2,1,0] }
    end
    let(:example2) do
      { input: "3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0".split(",").map(&:to_i),
        answer: 54321,
        answer_phases: [0,1,2,3,4] }
    end
    let(:example3) do
      { input: "3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,
1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0".split(",").map(&:to_i),
        answer: 65210,
        answer_phases: [1,0,4,3,2] }
    end

    shared_examples :phase_example do
      let(:example) { nil }
      it 'finds #{example[:answer]} given phases #{example[:answer_phases]}' do
        expect(run_with_phases(example[:input], example[:answer_phases])).to eq example[:answer]
      end
      
      it 'finds #{example[:answer]} from all phases' do
        expect(run_all_phases(example[:input])).to eq example[:answer]
      end
    end

    it_behaves_like :phase_example do
      let(:example) { example1 }
    end
    
    it_behaves_like :phase_example do
      let(:example) { example2 }
    end
    
    it_behaves_like :phase_example do
      let(:example) { example3 }
    end
  end    
end
