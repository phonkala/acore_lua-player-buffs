--------------------------------------------------
--  
--  Lua Player Buffs for AzerothCore @ https://github.com/azerothcore/azerothcore-wotlk
--  
--  Created by Grandold @ https://github.com/phonkala, Grandold#2267 @ Discord
--  Requires Eluna Lua Engine @ https://github.com/azerothcore/mod-eluna
--  
--------------------------------------------------
--  
--  This module is used to buff players based on class, spec and level range.
--  
--  The module was originally just a casual learning experience / introduction to
--  Lua language, but it actually seems quite handy on my private AzerothCore server!
--  
--  - Grandold
--  
--------------------------------------------------
--  
--  TO DO:
--  
--  * Remove spellHealthPoints and spellRageFromDamage completely (from DB too).
--  * Create spells from scratch, currectly using clones of spells from https://github.com/55Honey/Acore_ZoneDebuff
--    * We do not want damageDone and damageTaken buffs combined into one spell, actually we don't want damageTaken at all.
--    * Also we want baseStats and (melee and ranged) AP buffs separated into 2 different spells.
--    ** I could use some help here as I currently have no access to AzerothCore DB to re-create the spells. Feel free to pm me in Discord.
--  
--------------------------------------------------


local config = {}
local playerBuffs = {}


-- Config values.
config.isActive = 1
config.debug = 1


-- Function to set up the buffs.
--
-- classID          Unit class ID. 
-- talentSpecID     Unit specialization ID. Set to 0 to apply buff to all talent specs.
-- levelRequired    Required level for the buff to be applied.
-- buffTypeID       Buff type ID.
-- modifier         Modifier from original (not modified) value in percentage (no % character).
local function setPlayerBuff (classID, talentSpecID, levelRequired, buffTypeID, modifier)
    
    -- Create required object structure for storing data.
    if not playerBuffs[classID] then playerBuffs[classID] = {} end
    if not playerBuffs[classID][talentSpecID] then playerBuffs[classID][talentSpecID] = {} end
    if not playerBuffs[classID][talentSpecID][levelRequired] then playerBuffs[classID][talentSpecID][levelRequired] = {} end
    if not playerBuffs[classID][talentSpecID][levelRequired][buffTypeID] then playerBuffs[classID][talentSpecID][levelRequired][buffTypeID] = {} end
    
    playerBuffs[classID][talentSpecID][levelRequired][buffTypeID] = modifier
    
    if config.debug == 1 then
        print('[lua-player-buffs] Buff registered: classID: ' .. classID .. ', talentSpecID: ' .. talentSpecID ..
              ', levelRequired: ' .. levelRequired .. ', buffTypeID: ' .. buffTypeID .. ', modifier: ' .. modifier .. '(%)')
    end
    
end


