Scriptname TTMCM extends SKI_ConfigBase

import JsonUtil
; -------------------------------- Properties
Actor Property PlayerRef Auto
; -------------------------------- Variables
string filepath = "../ToyfulTemptations/LootTable.json"
; --- General

float Property fBaseChance = 7.5 Auto Hidden
bool Property bMatchToy = true Auto Hidden
float Property fToyChance = 10.0 Auto Hidden
string[] restrictLootList
int Property iChestTypeReg = 0 Auto Hidden
int Property iMaxRolls = 3 Auto Hidden
; --- Loot Table
string[] lootPresets
int presetIndex = 1
; Key Weights
float Property fKeyChance = 5.0 Auto Hidden
float Property fKeyRoleChance = 40.0 Auto Hidden
int Property iKeyWeightBasic = 60 Auto Hidden
int Property iKeyWeightBasicTiny = 50 Auto Hidden
int Property iKeyWeightBasicExotic = 15 Auto Hidden
int Property iKeyWeightBasicExoticTiny = 10 Auto Hidden
; Profile Preview
string Property dragonKey = "hazardous" Auto Hidden ; 1 Dragon
string Property npcKey = "balanced" Auto Hidden ; 2 NPC
string Property undeadKey = "risky" Auto Hidden ; 3 Undead
string Property preyKey = "merciful" Auto Hidden ; 4 Prey
string Property miscKey = "balanced" Auto Hidden ; 5 Misc
string Property chestRareKey = "merciful" Auto Hidden ; 6 Rare Chest
string Property chestKey = "balanced" Auto Hidden ; 7 Regular Chest
; --- Events
int Property TTypeWeightHand = 30 Auto Hidden
int Property TTypeWeightFeet = 40 Auto Hidden
int Property TTypeWeightMouth = 70 Auto Hidden
int Property TTypeWeightNeck = 60 Auto Hidden
int Property TTypeWeightWrists = 20 Auto Hidden
int Property TTypeWeightAnal = 40 Auto Hidden
int Property TTypeWeightPelvis = 50 Auto Hidden
int Property TTypeWeightGenital = 40 Auto Hidden
int Property TTypeWeightNipples = 80 Auto Hidden
int Property TTypeWeightLegs = 60 Auto Hidden
int Property TTypeWeightEyes = 30 Auto Hidden
int Property TTypeWeightBreasts = 20 Auto Hidden
int Property TTypeWeightVaginal = 40 Auto Hidden
int Property TTypeWeightTorso = 70 Auto Hidden
int Property TTypeWeightArms = 60 Auto Hidden

; -------------------------------- O_IDs
int oTTypeHand
int oTTypeFeet
int oTTypeMouth
int oTTypeNeck
int oTTypeWrists
int oTTypeAnal
int oTTypePelvis
int oTTypeGenital
int oTTypeNipples
int oTTypeLegs
int oTTypeEyes
int oTTypeBreasts
int oTTypeVaginal
int oTTypeTorso
int oTTypeArms

; -------------------------------- Code
int Function GetVersion()
	return 1
endFunction

Function Initialize()
	Pages = new string[3]
  Pages[0] = " General"
	Pages[1] = " Keys"
	Pages[2] = " Events"

	lootPresets = new string[3]
	lootPresets[0] = " Easy"
	lootPresets[1] = " Normal"
	lootPresets[2] = " Hard"
	; lootPresets[3] = "Cursed"

	restrictLootList = new string[3]
	restrictLootList[0] = "No Restrictions"
	restrictLootList[1] = "Only Chests"
	restrictLootList[2] = "Only Corpses"
endFunction

; ==================================
; 							MENU
; ==================================
Event OnConfigInit()
	Initialize()
EndEvent

Event OnVersionUpdate(int newVers)
	Initialize()
endEvent

