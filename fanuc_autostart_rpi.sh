#!/bin/bash
 
##########################################################
#   This program extracts all programs individually from
#   the *.ALL into individual files.
#
#   Tested to FANUC version
#       0i, 16i, 18i, 31i
#
#   Runs on Linux, Android and Windows
#   (with additional installation of a Linux shell from Microsoft-Store)
#
#   Coded by Sebastian Staitsch
#   s.staitsch@gmail.com
#   Version 1.4
#   last modified: 2020/07/03 01:35:46
#   https://github.com/sstaitsch/fanuc
#   https://pastebin.com/4wFFYnw3
#
#   === VIDEO ===
#   https://youtu.be/zgsBnk39xLI
#
#   NOTE:   -Files must be in the same folder as the script file
#           -Files must have the suffix * .ALL
#			-this SourceCode is for "RasperryPi Zero W Autostart"
#   USE: sh fanuc.sh
##########################################################

led_on(){
sudo sh -c 'echo 0 > /sys/class/leds/led0/brightness'
}

led_off(){
sudo sh -c 'echo 1 > /sys/class/leds/led0/brightness'
}

blink(){
for i in {1..5} ; do
        led_on
        led_off
done
}

while true; do
clear
echo plugin your device now
        until [ -n "$(lsblk | grep -E -o 'sd.1')" ]; do
                sleep 5
                led_on
                led_off
        continue; done
                device=$(lsblk | grep -E -o 'sd.1')
                echo Device found $device
                blink
                led_on
                sudo mount -t vfat -rw /dev/$device /home/pi/usb
                echo beginn process... please wait
                sudo cp fanuc.sh /home/pi/usb/fanuc.sh
                cd usb/
                chmod +rwx *ALL
                chmod +rwx fanuc.sh
                sudo sh /home/pi/usb/fanuc.sh
                sudo rm /home/pi/usb/fanuc.sh
                cd /home/pi/
                sudo umount /dev/$device
                blink
                led_off
                clear
                echo process finish
                echo remove your device now
        until [ -z "$(lsblk | grep -E -o 'sd.1')" ]; do
                sleep 1
                led_on
                sleep 1
                led_off
        continue; done
        
clear
led_off
echo device removed... 
echo programm restarts now
sleep 2
clear
done
