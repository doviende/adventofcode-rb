require_relative "../p3_1.rb"
require 'easy_tests'

describe 'double coverage' do
  tile_list = [
    "#1 @ 1,3: 4x4",
    "#2 @ 3,1: 4x4",
    "#3 @ 5,5: 2x2"
  ]
  examples = [
    { args: [tile_list], answer: [4, 3] },
  ]
  parse_examples = [
    { args: tile_list[0], answer: [1, 1, 3, 4, 4] },
    { args: tile_list[1], answer: [2, 3, 1, 4, 4] }
  ]

  it_behaves_like 'easy test', :main, examples
  it_behaves_like 'easy test', :parse_string, parse_examples do
    let(:klass) { Sector }
  end
end