-- IDs of classes and specs.
local CLASS_WARRIOR                 =    1
local     SPEC_WARRIOR_ARMS         =  161
local     SPEC_WARRIOR_FURY         =  164
local     SPEC_WARRIOR_PROTECTION   =  163
local CLASS_PALADIN                 =    2
local     SPEC_PALADIN_HOLY         =  382
local     SPEC_PALADIN_PROTECTION   =  383
local     SPEC_PALADIN_RETRIBUTION  =  381
local CLASS_HUNTER                  =    3
local     SPEC_HUNTER_BEASTMASTERY  =  361 -- ALL pets get automatically same buffs as their owners.
local     SPEC_HUNTER_MARKSMANSHIP  =  363 -- 
local     SPEC_HUNTER_SURVIVAL      =  362 --
local     PET_HUNTER_BEASTMASTERY   = 3610 -- Each hunter specialization pet buffs can be set separately too.
local     PET_HUNTER_MARKSMANSHIP   = 3630 -- This way it is possible to override the values inherited from 
local     PET_HUNTER_SURVIVAL       = 3620 -- hunter spec values to set different buffs for the hunter and the pet.
local CLASS_ROGUE                   =    4
local     SPEC_ROGUE_ASSASSINATION  =  182
local     SPEC_ROGUE_COMBAT         =  181
local     SPEC_ROGUE_SUBTLETY       =  183
local CLASS_PRIEST                  =    5
local     SPEC_PRIEST_DISCIPLINE    =  201
local     SPEC_PRIEST_HOLY          =  202
local     SPEC_PRIEST_SHADOW        =  203
local CLASS_DEATHKNIGHT             =    6
local     SPEC_DEATHKNIGHT_BLOOD    =  398
local     SPEC_DEATHKNIGHT_FROST    =  399
local     SPEC_DEATHKNIGHT_UNHOLY   =  400
local CLASS_SHAMAN                  =    7
local     SPEC_SHAMAN_ELEMENTAL     =  261
local     SPEC_SHAMAN_ENHANCEMENT   =  263
local     SPEC_SHAMAN_RESTORATION   =  262
local CLASS_MAGE                    =    8
local     SPEC_MAGE_ARCANE          =   81
local     SPEC_MAGE_FIRE            =   41
local     SPEC_MAGE_FROST           =   61
local CLASS_WARLOCK                 =    9
local     SPEC_WARLOCK_AFFLICTION   =  302
local     SPEC_WARLOCK_DEMONOLOY    =  303
local     SPEC_WARLOCK_DESTRUCTION  =  301
local CLASS_DRUID                   =   11
local     SPEC_DRUID_BALANCE        =  283
local     SPEC_DRUID_FERAL          =  281
local     SPEC_DRUID_RESTORATION    =  282


-- IDs of buff types.
local SPELL_BUFF_DAMAGE_DONE_TAKEN  =   1
local SPELL_BUFF_BASE_STATS_AP      =   2
local SPELL_BUFF_ABSORB_GIVEN       =   3
local SPELL_BUFF_HEALING_DONE       =   4


--------------------------------------------------
-- SET UP THE BUFFS.
--------------------------------------------------

-- Note: These are mostly just for demonstration purposes, please set up your own buffs however you like.
-- Class buffs (talentSpecID == 0) are always overridden by specific talent spec buffs of the same buff type.
-- Hunter pet buffs override previous hunter buff values of the same buff type for pets specifically.

-- Increase feral druid damage done and taken by 20% up to level 50 and by 10% up to level 75.
setPlayerBuff(CLASS_DRUID, SPEC_DRUID_FERAL, 0, SPELL_BUFF_DAMAGE_DONE_TAKEN, 20)
setPlayerBuff(CLASS_DRUID, SPEC_DRUID_FERAL, 50, SPELL_BUFF_DAMAGE_DONE_TAKEN, 10)
setPlayerBuff(CLASS_DRUID, SPEC_DRUID_FERAL, 75, SPELL_BUFF_DAMAGE_DONE_TAKEN, 0)

-- Reduce all hunter damage done and taken by 20% up to level 30 and by 10% up to level 70.
setPlayerBuff(CLASS_HUNTER, 0, 0, SPELL_BUFF_DAMAGE_DONE_TAKEN, -20)
setPlayerBuff(CLASS_HUNTER, 0, 30, SPELL_BUFF_DAMAGE_DONE_TAKEN, -10)
setPlayerBuff(CLASS_HUNTER, 0, 70, SPELL_BUFF_DAMAGE_DONE_TAKEN, 0)
-- Don't reduce survival hunter damage done and taken at all. This overrides (all) previous hunter buffs of same type.
setPlayerBuff(CLASS_HUNTER, SPEC_HUNTER_SURVIVAL, 0, SPELL_BUFF_DAMAGE_DONE_TAKEN, 0)

-- Reduce BM hunter pet damage by 10% all the way until level 80. These override previous hunter buffs of same type.
setPlayerBuff(CLASS_HUNTER, PET_HUNTER_BEASTMASTERY, 0, SPELL_BUFF_DAMAGE_DONE_TAKEN, -10)
setPlayerBuff(CLASS_HUNTER, PET_HUNTER_BEASTMASTERY, 80, SPELL_BUFF_DAMAGE_DONE_TAKEN, 0)










