-- KeyKit Core: keyboard layout, text format, binding-string helpers.
-- No WoW API calls here, so this file can be loaded and tested outside the game.
local _, ns = ...
ns = ns or {}

-- Left-hand board, the same keys the profiles in profiles/keybinds/ use.
-- { WoW key name, cap label, width in key units }
ns.ROWS = {
  { { "ESCAPE", "Esc", 1 }, { "`", "`", 1 }, { "1", "1", 1 }, { "2", "2", 1 }, { "3", "3", 1 }, { "4", "4", 1 }, { "5", "5", 1 }, { "6", "6", 1 } },
  { { "TAB", "Tab", 1.5 }, { "Q", "Q", 1 }, { "W", "W", 1 }, { "E", "E", 1 }, { "R", "R", 1 }, { "T", "T", 1 } },
  { { "CAPSLOCK", "Caps", 1.75 }, { "A", "A", 1 }, { "S", "S", 1 }, { "D", "D", 1 }, { "F", "F", 1 }, { "G", "G", 1 }, { "H", "H", 1 } },
  { { "LSHIFT", "Shift", 2.25 }, { "Z", "Z", 1 }, { "X", "X", 1 }, { "C", "C", 1 }, { "V", "V", 1 }, { "B", "B", 1 } },
  { { "LCTRL", "Ctrl", 1.5 }, { "LALT", "Alt", 1.5 }, { "SPACE", "Space", 3.25 } },
}
ns.MOUSE = { { "BUTTON3", "M3" }, { "BUTTON4", "M4" }, { "BUTTON5", "M5" } }

-- Modifier keys themselves are drawn but never bound.
ns.UNBINDABLE = { LSHIFT = true, LCTRL = true, LALT = true }

ns.LAYERS = { "none", "shift", "alt", "ctrl" }
ns.LAYER_PREFIX = { none = "", shift = "SHIFT-", alt = "ALT-", ctrl = "CTRL-" }

-- Same colors as the PNG renders (0-1 RGB).
ns.ROLE_COLORS = {
  rotation  = { 0.85, 0.66, 0.28 },
  cc        = { 0.86, 0.38, 0.35 },
  defensive = { 0.38, 0.58, 0.90 },
  heal      = { 0.35, 0.73, 0.51 },
  buff      = { 0.66, 0.51, 0.86 },
  movement  = { 0.47, 0.54, 0.60 },
  utility   = { 0.31, 0.69, 0.69 },
}

