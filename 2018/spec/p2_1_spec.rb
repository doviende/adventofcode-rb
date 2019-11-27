
require_relative "../p2_1.rb"
require 'easy_tests'

describe 'letter_counts' do
  examples = 
  [
    { args: "abcdef", answer: [0, 0] },
    { args: "bababc", answer: [1, 1] },
    { args: "aabcdd", answer: [1, 0] }
  ]

  it_behaves_like 'easy test', :letter_counts, examples
end

describe 'list_checksum' do
  examples = [
    { args: [["abcdef", "bababc", "aabcdd", "aaabcd", "abbbcd"]], answer: 2*3 },
  ]
  

  it_behaves_like 'easy test', :list_checksum, examples
end
