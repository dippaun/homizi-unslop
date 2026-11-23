# Unslop audit and design pass

Method: [unslop](https://github.com/heydamir/unslop) by Damir Sokolovsky
([@heydamir](https://x.com/heydamir)), CC BY 4.0. Audit against its
`references/signs.md`, then nine passes in order: spacing, color, icons,
copy, type, layout, details, visuals, motion. Each pass is one commit on
the local branch `unslop-design-pass`, so any pass can be reverted alone.

Baseline: `main` at `c37b265` (22 Nov 2026).

## Screens audited

| Area | Main files |
| --- | --- |
| Home | `features/home/home_screen.dart`, `home_listing_deck.dart`, `core/widgets/compartment_bar.dart` |
| Search and results | `features/search_properties/*`, `features/discovery/flats_swipe_deck.dart`, `features/search_flow/*` |
| Listing cards | `shared/widgets/homizi_property_card.dart`, `features/discovery/listing_card.dart`, `core/widgets/listing_widgets.dart` |
| Listing detail | `features/discovery/listing_detail_lower.dart`, `listing_detail_sections.dart`, `host_public_profile_page.dart`, `features/listings/rent_cost_breakdown.dart` |
| Roommate | `features/roommates/finder/*`, `features/find_roomie/*`, `features/priorities/*`, `features/seekers/*` |
| Chat | `features/chat/chat_inbox_screen.dart`, `features/likes/tenant_likes_screen.dart` |
| Profile | `features/profile/profile_me_screen.dart`, `profile_hub_screen.dart`, `animated_profile_photo.dart` |
| Onboarding and OTP | `features/auth/login_screen.dart`, `auth/otp/*`, `auth_celebration.dart`, `registration_finish_screen.dart`, `features/profile_create/*` |
| Verify | `features/verification/kyc_screen.dart`, `features/profile/verification_panel.dart` |
| Post property | `features/post_property/*`, `features/listings/listing_wizard_steps.dart` |
| Shell | `features/shell/glassy_nav_bar.dart`, `ui/kit/page_background.dart`, `core/theme/*` |

## Verdict

Heavy slop in the chrome, good content underneath. The listing photos,
the Indian homes, names and rupee figures are real and specific. Around
them, colour, weight and effects were spread over everything. Full
process, not polish mode.

## Signs found (main)

### Surfaces and color
- **Purple off-brand.** `homiziPurple #6A3DE8` and `homiziLavender` in 55
  places across 20 files: Post Property selection, chips, borders, icons,
  likes/chat/profile tiles, wizard lock notes.
- **Hue-to-hue gradients.** 40 `LinearGradient`s in 27 files. Orange into
  purple on Post Property heroes (`post_property_chrome.dart`) and the
  Message CTA (`listing_detail_lower.dart:597`). Pastel orange into
  lavender on the cost card, contact gate and rent estimate. Orange
  gradients on selected tabs (seeker matches, priorities, split modes),
  on the `P1` badges, the "How It Works" pill, avatar rings, the OTP
  badge, the sign-in lock circle, the seeker header band, the compartment
  tiles. 3 `SweepGradient` rings (match score, priority wheel, profile
  photo) in two or three hues.
- **Five near-identical CTA gradients.** logo orange into red-orange,
  deep orange, vermilion, or purple, depending on the screen.
- **Coloured glow.** Compartment tile casts an orange 28% shadow when
  selected and grows to 1.04.
- **Rainbow tints.** Listing fact tiles each get their own pastel
  (peach, lavender, yellow, green, blue, teal). Profile stats are four
  pills in four colours. Poster-kind tags in brown, green, indigo.
- **Raw hex outside the token file.** 51 `Color(0x..)` literals in 17
  files.
- **Decorative watermark.** A faint orange skyline drawn behind most
  pages and under the bottom tabs, plus two blurred orange washes on
  "soft" pages.
- Cool grey page (`#F7F8FA`) against a warm brand.

### Type
- 424 uses of `FontWeight.w800/w900` and 267 of `w700` in 124 files.
  Theme headings at 800, buttons at 800.
- 17 font sizes in use, including 10, 10.5, 26, 30, 34.
- Tracked uppercase `OR` divider. Wordmark tracking varies 0.4 to 1.6.

### Icons
- `🎉` in the welcome headline. `✓` glued to "Profile complete".
- 8 `Icons.auto_awesome` sparkles used for matches, fit reasons and the
  rent estimate.

### Spacing
- One-off values in paddings and gaps: 14 (96), 18 (37), 3 (14), 5 (10),
  13, 11, 22, 46.
- 21 different corner radii, from 0.6 to 999. Cards at 20, controls at
  14, inputs at 16, chips at 20 (pill).

### Copy
- Exclamation marks: "Welcome back!", "Almost there!", "Profile
  Completed!", "Great Match!", "Registration Successful!", "Request
  accepted!", "are a match!", "You are moving in!".
- Unverifiable promise: "get 3+ more matches".
- "See all >" with a typed arrow. Title Case badge "How It Works".

### Motion
- Verification panel pulses forever (1.4 s reverse loop).
- Profile photo ring spins forever (8 s loop).
- 8 `Curves.easeOutBack` overshoots.

## Direction

- **Product.** HOMIZI helps people in India rent a home, find a flatmate
  or list a room, with verified hosts and honest rent maths.
- **Character.** Warm, straight-talking, a little homely.
- **World.** A rented flat in an Indian city at evening: a warm
  off-white wall, ink-blue type, the orange of the HOMIZI mark.
- **Moments.** The listing photos and roommate portraits carry the
  colour. The match ring and rent figure are the one place orange and
  green mean something. The orange skyline is the sign-in moment.
- **Signature.** The single orange-to-red action gradient: it appears
  only on the button that moves you forward, never on decoration.

Locked brand rules kept: colours only through `HomiziColors`; orange/red
gradient only on primary actions; green for verification and
compatibility; blue only for secondary info; no white text on yellow;
one Back per page; no new screens; no NoBroker branding.

## Passes

1. **Spacing.** `HomiziSpace` scale (4 to 48, page, card) and
   `HomiziRadius`. Odd paddings and gaps snapped to the 4px grid in 70
   files.
2. **Color.** Purple removed. `HomiziGradients.action` is the one
   gradient, on primary actions only. Selected tabs and badges solid
   ink; decorative pastels solid white or warm wash; rings solid.
   Raw hex moved into tokens. Warm off-white page and hairline.
3. **Icons.** Emoji and glued ✓ removed. Sparkles replaced with icons
   that say what the thing is.
4. **Copy.** No exclamation marks, no unverifiable promise, sentence
   case badge.
5. **Type.** Weights 400 to 600 (wordmark and swipe stamps keep 700).
   `HomiziType` scale. Nothing under 11.
6. **Layout.** Home section header with a real chevron. Profile stats
   as one row of equal, quiet tiles with tabular figures.
7. **Details.** Theme radii from tokens (controls 12, chips 8, cards
   16). Hand-written radii snapped. Flat cards with a hairline. Softer
   neutral shadows, `HomiziElevation`. No glow.
8. **Visuals.** Skyline only on sign-in; page and tab-bar watermarks
   and orange washes removed.
9. **Motion.** `HomiziMotion` (one curve, three durations). No
   overshoot, no decorative loops.

## Left as suggestions

- Plus Jakarta Sans and Inter have no Devanagari. The app ships Hindi,
  so a family drawn for both scripts (for example Mukta or Hind) would
  serve Hindi readers better. Not changed: it needs a new bundled font.
- Feature names in Title Case ("Find Your Roomie", "Post Your Property",
  "Search Properties") are product names used across tests and copy;
  left as they are.
- The welcome confetti could be reduced to one short burst.

## v3 direction (23 Nov 2026) — replaces the v2 Indian-motif pass

Deep rejected v2: "Indian" meant real Indian flats and houses in the
listings, not jaali, kolam, block-print, jharokha or skyline patterns, and
the patterned cream backgrounds read as average. v3 is a new direction,
not a tweak.

**Reference bar.** Top property apps (Airbnb, Zillow, Housing.com): the
photo is the product, the chrome is quiet, and one dark surface carries
the brand.

**Surface system.**
- Page: neutral stone `#F5F3F0` (`HomiziColors.cream`/`soft`), never
  white and never patterned. Deeper stone `#EDE9E3` for wells.
- Cards: white, 20–24px radius, soft ink shadow, no outline.
- Dark sections: ink `#172033` (`HomiziColors.ink`), `inkDeep` for the
  wide-screen stage, `inkRaised` for pills on ink, `onInkMuted` (9:1)
  for secondary text on ink.
- Role heroes (`HomiziHeroBand` / `HomiziRoleIntro`): an ink panel over a
  real Indian home photo with a left-to-right ink scrim (copy side ≥12:1)
  and a soft light in the role's `glow` colour.

**Brand palette, used deliberately.**
- Orange `#F47B0B`: the active nav pill (ink icon, 5.95:1), the second
  line of the home promise on ink, accents.
- Red Orange `#CC3015` → Deep Red `#A92310`: primary action gradient
  with white text (5.25:1+); small links in red orange.
- Yellow/Golden: only on ink (11:1 / 8.5:1) for eyebrows, ticks and
  icons. Never white text on yellow.
- Role glows (eyebrow, ring, light): tenant orange, flatmate yellow,
  owner deep orange (4.56:1 on ink), PG golden, partner yellow, sharer
  golden.
- Logo orange `#F75620` is no longer used for text (3.3:1 on white);
  prices are ink.
- Green only for verification/match; blue only for secondary info.

**Type.** Poppins 600 for display, titles, prices and buttons, with
slight negative tracking; Inter for body. Yatra One removed.

**Imagery.** Bundled Pexels photos shot in Indian cities (Mumbai,
Bengaluru, Hyderabad, Noida, Kochi, Goa, Jodhpur, Ahmedabad) replace the
Western stock in `assets/photos`, `assets/images/real` and
`assets/images/home`; demo portraits are Indian people. File names and
sizes are unchanged, so listing data did not move. Sources are in each
folder's CREDITS file (Pexels License: free, commercial use allowed).

**Screens.**
- Home: dark photo hero (Mumbai high-rise) with "Zero brokerage ·
  verified owners", the promise, and city pills; white photo action
  cards with a tinted icon badge; ink trust band with three proof points.
- Nav: dark ink bar with rounded top, orange active pill.
- Listing cards: photo-first, Poppins title, ink price; "Set
  preferences" is a white pill over photos.
- Listing detail: gallery, then the facts on a white sheet with rounded
  top; Poppins ink price; outlined white fact tiles.
- Role dashboards (owner, PG owner, partner/broker, room sharer, host):
  the shared dark photo hero with the role glow; owner leads and visits
  as white cards.
- Profile: photo, name, role on the role hero; stats in a white card.
- Role picker: white cards with the role photo as a thumb.
- Login: dark Mumbai photo panel behind the lockup; white auth card.
- Empty states: a rounded real-home photo with a white icon badge.

**Motion kept.** Press-scale with light haptic, staggered entrances,
pull-to-refresh, listing photo Hero into detail, swipe haptics; all
honour reduced motion.

**Known gaps.** Wizard steps, chats, verify and settings use the new
surfaces and type through the theme but were not individually redrawn;
some older screens still use logo orange for icon accents (non-text).
