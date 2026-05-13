
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
["finish"] = {
},
["init"] = {
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
["subeventSuffix"] = "_CAST_START",
["subeventPrefix"] = "SPELL",
["names"] = {
},
["useName"] = true,
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
["spec"] = {
["multi"] = {
},
},
["use_combat"] = true,
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
["config"] = {
},
["animation"] = {
["start"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
["main"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
["finish"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
},
["semver"] = "1.2.0",
["tocversion"] = 20505,
["id"] = "W Shield 3",
["xOffset"] = -102.19324951172,
["alpha"] = 1,
["width"] = 40.273517608643,
["parent"] = "Wata shield",
["uid"] = "bKDFLW2aasC",
["frameStrata"] = 1,
["anchorFrameType"] = "SCREEN",
["conditions"] = {
},
["information"] = {
["showNilIsFalse"] = true,
},
["color"] = {
0,
0.79215693473816,
1,
1,
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
["finish"] = {
},
["init"] = {
},
},
["triggers"] = {
{
["trigger"] = {
["names"] = {
},
["type"] = "aura2",
["spellIds"] = {
},
["subeventSuffix"] = "_CAST_START",
["subeventPrefix"] = "SPELL",
["debuffType"] = "HELPFUL",
["event"] = "Health",
["unit"] = "player",
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
["size"] = {
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
["talent"] = {
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
["frameStrata"] = 1,
["borderOffset"] = 4,
["semver"] = "1.2.0",
["tocversion"] = 20505,
["id"] = "Lightning shield",
["animation"] = {
["start"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
["main"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
["finish"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
},
["alpha"] = 1,
["anchorFrameType"] = "SCREEN",
["parent"] = "Sham Shields",
["uid"] = "Q1U6c1N03cL",
["config"] = {
},
["borderInset"] = 1,
["conditions"] = {
},
["information"] = {
["showNilIsFalse"] = true,
},
["xOffset"] = -60.171203613281,
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
["zoom"] = 0,
["sparkRotation"] = 0,
["sparkRotationMode"] = "AUTO",
["url"] = "https://wago.io/fDDNP0SM7/15",
["actions"] = {
["start"] = {
},
["finish"] = {
},
["init"] = {
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
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
["main"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
["finish"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
},
["backgroundColor"] = {
0,
0,
0,
0,
},
["barColor"] = {
1,
0,
0.015686274509804,
0,
},
["desaturate"] = false,
["barColor2"] = {
1,
1,
0,
1,
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
["class"] = {
["multi"] = {
},
},
["use_combat"] = true,
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
["enableGradient"] = false,
["uid"] = "7y6BGEkcT6p",
["sparkColor"] = {
1,
0,
0.03921568627451,
1,
},
["selfPoint"] = "CENTER",
["anchorFrameType"] = "SCREEN",
["useAdjustededMin"] = false,
["regionType"] = "aurabar",
["alpha"] = 1,
["sparkOffsetY"] = 0,
["icon_side"] = "RIGHT",
["sparkHidden"] = "FULL",
["sparkHeight"] = 30,
["texture"] = "Solid",
["spark"] = true,
["sparkTexture"] = "Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_White",
["semver"] = "3.0.5",
["tocversion"] = 20505,
["id"] = "OHTick",
["gradientOrientation"] = "HORIZONTAL",
["frameStrata"] = 1,
["width"] = 202,
["authorOptions"] = {
{
["type"] = "toggle",
["default"] = false,
["key"] = "bigBadSync",
["name"] = "Emphasize Bad Sync",
["useDesc"] = false,
["width"] = 1,
},
{
["type"] = "toggle",
["default"] = false,
["width"] = 1,
["name"] = "Colorblind Mode",
["useDesc"] = true,
["key"] = "CbM",
["desc"] = "Might help with red-green colorblindness",
},
},
["config"] = {
["CbM"] = false,
["bigBadSync"] = false,
},
["inverse"] = true,
["icon"] = false,
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
["information"] = {
["showNilIsFalse"] = true,
["forceEvents"] = true,
},
["iconSource"] = -1,
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
["zoneIds"] = "",
["class"] = {
["single"] = "SHAMAN",
["multi"] = {
["WARRIOR"] = true,
["SHAMAN"] = true,
["ROGUE"] = true,
},
},
["ingroup"] = {
["multi"] = {
},
},
["race"] = {
["multi"] = {
},
},
["difficulty"] = {
["multi"] = {
},
},
["role"] = {
["multi"] = {
},
},
["pvptalent"] = {
["multi"] = {
},
},
["faction"] = {
["multi"] = {
},
},
["use_spec"] = true,
["use_combat"] = true,
["spec"] = {
["single"] = 1,
["multi"] = {
},
},
["size"] = {
["multi"] = {
},
},
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
["event"] = "Swing Timer",
["unevent"] = "auto",
["names"] = {
},
["duration"] = "1",
["genericShowOn"] = "showOnActive",
["use_unit"] = true,
["subeventSuffix"] = "_CAST_START",
["subeventPrefix"] = "SPELL",
["spellIds"] = {
},
["use_hand"] = true,
["unit"] = "player",
["use_absorbMode"] = true,
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
["duration"] = "1",
["subeventSuffix"] = "_CAST_START",
["subeventPrefix"] = "SPELL",
["event"] = "Conditions",
["use_unit"] = true,
},
["untrigger"] = {
},
},
{
["trigger"] = {
["type"] = "unit",
["event"] = "Swing Timer",
["unevent"] = "auto",
["names"] = {
},
["duration"] = "1",
["genericShowOn"] = "showOnActive",
["use_unit"] = true,
["subeventSuffix"] = "_CAST_START",
["subeventPrefix"] = "SPELL",
["spellIds"] = {
},
["use_hand"] = true,
["unit"] = "player",
["use_absorbMode"] = true,
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
["spellName"] = {
"Windfury Attack",
},
["use_sourceUnit"] = true,
["use_spellId"] = true,
["subeventPrefix"] = "SPELL",
["sourceUnit"] = "player",
["debuffType"] = "HELPFUL",
},
["untrigger"] = {
},
},
{
["trigger"] = {
["type"] = "custom",
["custom_type"] = "event",
["debuffType"] = "HELPFUL",
["use_genericShowOn"] = true,
["genericShowOn"] = "showOnCooldown",
["unit"] = "player",
["realSpellName"] = 0,
["use_spellName"] = true,
["custom"] = "function ()\n    if aura_env.config[\"macroTicks\"] then\n        return true\n    else\n        return false\n    end\nend\n\n\n",
["spellName"] = 0,
["event"] = "Cooldown Progress (Spell)",
["events"] = "PLAYER_ENTER_COMBAT",
["use_track"] = true,
["custom_hide"] = "timed",
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
["spellName"] = {
"Windfury Attack",
},
["use_sourceUnit"] = true,
["use_spellId"] = true,
["subeventPrefix"] = "SPELL",
["sourceUnit"] = "player",
["debuffType"] = "HELPFUL",
},
["untrigger"] = {
},
},
{
["trigger"] = {
["enchant"] = "2636",
["itemName"] = 0,
["weapon"] = "main",
["use_showOn"] = true,
["use_genericShowOn"] = true,
["use_itemName"] = true,
["use_enchant"] = true,
["type"] = "item",
["event"] = "Weapon Enchant",
["use_weapon"] = true,
["use_unit"] = true,
["showOn"] = "showOnMissing",
["genericShowOn"] = "showOnCooldown",
["unit"] = "player",
["debuffType"] = "HELPFUL",
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
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
["main"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
["finish"] = {
["easeStrength"] = 3,
["type"] = "none",
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
["text_shadowColor"] = {
0,
0,
0,
1,
},
["anchorXOffset"] = 0,
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
["text_text_format_p_time_format"] = 0,
["text_visible"] = true,
["anchor_point"] = "CENTER",
["text_fontSize"] = 14,
["text_text_format_p_time_dynamic_threshold"] = 60,
["text_text_format_p_format"] = "timed",
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
["text_shadowColor"] = {
0,
0,
0,
1,
},
["text_text_format_p_time_dynamic_threshold"] = 60,
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
["text_anchorYOffset"] = 60,
["text_shadowYOffset"] = -1,
["text_visible"] = false,
["text_wordWrap"] = "WordWrap",
["text_fontType"] = "None",
["text_text_format_p_time_format"] = 0,
["text_text_format_p_time_precision"] = 1,
["anchor_point"] = "INNER_CENTER",
["text_fontSize"] = 14,
["anchorXOffset"] = 0,
["text_text_format_p_format"] = "timed",
},
{
["border_size"] = 2,
["border_offset"] = 1,
["anchor_area"] = "bar",
["text_color"] = {
},
["border_color"] = {
0,
0,
0,
1,
},
["border_visible"] = false,
["border_edge"] = "None",
["type"] = "subborder",
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
["tick_blend_mode"] = "ADD",
["tick_mirror"] = false,
["tick_visible"] = false,
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
["tick_blend_mode"] = "ADD",
["tick_mirror"] = false,
["tick_visible"] = false,
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
["uid"] = "bteulnmWuVu",
["information"] = {
["showNilIsFalse"] = true,
["forceEvents"] = true,
["ignoreOptionsEventErrors"] = true,
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
["width"] = 1,
["name"] = "Learning Mode/Assistant",
["useDesc"] = true,
["key"] = "macroTicks",
["desc"] = "Enables vertical bars marking the best time frame to sync weapons using the sync macro",
},
},
["sparkHeight"] = 30,
["useAdjustededMax"] = false,
["useAdjustedMin"] = false,
["width"] = 202,
["semver"] = "3.0.5",
["sparkHidden"] = "NEVER",
["id"] = "MH",
["backgroundColor"] = {
0.31764705882353,
0.22745098039216,
0.16862745098039,
0.60000002384186,
},
["frameStrata"] = 1,
["anchorFrameType"] = "SCREEN",
["actions"] = {
["start"] = {
["message"] = "",
["custom"] = "\n    if aura_env.mh_hilight then\n        return true\n    else return false\n    end\n\n\n\n",
["message_type"] = "PRINT",
["do_custom"] = false,
["do_message"] = false,
["message_custom"] = "function ()\n    if aura_env.mh_hilight then\n        return true\n    else return false\n    end\nend\n\n\n",
},
["finish"] = {
},
["init"] = {
["custom"] = "if aura_env.mh_hilight then\n    return true\nelse return false\nend\n\n\n\n",
["do_custom"] = false,
},
},
["zoom"] = 0,
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
["barColor2"] = {
1,
1,
0,
1,
},
["preferToUpdate"] = false,
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
["finish"] = {
},
["init"] = {
},
},
["triggers"] = {
{
["trigger"] = {
["names"] = {
},
["type"] = "aura2",
["spellIds"] = {
},
["subeventSuffix"] = "_CAST_START",
["subeventPrefix"] = "SPELL",
["debuffType"] = "HELPFUL",
["event"] = "Health",
["unit"] = "player",
},
["untrigger"] = {
},
},
},
["internalVersion"] = 89,
["animation"] = {
["start"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
["main"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
["finish"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
},
["version"] = 15,
["subRegions"] = {
},
["load"] = {
["size"] = {
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
["talent"] = {
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
["borderInset"] = 1,
["alpha"] = 1,
["anchorFrameType"] = "SCREEN",
["frameStrata"] = 1,
["uid"] = "9b0ooXp)9Nb",
["config"] = {
},
["selfPoint"] = "CENTER",
["conditions"] = {
},
["information"] = {
["forceEvents"] = true,
["showNilIsFalse"] = true,
},
["authorOptions"] = {
},
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
["finish"] = {
},
["init"] = {
},
},
["triggers"] = {
{
["trigger"] = {
["names"] = {
},
["type"] = "aura2",
["spellIds"] = {
},
["subeventSuffix"] = "_CAST_START",
["subeventPrefix"] = "SPELL",
["debuffType"] = "HELPFUL",
["event"] = "Health",
["unit"] = "player",
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
["size"] = {
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
["talent"] = {
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
["alpha"] = 1,
["frameStrata"] = 1,
["anchorFrameType"] = "SCREEN",
["animation"] = {
["start"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
["main"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
["finish"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
},
["uid"] = "pgn179hZoxd",
["borderInset"] = 1,
["config"] = {
},
["conditions"] = {
},
["information"] = {
["showNilIsFalse"] = true,
},
["xOffset"] = 0,
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
["finish"] = {
},
["init"] = {
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
["subeventSuffix"] = "_CAST_START",
["subeventPrefix"] = "SPELL",
["names"] = {
},
["useName"] = true,
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
["spec"] = {
["multi"] = {
},
},
["use_combat"] = true,
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
["config"] = {
},
["animation"] = {
["start"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
["main"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
["finish"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
},
["semver"] = "1.2.0",
["tocversion"] = 20505,
["id"] = "L Shield 2",
["xOffset"] = -84.239196777344,
["alpha"] = 1,
["width"] = 40.273517608643,
["parent"] = "Lightning shield",
["uid"] = "vUdZjgIeaYU",
["frameStrata"] = 1,
["anchorFrameType"] = "SCREEN",
["conditions"] = {
},
["information"] = {
["showNilIsFalse"] = true,
},
["color"] = {
0.0039215688593686,
0,
0.4078431725502,
1,
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
["zoneIds"] = "",
["class"] = {
["single"] = "SHAMAN",
["multi"] = {
["WARRIOR"] = true,
["SHAMAN"] = true,
["ROGUE"] = true,
},
},
["ingroup"] = {
["multi"] = {
},
},
["race"] = {
["multi"] = {
},
},
["difficulty"] = {
["multi"] = {
},
},
["role"] = {
["multi"] = {
},
},
["pvptalent"] = {
["multi"] = {
},
},
["faction"] = {
["multi"] = {
},
},
["use_spec"] = true,
["use_combat"] = true,
["spec"] = {
["single"] = 1,
["multi"] = {
},
},
["size"] = {
["multi"] = {
},
},
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
["event"] = "Swing Timer",
["unevent"] = "auto",
["names"] = {
},
["duration"] = "1",
["genericShowOn"] = "showOnActive",
["use_unit"] = true,
["subeventSuffix"] = "_CAST_START",
["subeventPrefix"] = "SPELL",
["spellIds"] = {
},
["use_hand"] = true,
["unit"] = "player",
["use_absorbMode"] = true,
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
["duration"] = "1",
["subeventSuffix"] = "_CAST_START",
["subeventPrefix"] = "SPELL",
["event"] = "Conditions",
["use_unit"] = true,
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
["spellName"] = {
"Windfury Attack",
},
["use_sourceUnit"] = true,
["use_spellId"] = true,
["subeventPrefix"] = "SPELL",
["sourceUnit"] = "player",
["debuffType"] = "HELPFUL",
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
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
["main"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
["finish"] = {
["easeStrength"] = 3,
["type"] = "none",
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
["text_shadowColor"] = {
0,
0,
0,
1,
},
["anchorXOffset"] = 0,
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
["text_text_format_p_time_format"] = 0,
["text_visible"] = true,
["anchor_point"] = "CENTER",
["text_fontSize"] = 14,
["text_text_format_p_time_dynamic_threshold"] = 60,
["text_text_format_p_format"] = "timed",
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
["text_shadowColor"] = {
0,
0,
0,
1,
},
["text_text_format_p_time_dynamic_threshold"] = 60,
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
["text_anchorYOffset"] = 60,
["text_shadowYOffset"] = -1,
["text_visible"] = false,
["text_wordWrap"] = "WordWrap",
["text_fontType"] = "None",
["text_text_format_p_time_format"] = 0,
["text_text_format_p_time_precision"] = 1,
["anchor_point"] = "INNER_CENTER",
["text_fontSize"] = 30,
["anchorXOffset"] = 0,
["text_text_format_p_format"] = "timed",
},
{
["border_size"] = 2,
["border_offset"] = 1,
["anchor_area"] = "bar",
["text_color"] = {
},
["border_color"] = {
0,
0,
0,
1,
},
["border_visible"] = false,
["border_edge"] = "None",
["type"] = "subborder",
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
["tick_blend_mode"] = "ADD",
["tick_mirror"] = false,
["tick_visible"] = false,
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
["tick_blend_mode"] = "ADD",
["tick_mirror"] = false,
["tick_visible"] = false,
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
["uid"] = "9kp0gx1v2GB",
["information"] = {
["showNilIsFalse"] = true,
["forceEvents"] = true,
["ignoreOptionsEventErrors"] = true,
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
["useAdjustededMax"] = false,
["useAdjustedMin"] = false,
["width"] = 202,
["semver"] = "3.0.5",
["sparkHidden"] = "NEVER",
["id"] = "OHBar",
["backgroundColor"] = {
0.31764705882353,
0.22745098039216,
0.16862745098039,
0.60000002384186,
},
["frameStrata"] = 1,
["anchorFrameType"] = "SCREEN",
["actions"] = {
["start"] = {
["message"] = "",
["custom"] = "\n    if aura_env.mh_hilight then\n        return true\n    else return false\n    end\n\n\n\n",
["message_type"] = "PRINT",
["do_custom"] = false,
["do_message"] = false,
["message_custom"] = "function ()\n    if aura_env.mh_hilight then\n        return true\n    else return false\n    end\nend\n\n\n",
},
["finish"] = {
},
["init"] = {
["custom"] = "if aura_env.mh_hilight then\n    return true\nelse return false\nend\n\n\n\n",
["do_custom"] = false,
},
},
["zoom"] = 0,
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
["barColor2"] = {
1,
1,
0,
1,
},
["preferToUpdate"] = false,
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
["finish"] = {
["sound"] = "Interface\\Addons\\FojjiCore\\sound\\Link.ogg",
["do_sound"] = true,
},
["init"] = {
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
["subeventSuffix"] = "_CAST_START",
["subeventPrefix"] = "SPELL",
["names"] = {
},
["useName"] = true,
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
["spec"] = {
["multi"] = {
},
},
["use_combat"] = true,
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
["config"] = {
},
["animation"] = {
["start"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
["main"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
["finish"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
},
["semver"] = "1.2.0",
["tocversion"] = 20505,
["id"] = "L Shield 1",
["xOffset"] = -61.919689941406,
["alpha"] = 1,
["width"] = 40.273517608643,
["parent"] = "Lightning shield",
["uid"] = "284YsQqMA4B",
["frameStrata"] = 1,
["anchorFrameType"] = "SCREEN",
["conditions"] = {
},
["information"] = {
["showNilIsFalse"] = true,
},
["color"] = {
0.0039215688593686,
0,
0.4078431725502,
1,
},
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
["finish"] = {
},
["init"] = {
},
},
["triggers"] = {
{
["trigger"] = {
["names"] = {
},
["type"] = "aura2",
["spellIds"] = {
},
["subeventSuffix"] = "_CAST_START",
["subeventPrefix"] = "SPELL",
["debuffType"] = "HELPFUL",
["event"] = "Health",
["unit"] = "player",
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
["size"] = {
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
["talent"] = {
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
["frameStrata"] = 1,
["borderOffset"] = 4,
["semver"] = "1.2.0",
["tocversion"] = 20505,
["id"] = "Wata shield",
["animation"] = {
["start"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
["main"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
["finish"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
},
["alpha"] = 1,
["anchorFrameType"] = "SCREEN",
["parent"] = "Sham Shields",
["uid"] = "rQfBiekzqnL",
["config"] = {
},
["borderInset"] = 1,
["conditions"] = {
},
["information"] = {
["showNilIsFalse"] = true,
},
["xOffset"] = -60.171203613281,
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
["finish"] = {
},
["init"] = {
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
["subeventSuffix"] = "_CAST_START",
["subeventPrefix"] = "SPELL",
["names"] = {
},
["useName"] = true,
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
["spec"] = {
["multi"] = {
},
},
["use_combat"] = true,
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
["config"] = {
},
["animation"] = {
["start"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
["main"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
["finish"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
},
["semver"] = "1.2.0",
["tocversion"] = 20505,
["id"] = "L Shield 3",
["xOffset"] = -102.19324951172,
["alpha"] = 1,
["width"] = 40.273517608643,
["parent"] = "Lightning shield",
["uid"] = "V(9vKtKIz)b",
["frameStrata"] = 1,
["anchorFrameType"] = "SCREEN",
["conditions"] = {
},
["information"] = {
["showNilIsFalse"] = true,
},
["color"] = {
0.0039215688593686,
0,
0.4078431725502,
1,
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
["finish"] = {
["sound"] = "Interface\\Addons\\FojjiCore\\sound\\Link.ogg",
["do_sound"] = true,
},
["init"] = {
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
["subeventSuffix"] = "_CAST_START",
["subeventPrefix"] = "SPELL",
["names"] = {
},
["useName"] = true,
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
["spec"] = {
["multi"] = {
},
},
["use_combat"] = true,
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
["config"] = {
},
["animation"] = {
["start"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
["main"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
["finish"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
},
["semver"] = "1.2.0",
["tocversion"] = 20505,
["id"] = "W Shield 1",
["xOffset"] = -61.919689941406,
["alpha"] = 1,
["width"] = 40.273517608643,
["parent"] = "Wata shield",
["uid"] = "NZrH1zj9FTV",
["frameStrata"] = 1,
["anchorFrameType"] = "SCREEN",
["conditions"] = {
},
["information"] = {
["showNilIsFalse"] = true,
},
["color"] = {
0,
0.79215693473816,
1,
1,
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
["finish"] = {
},
["init"] = {
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
["subeventSuffix"] = "_CAST_START",
["subeventPrefix"] = "SPELL",
["names"] = {
},
["useName"] = true,
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
["spec"] = {
["multi"] = {
},
},
["use_combat"] = true,
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
["config"] = {
},
["animation"] = {
["start"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
["main"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
["finish"] = {
["easeStrength"] = 3,
["type"] = "none",
["duration_type"] = "seconds",
["easeType"] = "none",
},
},
["semver"] = "1.2.0",
["tocversion"] = 20505,
["id"] = "W Shield 2",
["xOffset"] = -84.239196777344,
["alpha"] = 1,
["width"] = 40.273517608643,
["parent"] = "Wata shield",
["uid"] = "YStTrNHNW(1",
["frameStrata"] = 1,
["anchorFrameType"] = "SCREEN",
["conditions"] = {
},
["information"] = {
["showNilIsFalse"] = true,
},
["color"] = {
0,
0.79215693473816,
1,
1,
},
},
},
["editor_font_size"] = 12,
["lastArchiveClear"] = 1777260853,
["minimap"] = {
["minimapPos"] = 185.77,
["hide"] = false,
},
["lastUpgrade"] = 1777260857,
["dbVersion"] = 89,
["migrationCutoff"] = 730,
["features"] = {
},
["login_squelch_time"] = 10,
["historyCutoff"] = 730,
["registered"] = {
},
}
