Scriptname TTMCM extends SKI_ConfigBase

import JsonUtil
; -------------------------------- Properties
Actor Property PlayerRef Auto
; -------------------------------- Variables
string filepath = "../ToyfulTemptations/LootTable.json"
; --- General
; Drops
string[] lootTypeList
int Property iLootType = 0 Auto Hidden
float Property fBaseChance = 5.0 Auto Hidden
bool Property bSplitChance = false Auto Hidden
float Property fBaseChanceC = 2.0 Auto Hidden
float Property fBaseChanceD = 7.5 Auto Hidden
float Property fBaseChanceW = 4.0 Auto Hidden
float Property fArousalWeight = 0.4 Auto Hidden
; Container
String[] TrapMethods
int Property iMaxDrops = 2 Auto Hidden
float Property fSwapChance = 0.0 Auto Hidden
bool Property bFilterOwned = true Auto Hidden
bool Property bFilterEmpty = true Auto Hidden
int Property iTrapMethod = 2 Auto Hidden
bool Property bTrapStrip = false Auto Hidden
bool Property bNotifyOnTrap = false Auto Hidden
float Property fToyChance = 10.0 Auto Hidden
bool Property bMatchToy = true Auto Hidden
; Keys
float Property fKeyChance = 7.0 Auto Hidden
float Property fKeyChanceAdd = 30.0 Auto Hidden
int[] Property iKeyWeight Auto Hidden
{Key - 60, Tiny - 50, Exotic - 15, Tiny Exotic - 10}
; --- Events
int[] Property TTypeWeights Auto Hidden
{Hand - 30, Feet - 40, Mouth - 70, Neck - 60, Wrist - 20, Anal - 40, Pelvis - 50, Genital - 40, Nipples - 80, Legs - 60, Eyes - 30, Breast - 20, Vaginal - 40, Torso - 70, Arms - 60}

; ===============================================================
; =============================	STARTUP // UTILITY
; ===============================================================
int Function GetVersion()
	return 1
endFunction

Event OnVersionUpdate(int newVers)
	;
EndEvent

Event OnConfigInit()
	Pages = new string[2]
  Pages[0] = "$TT_General"
	Pages[1] = "$TT_Events"

	lootTypeList = new string[3]
	lootTypeList[0] = "$TT_LootType_0"
	lootTypeList[1] = "$TT_LootType_1"
	lootTypeList[2] = "$TT_LootType_2"

	TrapMethods = new String[3]
	TrapMethods[0] = "$TT_TrapMathoed_0"
	TrapMethods[1] = "$TT_TrapMathoed_1"
	TrapMethods[2] = "$TT_TrapMathoed_2"

	iKeyWeight = new int[4]
	iKeyWeight[0] = 60
	iKeyWeight[1] = 50
	iKeyWeight[2] = 40
	iKeyWeight[3] = 40

	TTypeWeights = new int[15]
	TTypeWeights[0] = 30
	TTypeWeights[1] = 40
	TTypeWeights[2] = 70
	TTypeWeights[3] = 60
	TTypeWeights[4] = 20
	TTypeWeights[5] = 40
	TTypeWeights[6] = 50
	TTypeWeights[7] = 40
	TTypeWeights[8] = 80
	TTypeWeights[9] = 60
	TTypeWeights[10] = 30
	TTypeWeights[11] = 20
	TTypeWeights[12] = 40
	TTypeWeights[13] = 70
	TTypeWeights[14] = 60
EndEvent

