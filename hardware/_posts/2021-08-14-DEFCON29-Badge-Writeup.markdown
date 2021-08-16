---
layout: post
title:  "DEFCON 29 - Badge Writeup"
date:   2021-08-14 06:00:00
image: 
  path: /assets/img/hardware/defcon29-badge-writeup/Header.png
author: Ryan
---

- Table of Contents
{:toc .large-only}


DEFCON is one of the world's largest hacker conferences, taking place in Las Vegas for the past 29 years. Attendees are identified by badges, varying in types like Human, Goon, Creator, Speaker, Artist, Vendor, and Press. These badges allow a wearer admission to the con and, in recent years, can eclipse talks and villages with unique and challenging puzzles.

## Badge Walk-through
This year's badge was the first from creators MK Factor, who did an amazing job of bridging the gap between the in-person and virtual attendees. With multiple ways to connect and sync with other badges, everyone was able to play along and get the most from their DEFCON Badge experience.

The badge consisted of stacked boards hosting four RGB keys, three touch sensors, male/female connectors on the sides, USB-A and USB-C ports on the bottom, and a special lanyard cable with USB-A and USB-C plugs on the ends. The badge could be powered by battery, or either of the USB ports. Powering on the badge while holding down the top-left key would start a game of Simon Says, with multiplayer scaled to any other badges connected. Connecting the badge to a phone or laptop resulted in a console with a player's Simon Says stats and badge challenge progression.

![Badge Front](/assets/img/hardware/defcon29-badge-writeup/Badge_Front.jpg)

![Badge Back](/assets/img/hardware/defcon29-badge-writeup/Badge_Back.jpg)

![Lanyard](/assets/img/hardware/defcon29-badge-writeup/Lanyard.jpg)


### Gotta Catch Them All
We were first tasked with collecting each of the other badge types by connecting via ports on the sides of the badge, the lanyard USB cable, or token generated in the badge console. With DEFCON not officially starting until Friday, it was difficult to find many badge types outside of Human, Goon, and Creator in-person. Luckily the Discord server was very active and a great place to find others looking to share tokens.

![Token Generation](/assets/img/hardware/defcon29-badge-writeup/TokenRequest.png)

