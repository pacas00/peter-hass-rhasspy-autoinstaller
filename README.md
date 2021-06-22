# peter-hass-rhasspy-autoinstaller
An autoinstaller script and default configs to make my life easier.

Primarilly built/tested for/on Raspbian.
 
No support or warranty is given for use of this installer.

### Min Requirements

Base Station
- Raspberry Pi 4 (or better)


Speakers
- Raspberry Pi 3 (or better)


### Supported Audio Drivers
Note: Audio is not automatically configured, supported drivers are automatically installed.

- Respeaker 2 Mic Hat



### Quick install 

`curl -fsSL https://raw.githubusercontent.com/pacas00/peter-hass-rhasspy-autoinstaller/main/HABuildScript.sh -o HABuildScript.sh; sudo bash HABuildScript.sh`


### What gets installed
Some of these are only required on Base Station units or Speaker units.

- Git
- PulseAudio
- Audio Drivers (if supported)
- - Respeaker 2 Mic Hat
- Docker - https://www.docker.com
- Portainer CE (Web GUI for managing docker containers) - https://www.portainer.io
- Home Assissant (Smart Home hub / home automation solution) - https://www.home-assistant.io
- NodeRed (Planned, Not currently installed) - https://nodered.org
- Default config sets for Rhasspy (BaseStation, Base + Speaker, Speaker Only)
- Rhasspy (Offline private voice assistant for many human languages) - https://github.com/rhasspy/rhasspy




