# rojo.nvim
rojo.nvim is a Neovim plugin that provides convenience commands to Neovim. The commands are a wrapper around the Roblox Rojo CLI.

## Requirements
Ensure you have 'rojo' on your PATH. Install Rojo CLI using instructions [here](https://rojo.space/docs/v7/getting-started/installation/).

## Installation
### lazy.nvim
```lua
{
  'ShouxTech/rojo.nvim',
  opts = {},
}
```

## Usage
The plugin will expose these commands for you:
```
:RojoVersion
:RojoInit
:RojoServe
:RojoStopServe
```
