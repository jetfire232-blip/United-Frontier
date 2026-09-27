# United Diplomacy

## Phase 2 - Military Foundation

This development branch builds on Global Affairs and establishes the persistent framework for modern strategic warfare.

### Added in Phase 2
- Military host configuration for Headquarters, Airbases, Forward Airstrips, SAM Sites, Missile Silos, Power Grid, Air Wings, and Special Forces.
- Four Headquarters branches: Intelligence, Security, Cyber Warfare, and Joint Command.
- Persistent national military summary state prepared for future construction, damage, repairs, and AI planning.
- Air Wing scale is host-configurable (default: 25 aircraft represented per Wing).
- Uranium strategy settings prepared: zero starting stockpile by default, rarity mode, and higher facility-cost multiplier.
- Hidden military infrastructure is explicitly designed to use private/player-specific data rather than PublicGameData when activated.
- Existing Recruiter system remains active under the Military tab.

### Important
Phase 2 is the framework build. New Airbase/SAM/Silo/HQ/Air Wing/Special Forces purchase actions are intentionally not live yet. This lets the configuration and persistent data model be tested before combat logic is layered on top.

# United Diplomacy

## Phase 1 Development Build

This build establishes the new navigation and military foundation while preserving the working Global Affairs systems.

### New navigation
- Overview
- Markets (includes Investments, AI Manager, Global Economy)
- Resources
- Military
- Diplomacy
- United Nations
- How It Works
- Customize Tabs

### Military foundation
- Headquarters with four branches: Intelligence, Security, Cyber Warfare, Joint Command
- Recruiting Stations moved under Military
- Planned: Airbases, Forward Airstrips, Air Wings, SAM Sites, Missile Silos, Power Grid, repairs, Special Forces

### Resource UI
- Color-coded national status
- Cleaner production/need/stockpile/net display
- Resource Market & Trade section
- One resource icon per territory; upgrades will replace the visual level rather than stack multiple icons

---


United Diplomacy builds on the Global Affairs V3 foundation and expands it into a modern strategic economy, diplomacy, intelligence, infrastructure, and warfare system.

## Core Systems

- Commerce economy with taxation, ideology, Trade Agreements, investments, and national growth.
- Flagship companies, stock trading, dividends, portfolios, stock splits, ETF trading, and AI investors.
- War Bonds that allow wartime financing with a defined term and target payout.
- Strategic Resources including Oil, Gas, Uranium, Iron, Food, Rare Earths, and optional Coal, Copper, and Lithium.
- Persistent national resource stockpiles: positive net production is stored, and later deficits consume stockpile reserves before uncovered shortages create penalties.
- Resource facilities with immediate Commerce payment, ownership transfer through territorial capture, and production tied to controlled territory.
- Military Readiness driven by strategic-resource availability.
- Army Recruiters that generate armies based on recruiter level and Military Readiness while adding resource maintenance demand.
- Diplomacy with wars, peace, Non-Aggression Pacts, alliances, factions, player search/overview, relationship history, and coalition Current Wars.
- Direct Join War controls that let a human nation choose which side of an active conflict to support, subject to diplomacy safety checks.
- War Events with player choices and automatic balanced resolution when a human does not respond in time.
- Optional United Nations / Security Council with permanent and rotating members, vetoes, AI voting, sanctions, embargoes, aid, condemnations, and ceasefires.
- AI Manager for player-authorized market and investment spending with a defined per-turn budget and visible spending breakdown.
- Smart AI for markets, investments, resources, diplomacy, war targeting, and other economic decisions.
- Mobile-focused UI, customizable tabs, player search, and an expanded How It Works guide.

## Markets and ETF

Eligible nations may establish flagship companies using Growth, Balanced, or Dividend strategies. Players and AI can buy and sell shares, receive dividends, track cost basis and profit/loss, and trade the global ETF.

