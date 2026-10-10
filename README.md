# United Frontier

United Frontier is a War.app / Warzone Lua strategy mod that adds national economics, strategic resources, markets, diplomacy, factions, the United Nations, military infrastructure, intelligence, missiles, and Smart AI.

## Current v4 design

The everyday UI is intentionally concise: costs, hard numbers, actions, and reports are shown directly; deeper rules are in **How It Works**.

### National systems
- Mandatory National Setup with numerical previews and auto-assignment for unfinished setup.
- Company Confidence affects flagship market performance.
- Unrest has visible Commerce and Recruiter penalties.
- Strategic Resources are private and discovered through ownership, borders, faction/alliance sharing, or intelligence.

### Military infrastructure
- Recruiters remain the core military system and continue working if optional military systems are disabled.
- Power Grid is a private prerequisite for Airbases, Missile Command, and the Intelligence Agency.
- Infrastructure durability scales with level: Lv.1 10 HP, Lv.2 20 HP, Lv.3 30 HP, Lv.4 40 HP.
- An upgrade strengthens the existing installation and preserves existing damage; it does not intentionally create another structure icon.
- Airbases consume Oil + Iron per build/upgrade (host configurable).
- Forward Airstrips consume Oil per build/upgrade (host configurable).
- If Airbases or Airstrips are enabled, Airlift Cards require airport infrastructure at both endpoints. If both are disabled, normal War.app Airlift rules apply. AI follows the same rule.

### Intelligence Agency
- One physical Intelligence Agency per nation; it can be rebuilt after destruction/capture.
- Intelligence Operations: 3 levels.
- Cyber Operations: 2 levels.
- Counterintelligence: 2 levels.
- Lv.3 Intelligence unlocks Financial Espionage and strategic missile warnings.
- Detected covert operations let human defenders Counter, Trace (Lv.2), or Ignore before the turn advances. AI defenders can use active countermeasures automatically.
- Successful intelligence can be shared with Faction members.

### Missile Command & Defense
- Missile Command development requires an operational Power Grid and Uranium for each build/upgrade.
- Conventional, EMP, Nuclear, and Interceptor stockpiles.
- Quantity controls allow multi-missile purchases and salvos.
- Every missile resolves independently against interception.
- Nuclear missiles consume Uranium and Low/Medium/High yield requires Missile Command Lv.1/Lv.2/Lv.3 respectively.

### Factions
- Public Faction directory with leaders/members.
- Invitations, join requests, member management, leader transfer, Faction chat.
- Faction Military Exercises with host-configurable contribution tiers and hard Recruiter-output previews.
- Faction leaders can declare war on another Faction; members receive notifications and member wars propagate.
- AI Faction creation/join decisions use ideology and diplomatic alignment instead of a random 50% roll.

### AI / automation
- Smart AI follows strategic-resource, airport/airlift, Uranium, infrastructure, and missile-defense rules.
- AI flagship acquisition availability is determined from economic/market conditions rather than being permanently fixed.
- Human AI Manager supports a recurring budget plus a one-time extra budget and has a simplified control screen.

See **How It Works** inside the mod for the player-facing guide and `V4_PATCH_NOTES.txt` for the latest patch summary.
