# GodoLibur - Create 2D Adventure games with the Godot Engine

**Godot Version: 4.1.2**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![Godot Engine](https://img.shields.io/badge/GODOT-%23FFFFFF.svg?style=for-the-badge&logo=godot-engine)

![godolibur](https://github.com/Programando-o-Mundo/GodoLibur/assets/9157977/9e241a08-6583-4dd6-a1d8-256647c53482)

**Warning! - This library is currently in a experimental stage, and is very likely you will find bugs if you try to use in your project.**
**We are trying to clean these bugs as fast as we can, while also creating a documentation for every node in the project**

# Summary

- [Description](#description)
- [Download](#download)
- [Features](#features)
- [Contributing](#contributing)
- [License](#license)

## Description

GodoLibur is a node library created to help Godot developers create 2D Adventure games, with custom nodes specially made to
solve most common features adventure games has. The objective of this library is to speed up the process of creating games
for these gaming genres by providing nodes that are both ready to use and customizable (if needed) for specific scenarios.

Checkout a demo developed using this library:

[![Demo thumbnail](https://i.imgur.com/EwRgF4H.jpg)](https://youtu.be/xlmQLanqUYw)

## Download

- Create a ```/addons``` folder in your Godot Project
- Download the [lastest version](https://github.com/Programando-o-Mundo/GodoLibur/releases/tag/V1.0) in this repository's download section
- Unzip the plugin in the ```/addons``` folder
- Open the Godot Engine, go to ```Project -> Project Configuration```
- Open the **Plugins** tab
- Enable the plugin

## Features

Here is a list of the already implemented features:

* CampaingOverseer
  * Save/Load ( Save and load only the necessary information in a Campaing)  
* Campaing
  * Campaing Timer (Stopwatch)
* SceneHandling
  * SceneTransition (Door)
  * Scene Visibility
  * EnemyController (Create Intelligent enemies that follow the player through different screens)
  * SceneAudio (Play audio and music with dinamic effects)
  * PlayerInteraction (link with inventory and objects in the Scene)
* UI
  * DialogBox
  * MenuController
  * GameGUI
    * CutceneHandler
    * DialogBoxHandler
    * GameMenu
      * SimpleScreen
    * SceneOverlay
* Enemy AI and Behavior
* Movable Objects
* Pickable Objects
* Player
  * Player Custom Camera
  * Player Custom Raycast (PlayerCast)
* Player Inventory
  * Save items picked up by player
  * Store player information (nickname, portrait/icon) 
* Cutcene
  * Static Cutcenes
  * Cinematic Cutcene
  * Cutcene Scripts (control the dynamics during cutcene)  

## Contributing

If you want to contribute to the project, check it out the [CONTRIBUTING.md](/CONTRIBUTING.md)

## License

[MIT](https://choosealicense.com/licenses/mit/)
