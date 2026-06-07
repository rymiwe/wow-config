-- Element moods: TBC spells that deal Fire, Frost, or Nature damage.
-- Nature is split earth (ground/plant/sting) vs air (lightning/storm).
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
            "Earth Shock",
            "Wrath",
            "Insect Swarm",
            "Serpent Sting",
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