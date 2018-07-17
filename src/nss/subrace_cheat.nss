#include "inc_server"
#include "sfsubr_consts"
#include "db_inc"
#include "nwnx_creature"
#include "nwnx_admin"

//:://////////////////////////////////////////////////////////////
//:: Anti-Cheat script that checks a new player's stats/feats/etc.
//:://////////////////////////////////////////////////////////////

//Get the points of a statistic, if outside range, return 9999
int CheckStats(int iScore)
{
    switch (iScore)
    {
        case 8:  return 0;
        case 9:  return 1;
        case 10: return 2;
        case 11: return 3;
        case 12: return 4;
        case 13: return 5;
        case 14: return 6;
        case 15: return 8;
        case 16: return 10;
        case 17: return 13;
        case 18: return 16;
    }
    return 9999;
}

//Check starting statistic of PC
int GetHasValidAbilities(object oPC)
{
    int iPoints = 0;
    int iCha = GetAbilityScore(oPC, ABILITY_CHARISMA);
    int iCon = GetAbilityScore(oPC, ABILITY_CONSTITUTION);
    int iDex = GetAbilityScore(oPC, ABILITY_DEXTERITY);
    int iInt = GetAbilityScore(oPC, ABILITY_INTELLIGENCE);
    int iStr = GetAbilityScore(oPC, ABILITY_STRENGTH);
    int iWis = GetAbilityScore(oPC, ABILITY_WISDOM);
    switch(GetRacialType(oPC))
    {
         case RACIAL_TYPE_DWARF:    { iCha+=2; iCon-=2; break;}
         case RACIAL_TYPE_ELF:      { iCon+=2; iDex-=2; break;}
         case RACIAL_TYPE_GNOME:    { iStr+=2; iCon-=2; break;}
         case RACIAL_TYPE_HALFELF:  { break;}
         case RACIAL_TYPE_HALFLING: { iStr+=2; iDex-=2; break;}
         case RACIAL_TYPE_HALFORC:  { iCha+=2; iStr-=2; iInt+=2; break;}
         case RACIAL_TYPE_HUMAN:    {  break;}
         default: { return FALSE; }
    }
    //get the point value of each stat
    iPoints += CheckStats(iCha);
    iPoints += CheckStats(iCon);
    iPoints += CheckStats(iDex);
    iPoints += CheckStats(iInt);
    iPoints += CheckStats(iStr);
    iPoints += CheckStats(iWis);
    //check
    if (iPoints > 30)
        return FALSE;
    else
        return TRUE;
}
int GetHasInvalidFeats(object oPC)
{
    int nFeat = 427;    // start from FEAT_RESIST_ENERGY_COLD
    while (nFeat < 870) // stop at FEAT_EPIC_LASTING_INSPIRATION
    {
        if(GetHasFeat(nFeat, oPC))
            return TRUE;
        else
            nFeat++;
    }

    nFeat = 872;        // start from FEAT_EPIC_WILD_SHAPE_UNDEAD
    while (nFeat < 910) // stop at FEAT_EXTRA_SMITING
    {
    if(GetHasFeat(nFeat, oPC))
        return TRUE;
    else
        nFeat++;
    }

    nFeat = 917;// start from FEAT_EPIC_SKILL_FOCUS_BLUFF
    while (nFeat < 943) // stop at FEAT_WEAPON_OF_CHOICE_TWOBLADEDSWORD
    {
        if(GetHasFeat(nFeat, oPC))
            return TRUE;
        else
            nFeat++;
    }

    nFeat = 953;// start from FEAT_EPIC_DEVASTATING_CRITICAL_DWAXE
    while (nFeat < 1071) // stop at FEAT_EPIC_SUPERIOR_WEAPON_FOCUS
    {
        if(GetHasFeat(nFeat, oPC))
            return TRUE;
        else
            nFeat++;
    }

    nFeat = 214;// start from FEAT_DIAMOND_BODY
    while (nFeat < 216) // stop at FEAT_PERFECT_SELF
    {
        if(GetHasFeat(nFeat, oPC))
            return TRUE;
        else
            nFeat++;
    }

    nFeat = 222;// start from FEAT_CRIPPLING_STRIKE
    while (nFeat < 226) // stop at FEAT_PERFECT_SELF
    {
        if(GetHasFeat(nFeat, oPC))
            return TRUE;
        else
            nFeat++;
    }

    nFeat = 251;// start from FEAT_UNCANNY_DODGE_2
    while (nFeat < 255) // stop at FEAT_UNCANNY_DODGE_6
    {
        if(GetHasFeat(nFeat, oPC))
            return TRUE;
        else
            nFeat++;
    }

    nFeat = 345;// start from FEAT_UNCANNY_DODGE_2
    while (nFeat < 353) // stop at FEAT_UNCANNY_DODGE_6
    {
        if(GetHasFeat(nFeat, oPC))
            return TRUE;
        else
            nFeat++;
    }

    if( GetHasFeat(195, oPC) ||
        GetHasFeat(259, oPC) ||
        GetHasFeat(296, oPC) ||
        GetHasFeat(297, oPC) ||
        GetHasFeat(409, oPC) ||
        GetHasFeat(412, oPC))
    {
        return TRUE;
    }

    nFeat = 947;        // start from FEAT_EPIC_DEVASTATING_CRITICAL_DWAXE
    while (nFeat < 951) // stop at FEAT_EPIC_SUPERIOR_WEAPON_FOCUS
    {
        if(GetHasFeat(nFeat, oPC))
            return TRUE;
        else
            nFeat++;
    }

    nFeat = 52;         // start from FEAT_IMPROVED_CRITICAL_DAGGER
    while (nFeat < 89)  // stop at FEAT_IMPROVED_CRITICAL_TWO_BLADED_SWORD
    {
        if(GetHasFeat(nFeat, oPC))
            return TRUE;
        else
            nFeat++;
    }

nFeat = 128;            // start from FEAT_WEAPON_SPECIALIZATION_DAGGER
    while (nFeat < 165) // stop at FEAT_WEAPON_SPECIALIZATION_TWO_BLADED_SWORD
    {
        if(GetHasFeat(nFeat, oPC))
            return TRUE;
        else
            nFeat++;
    }
    return FALSE;
}