Event OnPageReset(String Page)
  SetCursorFillMode(TOP_TO_BOTTOM)
  If(Page == "")
    Page = " General"
  EndIf
  If(Page == " General")
		AddHeaderOption(" Event Chance")
    AddSliderOptionST("baseChance", "Base Chance", fBaseChance, "{1}%")
		SetCursorPosition(1)
		AddHeaderOption(" Containers")
		AddMenuOptionST("rTRestrictChest", "Restrict Containers", restrictLootList[iChestTypeReg])
		AddSliderOptionST("maxToyDrops", "Maximum Rolls per Container", iMaxRolls)
		AddSliderOptionST("regularToy", "Regular Toy Chance", fToyChance, "{1}%")
		AddHeaderOption(" Miscellaneous")
		AddToggleOptionST("equipMatching", "Equip Matching Types", bMatchToy)
	ElseIf(Page == " Keys")
		AddSliderOptionST("KeyChance", "Key Dropchance", fKeyChance, "{1}%")
		AddSliderOptionST("KeyRoles", "Additional Role Chance", fKeyRoleChance, "{1}%")
		AddSliderOptionST("KeyWeight0", "Basic Key", iKeyWeightBasic)
		AddSliderOptionST("KeyWeight1", "Tiny Key", iKeyWeightBasicTiny)
		AddSliderOptionST("KeyWeight2", "Exotic Key", iKeyWeightBasicExotic)
		AddSliderOptionST("KeyWeight3", "Tiny Exotic Key", iKeyWeightBasicExoticTiny)
	ElseIf(Page == " Loot Table")
		AddMenuOptionST("TableSelect", "Change Preset", lootPresets[presetIndex])
		AddEmptyOption()
		AddHeaderOption("Key Weights")
		AddSliderOptionST("KeyRoles", "Additional Role Chance", fKeyRoleChance, "{1}%")
		AddSliderOptionST("KeyWeight0", "Basic Key", iKeyWeightBasic)
		AddSliderOptionST("KeyWeight1", "Tiny Key", iKeyWeightBasicTiny)
		AddSliderOptionST("KeyWeight2", "Exotic Key", iKeyWeightBasicExotic)
		AddSliderOptionST("KeyWeight3", "Tiny Exotic Key", iKeyWeightBasicExoticTiny)
		; --------------------------------------------
		SetCursorPosition(1)
		AddTextOption("Tier: Dragon", dragonKey, OPTION_FLAG_DISABLED)
		AddTextOption("Tier: NPC", npcKey, OPTION_FLAG_DISABLED)
		AddTextOption("Tier: Undead", undeadKey, OPTION_FLAG_DISABLED)
		AddTextOption("Tier: Prey", preyKey, OPTION_FLAG_DISABLED)
		AddTextOption("Tier: Misc Creatures", miscKey, OPTION_FLAG_DISABLED)
		AddEmptyOption()
		AddTextOption("Tier: Rare Chests", chestRareKey, OPTION_FLAG_DISABLED)
		AddTextOption("Tier: Regular Chests", chestKey, OPTION_FLAG_DISABLED)
		; --------------------------------------------
	ElseIf(Page == " Events")
		SetCursorFillMode(LEFT_TO_RIGHT)
		AddHeaderOption(" Basic Events")
		AddEmptyOption()
		oTTypeHand = AddSliderOPtion("Hand Toy", TTypeWeightHand)
		oTTypeFeet = AddSliderOPtion("Feet Toy", TTypeWeightFeet)
		oTTypeMouth = AddSliderOPtion("Mouth Toy", TTypeWeightMouth)
		oTTypeNeck = AddSliderOPtion("Neck Toy", TTypeWeightNeck)
		oTTypeWrists = AddSliderOPtion("Wrist Toy", TTypeWeightWrists)
		oTTypeAnal = AddSliderOPtion("Anal Toy", TTypeWeightAnal)
		oTTypePelvis = AddSliderOPtion("Pelvis Toy", TTypeWeightPelvis)
		oTTypeGenital = AddSliderOPtion("Genital Toy", TTypeWeightGenital)
		oTTypeNipples = AddSliderOPtion("Nipple Toy", TTypeWeightNipples)
		oTTypeLegs = AddSliderOPtion("Leg Toy", TTypeWeightLegs)
		oTTypeEyes = AddSliderOPtion("Eye Toy", TTypeWeightEyes)
		oTTypeBreasts = AddSliderOPtion("Breasts Toy", TTypeWeightBreasts)
		oTTypeVaginal = AddSliderOPtion("Vaginal Toy", TTypeWeightVaginal)
		oTTypeTorso = AddSliderOPtion("Torso Toy", TTypeWeightTorso)
		oTTypeArms = AddSliderOPtion("Arm Toy", TTypeWeightArms)
		AddEmptyOption()
		; SetCursorPosition(1)
		; AddHeaderOption(" Special Events")
		; AddTextOPtion("N/A; Comming soon", none, OPTION_FLAG_DISABLED)
  EndIf
