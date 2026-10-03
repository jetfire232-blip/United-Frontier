# United Frontier — Phase 9 Complete Warfare

United Frontier is a modern economy, diplomacy, resource, intelligence, and strategic-warfare expansion for War.app. It builds on the stable Global Affairs foundation while reorganizing the player experience around a cleaner Overview, private resource intelligence, visible military assets, Headquarters systems, stronger AI planning, and host-configurable strategic development.

## Main Tabs

- **Overview** — command dashboard, alerts, Commerce, allies/faction, war status, resource warnings, flagship company movement, military summary, and AI Manager status.
- **Markets** — stocks, flagship companies, ETF, dividends, investments, War Bonds, Global Economy, and AI Manager.
- **Resources** — production, requirements, stockpiles, shortages, private resource intelligence, facilities, offers, requests, and active contracts.
- **Military** — Headquarters, Recruiters, Airbases, Forward Airstrips, SAM Sites, Missile Silos, Power Grid, Air Wings, Special Forces, and strategic asset management.
- **Diplomacy** — relations, alliances, factions, Current Wars, Join War, peace, NAPs, Headquarters sharing, and diplomatic actions.
- **United Nations** — Security Council voting, sanctions, embargoes, aid, condemnations, and ceasefires.
- **How It Works** — detailed rules and examples.
- **Customize Tabs** — player UI preferences and alerts.

## Strategic Resources

Resources are Oil, Gas, Uranium, Iron, Food, Rare Earths, Coal, Copper, and Lithium.

Resource locations are **not globally exposed as standing map icons**. A player learns a resource location through:

1. ownership;
2. a resource territory directly bordering that specific player's territory;
3. faction intelligence;
4. an ally with accepted Shared Intelligence; or
5. Headquarters Intelligence discovery.

The Resources UI provides filters for **My Resources**, **Neighbors**, **Ally/Faction**, **HQ Intel**, and **All Known**, with Show-on-Map highlighting.

Resource stockpiles persist. Surplus production is stored and later deficits consume stockpile before uncovered shortages apply penalties. Resource facilities are capped at visual Level 5. Uranium is intentionally rare, expensive, and not automatically granted based on national Commerce.

## Resource Market

Players may **offer** or **request** resources. Accepted contracts exchange resources for Commerce while active. Resource trades affect effective production before stockpile shortage resolution.

## Military Assets

The current military asset set is:

- Headquarters
- Recruiting Stations
- Airbases
- Forward Airstrips
- SAM Sites
- Missile Silos
- Power / Electrical Grid
- Air Wings
- Special Forces

Military installation locations are visible map assets. Sensitive military details can remain intelligence-dependent. Power Grid is deliberately public.

Headquarters, Airbases, Airstrips, SAMs, Silos, Power Grids, and Recruiters use structure-style map assets. Air Wings and Special Forces use custom special-unit icons and remain visible purchasable units.

## Headquarters

Headquarters uses four top-level branches:

- **Intelligence**
- **Security**
- **Cyber Warfare**
- **Joint Command**

Headquarters Intelligence supports private resource discovery and military-detail discovery. Target Security reduces intelligence effectiveness.

Faction members automatically share strategic intelligence. Normal allies do not automatically share private intelligence: allied players can separately request **Shared Intelligence** and **Joint Strategic Warning**.

## Air Wings and Special Forces

Air Wings are visible custom special units and require Airbase capacity. The host controls how many aircraft one Air Wing represents for scenario scale.

Special Forces are visible custom special units intended to remain elite rather than replacing normal armies. Dedicated Special Forces operation missions are not included in this release.

## Territory Selection

Build and targeting flows use a consistent pattern:

**Choose action → dialog closes → click territory → fresh confirmation dialog opens → review → confirm.**

This avoids stale UI callbacks and makes mobile map selection easier. Resource development also shows current resource levels on the selected territory before confirmation.

## Smart AI

Smart AI is being upgraded around national planning:

- Peace / tension / war / emergency priorities.
- Light peacetime border screens with second-line reserves.
- Better Recruiter placement.
- Resource shortage response.
- Military infrastructure development.
- Air Wing / SAM / Silo prioritization during war.
- Reduced unnecessary Commerce hoarding.
- War Economy priorities that reduce nonessential market/investment spending.

