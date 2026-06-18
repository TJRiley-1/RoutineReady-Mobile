# RoutineReady — Brand Guidelines

Single source of truth for RoutineReady's visual identity. Derived from the live
website (routineready.co.uk). **When the website and the Flutter app disagree,
the website is canonical** — see "Known inconsistency" at the bottom.

Machine-readable versions of these tokens live alongside this file:
`brand-tokens.css` (CSS custom properties) and `brand-tokens.json`.

---

## Brand essence

> **Visual Schedules for Calmer Classrooms**
> *Every child deserves to know what comes next.*

Warm, calm, reassuring. The product reduces transition anxiety for autistic
learners, so the brand should feel **soft, predictable and trustworthy** — never
clinical, loud or "techy". Warm off-whites over stark white; muted sage-teal
over bright cyan; generous spacing; gentle rounded corners.

---

## Colour palette

### Primary — Teal
| Token | Hex | Use |
|---|---|---|
| `teal` | `#1a7f7a` | Primary brand colour: buttons, logo badge, "Ready", links |
| `teal-light` | `#2a9e98` | Hover/active highlights, subtle accents |
| `teal-dark` | `#0f5550` | Button hover, pressed states, deep contrast |
| `teal-faint` | `#f0faf9` | Tinted backgrounds, info panels |
| `teal-mid` | `#c8e9e7` | Borders on teal-tinted panels, dividers |

### Accent — Amber
| Token | Hex | Use |
|---|---|---|
| `amber` | `#f59e0b` | Sparing accent: highlights, stars, small emphasis only |
| `amber-dark` | `#d97706` | Amber hover/contrast |

> **Amber is a seasoning, not a base.** Use it for a single highlight (a star, a
> code, one word) — never large fills or primary buttons.

### Neutrals
| Token | Hex | Use |
|---|---|---|
| `dark` | `#1c2b2a` | Headlines & body text (warm near-black, NOT cool gray) |
| `warm-gray` | `#6b7280` | Secondary/muted text |
| `cream` | `#faf8f5` | Page background (warm off-white) |
| `white` | `#ffffff` | Cards, surfaces |
| `border` | `#e8eceb` | Hairline borders, dividers |

---

## Typography

Both fonts are Google Fonts (free, web + email-safe via `<link>`).

| Role | Font | Fallback stack | Weights |
|---|---|---|---|
| Headlines, wordmark | **Lora** (serif) | `Georgia, 'Times New Roman', serif` | 400, 600, 700 (+ italic 400) |
| Body, UI, buttons | **DM Sans** (sans) | `-apple-system, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif` | 400, 500, 600, 700 |

- Headlines: Lora, `letter-spacing: -0.01em`, line-height ~1.25.
- Body: DM Sans, line-height ~1.6.
- In email, web fonts load in Apple Mail / iOS Mail and gracefully fall back to
  the stacks above elsewhere. **Note:** the bundled Twinkl handwriting fonts are
  for the *in-app display*, not marketing/brand surfaces.

---

## Logo & wordmark

**Wordmark:** "Routine Ready" set in **Lora**.
- "Routine" in `dark` (`#1c2b2a`)
- "Ready" in `teal` (`#1a7f7a`)

**Logo mark (badge):** a 32px rounded square (`border-radius: 8px`) filled
`teal`, containing a white outlined **clock** icon (18px, 2px round stroke).
The clock = "knowing what comes next". Standalone asset: `brand/logo-mark.svg`.

Lockup: badge, then a 0.5rem gap, then the wordmark, vertically centred.

---

## Buttons

| Property | Value |
|---|---|
| Background | `teal` (`#1a7f7a`) |
| Border | `1.5px solid teal` |
| Text | white, DM Sans, weight 600 |
| Radius | `6px` |
| Hover | background + border → `teal-dark` (`#0f5550`) |
| Padding | ~`0.45rem 1.1rem` (web); roomier (14px 32px) for email/touch |

Secondary/ghost: transparent background, `1.5px solid teal` border, teal text.

---

## Shape & depth

- **Card radius:** `12px`. **Button/input radius:** `6px`. Badge: `8px`.
- **Shadow (soft, teal-tinted):** `0 4px 24px rgba(26, 127, 122, 0.08)`.
- Borders are hairline `#e8eceb`. Avoid heavy drop shadows.

---

## Voice & tone

- Reassuring, plain-English, never jargon. Speak to tired teachers and anxious
  children's needs.
- Short sentences. Calm, not salesy. "you can safely ignore this" over "DO NOT
  share this code!!".
- UK English (organise, colour, personalise).
- Contact: **info@routineready.co.uk**

---

## Known inconsistency (action needed)

The Flutter app (`lib/config/theme_constants.dart`) currently uses a **brighter
teal `#0D9488`** and cool grays (`#1F2937`, `#F9FAFB`), which do **not** match
the website's warmer `#1a7f7a` / `#1c2b2a` / `#faf8f5`. To make all surfaces
consistent, the app theme should be realigned to the tokens above. Tracked as a
follow-up — not yet applied.
