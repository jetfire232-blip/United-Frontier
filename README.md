# United Frontier

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

Headquarters, Airbases, Airstrips, SAMs, Silos, Power Grids, and Recruiters use structure-style map assets. Air Wings and Special Forces use custom special-unit icons.

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

Special Forces are visible custom special units intended for reconnaissance, raids, sabotage, infrastructure operations, and intelligence support rather than replacing normal armies.

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

Advanced strategic combat effects such as full Air Wing mission resolution, SAM interception, missile inventory/reload, EMP/nuclear area effects, cyber damage, and the complete Operational/Damaged/Disabled/Destroyed repair loop are represented in the architecture and How It Works design but should not be treated as fully verified gameplay until implemented and tested in War.app.

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


## Phase 6 - Operational Warfare Pass

- Headquarters now requires an operational Power Grid before construction and command-system use.
- HQ branches are capped at five meaningful levels and show current/next effects and Commerce cost.
- Missile Command adds Silo resupply, conventional/EMP/nuclear targeting, and turn-advance strike resolution.
- Airlift Card orders are restricted to Airbase / Forward Airstrip endpoints.
- Smart AI receives supplemental frontline attacks, rear-to-front transfers, Power Grid-before-HQ planning, HQ branch development, and stronger allied-war support.
- Human Trade Agreements are directly accessible from Markets.