setPlayerBuff(CLASS_DRUID, SPEC_DRUID_FERAL, 0, SPELL_BUFF_DAMAGE_DONE_TAKEN, 20)
setPlayerBuff(CLASS_DRUID, SPEC_DRUID_FERAL, 50, SPELL_BUFF_DAMAGE_DONE_TAKEN, 10)
setPlayerBuff(CLASS_DRUID, SPEC_DRUID_FERAL, 75, SPELL_BUFF_DAMAGE_DONE_TAKEN, 0)

-- Reduce all hunter damage done and taken by 20% up to level 30 and by 10% up to level 70.
setPlayerBuff(CLASS_HUNTER, 0, 0, SPELL_BUFF_DAMAGE_DONE_TAKEN, -20)
setPlayerBuff(CLASS_HUNTER, 0, 30, SPELL_BUFF_DAMAGE_DONE_TAKEN, -10)
setPlayerBuff(CLASS_HUNTER, 0, 70, SPELL_BUFF_DAMAGE_DONE_TAKEN, 0)
-- Don't reduce survival hunter damage done and taken at all. This overrides (all) previous hunter buffs of same type.
setPlayerBuff(CLASS_HUNTER, SPEC_HUNTER_SURVIVAL, 0, SPELL_BUFF_DAMAGE_DONE_TAKEN, 0)

-- Reduce BM hunter pet damage by 10% all the way until level 80. These override previous hunter buffs of same type.
setPlayerBuff(CLASS_HUNTER, PET_HUNTER_BEASTMASTERY, 0, SPELL_BUFF_DAMAGE_DONE_TAKEN, -10)
setPlayerBuff(CLASS_HUNTER, PET_HUNTER_BEASTMASTERY, 80, SPELL_BUFF_DAMAGE_DONE_TAKEN, 0)









--------------------------------------------------
-- NO ADJUSTMENTS REQUIRED BELOW THIS LINE.
--------------------------------------------------


-- Set up the buff spell IDs.
config.spells = {}
config.spells.spellDamageDoneTaken  = 123001
config.spells.spellBaseStatAP       = 123002
config.spells.spellAbsorbGiven      = 123003
config.spells.spellHealingDone      = 123004


