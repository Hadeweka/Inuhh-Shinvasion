# Inuhh-Shinvasion
This game is a jump'n'run about a dog. No plumber, no penguin, no hedgehog. A dog.

## Story

The protagonist is Inuhh, a dog, whose world got invaded by a weird alien race, called "Shi". His goal is, of course, to defeat the Shi empire. This would be easy if the Shi weren't masters of genetics and produced a huge number of variations of themselves. Some have spikes, others are much faster than normal ones, and some are even gigantic. If Inuhh travels through the five worlds of Westton, he may have a chance to expel the Shi from there.

## Instructions and informations

Current version of the game: 1.1.0 (in development)

### I am on Windows and lazy

Download this repository using the green Clone/Download button as a zip file and extract it to any place you want.

Then just exectute "Inuhh Shinvasion.exe", be happy and submit any bugs to me ;-)

### I'd rather install everything manually

The game is written in Ruby and programmed using the Gosu library. Use [Ruby Installer](https://rubyinstaller.org/downloads/) on Windows and make sure to use Ruby Version 2.0 or preferably newer.

Download this repository using the green Clone/Download button as a zip file and extract it to any place you want.

Execute then the file "Setup.rb" from the folder to install the required Ruby Gems Gosu and Mathn. If you REALLY like to install things manually, install the two gems using "gem install gosu" and "gem install mathn". If you are not on Windows, use https://www.libgosu.org/ for an instruction to install Gosu.

The game itself can be started by using "ruby Inuhh.rb" in a terminal or by executing "Inuhh Shinvasion.rbw" on Windows.

## What else?

Don't expect any music besides some jingles. This game has none. And this is because ~~this game is an experimental avantgarde game which will leave your imagination with the task of creating background music~~ I have no talent and was too lazy to search for free music.

Also despite this game being fully playable, I may add some features in the future, if I have the time and motivation to do so. Also I will of course try to fix any bugs as soon as possible.

## Controls:

* Move Inuhh left: **Left** / **A**
* Move Inuhh right: **Right** / **D**
* Jump: **Up** / **W**
* Run: **Ctrl** / **Shift**
* Use items: **Space**
* (Overworld) Toggle HUD: **Space**
* Read signs, close dialogs: **Return**
* (Overworld) Enter level: **Return**
* Pause: **P**
* Display information about current item: **F1**
* Give up level: **Escape**
* (Overworld) Trade gems for lifes: **1**-**5**

## What can you do in Inuhh Shinvasion?

Inuhh Shinvasion is a game containing many secrets and missions. If you complete one mission and open the "Achievements" menu on the starting screen, you'll see a golden embleme before the criterion you managed to beat, for example beating all levels in the game. Try to get all achievements to make everyone jealous!

## What are Shi Coins?

In Inuhh Shinvasion several special coins, called Shi Coins, can be found at hidden places. At a certain place it is possible to trade them for helpful things, which may help out in the later game (the game is still possible to beat without them, albeit at a much higher difficulty), so try to find as many as possible of them. In each level segment at least one Shi Coin can be found. Maybe you can even find some other rare objects!

## What is the Shipedia?

Another program included is the so called Shipedia, in which you can find detailed information about every enemy in the game. However, you need to type in passwords you can obtain on certain points in the game, to gain access to all information.

### Shipedia Controls:

* Complete name: **Tab**
* Enter command or name: **Return**
* Leave enemy information: **Escape**
* Scroll: **Mouse Wheel**

### Shipedia Commands:

* *SORT* [PROPERTY]: Sorts enemies by the given property
* *DIFF* [DIFFICULTY]: Sets the given difficulty as base for the enemy properties

### Shipedia Sorting Properties:

* *NAME*: Name of the enemy
* *STRENGTH*: Strength of the enemy
* *DEFENSE*: Defense of the enemy
* *HP*: Health points of the enemy
* *SPEED*: Speed of the enemy
* *WORLD*: The world in which the enemy can be encountered first
* *SCORE*: The base score of the enemy
* *SIZE*: The size of the enemy

### Shipedia Difficulties:
* *EASY*
* *NORMAL*
* *HARD*
* *DOOM*
