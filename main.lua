local soundbites = {
	seren_influence = {49590, "I am very familiar with Seren's influence", "Activate Light Form"},
	disappointing = {49594, "Disappointing, but not unexpected.", "Die"},
	follow_me = {50326, "Please, follow me.", "Summon familiar/pet"},
	memories = {50328, "Well, this brings back memories.", "Visit specific locations"},
	this_suffices = {50329, "Yes, this should suffice.", "Have maximum Invention charges"},
	place_know = {50283, "A place I know well.", "Visit POH"},
	you_still_needed = {50966, "No, you are still needed!", "Trigger Ring of Death"},
	pulling_out = {50968, "Pulling you out!", "Fail Heist 1"},
	see_them = {50970, "I see them!", "Spy on penguins"},
	teleporting_now = {50972, "Teleporting, now!", "Use lodestones"},
	not_today = {50976, "Not today!", "Get caught pickpocketing in Prifddinas"},
	not_ideal = {50981, "That is not ideal", "Out of Prayer points"},
	too_close = {50988, "That was a little too close...", "Get caught on Ape Atoll"},
	foe_beaten_will_return = {51001, "The foe is beaten, but it will return!", "Kill a BGH dino"},
	well_fought = {51009, "Well fought, World Guardian!", "Add a new Slayer Codex entry"},
	brief_reprieve = {51013, "Use this brief reprieve well; replenish your magic.", "Activate Rest"},
	ready_defenses = {51017, "Ready your defenses!", "Activate Preparation"},
	fortify = {51023, "Fortify yourself!", "Activate Fortitude"},
	good_reso = {51027, "A good use of Resonance!", "Activate Resonance"},
	handled_well = {51029, "You handled that remarkably well!", "Complete a quest"},
 	still_standing = {51031, "Are you still standing?", "Out of Run energy"},
 	survive_attack = {51033, "It's no small feat surviving such an attack", "Survive a big hit"},
 	crude_effective = {51041, "Crude, but all too effective!", "Equip a bronze dagger"},
	run_wg = {51052, "Run World Guardian!", "Activate Run"},
	watch_step = {51063, "Watch your step!", "Enter Familiarisation"},
	impressive_manoeuv = {51067, "Your manoeuvrability is impressive!", "Gain Agility Arena tickets"},
	artfully_done = {51071, "Artfully done!", "Find specific paintings"},
	last_of_them = {51097, "That's the last of them.", "Complete a Slayer task"},
	efficient_approach = {51139, "An efficient approach!", "Improve your boss PB"},
	move_safer = {51157, "Move to a safer location!", "Enter the Wilderness"},
	suggest_prayer = {51163, "Might I suggest a Prayer?", "Jad spawns"},
	use_overloads = {51165, "You would do well to use Overload potions.", "Unlock a new Overload potion"},
	interesting = {51193, "Interesting!", "Add a new Collection Log entry"},
	not_bad = {51189, "Not bad!", "Buy/sell something for at least 200m coins"},
}

-- Herblore levels Azzanadra will comment on
local herbLevels = {
	[96] = 9684577,
	[97] = 10692629,
	[98] = 11805606,
	[99] = 13034431,
	[106] = 26068632,
	[107] = 28782069
}

-- Painting Azzanadra will comment on
local paintings = {
	"ARCH_GUILD_OFFICE_PAINTING_1_MULTI", "ARCH_GUILD_OFFICE_PAINTING_2_MULTI", "ARCH_GUILD_OFFICE_PAINTING_3_MULTI",
	"QUEST_AMASCUT_ZEMO_DECORATION_POSTER", "Q200_DECORATION_PAINTING", "ZAMORAK_BOSS_DECORATION_POSTER",
	"PENG_RAK_SUB_DORM_PINUP_LVL1", "PENG_POW_SUB_DORM_PINUP_LVL1", "Q200_PALACE_LVL1_HEART_VAULT_PAINTING_01_RUINED",
	"Q200_PALACE_LVL1_HEART_VAULT_PAINTING_02_RUINED", "Q200_PALACE_LVL1_HEART_VAULT_PAINTING_03_RUINED",
	"MYQ5_DM_MID_POSTER_DEFACED1", "MYQ5_DM_MID_POSTER_DEFACED2", "MYQ5_DM_MID_POSTER_DEFACED3", "MYQ5_DM_MID_POSTER_DEFACED4"
}

