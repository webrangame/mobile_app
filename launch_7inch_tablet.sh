#!/bin/bash
# Launch the 7-inch Tablet Emulator (Nexus 7 2013)
# This will start the emulator with a GUI window and audio enabled.

EMULATOR_PATH="/home/ranga/Android/Sdk/emulator/emulator"
$EMULATOR_PATH -avd tablet_7_inch -netdelay none -netspeed full &
