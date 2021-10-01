
# Raspberry Pi Power Button - Wake/Power Off/Restart(Double Press)

## Information

When Raspberry Pi is powered off, shortening GPIO3 (Pin 5) to ground will wake the Raspberry Pi.

This script will use pin GPIO3(5), Ground(6) with momentary button.

       3V3  (1) (2)  5V         
     GPIO2  (3) (4)  5V         
    -----------------------     
    | GPIO3  (5) (6)  GND | <-  
    -----------------------     
     GPIO4  (7) (8)  GPIO14     
       GND  (9) (10) GPIO15     
    GPIO17 (11) (12) GPIO18     
    GPIO27 (13) (14) GND        
    GPIO22 (15) (16) GPIO23     
       3V3 (17) (18) GPIO24     
    GPIO10 (19) (20) GND        
     GPIO9 (21) (22) GPIO25     
    GPIO11 (23) (24) GPIO8      
       GND (25) (26) GPIO7      
     GPIO0 (27) (28) GPIO1      
     GPIO5 (29) (30) GND        
     GPIO6 (31) (32) GPIO12     
    GPIO13 (33) (34) GND        
    GPIO19 (35) (36) GPIO16     
    GPIO26 (37) (38) GPIO20     
       GND (39) (40) GPIO21     

## Default Behavior

| __Button Press When Pi is On__      | __Description__ |
| ----------------------------------- | --------------- |
| Single                              | Nothing         |
| Double                              | Reboot          |
| Long and releases (Above 3 seconds) | Power off       |

| __Button Press When Pi is off__ | __Description__            |
| ------------------------------- | -------------------------- |
| Single                          | Powers on the Raspberry Pi |

## Requirements

python3-gpiozero

Can be install via apt

```bash
sudo apt install python3-gpiozero
```

### Software

* A Debian-based operating system that uses systemd (tested on Jessie and Stretch)
  