EndEvent

; ==================================
; 				States /// General
; ==================================
State baseChance
  Event OnSliderOpenST()
		SetSliderDialogStartValue(fBaseChance)
		SetSliderDialogDefaultValue(7.5)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(0.5)
	EndEvent
	Event OnSliderAcceptST(float value)
		fBaseChance = value
		SetSliderOptionValueST(fBaseChance, "{1}%")
	EndEvent
	Event OnHighlightST()
		SetInfoText("Basechance for an Event to happen.")
	EndEvent
EndState

State equipMatching
	Event OnSelectST()
		bMatchToy = !bMatchToy
		SetToggleOptionValueST(bMatchToy)
	EndEvent
	Event OnHighlightST()
		SetInfoText("Prefer Toys from the same Toy Box or choose randomly between all available Restraints?")
	EndEvent
EndState

State rTRestrictChest
	Event OnMenuOpenST()
		SetMenuDialogStartIndex(iChestTypeReg)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(restrictLootList)
	EndEvent
	Event OnMenuAcceptST(int index)
		iChestTypeReg = index
		SetMenuOptionValueST(restrictLootList[iChestTypeReg])
	EndEvent
	Event OnDefaultST()
		iChestTypeReg = 1
		SetMenuOptionValueST(restrictLootList[iChestTypeReg])
	EndEvent
	Event OnHighlightST()
		SetInfoText("Restrict which Containers can contain Toys")
	EndEvent
EndState

State regularToy
	Event OnSliderOpenST()
		SetSliderDialogStartValue(fToyChance)
		SetSliderDialogDefaultValue(10.0)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(0.5)
	EndEvent
	Event OnSliderAcceptST(float value)
		fToyChance = value
		SetSliderOptionValueST(fToyChance, "{1}%")
	EndEvent
	Event OnHighlightST()
		SetInfoText("Chance that a non-trapped Toy can be found inside a Container.\n(A Toy that doesn't equip itself)")
	EndEvent
EndState

State maxToyDrops
	Event OnSliderOpenST()
		SetSliderDialogStartValue(iMaxRolls)
		SetSliderDialogDefaultValue(3)
		SetSliderDialogRange(0, 10)
		SetSliderDialogInterval(1)
	EndEvent
	Event OnSliderAcceptST(float value)
		iMaxRolls = value as int
		SetSliderOptionValueST(iMaxRolls)
	EndEvent
	Event OnHighlightST()
		SetInfoText("How many times can a single Container check for Drops?\n(This will roll for Trapped & Non-Trapped Toys for each check respectively)")
	EndEvent
EndState

; ==================================
; 			States /// Loot Table
; ==================================
State TableSelect
	Event OnMenuOpenST()
		SetMenuDialogStartIndex(presetIndex)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(lootPresets)
	EndEvent
	Event OnMenuAcceptST(int index)
		presetIndex = index
		SetMenuOptionValueST(lootPresets[presetIndex])
		string[] keyfile = StringListToArray(filepath, lootPresets[presetIndex])
		dragonKey = keyfile[0]
		npcKey = keyfile[1]
		undeadKey = keyfile[2]
		preyKey = keyfile[3]
		miscKey = keyfile[4]
		chestRareKey = keyfile[5]
		chestKey = keyfile[6]
		Utility.WaitMenuMode(0.1)
		ForcePageReset()
	EndEvent
	Event OnDefaultST()
		presetIndex = 0
		SetMenuOptionValueST(lootPresets[presetIndex])
		ForcePageReset()
	EndEvent
	Event OnHighlightST()
		SetInfoText("Change your Preset. A Preset dictates how likely certain drops are from chests.")
	endEvent
EndState

State KeyChance
	Event OnSliderOpenST()
		SetSliderDialogStartValue(fKeyChance)
		SetSliderDialogDefaultValue(5)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(0.5)
	EndEvent
	Event OnSliderAcceptST(float value)
		fKeyChance = value
		SetSliderOptionValueST(fKeyChance, "{1}%")
	EndEvent
	Event OnHighlightST()
		SetInfoText("Chance for a Key to appear in a Container.")
	EndEvent
EndState

