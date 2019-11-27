require_relative "../p3_1.rb"
require 'easy_tests'

describe 'double coverage' do
  tile_list = [
    "#1 @ 1,3: 4x4",
    "#2 @ 3,1: 4x4",
    "#3 @ 5,5: 2x2"
  ]
  examples = [
    { args: [tile_list], answer: 4 },
  ]

  it_behaves_like 'easy test', :double_covered, examples
end