* the `python3-gpiozero` package to provide [GPIO
  Zero](https://gpiozero.readthedocs.io/en/stable/) (tested on version 1.4.0)

## Installation

### Hardware

#### 40-pin GPIO connector (B+, 2B, 3B, Zero)

Connect the button between GPIO 27 and GND. If you use an ATX power
button and a Raspberry Pi with a 40-pin GPIO header, connect it across
the seventh column from the left:

                -
    · · · · · ·|·|· · · · · · · · · · · · · 
    · · · · · ·|·|· · · · · · · · · · · · · 
                -

This shorts GPIO 27 (physical pin 13) to ground (physical pin 14) when
the button is pressed.

#### 26-pin GPIO connector (models B and A only)

GPIO 27 is not exposed on the original Raspberry Pi header, so [GPIO 17](https://pinout.xyz/pinout/pin11_gpio17#) is a reasonable option. If you use an ATX power button and a Raspberry Pi with a 26-pin GPIO header, connect it across the fifth and sixth columns of the second row:

    . . . . ._. . . . . . . .
    . . . .|. .|. . . . . . .
             -
You will also need to change [line 7 of shutdown_button.py](https://github.com/scruss/shutdown_button/blob/master/shutdown_button.py#L7) to read:

    use_button=17

### Software

The software is installed with the following commands:

    sudo apt install python3-gpiozero
    sudo mkdir -p /usr/local/bin
    chmod +x shutdown_button.py
    sudo cp shutdown_button.py /usr/local/bin
    sudo cp shutdown_button.service /etc/systemd/system
    sudo systemctl enable shutdown_button.service
    sudo systemctl start shutdown_button.service

## Troubleshooting

Enabling the service should produce output very similar to:

    Created symlink /etc/systemd/system/multi-user.target.wants/shutdown_button.service → /etc/systemd/system/shutdown_button.service.

You can check the status of the program at any time with the command:
	
    systemctl status shutdown_button.service

This should produce output similar to:
	
    ● shutdown_button.service - GPIO shutdown button
       Loaded: loaded (/etc/systemd/system/shutdown_button.service; enabled; vendor 
       Active: active (running) since Sat 2017-10-21 11:20:56 EDT; 27s ago
     Main PID: 3157 (python3)
       CGroup: /system.slice/shutdown_button.service
               └─3157 /usr/bin/python3 /usr/local/bin/shutdown_button.py

    Oct 21 11:20:56 naan systemd[1]: Started GPIO shutdown button.

If you're seeing anything *other* than **Active: active (running)**,
it's not working. Does the Python script have the right permissions?
Is it in the right place? If you modified the script, did you check it
for syntax errors? If you're using a model A or B with a 26-pin GPIO connector, did you make the modifications in the Python script to use GPIO 17 instead of 27?

The output from `dmesg` will show you any error messages generated by
the service.

## Modifications

If you use a HAT/pHAT/Bonnet/etc. with your Raspberry Pi, check
[pinout.xyz](https://pinout.xyz/) to see if it uses BCM 27. If you do
need to change the pin, best to pick one that doesn't have a useful
system service like serial I/O or SPI. If you're using an ATX button
with a two pin connector, make sure you choose a pin physically
adjacent to a ground pin.

If you modify the timing, please ensure that you keep the shutdown
button press duration *longer* than the reboot one. Otherwise you'll
only be able to shut down.

## Notes

You should not need to reboot to enable the service. One machine of
mine — a Raspberry Pi Zero running Raspbian Stretch — did need a
reboot before the button worked.

The reboot code is based on the [Shutdown
button](https://gpiozero.readthedocs.io/en/stable/recipes.html#shutdown-button)
example from the GPIO Zero documentation.

This is not the only combined shutdown/reset button project to use
GPIO Zero. [gilyes/pi-shutdown](https://github.com/gilyes/pi-shutdown)
also does so, but pre-dates the implementation of the various hold
time functions in GPIO Zero.

GPIO 27 was used, as it's broken out onto a physical button on the Adafruit [PiTFT+](http://adafru.it/2423) display I own.

This is my first systemd service, and I'm still at the “amazed it
works at all” stage. The service file may not contain the ideal
configuration.

### Connector Pinouts

       3V3  (1) (2)  5V    
     GPIO2  (3) (4)  5V    
    -----------------------
    | GPIO3  (5) (6)  GND | <-
    -----------------------
     GPIO4  (7) (8)  GPIO14
       GND  (9) (10) GPIO15
    GPIO17 (11) (12) GPIO18
    GPIO27 (13) (14) GND   
    GPIO22 (15) (16) GPIO23
       3V3 (17) (18) GPIO24
    GPIO10 (19) (20) GND   
     GPIO9 (21) (22) GPIO25
    GPIO11 (23) (24) GPIO8 
       GND (25) (26) GPIO7 
     GPIO0 (27) (28) GPIO1 
     GPIO5 (29) (30) GND   
     GPIO6 (31) (32) GPIO12
    GPIO13 (33) (34) GND   
    GPIO19 (35) (36) GPIO16
    GPIO26 (37) (38) GPIO20
       GND (39) (40) GPIO21
    

*****


# pi-power-button

Scripts used in our official [Raspberry Pi power button guide](https://howchoo.com/g/mwnlytk3zmm/how-to-add-a-power-button-to-your-raspberry-pi).

## Installation

1. [Connect to your Raspberry Pi via SSH](https://howchoo.com/g/mgi3mdnlnjq/how-to-log-in-to-a-raspberry-pi-via-ssh)
1. Clone this repo: `git clone https://github.com/Howchoo/pi-power-button.git`
1. Run the setup script: `./pi-power-button/script/install`

## Uninstallation

If you need to uninstall the power button script in order to use GPIO3 for another project or something:

1. Run the uninstall script: `./pi-power-button/script/uninstall`

## Hardware

A full list of what you'll need can be found [here](https://howchoo.com/g/mwnlytk3zmm/how-to-add-a-power-button-to-your-raspberry-pi#parts-list). At a minimum, you'll need a normally-open (NO) power button, some jumper wires, and a soldering iron. If you _don't_ have a soldering iron or don't feel like breaking it out, you can use [this prebuilt button](https://howchoo.com/shop/product/prebuilt-raspberry-pi-power-button?utm_source=github&utm_medium=referral&utm_campaign=git-repo-readme) instead.

Connect the power button to Pin 5 (GPIO 3/SCL) and Pin 6 (GND) as shown in this diagram:

![Connection Diagram](https://raw.githubusercontent.com/Howchoo/pi-power-button/master/diagrams/pinout.png)

### Is it possible to use another pin other than Pin 5 (GPIO 3/SCL)?

Not for full functionality, no. There are two main features of the power button:

1. **Shutdown functionality:** Shut the Pi down safely when the button is pressed. The Pi now consumes zero power.
1. **Wake functionality:** Turn the Pi back on when the button is pressed again.

The **wake functionality** requires the SCL pin, Pin 5 (GPIO 3). There's simply no other pin that can "hardware" wake the Pi from a zero-power state. If you don't care about turning the Pi back _on_ using the power button, you could use a different GPIO pin for the **shutdown functionality** and still have a working shutdown button. Then, to turn the Pi back on, you'll just need to disconnect and reconnect power (or use a cord with a physical switch in it) to "wake" the Pi.

Of course, for the GND connection, you can use [any other ground pin you want](https://pinout.xyz/).