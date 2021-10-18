Scriptname TTCorpze extends ActiveMagicEffect

TTMain Property Main  Auto

Event OnActivate(ObjectReference akActionRef)
  Actor me = akActionRef as Actor
  If(me)
    If(me == Main.PlayerRef || me.IsPlayerTeammate())
      Main.createEncounter(GetTargetActor(), me)
    EndIf
  EndIf
EndEvent