//Checks that the number of start feats is below max for level/class combo
int GetHasValidFeatCount(object oPC)
{
    //base 1 feat
    int iMaxFeats = 1;
    //racial feat count
    switch(GetRacialType(oPC))
    {
        case RACIAL_TYPE_DWARF:    { iMaxFeats+=8; break;}
        case RACIAL_TYPE_ELF:      { iMaxFeats+=8; break;}
        case RACIAL_TYPE_GNOME:    { iMaxFeats+=9; break;}
        case RACIAL_TYPE_HALFELF:  { iMaxFeats+=6; break;}
        case RACIAL_TYPE_HALFLING: { iMaxFeats+=6; break;}
        case RACIAL_TYPE_HALFORC:  { iMaxFeats+=1; break;}
        case RACIAL_TYPE_HUMAN:    { iMaxFeats+=2; break;}
        default: { return FALSE; }
    }
    //class feat count
    switch(GetClassByPosition(1, oPC))
    {
        case CLASS_TYPE_BARBARIAN: { iMaxFeats+=7; break;}
        case CLASS_TYPE_BARD:      { iMaxFeats+=7; break;}
        case CLASS_TYPE_CLERIC:    { iMaxFeats+=9; break;}
        case CLASS_TYPE_DRUID:     { iMaxFeats+=7; break;}
        case CLASS_TYPE_FIGHTER:   { iMaxFeats+=7; break;}
        case CLASS_TYPE_MONK:      { iMaxFeats+=7; break;}
        case CLASS_TYPE_PALADIN:   { iMaxFeats+=10; break;}
        case CLASS_TYPE_RANGER:    { iMaxFeats+=11; break;}
        case CLASS_TYPE_ROGUE:     { iMaxFeats+=3; break;}
        case CLASS_TYPE_SORCERER:  { iMaxFeats+=3; break;}
        case CLASS_TYPE_WIZARD:    { iMaxFeats+=3; break;}
        default: { return FALSE; }
    }
    //count feats
    int iCount = 0;
    int iLoop = 0;
    string sFeats = "";
    while(iLoop < 1074)
    {
        if(GetHasFeat(iLoop, oPC)) 
        {
            iCount++;
            sFeats = sFeats + IntToString(iLoop) + ",";
        }
        iLoop++;
    }
    //check if the counted feats exceed the maximum allowed
    if (iCount > iMaxFeats)  
        return FALSE;
    else  
        return TRUE;
}

