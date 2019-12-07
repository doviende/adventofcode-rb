
require_relative "../p7.rb"

describe "2019 p7" do
  $stderr.reopen("/dev/null")
    
  shared_examples :phase_example do
    let(:example) { nil }
    let(:feedback) { false }
    let(:all_func) do
      if feedback
        :run_feedback_phases
      else
        :run_all_phases
      end
    end
    it 'finds #{example[:answer]} given phases #{example[:answer_phases]}' do
      expect(run_with_phases(example[:input], example[:answer_phases], feedback)).to eq example[:answer]
    end
    
    it 'finds #{example[:answer]} from all phases' do
      expect(send(all_func, example[:input])).to eq example[:answer]
    end
  end

  context "run_with_phases" do
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

  context "run_feedback_phases" do
    let(:example1) do
      { input: "3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5".split(",").map(&:to_i),
        answer: 139629729,
        answer_phases: [9,8,7,6,5] }
    end
    let(:example2) do
      { input: "3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,
-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,
53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10".split(",").map(&:to_i),
        answer: 18216,
        answer_phases: [9,7,8,5,6] }
    end

    it_behaves_like :phase_example do
      let(:example) { example1 }
      let(:feedback) { true }
    end

    it_behaves_like :phase_example do
      let(:example) { example2 }
      let(:feedback) { true }
    end
  end
end