--
local function calculateTalentPoints (characterID, specID)
    
    specID = specID + 1
    
    local Q
    Q = CharDBQuery(
        [[
            SELECT
                `ct`.`guid` AS `guid`,
                `ct`.`spell` AS `spellID`,
                `ct`.`specMask` AS `specMask`,
                `dbct`.`TabID` AS `tabID`,
                `dbct`.`TierID` AS `tierID`,
                `dbct`.`ColumnIndex` AS `columnIndex`,
                `dbct`.`SpellRank[0]` AS `spellRank0`,
                `dbct`.`SpellRank[1]` AS `spellRank1`,
                `dbct`.`SpellRank[2]` AS `spellRank2`,
                `dbct`.`SpellRank[3]` AS `spellRank3`,
                `dbct`.`SpellRank[4]` AS `spellRank4`,
                `dbct`.`SpellRank[5]` AS `spellRank5`,
                `dbct`.`SpellRank[6]` AS `spellRank6`,
                `dbct`.`SpellRank[7]` AS `spellRank7`,
                `dbct`.`SpellRank[8]` AS `spellRank8`
            FROM
                `character_talent` AS `ct`    
            INNER JOIN
                `custom_lua-player-buffs_dbc-talent` AS `dbct`
            ON ( `ct`.`spell` = `dbct`.`SpellRank[0]` OR
                `ct`.`spell` = `dbct`.`SpellRank[1]` OR
                `ct`.`spell` = `dbct`.`SpellRank[2]` OR
                `ct`.`spell` = `dbct`.`SpellRank[3]` OR
                `ct`.`spell` = `dbct`.`SpellRank[4]` OR
                `ct`.`spell` = `dbct`.`SpellRank[5]` OR
                `ct`.`spell` = `dbct`.`SpellRank[6]` OR
                `ct`.`spell` = `dbct`.`SpellRank[7]` OR
                `ct`.`spell` = `dbct`.`SpellRank[8]`)
            WHERE
                `ct`.`guid` = ]] .. characterID .. [[ AND
                ( `ct`.`specMask` & ]] .. specID .. [[ ) != 0
        ]]
    );
    
    if config.debug == 1 then
        print('[lua-player-buffs] Calculating talent points for characterID: ' .. characterID)
    end
    
    -- Calculate invested talent points in each talent tree.
    local talentPoints = {}
    if Q then
        
        repeat
            
            local spellID, tabID = Q:GetUInt32(1), Q:GetUInt32(3)
            local spellRank0, spellRank1, spellRank2, spellRank3, spellRank4, spellRank5, spellRank6, spellRank7, spellRank8
                = Q:GetUInt32(6), Q:GetUInt32(7), Q:GetUInt32(8), Q:GetUInt32(9), Q:GetUInt32(10), Q:GetUInt32(11), Q:GetUInt32(12), Q:GetUInt32(13), Q:GetUInt32(14)
            
            if not talentPoints[tabID] then talentPoints[tabID] = 0 end
            
            local spellTalentPoints = 0
            
            if spellID == spellRank0 then spellTalentPoints = 1 end
            if spellID == spellRank1 then spellTalentPoints = 2 end
            if spellID == spellRank2 then spellTalentPoints = 3 end
            if spellID == spellRank3 then spellTalentPoints = 4 end
            if spellID == spellRank4 then spellTalentPoints = 5 end
            if spellID == spellRank5 then spellTalentPoints = 6 end
            if spellID == spellRank6 then spellTalentPoints = 7 end
            if spellID == spellRank7 then spellTalentPoints = 8 end
            if spellID == spellRank8 then spellTalentPoints = 9 end
            
            talentPoints[tabID] = talentPoints[tabID] + spellTalentPoints
            
            if config.debug == 1 then
                print('[lua-player-buffs] > spellID: ' .. spellID .. ', talentSpecID: ' .. tabID .. ', spellTalentPoints: ' .. spellTalentPoints)
            end
            
        until not Q:NextRow()
        
    end
    
    return talentPoints
    
end


--
local function getDominantTalentSpec (characterID, specID)
    
    local talentPoints = calculateTalentPoints(characterID, specID)
    
    local dominantTalentSpec, dominantTalentSpecPoints = 0, 0
    local dominantTalentSpecUnique = false
    
    for k, v in pairs(talentPoints) do
        
        -- Check which talent tree has most talent points invested.
        if talentPoints[k] > dominantTalentSpecPoints then
            dominantTalentSpec = k
            dominantTalentSpecPoints = talentPoints[k]
            dominantTalentSpecUnique = true
        elseif talentPoints[k] == dominantTalentSpecPoints then
            dominantTalentSpecUnique = false
        end
        
        if config.debug == 1 then
            print('[lua-player-buffs] >> Talent points used: ' .. talentPoints[k] .. ' for talentSpecID: ' .. k)
        end
        
    end
    
    -- Return 0 if we can't detect dominant talent spec.
    if dominantTalentSpecUnique then return dominantTalentSpec
    else return 0 end
    
end


--
function Player:GetTalentSpec ()
    
    local classID = self:GetClass()
    local currentSpec = self:GetActiveSpec()
    
    local talentSpecID = getDominantTalentSpec(self:GetGUIDLow(), currentSpec)
    
    if config.debug == 1 then
        print('[lua-player-buffs] >>> Detected talentSpec for ' .. self:GetName() .. ': currentSpec: ' .. currentSpec .. '(0/1), talentSpecID: ' .. talentSpecID)
    end
    
    return talentSpecID
    
end