-- Every key KeyKit draws, in every layer. Used by Export and by Undo snapshots.
function ns.AllKeys()
  local keys = {}
  local function add(base)
    if ns.UNBINDABLE[base] then return end
    for _, layer in ipairs(ns.LAYERS) do
      keys[#keys + 1] = ns.LAYER_PREFIX[layer] .. base
    end
  end
  for _, row in ipairs(ns.ROWS) do
    for _, k in ipairs(row) do add(k[1]) end
  end
  for _, m in ipairs(ns.MOUSE) do add(m[1]) end
  return keys
end

-- "ALT-1" -> "1", "alt"
function ns.SplitKey(key)
  for _, layer in ipairs({ "shift", "alt", "ctrl" }) do
    local p = ns.LAYER_PREFIX[layer]
    if key:sub(1, #p) == p then return key:sub(#p + 1), layer end
  end
  return key, "none"
end

-- GetBindingAction() strings -> kind, value.
--   "SPELL Frostbolt" -> spell, "MACRO Pet" -> macro,
--   "CLICK Btn:LeftButton" -> click, anything else -> cmd.
function ns.ActionToEntry(action)
  if not action or action == "" then return nil end
  local kind, value = action:match("^(%u+) (.+)$")
  if kind == "SPELL" then return "spell", value end
  if kind == "MACRO" then return "macro", value end
  if kind == "CLICK" then return "click", value end
  if kind == "ITEM" then return "item", value end
  return "cmd", action
end

-- Binding command -> action slot it fires (page 1). nil if not a bar button.
-- ELVUIBAR2BUTTON is the Shift bar (page 2), ELVUIBAR10BUTTON the Ctrl bar (page 10).
local BAR_BASE = {
  ACTIONBUTTON = 0, ELVUIBAR2BUTTON = 12, ELVUIBAR10BUTTON = 108, MULTIACTIONBAR3BUTTON = 24, MULTIACTIONBAR4BUTTON = 36,
  MULTIACTIONBAR2BUTTON = 48, MULTIACTIONBAR1BUTTON = 60,
  MULTIACTIONBAR5BUTTON = 144, MULTIACTIONBAR6BUTTON = 156, MULTIACTIONBAR7BUTTON = 168,
}
function ns.SlotForCommand(cmd)
  if not cmd then return nil end
  local bar, n = cmd:match("^(%u[%u%d]-BUTTON)(%d+)$")
  n = tonumber(n)
  if bar and BAR_BASE[bar] and n >= 1 and n <= 12 then return BAR_BASE[bar] + n end
  return nil
end

-- Every slot on the bar a command belongs to: "MULTIACTIONBAR3BUTTON5" -> 25..36.
function ns.BarSlots(cmd)
  local bar = cmd and cmd:match("^(%u[%u%d]-BUTTON)%d+$")
  local base = bar and BAR_BASE[bar]
  if not base then return nil end
  local slots = {}
  for n = 1, 12 do slots[n] = base + n end
  return bar, slots
end

local function trim(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end

local HEADER_FIELDS = { name = true, class = true, levels = true, note = true, url = true }
local KINDS = { spell = true, item = true, macro = true, click = true, cmd = true }

--[[ KeyKit text format, version 1. One item per line:

  # KeyKit 1
  name = My hunter
  class = hunter
  levels = 10-30
  note = Pet on Q, traps on Alt
  url = https://example.com/where-i-got-this
  1 = spell Arcane Shot
  ALT-1 = spell Serpent Sting
  W = cmd TOGGLEAUTORUN
  BUTTON4 = macro PetAttack
  C = item Hearthstone
  F = click MyAddonButton:LeftButton

Keys are WoW key names (ALT-/CTRL-/SHIFT- prefixes, BUTTON3-5 for the mouse).
Lines starting with # are comments. Only "name" and one binding are required.
]]
function ns.Parse(text)
  local p = { binds = {}, levels = "any", class = "any", note = "", url = "" }
  local n = 0
  for raw in (text or ""):gmatch("[^\r\n]+") do
    n = n + 1
    local line = trim(raw)
    if line ~= "" and line:sub(1, 1) ~= "#" then
      local left, right = line:match("^(.-)%s*=%s*(.*)$")
      if not left or left == "" then
        return nil, ("line %d: expected 'key = value'"):format(n)
      end
      local field = left:lower()
      if HEADER_FIELDS[field] then
        p[field] = right
      else
        local kind, value = right:match("^(%a+)%s+(.+)$")
        kind = kind and kind:lower()
        if not kind or not KINDS[kind] then
          return nil, ("line %d: use 'KEY = spell|item|macro|click|cmd <name>'"):format(n)
        end
        local key = left:upper()
        local base, layer = ns.SplitKey(key)
        p.binds[#p.binds + 1] = { key = key, base = base, layer = layer, label = value, kind = kind, value = value }
      end
    end
  end
  if not p.name or p.name == "" then return nil, "missing 'name = ...' line" end
  if #p.binds == 0 then return nil, "no bindings found" end
  p.title = p.name
  p.id = "personal:" .. p.name
  return p
end

function ns.Format(p)
  local out = { "# KeyKit 1" }
  out[#out + 1] = "name = " .. (p.name or p.title or "Untitled")
  for _, f in ipairs({ "class", "levels", "note", "url" }) do
    if p[f] and p[f] ~= "" then out[#out + 1] = f .. " = " .. p[f] end
  end
  for _, b in ipairs(p.binds) do
    if b.kind then out[#out + 1] = b.key .. " = " .. b.kind .. " " .. b.value end
  end
  return table.concat(out, "\n")
end

return ns
