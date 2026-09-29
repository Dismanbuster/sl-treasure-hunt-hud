// Treasure Hunt HUD v2 - Persistent Notecard System
// Stores location data and search criteria in a notecard that survives logoffs
// Format: RegionName|SearchCriteria|XPReward|Season

string NOTECARD_NAME = "TreasureLocations";
key gNoteCardQuery = NULL_KEY;
integer gLineNumber = 0;

string gCurrentRegion = "";
string gLastRegion = "";
integer gTotalXP = 0;
list gVisitedLocations = [];
list gFoundTreasures = [];

// Locations loaded from notecard
list gLocations = [];  // Will be populated from notecard

integer gDebugMode = 1;

integer GetLocationIndex(string locationName)
{
    integer i;
    integer len = llGetListLength(gLocations);
    for (i = 0; i < len; i += 4)
    {
        if (llList2String(gLocations, i) == locationName)
            return i;
    }
    return -1;
}

integer HasVisited(string locationName)
{
    return llListFindList(gVisitedLocations, [locationName]) != -1;
}

integer HasFoundTreasure(string treasureName)
{
    return llListFindList(gFoundTreasures, [treasureName]) != -1;
}

AwardXP(integer xp, string reason)
{
    gTotalXP += xp;
    llOwnerSay("║ XP +" + (string)xp + " │ " + reason);
    UpdateHUDDisplay();
}

UpdateHUDDisplay()
{
    integer avatarCount = llGetRegionAgentCount();
    string searchCriteria = "";
    
    // Get search criteria for current region
    integer idx = GetLocationIndex(gCurrentRegion);
    if (idx != -1)
    {
        searchCriteria = llList2String(gLocations, idx + 1);
    }
    
    string display = "═══════════════════════════\n";
    display += "XP: " + (string)gTotalXP + "\n";
    display += "Region: " + gCurrentRegion + "\n";
    display += "Avatars: " + (string)avatarCount + "\n";
    if (searchCriteria != "")
    {
        display += "Search: " + searchCriteria + "\n";
    }
    display += "Found: " + (string)llGetListLength(gFoundTreasures) + "\n";
    display += "═══════════════════════════";
    
    llSetText(display, <0.2, 1.0, 0.2>, 1.0);
}

LoadLocationNotecard()
{
    gLocations = [];  // Clear existing
    gLineNumber = 0;
    llOwnerSay("Loading treasure locations from notecard...");
    gNoteCardQuery = llGetNotecardLine(NOTECARD_NAME, gLineNumber);
}

ProcessNoteCardLine(string line)
{
    // Skip empty lines and comments
    if (line == "" || llGetSubString(line, 0, 0) == "#")
        return;
    
    // Parse: RegionName|SearchCriteria|XPReward|Season
    list parts = llParseString2List(line, ["|"], []);
    
    if (llGetListLength(parts) >= 4)
    {
        string region = llStringTrim(llList2String(parts, 0), STRING_TRIM);
        string search = llStringTrim(llList2String(parts, 1), STRING_TRIM);
        integer xp = llList2Integer(parts, 2);
        string season = llStringTrim(llList2String(parts, 3), STRING_TRIM);
        
        gLocations += [region, search, xp, season];
        
        if (gDebugMode)
            llOwnerSay("✓ Loaded: " + region + " | Search: " + search + " | XP: " + (string)xp + " | Season: " + season);
    }
}

SearchForTreasure()
{
    integer idx = GetLocationIndex(gCurrentRegion);
    if (idx == -1)
    {
        // Don't spam if region not in hunt list
        return;
    }
    
    string searchCriteria = llList2String(gLocations, idx + 1);
    integer treasureXP = llList2Integer(gLocations, idx + 2);
    string season = llList2String(gLocations, idx + 3);
    
    if (gDebugMode)
        llOwnerSay("▶ Searching for: " + searchCriteria);
    
    // Sensor with search criteria (20m radius, 180° sweep)
    llSensor(searchCriteria, NULL_KEY, SCRIPTED, 20.0, PI);
}

