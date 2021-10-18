Scriptname TTPlayer extends ReferenceAlias

TTMain Property Main Auto

Event OnInit()
  OnPlayerLoadGame()
EndEvent

Event OnPlayerLoadGame()
  Main.maintenance()
EndEvent