-- Locations Azzanadra will comment on
local azzyLocs = {
	["Empty Throne Room"] = {44, 197},
	["Senntisten Altar"] = {49, 89},
	["DT Pyramid"] = {50, 145},
	["Ritual marker"] = {45, 60},
	["Freneskae"] = {39, 194},
	["Empyrean Citadel"] = {59, 68},
}
function isAzzyLoc()
	grid = Player.GetEntity().coordGrid
	gridX, gridZ = grid.mapSquareX, grid.mapSquareZ
	for _, v in pairs(azzyLocs) do
		if gridX == v[1] and gridZ == v[2] then return true end
	end
	return false
end

local azzyChatEnabled = PersistentDB:GetBool("azzyChatEnabled") ~= false
local azzyVoiceEnabled = PersistentDB:GetBool("azzyVoiceEnabled") ~= false
local soundbiteSettings = PersistentDB:GetStructuredData("soundbiteSettings") or {}
local audioParams = audio.SoundPlaybackParams.new()
	audioParams.type = audio.SoundType.SCRIPT
	audioParams.audioBus = audio.AudioBus.VOICEOVER
local currentSound

function playSound(soundbite)
	if not soundbiteSettings[soundbite] then return end
	local soundID = soundbites[soundbite][1]
	local chatMessage = soundbites[soundbite][2]
	if soundID == nil then
		return
	end
	if currentSound ~= nil and currentSound.isPlaying then
		currentSound:Stop()
	end

	if azzyVoiceEnabled then
		currentSound = audio.Play(soundID, audioParams)
	end
	if azzyChatEnabled then
		Chat.AddMessage("<sprite=12709> <col=fc51fd>Azzanadra:</col> " .. chatMessage)
	end
end

--[[
=======================
TRIGGERS FOR SOUNDBITES
=======================
]]
function levelUpTrigger(event)
	local skillName = SkillType.FromID(event.skill)
	local level = event.newGameplayLevel
	if skillName == "HERBLORE" and herbLevels[level] then
		if event.oldXP < herbLevels[level] and event.newXP >= herbLevels[level] then -- Player didn't boost their level
			playSound("use_overloads")
		end
	end
end