State KeyRoles
	Event OnSliderOpenST()
		SetSliderDialogStartValue(fKeyRoleChance)
		SetSliderDialogDefaultValue(40)
		SetSliderDialogRange(0, 60)
		SetSliderDialogInterval(0.5)
	EndEvent
	Event OnSliderAcceptST(float value)
		fKeyRoleChance = value
		SetSliderOptionValueST(fKeyRoleChance, "{1}%")
	EndEvent
	Event OnHighlightST()
		SetInfoText("When a Key Drops, how likely is it for a second one to drop?\n*Base Chance for Key Drops is defined inside the Loot Tables.\nChance will decrease with every drop, maximum of 5 Keys can drop at once. Set to 0 to disable.")
	EndEvent
EndState

State KeyWeight0
	Event OnSliderOpenST()
		SetSliderDialogStartValue(iKeyWeightBasic)
		SetSliderDialogDefaultValue(60)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	EndEvent
	Event OnSliderAcceptST(float value)
		iKeyWeightBasic = value as int
		SetSliderOptionValueST(iKeyWeightBasic)
	EndEvent
	Event OnHighlightST()
		SetInfoText("Relative Chance of getting a regular Key.")
	EndEvent
EndState

State KeyWeight1
	Event OnSliderOpenST()
		SetSliderDialogStartValue(iKeyWeightBasicTiny)
		SetSliderDialogDefaultValue(50)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	EndEvent
	Event OnSliderAcceptST(float value)
		iKeyWeightBasicTiny = value as int
		SetSliderOptionValueST(iKeyWeightBasicTiny)
	EndEvent
	Event OnHighlightST()
		SetInfoText("Relative Chance of getting a regular tiny Key.")
	EndEvent
EndState

State KeyWeight2
	Event OnSliderOpenST()
		SetSliderDialogStartValue(iKeyWeightBasicExotic)
		SetSliderDialogDefaultValue(15)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	EndEvent
	Event OnSliderAcceptST(float value)
		iKeyWeightBasicExotic = value as int
		SetSliderOptionValueST(iKeyWeightBasicExotic)
	EndEvent
	Event OnHighlightST()
		SetInfoText("Relative Chance of getting an Exotic Key.")
	EndEvent
EndState

State KeyWeight3
	Event OnSliderOpenST()
		SetSliderDialogStartValue(iKeyWeightBasicExoticTiny)
		SetSliderDialogDefaultValue(10)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	EndEvent
	Event OnSliderAcceptST(float value)
		iKeyWeightBasicExoticTiny = value as int
		SetSliderOptionValueST(iKeyWeightBasicExoticTiny)
	EndEvent
	Event OnHighlightST()
		SetInfoText("Relative Chance of getting a tiny Exotic Key.")
	EndEvent
EndState

; ==================================
; 				NON-STATE OPTIONS
; ==================================
Event OnOptionSliderOpen(int option)
	If(option == oTTypeHand)
		SetSliderDialogStartValue(TTypeWeightHand)
		SetSliderDialogDefaultValue(30)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf (option == oTTypeFeet)
		SetSliderDialogStartValue(TTypeWeightFeet)
		SetSliderDialogDefaultValue(40)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf (option == oTTypeMouth)
		SetSliderDialogStartValue(TTypeWeightMouth)
		SetSliderDialogDefaultValue(70)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf (option == oTTypeNeck)
		SetSliderDialogStartValue(TTypeWeightNeck)
		SetSliderDialogDefaultValue(60)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf (option == oTTypeWrists)
		SetSliderDialogStartValue(TTypeWeightWrists)
		SetSliderDialogDefaultValue(20)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf (option == oTTypeAnal)
		SetSliderDialogStartValue(TTypeWeightAnal)
		SetSliderDialogDefaultValue(40)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf (option == oTTypePelvis)
		SetSliderDialogStartValue(TTypeWeightPelvis)
		SetSliderDialogDefaultValue(50)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf (option == oTTypeGenital)
		SetSliderDialogStartValue(TTypeWeightGenital)
		SetSliderDialogDefaultValue(40)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf (option == oTTypeNipples)
		SetSliderDialogStartValue(TTypeWeightNipples)
		SetSliderDialogDefaultValue(80)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf (option == oTTypeLegs)
		SetSliderDialogStartValue(TTypeWeightLegs)
		SetSliderDialogDefaultValue(60)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf (option == oTTypeEyes)
		SetSliderDialogStartValue(TTypeWeightEyes)
		SetSliderDialogDefaultValue(30)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf (option == oTTypeBreasts)
		SetSliderDialogStartValue(TTypeWeightBreasts)
		SetSliderDialogDefaultValue(20)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf (option == oTTypeVaginal)
		SetSliderDialogStartValue(TTypeWeightVaginal)
		SetSliderDialogDefaultValue(40)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf (option == oTTypeTorso)
		SetSliderDialogStartValue(TTypeWeightTorso)
		SetSliderDialogDefaultValue(70)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf (option == oTTypeArms)
		SetSliderDialogStartValue(TTypeWeightArms)
		SetSliderDialogDefaultValue(60)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	EndIf