The Market Overview includes gainers, downtrend stocks, company confidence, owner unrest, and trend information. The ETF rebalances every 5 turns and can provide visible holder distributions in addition to normal ETF dividends.

## Strategic Resources and Stockpiles

Territory ownership determines resource production. Capturing a resource territory transfers its future production to the new owner after the turn resolves.

Each nation also tracks resource requirements and a persistent national stockpile. Positive net production is added to that resource's stockpile each turn. When production falls below requirements, the stockpile is consumed first. Only the uncovered portion of a shortage applies shortage penalties.

Resource shortages can reduce Commerce, lower Military Readiness, and increase unrest. Existing armies are never deleted because of a shortage.

Each resource territory displays one dominant-resource map icon with a numeric badge for its combined facility/deposit level. The host may disable resource map icons while leaving the resource economy active.

## Army Recruiters

When enabled by the host, players may build and upgrade Army Recruiters on owned territories.

- Recruiters generate armies on their territory each turn.
- Output scales with Military Readiness.
- Recruiter levels add strategic-resource maintenance demand.
- Recruiters transfer with the territory when captured.
- Build and upgrade costs are deducted immediately when the action succeeds.
- Failed or unaffordable actions do not charge the player.

## Current Wars and Join War

Current Wars groups coalition conflicts into one conflict entry instead of displaying every bilateral relationship as a separate war. Each conflict keeps its original cause directly under the matchup and tracks start turn, duration, attacks, combat losses, territories captured, and direct wartime decision costs.

A human nation that is not already participating may choose a side through the Join War controls. Diplomacy safety checks prevent joining in a way that would place the player against an active ally or on the same side as a nation they are already fighting. Joining adds the nation to the existing coalition conflict rather than creating a duplicate conflict entry.

Normal independent AI war declarations require a shared land border. Alliance, faction, and join-war situations can create broader conflicts.

## United Nations / Security Council

The UN is optional and host-configurable. Permanent members may veto Security Council resolutions. Human council members vote YES / NO / ABSTAIN; AI council members vote automatically. Proposal cooldowns prevent resolution spam.

Supported actions include Economic Sanctions, Trade Embargo, Economic Aid, Condemn Nation, and Peace / Ceasefire.

## AI Manager

When allowed by the host, human players may enable an AI Manager with a defined per-turn budget. The manager handles authorized market and investment activity and reports budget, amount spent, unused amount, Commerce before/after spending, and a spending breakdown.

It does not take over diplomacy, tax policy, ideology, or military orders.

## Performance

Global Affairs V3 includes large-game performance safeguards such as cached economic data, shared AI threat calculations, cached territory lists, reduced repeated game-data writes, and automatic staggering of non-urgent AI work as player counts grow.

Critical maintenance, active agreements, resource processing, incoming diplomacy, UN effects, and required turn-state updates continue every turn.

## Release QA

Before publishing a release build, verify the following in a fresh multiplayer game:

- Commerce, taxation, ideology, Trade Agreements, and investments.
- Stocks, dividends, ETF, War Bonds, and market displays.
- Resource production, requirements, stockpile growth, stockpile depletion, facilities, and repeated territorial capture.
- Military Readiness and Army Recruiter production, maintenance, capture, and immediate payment behavior.
- Current Wars deduplication, war causes, Join War side selection, coalition membership, peace, and War Events.
- United Nations voting and resolution effects.
- AI Manager spending and Smart AI behavior.
- Mobile UI and How It Works guidance.
- 30–40 player regression testing and 100+ player Mega Game performance testing.

Gameplay features should be considered confirmed only after they have been tested in War.app.


## Release safeguards

- **Reviewer / spectator safety:** player-specific menus now handle cases where War.app opens the UI without a local `game.Us` player, showing a viewer-mode message instead of crashing.
- **Bounded history:** long-running games automatically trim older reporting/history records while preserving live gameplay state, reducing the chance of exceeding War.app's `PublicGameData` size limit.