; ===============================================================
; =============================	MENU
; ===============================================================
Event OnPageReset(String Page)
  SetCursorFillMode(TOP_TO_BOTTOM)
  If(Page == "")
    Page = "$TT_General"
  EndIf
  If(Page == "$TT_General")
		AddHeaderOption("$TT_Drops")
		AddMenuOptionST("lootType", "$TT_LootType", lootTypeList[iLootType])
    AddSliderOptionST("baseChance", "$TT_BaseChance", fBaseChance, "{1}%", getFlag(!bSplitChance))
		AddToggleOptionST("splitChance", "$TT_SplitChance", bSplitChance)
    AddSliderOptionST("baseChanceC", "$TT_SplitChanceC", fBaseChanceC, "{1}%", getFlag(bSplitChance))
    AddSliderOptionST("baseChanceD", "$TT_SplitChanceD", fBaseChanceD, "{1}%", getFlag(bSplitChance))
    AddSliderOptionST("baseChanceW", "$TT_SplitChanceW", fBaseChanceW, "{1}%", getFlag(bSplitChance))
		AddEmptyOption()
		AddSliderOptionST("arousalWeight", "$TT_ArousalWeight", fArousalWeight, "{2}")
		SetCursorPosition(1)
		AddHeaderOption("$TT_Miscellaneous")
		AddSliderOptionST("MaxDrops", "$TT_MaxDrops", iMaxDrops)
		AddSliderOptionST("SwapChance", "$TT_SwapChance", fSwapChance, "{1}%")
		AddToggleOptionST("filterEmpty", "$TT_FilterEmpty", bFilterEmpty)
		AddToggleOptionST("filterOwned", "$TT_FilterOwned", bFilterOwned)
		AddMenuOptionST("trapMethod", "$TT_TrapMethod", TrapMethods[iTrapMethod])
		AddToggleOptionST("trapStrip", "$TT_TrapStrip", bTrapStrip)
		AddToggleOptionST("trapNotify", "$TT_TrapNotify", bNotifyOnTrap)
		AddSliderOptionST("regularToy", "$TT_ChanceRegular", fToyChance, "{1}%")
		AddToggleOptionST("equipMatching", "$TT_EquipMatching", bMatchToy)
		AddHeaderOption("$TT_Keys")
		AddSliderOptionST("KeyChance", "$TT_KeyChance", fKeyChance, "{1}%")
		AddSliderOptionST("KeyChanceAdd", "$TT_KeyChanceAdd", fKeyChanceAdd, "{1}%")
		int i = 0
		While(i < iKeyWeight.Length)
			AddSliderOptionST("keyWeight_" + i, "$TT_Key_" + i, iKeyWeight[i], "{0}")
			i += 1
		EndWhile
	ElseIf(Page == "$TT_Events")
		SetCursorFillMode(LEFT_TO_RIGHT)
		AddHeaderOption("$TT_Events")
		AddEmptyOption()
		int i = 0
		While(i < TTypeWeights.Length)
			AddSliderOptionST("TTWeight_" + i, "$TT_TType_" + i, TTypeWeights[i], "{0}")
			i += 1
		EndWhile
  EndIf
EndEvent

; ===============================================================
; =============================	TOGGLE OPTION
; ===============================================================
Event OnSelectST()
	String[] option = PapyrusUtil.StringSplit(GetState(), "_")
	If(option[0] == "splitChance")
		bSplitChance = !bSplitChance
		SetToggleOptionValueST(bSplitChance)
		SetOptionFlagsST(getFlag(!bSplitChance), true, "baseChance")
		SetOptionFlagsST(getFlag(bSplitChance), true, "baseChanceC")
		SetOptionFlagsST(getFlag(bSplitChance), true, "baseChanceD")
		SetOptionFlagsST(getFlag(bSplitChance), false, "baseChanceW")
	ElseIf(option[0] == "filterOwned")
		bFilterOwned = !bFilterOwned
		SetToggleOptionValueST(bFilterOwned)
	ElseIf(option[0] == "filterEmpty")
		bFilterEmpty = !bFilterEmpty
		SetToggleOptionValueST(bFilterEmpty)
	ElseIf(option[0] == "trapStrip")
		bTrapStrip = !bTrapStrip
		SetToggleOptionValueST(bTrapStrip)
	ElseIf(option[0] == "trapNotify")
		bNotifyOnTrap = !bNotifyOnTrap
		SetToggleOptionValueST(bNotifyOnTrap)
	ElseIf(option[0] == "equipMatching")
		bMatchToy = !bMatchToy
		SetToggleOptionValueST(bMatchToy)
	EndIf
