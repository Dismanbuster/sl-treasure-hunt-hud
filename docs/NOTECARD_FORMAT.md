# Treasure Hunt Notecard Format

## How to Use
1. Create a notecard in your Second Life inventory
2. Name it exactly: **TreasureLocations**
3. Copy the entries below into the notecard
4. Paste the notecard into your HUD prim
5. The HUD will automatically load and parse the entries

## Format
Each line: `RegionName|SearchWord|XPReward|Season`

**Important:**
- Use pipe character `|` to separate fields
- RegionName must match EXACTLY (case-sensitive)
- SearchWord is what the HUD will sensor for (case-insensitive)
- XPReward is an integer (no decimals)
- Season: `all`, `halloween`, `christmas`, `easter`, `summer`, or custom

## Example Entries

```
# Core Hunt Locations (Available Year-Round)
The Dock|Chest|100|all
The Plaza|Statue|120|all
The Ruins|Urn|150|all
The Garden|Throne|180|all
The Beach|Anchor|100|all

# Halloween Hunt (Oct 1 - Oct 31)
Spooky Manor|Pumpkin|200|halloween
Graveyard|Coffin|250|halloween
Haunted Forest|Skull|150|halloween

# Christmas Hunt (Dec 1 - Dec 25)
Winter Village|Wreath|200|christmas
Snowy Peak|Bell|180|christmas
Frozen Lake|Gift|220|christmas

# Easter Hunt (Apr 1 - Apr 30)
Spring Meadow|Egg|150|easter
Garden Grove|Bunny|140|easter
Flower Field|Basket|160|easter

# Summer Hunt (Jun 1 - Aug 31)
Tropical Beach|Shell|120|summer
Coral Reef|Treasure Chest|200|summer
Waterfall Grove|Gem|180|summer

# Medieval/Themed Regions
Castle Keep|Crown|300|all
Dragon Lair|Dragon Egg|350|all
Pirate Cove|Gold Stash|250|all
Wizard Tower|Potion Bottle|200|all
Ancient Temple|Idol|280|all
```

## Adding Your Own Locations

To add a new treasure hunt location:

1. **Visit the location** in Second Life
2. **Place an object** you want to hide (or find an existing one)
3. **Note the object name** exactly as it appears
4. **Get the region name** (shown in top-left of SL client)
5. **Add a line** to your notecard:
   ```
   YourRegionName|ObjectName|XPValue|Season
   ```

### Object Naming Tips
- Keep names short and descriptive: `Chest`, `Statue`, `Crown`
- Avoid special characters (use names the HUD can easily sensor for)
- Case doesn't matter for the search—`chest`, `Chest`, `CHEST` all work
- If object name has spaces, that's fine: `Gold Stash`, `Dragon Egg`

## Example Custom Entry
```
MySecretIsland|Hidden Idol|500|all
```

Then place (or find) an object named "Hidden Idol" on that island, and the HUD will detect it!

## Testing Your Notecard

1. Attach the HUD to yourself
2. Touch it to see status
3. Teleport to one of the locations in your notecard
4. The HUD should:
   - Announce the region
   - Award +10 XP for first visit
   - Display the search word in the HUD text
   - Sensor for the object within 20 meters
   - Award XP if found

---

**Troubleshooting:**
- If HUD says "No hunt configured for this region" → Region name doesn't match notecard exactly
- If "No X detected nearby" → Object isn't within 20m of you, or object name doesn't match search word
- If notecard won't load → Make sure it's named exactly `TreasureLocations`
