
require_relative "../p6"

describe "2019 p6" do
  context "example 1" do
    let (:example_list) { "COM)B
B)C
C)D
D)E
E)F
B)G
G)H
D)I
E)J
J)K
K)L" }
    let (:tree) { Tree.new(example_list.split("\n").map { |x| x.chomp.split(")") } ) }
    it 'is 42' do
      expect(tree.sum_of_depths).to eq 42
    end
  end
end
     
