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

## And It's Over

I finished the last puzzle this evening... on the Mac. To be fair, every day started on the iPad, and all of the code runs on it (except the aforementioned multithreaded brute force), but as the challenges got harder and debugging became more critical and nuanced, using the iPad was... frustrating. It had no interactive debugger, but it also made it painful to use the console. 

I did last year's Advent in Perl, where I didn't have access to an interactive debugger, but then I could run the code from BBEdit as fast as I could hit Command-R and Data::Dumper made quickly reviewing variable contents easy. In Swift Playgrounds, I would have to hit the start button, wait (sometimes through multiple startup crashes) for my SwiftUI screen to show, then tap the day, tap the input and then tap solve. Then I had to tap the tiny orange lozenge shape in the upper right, tap "Show Console", tap to dismiss the dialog, then tap the little console button to actually show the console. And then the output to the console was only as rich as I programmed in. Using the actual "playground"  instead of an app would make it easier to work with, I think. I did a Swift playground in Xcode in 2020, and ran into a lot of the same problems, plus slowness.

I don't think I would do this again, not until Swift Playgrounds on iPad improves. Other possibilities:
- [GitHub Codespaces](https://github.com/features/codespaces) or [Visual Studio Code Server](https://code.visualstudio.com/docs/remote/vscode-server) as remote sessions driven by the iPad
- [Pythonista](https://apps.apple.com/us/app/pythonista-3/id1085978097) or [Pyto](https://apps.apple.com/us/app/pyto-python-3/id1436650069) to do Python.

## What Did I Learn This Year?

I immediately recognized when modular math (Chinese remainder theorem/LCM) was the right answer. In years past, I've had to go to Reddit to figure that out. I also learned how to use Swift Regex, at least at a basic level. I didn't use any of the fancy "builder" code, just inline regex like I'd use in Perl. 