Human players may optionally use AI Manager. AI Manager reserves a defined Commerce budget for the current turn and may allocate it to Markets, Investments, Resources, Recruiters, and military development. Disabling AI Manager restores full manual Commerce control on the following turn, not mid-turn.

## United Nations

Security Council actions include Sanctions, Embargo, Aid, Condemnation, and Ceasefire. Host settings control proposal pacing and council rules.

Sanctions and Ceasefires use host-configurable minimum and maximum durations. A passed Ceasefire forces peace and blocks immediate redeclaration for the selected duration.

## Performance and Safety

United Frontier retains the Global Affairs long-game safeguards:

- bounded PublicGameData histories;
- spectator/reviewer-safe menus;
- guarded custom-message actions;
- cached economy/resource work;
- strategic data stored privately when appropriate;
- custom structure image count kept below War.app's 100-image limit.

## Current Build Notes

This all-in-one development build integrates the new navigation, resource intelligence, Headquarters sharing, visible military structure framework, Air Wing/Special Forces custom units, territory-selection rewrite, Overview command dashboard, AI strategic spending foundation, resource trading/requests, UN duration controls, and existing Global Affairs economy/diplomacy systems.

Strategic missile inventory/reload, SAM interception, EMP/nuclear area effects, cyber disruption, and the Operational/Damaged/Disabled/Destroyed repair loop are included for testing. Dedicated Air Wing and Special Forces operation mission menus are intentionally removed from this release.

## QA Checklist

Test in a fresh development game:

- Mod reloads with no structure-image error.
- Overview dashboard loads for player and spectator.
- Resources filters show only permitted intelligence.
- Resource Offer and Request contracts work.
- Resource facility territory selector closes/reopens cleanly.
- Headquarters construction and branch upgrades.
- Intelligence resource/military scans.
- Alliance Shared Intelligence and faction automatic sharing.
- Recruiter construction/upgrades and army generation.
- Airbase, Airstrip, SAM, Silo, and Grid construction/upgrades.
- Military structures appear on the map after turn advancement.
- Air Wing and Special Forces purchases appear as custom units.
- AI Manager reserved Commerce and spending breakdown.
- AI military/resource spending in war.
- UN Sanctions/Ceasefire durations.
- Current Wars / Join War / diplomacy regression.
- Spectator/incognito click-through.


## Special Unit Image Hotfix
Air Wing and Special Forces icons are 60x60 PNG files, matching War.app special-unit image limits and the reference mods.


## Phase 7 - Operational Warfare Pass

- Headquarters now requires an operational Power Grid before construction and command-system use.
- HQ branches are capped at five meaningful levels and show current/next effects and Commerce cost.
- Missile Command adds Silo resupply, conventional/EMP/nuclear targeting, and turn-advance strike resolution.
- Airlift Card orders are restricted to Airbase / Forward Airstrip endpoints.
- Smart AI receives supplemental frontline attacks, rear-to-front transfers, Power Grid-before-HQ planning, HQ branch development, and stronger allied-war support.
- Human Trade Agreements are directly accessible from Markets.


## Phase 7 integrated operations
- HQ operational actions now appear below branch upgrades.
- Cyber Warfare Level 1 can launch a basic disruption operation.
- Security shows passive counterintelligence / warning status.
- Joint Command links directly to alliance and faction controls.
- HQ and missile results use simple SUCCESS / FAILED / NO DAMAGE / DAMAGED / DISABLED / DESTROYED feedback.
- SHOW buttons close the mod menu before highlighting the map.
- AI nations can use real Airlift Cards between Airbases / Forward Airstrips during war to reinforce front airports.
- Current Wars now uses player colors and colored status/stat lines for readability.

## Phase 8 - Finalization Pass

This pass focuses on usability, Headquarters depth, market visibility, controlled AI diplomacy, Special Forces operations, and strategic AI targeting.