EndEvent

Event OnOptionSliderAccept(int option, float value)
	If(option == oTTypeHand)
		TTypeWeightHand = value as int
		SetSliderOptionValue(oTTypeHand, TTypeWeightHand)
	ElseIf(option == oTTypeFeet)
		TTypeWeightFeet = value as int
		SetSliderOptionValue(oTTypeFeet, TTypeWeightFeet)
	ElseIf(option == oTTypeMouth)
		TTypeWeightMouth = value as int
		SetSliderOptionValue(oTTypeMouth, TTypeWeightMouth)
	ElseIf(option == oTTypeNeck)
		TTypeWeightNeck = value as int
		SetSliderOptionValue(oTTypeNeck, TTypeWeightNeck)
	ElseIf(option == oTTypeWrists)
		TTypeWeightWrists = value as int
		SetSliderOptionValue(oTTypeWrists, TTypeWeightWrists)
	ElseIf(option == oTTypeAnal)
		TTypeWeightAnal = value as int
		SetSliderOptionValue(oTTypeAnal, TTypeWeightAnal)
	ElseIf(option == oTTypePelvis)
		TTypeWeightPelvis = value as int
		SetSliderOptionValue(oTTypePelvis, TTypeWeightPelvis)
	ElseIf(option == oTTypeGenital)
		TTypeWeightGenital = value as int
		SetSliderOptionValue(oTTypeGenital, TTypeWeightGenital)
	ElseIf(option == oTTypeNipples)
		TTypeWeightNipples = value as int
		SetSliderOptionValue(oTTypeNipples, TTypeWeightNipples)
	ElseIf(option == oTTypeLegs)
		TTypeWeightLegs = value as int
		SetSliderOptionValue(oTTypeLegs, TTypeWeightLegs)
	ElseIf(option == oTTypeEyes)
		TTypeWeightEyes = value as int
		SetSliderOptionValue(oTTypeEyes, TTypeWeightEyes)
	ElseIf(option == oTTypeBreasts)
		TTypeWeightBreasts = value as int
		SetSliderOptionValue(oTTypeBreasts, TTypeWeightBreasts)
	ElseIf(option == oTTypeVaginal)
		TTypeWeightVaginal = value as int
		SetSliderOptionValue(oTTypeVaginal, TTypeWeightVaginal)
	ElseIf(option == oTTypeTorso)
		TTypeWeightTorso = value as int
		SetSliderOptionValue(oTTypeTorso, TTypeWeightTorso)
	ElseIf(option == oTTypeArms)
		TTypeWeightArms = value as int
		SetSliderOptionValue(oTTypeArms, TTypeWeightArms)
	EndIf
EndEvent

; ------------------------- Utility
int Function getFlagFloat(float val)
	If(val)
		return OPTION_FLAG_NONE
	else
		return OPTION_FLAG_DISABLED
	EndIf
EndFunction

; State hahaha
; 	Event OnSelectST()
; 		IntListAdd(filepath, "balanced", 35)
; 		IntListAdd(filepath, "balanced", 35)
; 		IntListAdd(filepath, "balanced", 30)
; 		StringListAdd(filepath, " Easy", "risky")
; 		StringListAdd(filepath, " Easy", "forgiving")
; 		StringListAdd(filepath, " Easy", "balanced")
; 		StringListAdd(filepath, " Easy", "merciful")
; 		StringListAdd(filepath, " Easy", "forgiving")
; 		StringListAdd(filepath, " Easy", "simple")
; 		StringListAdd(filepath, " Easy", "balanced")
; 	EndEvent
; EndState
