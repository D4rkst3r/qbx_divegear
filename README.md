# qbx_divegear

A customized FiveM resource for diving with native GTA diving suits and oxygen management.

## Features

✅ **Complete Diving Suit System** - Uses authentic GTA diving suit components
✅ **Multiple Color Variants** - Black, Blue, Red, Yellow diving suits
✅ **Oxygen Management** - Oxygen decay system while underwater
✅ **Cloth Restoration** - Automatically restores player's original clothes when suit is removed
✅ **Smooth Animations** - Progress bars for equipping/removing gear
✅ **Scuba Breathing** - Native GTA scuba diving mechanics

## Installation

1. Clone or download this resource into your `resources` folder
2. Ensure you have `ox_lib` installed and running
3. Add to your `server.cfg`:
```
ensure qbx_divegear
```

## Configuration

Edit `config/client.lua` to customize:
- Starting oxygen level (default: 100)
- Suit on/off/refill times
- Oxygen decay rate
- Available suit variants

## Usage

Trigger the event to equip/remove the suit:
```lua
TriggerEvent('qbx_divegear:client:useGear')
```

Or with a specific suit variant:
```lua
TriggerEvent('qbx_divegear:client:useGear', Config.client.divingSuits[2])
```

## Suit Variants

The following diving suits are available:
- Black & Yellow Suit
- Full Black Suit
- Blue Diving Suit
- Red Diving Suit

## Requirements

- QBX Framework (or easily adaptable to QB-Core)
- ox_lib
- ox_inventory (optional, for inventory integration)

## License

GPL-3.0
