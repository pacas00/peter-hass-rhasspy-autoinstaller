# peter-hass-rhasspy-autoinstaller
An autoinstaller script and default configs to quickly setup a Home Assissant/Rhasspy Voice Assissant installation.
Made to make my life easier and have voice control of my smart lights when the internet is down.

Primarilly built/tested for/on Raspbian. (Future: Maybe it works on the Ubuntu Server image for RPi3/4 (depends on if the Respeaker driver is not needed)
 
No support or warranty is given for use of this installer.

### Min Requirements

Base Station
- Raspberry Pi 4 (or better)


Speakers
- Raspberry Pi 3 (or better)


### Supported Audio Drivers
Note: Audio is not automatically configured, supported drivers are automatically installed.

- Respeaker 2 Mic Hat (not working on Ubuntu image for RPi)



### Quick install 

`curl -fsSL https://raw.githubusercontent.com/pacas00/peter-hass-rhasspy-autoinstaller/main/HABuildScript.sh -H 'Cache-Control: no-cache' -J -o HABuildScript.sh; sudo bash HABuildScript.sh`


### What gets installed
Some of these are only required on Base Station units or Speaker units.

Dependency markers (Combo Base Station + Speakers will contain both)
(A) All
(B) Base Station Only
(S) Speaker Only

- (A) Git
- (S) PulseAudio
- (S) Audio Drivers (if supported)
- - Respeaker 2 Mic Hat
- (A) Docker - https://www.docker.com
- (A) Portainer CE (Web GUI for managing docker containers) - https://www.portainer.io
- (B) Home Assissant (Smart Home hub / home automation solution) - https://www.home-assistant.io
- (B) NodeRed (Planned, Not currently installed) - https://nodered.org
- (A) Default config sets for Rhasspy (BaseStation, Base + Speaker, Speaker Only)
- (A) Rhasspy (Offline private voice assistant for many human languages) - https://github.com/rhasspy/rhasspy




