Scriptname TTCorpze extends ActiveMagicEffect

TTMain Property Main  Auto

Event OnActivate(ObjectReference akActionRef)
  Actor me = akActionRef as Actor
  If(me)
    If(me == Main.PlayerRef || me.IsPlayerTeammate())
      Main.prepareEncounter(GetTargetActor())
    EndIf
  EndIf
EndEvent