--
local function applyUnitBuff (unit, buffTypeID, modifier)
    
    local spellToApply = 0
    if buffTypeID == SPELL_BUFF_DAMAGE_DONE_TAKEN   then spellToApply = config.spells.spellDamageDoneTaken  end
    if buffTypeID == SPELL_BUFF_BASE_STATS_AP       then spellToApply = config.spells.spellBaseStatAP       end
    if buffTypeID == SPELL_BUFF_ABSORB_GIVEN        then spellToApply = config.spells.spellAbsorbGiven      end
    if buffTypeID == SPELL_BUFF_HEALING_DONE        then spellToApply = config.spells.spellHealingDone      end

    if spellToApply ~= 0 then
        
        if unit:HasAura(spellToApply) then
            
            unit:RemoveAura(spellToApply)
            
            if config.debug == 1 then
                print('[lua-player-buffs] - Removed previous buff with spellID: ' .. spellToApply .. ' from ' .. unit:GetName())
            end
            
        end
        
        if modifier ~= 0 then
            
            if buffTypeID == SPELL_BUFF_DAMAGE_DONE_TAKEN then
                unit:CastCustomSpell(unit, spellToApply, true, modifier, modifier)
            elseif buffTypeID == SPELL_BUFF_BASE_STATS_AP then
                unit:CastCustomSpell(unit, spellToApply, true, modifier, modifier, modifier)
            else
                unit:CastCustomSpell(unit, spellToApply, true, modifier)
            end
            
            if config.debug == 1 then
                print('[lua-player-buffs] + Buff applied to ' .. unit:GetName() .. ': buffTypeID: ' .. buffTypeID .. ', spellID: ' .. spellToApply .. ', modifier: ' .. modifier .. '(%)')
            end
            
        end
        
    end
    
end


--
local function applyUnitBuffsByTalentSpec(unit, classID, talentSpecID, talentSpecValues)
    
    -- Buffs need to be sorted by buff level requirement (asc) to handle the lower level buffs first.
    local orderedLevelKeys  = {}
    for i in pairs(talentSpecValues) do
        table.insert(orderedLevelKeys, i)
    end
    table.sort(orderedLevelKeys)
    
    -- Loop through the buffs.
    for i = 1, #orderedLevelKeys do
        
        local levelKey, levelValues = orderedLevelKeys[i], playerBuffs[classID][talentSpecID][orderedLevelKeys[i]]
        
        if unit:GetLevel() >= levelKey then
            
            for buffKey, buffValue in pairs(levelValues) do
                
                applyUnitBuff(unit, buffKey, buffValue)
                
            end
            
        end
        
        -- Buff pet too, if such exists and is correct level.
        local petGUID = unit:GetPetGUID()
        if petGUID ~= 0 then 
            
            local map = unit:GetMap()
            local pet = map:GetWorldObject(petGUID)
            
            if pet then
                
                local petLevel = pet:GetLevel()
                
                if petLevel >= levelKey then
            
                    for buffKey, buffValue in pairs(levelValues) do
                        
                        applyUnitBuff(pet, buffKey, buffValue)
                        
                    end
                    
                end
                
                -- Also separately buff hunter pets if needed.
                -- We re-use this same function as hunter pets are handled as any player talent spec.
                
                if classID == CLASS_HUNTER and talentSpecID == SPEC_HUNTER_BEASTMASTERY and playerBuffs[CLASS_HUNTER][PET_HUNTER_BEASTMASTERY] ~= nil then
                    applyUnitBuffsByTalentSpec(pet, CLASS_HUNTER, PET_HUNTER_BEASTMASTERY, playerBuffs[CLASS_HUNTER][PET_HUNTER_BEASTMASTERY])
                end
                
                if classID == CLASS_HUNTER and talentSpecID == SPEC_HUNTER_MARKSMANSHIP and playerBuffs[CLASS_HUNTER][PET_HUNTER_MARKSMANSHIP] ~= nil then
                    applyUnitBuffsByTalentSpec(pet, CLASS_HUNTER, PET_HUNTER_MARKSMANSHIP, playerBuffs[CLASS_HUNTER][PET_HUNTER_MARKSMANSHIP])
                end
                
                if classID == CLASS_HUNTER and talentSpecID == SPEC_HUNTER_SURVIVAL and playerBuffs[CLASS_HUNTER][PET_HUNTER_SURVIVAL] ~= nil then
                    applyUnitBuffsByTalentSpec(pet, CLASS_HUNTER, PET_HUNTER_SURVIVAL, playerBuffs[CLASS_HUNTER][PET_HUNTER_SURVIVAL])
                end
                
            end
            
        end
        
    end
    
