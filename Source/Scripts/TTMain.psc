Scriptname TTMain extends Quest

import JsonUtil
import StringUtil

TTMCM Property MCM Auto
ToysFramework Property Toys Auto
slaFrameworkScr Property SLA Auto
Actor Property PlayerRef Auto
Keyword Property LocTypeHabitation Auto
Keyword Property LocTypeDungeon Auto
Keyword Property ActorTypeDragon Auto
Faction Property PreyFaction Auto
Race Property ChickenRace Auto
Race Property HareRace Auto ; Bunny
Key[] Property ToysKeys Auto
{Key, Tiny, Exotic, Tiny Exotic}
; Event
ImageSpaceModifier Property FadeToBlackFastImod Auto
ImageSpaceModifier Property FadeToBlackHoldImod Auto
ImageSpaceModifier Property FadeToBlackBackImod Auto
ImageSpaceModifier Property RushedImod Auto
; -------------------------------- Variables
string filePath = "../ToyfulTemptations/LootTable.json"
ObjectReference[] chestCache
int cacheIndex = 0
bool msgOnce = true
; -------------------------------- Code
Function maintenance()
  RegisterForMenu("ContainerMenu")
  chestCache = new ObjectReference[10]
EndFunction

Event OnMenuOpen(string Menu)
  ObjectReference[] chests = MiscUtil.ScanCellObjects(28, PlayerRef, 400.0)
  int index = 0
  While(index < chests.Length)
    If(chests[index].GetOpenState() == 1)
      CreateEncounter(chests[index], PlayerRef)
      return
    EndIf
    index += 1
  EndWhile
EndEvent

Function CreateEncounter(ObjectReference p, Actor a)
  If(Toys.IsBusy(false, false, true) || chestCache.Find(p) >= 0 || (MCM.bFilterEmpty && p.GetNumItems() == 0) || a != PlayerRef)
    Debug.Trace("[TT] Cancel Encounter Creation due to invalid Entry Checks")
    return
  EndIf
  Debug.Trace("[TT] Creating Encounter")
  Toys.SetBusy(true)
  Actor corpse = p as Actor
  float chanceMult = 0
  If(corpse && MCM.iLootType != 1)
     If(corpse.HasKeyword(ActorTypeDragon))
      chanceMult = 0.8
    ElseIf(corpse.IsInFaction(PreyFaction))
      chanceMult = 1.3
    Else
      chanceMult = 1.1
    EndIf
  ElseIf(MCM.iLootType != 2)
    chanceMult = 1
  EndIf
  ; Add to Container
  int n = 0
  While(Utility.RandomFloat(0.0, 99.5) < MCM.fToyChance && n < 4) ; Add Container
    p.AddItem(Toys.GetToy("TT", available = false, prefer = false))
    n += 1
  EndWhile
  If(Utility.RandomFloat(0.5, 100.0) <= (MCM.fKeyChance * chanceMult))
    Form[] keys = CreateKeys()
    int i = 0
    While(i < keys.length)
      p.AddItem(keys[i], 1, true)
      i += 1
    EndWhile
  EndIf
  float trapChance = ((SLA.GetActorArousal(a) as float / 100) * MCM.fArousalWeight + 1) * (1/chanceMult)
  If(MCM.bSplitChance)
    Location loc = a.GetCurrentLocation()
    If(!loc)
      trapChance *= MCM.fBaseChanceW
    ElseIf(loc.HasKeyword(LocTypeHabitation))
      trapChance *= MCM.fBaseChanceC
    ElseIf(loc.HasKeyword(LocTypeDungeon))
      trapChance *= MCM.fBaseChanceD
    Else
      trapChance *= MCM.fBaseChanceW
    EndIf
  Else
    trapChance *= MCM.fBaseChance
  EndIf
  int[] freeSlots = CreateValidSlots()
  bool firstTrigger = true
  int i = 0
  While(i < MCM.iMaxDrops)
    If(Utility.RandomFloat(0.0, 99.9) < trapChance) ; Trap
      Utility.Wait(0.01) ; Don't do this before we didnt close the Container
      If(!CreateTrap(freeSlots))
        return
      EndIf
      If(firstTrigger)
        Game.DisablePlayerControls()
        If(MCM.iTrapMethod == 0) ; Bleedout
          Debug.SendAnimationEvent(a, "BleedoutEnter")
          FadeToBlackFastImod.Apply()
          Utility.Wait(0.5)
          FadeToBlackFastImod.PopTo(FadeToBlackHoldImod)
        ElseIf(MCM.iTrapMethod == 1) ; Toys
          Toys.WuusshEffect(PlayerRef)
        ElseIf(MCM.iTrapMethod == 2) ; Rushed
          If(a == PlayerRef)
            RushedImod.Apply()
            Game.ShakeCamera(p, 0.3, 0.7)
          EndIf
          Debug.SendAnimationEvent(a, "staggerStart")
        EndIf
        If(MCM.bTrapStrip)
          a.UnequipAll()
          a.QueueNiNodeUpdate()
        EndIf
        If(msgOnce && MCM.bNotifyOnTrap)
          String intro = ""
          If(corpse)
            intro = "As you look through the Corpse"
          Else
            intro = "As you open the chest"
          EndIf
          Debug.MessageBox(intro + ", a narcotic scent overcomes you and knocks you out. When you wake backup, some strange armor has wrapped itself tight around your skin.")
          msgOnce = false
        EndIf
      EndIf
    EndIf
    i += 1
  EndWhile
  If(MCM.iTrapMethod == 0)
    Debug.SendAnimationEvent(a, "BleedoutExit")
    FadeToBlackHoldImod.PopTo(FadeToBlackBackImod)
  EndIf
  Game.EnablePlayerControls()
  ; Cache
  chestCache[cacheIndex] = p
  cacheIndex += 1
  If(cacheIndex >= chestCache.Length)
    cacheIndex = 0
  EndIf
  ; Cleanup
  Toys.SetBusy(false)
