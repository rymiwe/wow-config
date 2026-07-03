-- Element moods for GMOTD flavor text (spell names, not casts).
-- Fire/Water: damage school. Earth: rock/dirt/soil/plant + shaman earth totems.
-- Air: lightning/storm Nature. Nature split earth vs air for non-totem spells.
GuildMotdData = GuildMotdData or {}

GuildMotdData.ELEMENTS = {
    {
        key = "Water",
        lord = "Neptulon stirs the tide.",
        moods = {
            "Frostbolt",
            "Frost Shock",
            "Blizzard",
            "Cone of Cold",
            "Frost Trap",
        },
    },
    {
        key = "Earth",
        lord = "Therazane holds the line.",
        moods = {
            -- Shaman earth totems + shock
            "Earth Shock",
            "Stoneclaw Totem",
            "Stoneskin Totem",
            "Strength of Earth Totem",
            "Earthbind Totem",
            "Tremor Totem",
            "Earth Elemental Totem",
            -- Druid nature (ground/plant)
            "Entangling Roots",
            "Insect Swarm",
            "Wrath",
            "Force of Nature",
        },
    },
    {
        key = "Fire",
        lord = "Ragnaros is restless.",
        moods = {
            "Fireball",
            "Scorch",
            "Flame Shock",
            "Immolate",
            "Searing Totem",
            "Magma Totem",
            "Fire Nova Totem",
            "Rain of Fire",
            "Hellfire",
            "Searing Pain",
            "Pyroblast",
            "Flamestrike",
            "Blast Wave",
            "Dragon's Breath",
            "Explosive Trap",
            "Soul Fire",
            "Incinerate",
        },
    },
    {
        key = "Air",
        lord = "Al'Akir rides the gale.",
        moods = {
            "Chain Lightning",
            "Lightning Bolt",
            "Lightning Shield",
            "Hurricane",
            "Stormstrike",
        },
    },
}