int SR_GetHasLegalHitpoints(object oPC)
{
    int nHD = 0;

    switch (GetClassByPosition(1, oPC))
    {
        case CLASS_TYPE_SORCERER:   nHD = 4; break;
        case CLASS_TYPE_WIZARD:     nHD = 4; break;
        case CLASS_TYPE_BARD:       nHD = 6; break;
        case CLASS_TYPE_ROGUE:      nHD = 6; break;
        case CLASS_TYPE_CLERIC:     nHD = 8; break;
        case CLASS_TYPE_DRUID:      nHD = 8; break;
        case CLASS_TYPE_MONK:       nHD = 8; break;
        case CLASS_TYPE_FIGHTER:    nHD = 10; break;
        case CLASS_TYPE_PALADIN:    nHD = 10; break;
        case CLASS_TYPE_RANGER:     nHD = 10; break;
        case CLASS_TYPE_BARBARIAN:  nHD = 12; break;
    }

    nHD += GetAbilityModifier(ABILITY_CONSTITUTION, oPC);
    nHD += GetHasFeat(FEAT_TOUGHNESS, oPC);

    return GetMaxHitPoints(oPC) == nHD;
}

const int MAX_SKILL_POINTS = 10;

int SR_GetHasLegalSkillPoints(object oPC)
{
    if  (GetSkillRank(SKILL_ANIMAL_EMPATHY, oPC, TRUE) <= MAX_SKILL_POINTS &&
            GetSkillRank(SKILL_APPRAISE, oPC, TRUE) <= MAX_SKILL_POINTS &&
            GetSkillRank(SKILL_BLUFF, oPC, TRUE)  <=MAX_SKILL_POINTS &&
            GetSkillRank(SKILL_CONCENTRATION, oPC, TRUE) <= MAX_SKILL_POINTS &&
            GetSkillRank(SKILL_CRAFT_ARMOR, oPC, TRUE)  <= MAX_SKILL_POINTS &&
            GetSkillRank(SKILL_CRAFT_TRAP, oPC, TRUE) <=MAX_SKILL_POINTS  &&
            GetSkillRank(SKILL_CRAFT_WEAPON, oPC, TRUE) <= MAX_SKILL_POINTS &&
            GetSkillRank(SKILL_DISABLE_TRAP, oPC, TRUE) <= MAX_SKILL_POINTS &&
            GetSkillRank(SKILL_DISCIPLINE, oPC, TRUE) <= MAX_SKILL_POINTS  &&
            GetSkillRank(SKILL_HEAL, oPC, TRUE)<= MAX_SKILL_POINTS  &&
            GetSkillRank(SKILL_HIDE, oPC, TRUE)<= MAX_SKILL_POINTS &&
            GetSkillRank(SKILL_INTIMIDATE, oPC, TRUE)  <= MAX_SKILL_POINTS &&
            GetSkillRank(SKILL_LISTEN, oPC, TRUE) <= MAX_SKILL_POINTS  &&
            GetSkillRank(SKILL_LORE, oPC, TRUE)<= MAX_SKILL_POINTS  &&
            GetSkillRank(SKILL_MOVE_SILENTLY, oPC, TRUE)<= MAX_SKILL_POINTS &&
            GetSkillRank(SKILL_OPEN_LOCK, oPC, TRUE) <= MAX_SKILL_POINTS  &&
            GetSkillRank(SKILL_PARRY, oPC, TRUE) <= MAX_SKILL_POINTS &&
            GetSkillRank(SKILL_PERFORM, oPC, TRUE)<= MAX_SKILL_POINTS  &&
            GetSkillRank(SKILL_PERSUADE, oPC, TRUE) <= MAX_SKILL_POINTS  &&
            GetSkillRank(SKILL_PICK_POCKET, oPC, TRUE)<= MAX_SKILL_POINTS  &&
            GetSkillRank(SKILL_SEARCH, oPC, TRUE) <= MAX_SKILL_POINTS &&
            GetSkillRank(SKILL_SET_TRAP, oPC, TRUE) <= MAX_SKILL_POINTS &&
            GetSkillRank(SKILL_SPELLCRAFT, oPC, TRUE)<= MAX_SKILL_POINTS &&
            GetSkillRank(SKILL_SPOT, oPC, TRUE) <= MAX_SKILL_POINTS  &&
            GetSkillRank(SKILL_TAUNT, oPC, TRUE) <= MAX_SKILL_POINTS  &&
            GetSkillRank(SKILL_TUMBLE, oPC, TRUE)<= MAX_SKILL_POINTS  &&
            GetSkillRank(SKILL_USE_MAGIC_DEVICE, oPC, TRUE) <= MAX_SKILL_POINTS)
            {
                return TRUE;
            }
            return FALSE;
}

