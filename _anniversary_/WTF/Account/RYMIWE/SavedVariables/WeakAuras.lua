
WeakAurasSaved = {
["dynamicIconCache"] = {
},
["editor_tab_spaces"] = 4,
["displays"] = {
["W Shield 3"] = {
["wagoID"] = "OPRZeg-u6",
["authorOptions"] = {
},
["preferToUpdate"] = false,
["yOffset"] = 8.1025390625,
["anchorPoint"] = "CENTER",
["url"] = "https://wago.io/OPRZeg-u6/2",
["actions"] = {
["start"] = {
},
["init"] = {
},
["finish"] = {
},
},
["triggers"] = {
{
["trigger"] = {
["type"] = "aura2",
["stacksOperator"] = "==",
["auranames"] = {
"Water Shield",
},
["event"] = "Health",
["unit"] = "player",
["useStacks"] = true,
["stacks"] = "3",
["spellIds"] = {
},
["useName"] = true,
["names"] = {
},
["subeventPrefix"] = "SPELL",
["subeventSuffix"] = "_CAST_START",
["debuffType"] = "HELPFUL",
},
["untrigger"] = {
},
},
["activeTriggerMode"] = -10,
},
["internalVersion"] = 89,
["selfPoint"] = "CENTER",
["desaturate"] = false,
["rotation"] = 0,
["version"] = 2,
["subRegions"] = {
{
["type"] = "subbackground",
},
},
["height"] = 38.08532333374,
["rotate"] = false,
["load"] = {
["use_class"] = true,
["use_never"] = false,
["talent"] = {
["multi"] = {
},
},
["use_combat"] = true,
["spec"] = {
["multi"] = {
},
},
["class"] = {
["single"] = "SHAMAN",
["multi"] = {
},
},
["size"] = {
["multi"] = {
},
},
},
["textureWrapMode"] = "CLAMPTOBLACKADDITIVE",
["mirror"] = false,
["regionType"] = "texture",
["blendMode"] = "BLEND",
["texture"] = "Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-73",
["uid"] = "bKDFLW2aasC",
["color"] = {
0,
0.79215693473816,
1,
1,
},
["semver"] = "1.2.0",
["tocversion"] = 20505,
["id"] = "W Shield 3",
["xOffset"] = -102.19324951172,
["alpha"] = 1,
["width"] = 40.273517608643,
["parent"] = "Wata shield",
["config"] = {
},
["anchorFrameType"] = "SCREEN",
["frameStrata"] = 1,
["conditions"] = {
},
["information"] = {
["showNilIsFalse"] = true,
},
["animation"] = {
["start"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
["main"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
["finish"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
},
},
["Lightning shield"] = {
["controlledChildren"] = {
"L Shield 3",
"L Shield 2",
"L Shield 1",
},
["borderBackdrop"] = "Blizzard Tooltip",
["wagoID"] = "OPRZeg-u6",
["authorOptions"] = {
},
["preferToUpdate"] = false,
["yOffset"] = -28.145261764526,
["anchorPoint"] = "CENTER",
["borderColor"] = {
0,
0,
0,
1,
},
["url"] = "https://wago.io/OPRZeg-u6/2",
["actions"] = {
["start"] = {
},
["init"] = {
},
["finish"] = {
},
},
["triggers"] = {
{
["trigger"] = {
["unit"] = "player",
["type"] = "aura2",
["spellIds"] = {
},
["subeventSuffix"] = "_CAST_START",
["subeventPrefix"] = "SPELL",
["debuffType"] = "HELPFUL",
["event"] = "Health",
["names"] = {
},
},
["untrigger"] = {
},
},
},
["internalVersion"] = 89,
["selfPoint"] = "CENTER",
["version"] = 2,
["subRegions"] = {
},
["load"] = {
["talent"] = {
["multi"] = {
},
},
["spec"] = {
["multi"] = {
},
},
["class"] = {
["multi"] = {
},
},
["size"] = {
["multi"] = {
},
},
},
["backdropColor"] = {
1,
1,
1,
0.5,
},
["scale"] = 1,
["border"] = false,
["borderEdge"] = "Square Full White",
["regionType"] = "group",
["borderSize"] = 2,
["uid"] = "Q1U6c1N03cL",
["borderOffset"] = 4,
["semver"] = "1.2.0",
["tocversion"] = 20505,
["id"] = "Lightning shield",
["xOffset"] = -60.171203613281,
["alpha"] = 1,
["anchorFrameType"] = "SCREEN",
["parent"] = "Sham Shields",
["config"] = {
},
["frameStrata"] = 1,
["borderInset"] = 1,
["conditions"] = {
},
["information"] = {
["showNilIsFalse"] = true,
},
["animation"] = {
["start"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
["main"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
["finish"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
},
},
["OHTick"] = {
["sparkWidth"] = 2,
["sparkOffsetX"] = 0,
["wagoID"] = "fDDNP0SM7",
["xOffset"] = -0.00018310546875,
["adjustedMax"] = "",
["adjustedMin"] = "",
["yOffset"] = 0,
["anchorPoint"] = "CENTER",
["sparkTexture"] = "Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_White",
["sparkRotation"] = 0,
["sparkRotationMode"] = "AUTO",
["url"] = "https://wago.io/fDDNP0SM7/15",
["actions"] = {
["start"] = {
},
["init"] = {
},
["finish"] = {
},
},
["triggers"] = {
{
["trigger"] = {
["type"] = "unit",
["subeventSuffix"] = "_CAST_START",
["event"] = "Swing Timer",
["unit"] = "player",
["names"] = {
},
["spellIds"] = {
},
["use_hand"] = true,
["subeventPrefix"] = "SPELL",
["use_unit"] = true,
["hand"] = "off",
["debuffType"] = "HELPFUL",
},
["untrigger"] = {
},
},
{
["trigger"] = {
["type"] = "unit",
["subeventSuffix"] = "_CAST_START",
["event"] = "Swing Timer",
["unit"] = "player",
["names"] = {
},
["spellIds"] = {
},
["use_hand"] = true,
["subeventPrefix"] = "SPELL",
["use_unit"] = true,
["hand"] = "main",
["debuffType"] = "HELPFUL",
},
["untrigger"] = {
},
},
["disjunctive"] = "custom",
["customTriggerLogic"] = "function(trigger)\n    return trigger[1]\nend",
["activeTriggerMode"] = -10,
},
["icon_color"] = {
1,
1,
1,
1,
},
["internalVersion"] = 89,
["progressSource"] = {
-1,
"",
},
["animation"] = {
["start"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
["main"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
["finish"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
},
["iconSource"] = -1,
["barColor"] = {
1,
0,
0.015686274509804,
0,
},
["desaturate"] = false,
["information"] = {
["showNilIsFalse"] = true,
["forceEvents"] = true,
},
["preferToUpdate"] = false,
["version"] = 15,
["subRegions"] = {
{
["type"] = "subbackground",
},
{
["type"] = "subforeground",
},
},
["height"] = 30,
["textureSource"] = "LSM",
["load"] = {
["use_never"] = true,
["talent"] = {
["multi"] = {
},
},
["use_combat"] = true,
["class"] = {
["multi"] = {
},
},
["spec"] = {
["multi"] = {
},
},
["size"] = {
["multi"] = {
},
},
},
["sparkBlendMode"] = "BLEND",
["useAdjustededMax"] = false,
["parent"] = "SwingTimer",
["icon"] = false,
["sparkColor"] = {
1,
0,
0.03921568627451,
1,
},
["config"] = {
["CbM"] = false,
["bigBadSync"] = false,
},
["authorOptions"] = {
{
["type"] = "toggle",
["default"] = false,
["key"] = "bigBadSync",
["useDesc"] = false,
["name"] = "Emphasize Bad Sync",
["width"] = 1,
},
{
["type"] = "toggle",
["default"] = false,
["desc"] = "Might help with red-green colorblindness",
["key"] = "CbM",
["useDesc"] = true,
["name"] = "Colorblind Mode",
["width"] = 1,
},
},
["width"] = 202,
["useAdjustededMin"] = false,
["regionType"] = "aurabar",
["frameStrata"] = 1,
["gradientOrientation"] = "HORIZONTAL",
["icon_side"] = "RIGHT",
["id"] = "OHTick",
["sparkHeight"] = 30,
["texture"] = "Solid",
["semver"] = "3.0.5",
["zoom"] = 0,
["spark"] = true,
["tocversion"] = 20505,
["sparkHidden"] = "FULL",
["sparkOffsetY"] = 0,
["alpha"] = 1,
["anchorFrameType"] = "SCREEN",
["selfPoint"] = "CENTER",
["uid"] = "7y6BGEkcT6p",
["inverse"] = true,
["enableGradient"] = false,
["orientation"] = "HORIZONTAL",
["conditions"] = {
{
["check"] = {
["trigger"] = -1,
["variable"] = "customcheck",
["value"] = "function(states)\n    if states[1].expirationTime and states[2].expirationTime and states[2].duration then\n        \n        \n        local timeLeft = math.abs(states[1].expirationTime - states[2].expirationTime)     \n        local ohLeft = states[1].expirationTime - GetTime()\n        local mhLeft = states[2].expirationTime - GetTime()\n        -- time left in real time until main hand swings\n        local wasMH = states[2].expirationTime-GetTime()+0.01 > states[2].duration\n        local wasOH = states[1].expirationTime-GetTime()+0.01 > states[1].duration\n        -- did we just hit with the off hand?\n        local ohBeforeMh = states[1].expirationTime <= states[2].expirationTime\n        \n        return not aura_env.config[\"CbM\"] and (((timeLeft < 0.5 and ohBeforeMh) and not (ohLeft < 0.5 and wasMH)) or (mhLeft < 0.5 and wasOH))\n    end\nend",
},
["linked"] = false,
["changes"] = {
{
["value"] = {
1,
1,
0,
1,
},
["property"] = "sparkColor",
},
},
},
{
["check"] = {
["op"] = "",
["checks"] = {
{
["trigger"] = -1,
["variable"] = "customcheck",
},
},
["value"] = "function(states)\n    if states[1].expirationTime and states[2].expirationTime and states[2].duration then\n        \n        \n        local timeLeft = math.abs(states[1].expirationTime - states[2].expirationTime)     \n        local ohLeft = states[1].expirationTime - GetTime()\n        local mhLeft = states[2].expirationTime - GetTime()\n        -- time left in real time until main hand swings\n        local wasMH = states[2].expirationTime-GetTime()+0.01 > states[2].duration\n        local wasOH = states[1].expirationTime-GetTime()+0.01 > states[1].duration\n        -- did we just hit with the off hand?\n        local ohBeforeMh = states[1].expirationTime <= states[2].expirationTime\n        \n        return not aura_env.config[\"CbM\"] and ((timeLeft < 0.5 and not ohBeforeMh) or (ohLeft < 0.5 and wasMH))\n    end\nend",
["variable"] = "customcheck",
["trigger"] = -1,
},
["changes"] = {
{
["value"] = {
0.066666666666667,
1,
0,
1,
},
["property"] = "sparkColor",
},
},
},
{
["check"] = {
["trigger"] = -1,
["variable"] = "customcheck",
["value"] = "function()\n    if aura_env.config[\"CbM\"] then\n        return true\n    end\nend",
},
["changes"] = {
{
["value"] = {
0.99607843137255,
1,
0.98823529411765,
1,
},
["property"] = "sparkColor",
},
{
["value"] = 2,
["property"] = "sparkWidth",
},
},
},
{
["check"] = {
["trigger"] = -1,
["variable"] = "customcheck",
["value"] = "function(states)\n    if states[1].expirationTime and states[2].expirationTime and states[2].duration then\n        \n        \n        local timeLeft = math.abs(states[1].expirationTime - states[2].expirationTime)     \n        local ohLeft = states[1].expirationTime - GetTime()\n        local mhLeft = states[2].expirationTime - GetTime()\n        -- time left in real time until main hand swings\n        local wasMH = states[2].expirationTime-GetTime()+0.01 > states[2].duration\n        local wasOH = states[1].expirationTime-GetTime()+0.01 > states[1].duration\n        -- did we just hit with the off hand?\n        local ohBeforeMh = states[1].expirationTime <= states[2].expirationTime\n        \n        return aura_env.config[\"CbM\"] and (((timeLeft < 0.5 and ohBeforeMh) and not (ohLeft < 0.5 and wasMH)) or (mhLeft < 0.5 and wasOH))\n    end\nend",
},
["changes"] = {
{
["value"] = {
1,
0.97647058823529,
0,
1,
},
["property"] = "sparkColor",
},
{
["value"] = 2,
["property"] = "sparkWidth",
},
},
},
{
["check"] = {
["trigger"] = -1,
["variable"] = "customcheck",
["value"] = "function(states)\n    if states[1].expirationTime and states[2].expirationTime and states[2].duration then\n        \n        \n        local timeLeft = math.abs(states[1].expirationTime - states[2].expirationTime)     \n        local ohLeft = states[1].expirationTime - GetTime()\n        local mhLeft = states[2].expirationTime - GetTime()\n        -- time left in real time until main hand swings\n        local wasMH = states[2].expirationTime-GetTime()+0.01 > states[2].duration\n        local wasOH = states[1].expirationTime-GetTime()+0.01 > states[1].duration\n        -- did we just hit with the off hand?\n        local ohBeforeMh = states[1].expirationTime <= states[2].expirationTime\n        \n        return aura_env.config[\"CbM\"] and ((timeLeft < 0.5 and not ohBeforeMh) or (ohLeft < 0.5 and wasMH))\n    end\nend",
},
["changes"] = {
{
["value"] = {
0,
0,
0,
1,
},
["property"] = "sparkColor",
},
{
["value"] = 2,
["property"] = "sparkWidth",
},
},
},
},
["barColor2"] = {
1,
1,
0,
1,
},
["backgroundColor"] = {
0,
0,
0,
0,
},
},
["MH"] = {
["sparkWidth"] = 10,
["iconSource"] = -1,
["xOffset"] = 0,
["adjustedMax"] = "",
["yOffset"] = 0,
["anchorPoint"] = "CENTER",
["sparkRotation"] = 0,
["url"] = "https://wago.io/fDDNP0SM7/15",
["icon"] = false,
["fontFlags"] = "OUTLINE",
["icon_color"] = {
1,
1,
1,
1,
},
["enableGradient"] = false,
["selfPoint"] = "CENTER",
["barColor"] = {
0.13725490196078,
0.32549019607843,
1,
1,
},
["desaturate"] = false,
["sparkOffsetY"] = 0,
["gradientOrientation"] = "HORIZONTAL",
["load"] = {
["talent2"] = {
["multi"] = {
},
},
["use_never"] = true,
["talent"] = {
["single"] = 38,
["multi"] = {
[38] = true,
},
},
["size"] = {
["multi"] = {
},
},
["class"] = {
["single"] = "SHAMAN",
["multi"] = {
["WARRIOR"] = true,
["ROGUE"] = true,
["SHAMAN"] = true,
},
},
["spec"] = {
["single"] = 1,
["multi"] = {
},
},
["role"] = {
["multi"] = {
},
},
["difficulty"] = {
["multi"] = {
},
},
["race"] = {
["multi"] = {
},
},
["use_spec"] = true,
["pvptalent"] = {
["multi"] = {
},
},
["faction"] = {
["multi"] = {
},
},
["use_combat"] = true,
["ingroup"] = {
["multi"] = {
},
},
["zoneIds"] = "",
},
["smoothProgress"] = false,
["useAdjustededMin"] = false,
["regionType"] = "aurabar",
["texture"] = "Solid",
["sparkTexture"] = "Interface\\CastingBar\\UI-CastingBar-Spark",
["auto"] = true,
["tocversion"] = 20505,
["alpha"] = 1,
["sparkColor"] = {
1,
1,
1,
1,
},
["sparkOffsetX"] = 0,
["wagoID"] = "fDDNP0SM7",
["parent"] = "SwingTimer",
["adjustedMin"] = "",
["sparkRotationMode"] = "AUTO",
["triggers"] = {
{
["trigger"] = {
["type"] = "unit",
["genericShowOn"] = "showOnActive",
["unevent"] = "auto",
["use_unit"] = true,
["duration"] = "1",
["event"] = "Swing Timer",
["names"] = {
},
["use_absorbMode"] = true,
["unit"] = "player",
["spellIds"] = {
},
["use_hand"] = true,
["subeventPrefix"] = "SPELL",
["subeventSuffix"] = "_CAST_START",
["hand"] = "main",
["debuffType"] = "HELPFUL",
},
["untrigger"] = {
},
},
{
["trigger"] = {
["type"] = "unit",
["use_alwaystrue"] = true,
["unevent"] = "auto",
["use_absorbMode"] = true,
["genericShowOn"] = "showOnActive",
["unit"] = "player",
["use_unit"] = true,
["event"] = "Conditions",
["subeventPrefix"] = "SPELL",
["subeventSuffix"] = "_CAST_START",
["duration"] = "1",
},
["untrigger"] = {
},
},
{
["trigger"] = {
["type"] = "unit",
["genericShowOn"] = "showOnActive",
["unevent"] = "auto",
["use_unit"] = true,
["duration"] = "1",
["event"] = "Swing Timer",
["names"] = {
},
["use_absorbMode"] = true,
["unit"] = "player",
["spellIds"] = {
},
["use_hand"] = true,
["subeventPrefix"] = "SPELL",
["subeventSuffix"] = "_CAST_START",
["hand"] = "off",
["debuffType"] = "HELPFUL",
},
["untrigger"] = {
},
},
{
["trigger"] = {
["type"] = "combatlog",
["spellId"] = {
"33750",
},
["subeventSuffix"] = "_DAMAGE",
["duration"] = "3",
["event"] = "Combat Log",
["unit"] = "player",
["use_spellName"] = false,
["debuffType"] = "HELPFUL",
["use_sourceUnit"] = true,
["use_spellId"] = true,
["subeventPrefix"] = "SPELL",
["sourceUnit"] = "player",
["spellName"] = {
"Windfury Attack",
},
},
["untrigger"] = {
},
},
{
["trigger"] = {
["type"] = "custom",
["custom_type"] = "event",
["custom_hide"] = "timed",
["use_genericShowOn"] = true,
["genericShowOn"] = "showOnCooldown",
["unit"] = "player",
["realSpellName"] = 0,
["use_spellName"] = true,
["custom"] = "function ()\n    if aura_env.config[\"macroTicks\"] then\n        return true\n    else\n        return false\n    end\nend\n\n\n",
["spellName"] = 0,
["events"] = "PLAYER_ENTER_COMBAT",
["event"] = "Cooldown Progress (Spell)",
["use_track"] = true,
["debuffType"] = "HELPFUL",
},
["untrigger"] = {
},
},
{
["trigger"] = {
["type"] = "combatlog",
["spellId"] = {
"25504",
},
["subeventSuffix"] = "_DAMAGE",
["duration"] = "3",
["event"] = "Combat Log",
["unit"] = "player",
["use_spellName"] = false,
["debuffType"] = "HELPFUL",
["use_sourceUnit"] = true,
["use_spellId"] = true,
["subeventPrefix"] = "SPELL",
["sourceUnit"] = "player",
["spellName"] = {
"Windfury Attack",
},
},
["untrigger"] = {
},
},
{
["trigger"] = {
["enchant"] = "2636",
["itemName"] = 0,
["debuffType"] = "HELPFUL",
["use_showOn"] = true,
["use_genericShowOn"] = true,
["use_itemName"] = true,
["use_enchant"] = true,
["unit"] = "player",
["genericShowOn"] = "showOnCooldown",
["use_weapon"] = true,
["use_unit"] = true,
["showOn"] = "showOnMissing",
["event"] = "Weapon Enchant",
["type"] = "item",
["weapon"] = "main",
},
["untrigger"] = {
},
},
["disjunctive"] = "custom",
["customTriggerLogic"] = "function(t)\n    return t[1] or t[2]\nend",
["activeTriggerMode"] = -10,
},
["internalVersion"] = 89,
["progressSource"] = {
-1,
"",
},
["animation"] = {
["start"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
["main"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
["finish"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
},
["backdropInFront"] = false,
["stickyDuration"] = false,
["version"] = 15,
["subRegions"] = {
{
["type"] = "subbackground",
},
{
["type"] = "subforeground",
},
{
["text_shadowXOffset"] = 1,
["text_text"] = "%p",
["text_text_format_p_time_mod_rate"] = true,
["text_selfPoint"] = "CENTER",
["text_automaticWidth"] = "Auto",
["text_fixedWidth"] = 64,
["text_text_format_p_time_legacy_floor"] = true,
["text_justify"] = "CENTER",
["rotateText"] = "NONE",
["text_text_format_p_format"] = "timed",
["text_text_format_p_time_dynamic_threshold"] = 60,
["type"] = "subtext",
["text_anchorXOffset"] = 0,
["text_color"] = {
1,
1,
1,
1,
},
["text_font"] = "PEPSI",
["text_text_format_p_time_precision"] = 1,
["text_shadowYOffset"] = -1,
["anchorYOffset"] = 0,
["text_wordWrap"] = "WordWrap",
["text_fontType"] = "None",
["text_visible"] = true,
["text_text_format_p_time_format"] = 0,
["anchor_point"] = "CENTER",
["text_fontSize"] = 14,
["anchorXOffset"] = 0,
["text_shadowColor"] = {
0,
0,
0,
1,
},
},
{
["text_shadowXOffset"] = 1,
["text_text"] = "%p",
["text_text_format_p_time_mod_rate"] = true,
["text_selfPoint"] = "AUTO",
["text_automaticWidth"] = "Auto",
["text_fixedWidth"] = 64,
["text_text_format_p_time_legacy_floor"] = true,
["text_justify"] = "CENTER",
["rotateText"] = "NONE",
["text_text_format_p_format"] = "timed",
["anchorXOffset"] = 0,
["anchorYOffset"] = 0,
["type"] = "subtext",
["text_anchorXOffset"] = 0,
["text_color"] = {
1,
1,
1,
1,
},
["text_font"] = "PEPSI",
["text_shadowYOffset"] = -1,
["text_anchorYOffset"] = 60,
["text_text_format_p_time_precision"] = 1,
["text_wordWrap"] = "WordWrap",
["text_fontType"] = "None",
["text_text_format_p_time_format"] = 0,
["text_visible"] = false,
["anchor_point"] = "INNER_CENTER",
["text_fontSize"] = 14,
["text_text_format_p_time_dynamic_threshold"] = 60,
["text_shadowColor"] = {
0,
0,
0,
1,
},
},
{
["type"] = "subborder",
["border_size"] = 2,
["border_visible"] = false,
["text_color"] = {
},
["border_color"] = {
0,
0,
0,
1,
},
["anchor_area"] = "bar",
["border_edge"] = "None",
["border_offset"] = 1,
},
{
["tick_rotation"] = 0,
["tick_xOffset"] = 0,
["tick_desaturate"] = false,
["use_texture"] = false,
["tick_placement_mode"] = "AtPercent",
["tick_texture"] = "Interface\\CastingBar\\UI-CastingBar-Spark",
["tick_length"] = 10,
["progressSources"] = {
{
-2,
"",
},
},
["type"] = "subtick",
["tick_placements"] = {
"50",
},
["automatic_length"] = false,
["tick_thickness"] = 1,
["tick_color"] = {
1,
0.83921568627451,
0.53333333333333,
1,
},
["tick_yOffset"] = 10,
["tick_visible"] = false,
["tick_mirror"] = false,
["tick_blend_mode"] = "ADD",
},
{
["tick_rotation"] = 0,
["tick_xOffset"] = 0,
["tick_desaturate"] = false,
["use_texture"] = false,
["tick_placement_mode"] = "AtPercent",
["tick_texture"] = "Interface\\CastingBar\\UI-CastingBar-Spark",
["tick_length"] = 10,
["progressSources"] = {
{
-2,
"",
},
},
["type"] = "subtick",
["tick_placements"] = {
"40",
},
["automatic_length"] = false,
["tick_thickness"] = 1,
["tick_color"] = {
0.5921568627451,
1,
0.56862745098039,
1,
},
["tick_yOffset"] = 10,
["tick_visible"] = false,
["tick_mirror"] = false,
["tick_blend_mode"] = "ADD",
},
},
["height"] = 30,
["textureSource"] = "LSM",
["sparkBlendMode"] = "ADD",
["backdropColor"] = {
0,
0,
0,
1,
},
["useAdjustedMax"] = false,
["preferToUpdate"] = false,
["barColor2"] = {
1,
1,
0,
1,
},
["borderBackdrop"] = "None",
["borderInFront"] = true,
["config"] = {
["macroTicks"] = true,
},
["icon_side"] = "LEFT",
["spark"] = false,
["authorOptions"] = {
{
["type"] = "toggle",
["default"] = true,
["desc"] = "Enables vertical bars marking the best time frame to sync weapons using the sync macro",
["key"] = "macroTicks",
["useDesc"] = true,
["name"] = "Learning Mode/Assistant",
["width"] = 1,
},
},
["sparkHeight"] = 30,
["zoom"] = 0,
["actions"] = {
["start"] = {
["message"] = "",
["custom"] = "\n    if aura_env.mh_hilight then\n        return true\n    else return false\n    end\n\n\n\n",
["message_type"] = "PRINT",
["message_custom"] = "function ()\n    if aura_env.mh_hilight then\n        return true\n    else return false\n    end\nend\n\n\n",
["do_message"] = false,
["do_custom"] = false,
},
["init"] = {
["custom"] = "if aura_env.mh_hilight then\n    return true\nelse return false\nend\n\n\n\n",
["do_custom"] = false,
},
["finish"] = {
},
},
["anchorFrameType"] = "SCREEN",
["semver"] = "3.0.5",
["id"] = "MH",
["sparkHidden"] = "NEVER",
["backgroundColor"] = {
0.31764705882353,
0.22745098039216,
0.16862745098039,
0.60000002384186,
},
["frameStrata"] = 1,
["width"] = 202,
["useAdjustedMin"] = false,
["useAdjustededMax"] = false,
["inverse"] = true,
["sparkDesature"] = false,
["orientation"] = "HORIZONTAL",
["conditions"] = {
{
["check"] = {
["trigger"] = -1,
["variable"] = "incombat",
["value"] = 0,
},
["changes"] = {
{
["value"] = 0.49,
["property"] = "alpha",
},
{
["value"] = {
0,
0,
0,
1,
},
["property"] = "barColor",
},
},
},
{
["check"] = {
["trigger"] = 6,
["variable"] = "show",
["value"] = 1,
["checks"] = {
{
["trigger"] = 6,
["variable"] = "show",
["value"] = 1,
},
},
},
["changes"] = {
{
["value"] = {
0.60392156862745,
0.55294117647059,
0.56078431372549,
1,
},
["property"] = "barColor",
},
},
},
{
["check"] = {
["trigger"] = 5,
["variable"] = "show",
["value"] = 1,
},
["changes"] = {
{
["value"] = true,
["property"] = "sub.6.tick_visible",
},
{
["value"] = true,
["property"] = "sub.7.tick_visible",
},
},
},
{
["check"] = {
["trigger"] = 7,
["variable"] = "show",
["value"] = 1,
},
["changes"] = {
{
["value"] = {
1,
1,
1,
1,
},
["property"] = "barColor",
},
},
},
},
["information"] = {
["showNilIsFalse"] = true,
["forceEvents"] = true,
["ignoreOptionsEventErrors"] = true,
},
["uid"] = "bteulnmWuVu",
},
["SwingTimer"] = {
["controlledChildren"] = {
"MH",
"OHBar",
"OHTick",
},
["borderBackdrop"] = "Blizzard Tooltip",
["wagoID"] = "fDDNP0SM7",
["xOffset"] = 0,
["preferToUpdate"] = false,
["yOffset"] = -150,
["anchorPoint"] = "CENTER",
["borderColor"] = {
0,
0,
0,
1,
},
["url"] = "https://wago.io/fDDNP0SM7/15",
["actions"] = {
["start"] = {
},
["init"] = {
},
["finish"] = {
},
},
["triggers"] = {
{
["trigger"] = {
["unit"] = "player",
["type"] = "aura2",
["spellIds"] = {
},
["subeventSuffix"] = "_CAST_START",
["subeventPrefix"] = "SPELL",
["debuffType"] = "HELPFUL",
["event"] = "Health",
["names"] = {
},
},
["untrigger"] = {
},
},
},
["internalVersion"] = 89,
["animation"] = {
["start"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
["main"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
["finish"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
},
["version"] = 15,
["subRegions"] = {
},
["load"] = {
["talent"] = {
["multi"] = {
},
},
["spec"] = {
["multi"] = {
},
},
["class"] = {
["multi"] = {
},
},
["size"] = {
["multi"] = {
},
},
},
["backdropColor"] = {
1,
1,
1,
0.5,
},
["scale"] = 1,
["border"] = false,
["borderEdge"] = "Square Full White",
["regionType"] = "group",
["borderSize"] = 2,
["borderOffset"] = 4,
["semver"] = "3.0.5",
["tocversion"] = 20505,
["id"] = "SwingTimer",
["authorOptions"] = {
},
["frameStrata"] = 1,
["anchorFrameType"] = "SCREEN",
["alpha"] = 1,
["uid"] = "9b0ooXp)9Nb",
["config"] = {
},
["borderInset"] = 1,
["conditions"] = {
},
["information"] = {
["forceEvents"] = true,
["showNilIsFalse"] = true,
},
["selfPoint"] = "CENTER",
},
["Sham Shields"] = {
["controlledChildren"] = {
"Lightning shield",
"Wata shield",
},
["borderBackdrop"] = "Blizzard Tooltip",
["wagoID"] = "OPRZeg-u6",
["authorOptions"] = {
},
["preferToUpdate"] = false,
["yOffset"] = 0,
["anchorPoint"] = "CENTER",
["borderColor"] = {
0,
0,
0,
1,
},
["url"] = "https://wago.io/OPRZeg-u6/2",
["actions"] = {
["start"] = {
},
["init"] = {
},
["finish"] = {
},
},
["triggers"] = {
{
["trigger"] = {
["unit"] = "player",
["type"] = "aura2",
["spellIds"] = {
},
["subeventSuffix"] = "_CAST_START",
["subeventPrefix"] = "SPELL",
["debuffType"] = "HELPFUL",
["event"] = "Health",
["names"] = {
},
},
["untrigger"] = {
},
},
},
["internalVersion"] = 89,
["selfPoint"] = "CENTER",
["version"] = 2,
["subRegions"] = {
},
["load"] = {
["talent"] = {
["multi"] = {
},
},
["spec"] = {
["multi"] = {
},
},
["class"] = {
["multi"] = {
},
},
["size"] = {
["multi"] = {
},
},
},
["backdropColor"] = {
1,
1,
1,
0.5,
},
["scale"] = 1,
["border"] = false,
["borderEdge"] = "Square Full White",
["regionType"] = "group",
["borderSize"] = 2,
["borderOffset"] = 4,
["semver"] = "1.2.0",
["tocversion"] = 20505,
["id"] = "Sham Shields",
["uid"] = "pgn179hZoxd",
["frameStrata"] = 1,
["anchorFrameType"] = "SCREEN",
["alpha"] = 1,
["borderInset"] = 1,
["xOffset"] = 0,
["config"] = {
},
["conditions"] = {
},
["information"] = {
["showNilIsFalse"] = true,
},
["animation"] = {
["start"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
["main"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
["finish"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
},
},
["W Shield 2"] = {
["wagoID"] = "OPRZeg-u6",
["authorOptions"] = {
},
["preferToUpdate"] = false,
["yOffset"] = -43.316467285156,
["anchorPoint"] = "CENTER",
["url"] = "https://wago.io/OPRZeg-u6/2",
["actions"] = {
["start"] = {
},
["init"] = {
},
["finish"] = {
},
},
["triggers"] = {
{
["trigger"] = {
["type"] = "aura2",
["stacksOperator"] = ">=",
["auranames"] = {
"Water Shield",
},
["event"] = "Health",
["unit"] = "player",
["useStacks"] = true,
["stacks"] = "2",
["spellIds"] = {
},
["useName"] = true,
["names"] = {
},
["subeventPrefix"] = "SPELL",
["subeventSuffix"] = "_CAST_START",
["debuffType"] = "HELPFUL",
},
["untrigger"] = {
},
},
["activeTriggerMode"] = -10,
},
["internalVersion"] = 89,
["selfPoint"] = "CENTER",
["desaturate"] = false,
["rotation"] = 0,
["version"] = 2,
["subRegions"] = {
{
["type"] = "subbackground",
},
},
["height"] = 38.08532333374,
["rotate"] = false,
["load"] = {
["use_class"] = true,
["use_never"] = false,
["talent"] = {
["multi"] = {
},
},
["use_combat"] = true,
["spec"] = {
["multi"] = {
},
},
["class"] = {
["single"] = "SHAMAN",
["multi"] = {
},
},
["size"] = {
["multi"] = {
},
},
},
["textureWrapMode"] = "CLAMPTOBLACKADDITIVE",
["mirror"] = false,
["regionType"] = "texture",
["blendMode"] = "BLEND",
["texture"] = "Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-73",
["uid"] = "YStTrNHNW(1",
["color"] = {
0,
0.79215693473816,
1,
1,
},
["semver"] = "1.2.0",
["tocversion"] = 20505,
["id"] = "W Shield 2",
["xOffset"] = -84.239196777344,
["alpha"] = 1,
["width"] = 40.273517608643,
["parent"] = "Wata shield",
["config"] = {
},
["anchorFrameType"] = "SCREEN",
["frameStrata"] = 1,
["conditions"] = {
},
["information"] = {
["showNilIsFalse"] = true,
},
["animation"] = {
["start"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
["main"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
["finish"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
},
},
["L Shield 1"] = {
["wagoID"] = "OPRZeg-u6",
["authorOptions"] = {
},
["preferToUpdate"] = false,
["yOffset"] = -96.923095703125,
["anchorPoint"] = "CENTER",
["url"] = "https://wago.io/OPRZeg-u6/2",
["actions"] = {
["start"] = {
},
["init"] = {
},
["finish"] = {
["sound"] = "Interface\\Addons\\FojjiCore\\sound\\Link.ogg",
["do_sound"] = true,
},
},
["triggers"] = {
{
["trigger"] = {
["type"] = "aura2",
["stacksOperator"] = ">=",
["auranames"] = {
"Lightning Shield",
},
["event"] = "Health",
["unit"] = "player",
["useStacks"] = true,
["stacks"] = "1",
["spellIds"] = {
},
["useName"] = true,
["names"] = {
},
["subeventPrefix"] = "SPELL",
["subeventSuffix"] = "_CAST_START",
["debuffType"] = "HELPFUL",
},
["untrigger"] = {
},
},
["activeTriggerMode"] = -10,
},
["internalVersion"] = 89,
["selfPoint"] = "CENTER",
["desaturate"] = false,
["rotation"] = 0,
["version"] = 2,
["subRegions"] = {
{
["type"] = "subbackground",
},
},
["height"] = 38.08532333374,
["rotate"] = false,
["load"] = {
["use_class"] = true,
["use_never"] = false,
["talent"] = {
["multi"] = {
},
},
["use_combat"] = true,
["spec"] = {
["multi"] = {
},
},
["class"] = {
["single"] = "SHAMAN",
["multi"] = {
},
},
["size"] = {
["multi"] = {
},
},
},
["textureWrapMode"] = "CLAMPTOBLACKADDITIVE",
["mirror"] = false,
["regionType"] = "texture",
["blendMode"] = "BLEND",
["texture"] = "Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-73",
["uid"] = "284YsQqMA4B",
["color"] = {
0.0039215688593686,
0,
0.4078431725502,
1,
},
["semver"] = "1.2.0",
["tocversion"] = 20505,
["id"] = "L Shield 1",
["xOffset"] = -61.919689941406,
["alpha"] = 1,
["width"] = 40.273517608643,
["parent"] = "Lightning shield",
["config"] = {
},
["anchorFrameType"] = "SCREEN",
["frameStrata"] = 1,
["conditions"] = {
},
["information"] = {
["showNilIsFalse"] = true,
},
["animation"] = {
["start"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
["main"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
["finish"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
},
},
["OHBar"] = {
["sparkWidth"] = 10,
["iconSource"] = -1,
["xOffset"] = 0,
["adjustedMax"] = "",
["yOffset"] = -24,
["anchorPoint"] = "CENTER",
["sparkRotation"] = 0,
["url"] = "https://wago.io/fDDNP0SM7/15",
["icon"] = false,
["fontFlags"] = "OUTLINE",
["icon_color"] = {
1,
1,
1,
1,
},
["enableGradient"] = false,
["selfPoint"] = "CENTER",
["barColor"] = {
0.13725490196078,
0.32549019607843,
1,
1,
},
["desaturate"] = false,
["sparkOffsetY"] = 0,
["gradientOrientation"] = "HORIZONTAL",
["load"] = {
["talent2"] = {
["multi"] = {
},
},
["use_never"] = true,
["talent"] = {
["single"] = 38,
["multi"] = {
[38] = true,
},
},
["size"] = {
["multi"] = {
},
},
["class"] = {
["single"] = "SHAMAN",
["multi"] = {
["WARRIOR"] = true,
["ROGUE"] = true,
["SHAMAN"] = true,
},
},
["spec"] = {
["single"] = 1,
["multi"] = {
},
},
["role"] = {
["multi"] = {
},
},
["difficulty"] = {
["multi"] = {
},
},
["race"] = {
["multi"] = {
},
},
["use_spec"] = true,
["pvptalent"] = {
["multi"] = {
},
},
["faction"] = {
["multi"] = {
},
},
["use_combat"] = true,
["ingroup"] = {
["multi"] = {
},
},
["zoneIds"] = "",
},
["smoothProgress"] = false,
["useAdjustededMin"] = false,
["regionType"] = "aurabar",
["texture"] = "Solid",
["sparkTexture"] = "Interface\\CastingBar\\UI-CastingBar-Spark",
["auto"] = true,
["tocversion"] = 20505,
["alpha"] = 1,
["sparkColor"] = {
1,
1,
1,
1,
},
["sparkOffsetX"] = 0,
["wagoID"] = "fDDNP0SM7",
["parent"] = "SwingTimer",
["adjustedMin"] = "",
["sparkRotationMode"] = "AUTO",
["triggers"] = {
{
["trigger"] = {
["type"] = "unit",
["genericShowOn"] = "showOnActive",
["unevent"] = "auto",
["use_unit"] = true,
["duration"] = "1",
["event"] = "Swing Timer",
["names"] = {
},
["use_absorbMode"] = true,
["unit"] = "player",
["spellIds"] = {
},
["use_hand"] = true,
["subeventPrefix"] = "SPELL",
["subeventSuffix"] = "_CAST_START",
["hand"] = "off",
["debuffType"] = "HELPFUL",
},
["untrigger"] = {
},
},
{
["trigger"] = {
["type"] = "unit",
["use_alwaystrue"] = true,
["unevent"] = "auto",
["use_absorbMode"] = true,
["genericShowOn"] = "showOnActive",
["unit"] = "player",
["use_unit"] = true,
["event"] = "Conditions",
["subeventPrefix"] = "SPELL",
["subeventSuffix"] = "_CAST_START",
["duration"] = "1",
},
["untrigger"] = {
},
},
{
["trigger"] = {
["type"] = "combatlog",
["spellId"] = {
"33750",
},
["subeventSuffix"] = "_DAMAGE",
["duration"] = "3",
["event"] = "Combat Log",
["unit"] = "player",
["use_spellName"] = false,
["debuffType"] = "HELPFUL",
["use_sourceUnit"] = true,
["use_spellId"] = true,
["subeventPrefix"] = "SPELL",
["sourceUnit"] = "player",
["spellName"] = {
"Windfury Attack",
},
},
["untrigger"] = {
},
},
{
["trigger"] = {
["enchant"] = "2636",
["itemName"] = 0,
["use_genericShowOn"] = true,
["genericShowOn"] = "showOnCooldown",
["unit"] = "player",
["use_weapon"] = true,
["debuffType"] = "HELPFUL",
["type"] = "item",
["use_showOn"] = true,
["use_itemName"] = true,
["realSpellName"] = 0,
["use_spellName"] = true,
["event"] = "Weapon Enchant",
["spellName"] = 0,
["showOn"] = "showOnMissing",
["use_enchant"] = true,
["use_track"] = true,
["weapon"] = "off",
},
["untrigger"] = {
},
},
["disjunctive"] = "custom",
["customTriggerLogic"] = "function(t)\n    return t[1] or t[2]\nend",
["activeTriggerMode"] = -10,
},
["internalVersion"] = 89,
["progressSource"] = {
-1,
"",
},
["animation"] = {
["start"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
["main"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
["finish"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
},
["backdropInFront"] = false,
["stickyDuration"] = false,
["version"] = 15,
["subRegions"] = {
{
["type"] = "subbackground",
},
{
["type"] = "subforeground",
},
{
["text_shadowXOffset"] = 1,
["text_text"] = "%p",
["text_text_format_p_time_mod_rate"] = true,
["text_selfPoint"] = "CENTER",
["text_automaticWidth"] = "Auto",
["text_fixedWidth"] = 64,
["text_text_format_p_time_legacy_floor"] = true,
["text_justify"] = "CENTER",
["rotateText"] = "NONE",
["text_text_format_p_format"] = "timed",
["text_text_format_p_time_dynamic_threshold"] = 60,
["type"] = "subtext",
["text_anchorXOffset"] = 0,
["text_color"] = {
1,
1,
1,
1,
},
["text_font"] = "PEPSI",
["text_text_format_p_time_precision"] = 1,
["text_shadowYOffset"] = -1,
["anchorYOffset"] = 0,
["text_wordWrap"] = "WordWrap",
["text_fontType"] = "None",
["text_visible"] = true,
["text_text_format_p_time_format"] = 0,
["anchor_point"] = "CENTER",
["text_fontSize"] = 14,
["anchorXOffset"] = 0,
["text_shadowColor"] = {
0,
0,
0,
1,
},
},
{
["text_shadowXOffset"] = 1,
["text_text"] = "%p",
["text_text_format_p_time_mod_rate"] = true,
["text_selfPoint"] = "AUTO",
["text_automaticWidth"] = "Auto",
["text_fixedWidth"] = 64,
["text_text_format_p_time_legacy_floor"] = true,
["text_justify"] = "CENTER",
["rotateText"] = "NONE",
["text_text_format_p_format"] = "timed",
["anchorXOffset"] = 0,
["anchorYOffset"] = 0,
["type"] = "subtext",
["text_anchorXOffset"] = 0,
["text_color"] = {
1,
1,
1,
1,
},
["text_font"] = "PEPSI",
["text_shadowYOffset"] = -1,
["text_anchorYOffset"] = 60,
["text_text_format_p_time_precision"] = 1,
["text_wordWrap"] = "WordWrap",
["text_fontType"] = "None",
["text_text_format_p_time_format"] = 0,
["text_visible"] = false,
["anchor_point"] = "INNER_CENTER",
["text_fontSize"] = 30,
["text_text_format_p_time_dynamic_threshold"] = 60,
["text_shadowColor"] = {
0,
0,
0,
1,
},
},
{
["type"] = "subborder",
["border_size"] = 2,
["border_visible"] = false,
["text_color"] = {
},
["border_color"] = {
0,
0,
0,
1,
},
["anchor_area"] = "bar",
["border_edge"] = "None",
["border_offset"] = 1,
},
{
["tick_rotation"] = 0,
["tick_xOffset"] = 0,
["tick_desaturate"] = false,
["use_texture"] = false,
["tick_placement_mode"] = "AtPercent",
["tick_texture"] = "Interface\\CastingBar\\UI-CastingBar-Spark",
["tick_length"] = 10,
["progressSources"] = {
{
-2,
"",
},
},
["type"] = "subtick",
["tick_placements"] = {
"50",
},
["automatic_length"] = false,
["tick_thickness"] = 1,
["tick_color"] = {
1,
0.83921568627451,
0.53333333333333,
1,
},
["tick_yOffset"] = 10,
["tick_visible"] = false,
["tick_mirror"] = false,
["tick_blend_mode"] = "ADD",
},
{
["tick_rotation"] = 0,
["tick_xOffset"] = 0,
["tick_desaturate"] = false,
["use_texture"] = false,
["tick_placement_mode"] = "AtPercent",
["tick_texture"] = "Interface\\CastingBar\\UI-CastingBar-Spark",
["tick_length"] = 10,
["progressSources"] = {
{
-2,
"",
},
},
["type"] = "subtick",
["tick_placements"] = {
"40",
},
["automatic_length"] = false,
["tick_thickness"] = 1,
["tick_color"] = {
0.5921568627451,
1,
0.56862745098039,
1,
},
["tick_yOffset"] = 10,
["tick_visible"] = false,
["tick_mirror"] = false,
["tick_blend_mode"] = "ADD",
},
},
["height"] = 15,
["textureSource"] = "LSM",
["sparkBlendMode"] = "ADD",
["backdropColor"] = {
0,
0,
0,
1,
},
["useAdjustedMax"] = false,
["preferToUpdate"] = false,
["barColor2"] = {
1,
1,
0,
1,
},
["borderBackdrop"] = "None",
["borderInFront"] = true,
["config"] = {
},
["icon_side"] = "LEFT",
["spark"] = false,
["authorOptions"] = {
},
["sparkHeight"] = 30,
["zoom"] = 0,
["actions"] = {
["start"] = {
["message"] = "",
["custom"] = "\n    if aura_env.mh_hilight then\n        return true\n    else return false\n    end\n\n\n\n",
["message_type"] = "PRINT",
["message_custom"] = "function ()\n    if aura_env.mh_hilight then\n        return true\n    else return false\n    end\nend\n\n\n",
["do_message"] = false,
["do_custom"] = false,
},
["init"] = {
["custom"] = "if aura_env.mh_hilight then\n    return true\nelse return false\nend\n\n\n\n",
["do_custom"] = false,
},
["finish"] = {
},
},
["anchorFrameType"] = "SCREEN",
["semver"] = "3.0.5",
["id"] = "OHBar",
["sparkHidden"] = "NEVER",
["backgroundColor"] = {
0.31764705882353,
0.22745098039216,
0.16862745098039,
0.60000002384186,
},
["frameStrata"] = 1,
["width"] = 202,
["useAdjustedMin"] = false,
["useAdjustededMax"] = false,
["inverse"] = true,
["sparkDesature"] = false,
["orientation"] = "HORIZONTAL",
["conditions"] = {
{
["check"] = {
["trigger"] = -1,
["variable"] = "incombat",
["value"] = 0,
},
["changes"] = {
{
["value"] = 0.49,
["property"] = "alpha",
},
{
["value"] = {
0,
0,
0,
1,
},
["property"] = "barColor",
},
},
},
{
["check"] = {
["trigger"] = 3,
["variable"] = "show",
["value"] = 1,
["checks"] = {
{
["value"] = 1,
["variable"] = "show",
},
},
},
["changes"] = {
{
["value"] = {
0.55294117647059,
0.56862745098039,
0.53333333333333,
1,
},
["property"] = "barColor",
},
},
},
{
["check"] = {
["trigger"] = 4,
["variable"] = "show",
["value"] = 1,
},
["changes"] = {
{
["property"] = "barColor",
},
},
},
},
["information"] = {
["showNilIsFalse"] = true,
["forceEvents"] = true,
["ignoreOptionsEventErrors"] = true,
},
["uid"] = "9kp0gx1v2GB",
},
["Wata shield"] = {
["controlledChildren"] = {
"W Shield 3",
"W Shield 2",
"W Shield 1",
},
["borderBackdrop"] = "Blizzard Tooltip",
["wagoID"] = "OPRZeg-u6",
["authorOptions"] = {
},
["preferToUpdate"] = false,
["yOffset"] = -28.145261764526,
["anchorPoint"] = "CENTER",
["borderColor"] = {
0,
0,
0,
1,
},
["url"] = "https://wago.io/OPRZeg-u6/2",
["actions"] = {
["start"] = {
},
["init"] = {
},
["finish"] = {
},
},
["triggers"] = {
{
["trigger"] = {
["unit"] = "player",
["type"] = "aura2",
["spellIds"] = {
},
["subeventSuffix"] = "_CAST_START",
["subeventPrefix"] = "SPELL",
["debuffType"] = "HELPFUL",
["event"] = "Health",
["names"] = {
},
},
["untrigger"] = {
},
},
},
["internalVersion"] = 89,
["selfPoint"] = "CENTER",
["version"] = 2,
["subRegions"] = {
},
["load"] = {
["talent"] = {
["multi"] = {
},
},
["spec"] = {
["multi"] = {
},
},
["class"] = {
["multi"] = {
},
},
["size"] = {
["multi"] = {
},
},
},
["backdropColor"] = {
1,
1,
1,
0.5,
},
["scale"] = 1,
["border"] = false,
["borderEdge"] = "Square Full White",
["regionType"] = "group",
["borderSize"] = 2,
["uid"] = "rQfBiekzqnL",
["borderOffset"] = 4,
["semver"] = "1.2.0",
["tocversion"] = 20505,
["id"] = "Wata shield",
["xOffset"] = -60.171203613281,
["alpha"] = 1,
["anchorFrameType"] = "SCREEN",
["parent"] = "Sham Shields",
["config"] = {
},
["frameStrata"] = 1,
["borderInset"] = 1,
["conditions"] = {
},
["information"] = {
["showNilIsFalse"] = true,
},
["animation"] = {
["start"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
["main"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
["finish"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
},
},
["L Shield 3"] = {
["wagoID"] = "OPRZeg-u6",
["authorOptions"] = {
},
["preferToUpdate"] = false,
["yOffset"] = 8.1025390625,
["anchorPoint"] = "CENTER",
["url"] = "https://wago.io/OPRZeg-u6/2",
["actions"] = {
["start"] = {
},
["init"] = {
},
["finish"] = {
},
},
["triggers"] = {
{
["trigger"] = {
["type"] = "aura2",
["stacksOperator"] = "==",
["auranames"] = {
"Lightning Shield",
},
["event"] = "Health",
["unit"] = "player",
["useStacks"] = true,
["stacks"] = "3",
["spellIds"] = {
},
["useName"] = true,
["names"] = {
},
["subeventPrefix"] = "SPELL",
["subeventSuffix"] = "_CAST_START",
["debuffType"] = "HELPFUL",
},
["untrigger"] = {
},
},
["activeTriggerMode"] = -10,
},
["internalVersion"] = 89,
["selfPoint"] = "CENTER",
["desaturate"] = false,
["rotation"] = 0,
["version"] = 2,
["subRegions"] = {
{
["type"] = "subbackground",
},
},
["height"] = 38.08532333374,
["rotate"] = false,
["load"] = {
["use_class"] = true,
["use_never"] = false,
["talent"] = {
["multi"] = {
},
},
["use_combat"] = true,
["spec"] = {
["multi"] = {
},
},
["class"] = {
["single"] = "SHAMAN",
["multi"] = {
},
},
["size"] = {
["multi"] = {
},
},
},
["textureWrapMode"] = "CLAMPTOBLACKADDITIVE",
["mirror"] = false,
["regionType"] = "texture",
["blendMode"] = "BLEND",
["texture"] = "Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-73",
["uid"] = "V(9vKtKIz)b",
["color"] = {
0.0039215688593686,
0,
0.4078431725502,
1,
},
["semver"] = "1.2.0",
["tocversion"] = 20505,
["id"] = "L Shield 3",
["xOffset"] = -102.19324951172,
["alpha"] = 1,
["width"] = 40.273517608643,
["parent"] = "Lightning shield",
["config"] = {
},
["anchorFrameType"] = "SCREEN",
["frameStrata"] = 1,
["conditions"] = {
},
["information"] = {
["showNilIsFalse"] = true,
},
["animation"] = {
["start"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
["main"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
["finish"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
},
},
["W Shield 1"] = {
["wagoID"] = "OPRZeg-u6",
["authorOptions"] = {
},
["preferToUpdate"] = false,
["yOffset"] = -96.923095703125,
["anchorPoint"] = "CENTER",
["url"] = "https://wago.io/OPRZeg-u6/2",
["actions"] = {
["start"] = {
},
["init"] = {
},
["finish"] = {
["sound"] = "Interface\\Addons\\FojjiCore\\sound\\Link.ogg",
["do_sound"] = true,
},
},
["triggers"] = {
{
["trigger"] = {
["type"] = "aura2",
["stacksOperator"] = ">=",
["auranames"] = {
"Water Shield",
},
["event"] = "Health",
["unit"] = "player",
["useStacks"] = true,
["stacks"] = "1",
["spellIds"] = {
},
["useName"] = true,
["names"] = {
},
["subeventPrefix"] = "SPELL",
["subeventSuffix"] = "_CAST_START",
["debuffType"] = "HELPFUL",
},
["untrigger"] = {
},
},
["activeTriggerMode"] = -10,
},
["internalVersion"] = 89,
["selfPoint"] = "CENTER",
["desaturate"] = false,
["rotation"] = 0,
["version"] = 2,
["subRegions"] = {
{
["type"] = "subbackground",
},
},
["height"] = 38.08532333374,
["rotate"] = false,
["load"] = {
["use_class"] = true,
["use_never"] = false,
["talent"] = {
["multi"] = {
},
},
["use_combat"] = true,
["spec"] = {
["multi"] = {
},
},
["class"] = {
["single"] = "SHAMAN",
["multi"] = {
},
},
["size"] = {
["multi"] = {
},
},
},
["textureWrapMode"] = "CLAMPTOBLACKADDITIVE",
["mirror"] = false,
["regionType"] = "texture",
["blendMode"] = "BLEND",
["texture"] = "Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-73",
["uid"] = "NZrH1zj9FTV",
["color"] = {
0,
0.79215693473816,
1,
1,
},
["semver"] = "1.2.0",
["tocversion"] = 20505,
["id"] = "W Shield 1",
["xOffset"] = -61.919689941406,
["alpha"] = 1,
["width"] = 40.273517608643,
["parent"] = "Wata shield",
["config"] = {
},
["anchorFrameType"] = "SCREEN",
["frameStrata"] = 1,
["conditions"] = {
},
["information"] = {
["showNilIsFalse"] = true,
},
["animation"] = {
["start"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
["main"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
["finish"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
},
},
["L Shield 2"] = {
["wagoID"] = "OPRZeg-u6",
["authorOptions"] = {
},
["preferToUpdate"] = false,
["yOffset"] = -43.316467285156,
["anchorPoint"] = "CENTER",
["url"] = "https://wago.io/OPRZeg-u6/2",
["actions"] = {
["start"] = {
},
["init"] = {
},
["finish"] = {
},
},
["triggers"] = {
{
["trigger"] = {
["type"] = "aura2",
["stacksOperator"] = ">=",
["auranames"] = {
"Lightning Shield",
},
["event"] = "Health",
["unit"] = "player",
["useStacks"] = true,
["stacks"] = "2",
["spellIds"] = {
},
["useName"] = true,
["names"] = {
},
["subeventPrefix"] = "SPELL",
["subeventSuffix"] = "_CAST_START",
["debuffType"] = "HELPFUL",
},
["untrigger"] = {
},
},
["activeTriggerMode"] = -10,
},
["internalVersion"] = 89,
["selfPoint"] = "CENTER",
["desaturate"] = false,
["rotation"] = 0,
["version"] = 2,
["subRegions"] = {
{
["type"] = "subbackground",
},
},
["height"] = 38.08532333374,
["rotate"] = false,
["load"] = {
["use_class"] = true,
["use_never"] = false,
["talent"] = {
["multi"] = {
},
},
["use_combat"] = true,
["spec"] = {
["multi"] = {
},
},
["class"] = {
["single"] = "SHAMAN",
["multi"] = {
},
},
["size"] = {
["multi"] = {
},
},
},
["textureWrapMode"] = "CLAMPTOBLACKADDITIVE",
["mirror"] = false,
["regionType"] = "texture",
["blendMode"] = "BLEND",
["texture"] = "Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-73",
["uid"] = "vUdZjgIeaYU",
["color"] = {
0.0039215688593686,
0,
0.4078431725502,
1,
},
["semver"] = "1.2.0",
["tocversion"] = 20505,
["id"] = "L Shield 2",
["xOffset"] = -84.239196777344,
["alpha"] = 1,
["width"] = 40.273517608643,
["parent"] = "Lightning shield",
["config"] = {
},
["anchorFrameType"] = "SCREEN",
["frameStrata"] = 1,
["conditions"] = {
},
["information"] = {
["showNilIsFalse"] = true,
},
["animation"] = {
["start"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
["main"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
["finish"] = {
["type"] = "none",
["easeStrength"] = 3,
["duration_type"] = "seconds",
["easeType"] = "none",
},
},
},
},
["login_squelch_time"] = 10,
["lastArchiveClear"] = 1777260853,
["minimap"] = {
["minimapPos"] = 185.7741015309161,
["hide"] = false,
},
["lastUpgrade"] = 1777260857,
["dbVersion"] = 89,
["migrationCutoff"] = 730,
["features"] = {
},
["registered"] = {
},
["historyCutoff"] = 730,
["editor_font_size"] = 12,
}
