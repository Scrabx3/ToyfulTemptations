Scriptname TTMain extends Quest

import JsonUtil
import StringUtil
; -------------------------------- Properties
TTMCM Property MCM Auto
ToysFramework Property Toys Auto
Actor Property PlayerRef Auto
; Prepare State
Keyword Property ActorTypeDragon Auto
Keyword Property ActorTypeNPC Auto
Keyword Property ActorTypeUndead Auto
Faction Property PreyFaction Auto
Race Property ChickenRace Auto
Race Property HareRace Auto ; Bunny
; GetKey
Key Property ToysKey Auto
Key Property ToysKeyTiny Auto
Key Property ToysKeyExotic Auto
Key Property ToysKeyExoticTiny Auto
; Event
ImageSpaceModifier Property FadeToBlackFastImod Auto
ImageSpaceModifier Property FadeToBlackHoldImod Auto
ImageSpaceModifier Property FadeToBlackBackImod Auto
; Formlist Property AllDevices Auto
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
  ObjectReference[] boxz = MiscUtil.ScanCellObjects(28, PlayerRef, 400.0)
  int index = 0
  While(index < boxz.Length)
    int openstate = boxz[index].GetOpenState()
    If(openstate == 1)
      Self.prepareEncounter(boxz[index])
      return
    EndIf
    index += 1
  EndWhile
EndEvent

Function prepareEncounter(ObjectReference toPrepare)
  If(Toys.IsBusy(false, false, true) || chestCache.Find(toPrepare) >= 0)
    return
  else
    Toys.SetBusy(true)
  EndIf
  ; Evaluate Chance of smth happening
  Actor corpze = toPrepare as Actor
  If(corpze != none && MCM.iChestTypeReg != 1) ;Corpse allowed, check Trap & Drop
    If(corpze.HasKeyword(ActorTypeDragon)) ; Corpse Type: Dragon
      rollLoot(1.1, toPrepare); IntListToArray(filePath, MCM.dragonKey), toPrepare)
    ElseIf(corpze.HasKeyword(ActorTypeNPC))
      rollLoot(0.9, toPrepare); IntListToArray(filePath, MCM.npcKey), toPrepare)
    ElseIf(corpze.HasKeyword(ActorTypeUndead))
      rollLoot(0.8, toPrepare); IntListToArray(filePath, MCM.undeadKey), toPrepare)
    ElseIf(corpze.IsInFaction(PreyFaction))
      rollLoot(1.3, toPrepare); IntListToArray(filePath, MCM.preyKey), toPrepare)
    Else
      rollLoot(1, toPrepare); IntListToArray(filePath, MCM.miscKey), toPrepare)
    EndIf
  ElseIf(MCM.iChestTypeReg != 2) ; Chest or so
    If(FormListFind(filePath, "rareContainers", toPrepare.GetBaseObject()))
      rollLoot(1.5, toPrepare); IntListToArray(filePath, MCM.chestRareKey), toPrepare)
    Else
      rollLoot(1, toPrepare); IntListToArray(filePath, MCM.chestKey), toPrepare)
    EndIf
  EndIf
  ; Cache
  chestCache[cacheIndex] = toPrepare
  cacheIndex += 1
  If(cacheIndex >= chestCache.Length)
    cacheIndex = 0
  EndIf
  ; Cleanup
  Toys.SetBusy(false)
EndFunction

; ---------------------------- Looting
Function rollLoot(float chanceMult, ObjectReference box) ; int[] thresholds
  int count = MCM.iMaxRolls - 1
  int[] freeSlots = GetAvailableSlots()
  bool firstCall = true
  While(count)
    count -= 1
    ; Regular Toys
    If(Utility.RandomFloat(0.5, 100.0) <= MCM.fToyChance)
      addLoot(box)
    EndIf
    ; Traps
    If(Utility.RandomFloat(0.5, 100.0) <= (MCM.fBaseChance * (1 / chanceMult)) && freeSlots)
      If(firstCall)
        freeSlots = checkTrap(freeSlots)
        If(freeSlots[0])
          Toys.WuusshEffect(PlayerRef)
          If(msgOnce)
            Debug.MessageBox("As you open the chest, a narcotic scent overcomes you and knocks you out. When you wake backup, some strange armor has wrapped itself tight around your skin.")
            msgOnce = false
          else
            Debug.Notification("You feel some toyful Restraints wrapping around your skin.")
          EndIf
          firstCall = false
        EndIf
      ElseIf(Utility.RandomInt(1, 100) <= 50)
        freeSlots = checkTrap(freeSlots)
      EndIf
    EndIf
  EndWhile
  ; Key
  ; Doing this after the Loop to not have Keys drop "Roll times", which would make them overly common
  If(Utility.RandomFloat(0.5, 100.0) <= (MCM.fKeyChance * chanceMult))
    Form[] myKeys = getKeys()
    int numK = myKeys.Length
    While(numK)
      numK -= 1
      box.AddItem(myKeys[numK])
    EndWhile
  EndIf
EndFunction
; ---------------------------- Drop Functions
; Regular Loot
Function addLoot(ObjectReference toAdd)
  toAdd.AddItem(Toys.GetToy("TT", available = false, prefer = false))
EndFunction

; Traps
int[] Function checkTrap(int[] slots)
  int tmp = slots[Utility.RandomInt(0, slots.length - 1)]
  slots = PapyrusUtil.RemoveInt(slots, tmp)
  Armor tmpA = fetchToy(tmp)
  If(tmpA != none)
    Debug.Trace("TT: Attempting to equip " + tmpA.GetName())
    Toys.HandleToy("TT", PlayerRef, tmpA)
    return slots
  else
    return new int[1]
  EndIf
