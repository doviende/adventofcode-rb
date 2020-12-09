#!/usr/bin/env ruby
require 'pry-byebug'

class SequenceValidatorBase
  def initialize(preamble)
    @width = preamble.size
    @buffer = preamble # the set of numbers currently
    @possible_sums = {} # how many different ways are there to sum to this key? when 0, remove
  end

  def calculate
  end

  def valid_next?(value)
    !@possible_sums[value].nil?
  end

  def append(value)
    removed = @buffer.shift
    yield removed if block_given?
    @buffer.push(value)
    calculate
  end
end

class N2SequenceValidator < SequenceValidatorBase
  def calculate
    @buffer.each do |x|
      @buffer.each do |y|
        @possible_sums[x+y] ||= 1
      end
    end
    self
  end
end

class ContiguousFinder
  def initialize(sequence)
    @buffer = sequence
    @first = 0
    @last = 1
  end

  def find(goal)
    loop do
      sum = @buffer[@first..@last].sum
      return answer if sum == goal

      if sum < goal
        @last += 1
      else
        @first += 1
      end
    end
  end

  private

  def answer
    slice = @buffer[@first..@last].sort
    slice.first + slice.last
  end
end

if __FILE__ == $0
  lines = DATA.readlines(chomp: true).map(&:to_i).freeze
  preamble = []
  copy = lines.dup
  25.times do |i|
    preamble.push(copy.shift)
  end
  validator = N2SequenceValidator.new(preamble).calculate
  part1 = copy.each do |item|
    break item unless validator.valid_next?(item)

    validator.append(item)
  end
  puts "part 1: first item that isn't a sum of the previous 25 numbers is #{part1}"

  finder = ContiguousFinder.new(lines)
  part2 = finder.find(part1)
  puts "part 2: the sum of the smallest and biggest of a contiguous block adding to #{part1} is #{part2}"
end

