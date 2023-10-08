<h1 align="center">Fallout 3 / Fallout: New Vegas to Fallout 4 converter</h1>

<p align="center">
</p>
<table>
  <tr>
    <td><img src="images/screenshot-1.jpg" alt="Image 1 description"/></td>
    <td><img src="images/screenshot-5.jpg" alt="Image 2 description"/></td>
  </tr>
  <tr>
    <td><img src="images/screenshot-2.jpg" alt="Image 3 description"/></td>
    <td><img src="images/screenshot-3.jpg" alt="Image 4 description"/></td>
  </tr>
</table>

# Features
* Fully convert most models from Fallout 3 / Fallout: New Vegas to Fallout 4.
* Partially convert plugin files (.esp/.esm) from Fallout 3 / Fallout: New Vegas to Fallout 4.

# Usage

1. Download the latest release from https://github.com/terry-haire/fnv-to-fo4/releases and unzip it.
1. Install Fallout: New Vegas and launch it at least once.
1. Install Fallout 4 and launch it at least once.
1. Install Fallout 4: Creation Kit.
1. Run `convert.bat` to convert New Vegas models. The converted models are saved in the `output` directory.
1. Convert plugin files. (Instructions are W.I.P.) <!-- TODO: -->
1. Copy over the contents of the `output` directory to the Fallout 4 Data directory. Or create a zip file of the `output` directory and open it with a mod manager.
1. Copy the contents of the Textures directory from the EXTRACTED_BSA_PATH to the Fallout 4 Data/textures/new_vegas directory.
1. Allow mods in Fallout 4 (https://wiki.nexusmods.com/index.php/Fallout_4_Mod_Installation).
1. Activate the esp in Fallout 4.

# Development setup

Make sure all submodules are present:
```
git submodule update --init --recursive
```

## TES5Edit
* Follow instructions on the official TES5Edit discord to set up the IDE: https://gist.github.com/flayman/24b4326fd451f1200d2c199a1bf62fa1

## Nifskope
* Follow the instructions here: https://github.com/niftools/nifskope/wiki/Compiling-with-Qt-Creator-(Windows)
    * Make sure to download the latest Qt5.* and not Qt6+ when using the online installer.
