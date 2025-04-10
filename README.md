# An Example Control Configuration for Reaper

This repository contains configuration files for an example control setup for Reaper that combines nOb with nAc, Open Stage Control, and Helgoboss's ReaLearn.  
This configuration is intended as educational material to inspire you to create your own setup for Reaper or any other DAW of your choice.

**IMPORTANT: Always back up your own configuration files before experimenting with someone else's setup.**

## nAc (a.k.a nOb Assignment Center)

If you are a nOb controller owner, please download nAc from [https://nobcontrol.com/nac](https://nobcontrol.com/nac). nAc will open up a lot of exciting control possibilities and workflow improvements for your device. Please follow nAc's user manual for proper installation.

In the `nAc` folder, you will find a JSON file that contains all the profiles used in this configuration. This file should be placed in `C:\Users\YourUserName\AppData\Roaming\nac` on Windows, or in `/Users/YourUserName/Library/Application Support/nac/` on macOS.

In this setup, nAc receives Open Sound Control (OSC) data on port 8000.

Always back up your own nAc configuration before using my profiles!  
Treat this configuration as an example to learn how to set up nAc and create your own custom setup, tailored to your needs.

## Open Stage Control

Open Stage Control is an excellent free and open-source software for creating control interfaces for touch-enabled devices (phones, tablets, etc.). Interfaces created with Open Stage Control can receive and send OSC and MIDI data, which can be highly customized with scripts. You can download it here: [https://openstagecontrol.ammd.net/](https://openstagecontrol.ammd.net/)

In my setup, Open Stage Control receives OSC data on port 8002 by default.

Here is a screenshot of how it is configured:  
![Open Stage Control](/images/OpenStageControl.jpg)

Feel free to support this project in any way you can!  
You can find the source code here: [https://github.com/jean-emmanuel/open-stage-control](https://github.com/jean-emmanuel/open-stage-control)  
Support the main developer on Patreon: [https://www.patreon.com/openstagecontrol](https://www.patreon.com/openstagecontrol)

Don't forget to check out the community forums if you need help or want to share your own control solutions:  
[https://openstagecontrol.discourse.group/](https://openstagecontrol.discourse.group/)

## ReaLearn by Helgoboss

Another important part of this configuration is the excellent ReaLearn plugin for Reaper by Helgoboss.  
You can download it here: [https://www.helgoboss.org/projects/realearn](https://www.helgoboss.org/projects/realearn)

If you use Reaper, this is a powerful tool to enhance your control workflow.  
Check out the official video tutorials here: [YouTube Playlist](https://www.youtube.com/playlist?list=PL0bFMT0iEtAgKY2BUSyjEO1I4s20lZa5G)

Also, don't forget to join ReaLearn's vibrant community for tips, tricks, and more:  
[https://www.helgoboss.org/projects/realearn#community](https://www.helgoboss.org/projects/realearn#community)

In this repository, my ReaLearn presets can be found in the corresponding folder. ReaLearn receives OSC data from Open Stage Control on port 8001

![ReaLearn](/images/ReaLearn.jpg)

## Reaper

Reaper needs no introduction. You can get it here: [https://www.reaper.fm/](https://www.reaper.fm/)

In this repository, you’ll also find a collection of scripts for Reaper, along with other configuration files.  
These files should be placed in the corresponding folders inside Reaper’s resource path.

My Reaper setup includes two enabled OSC control surfaces:
- One to receive OSC data from nAc on port 8003  
  ![nAc](/images/Reaper_OSC_nAc.jpg)
- One to receive OSC data from Open Stage Control on port 8004  
  ![OpenStageControl](/images/Reaper_OSC_OpenStageControl.jpg)

Always remember to back up your own Reaper configuration before using someone else’s setup!

## Final words

This configuration is a continuous work in progress and may contain bugs.  
Feel free to explore it at your own convenience, and don’t hesitate to reach out to us at [info@nobcontrol.com](mailto:info@nobcontrol.com) with your feedback or questions!