function varTrigger(varEvent)
	local eventName = varEvent.var.configName
	if eventName == "CONSTRUCTION_HOUSE_HOST_HASH64" and varEvent.oldValue == -1 then -- Enter POH
		playSound("place_know")
	end
	if eventName == "COMBATV2_JUST_USED_ABILITY" and varEvent.newValue == 14713 then -- Resonance
		playSound("good_reso")
	end
	if eventName == "LIFEPOINTS" then
		if varEvent.newValue == 0 then -- Player dies
			playSound("disappointing")
		elseif varEvent.oldValue - varEvent.newValue >= 9000 then -- Player survived a big hit
			playSound("survive_attack")
		end
	end
	if varEvent.var.configName == "DIV_UNPROTECTED" and varEvent.oldValue == 0 then -- Ring of Death
		playSound("you_still_needed")
	end
	if eventName == "LORE_NPC_HEAD" and varEvent.newValue > -1 then -- Familiar/Pet summoned
		playSound("follow_me")
	end
	if eventName == "OPTION_RUN" and varEvent.newValue == 1 then -- Run toggled on
		playSound("run_wg")
	end
	if eventName == "PRAYER_POINTS_VAR" and varEvent.newValue == 6488064 then -- Out of Prayer points
		playSound("not_ideal")
	end
	if eventName == "SS" and varEvent.newValue == 1 then -- Slayer task done
		playSound("last_of_them")
	end
	if eventName == "CURSE_BASE" and varEvent.newValue == 536870912 then -- Light Form activated
		playSound("seren_influence")
	end
	if eventName == "CURSE_BASE" and varEvent.newValue == 268435456 then -- Fortitude activated
		playSound("fortify")
	end
	if eventName == "COMBATV2_JUST_USED_ABILITY" and varEvent.newValue == 14714 then -- Preparation
		playSound("ready_defenses")
	end
	if eventName == "OPTION_RUN_STATUS_VARC" and varEvent.newValue == 3 and varEvent.oldValue ~= 3 then -- Rest
		playSound("brief_reprieve")
	end
	if string.find(eventName, "BOSS_INSTANCE_SCORES_") then -- New boss PB
		playSound("efficient_approach")
	end
	if eventName == "CURRENCY_BRIM_AGIL_TICKET" and varEvent.newValue > varEvent.oldValue then -- Agi arena ticket
		playSound("impressive_manoeuv")
	end
	if eventName == "INVENT_CHARGE" and varEvent.newValue > varEvent.oldValue and varEvent.newValue >= 1491003000 then -- Max Inv charge
		playSound("this_suffices")
	end
	if eventName == "PLAYER_COORD" then -- Visit Azzy-themed location
		if isAzzyLoc() then	playSound("memories") end
	end
	if eventName == "THAS_TELEPORT_HUBS_VAR1" then -- Use lodestone
		playSound("teleporting_now")
	end
	if eventName == "WILDERNESS" and varEvent.newValue == 1 then -- Enter Wildy
		playSound("move_safer")
	end
	if eventName == "DINO_GAME_TOTAL_KILLS" then -- BGH kill
		playSound("foe_beaten_will_return")
	end
	if string.find(eventName, "SLAYER_CODEX_") then -- New slayer codex entry
		playSound("well_fought")
	end
	if eventName == "HEIST_NPCS_1" and varEvent.newValue == 2926 and varEvent.newValue < varEvent.oldValue then -- Caught in heist
		playSound("pulling_out")
	end
	if eventName == "PENG_SPY_SWITCH" then -- Penguin found
		playSound("see_them")
	end
	if eventName == "EXCHANGE_HISTORY_1_COINS_LONG" and varEvent.newValue >= 200000000 then -- Buy/Sell for 200m
		playSound("not_bad")
	end
	if eventName == "QP" and varEvent.newValue > varEvent.oldValue then -- Complete a quest
		playSound("handled_well")
	end
	if eventName == "SFA_HUNT" and varEvent.newValue == 0 then -- Enter Familiarisation
		playSound("watch_step")
	end
	if eventName == "ELFCITY_PICKPOCKET_SPOTTED" and varEvent.newValue > varEvent.oldValue then -- Get caught Prifpocketing
		playSound("not_today")
	end
	if eventName == "MM_FLAGS" and var.VarPlayer.MM_PLAYER_IS_UNCONSCIOUS.value == 1 then -- Sent to monkey jail
		playSound("too_close")
	end
end

local previousLoc
function miniMenuTrigger(menuEvent)
	local hoveredLoc
	for _, entry in ipairs(menuEvent.miniMenu.entries) do
		if entry.locData then
			hoveredLoc = entry.locData
			break
		end
	end
	if not hoveredLoc then return end
	if previousLoc == hoveredLoc.config.configName then return end
	previousLoc = hoveredLoc.config.configName

	local locName = hoveredLoc.config.configName
	for i=1, #paintings do
		if paintings[i] == locName then -- Hovering over a specific painting
			playSound("artfully_done")
			break
		end
	end
end

function runTrigger(runEvent)
	if runEvent.newRunEnergy == 0 then -- Out of run energy
		playSound("still_standing")
	end
end

function inventoryTrigger(invEvent)
	local invName = invEvent.inv.configName
	if invName == "WORN" then
		local wornInv = Inventory.Find(config.Inv.WORN)
		local item = wornInv:GetSlot(4).obj.configName
		if item == "BRONZE_DAGGER" then -- Equip bronze dagger
			playSound("crude_effective")
		end
	end
end

function npcAddedTrigger(npcEvent)
	local npcName = npcEvent.npcEntity.config.configName
	if npcName == "TZHAAR_FIGHTCAVE_SWARM_BOSS" then -- Jad spawns
		playSound("suggest_prayer")
	end
end

--[[
COLLECTION LOG POPUP
]]
local notificationDetected = false
local function getInfoPopup()
    local popup = ui.Interfaces:GetComponent(id.Component.INFO_POPUP__BESPOKE_WINDOW)
    local found = false

    if popup then
        local function scan(component)
            if component.type == 2 and component.staticID == 4 and component.content == "Collection Log Updated" then
                found = true
            end

            if component.IterateStaticComponents then
                component:IterateStaticComponents(function(child)
                    scan(child)
                    return false
                end)
            end
        end
        scan(popup)
    end

    if found and not notificationDetected then
        playSound("interesting")
    end
    notificationDetected = found