CheckRegionChange()
{
    string newRegion = llGetRegionName();
    
    if (newRegion != gLastRegion)
    {
        gCurrentRegion = newRegion;
        gLastRegion = newRegion;
        
        llOwnerSay("\n▶ Entered region: " + gCurrentRegion);
        
        // Check if this region is in our hunt list
        if (GetLocationIndex(gCurrentRegion) != -1)
        {
            // Award XP for visiting location
            if (!HasVisited(gCurrentRegion))
            {
                gVisitedLocations += [gCurrentRegion];
                AwardXP(10, "First visit to " + gCurrentRegion);
            }
            else
            {
                llOwnerSay("  (Previously visited)");
            }
            
            // Look for treasure
            SearchForTreasure();
        }
        else
        {
            llOwnerSay("  (No hunt configured for this region)");
        }
        
        UpdateHUDDisplay();
    }
}

default
{
    state_entry()
    {
        llOwnerSay("✓ Treasure HUD v2 Online - Loading locations...");
        UpdateHUDDisplay();
        LoadLocationNotecard();
    }

    dataserver(key query_id, string data)
    {
        if (query_id == gNoteCardQuery)
        {
            if (data == EOF)
            {
                llOwnerSay("✓ Loaded " + (string)(llGetListLength(gLocations) / 4) + " treasure locations");
                llSetTimerEvent(2.0);  // Start checking for region changes
                UpdateHUDDisplay();
            }
            else
            {
                ProcessNoteCardLine(data);
                gLineNumber++;
                gNoteCardQuery = llGetNotecardLine(NOTECARD_NAME, gLineNumber);
            }
        }
    }

    timer()
    {
        CheckRegionChange();
    }

    sensor(integer num_detected)
    {
        integer idx = GetLocationIndex(gCurrentRegion);
        if (idx == -1)
            return;

        string searchCriteria = llList2String(gLocations, idx + 1);
        integer treasureXP = llList2Integer(gLocations, idx + 2);

        integer i;
        for (i = 0; i < num_detected; ++i)
        {
            string objName = llDetectedName(i);
            
            // Case-insensitive comparison
            if (llToLower(objName) == llToLower(searchCriteria))
            {
                if (!HasFoundTreasure(searchCriteria))
                {
                    gFoundTreasures += [searchCriteria];
                    AwardXP(treasureXP, "Found " + objName + "!");
                    llOwnerSay("  ★ Treasure discovered!");
                }
                else
                {
                    llOwnerSay("  ◆ " + objName + " already found.");
                }
                return;
            }
        }
        
        if (gDebugMode)
            llOwnerSay("  ✗ " + searchCriteria + " not detected within 20m");
    }

    no_sensor()
    {
        integer idx = GetLocationIndex(gCurrentRegion);
        if (idx != -1 && gDebugMode)
        {
            string searchCriteria = llList2String(gLocations, idx + 1);
            llOwnerSay("  ✗ No " + searchCriteria + " detected nearby");
        }
    }

    touch_start(integer num_detected)
    {
        llOwnerSay("\n════════ HUD STATUS ════════");
        llOwnerSay("Total XP: " + (string)gTotalXP);
        llOwnerSay("Region: " + gCurrentRegion);
        llOwnerSay("Avatars: " + (string)llGetRegionAgentCount());
        llOwnerSay("Locations Visited: " + (string)llGetListLength(gVisitedLocations));
        llOwnerSay("Treasures Found: " + (string)llGetListLength(gFoundTreasures));
        llOwnerSay("Loaded Hunt Locations: " + (string)(llGetListLength(gLocations) / 4));
        llOwnerSay("═════════════════════════════");
    }

    changed(integer change)
    {
        if (change & CHANGED_REGION)
        {
            gCurrentRegion = llGetRegionName();
            gLastRegion = gCurrentRegion;
            CheckRegionChange();
        }
    }
}
