# Chat panel theme — image generation prompts

For when you generate panel textures via claude.ai (Sonnet 4.6 native image
gen), Midjourney, DALL-E, or similar.

## General principles for any prompt

- **Aspect ratio: 2:1** (wide format). Final texture is 512×256.
- **Subtle, designery, NOT on-the-nose.** Wallpaper-style, not illustration-of-an-object.
- **Negative space dominates.** ~60-70% of the image should be quiet/empty so chat text reads.
- **Low-saturation palette.** No primary-color brightness — muted/desaturated tones win.
- **No text, no UI elements, no logos.** Just the visual texture.
- **Dark or transparent base.** Chat text is white, so backgrounds must be dark for readability.

## After generating

```bash
python scripts/png-to-tga.py ~/Downloads/your-image.png <name>
```

Then map the texture in `_anniversary_/Interface/AddOns/ChatPanelThemes/ChatPanelThemes.lua`:

```lua
local CHAR_TEXTURE = { Ocisly = "ocisly" }     -- per-character override
local CLASS_TEXTURE = { DRUID = "druid" }       -- per-class default
```

`/rl` in WoW.

---

## Prompt: kid's Druid character (pugs + strawberries + Balance druid)

> A subtle, designery wallpaper texture in 2:1 horizontal format. Dark forest-green watercolor wash background with soft painterly grain. Sparsely placed, abstracted decorative elements: small simplified strawberry silhouettes in muted dusty rose, abstract paw-print motifs in cream-colored ink (just the pad shape, very stylized), and one delicate crescent moon in pale gold tucked into a corner. Composition is asymmetric and balanced, with significant negative space (60% empty/dark). Inspired by boutique stationery design and high-end children's book illustration. Refined, never cartoonish. NO text, NO bright colors, NO realistic detail — pure pattern. Suitable as a chat backdrop where white text must read clearly over the design.

## Prompt: generic Druid (no character-specific theme)

> A subtle, designery wallpaper texture in 2:1 horizontal format. Dark forest-green watercolor wash with painterly organic grain. Sparse, abstracted leaf shapes — simplified silhouettes of oak, fern, and clover — in muted sage and emerald inks. Composition is asymmetric, with delicate vine traces and significant negative space (~65% empty/dark). Style references Japanese ink-wash botanical art crossed with modern boutique stationery. NO realistic detail, NO bright colors. Suitable as a chat backdrop where white text must read clearly.

## Prompt: Warlock (fel/shadow theme)

> Subtle, designery wallpaper texture in 2:1 horizontal format. Deep charcoal-purple watercolor wash with smoky organic grain. Sparse abstracted motifs: faint wisp tendrils in muted fel-green, simplified rune fragments in dusty violet, one barely-visible pentagram traced in pale gold tucked into a corner. Heavily asymmetric, ~70% negative space. Style references occult tarot card backs crossed with high-end stationery. NO realistic skulls or demons, NO bright neon colors. Suitable as a chat backdrop where white text must read clearly.

## Prompt: Mage (frost/arcane theme)

> Subtle, designery wallpaper texture in 2:1 horizontal format. Deep midnight-blue watercolor wash with crystalline grain. Sparse abstracted motifs: faint frost-fractal shapes in pale cyan, simplified arcane sigil fragments in muted lavender, delicate snowflake silhouettes scattered minimally. Asymmetric composition, ~65% negative space. Style references frosted glass etching crossed with ornate book endpapers. NO bright magic effects, NO sci-fi detail. Suitable as a chat backdrop where white text must read clearly.

## Prompt: Paladin (holy/heraldic theme)

> Subtle, designery wallpaper texture in 2:1 horizontal format. Deep ochre-and-charcoal watercolor wash with parchment grain. Sparse heraldic motifs: faint cross-and-laurel fragments in muted gold leaf, simplified shield outlines in dusty bronze, one delicate sunburst tucked into a corner. Asymmetric, ~65% negative space. Style references medieval illuminated manuscripts crossed with boutique stationery. NO bright gold gleam, NO realistic armor. Suitable as a chat backdrop where white text must read clearly.

## Prompt template — fill in your own class/character

> Subtle, designery wallpaper texture in 2:1 horizontal format. **[BASE COLOR]** watercolor wash with **[GRAIN STYLE]** organic grain. Sparse abstracted motifs: **[MOTIF 1]** in muted **[ACCENT 1]**, simplified **[MOTIF 2]** in dusty **[ACCENT 2]**, one delicate **[FEATURE]** tucked into a corner. Asymmetric composition, ~65% negative space. Style references **[ART STYLE REFERENCE]** crossed with boutique stationery. NO bright colors, NO literal detail. Suitable as a chat backdrop where white text must read clearly.