EndFunction

Armor Function fetchToy(int Slot)
  return Toys.GetToy("TT", Slot, Prefer = MCM.bMatchToy)
EndFunction

; Keys
Form[] Function getKeys()
  Form[] toReturn = new Form[5]
  int roles = 0
  float chance = 100.0
  int fusedWeight = MCM.iKeyWeightBasic + MCM.iKeyWeightBasicTiny + MCM.iKeyWeightBasicExotic + MCM.iKeyWeightBasicExoticTiny
  While(Utility.RandomFloat(0, 99.0) < chance && roles < 5)
    int nextKey = Utility.RandomInt(1, fusedWeight)
    int keyChoice
    int tmp
    While(tmp < nextKey)
      If(keyChoice == 0)
        tmp = MCM.iKeyWeightBasic
      ElseIf(keyChoice == 1)
        tmp += MCM.iKeyWeightBasicTiny
      ElseIf(keyChoice == 2)
        tmp += MCM.iKeyWeightBasicExotic
      ElseIf(keyChoice == 3)
        tmp += MCM.iKeyWeightBasicExoticTiny
      else
        tmp = nextKey
      EndIf
      keyChoice += 1
    EndWhile
    If(keyChoice == 1)
      toReturn[roles] = ToysKey
    ElseIf(keyChoice == 2)
      toReturn[roles] = ToysKeyTiny
    ElseIf(keyChoice == 3)
      toReturn[roles] = ToysKeyExotic
    ElseIf(keyChoice == 4)
      toReturn[roles] = ToysKeyExoticTiny
    EndIf
    roles += 1
    chance *= (MCM.fKeyRoleChance/100.0)
  EndWhile
  return PapyrusUtil.RemoveForm(toReturn, none)
EndFunction

; ---------------------------- Getters
int[] Function GetAvailableSlots()
  int[] sol = new int[15] ; Number betw 1 & 15
  If(Toys.IsSlotAvailable("TT", 1) && Utility.RandomInt(1, 100) <= MCM.TTypeWeightHand)
    sol[0] = 1
  EndIf
  If(Toys.IsSlotAvailable("TT", 2) && Utility.RandomInt(1, 100) <= MCM.TTypeWeightFeet)
    sol[1] = 2
  EndIf
  If(Toys.IsSlotAvailable("TT", 3) && Utility.RandomInt(1, 100) <= MCM.TTypeWeightMouth)
    sol[2] = 3
  EndIf
  If(Toys.IsSlotAvailable("TT", 4) && Utility.RandomInt(1, 100) <= MCM.TTypeWeightNeck)
    sol[3] = 4
  EndIf
  If(Toys.IsSlotAvailable("TT", 5) && Utility.RandomInt(1, 100) <= MCM.TTypeWeightWrists)
    sol[4] = 5
  EndIf
  If(Toys.IsSlotAvailable("TT", 6) && Utility.RandomInt(1, 100) <= MCM.TTypeWeightAnal)
    sol[5] = 6
  EndIf
  If(Toys.IsSlotAvailable("TT", 7) && Utility.RandomInt(1, 100) <= MCM.TTypeWeightPelvis)
    sol[6] = 7
  EndIf
  If(Toys.IsSlotAvailable("TT", 8) && Utility.RandomInt(1, 100) <= MCM.TTypeWeightGenital)
    sol[7] = 8
  EndIf
  If(Toys.IsSlotAvailable("TT", 9) && Utility.RandomInt(1, 100) <= MCM.TTypeWeightNipples)
    sol[8] = 9
  EndIf
  If(Toys.IsSlotAvailable("TT", 10) && Utility.RandomInt(1, 100) <= MCM.TTypeWeightLegs)
    sol[9] = 10
  EndIf
  If(Toys.IsSlotAvailable("TT", 11) && Utility.RandomInt(1, 100) <= MCM.TTypeWeightEyes)
    sol[10] = 11
  EndIf
  If(Toys.IsSlotAvailable("TT", 12) && Utility.RandomInt(1, 100) <= MCM.TTypeWeightBreasts)
    sol[11] = 12
  EndIf
  If(Toys.IsSlotAvailable("TT", 13) && Utility.RandomInt(1, 100) <= MCM.TTypeWeightVaginal)
    sol[12] = 13
  EndIf
  If(Toys.IsSlotAvailable("TT", 14) && Utility.RandomInt(1, 100) <= MCM.TTypeWeightTorso)
    sol[13] = 14
  EndIf
  If(Toys.IsSlotAvailable("TT", 15) && Utility.RandomInt(1, 100) <= MCM.TTypeWeightArms)
    sol[14] = 15
  EndIf
  return PapyrusUtil.RemoveInt(sol, 0)
EndFunction

;/
LootTable Syntax:
intList -> Save/Unsave/Key

rareChest List:
TreasAlchemySatchelCommon; TreasAlchemySatchelRare; TreasAlchemySatchelUncommon; TreasRuinsUrnSmall02EMPTY; TreasRuinsUrnSmall02; TreasKnapsack; TreasRuinsUrnSmall01EMPTY; TreasRuinsUrnSmall01; TreasDwarvenJewelryBox; RTCoffin01; MarkarthCoffin01box; MarkarthCoffin02box; DLC1TreasSoulCairnChest; DLC1TreasSoulCairnChest02; DLC01SC_ChestBoss; DLC01TreasSnowElfChestBoss; DLC2TreasApocryphaChestBoss
/;
