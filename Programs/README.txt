This is where BattleDrive games are put.
For every game, one Lua file must be present, providing basic info about it.

The game file, when executed, should return "bdGameInfo" table
with these fields

NOTE: Game's loader script should return a constructor of a Loader object.
The loader object has a "loadGame" method, which returns the Game object.

REQUIRED:
name String; the game name;
OLD mainScriptPath String; relative path to program's 'main' script.
gameDir string relative path to game's directory (without slashes)
loaderScriptName name of the loader script
OPTIONAL:
description String;
versionMinor Number;
versionMajor Number;
versionBugfix Number;