end

--[[
=================
EVENT SUBSCRIBERS
=================
]]
Event.SkillTransmit.Subscribe("levelUp", levelUpTrigger)
Event.VarTransmit.Subscribe("varTransmit", varTrigger)
Event.RunEnergyTransmit.Subscribe("runTransmit", runTrigger)
Event.InventoryUpdated.Subscribe("inventoryUpdate", inventoryTrigger)
Event.MiniMenuReady.Subscribe("miniMenuReady", miniMenuTrigger)
Event.NPCEntityAdded.Subscribe("entityAdded", npcAddedTrigger)
Event.ServerLogic.Subscribe("uiWatcher", getInfoPopup)

--[[
=============
SETTINGS MENU
=============
]]
local settingsView
Event.SettingsLayerReady.Subscribe("azzy-awesome-settings", function(event)
    if settingsView then settingsView:Destroy() end

    local parent = event.component
    settingsView = prettyui.SimpleView.new(parent, {width = parent.width, height = parent.height})

	settingsView:AddText("Changes are saved immediately.")
    settingsView:AddTitle("Messages")
    settingsView:AddCheckboxButton({{text = "Chatbox messages", value = "azzyChatEnabled", selected = azzyChatEnabled},
    }, {
        onChange = function(_, _, _, selected)
            azzyChatEnabled = selected
            PersistentDB:SetBool("azzyChatEnabled", selected)
        end,
    })
    settingsView:AddCheckboxButton({{text = "Voiceover audio", value = "azzyVoiceEnabled", selected = azzyVoiceEnabled},
    }, {
        onChange = function(_, _, _, selected)
            azzyVoiceEnabled = selected
            PersistentDB:SetBool("azzyVoiceEnabled", selected)
        end,
    })

    -- TRIGGER OPTIONS
    settingsView:AddTitle("Triggers")
    settingsView:AddText("Choose when Azzanadra can comment on your activities.")
    local sortedKeys = {}
	local soundbiteCheckboxes = {}

	for key in pairs(soundbites) do
	    table.insert(sortedKeys, key)
	end

	-- Alphabetical order by the visible label
	table.sort(sortedKeys, function(a, b)
	    return soundbites[a][3]:lower() < soundbites[b][3]:lower()
	end)

	-- Initialize missing settings as enabled
	for _, key in ipairs(sortedKeys) do
	    if soundbiteSettings[key] == nil then
	        soundbiteSettings[key] = true
	    end
	end
	PersistentDB:SetStructuredData("soundbiteSettings", soundbiteSettings)

	-- Toggle all: enable all unless they're already all enabled
	settingsView:AddSimpleButton("Toggle All", function()
	    local allEnabled = true
	    for _, key in ipairs(sortedKeys) do
	        if soundbiteSettings[key] ~= true then
	            allEnabled = false
	            break
	        end
	    end
	    local newState = not allEnabled
	    for _, key in ipairs(sortedKeys) do
	        soundbiteSettings[key] = newState
	        soundbiteCheckboxes[key]:SetSelected(soundbites[key][1], newState)
	    end
	    PersistentDB:SetStructuredData("soundbiteSettings", soundbiteSettings)
	end)

	-- Create the checkboxes
	for _, key in ipairs(sortedKeys) do
	    local soundbite = soundbites[key]
	    soundbiteCheckboxes[key] = settingsView:AddCheckboxButton({
	        {
	            text = soundbite[3],
	            value = soundbite[1],
	            selected = soundbiteSettings[key]
	        }
	    }, {
	        onChange = function(_, _, _, selected)
	            soundbiteSettings[key] = selected
	            PersistentDB:SetStructuredData("soundbiteSettings", soundbiteSettings)
	        end,
	    })
	end
end)

function PluginShutdown()
    Event.SettingsLayerReady.Unsubscribe("azzy-awesome-settings")
    if settingsView then
        settingsView:Destroy()
        settingsView = nil
    end
end