void SR_HackerAction(object oPC)
{
    string sHackReason = GetDeity(oPC); //Uses the Diety field to check the character
    ExportSingleCharacter(oPC);
    
    SendMessageToAllDMs(GetName(oPC) + " has an invalid character: " + sHackReason + "\nCD Key: " + GetPCPublicCDKey(oPC));
    PrintString(GetName(oPC) + " has an invalid character: " + sHackReason + "\nCD Key: " + GetPCPublicCDKey(oPC));
    WriteTimestampedLogEntry(GetName(oPC) + " has an invalid character: " + sHackReason + "\nCD Key: " + GetPCPublicCDKey(oPC));

    //Freeze the character
    AssignCommand(oPC, ClearAllActions(TRUE));
    DelayCommand(0.2, AssignCommand(oPC, PopUpDeathGUIPanel(oPC, FALSE, FALSE, 0, "ERROR! Invalid Character:" + sHackReason)));
    DelayCommand(0.3, AssignCommand(oPC, SetCommandable(FALSE, oPC)));

    //Kick the character
    DelayCommand(9.3, NWNX_Administration_DeletePlayerCharacter(oPC));
}

string SR_GetIsValidName(string sName)
{
    string sReturn;
    int nNameLength = GetStringLength(sName);

    if (nNameLength > 50)
    {
        sReturn = "Charactername to long (max 40 character)";
    }
    else if (nNameLength < 1)
    {
        sReturn = "Charactername to short";
    }
    else if (FindSubString(sName, "~") != -1 ||
             FindSubString(sName, "")  != -1)
    {
        sReturn = "Player Name contain invalid character (tilde or seperator)";
    }
    return sReturn;
}

int SR_GetIsCharacterLegal(object oPC, string sName)
{
    if (GetSubRace(oPC) == "ILLEGAL_CHARACTER")
    {
        return FALSE;
    }

    int nIllegal = FALSE;
    string sIllegal = "";

    if (!GetHasValidFeatCount(oPC))
    {
        nIllegal ++;
        sIllegal += "\n'Illegal Feat Count'";
    }
    if (GetHasInvalidFeats(oPC))
    {
        nIllegal ++;
        sIllegal += "\n'Illegal Feats'";
    }
    if (!GetHasValidAbilities(oPC))
    {
        nIllegal ++;
        sIllegal += "\n'Illegal Ability Scores'";
    }
    if (!SR_GetHasLegalHitpoints(oPC))
    {
        nIllegal ++;
        sIllegal += "\n'Illegal Hitpoints'";
    }
    if (!SR_GetHasLegalSkillPoints(oPC))
    {
        nIllegal ++;
        sIllegal += "\n'Illegal Skill Points'";
    }
    string sValidName = SR_GetIsValidName(sName);
    if (sValidName != "") //Invalid name
    {
        nIllegal ++;
        sIllegal += "\n'" + sValidName + "'";
    }
    else //Name is valid, check unique
    {
        NWNX_SQL_ExecuteQuery("select logins from player where name like " + dbQuotes(GetName(oPC)));

        if (NWNX_SQL_ReadyToReadNextRow()) //Name created because it exists
        {
            NWNX_SQL_ReadNextRow();
            if (StringToInt(NWNX_SQL_ReadDataInActiveRow(0)) > 0)
            {
                nIllegal ++;
                sIllegal += "\n'Not a unique Player Name, please pick another one'";
            }
        }
    }
    if (nIllegal)
    {
        SetSubRace(oPC, "ILLEGAL_CHARACTER");   //Stops the subrace from being applied.
        SetDeity(oPC, sIllegal);                //Reason for being illegal
        SetLocalString(oPC, "BANNED", "1");     //This stops executing the OnClientExit
        DelayCommand(1.0, SR_HackerAction(oPC));
        return FALSE;
    }
    return TRUE;
}