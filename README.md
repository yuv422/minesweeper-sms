# Minesweeper v1.1

![Minesweeper SMS](images/Minesweeper-SMS.png)

My entry into the sms power 2014 coding competition.

This is my take on the classic computer game Minesweeper for the sega master
system.

## Controls

 * Button 1 - uncover a tile
 * Button 2 - mark a tile with either a flag or a question mark
 * Pause    - toggle music

The aim of the game is to find all the bomb tiles by uncovering non-bomb
tiles on the board. If you accidentally uncover a bomb then you lose.
The number on the uncovered tiles tell you how many bombs surround the
tile.
You can select from three different boardsizes.


## Credits

 * Code + gfx: Eric Fry (efry)
 * Music:      Niloct

## Software used

* Grafx2
* Gimp
* Bmp2tile
* Mod2PSG
* WLA-DX
* Vim

## Tools

Master everdrive USB (for testing on my master system 2)

## Utils

I've included my unix usb-loader code for the master everdrive. I needed this
as I develop on Mac OS X and the everdrive only comes with windows drivers. :(

I've also included my vim syntax highlighting file. It's based on Maxim's
ConTEXT highlighter.

## Todo

* Win / Lose animations + bomb sfx.
* Key repeat.

Thanks to www.smspower.org for providing a great resource to the sega 8bit
community.

Source is included please be kind. ;)

(c) 2014 Eric Fry 2014-03-27
