# AdventOfCode2023
 Code solutions for the 2023 Advent of Code

## Starting Off

This year's AoC has started off with a stumble. I had thought I was prepared because I'd updated my support libraries in Perl, PHP and Python (for variety) and I even had a Swift project ready for visualization. I'd written unit test cases for all of them. But then on Black Friday I bought an iPad Pro and I decided my challenge for this year was to use Swift Playgrounds. I quickly refactored and wrote unit tests for my Swift libraries, and adapted my SwiftUI running app to work on the iPad.

![AoC Runner App on iPad](https://github.com/sbiickert/AdventOfCode2023/blob/main/Support/swift_aoc_runner.png)

But then I was hung over from the Xmas party on Nov. 30th, and I had to travel to help move my Dad into a care home on Dec. 1. Plus, Day 1 was much trickier to solve than a normal Day 1. I was hoping to ease into the new environment and updated language (Swift now has full support for Regex) but it didn't turn out that way. I was tempted to chuck it and go with Perl, but I had to choose whether or not to take my MacBook on the trip or my iPad. I chose the iPad and that forced me to stick with Playgrounds. It got better, and now I've got eight stars.

## Nine Days In

It's been commented on in Reddit, but this year's difficulty curve is very erratic and unpredictable. Days 1, 3 and 5 were tough, and I had to resort to my MacBook on Day 5. The second part of the challenge has a smart solution (I'm sure of it) but it also could be brute-forced. On the Mac, I could use [GCD](https://en.wikipedia.org/wiki/Grand_Central_Dispatch) and a release compile to accelerate the task. It was fun to watch all 10 cores on my M2 Pro light up. And yet today, they gave you the algorithm in the puzzle description. ¯\_(ツ)_/¯ 

I haven't done much "re-coding" in alternate languages. With the travel and early difficulty, it's only been the last couple of days that I've finished early.

## Running into Issues

One way to see how the iPad journey is going is to look at what days I've added my solution to the Xcode project. As things have gotten more difficult, I've had to fall back on the pro developer tools.
- Having access to a debugger. Print statements work to a point, but stepping through code can give insight when things go wrong.
- Having access to a profiler. Even Perl has NYTProf. Understanding where performance problems lie doesn't usually make the difference between success and failure in AoC, but it can make the difference between fast and poky.
- Quick build-run loop. One of the big frustrations of Swift Playgrounds to build an app is the time it takes to run and test, especially if you want to see console output. Too many clicks and a tiny tap target. In Xcode it's Command-R and done.

That having been said, all days except 5 part 2 run on the iPad.