end

--
local function applyPlayerBuffs (player)
    
    if config.isActive == 0 then
        return
    end
    
    local classID = player:GetClass()
    local talentSpecID = player:GetTalentSpec()
    
    for classKey, classValues in pairs(playerBuffs) do
        
        if classKey == classID then
            
            -- Buffs need to be sorted by talentSpecKey (asc) to handle the class buffs first.
            local orderedTalentSpecKeys  = {}
            for i in pairs(classValues) do
                table.insert(orderedTalentSpecKeys, i)
            end
            table.sort(orderedTalentSpecKeys)
            
            -- Loop through the buffs.
            for i = 1, #orderedTalentSpecKeys do
                
                local talentSpecKey, talentSpecValues = orderedTalentSpecKeys[i], playerBuffs[classID][orderedTalentSpecKeys[i]]
                
                if talentSpecKey == 0 or talentSpecKey == talentSpecID then
                    
                    applyUnitBuffsByTalentSpec(player, classKey, talentSpecKey, talentSpecValues)
                    
                end
                
            end
            
        end
        
    end
    
end


--
local PLAYER_EVENT_ON_LOGIN         =  3
local PLAYER_EVENT_ON_CHAT          = 18
local PLAYER_EVENT_ON_MAP_CHANGE    = 28
local PLAYER_EVENT_ON_RESURRECT     = 36
local PLAYER_EVENT_ON_PET_SPAWNED   = 43

local function triggerOnLoginEvent (event, player)
    if config.debug == 1 then
        print('[lua-player-buffs] ----------------------------------------')
        print('[lua-player-buffs] ** OnLoginEvent')
    end
    applyPlayerBuffs(player)
end
local function triggerOnMapChangeEvent (event, player, newZone, newArea)
    if config.debug == 1 then
        print('[lua-player-buffs] ----------------------------------------')
        print('[lua-player-buffs] ** OnMapChangeEvent')
    end
    applyPlayerBuffs(player)
end
local function triggerOnResurrectEvent (event, player)
    if config.debug == 1 then
        print('[lua-player-buffs] ----------------------------------------')
        print('[lua-player-buffs] ** OnResurrectEvent')
    end
    applyPlayerBuffs(player)
end
local function triggerOnPetSpawnedEvent (event, player, _)
    if config.debug == 1 then
        print('[lua-player-buffs] ----------------------------------------')
        print('[lua-player-buffs] ** OnPetSpawnedEvent')
    end
    applyPlayerBuffs(player)
end
local function triggerOnChatEvent (event, player, _, _, _)
    if config.debug == 1 then
        print('[lua-player-buffs] ----------------------------------------')
        print('[lua-player-buffs] ** OnChatEvent')
    end
    applyPlayerBuffs(player)
end

if config.isActive == 1 then
    RegisterPlayerEvent(PLAYER_EVENT_ON_LOGIN, triggerOnLoginEvent)
    RegisterPlayerEvent(PLAYER_EVENT_ON_MAP_CHANGE, triggerOnMapChangeEvent)
    RegisterPlayerEvent(PLAYER_EVENT_ON_RESURRECT, triggerOnResurrectEvent)
    RegisterPlayerEvent(PLAYER_EVENT_ON_PET_SPAWNED, triggerOnPetSpawnedEvent)
    if config.debug == 1 then
        RegisterPlayerEvent(PLAYER_EVENT_ON_CHAT, triggerOnChatEvent)
    end
end
