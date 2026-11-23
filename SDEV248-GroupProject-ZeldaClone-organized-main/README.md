Group Project for SDEV248 at Ivy Tech Community College, taught by Professor Mark Earle.

This project aims to generally re-create three sequential scenes from the original Legend of Zelda on the NES.

Group Members in alphabetical order:
Eli Cain
Cody Gunter
Duncan Hegerman
Ean Miller

## Control Scheme (can be modified in Project Settings)
Move Up - "W"   
Move Down - "S"  
Move Left - "A"  
Move Right - "D"  
Cast (fireball) - Spacebar  
Interact (with Spearwoman) - "E"

## Scene Explanations (all located in /scenes)

- intro_cutscene.tscn - Opening story cutscene
- room_1.tscn - Room 1 (opening area with Spearwoman and one Enemy)
- room_2.tscn - Room 2 (Enemies scattered about here.)
- room_3.tscn - Room 3 (final room of the project.)
- victory_cutscene.tscn - Success ending
- defeat_cutscene.tscn - Failure ending

## Autoloading and explanation of why

- `GameManager` (`res://scenes/GameManager.gd`) - keeps health and room states when transitioning between rooms.
