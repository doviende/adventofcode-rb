#!/usr/bin/env ruby

# if you are greater than the X of all points and you increase X, you can't
# change which one you are closest to, so your current group is infinite.

# i think if we find the global X boundaries and global Y boundaries, and trace them out and calculate
# which group everything is in along that perimeter, then exactly all of those are the infinite ones.

def manh(p1, p2)
  (p1[0] - p2[0]).abs + (p1[1] - p2[1]).abs
end

if __FILE__ == $0
  points_list = DATA.readlines.map(&:chomp).map { |p| p.split(', ').map(&:to_i) }
  xes = points_list.map { |x, y| x }
  xmin = xes.min
  xmax = xes.max
  yes = points_list.map { |x, y| y }
  ymin = yes.min
  ymax = yes.max

  closest = {}
  (xmin .. xmax).each do |x|
    (ymin .. ymax).each do |y|
      # for each interior or perimeter point, find point it is closest to
      points_list.each do |po|
        cl = closest[[x,y]]
        if cl.nil? || (manh([x,y], po) < manh([x,y], cl))
          closest[[x,y]] = po
        elsif manh([x,y], po) == manh([x,y], cl)
          closest[[x,y]] = cl + po  # doesn't affect other math, but is noticably bigger for later
        end
      end
    end
  end
  # closest now has a value for all the interior points, so we add them up
  # but ignore points from that are closest to the perimeter
  ignore = []
  (xmin .. xmax).each do |x|
    ignore << closest[[x, ymin]]
    ignore << closest[[x, ymax]]
  end
  (ymin .. ymax).each do |y|
    ignore << closest[[xmin, y]]
    ignore << closest[[xmax, y]]
  end
  ignore = ignore.uniq
  answer = closest.reject { |k,v| v.size > 2 || ignore.include?(v) }.values.group_by(&:itself).map { |k,v| v.size }.max
  puts "part 1: #{answer}"

  # part 2
  
end


__END__
268, 273
211, 325
320, 225
320, 207
109, 222
267, 283
119, 70
138, 277
202, 177
251, 233
305, 107
230, 279
243, 137
74, 109
56, 106
258, 97
248, 346
71, 199
332, 215
208, 292
154, 80
74, 256
325, 305
174, 133
148, 51
112, 71
243, 202
136, 237
227, 90
191, 145
345, 133
340, 299
322, 256
86, 323
341, 310
342, 221
50, 172
284, 160
267, 142
244, 153
131, 147
245, 323
42, 241
90, 207
245, 167
335, 106
299, 158
181, 186
349, 286
327, 108
