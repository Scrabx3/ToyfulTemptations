Scriptname TTPlayer extends ReferenceAlias

; -------------------------------- Properties
TTMain Property Main Auto
Actor Property PlayerRef Auto
; -------------------------------- Variables
; -------------------------------- Code
Event OnPlayerLoadGame()
  Main.maintenance()
EndEvent

Event OnInit()
  OnPlayerLoadGame()
EndEvent
