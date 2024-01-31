<h1 align="center">Fallout 3 / Fallout: New Vegas to Fallout 4 converter</h1>

<div align="center">

[![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/terry-haire/fnv-to-fo4/total)](https://github.com/terry-haire/fnv-to-fo4/releases)
[![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/terry-haire/fnv-to-fo4/main.yml)](https://github.com/terry-haire/fnv-to-fo4/actions)
[![Discord](https://img.shields.io/discord/1179975442275500122?link=https%3A%2F%2Fdiscord.gg%2F5VcMTMVzgb)](https://discord.gg/5VcMTMVzgb)
[![License: GPL v3](https://img.shields.io/badge/license-GPLv3-blue.svg)](LICENSE)
[![YouTube Channel Views](https://img.shields.io/youtube/channel/views/UCPHhhWa28pUJQ-7TCaP2q7g?link=https%3A%2F%2Fwww.youtube.com%2F%40FNVtoFO4)](https://www.youtube.com/@FNVtoFO4)

</div>

<img src="images/gamebryo-creation-engine.png" alt="Image 1 description"/>

# Nexus
https://www.nexusmods.com/fallout4/mods/75425

# Features
* Fully convert most models from Fallout 3 / Fallout: New Vegas to Fallout 4.
* Partially convert plugin files (.esp/.esm) from Fallout 3 / Fallout: New Vegas to Fallout 4.

# Usage

1. Download the latest release from https://github.com/terry-haire/fnv-to-fo4/releases and unzip it.
1. Install Fallout: New Vegas and launch it at least once.
1. Install Fallout 4 and launch it at least once.
1. Install Fallout 4: Creation Kit.
1. Run `fnv-to-fo4.exe` to convert New Vegas models and plugin files. The converted files are saved in the `output` directory.
1. Copy over the contents of the `output` directory to the Fallout 4 Data directory. Or create a zip file of the `output` directory and open it with a mod manager.
1. Allow mods in Fallout 4 (https://wiki.nexusmods.com/index.php/Fallout_4_Mod_Installation).
1. Activate the esm in Fallout 4.
1. Launch Fallout 4, open the console and type `coc Goodsprings` to teleport to Fallout New Vegas.

# Development setup

Make sure all submodules are present:
```
git submodule update --init --recursive
```

## TES5Edit
* Follow instructions from the TES5Edit discord to set up the IDE: https://gist.github.com/flayman/24b4326fd451f1200d2c199a1bf62fa1

## Nifskope
* Follow the instructions here: https://github.com/niftools/nifskope/wiki/Compiling-with-Qt-Creator-(Windows)
    * Make sure to download the latest Qt5.* and not Qt6+ when using the online installer.

## Creation Kit

Add the following to CreationKit.ini in the Fallout 4 directory to allow multiple masters to load.
```ini
[General]
bAllowMultipleMasterFiles=1
bAllowMultipleMasterLoads=1
```