EndFunction

int[] Function CreateValidSlots()
  int[] sol = new int[15]
  int i = 0
  While(i < sol.Length)
    If(Toys.IsSlotAvailable("TT", i + 1, Utility.RandomFloat(0, 99.5) < MCM.fSwapChance))
      sol[i] = MCM.TTypeWeights[i]
    Else
      sol[i] = 0
    EndIf
    i += 1
  EndWhile
  return sol
EndFunction

bool Function CreateTrap(int[] weights)
  int allCells = 0
  int i = 0
  While(i < weights.length)
    allCells += weights[i]
    i += 1
  EndWhile
  If(allCells != 0)
    int c = Utility.RandomInt(1, allCells)
    int w = 0
    i = 0
    While(w < c)
      w += weights[i]
      i += 1
    EndWhile
    weights[i - 1] = 0
    Armor toy = Toys.GetToy("TT", i, Prefer = MCM.bMatchToy)
    If(toy)
      Debug.Trace("[TT] Attempting to equip " + toy)
      Debug.Notification(toy.GetName() + " has been equipped.")
      return Toys.HandleToy("TT", PlayerRef, toy) > 0
    EndIf
  EndIf
  return false
EndFunction

Form[] Function CreateKeys()
  Form[] ret = new Form[5]
  int allCells = MCM.iKeyWeight[0] + MCM.iKeyWeight[1] + MCM.iKeyWeight[2] + MCM.iKeyWeight[3]
  float p = 100.0
  int i = 0
  While(Utility.RandomFloat(0, 99.9) < p && i < 5)
    int c = Utility.RandomInt(1, allCells)
    int w = 0
    int n = 0
    While(w < c)
      w += MCM.iKeyWeight[n]
      n += 1
    EndWhile
    ret[i] = ToysKeys[n - 1]
    i += 1
    p *= (MCM.fKeyChanceAdd/100.0)
  EndWhile
  return PapyrusUtil.RemoveForm(ret, none)
EndFunction