### Can't Stop The Signal
Upon collecting each of the badge types, we were presented with a [link](https://defcon.org/signal/GottaCatchThemAll/) to our next task in the badge console.

![Gotta Catch Them All](/assets/img/hardware/defcon29-badge-writeup/GottaCatchThemAll.png)

Tying nicely into this year's DEFCON theme "Can't Stop The Signal", we were essentially spreading a worm across badges unlocking additional types and signals for other players.

![Signals Shared](/assets/img/hardware/defcon29-badge-writeup/SignalsShared.png)

### Taking The Red Pill
Following our newest clue from the badge console, we're given a [familiar choice](https://defcon.org/signal/WhatIfIToldYou/):

![What If I Told You](/assets/img/hardware/defcon29-badge-writeup/WhatIfIToldYou.png)

With nothing of use in the HTML, we take a look at the badge for anything that stands out.

![RED](/assets/img/hardware/defcon29-badge-writeup/RED.png)

Four rows of six bits, what if we try to read them?

`00000010 11110110 10100100`  

�� doesn't seem like a very good answer...

What if we try top to bottom instead of left to right?

`01010010 01100101 01100100`  

Red

Next to this area of the badge is a small pad on the board. Taking a set of small metal tweezers, we're able to scratch off the metal and "Disconnect" with the Red pill.

![Taking The Red Pill](/assets/img/hardware/defcon29-badge-writeup/TakingTheRedPill.jpg)

### Our Journey Begins
Reconnecting the badge to the console reveals a new URL to follow. This [puzzle](https://defcon.org/signal/YourJourneyBegins/) appears to be a cipher, and according to the HTML, "It's the simple things in life", and "It's too easy". One of the simplest ciphers to learn about is ROT13, which shifts letters of the alphabet by 13 characters.

![ROT13](/assets/img/hardware/defcon29-badge-writeup/ROT13.png)  

Passing our cipher through ROT13:  
```
Pynffvp pelcgb vf nyjnlf sha ohg qba’g rkcrpg gurz nyy gb or guvf rnfl. /NycunorgFuvsg

Classic crypto is always fun but don’t expect them all to be this easy. /AlphabetShift
```

### Nothing Lasts Forever
The next piece of the puzzle appears to be an image of the [Las Vegas strip](https://defcon.org/signal/YourJourneyBegins/AlphabetShift/), with a clue about shifting from place to place, but never forgetting the ones we've lost.

![Ones We Lost](/assets/img/hardware/defcon29-badge-writeup/OnesWeLost.png)  

It seems like this part of the challenge relates to the places in Las Vegas that have hosted DEFCON before.

![Ones We Lost pt2](/assets/img/hardware/defcon29-badge-writeup/OnesWeLost2.png)  

If we look through the list of all the places DEFCON has been hosted at, we can start picking out the ones no longer open. This brings us to (in order of DEFCON year):

* Sands Hotel and Casino
* Sahara Hotel and Casino
* Aladdin Hotel and Casino
* Riviera Hotel and Casino

Trying out different variations of these four results the following solution and next piece to the URL:  
`SandsSaharaAladdin`

### Bet You Can't Eat Just One
Not having a lot of hardware knowledge, I was pretty worried looking at the next challenge. Based on the clue, I'd need to identify [the chip](https://defcon.org/signal/YourJourneyBegins/AlphabetShift/SandsSaharaAladdin/) used in badges two consecutive years in a row.

![MC56F8006VLC](/assets/img/hardware/defcon29-badge-writeup/MC56F8006VLC.png) 

Although I don't know much about hardware components, I do know a bit of DEFCON history that the badges weren't always electronic. Early on, badges were cards or pieces of metal, with electronic badge eventually getting added to the mix. This narrowed down the number of consecutive electronic badge years to look into.

Thanks to a detailed [presentation](http://grandideastudio.com/wp-content/uploads/history_of_defcon_electronic_badges_slides.pdf) by Joe Grand on the history of the electonic badges he's made for DEFCON, we're able to get a close look at the schematics.

![DC17 Schematics](/assets/img/hardware/defcon29-badge-writeup/DC17_Schematic.png)  
![DC18 Schematics](/assets/img/hardware/defcon29-badge-writeup/DC18_Schematic.png)  

It looks like the `MC56F8006VLC` can be found on both, and leads us to the next challenge.

### What's Your Number?
Moving onto the next challenge, we're shown an image of [Jenny](https://defcon.org/signal/YourJourneyBegins/AlphabetShift/SandsSaharaAladdin/MC56F8006VLC/) from Forrest Gump. A bit different than what we've been shown before, this image is a gif slowly changing between *two tones*.

![JennyTones](/assets/img/hardware/defcon29-badge-writeup/jennytones.gif)  

The HTML provides an additional clue we can use to lead us down the right path:  

``` html
<html>
  <head>
    <title>1 2 4</title>
  </head>
  <body bgcolor="#000000" text="FFFFFF">
    <center>
      <img src="jennytones.gif">
    </center>
    <!--  -->
  </body>
</html>
```

Searching Google for ["Jenny Tones 1 2 4"](https://www.google.com/search?q=Jenny+Tones+1+2+4) results in a wiki page for Tommy Tutone's hit song Jenny (867-5309). A further clue that we're on the right track can be seen in Tommy's [Wikipedia](https://en.wikipedia.org/wiki/Tommy_Tutone) page with the billboard chart positions for Jenny lining up with the 1, 2, and 4 clues.

![Jenny Billboard](/assets/img/hardware/defcon29-badge-writeup/JennyWiki.png) 

At one point during the con, a connector on my badge broke off and required disassembly to solder back on. I took the opportunity to take a few pictures of the insides in case they were needed later. Revisiting these photos, there's a clear Roman Numeral 3 besides the keys.

![Inside Badge Top](/assets/img/hardware/defcon29-badge-writeup/Inside_Badge_Top.jpg)  

Venturing out around the con, I was able to track down a Goon and Creator, identifying a Roman Numeral 9 and 5 in their badges respectively. Not wanting to waste time, I wrote up a quick python script to generate all permutations of the badge types and validate for the known positions.

``` python
from itertools import permutations

#0:8, 1:6, 2:7, 3:5, 4:3, 5:0, 6:9
badges = ['Human','Goon','Creator','Speaker','Artist','Vendor','Press']
for x in permutations(badges):
    if x[3] == 'Creator' and x[4] == 'Human' and x[6] == 'Goon':
        flag = ''.join(x)
        url = 'https://defcon.org/signal/YourJourneyBegins/AlphabetShift/SandsSaharaAladdin/MC56F8006VLC/'+flag
        print(url)
```

With only 24 permutations to test, I was quickly able to open them in the browser and see which was the correct order.

`VendorSpeakerArtistCreatorHumanPressGoon`

### Sorry For The Interruption
It looks like hackers have [disabled the broadcast](https://defcon.org/signal/YourJourneyBegins/AlphabetShift/SandsSaharaAladdin/MC56F8006VLC/VendorSpeakerArtistCreatorHumanPressGoon/) and it's up to us to fix it.

![Broadcast](/assets/img/hardware/defcon29-badge-writeup/Broadcast.png) 

This part was interesting, as there had been a lot of suspicion during the first challenge with the Red Pill/Blue Pill. There was a 2nd pad on the lower left corner of the board that was assumed to be the Blue pill and already appeared to be cut. Upon closer inspection, we can now see that the cut pad is a wire going to all the TVs drawn on the badge. Heading over to Hardware Hacking Village, we had all the tools needed to solder a connection back in place.

![Broadcast](/assets/img/hardware/defcon29-badge-writeup/BroadcastFixed.jpg) 

### So, You Like Ciphers?
Another [cipher](https://defcon.org/signal/YourJourneyBegins/AlphabetShift/SandsSaharaAladdin/MC56F8006VLC/VendorSpeakerArtistCreatorHumanPressGoon/WatchYourHead/) challenge, our only clue can be found in the HTML. `Ivtrarer` translates to `Vigenere` using ROT13.

``` html
<html>
  <head>
    <title>Reminiscing</title>
  </head>
  <body bgcolor="#000000" text="FFFFFF">
    <center>
      <h1>
        Zlnns jh'zj uvnuii vvr vmlpoy ivto anqc xrcgv,<br>
        xmgfr'v ssg hudx xvoagw fdcih xmg frvx.<br>
        Nv'g n vmrrzr spfes jlxmqig wlj uzbww,<br>
        xqar sitrzr vxnnz gkmsm wg'v xmg prvx.<br>
        <br>
      </h1>
    </center>
    <!-- ivtrarer -->
  </body>
</html>
```

As mentioned before, ROT13 is shifting letters of a word by 13 places in the alphabet. This is also known as a Ceasar cipher, with the key of 13. To provide another example of a Ceasar cipher, if the key was 1, `Hello` would become `Ifmmp` shifting each of the letters ahead by 1. A Vigenere cipher builds off of this by shifting text based on the letters of a keyword.

If you had the word `Vigenere`, and the key `Cipher`, you could use the following table to generate your cipher text:

![Vigenere Table](/assets/img/hardware/defcon29-badge-writeup/Vigenere_Table.jpg) 

Matching the first letter of the message on the left with the first letter of the key along the top, repeating for the second lettof of the message with the second letter of the key and so on, `Vigenere` will become `Xqvlrvtm`.

We have our cipher text and the type of cipher to use, but all we need now is the key. After lots of trial and error, we arrive at the key of `DEFCON`.

```
Zlnns jh'zj uvnuii vvr vmlpoy ivto anqc xrcgv,
xmgfr'v ssg hudx xvoagw fdcih xmg frvx.
Nv'g n vmrrzr spfes jlxmqig wlj uzbww,
xqar sitrzr vxnnz gkmsm wg'v xmg prvx.

While we've shared the signal from many spots,
there's one that stands above the rest.
It's a simple place without the slots,
some people still think it's the best.
```

The resulting message is a poem about places we've been without any slots. If we think about the layout of DEFCON, there's a lot of named areas away from the slots but none really stand out from another and it would be hard to say with is best. If we think bigger, we can revisit the list of past DEFCON locations and see if any of those stand out.

![Alexis Park](/assets/img/hardware/defcon29-badge-writeup/AlexisPark.png) 

Alexis park hosted DEFCON for a number of years and is listed as being a non-gaming alternative to the rest of Vegas. It seems to fit what we're looking for.

`AlexisPark` leads us to the next challenge.

### Once Upon A Time
This challege starts out pretty easy if you know what to look for. We've already seen ROT13, Ceasar, and Vigenere ciphers as ways to hide messages, this one looks like its been hidden in [ASCII char codes](https://defcon.org/signal/YourJourneyBegins/AlphabetShift/SandsSaharaAladdin/MC56F8006VLC/VendorSpeakerArtistCreatorHumanPressGoon/WatchYourHead/AlexisPark/). The tricky part is that the values have been provided to us in image format, which would be tedious to type out manually.

![ASCII Codes](/assets/img/hardware/defcon29-badge-writeup/ASCII.png) 

Leveraging OCR (Optical character recognition), we can extract the numbers from the image and begin working to reveal the message.

``` python
codes = [
    84,104,111,115,101,32,107,101,121,99,97,112,
    115,32,100,105,100,110,39,116,32,97,112,112,
    101,97,114,32,111,117,116,32,111,102,32,110,
    111,119,104,101,114,101,46,32,84,104,101,121,
    32,103,114,101,119,32,108,97,121,101,114,32,
    98,121,32,108,97,121,101,114,32,111,117,116,
    32,111,102,32,115,111,109,101,32,118,101,114,
    121,32,112,101,99,117,108,105,97,114,108,121,
    32,110,97,109,101,100,32,118,97,116,115,46]
flag = ''

for x in codes:
    flag+=chr(x)
print(flag)
```

`Those keycaps didn't appear out of nowhere. They grew layer by layer out of some very peculiarly named vats.`

For those who solved the badge up until this point before the opening ceremonies of DEFCON and [badge talk by MK Factor](https://www.youtube.com/watch?v=H3kdq40PY3s&t=655s), there was a very specific detail provided when talking about how they made the badge. They used seven large resin 3D printers running non-stop to create the 56,000 keycaps needed. They were named after `Snow White And The Seven Dwarfs`.

### Aliens Do Exist
The [image](https://defcon.org/signal/YourJourneyBegins/AlphabetShift/SandsSaharaAladdin/MC56F8006VLC/VendorSpeakerArtistCreatorHumanPressGoon/WatchYourHead/AlexisPark/SnowWhiteAndTheSevenDwarfs/connections.jpg) from our next challenge is a big hint towards what we need to do.

![Connections](/assets/img/hardware/defcon29-badge-writeup/Connections.jpg) 

The original meme was captured from a show in 2010, "Ancient Aliens" on the History channel starring Giorgio A. Tsoukalos. They generally poke fun at Tsoukalos' obsession with "Ancient Astronaut Theory", and feature text that puts forth a question about a well-known mystery like the Egyptian pyramids, the answer to which is always "aliens".

In our case, the tag line has been replaced by the word "Connections". Looking at the back of the badge, we can clearly see two images featuring aliens, and on closer inspection, two small pads on the board.

![Connections](/assets/img/hardware/defcon29-badge-writeup/Connections2.jpg) 

Bridging these two points with a wire reveals another path to the URL when connecting to the console. 

`ItWasTotallyAliens`

### "Encryption"
As MK Factor [correctly guessed](https://defcon.org/signal/YourJourneyBegins/AlphabetShift/SandsSaharaAladdin/MC56F8006VLC/VendorSpeakerArtistCreatorHumanPressGoon/WatchYourHead/AlexisPark/SnowWhiteAndTheSevenDwarfs/ItWasTotallyAliens/), many people did in fact dump the strings from the badge firmware looking for clues.

![Encryption](/assets/img/hardware/defcon29-badge-writeup/Encryption.png) 

We're able to move on to the next challenge with the answer: `XOR`

### Are We Having Fun Yet?
We're shown an image containing [codes](https://defcon.org/signal/YourJourneyBegins/AlphabetShift/SandsSaharaAladdin/MC56F8006VLC/VendorSpeakerArtistCreatorHumanPressGoon/WatchYourHead/AlexisPark/SnowWhiteAndTheSevenDwarfs/ItWasTotallyAliens/XOR/) similar to what's been provided below. Reverse image searching leads us to a scene from the 2004 film "National Treasure" with Nicolas Cage.

![Declaration](/assets/img/hardware/defcon29-badge-writeup/declaration.png) 

Watching [this scene](https://www.youtube.com/watch?v=YSbyB4O5hyA) tells us that what we're looking at is an Ottendorf cipher. Looking in the HTML of the page, we're provided the additional clue `Year-P-L-W-L`. Year, Page, Line, Word, Letter.


``` html
<html>
  <head>
    <title>Look... Doors!</title>
  </head>
  <body bgcolor="#000000" text="FFFFFF">
    <center>
      <img src="declaration.png">
      <h1></h1>
      20-15-40-3-7<br>
      13-42-19-7-3<br>
      23-20-16-11-5<br>
      10-3-11-6-1<br>
      24-17-15-2-4<br>
      3-10-56-3-7<br>
      18-28-33-6-2<br>
      19-2-4-7-2<br>
      15-34-104-6-2<br>
      7-3-28-9-3<br>
      26-11-21-4-1<br>
      12-26-30-8-9<br>
      17-20-14-5-1<br>
      1-4-6-13-7<br>
      20-15-2-2-1<br>
      9-1-26-4-3<br>
      11-12-58-7-1<br>
      25-28-8-6-4<br>
      14-6-17-1-1<br>
      2-5-11-10-2<br>
      13-18-27-4-1<br>
      16-29-39-2-6<br>
      21-14-10-3-4<br>
      13-42-19-7-2<br>
      10-18-69-11-2<br>
      25-6-16-6-3<br>
      20-11-23-3-3<br>
      19-18-45-6-6<br>
      23-28-49-4-1<br>
      21-2-9-14-1<br>
      12-2-15-9-3<br>
      26-8-16-4-3<br>
      11-47-6-2-2<br>
      19-8-16-1-3<br>
      23-5-17-3-8<br>
      3-17-14-6-2<br>
      18-7-50-1-5<br>
      20-23-25-3-1<br>
      24-4-7-2-2<br>
      11-28-2-1-1<br>
      22-4-15-9-1<br>
      25-17-28-2-1<br>
      16-10-12-5-7<br>
      17-2-25-18-2<br>
      21-15-8-6-8<br>
      25-37-20-3-9<br>
      18-19-3-6-1<br>
      25-17-47-5-6<br>
      3-13-52-7-4<br>
      13-28-37-1-8<br>
      25-10-5-4-1<br>
      26-65-29-1-7<br>
      11-3-8-15-3<br>
      21-20-44-1-2<br>
      18-2-17-5-2<br>
      19-19-132-2-3<br>
      15-6-4-6-4<br>
      22-11-7-6-4<br>
      27-2-45-4-2<br>
      10-5-7-3-1<br>
      25-2-11-2-2<br>
      17-29-16-1-4<br>
      21-25-22-5-1<br>
      22-9-21-1-4<br>
      20-42-25-14-1<br>
      25-35-10-3-8<br>
      27-9-4-5-1<br>
      18-30-6-5-2<br>
      11-13-22-1-4<br>
      20-32-143-3-1<br>
      3-13-52-11-1<br>
      26-3-39-1-2<br>
      19-2-5-14-1<br>
      <br>
    </center>
    <!-- Are you having fun yet? :) -->
    <!-- Year-P-L-W-L -->
  </body>
</html>
```

In the movie the key was a series of letters, but in our case, they appear to be the programs from past DEFCON years. We can find them in the [archive media share](https://media.defcon.org/). After a long and tedious decoding, a message is revealed:

```
emailthedecodedbottomboardciphertoyouhadtheanswerthewholetime@mkfactorcom

Email the decoded bottom board cipher to youhadtheanswerthewholetime@mkfactor.com
```

Going back to the pictures taken when the badge was disassebled, we can see what cipher they're refering to:

![Inside Badge Bottom](/assets/img/hardware/defcon29-badge-writeup/Inside_Badge_Bottom.jpg) 

Retrying the cipher's we've already seen, we get lucky on the reuse of Vigenere and DEFCON key:

```
zi fts gki xkuadp

We Are The Signal
```

![Badge_Complete](/assets/img/hardware/defcon29-badge-writeup/Badge_Complete.jpg) 

What an amazing badge and just a ton of fun to play. Thank you, MK Factor, and looking forward to next year's badge.