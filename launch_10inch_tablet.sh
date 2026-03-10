#!/bin/bash
# Launch the 10.1-inch Tablet Emulator (Pixel Tablet)
# This will start the emulator with a GUI window and audio enabled.

EMULATOR_PATH="/home/ranga/Android/Sdk/emulator/emulator"
$EMULATOR_PATH -avd tablet_10_inch -netdelay none -netspeed full &
