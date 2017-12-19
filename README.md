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


## Functional Description
This remote uses a keylogger ([logkeys](https://github.com/kernc/logkeys)) to capture keystrokes from a specific (wireless) keyboard.  One process per key sequence scans through the captured keystrokes (using [bgrep](https://github.com/rsharo/bgrep)).  Upon detecting a key sequence, [castnow](https://github.com/xat/castnow) is used to play content on a nearby Chromecast instance.


## Hardware
Hardware requirements:
* Computer running Linux somewhere nearby where you desire the remote to function.  It need not be in the same room.  It need not be dedicated to this purpose.
    * If you desire a low-power solution, consider something like a [Raspberry Pi](https://www.raspberrypi.org/).
* Wireless keyboard, preferably a numpad only (like those you see inside banks)
* Chromecast connected to a nearby screen
* Colored stickers for keys (optional)
    * Or, just print some color blocks, cut them out, and use 2-sided adhesive tape to affix them.
    * Or, purchase some colored keycaps.

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

![My first remote](https://user-images.githubusercontent.com/1757771/34083863-09bf807c-e345-11e7-8dd7-8f24f0d08d7c.jpg)

The above photo pictures a 100% functioning remote running on a Raspberry Pi 3.  (I added the colored stickers to the keyboard.)

(Obviously) not pictured is the Chromecast attached to my TV.  This will not work without a Chromecast properly configured to control a nearby screen.


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
    * If running on a Raspberry Pi, ensure that you pull from master, including https://github.com/rsharo/bgrep/commit/4abd26576b519639f7be2560e28d169424630125
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
* `chromecast_dev` is the Chromecast you want to play videos on.  You can learn this from running `avahi-discover`.  The GUID you're looking for is all of the text before the `.local` suffix (including any dashes).


## Service Installation

The following steps install this as a service (so that it automatically starts upon boot).  It assumes that you have cloned the repo at `/home/pi/chromecast-remote-for-children/`

* Copy the service file
```
sudo cp -fv /home/pi/chromecast-remote-for-children/chromecast-remote-for-children.service /etc/systemd/system/
```
* Tell systemd about the new service
```
sudo systemctl daemon-reload
```
* Enable the service upon reboot
```
sudo systemctl enable chromecast-remote-for-children.service
```
* Start the service
```
sudo systemctl start chromecast-remote-for-children.service
```

To see the status of the service:
```
systemctl status chromecast-remote-for-children.service
```

It's normal for the status to show a ton of child processes.  See [start.sh](start.sh) if you're interested in seeing why.  Example output:
```
● chromecast-remote-for-children.service - Chromecast Remote for Children
   Loaded: loaded (/etc/systemd/system/chromecast-remote-for-children.service; enabled; vendor preset: enabled)
   Active: active (running) since Tue 2017-12-19 12:39:36 EST; 3s ago
  Process: 2346 ExecStop=/home/pi/chromecast-remote-for-children/stop.sh (code=exited, status=0/SUCCESS)
 Main PID: 2454 (start.sh)
   CGroup: /system.slice/chromecast-remote-for-children.service
           ├─2454 /bin/bash /home/pi/chromecast-remote-for-children/start.sh
           ├─2477 logkeys --start --device=/dev/input/event0
           ├─2486 /bin/bash /home/pi/chromecast-remote-for-children/start.sh
           ├─2487 /bin/bash /home/pi/chromecast-remote-for-children/start.sh
           ├─2488 tail -f -n0 /var/log/logkeys.log
           ├─2489 bgrep -b "<Esc>"
           ├─2490 /bin/bash /home/pi/chromecast-remote-for-children/start.sh
           ├─2491 /bin/bash /home/pi/chromecast-remote-for-children/start.sh
           ├─2492 /bin/bash /home/pi/chromecast-remote-for-children/start.sh
           ├─2493 tail -f -n0 /var/log/logkeys.log
           ├─2494 bgrep -b "<KP+>"
           ├─2495 /bin/bash /home/pi/chromecast-remote-for-children/start.sh
           ├─2496 /bin/bash /home/pi/chromecast-remote-for-children/start.sh
           ├─2497 /bin/bash /home/pi/chromecast-remote-for-children/start.sh
           ├─2498 tail -f -n0 /var/log/logkeys.log
           ├─2499 bgrep -b "<KP0>"
           ├─2500 /bin/bash /home/pi/chromecast-remote-for-children/start.sh
           ├─2501 /bin/bash /home/pi/chromecast-remote-for-children/start.sh
           ├─2502 tail -f -n0 /var/log/logkeys.log
           ├─2503 bgrep -b "<KP1>"
           ├─2504 /bin/bash /home/pi/chromecast-remote-for-children/start.sh
           ├─2505 /bin/bash /home/pi/chromecast-remote-for-children/start.sh
           ├─2506 /bin/bash /home/pi/chromecast-remote-for-children/start.sh
           ├─2507 /bin/bash /home/pi/chromecast-remote-for-children/start.sh
           ├─2508 tail -f -n0 /var/log/logkeys.log
           ├─2509 bgrep -b "<KP4>"
           ├─2510 /bin/bash /home/pi/chromecast-remote-for-children/start.sh
           ├─2511 /bin/bash /home/pi/chromecast-remote-for-children/start.sh
           ├─2512 /bin/bash /home/pi/chromecast-remote-for-children/start.sh
           ├─2513 /bin/bash /home/pi/chromecast-remote-for-children/start.sh
           ├─2514 tail -f -n0 /var/log/logkeys.log
           ├─2515 bgrep -b "<KP7>"
           ├─2516 /bin/bash /home/pi/chromecast-remote-for-children/start.sh
           ├─2517 /bin/bash /home/pi/chromecast-remote-for-children/start.sh
           ├─2518 tail -f -n0 /var/log/logkeys.log
           ├─2519 bgrep -b "<KP8>"
           ├─2520 /bin/bash /home/pi/chromecast-remote-for-children/start.sh
           ├─2521 /bin/bash /home/pi/chromecast-remote-for-children/start.sh
           ├─2522 tail -f -n0 /var/log/logkeys.log
           ├─2523 bgrep -b "<KP*>"
           ├─2524 tail -f -n0 /var/log/logkeys.log
           ├─2525 /bin/bash /home/pi/chromecast-remote-for-children/start.sh
           ├─2526 bgrep -b "<KP/>"
           ├─2527 /bin/bash /home/pi/chromecast-remote-for-children/start.sh
           ├─2528 tail -f -n0 /var/log/logkeys.log
           ├─2529 bgrep -b "<Tab>"
           ├─2530 /bin/bash /home/pi/chromecast-remote-for-children/start.sh
           ├─2531 tail -f -n0 /var/log/logkeys.log
           ├─2532 bgrep -b "<KP5>"
           ├─2533 /bin/bash /home/pi/chromecast-remote-for-children/start.sh
           ├─2534 tail -f -n0 /var/log/logkeys.log
           ├─2535 bgrep -b "<KP6>"
           ├─2536 /bin/bash /home/pi/chromecast-remote-for-children/start.sh
           ├─2537 tail -f -n0 /var/log/logkeys.log
           ├─2538 bgrep -b "<KP3>"
           ├─2539 /bin/bash /home/pi/chromecast-remote-for-children/start.sh
           ├─2540 tail -f -n0 /var/log/logkeys.log
           ├─2541 bgrep -b "<KP2>"
           ├─2542 /bin/bash /home/pi/chromecast-remote-for-children/start.sh
           ├─2543 tail -f -n0 /var/log/logkeys.log
           ├─2544 bgrep -b "<KP9>"
           ├─2545 /bin/bash /home/pi/chromecast-remote-for-children/start.sh
           ├─2546 tail -f -n0 /var/log/logkeys.log
           ├─2547 bgrep -b "<KP->"
           └─2548 /bin/bash /home/pi/chromecast-remote-for-children/start.sh

Dec 19 12:39:36 d-mote start.sh[2454]: + tail -f -n0 /var/log/logkeys.log
Dec 19 12:39:36 d-mote start.sh[2454]: + read -r
Dec 19 12:39:36 d-mote start.sh[2454]: + stdbuf -o0 bgrep -b '"<KP2>"'
Dec 19 12:39:36 d-mote start.sh[2454]: + tail -f -n0 /var/log/logkeys.log
Dec 19 12:39:36 d-mote start.sh[2454]: + read -r
Dec 19 12:39:36 d-mote start.sh[2454]: + stdbuf -o0 bgrep -b '"<KP->"'
Dec 19 12:39:36 d-mote start.sh[2454]: + tail -f -n0 /var/log/logkeys.log
Dec 19 12:39:36 d-mote start.sh[2454]: + read -r
Dec 19 12:39:36 d-mote start.sh[2454]: + stdbuf -o0 bgrep -b '"<KP7>"'
Dec 19 12:39:36 d-mote start.sh[2454]: + read -r
```

To see logs from the service:
```
journalctl -u chromecast-remote-for-children.service
```

To setup log rotation:
```
sudo cp -fv /home/pi/chromecast-remote-for-children/chromecast-remote-for-children.logrotate /etc/logrotate.d/chromecast-remote-for-children
```

## Updating Dependencies

If you run this service for a long time, you'll eventually want to update everything.  Use Git to update this repo to its latest.  Additionally...

Update the OS:
```
sudo bash -c "apt -y update; apt -y upgrade && apt -y autoremove"
```

Update `pip` packages:
```
pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 sudo -H pip install -U
```

Update `npm` packages:
```
sudo npm update -g
```

Also, be sure to update anything you manually built, such as:
* logkeys
* bgrep


## Ideas for Future Work
* Use numlock LED for status indicator
```
sudo su -c 'setleds -L +num < /dev/console'
sudo su -c 'setleds -L -num < /dev/console'
```
* Parental control: Add configurable lockout by time of day (i.e. for bedtime)
* Key sequence that causes remote to rotate between available Chromecasts on local network
* Create "pages" of videos available for playing (mapped to letters marked on keyboard)
    * Page "A" has numbers 0-9
    * Page "B" has numbers 0-9, and so on...
* Move key mappings to `config.json`

Ideas for other keyboard mappings:
* Include Easter egg (like when hit 1-9 in a row, or 1-2 buckle shoe)
* Wave files for piano keys (major scale)
* Wave file to say name of every character typed (even symbols), for learning
* [PAC-MAN game](http://pacman.platzh1rsch.ch/) (play using arrows on keypad)
* [Simon memory game](http://labs.uxmonk.com/simon-says/) (play using numbers on keypad, may conflict with colored stickers)