EndEvent

; ===============================================================
; =============================	SLIDER OPTION
; ===============================================================
Event OnSliderOpenST()
	String[] option = PapyrusUtil.StringSplit(GetState(), "_")
	If(option[0] == "baseChance")
		SetSliderDialogStartValue(fBaseChance)
		SetSliderDialogDefaultValue(5)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(0.5)
	ElseIf(option[0] == "baseChanceC")
		SetSliderDialogStartValue(fBaseChanceC)
		SetSliderDialogDefaultValue(2)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(0.5)
	ElseIf(option[0] == "baseChanceD")
		SetSliderDialogStartValue(fBaseChanceD)
		SetSliderDialogDefaultValue(7.5)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(0.5)
	ElseIf(option[0] == "baseChanceW")
		SetSliderDialogStartValue(fBaseChanceW)
		SetSliderDialogDefaultValue(4)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(0.5)
	ElseIf(option[0] == "arousalWeight")
		SetSliderDialogStartValue(fArousalWeight)
		SetSliderDialogDefaultValue(0.3)
		SetSliderDialogRange(0, 1)
		SetSliderDialogInterval(0.01)
	ElseIf(option[0] == "MaxDrops")
		SetSliderDialogStartValue(iMaxDrops)
		SetSliderDialogDefaultValue(2)
		SetSliderDialogRange(1, 15)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "SwapChance")
		SetSliderDialogStartValue(fSwapChance)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(0.5)
	ElseIf(option[0] == "regularToy")
		SetSliderDialogStartValue(fToyChance)
		SetSliderDialogDefaultValue(10)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(0.5)
	ElseIf(option[0] == "KeyChance")
		SetSliderDialogStartValue(fKeyChance)
		SetSliderDialogDefaultValue(7)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(0.5)
	ElseIf(option[0] == "KeyChanceAdd")
		SetSliderDialogStartValue(fKeyChanceAdd)
		SetSliderDialogDefaultValue(30)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(0.5)
	ElseIf(option[0] == "keyWeight")
		int i = option[1] as int
		SetSliderDialogStartValue(iKeyWeight[i])
		SetSliderDialogDefaultValue(40)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	ElseIf(option[0] == "TTWeight")
		int i = option[1] as int
		SetSliderDialogStartValue(TTypeWeights[i])
		SetSliderDialogDefaultValue(50)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	EndIf
EndEvent

Event OnSliderAcceptST(Float afValue)
	String[] option = PapyrusUtil.StringSplit(GetState(), "_")
	If(option[0] == "baseChance")
		fBaseChance = afValue
		SetSliderOptionValueST(fBaseChance, "{1}%")
	ElseIf(option[0] == "baseChanceC")
		fBaseChanceC = afValue
		SetSliderOptionValueST(fBaseChanceC, "{1}%")
	ElseIf(option[0] == "baseChanceD")
		fBaseChanceD = afValue
		SetSliderOptionValueST(fBaseChanceD, "{1}%")
	ElseIf(option[0] == "baseChanceW")
		fBaseChanceW = afValue
		SetSliderOptionValueST(fBaseChanceW, "{1}%")
	ElseIf(option[0] == "arousalWeight")
		fArousalWeight = afValue
		SetSliderOptionValueST(fArousalWeight, "{2}")
	ElseIf(option[0] == "MaxDrops")
		iMaxDrops = afValue as Int
		SetSliderOptionValueST(iMaxDrops)
	ElseIf(option[0] == "SwapChance")
		fSwapChance = afValue
		SetSliderOptionValueST(fSwapChance, "{1}%")
	ElseIf(option[0] == "regularToy")
		fToyChance = afValue
		SetSliderOptionValueST(fToyChance, "{1}%")
	ElseIf(option[0] == "KeyChance")
		fKeyChance = afValue
		SetSliderOptionValueST(fKeyChance, "{1}%")
	ElseIf(option[0] == "KeyChanceAdd")
		fKeyChanceAdd = afValue
		SetSliderOptionValueST(fKeyChanceAdd, "{1}%")
	ElseIf(option[0] == "keyWeight")
		int i = option[1] as int
		iKeyWeight[i] = afValue as Int
		SetSliderOptionValueST(iKeyWeight[i])
	ElseIf(option[0] == "TTWeight")
		int i = option[1] as int
		TTypeWeights[i] = afValue as Int
		SetSliderOptionValueST(TTypeWeights[i])
	EndIf
