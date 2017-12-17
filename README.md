# chromecast-remote-for-children
Linux-based service that turns your wireless numpad keyboard into a pushbutton Chromecast remote for children

## Motivation
I have a child about 1 year old, and he's always reaching for remotes and keyboards.  I thought it would be nice for him to have his own, but most are toys that (at best) only chime or beep when a button is pressed.  I thought it would be fun to hand my son his own remote that could actually control what he sees on the nearby screen.  (Cause and effect relationships, etc.)

### Disclaimer
I am not necessarily advocating for screen time for little ones.  However, if a screen is already turned on nearby, this is an inventive way for me to avoid having to ward off my curious son incessantly.

## Features
* Plays a designated YouTube video at the push of an associated button
    * View key mapping in [start.sh](start.sh)
* Plays any media supported by [castnow](https://github.com/xat/castnow)
* Mapped control keys
    * Stop
    * Next
    * Volume up
    * Volume down

### Parental Controls
* Remove the remote from the child
* Remove the battery from the remote
* Unplug the keyboard dongle from the computer

## Hardware
This project only covers the software that enables the remote to function.  You're on your own for the hardware.

Hardware requirements:
* Computer running Linux somewhere nearby where you desire the remote to function.  It need not be in the same room.  It need not be dedicated to this purpose.
    * If you desire a low-power solution, consider something like a [Raspberry Pi](https://www.raspberrypi.org/).
* Wireless keyboard, preferably a numpad only (like those you see inside banks)
* Chromecast connected to a nearby screen
* Colored stickers for keys (optional)
    * Or, just print some color blocks, cut them out, and use 2-sided adhesive tape to affix them.

Things to consider when choosing your keyboard:
* Wireless
* Power save
* Numpad only
* Numlock LED
* No drivers necessary
* N-key rollover
* Not 2.4 GHz (if you have things like baby monitors, cordless phones, microwaves, etc.)
* Mechanical keys

Here is the hardware I chose for my first remote:
* [CanaKit Raspberry Pi 3 Complete Starter Kit - 32 GB Edition](https://www.amazon.com/gp/product/B01C6Q2GSY/)
* [Mizux Mechanical Numeric Keypad Wireless USB Mini Numpad with Nano Receiver (22-Key)](https://www.amazon.com/gp/product/B0734JHW81/)

## Raspberry Pi Setup

The following steps are how I setup my Raspberry Pi.  If you're using a different machine, the process will differ.

* Download, install latest NOOBS to Raspberry Pi
    * Add Raspberry Pi to home Wi-Fi
* Install Raspbian Lite (no need for a graphical environment)
* Run `raspi-config`
    * Update raspi-config itself
    * Login to CLI on boot (not graphics desktop)
    * Change password
    * Set hostname
    * Add your locale to the list of selected locales
    * Set time zone
    * Enable SSH (if you're running this headless like me)
    * Disable VNC
    * Disable serial
* Reserve dynamic IP (if you desire to SSH into device after setup)
* Update Raspbian
```
sudo apt update
sudo apt upgrade
```
* Setup unattended upgrades
```
sudo apt install unattended-upgrades
sudo dpkg-reconfigure --priority=low unattended-upgrades
```

## Functional Description
This remote uses a keylogger ([logkeys](https://github.com/kernc/logkeys)) to capture keystrokes.  One process per key sequence reads through the captures keystrokes (using [bgrep](https://github.com/rsharo/bgrep)).  Upon detected key sequence, [castnow](https://github.com/xat/castnow) is used to play content on a nearby Chromecast instance.

## Installation

* Install packages
```
sudo apt install evtest npm python-pip git jq ufw
sudo ln -s /usr/bin/nodejs /usr/bin/node
sudo npm install castnow -g
sudo -H pip install --upgrade youtube-dl
```
* Configure UFW to allow inbound SSH
* [Configure rules to allow castnow to do its thing](https://github.com/xat/castnow/wiki#castnow-keeps-being-stuck-in-the-state-loading-or-scanning)
```
sudo /sbin/iptables -A INPUT -p udp --dport 5353 -j ACCEPT
sudo /sbin/iptables -A INPUT -p tcp --match multiport --dports 4100:4105 -j ACCEPT
```
* Compile https://github.com/kernc/logkeys from source (otherwise you'll see https://github.com/kernc/logkeys/issues/103)
    * You can install from package manager if you're not on a Raspberry Pi
* Compile https://github.com/rsharo/bgrep from source
    * You can install from package manager if you're not on a Raspberry Pi

## Configuration

Create a file named `config.json`, with contents like this:
```
{
	"input_dev": "/dev/input/event0",
	"chromecast_dev": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
}
```

...where:
* `input_dev` is the device you want to collect keystrokes from.  You can learn this from running `sudo evtest`.
* `chromecast_dev` is the Chromecast you want to play videos on.  You can learn this from running `avahi-discover`.  The GUID you're looking for is all of the text before the `.local` suffix.

## Ideas for Future Work
* Use numlock LED for status indicator
```
sudo su -c 'setleds -L +num < /dev/console'
sudo su -c 'setleds -L -num < /dev/console'
```
* Lockout by time of day (parental control)
* Key sequence that causes remote to rotate between available Chromecasts on local network
* Create "pages" of videos available for playing (mapped to letters marked on keyboard)
* Move functionality in [start.sh](start.sh) to single Python script
    * Key mappings move to config.json
    * When run without any arguments, starts all processes
        * One process per key sequence in JSON
        * Process calls same script with triggered key sequence as argument
    * When run with argument, passes to key sequence handler
        * Looks up key sequence in JSON, performs associated action
        * All actions passes to system() or equivalent

Ideas for other keyboard mappings:
* Include Easter egg (like when hit 1-9 in a row, or 1-2 buckle shoe)
* Wave files for piano keys (major scale)
* Wave file to say name of every character typed (even symbols), for learning
* [PAC-MAN game](http://pacman.platzh1rsch.ch/) (play using arrows on keypad)
* [Simon memory game](http://labs.uxmonk.com/simon-says/) (play using numbers on keypad, may conflict with colored stickers)
