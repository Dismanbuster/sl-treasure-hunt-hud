// Treasure Hunt HUD - Location to Location v1
// Detects when player changes regions and looks for hidden treasures

string gCurrentRegion = "";
string gLastRegion = "";
integer gTotalXP = 0;
list gVisitedLocations = [];
list gFoundTreasures = [];

// Location Data: [RegionName, TreasureObjectName, XP_Reward]
list gLocations = [
    "The Dock", "Anchor", 100,
    "The Plaza", "Clock", 100,
    "The Ruins", "Stone", 100,
    "The Garden", "Rose", 100,
    "The Beach", "Shell", 100
];

integer GetLocationIndex(string locationName)
{
    integer i;
    integer len = llGetListLength(gLocations);
    for (i = 0; i < len; i += 3)
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
    string display = "═══════════════════\n";
    display += "XP: " + (string)gTotalXP + "\n";
    display += "Region: " + gCurrentRegion + "\n";
    display += "Avatars: " + (string)avatarCount + "\n";
    display += "Treasures Found: " + (string)llGetListLength(gFoundTreasures) + "\n";
    display += "═══════════════════";
    
    llSetText(display, <0.2, 1.0, 0.2>, 1.0);
}

CheckRegionChange()
{
    string newRegion = llGetRegionName();
    
    if (newRegion != gLastRegion)
    {
        gCurrentRegion = newRegion;
        gLastRegion = newRegion;
        
        llOwnerSay("\n▶ Entered region: " + gCurrentRegion);
        
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
        
        // Look for treasure in this location
        SearchForTreasure();
    }
}

SearchForTreasure()
{
    integer idx = GetLocationIndex(gCurrentRegion);
    if (idx == -1)
    {
        llOwnerSay("  No treasure configured for this region.");
        return;
    }
    
    string treasureName = llList2String(gLocations, idx + 1);
    integer treasureXP = llList2Integer(gLocations, idx + 2);
    
    llOwnerSay("  Searching for: " + treasureName);
    
    // Sensor for the specific treasure object (20m radius, 180° sweep)
    llSensor(treasureName, NULL_KEY, SCRIPTED, 20.0, PI);
}

default
{
    state_entry()
    {
        llOwnerSay("✓ Treasure HUD Online");
        UpdateHUDDisplay();
        llSetTimerEvent(2.0);  // Check every 2 seconds for region change
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

        string treasureName = llList2String(gLocations, idx + 1);
        integer treasureXP = llList2Integer(gLocations, idx + 2);

        integer i;
        for (i = 0; i < num_detected; ++i)
        {
            string objName = llDetectedName(i);
            
            if (objName == treasureName)
            {
                if (!HasFoundTreasure(treasureName))
                {
                    gFoundTreasures += [treasureName];
                    AwardXP(treasureXP, "Found " + treasureName + "!");
                    llOwnerSay("  ★ Treasure discovered!");
                }
                else
                {
                    llOwnerSay("  ◆ " + treasureName + " already found.");
                }
                return;
            }
        }
    }

    no_sensor()
    {
        integer idx = GetLocationIndex(gCurrentRegion);
        if (idx != -1)
        {
            string treasureName = llList2String(gLocations, idx + 1);
            llOwnerSay("  ✗ " + treasureName + " not yet found (within 20m)");
        }
    }

    touch_start(integer num_detected)
    {
        llOwnerSay("\n═══ HUD STATUS ═══");
        llOwnerSay("Total XP: " + (string)gTotalXP);
        llOwnerSay("Region: " + gCurrentRegion);
        llOwnerSay("Avatars: " + (string)llGetRegionAgentCount());
        llOwnerSay("Locations Visited: " + (string)llGetListLength(gVisitedLocations));
        llOwnerSay("Treasures Found: " + (string)llGetListLength(gFoundTreasures));
        llOwnerSay("═══════════════════");
    }

    changed(integer change)
    {
        if (change & CHANGED_REGION)
        {
            gCurrentRegion = llGetRegionName();
            gLastRegion = gCurrentRegion;
            llOwnerSay("▶ Changed region to: " + gCurrentRegion);
            SearchForTreasure();
        }
    }
}