### Added / changed
- Resource intelligence rows now support SHOW with a compact map-return control and direct UPGRADE for owned deposits; MAX replaces upgrade when capped.
- Headquarters now displays Lv.0-Lv.5 progress bars, unlocked effects, next-upgrade Commerce cost, Security report access, and retained operation reports.
- AI Alliance proposals are restricted to established Trade Agreement partners or nations in the same broad ideology bloc; AI no longer randomly allies across the entire game.
- UN Ceasefire target discovery is limited to nations the proposing player is actually at war with.
- War Bonds were removed from the player Markets UI.
- Markets now includes public trend panels for flagship-stock momentum, global resource demand, strongest militaries (rank only), and largest Commerce reserves (rank only).
- Stock dividends continue to scale with the issuing nation's Commerce income and now include a host Dividend Payout Scale setting.
- Strategic AI attack scoring now prioritizes Headquarters, Recruiting Stations, Power Grids, Missile Silos, Airbases, SAMs, and valuable resource territories. AI Airlifts also prioritize threatened strategic areas.
- SHOW HQ / SHOW military asset now clears the main menu and leaves a compact Back control over the map.

### Still intentionally separate / next test focus
- Complete SAM interception resolution against Air Wings and strategic missiles.
- Full persistent damaged/disabled/repair state system and advanced EMP effects.
- Expanded nuclear yield/AoE balancing.


## Phase 9 complete warfare pass

- Persistent asset condition data for damage/disable states plus a player Repair screen.
- EMP strategic disruption and nuclear Low/Medium/High yield targeting.
- Nuclear strikes affect armies, city/territory damage records, resource facilities, and strategic assets; medium/high yields can spread to adjacent territories.
- Stock Market wording now explicitly exposes buying other players’ publicly traded flagship shares.


## Phase 10 - Market & Navigation Polish

- World Trends now stores a fresh Strongest Militaries and Largest Commerce Reserves ranking every turn.
- Resource Demand ranking was removed.
- SHOW map actions now leave a visible Back button that returns to the exact Resources/HQ/Military area.
- Flagship owners can turn acquisition offers on/off and accept/reject offers.
- Other players can submit acquisition offers when enabled.
- Successful acquisitions pay target shareholders, boost the buyer flagship price/confidence, and allow the acquired nation to rebuild a new flagship after a host-configurable cooldown.


## Release-candidate changes

- Dedicated Air Wing operation missions and Special Forces operation missions are removed from the player UI in this release. Air Wings and Special Forces remain visible purchasable units.
- Hosts can configure conventional missile army, infrastructure, city/territory, and resource damage; EMP disable duration; and Low/Medium/High nuclear damage.
- Missile reports now list the target territory/city, troop losses, strategic-asset effects, Recruiter effects, resource-facility level changes, and city/territory damage.
- Headquarters action screens now explain what Intelligence, Security, Cyber Warfare, and Joint Command actions actually do before the player uses them.

## Final Release Candidate

This release candidate removes dedicated Air Wing and Special Forces operation mission menus, adds host-configurable Missile Silo damage/effect controls, expands missile reports with troop/city/resource/Recruiter/asset details, and explains Headquarters actions directly in the HQ interface.

## Final AI / Military Management Polish

- AI uses **War Economy** doctrine while at war: no new stock purchases or investment projects, and Commerce is redirected to military readiness, resources, repairs, Headquarters, Recruiters, logistics, SAMs and Missile Silos.
- Host controls the AI's idle Commerce ceiling. Defaults are **300 Commerce in peace** and **150 Commerce in war**. Commerce above the ceiling is actively put to work when useful purchases/upgrades are available.
- AI aims for roughly **2 Recruiting Stations in peace** and **3 in war** (subject to host limits). Before adding another Recruiter level it checks Oil, Food and Iron support and prioritizes the missing resource first.
- AI maintains at least **1 Airbase** when enabled and normally **2 in larger wartime nations**, while avoiding airport spam.
- AI can actively use valid **Airlift Cards** between Airbases/Forward Airstrips and can use a **Gift Card** conservatively to give an ally a low-value frontline foothold when that ally cannot reach its war enemy by land.
- AI Missile Silos now maintain ammunition and can queue strategic strikes against high-value enemy territories such as Headquarters, Recruiters, Power Grids, Silos, Airbases, SAMs and resource centers.
- Military assets upgrade **in place** from the Military screen. `SHOW` locates the asset; `UPGRADE` raises the existing asset level and the map icon tier updates instead of placing a duplicate icon. `MAX` appears at the host maximum.
- Headquarters remain limited to **one per nation**. The Headquarters row opens its four branch upgrade/action screen instead of placing a second HQ. If the HQ is destroyed/lost, it can be rebuilt after restoring operational power.