__END__
19
20
22
10
11
29
4
41
38
46
7
2
49
26
48
6
47
42
18
40
43
45
14
30
8
55
9
12
54
10
69
11
57
13
15
32
21
53
20
16
17
19
36
22
34
23
77
18
24
25
47
26
51
39
54
29
27
49
28
62
73
33
42
41
70
40
37
43
58
44
82
45
83
55
52
84
53
56
99
57
80
119
61
65
74
122
75
110
77
81
85
87
88
144
89
106
97
105
107
108
180
113
164
118
126
136
135
138
139
155
152
156
158
162
166
200
175
177
186
194
215
202
212
225
226
231
282
326
244
277
271
273
290
291
307
548
564
377
328
341
352
361
398
380
396
414
639
438
475
470
1203
515
567
916
544
561
563
581
619
689
669
873
680
724
852
750
1404
776
810
957
884
908
913
945
1182
1560
1317
1105
1107
1797
1124
1144
1200
1288
1393
1349
1456
1862
1474
1526
2231
1586
1694
1718
1792
1858
2057
3720
2306
2212
2344
2229
2537
3632
2324
2268
2549
2488
3517
3580
2805
4499
3168
3000
3112
3280
3304
3412
5268
3650
4202
4269
4480
4441
4497
4553
6109
5354
4592
4812
4756
5549
5293
5805
7777
6112
6280
6168
7062
6416
11463
6716
10609
9292
7919
9365
8710
8921
8938
10105
10842
13174
9348
10397
14057
10049
11098
12521
11917
12280
12884
12448
23726
13132
21093
23571
14635
17267
21645
18759
27469
18058
31039
37574
28109
44819
19745
21147
21966
22329
49114
23015
24197
24728
38360
36645
25580
27767
30399
47057
31902
53547
35325
36817
37803
39205
40387
41711
40892
42074
45325
49777
46694
48595
54231
48925
47212
50308
52495
55979
53347
72142
88104
82210
68719
79114
93734
73128
74620
118319
79592
81279
89487
135557
95619
92019
96989
170766
108474
96137
99707
97520
102803
168747
109326
122066
143339
198813
141847
185753
147748
243894
152720
154212
217685
169079
173298
186476
187638
200493
188156
244737
197227
205463
289595
200323
285676
320879
231392
310222
342340
402690
310926
294567
300468
301960
306932
321799
341850
623759
611394
359774
374114
375794
388649
405786
397550
428619
603013
707746
542318
517068
553191
595035
663649
596527
1148226
715964
681573
648782
661734
1128462
701624
730499
1008799
1077401
779900
749908
764443
981810
803336
1258684
970937
1059386
1394148
1113595
1070259
1201973
1191562
1446463
1245309
1990609
1343307
1383197
1310516
1411642
1432123
1893186
1862722
2648436
1514351
1544343
1878038
1746253
2481901
1994898
3595496
2030323
2315568
2261821
3325309
2516722
2393535
2436871
2555825
2759660
2653823
2693713
2722158
2925993
2843765
2946474
3058694
3260604
3392389
3996252
3290596
3624291
5502299
5497588
4025221
4292144
4345891
5159029
9126590
4830406
5087248
5209648
4992696
5249538
5347536
6237070
5415871
5565923
10296896
5790239
8317365
9155281
9176297
7620543
6914887
8792895
9122550
8638035
8371112
8855627
9284840
12613239
9917654
18411430
10815461
10242234
10202344
10340232
18010908
19072935
10981794
17915445
15552922
12705126
13410782
15285999
29888396
14535430
17164007
15707782
17009147
27295748
18711344
18573456
18140467
19202494
20119998
25528233
20444578
22907470
20542576
24737774
28258048
31101792
29555250
23686920
30838921
41081155
55553796
27946212
40564576
30243212
33246774
38831342
32716929
44730727
43668700
36713923
43352048
39647072
39745070
49215153
40987154
43450046
61451697
48488788
48424694
51633132
53242170
53930132
88399427
72461999
62960141
58189424
83916624
63489986
76598822
87020748
69430852
96363859
76360995
77701077
100057826
80634226
119811041
153096225
84437200
128231954
178000465
106678212
96913482
101666864
104875302
122673022
126392131
121149565
181350682
249065153
121679410
132920838
312555139
203042071
254624085
435228161
414222003
180692052
158335303
331096690
165071426
186104064
189312502
266738290
198580346
201788784
243822587
254070403
206542166
438947270
248071541
242828975
254600248
322233340
532885474
366796116
291256141
339027355
799623764
419141829
344439367
323406729
345763478
347647805
433135089
351175490
508670651
387892848
602248053
581856330
408330950
751499626
449371141
529948895
502671789
662434084
497429223
599039615
671054534
875466767
614662870
630283496
667846096
905263059
827472779
1270094149
556543474
1079285553
698823295
853847279
837263989
796223798
857702091
1484130775
905760173
911002739
1378138556
1324837908
1525548187
1053972697
1127712719
1408431962
1155583089
2182954070
1171206344
1186826970
1224389570
1255366769
2303675123
1964976708
2604833740
2061653559
1536087284
1694966080
1633487787
1653925889
2564928628
1763462264
2605968819
2235840647
1964975436
2278362267
3791660710
2181685416
2209555786
2919355650
2326789433
2342410059
2358033314
4340015826
3529237029
2479756339
2791454053
3695141346
3169575071
3190013173
3231053364
4021755513
5196028800
3287413676
3417388153
5548046487
6134070769
4417526063
4620772326
4146660852
4567589100
4391241202
4508474849
4536345219
9939287689
4669199492
4700443373
4837789653
5271210392
6946625182
6421066537
15487334176
6885154519
6359588244
9369642865
6518467040
12878055284
6704801829
9421484445
7564049005
8537902054
8564186915
8655135701
8714249952
9807555611
8927586421
9044820068
13985115542
9205544711
9506989145
9538233026
11258856190
10109000045
13223268869
12780654781
17679922727
13589956348
18907875891
14897490298
15419051781
16126286274
14268850834
15242703883
16128235920
16101951059
17193037755
17219322616
17369385653
18221239097
22761501895
21825474849
31363707875
18712533856
20464400901
25006490343
24848812538
22889654826
23698956393
26003923650
26370611129
28832660231
27858807182
29511554717
40130887548
29687902615
39117663372
36592636821
31344654942
33321273675
33294988814
34412360371
34588708269
45228192835
36933772953
55146748524
39176934757
41602188682
42411490249
43354055727
54536715153
46588611219
48893578476
59203462124
57348578592
55203271360
57370361899
62806543531
59199457332
61032557557
116548035924
79946692548
64639643756
77933266161
67707349185
67883697083
77000198518
125672201313
103430293629
139146149880
80779123439
81588425006
145640615346
85765545976
102553513059
101125326372
106263940375
104096849836
112551849952
118402919456
114402728692
116569819231
180435547035
120232014889
245075190791
132346992941
365307205680
145816963244
135591046268
248370476303
248142896220
183332636498
162367548445
227229040352
181904449811
166544669415
182713751378
186890872348
241854986643
203678839431
205222176208
230972547923
294714541386
226954578644
234972738687
248916812172
384114386466
252579007830
255823061157
345081299823
267938039209
281408009512
388554812706
297958594713
328912217860
511625969238
414119912700
344271998256
348449119226
349258420793
508362588156
498393380817
390569711779
408901015639
432176754852
436194724131
457927126567
475871390816
461927317331
502910777896
501495820002
684755762682
641133820536
673993517683
1098875675382
565896633922
825129811609
1196381731920
642230592969
673184216116
1109378940247
1174680036118
734841710035
739018831005
807185547360
1074407347821
799470727418
956466345701
1050034836175
868371478983
1414393472268
919854443898
1269112864691
1237752487931
1207030454458
1067392453924
1208127226891
2007597954309
2336505318615
1239080850038
1300738343957
1606656274778
1315414809085
1377072303004
1691308055736
1473860541040
1658873274903
2117427290099
1824837824684
1755937073119
4125025244408
1719325171316
2023858799625
1788225922881
2508865570848
2578727718801
1987246897822
2616153153042
2274422908382
2415157681349
2996353149772
2447208076929
2539819193995
3356508140137
4862365758278
6741178397450
2692487112089
2789275350125
4141286089724
3132733815943
3262086463921
3447099197784
4298052890117
3812084722506
4411812283405
3507551094197
3706572069138
3775472820703
4062648831263
4983600047594
9188386474379
4261669806204
4689580589731
4814242102377
4954976875344
7274019905667
7847858158862
5232306306084
5954573576010
6296826444322
5481762462214
5825220928032
7769220900401
6394820279864
7037559284624
6709185661705
8501665312237
9769218977721
7214123163335
7283023914900
9216646681548
7482044889841
11049492726370
12465644937435
13570846349989
15001525283805
12122047372354
12220041207896
14311579190291
21396345563669
11186879882094
10714068768298
11306983390246
11778588906536
12190948123919
11876582742078
21645801719799
16499670596448
13104005941569
15715788475572
13923308825040
14497147078235
17052242892621
14696168053176
14765068804741
16698691571389
18196113658139
21763561494668
25294954065488
21900948650392
22021052158544
23429030762600
29802697512958
22492657674834
22493863272340
22905016892217
33799641065080
23085572296782
23655171648614
33750934464010
24980588683647
27601153019804
27027314766609
27800173994745
28420455903275
28619476878216
29193315131411
29461236857917
31394859624565
31463760376130
34894805229528
40097062308531
47473246358481
43922000808936
61551108458755
45106624455326
44986520947174
45397674567051
45398880164557
56220629898020
55050031273179
46740743945396
48635760332261
88800965737189
52007903450256
52581741703451
77829075463672
54827488761354
57039932781491
135541709682585
57812792009627
