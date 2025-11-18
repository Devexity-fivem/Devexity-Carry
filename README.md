# Devexity-Carry
An updated carry script with trunk functionality and improved features.

**Original credits:** https://github.com/rubbertoe98/FiveM-Scripts/tree/master/CarryPeople for providing the base

## Features

### Carry System
- Fixed the exploit where you could type `/carry` while being carried to uncarry yourself
- Added useful control blocks while being carried such as blocking inventory and forcing inventory close if using ox_inventory
- Modern ox_lib notifications instead of native text notifications

### Trunk System
- **Put carried players in trunk**: When carrying someone, approach a vehicle with an open trunk and you'll see an ox_lib textui prompt `[E] Put in Trunk`
- **Player can exit trunk**: Players placed in a trunk can exit themselves by pressing `E` when the trunk is open
- **Trunk camera**: Third-person camera view while in trunk
- **Vehicle validation**: Automatically checks if vehicle supports trunk functionality
- **Trunk state management**: Prevents multiple players from being in the same trunk

## Dependencies
- [ox_lib](https://github.com/overextended/ox_lib) - Required for notifications and textui

## Installation
1. Add `Devexity-Carry` to your `resources` folder
2. Add `ensure Devexity-Carry` to your `server.cfg`
3. Make sure `ox_lib` is installed and started before this resource

## Usage

### Carrying Players
- Use `/carry` command to start/stop carrying the nearest player
- The person being carried cannot use controls while being carried

### Trunk Functionality
1. **Putting someone in trunk:**
   - Carry a player using `/carry`
   - Approach a vehicle with an open trunk (within 5 meters)
   - An ox_lib textui prompt will appear: `[E] Put in Trunk`
   - Press `E` to place the carried player in the trunk

2. **Exiting trunk:**
   - When in a trunk, wait for someone to open it
   - When the trunk is open, a prompt will appear: `[E] Exit Trunk`
   - Press `E` to exit the trunk

## Supported Vehicles
Most vehicle classes support trunk functionality except:
- Motorcycles
- Certain supercars (Penetrator, Vacca, Monroe, Turismo R, Osiris, Comet variants, Ardent, Jester, Nero variants, Vagner, Infernus, Zentorno, Bullet)

## Notes
- Trunk must be open to place someone inside
- Trunk must be open for the player inside to exit
- Only one player can be in a trunk at a time
- The script uses ox_lib for all UI elements and notifications
