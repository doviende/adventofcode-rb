#!/usr/bin/env ruby

# part 1
def score(list)
  # score is the number of 1-differences (starting from 0) times
  # the number of 3-differences, with one more 3-difference on the end.
  list.sort!
  list = [0] + list + [list.last + 3]
  onediffs = 0
  threediffs = 0
  list.each_cons(2) do |a, b|
    diff = b - a
    if diff == 1
      onediffs += 1
    elsif diff == 3
      threediffs += 1
    end
  end
  onediffs * threediffs
end

if __FILE__ == $0
  lines = DATA.readlines(chomp: true).map(&:to_i)
  part1 = score(lines)
  puts "part 1 score is #{part1}"
end

__END__
17
110
146
144
70
57
124
121
134
12
135
120
19
92
6
103
46
56
93
65
14
31
63
41
131
60
73
83
71
37
85
79
13
7
109
24
94
2
30
3
27
77
91
106
123
128
35
26
112
55
97
21
100
88
113
117
25
82
129
66
11
116
64
78
38
99
130
84
98
72
50
36
54
8
34
20
127
1
137
143
76
69
111
136
53
43
140
145
49
122
18
42