EndEvent

; ===============================================================
; =============================	MENU OPTION
; ===============================================================
Event OnMenuOpenST()
	String[] option = PapyrusUtil.StringSplit(GetState(), "_")
	If(option[0] == "lootType")
		SetMenuDialogStartIndex(iLootType)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(lootTypeList)
	ElseIf(option[0] == "trapMethod")
		SetMenuDialogStartIndex(iTrapMethod)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(TrapMethods)
	EndIf
EndEvent

Event OnMenuAcceptST(Int aiIndex)
	String[] option = PapyrusUtil.StringSplit(GetState(), "_")
	If(option[0] == "lootType")
		iLootType = aiIndex
		SetMenuOptionValueST(lootTypeList[iLootType])
	ElseIf(option[0] == "trapMethod")
		iTrapMethod = aiIndex
		SetMenuOptionValueST(TrapMethods[iTrapMethod])
	EndIf
EndEvent

; ===============================================================
; =============================	HIGHLIGHTS
; ===============================================================
Event OnHighlightST()
	String[] option = PapyrusUtil.StringSplit(GetState(), "_")
	If(option[0] == "lootType")
		SetInfoText("$TT_LootTypeHighlight")
	ElseIf(option[0] == "splitChance")
		SetInfoText("$TT_SplitChanceHighlight")
	ElseIf(option[0] == "arousalWeight")
		SetInfoText("$TT_ArousalWeightHighlight")
	ElseIf(option[0] == "MaxDrops")
		SetInfoText("$TT_MaxDropsHighlight")
	ElseIf(option[0] == "SwapChance")
		SetInfoText("$TT_SwapChanceHighlight")
	ElseIf(option[0] == "FilterOwned")
		SetInfoText("$TT_FilterOwnedHighlight")
	ElseIf(option[0] == "FilterEmpty")
		SetInfoText("$TT_FilterEmptyHighlight")
	ElseIf(option[0] == "trapMethod")
		SetInfoText("$TT_TrapMethodHighlight")
	ElseIf(option[0] == "trapStrip")
		SetInfoText("$TT_TrapStripHighlight")
	ElseIf(option[0] == "trapNotify")
		SetInfoText("$TT_TrapNotifyHighlight")
	ElseIf(option[0] == "regularToy")
		SetInfoText("$TT_ChanceRegularHighlight")
	ElseIf(option[0] == "equipMatching")
		SetInfoText("$TT_EquipMatchingHighlight")
	ElseIf(option[0] == "KeyChance")
		SetInfoText("$TT_KeyChanceHighlight")
	ElseIf(option[0] == "KeyChanceAdd")
		SetInfoText("$TT_KeyChanceAddHighlight")
	EndIf
EndEvent

; ===============================================================
; =============================	UTILITY
; ===============================================================

; Return "NONE" flag if "option" parameter evaluates true
int Function getFlag(bool option)
	If(option)
		return OPTION_FLAG_NONE
	else
		return OPTION_FLAG_DISABLED
	EndIf
EndFunction