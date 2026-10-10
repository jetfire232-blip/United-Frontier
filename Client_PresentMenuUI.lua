ContentArea = nil;
local MAX_VISIBLE_HISTORY = 40;

-- Safe local-player helpers. War.app can open mod UI in reviewer/spectator
-- contexts where game.Us is nil; player-specific screens must not crash.
local function GetLocalPlayerID(game)
    if game ~= nil and game.Us ~= nil then
        return game.Us.ID;
    end
    return nil;
end

local function IsViewerMode(game)
    return GetLocalPlayerID(game) == nil;
end

local function ShowViewerModeNotice(area, text)
    UI.CreateLabel(area).SetText(
        text or "Viewer mode: this screen requires an active player."
    );
end

-- Spectators/reviewers can browse the mod UI, but War.app does not allow
-- them to send game custom messages. Route every player action through this
-- guard so a visible action can never crash spectator mode.
local function SafeSendGameCustomMessage(game, message, payload, callback)
    if IsViewerMode(game) then
        UI.Alert("Viewer mode: game actions are unavailable while spectating.");
        return;
    end
    game.SendGameCustomMessage(message, payload, callback);
end

-- War.app can collapse text fields to only a few pixels in some layouts.
-- Give every mod text input a sensible preferred width while still allowing
-- the layout engine to size it for smaller screens.
local function CreateWideTextInput(parent, width)
    return UI.CreateTextInputField(parent).SetPreferredWidth(width or 120);
end

InvestmentProjectTypes = {
    {
        id = "port",
        name = "Port Expansion",
        maxGoal = 1200,
        duration = 3,
        successReturn = 15,
        failureRecovery = 90,
        successChance = 90,
        risk = "Low"
    },
    {
        id = "commercial",
        name = "Commercial District",
        maxGoal = 1500,
        duration = 4,
        successReturn = 22,
        failureRecovery = 80,
        successChance = 82,
        risk = "Low-Medium"
    },
    {
        id = "infrastructure",
        name = "Infrastructure Corridor",
        maxGoal = 1800,
        duration = 5,
        successReturn = 28,
        failureRecovery = 80,
        successChance = 78,
        risk = "Medium"
    },
    {
        id = "industrial",
        name = "Industrial Development",
        maxGoal = 2000,
        duration = 5,
        successReturn = 35,
        failureRecovery = 70,
        successChance = 72,
        risk = "Medium"
    },
    {
        id = "resource",
        name = "Resource Development",
        maxGoal = 2400,
        duration = 4,
        successReturn = 45,
        failureRecovery = 55,
        successChance = 65,
        risk = "Medium-High"
    },
    {
        id = "technology",
        name = "Technology Venture",
        maxGoal = 3000,
        duration = 6,
        successReturn = 70,
        failureRecovery = 35,
        successChance = 55,
        risk = "High"
    },
    {
        id = "space",
        name = "Space Exploration",
        maxGoal = 4000,
        duration = 8,
        successReturn = 100,
        failureRecovery = 20,
        successChance = 45,
        risk = "Very High"
    },

    {
        id = "agriculture",
        name = "Agricultural Development",
        maxGoal = 1400,
        duration = 3,
        successReturn = 18,
        failureRecovery = 85,
        successChance = 86,
        risk = "Low"
    },

    {
        id = "energy",
        name = "Energy Development",
        maxGoal = 2200,
        duration = 4,
        successReturn = 38,
        failureRecovery = 65,
        successChance = 70,
        risk = "Medium"
    },

    {
        id = "defense",
        name = "Defense Industry Expansion",
        maxGoal = 2600,
        duration = 5,
        successReturn = 48,
        failureRecovery = 55,
        successChance = 64,
        risk = "Medium-High"
    },

    {
        id = "finance",
        name = "Financial Center",
        maxGoal = 2800,
        duration = 5,
        successReturn = 55,
        failureRecovery = 50,
        successChance = 60,
        risk = "High"
    },

    {
        id = "logistics",
        name = "Logistics & Supply Network",
        maxGoal = 1900,
        duration = 4,
        successReturn = 30,
        failureRecovery = 75,
        successChance = 76,
        risk = "Medium"
    }
};

function GetClientSetting(name, defaultValue)

    local settings =
        Mod.Settings or {};

    if settings[name] == nil then
        return defaultValue;
    end

    return settings[name];
end

function ClientMaxAgreements()

    return GetClientSetting(
        "MaxTradeAgreements",
        3
    );
end

function ClientTradeBonusPercent()

    return GetClientSetting(
        "TradeBonusPercent",
        10
    );
end

function ClientTradeCooldownTurns()

    return GetClientSetting(
        "TradeCooldownTurns",
        3
    );
end


PlayerTabVisibility = PlayerTabVisibility or {
    investments = true,
    markets = true,
    taxation = true,
    resources = true,
    unitedNations = true,
    globalEconomy = true,
    howItWorks = true
};

if PlayerTabVisibility.resources == nil then PlayerTabVisibility.resources = true; end
if PlayerTabVisibility.unitedNations == nil then PlayerTabVisibility.unitedNations = true; end
if PlayerTabVisibility.military == nil then PlayerTabVisibility.military = true; end

ActiveMainTab = ActiveMainTab or "overview";
MainTabsArea = nil;
UFMenuClose = UFMenuClose or nil;
ResourceIntelFilter = ResourceIntelFilter or "My Resources";
MilitaryIntelFilter = MilitaryIntelFilter or "My Infrastructure";
TradePartnerFilter = TradePartnerFilter or "ALL";


function MainTabText(key, label)

    if ActiveMainTab == key then
        return "▶ " .. label;
    end

    return label;
end

function GetPlayerUIColor(
    game,
    playerID,
    fallback
)

    local defaultColor =
        fallback
        or "#FFFFFF";

    if game == nil
        or game.Game == nil
        or game.Game.Players == nil
    then
        return defaultColor;
    end

    local player =
        game.Game.Players[
            playerID
        ];

    if player == nil
        or player.Color == nil
        or player.Color.HtmlColor == nil
    then
        return defaultColor;
    end

    local color =
        tostring(
            player.Color.HtmlColor
        );

    if color == "" then
        return defaultColor;
    end

    if string.sub(color, 1, 1) ~= "#" then
        color = "#" .. color;
    end

    return color;
end


function ShowComingSoonSection(
    parent,
    title,
    description
)

    local area =
        CreateContentArea(parent);

    UI.CreateLabel(area)
        .SetText(title);

    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );

    UI.CreateLabel(area)
        .SetText(description);

    UI.CreateLabel(area)
        .SetText(
            "\nThis section is now part of the new Global Economy interface. Its gameplay engine will be connected during the next build stages."
        );
end


function ShowWarDeclarationReasonMenu(parent, game, targetPlayerID)
    local area = CreateContentArea(parent);
    UI.CreateLabel(area).SetText("DECLARE WAR");
    UI.CreateLabel(area).SetText("Target: " .. tostring(GetPlayerName(game, targetPlayerID)));
    UI.CreateLabel(area).SetText("Select the official reason for war. The cause will be recorded in Current Wars and diplomatic history.");

    local reasons = {
        "Territorial Dispute",
        "Resource Security",
        "National Defense / Border Threat",
        "Support an Ally",
        "Economic Conflict",
        "Ideological Conflict"
    };

    for _, reason in ipairs(reasons) do
        local capturedReason = reason;
        UI.CreateButton(area).SetText(capturedReason).SetOnClick(function()
            SafeSendGameCustomMessage(game, 
                "Declaring war...",
                {type="declareWar", targetPlayerID=targetPlayerID, reason=capturedReason},
                function(result)
                    if result ~= nil and result.message ~= nil then UI.Alert(result.message); end
                    ShowDiplomacyMenu(parent, game);
                end
            );
        end);
    end

    UI.CreateButton(area).SetText("CANCEL").SetOnClick(function()
        ShowDiplomacyMenu(parent, game);
    end);
end

function ShowDiplomacyMenu(
    parent,
    game
)

    local area =
        CreateContentArea(
            parent
        );


    local data =
        Mod.PublicGameData
        or {};


    local economy =
        data.globalEconomy
        or {};


    local diplomacy =
        economy.diplomacy
        or {};

    local playerSearchInput =
    nil;

local playerSearchResults =
    nil;

local playerSearchResultsHost =
    nil;

    local selectedDiplomacyPlayerID =
    nil;

local selectedDiplomacyPlayerName =
    nil;

    local selectedDiplomacyPlayerLabel =
    nil;

    local selectedDiplomacyOverviewGroup =
    nil;

    local selectedDiplomacyOverviewHost =
    nil;

    local relationships =
        diplomacy.relationships
        or {};


    local pendingWarDeclarations =
        diplomacy.pendingWarDeclarations
        or {};


    local pendingPeaceOffers =
        diplomacy.pendingPeaceOffers
        or {};


    local pendingNAPOffers =
        diplomacy.pendingNAPOffers
        or {};
    
    local pendingAllianceOffers =
    diplomacy.pendingAllianceOffers
    or {};

    local alliances =
    diplomacy.alliances
    or {};

local pendingHeadquartersShareRequests =
    diplomacy.pendingHeadquartersShareRequests
    or {};

local factions =
    diplomacy.factions
    or {};

local pendingFactionInvites =
    diplomacy.pendingFactionInvites
    or {};

local playerFaction =
    diplomacy.playerFaction
    or {};

    local nonAggressionPacts =
        diplomacy.nonAggressionPacts
        or {};


    local history =
        diplomacy.history
        or {};


    local ourID =
        GetLocalPlayerID(game);

    if ourID == nil then
        ShowViewerModeNotice(
            area,
            "Viewer mode: diplomacy information is available, but create/join/propose actions are disabled while spectating."
        );
    end

    local economyRow = UI.CreateHorizontalLayoutGroup(area);
    UI.CreateButton(economyRow).SetText("TRADE AGREEMENTS").SetOnClick(function() ShowTradeAgreementsMenu(parent,game); end);

local ourFactionID =
    playerFaction[
        ourID
    ];

local ourFaction =
    nil;

if ourFactionID ~= nil then

    ourFaction =
        factions[
            ourFactionID
        ];

end


local function RefreshSelectedDiplomacyOverview()

    if selectedDiplomacyOverviewHost == nil then

        return;

    end

if selectedDiplomacyOverviewGroup ~= nil
    and not UI.IsDestroyed(
        selectedDiplomacyOverviewGroup
    )
then

    UI.Destroy(
        selectedDiplomacyOverviewGroup
    );

end

selectedDiplomacyOverviewGroup =
    UI.CreateVerticalLayoutGroup(
        selectedDiplomacyOverviewHost
    );

    if selectedDiplomacyPlayerID == nil then

        UI.CreateLabel(
            selectedDiplomacyOverviewGroup
        )
            .SetText(
                "Select a player to view their overview."
            );

        return;
    end


    local targetID =
        selectedDiplomacyPlayerID;

    local targetName =
        selectedDiplomacyPlayerName
        or GetPlayerName(
            game,
            targetID
        );


    local a =
        tostring(
            ourID
        );

    local b =
        tostring(
            targetID
        );

    local key;

    if a < b then

        key =
            a ..
            "|" ..
            b;

    else

        key =
            b ..
            "|" ..
            a;

    end


    local relationship =
        relationships[
            key
        ];

    local status =
        "peace";

    if relationship ~= nil
        and relationship.status ~= nil then

        status =
            relationship.status;

    end


    local activeNAP =
        nonAggressionPacts[
            key
        ];

    local activeAlliance =
        alliances[
            key
        ];

    local hasNAP =
        activeNAP ~= nil
        and activeNAP.active == true;

    local isAllied =
        activeAlliance ~= nil
        and activeAlliance.active == true;


    local targetNation =
        (
            economy.nations
            and economy.nations[
                targetID
            ]
        )
        or {};


    local targetColor =
        GetPlayerUIColor(
            game,
            targetID,
            "#FFFFFF"
        );

    local overviewTitle =
        UI.CreateLabel(
            selectedDiplomacyOverviewGroup
        )
            .SetText(
                "PLAYER OVERVIEW - " ..
                tostring(targetName)
            );

    overviewTitle.SetColor(
        targetColor
    );

    local function AddOverviewPair(
        leftText,
        rightText
    )

        local row =
            UI.CreateHorizontalLayoutGroup(
                selectedDiplomacyOverviewGroup
            );

        UI.CreateLabel(row)
            .SetText(leftText)
            .SetFlexibleWidth(1);

        UI.CreateLabel(row)
            .SetText(rightText)
            .SetFlexibleWidth(1);

    end

    AddOverviewPair(
        "Relationship: " ..
        string.upper(
            tostring(status)
        ),
        "Commerce/Turn: " ..
        tostring(
            GetPlayerIncome(
                game,
                targetID
            )
        )
    );

    AddOverviewPair(
        "Ideology: " ..
        tostring(
            targetNation.ideology
            or "Unknown"
        ),
        "Tax Policy: " ..
        tostring(
            targetNation.taxPolicy
            or "Unknown"
        )
    );

    AddOverviewPair(
        "Economic Strategy: " ..
        tostring(
            targetNation.economicStrategy
            or "Unknown"
        ),
        "Company Strategy: " ..
        tostring(
            targetNation.companyStrategy
            or "Unknown"
        )
    );

    AddOverviewPair(
        "NAP: " ..
        (
            hasNAP
            and "ACTIVE"
            or "NONE"
        ),
        "Alliance: " ..
        (
            isAllied
            and "ACTIVE"
            or "NONE"
        )
    );

    UI.CreateLabel(
        selectedDiplomacyOverviewGroup
    )
        .SetText(
            "Flagship Company: " ..
            tostring(
                targetNation.flagshipCompanyName
                or "None"
            )
        );

UI.CreateLabel(
    selectedDiplomacyOverviewGroup
)
    .SetText(
        "\nRECENT DIPLOMACY HISTORY"
    );

local matchingEvents =
    {};

for i =
    #history,
    1,
    -1 do

    local event =
        history[
            i
        ];

    if event ~= nil
        and (
            event.player1 == targetID
            or event.player2 == targetID
        )
    then

        table.insert(
            matchingEvents,
            event
        );

        if #matchingEvents >= 10 then
            break;
        end

    end

end

if #matchingEvents == 0 then

    UI.CreateLabel(
        selectedDiplomacyOverviewGroup
    )
        .SetText(
            "No diplomacy history with this player yet."
        );

else

    for _, event
        in ipairs(
            matchingEvents
        ) do

        UI.CreateLabel(
            selectedDiplomacyOverviewGroup
        )
            .SetText(
                "Turn " ..
                tostring(
                    event.turn
                    or "?"
                ) ..
                " - " ..
                tostring(
                    event.message
                    or event.type
                    or "Diplomacy event"
                )
            );

    end

end

end

local function RefreshPlayerSearchResults()

    if playerSearchResultsHost == nil
        or playerSearchInput == nil
    then
        return;
    end

    if playerSearchResults ~= nil
        and not UI.IsDestroyed(
            playerSearchResults
        )
    then

        UI.Destroy(
            playerSearchResults
        );

    end

    playerSearchResults =
        UI.CreateVerticalLayoutGroup(
            playerSearchResultsHost
        );

    local searchText =
        string.lower(
            playerSearchInput.GetText()
            or ""
        );

    local matches =
        {};

    for playerID, player
        in pairs(
            game.Game.Players
            or {}
        )
    do

        if playerID ~= ourID
            and player.State == WL.GamePlayerState.Playing
        then

            local playerName =
                player.DisplayName(
                    nil,
                    false
                );

            local lowerName =
                string.lower(
                    playerName
                    or ""
                );

            if searchText == ""
                or string.find(
                    lowerName,
                    searchText,
                    1,
                    true
                ) ~= nil
            then

                table.insert(
                    matches,
                    {
                        id = playerID,
                        name = playerName
                    }
                );

            end

        end

    end

    table.sort(
        matches,
        function(a, b)

            return string.lower(
                tostring(a.name)
            ) < string.lower(
                tostring(b.name)
            );

        end
    );

    if #matches == 0 then

        UI.CreateLabel(
            playerSearchResults
        )
            .SetText(
                "No players match your search."
            );

        return;
    end

    local row = nil;

    for index, entry
        in ipairs(matches)
    do

        if (index - 1) % 3 == 0 then

            row =
                UI.CreateHorizontalLayoutGroup(
                    playerSearchResults
                );

        end

        local targetID =
            entry.id;

        local targetName =
            entry.name;

        local playerButton =
            UI.CreateButton(row)
                .SetText(
                    tostring(targetName)
                )
                .SetFlexibleWidth(1)
                .SetPreferredHeight(36)
                .SetTextColor(
                    GetPlayerUIColor(
                        game,
                        targetID,
                        "#FFFFFF"
                    )
                );

        if selectedDiplomacyPlayerID == targetID then

            playerButton.SetColor(
                "#606060"
            );

        else

            playerButton.SetColor(
                "#BABABC"
            );

        end

        playerButton.SetOnClick(function()

            selectedDiplomacyPlayerID =
                targetID;

            selectedDiplomacyPlayerName =
                targetName;

            if selectedDiplomacyPlayerLabel ~= nil then

                selectedDiplomacyPlayerLabel.SetText(
                    "Selected Player: " ..
                    tostring(
                        selectedDiplomacyPlayerName
                    )
                );

                selectedDiplomacyPlayerLabel.SetColor(
                    GetPlayerUIColor(
                        game,
                        targetID,
                        "#FFFFFF"
                    )
                );

            end

            RefreshSelectedDiplomacyOverview();
            RefreshPlayerSearchResults();

        end);

    end

end

    UI.CreateLabel(area)
        .SetText(
            "DIPLOMACY"
        );

    UI.CreateLabel(area)
        .SetText(
            "Search or tap a player to open their overview."
        );

    playerSearchInput =
        CreateWideTextInput(
            area
        )
            .SetPlaceholderText(
                "Search players..."
            )
            .SetOnValueChanged(function()

                RefreshPlayerSearchResults();

            end);

    playerSearchResultsHost =
        UI.CreateVerticalLayoutGroup(
            area
        );

    playerSearchResults =
        UI.CreateVerticalLayoutGroup(
            playerSearchResultsHost
        );

    selectedDiplomacyPlayerLabel =
        UI.CreateLabel(area)
            .SetText(
                "Selected Player: None"
            );

    selectedDiplomacyOverviewHost =
        UI.CreateVerticalLayoutGroup(
            area
        );

    selectedDiplomacyOverviewGroup =
        UI.CreateVerticalLayoutGroup(
            selectedDiplomacyOverviewHost
        );

    RefreshPlayerSearchResults();
    RefreshSelectedDiplomacyOverview();

    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );

    -- =====================================================
    -- CURRENT WARS / WAR EVENT CENTER
    -- =====================================================

    UI.CreateLabel(area)
        .SetText("CURRENT WARS")
        .SetColor("#FFB347");

    -- Current Wars is conflict-first rather than pair-first.  A coalition war
    -- is rendered once with every participant, its original cause, aggregate
    -- statistics, and any Join War actions available to the viewing nation.
    local conflicts = diplomacy.warConflicts or {};
    local ourFactionIDForWars = (diplomacy.playerFaction or {})[ourID];
    local ourFactionForWars = ourFactionIDForWars and (diplomacy.factions or {})[ourFactionIDForWars] or nil;
    local warStats = diplomacy.warStats or {};
    local currentTurn = data.tradeTurn or economy.currentEconomyTurn or 0;
    local activeWarCount = 0;
    local renderedRelationshipKeys = {};

    local function CurrentWarsPairKey(player1, player2)
        local a = tostring(player1);
        local b = tostring(player2);
        if a < b then
            return a .. "|" .. b;
        end
        return b .. "|" .. a;
    end

    local function SortedWarParticipantIDs(side)
        local ids = {};
        for participantID, participating in pairs(side or {}) do
            if participating == true then
                table.insert(ids, participantID);
            end
        end
        table.sort(ids, function(a, b)
            return tostring(GetPlayerName(game, a)) < tostring(GetPlayerName(game, b));
        end);
        return ids;
    end

    local function WarParticipantNames(ids)
        local names = {};
        for _, participantID in ipairs(ids or {}) do
            table.insert(names, GetPlayerName(game, participantID));
        end
        return table.concat(names, ", ");
    end

    local function IsOurActiveAlly(participantID)
        local alliance = (alliances or {})[CurrentWarsPairKey(ourID, participantID)];
        return alliance ~= nil and alliance.active == true;
    end

    local function IsOurFactionMate(participantID)
        if ourFactionForWars == nil then return false; end
        return (ourFactionForWars.members or {})[participantID] == true;
    end

    local function HasWarAgainstSide(side)
        for participantID, participating in pairs(side or {}) do
            if participating == true then
                local rel = relationships[CurrentWarsPairKey(ourID, participantID)];
                if rel ~= nil and rel.status == "war" then
                    return true;
                end
            end
        end
        return false;
    end

    local function HasAllianceWithSide(side)
        for participantID, participating in pairs(side or {}) do
            if participating == true and IsOurActiveAlly(participantID) then
                return true;
            end
        end
        return false;
    end

    local function CanJoinWarSide(side, opposingSide)
        if (side or {})[ourID] == true or (opposingSide or {})[ourID] == true then
            return false;
        end
        if HasWarAgainstSide(side) or HasAllianceWithSide(opposingSide) then
            return false;
        end
        for participantID, participating in pairs(side or {}) do
            if participating == true
                and participantID ~= ourID
                and (IsOurFactionMate(participantID) or IsOurActiveAlly(participantID))
            then
                return true;
            end
        end
        return false;
    end

    local function AddAmount(target, playerID, amount)
        local key = tostring(playerID);
        target[key] = (target[key] or 0) + math.max(0, math.floor(tonumber(amount) or 0));
    end

    local function ParticipantTotalsText(ids, totals, unit)
        local parts = {};
        local suffix = unit and (" " .. tostring(unit)) or "";
        for _, participantID in ipairs(ids or {}) do
            table.insert(
                parts,
                GetPlayerName(game, participantID) .. " " .. tostring(totals[tostring(participantID)] or 0) .. suffix
            );
        end
        return table.concat(parts, " | ");
    end

    local conflictIDs = {};
    for conflictID, conflict in pairs(conflicts) do
        if conflict ~= nil and conflict.active ~= false then
            table.insert(conflictIDs, conflictID);
        end
    end
    table.sort(conflictIDs, function(a, b)
        return (tonumber(a) or 0) < (tonumber(b) or 0);
    end);

    for _, conflictID in ipairs(conflictIDs) do
        local conflict = conflicts[conflictID];
        local sideA = conflict.sideA or {};
        local sideB = conflict.sideB or {};
        local sideAIDs = SortedWarParticipantIDs(sideA);
        local sideBIDs = SortedWarParticipantIDs(sideB);

        if #sideAIDs > 0 and #sideBIDs > 0 then
            local hasActivePair = false;
            for _, playerA in ipairs(sideAIDs) do
                for _, playerB in ipairs(sideBIDs) do
                    local relationship = relationships[CurrentWarsPairKey(playerA, playerB)];
                    if relationship ~= nil and relationship.status == "war" then
                        hasActivePair = true;
                        break;
                    end
                end
                if hasActivePair then break; end
            end

            if hasActivePair then
                activeWarCount = activeWarCount + 1;

            local totalAttacks = 0;
            local totalCasualties = {};
            local totalCaptures = {};
            local totalEconomicImpact = {};
            local earliestStartTurn = conflict.startTurn or currentTurn;

            for _, playerA in ipairs(sideAIDs) do
                for _, playerB in ipairs(sideBIDs) do
                    local relationshipKey = CurrentWarsPairKey(playerA, playerB);
                    local relationship = relationships[relationshipKey];
                    if relationship ~= nil and relationship.status == "war" then
                        renderedRelationshipKeys[relationshipKey] = true;
                        local stats = warStats[relationshipKey] or {};
                        totalAttacks = totalAttacks + math.max(0, math.floor(tonumber(stats.attacks) or 0));
                        earliestStartTurn = math.min(
                            earliestStartTurn,
                            tonumber(stats.startTurn or relationship.sinceTurn or earliestStartTurn) or earliestStartTurn
                        );
                        for participantKey, amount in pairs(stats.casualties or {}) do
                            AddAmount(totalCasualties, participantKey, amount);
                        end
                        for participantKey, amount in pairs(stats.territoriesCaptured or {}) do
                            AddAmount(totalCaptures, participantKey, amount);
                        end
                        for participantKey, amount in pairs(stats.economicImpact or {}) do
                            AddAmount(totalEconomicImpact, participantKey, amount);
                        end
                    end
                end
            end

            local duration = math.max(1, currentTurn - earliestStartTurn + 1);
            local allParticipantIDs = {};
            for _, participantID in ipairs(sideAIDs) do table.insert(allParticipantIDs, participantID); end
            for _, participantID in ipairs(sideBIDs) do table.insert(allParticipantIDs, participantID); end

            local warNameRow = UI.CreateHorizontalLayoutGroup(area);
            local function AddColoredWarNames(row, ids)
                for index, participantID in ipairs(ids or {}) do
                    if index > 1 then UI.CreateLabel(row).SetText(", ").SetColor("#B8B8B8"); end
                    UI.CreateLabel(row)
                        .SetText(GetPlayerName(game, participantID))
                        .SetColor(GetPlayerUIColor(game, participantID, "#FFFFFF"));
                end
            end
            AddColoredWarNames(warNameRow, sideAIDs);
            UI.CreateLabel(warNameRow).SetText("  VS  ").SetColor("#FFFFFF");
            AddColoredWarNames(warNameRow, sideBIDs);

            -- Keep the cause directly underneath the fight it belongs to.
            UI.CreateLabel(area)
                .SetText("Cause: " .. tostring(conflict.cause or "Territorial Dispute") .. " | Conflict #" .. tostring(conflictID))
                .SetColor("#D4AF37");

            UI.CreateLabel(area)
                .SetText("Started Turn " .. tostring(earliestStartTurn) .. " | Duration: " .. tostring(duration) .. " turn(s)" .. " | Attacks: " .. tostring(totalAttacks))
                .SetColor("#9BC7FF");

            UI.CreateLabel(area)
                .SetText("Combat losses: " .. ParticipantTotalsText(allParticipantIDs, totalCasualties))
                .SetColor("#FF8A8A");

            UI.CreateLabel(area)
                .SetText("Territories captured: " .. ParticipantTotalsText(allParticipantIDs, totalCaptures))
                .SetColor("#7EDC8B");

            UI.CreateLabel(area)
                .SetText("Direct wartime decision cost: " .. ParticipantTotalsText(allParticipantIDs, totalEconomicImpact, "gold"))
                .SetColor("#FFD166");

            local joinConflictID = conflictID;
            local alreadyInConflict = sideA[ourID] == true or sideB[ourID] == true;
            if not alreadyInConflict then
                UI.CreateLabel(area)
                    .SetText("JOIN WAR: Choose the side your nation will support.");

                UI.CreateButton(area)
                    .SetText("JOIN " .. WarParticipantNames(sideAIDs))
                    .SetOnClick(function()
                        SafeSendGameCustomMessage(game, 
                            "Joining war...",
                            {type="joinWar", conflictID=joinConflictID, side="A"},
                            function(result)
                                if result and result.message then UI.Alert(result.message); end
                                ShowDiplomacyMenu(parent, game);
                            end
                        );
                    end);

                UI.CreateButton(area)
                    .SetText("JOIN " .. WarParticipantNames(sideBIDs))
                    .SetOnClick(function()
                        SafeSendGameCustomMessage(game, 
                            "Joining war...",
                            {type="joinWar", conflictID=joinConflictID, side="B"},
                            function(result)
                                if result and result.message then UI.Alert(result.message); end
                                ShowDiplomacyMenu(parent, game);
                            end
                        );
                    end);
            end

            UI.CreateLabel(area)
                .SetText(
                    "----------------------------------------"
                );
            end
        end
    end

    -- Backward-compatibility fallback: older saves or wars created before
    -- coalition tracking may only have pairwise relationship data.  Render
    -- those once, but skip pairs already represented by a conflict card.
    for relationshipKey, relationship in pairs(relationships) do
        if relationship ~= nil
            and relationship.status == "war"
            and relationship.player1 ~= nil
            and relationship.player2 ~= nil
            and renderedRelationshipKeys[tostring(relationshipKey)] ~= true
        then
            activeWarCount = activeWarCount + 1;

            local player1 = relationship.player1;
            local player2 = relationship.player2;
            local key = tostring(relationshipKey);
            local stats = warStats[key] or {};
            local startTurn = stats.startTurn or relationship.sinceTurn or currentTurn;
            local duration = math.max(1, currentTurn - startTurn + 1);
            local casualties = stats.casualties or {};
            local captures = stats.territoriesCaptured or {};
            local economicImpact = stats.economicImpact or {};

            local row = UI.CreateHorizontalLayoutGroup(area);
            UI.CreateLabel(row)
                .SetText(GetPlayerName(game, player1))
                .SetColor(GetPlayerUIColor(game, player1, "#FFFFFF"))
                .SetFlexibleWidth(1);
            UI.CreateLabel(row).SetText("vs");
            UI.CreateLabel(row)
                .SetText(GetPlayerName(game, player2))
                .SetColor(GetPlayerUIColor(game, player2, "#FFFFFF"))
                .SetFlexibleWidth(1);

            UI.CreateLabel(area)
                .SetText(
                    "Cause: " .. tostring(stats.reason or relationship.warReason or "Territorial Dispute")
                );

            UI.CreateLabel(area)
                .SetText(
                    "Started Turn " .. tostring(startTurn)
                    .. " | Duration: " .. tostring(duration) .. " turn(s)"
                    .. " | Attacks: " .. tostring(stats.attacks or 0)
                );

            UI.CreateLabel(area)
                .SetText(
                    "Combat losses: "
                    .. GetPlayerName(game, player1) .. " " .. tostring(casualties[tostring(player1)] or 0)
                    .. " | "
                    .. GetPlayerName(game, player2) .. " " .. tostring(casualties[tostring(player2)] or 0)
                );

            UI.CreateLabel(area)
                .SetText(
                    "Territories captured: "
                    .. GetPlayerName(game, player1) .. " " .. tostring(captures[tostring(player1)] or 0)
                    .. " | "
                    .. GetPlayerName(game, player2) .. " " .. tostring(captures[tostring(player2)] or 0)
                );

            UI.CreateLabel(area)
                .SetText(
                    "Direct wartime decision cost: "
                    .. GetPlayerName(game, player1) .. " " .. tostring(economicImpact[tostring(player1)] or 0) .. " gold"
                    .. " | "
                    .. GetPlayerName(game, player2) .. " " .. tostring(economicImpact[tostring(player2)] or 0) .. " gold"
                );

            UI.CreateLabel(area)
                .SetText(
                    "----------------------------------------"
                );
        end
    end

    if activeWarCount == 0 then
        UI.CreateLabel(area)
            .SetText(
                "No active wars."
            );
    end

    local ourNation =
        (economy.nations or {})[
            ourID
        ]
        or {};

    local pendingWarEvent =
        ourNation.pendingWarEvent;

    if pendingWarEvent ~= nil then

        UI.CreateLabel(area)
            .SetText(
                "WAR EVENT - DECISION REQUIRED"
            );

        local otherName =
            pendingWarEvent.otherPlayerID ~= nil
            and GetPlayerName(
                game,
                pendingWarEvent.otherPlayerID
            )
            or "Unknown Nation";

        UI.CreateLabel(area)
            .SetText(
                tostring(pendingWarEvent.title or "Wartime Strategy Decision")
                .. "\nWar opponent: " .. tostring(otherName)
                .. "\nChoose one response. The selected consequence is applied on the next economy turn."
            );

        local ourCommerce =
            math.max(
                1,
                GetPlayerIncome(
                    game,
                    ourID
                )
            );

        local fullCost =
            math.max(
                25,
                math.floor(
                    ourCommerce * 0.08 + 0.5
                )
            );

        local rationCost =
            math.max(
                10,
                math.floor(
                    ourCommerce * 0.03 + 0.5
                )
            );

        UI.CreateLabel(area)
            .SetText(
                "FULL MOBILIZATION\n-"
                .. tostring(fullCost)
                .. " gold next turn | +10 Military Readiness for 2 turns | +2 Unrest"
            );

        UI.CreateButton(area)
            .SetText(
                "CHOOSE FULL MOBILIZATION"
            )
            .SetOnClick(function()
                SafeSendGameCustomMessage(game, 
                    "Resolving war event...",
                    {
                        type = "resolveWarEvent",
                        eventID = pendingWarEvent.id,
                        choice = "FULL_MOBILIZATION"
                    },
                    function(result)
                        if result ~= nil and result.message ~= nil then
                            UI.Alert(result.message);
                        end
                        ShowDiplomacyMenu(parent, game);
                    end
                );
            end);

        UI.CreateLabel(area)
            .SetText(
                "RATION SUPPLIES\n-"
                .. tostring(rationCost)
                .. " gold next turn | +5 Military Readiness for 2 turns | +5 Unrest"
            );

        UI.CreateButton(area)
            .SetText(
                "CHOOSE RATION SUPPLIES"
            )
            .SetOnClick(function()
                SafeSendGameCustomMessage(game, 
                    "Resolving war event...",
                    {
                        type = "resolveWarEvent",
                        eventID = pendingWarEvent.id,
                        choice = "RATION_SUPPLIES"
                    },
                    function(result)
                        if result ~= nil and result.message ~= nil then
                            UI.Alert(result.message);
                        end
                        ShowDiplomacyMenu(parent, game);
                    end
                );
            end);

        UI.CreateLabel(area)
            .SetText(
                "PROTECT ECONOMY\nNo direct gold cost | -8 Military Readiness for 2 turns | -2 Unrest"
            );

        UI.CreateButton(area)
            .SetText(
                "CHOOSE PROTECT ECONOMY"
            )
            .SetOnClick(function()
                SafeSendGameCustomMessage(game, 
                    "Resolving war event...",
                    {
                        type = "resolveWarEvent",
                        eventID = pendingWarEvent.id,
                        choice = "PROTECT_ECONOMY"
                    },
                    function(result)
                        if result ~= nil and result.message ~= nil then
                            UI.Alert(result.message);
                        end
                        ShowDiplomacyMenu(parent, game);
                    end
                );
            end);

    else

        UI.CreateLabel(area)
            .SetText(
                "War Events: No decision currently pending."
            );

    end

    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );


    UI.CreateLabel(area)
        .SetText(
            "Official Peace / War relationships control when nations may attack each other."
        );


    -- =====================================================
    -- RELATIONS
    -- =====================================================

    UI.CreateLabel(area)
        .SetText(
            "\nRELATIONS"
        );


    local foundRelation =
        false;


    for playerID, player
        in pairs(
            game.Game.Players
        ) do


        if playerID
            ~= ourID
            and player.State
            == WL.GamePlayerState.Playing then


            foundRelation =
                true;


local otherName =
    GetPlayerName(
        game,
        playerID
    );

local targetID =
    playerID;

local a =
    tostring(
        ourID
    ); 

            local a =
                tostring(
                    ourID
                );


            local b =
                tostring(
                    playerID
                );


            local key;


            if a < b then

                key =
                    a ..
                    "|" ..
                    b;

            else

                key =
                    b ..
                    "|" ..
                    a;

            end


            local relationship =
                relationships[
                    key
                ];


            local status =
                "peace";


            if relationship ~= nil
                and relationship.status
                ~= nil then


                status =
                    relationship.status;
            end


            local activeNAP =
                nonAggressionPacts[
                    key
                ];
            
            local activeAlliance =
    alliances[
        key
    ];

            local isAllied =
    activeAlliance ~= nil
    and activeAlliance.active == true;

            local row =
                UI.CreateVerticalLayoutGroup(
                    area
                );


            local statusText =
                otherName ..
                " | " ..
                string.upper(
                    status
                );
if isAllied then

    statusText =
        statusText ..
        " | ALLIED";

end

            if activeNAP ~= nil
                and activeNAP.active
                == true then


                local currentTurn =
                    economy.currentEconomyTurn
                    or data.tradeTurn
                    or 1;


                if currentTurn
                    < (
                        activeNAP.endTurn
                        or currentTurn
                    ) then


                    statusText =
                        statusText ..
                        " | NAP until Turn " ..
                        tostring(
                            activeNAP.endTurn
                        );
                end
            end


            local pendingWar =
                pendingWarDeclarations[
                    key
                ];


            if pendingWar ~= nil then


                statusText =
                    statusText ..
                    " | WAR DECLARED - activates Turn " ..
                    tostring(
                        pendingWar.activatesTurn
                        or "?"
                    );
            end


            local relationLabel =
                UI.CreateLabel(row)
                    .SetText(
                        statusText
                    );

            relationLabel.SetColor(
                GetPlayerUIColor(
                    game,
                    playerID,
                    "#FFFFFF"
                )
            );


            -- =================================================
            -- PEACE ACTIONS
            -- =================================================

            if status
                ~= "war" then


if pendingWar == nil
    and activeNAP == nil
    and not isAllied then


                    UI.CreateButton(row)
                        .SetText(
                            "DECLARE WAR"
                        )
                        .SetOnClick(function()
                            ShowWarDeclarationReasonMenu(
                                parent,
                                game,
                                playerID
                            );
                        end);
                end


if activeNAP == nil
    and pendingWar == nil
    and not isAllied then


                    UI.CreateButton(row)
                        .SetText(
                            "PROPOSE 3-TURN NAP"
                        )
                        .SetOnClick(function()


                            SafeSendGameCustomMessage(game, 
                                "Sending Non-Aggression Pact proposal...",
                                {

                                    type =
                                        "sendNAPOffer",

                                    targetPlayerID =
                                        playerID,

                                    duration =
                                        3
                                },

                                function(
                                    result
                                )

                                    ShowDiplomacyMenu(
                                        parent,
                                        game
                                    );

                                end
                            );
                        end);
UI.CreateButton(row)
    .SetText(
        "PROPOSE ALLIANCE"
    )
    .SetOnClick(function()

        SafeSendGameCustomMessage(game, 
            "Sending Alliance proposal...",
            {

                type =
                    "proposeAlliance",

                targetPlayerID =
                    playerID

            },

            function(
                result
            )

                ShowDiplomacyMenu(
                    parent,
                    game
                );

            end
        );

    end);
                        
                end

if isAllied then

    local alliedPlayerID =
        playerID;

    local intelShared = activeAlliance.sharedIntelligence == true;
    local warningShared = activeAlliance.jointStrategicWarning == true;
    UI.CreateLabel(row)
        .SetText("Alliance Intel | Shared Intelligence: " .. (intelShared and "ON" or "OFF") .. " | Strategic Warning: " .. (warningShared and "ON" or "OFF"))
        .SetColor("#9CCBFF");

    if not intelShared then
        UI.CreateButton(row).SetText("REQUEST SHARED INTELLIGENCE").SetOnClick(function()
            SafeSendGameCustomMessage(game, "Sending alliance intelligence-sharing request...", {
                type="requestHeadquartersSharing", targetPlayerID=alliedPlayerID, shareType="SharedIntelligence"
            }, function(result)
                if result and result.message then UI.Alert(result.message); end
                ShowDiplomacyMenu(parent, game);
            end);
        end);
    end

    if not warningShared then
        UI.CreateButton(row).SetText("REQUEST JOINT STRATEGIC WARNING").SetOnClick(function()
            SafeSendGameCustomMessage(game, "Sending alliance intelligence-sharing request...", {
                type="requestHeadquartersSharing", targetPlayerID=alliedPlayerID, shareType="JointStrategicWarning"
            }, function(result)
                if result and result.message then UI.Alert(result.message); end
                ShowDiplomacyMenu(parent, game);
            end);
        end);
    end

    UI.CreateButton(row)
        .SetText(
            "END ALLIANCE"
        )
        .SetOnClick(function()

            SafeSendGameCustomMessage(game, 
                "Ending Alliance...",
                {

                    type =
                        "endAlliance",

                    otherPlayerID =
                        alliedPlayerID
                },

                function(result)

                    if result ~= nil
                        and result.message ~= nil then

                        UI.Alert(
                            result.message
                        );

                    end


                    ShowDiplomacyMenu(
                        parent,
                        game
                    );

                end
            );

        end);

end

if ourFaction ~= nil
    and ourFaction.leaderPlayerID == ourID
    and playerFaction[
        targetID
    ] == nil
    and status ~= "war" then


    UI.CreateButton(row)
        .SetText(
            "INVITE TO FACTION"
        )
        .SetOnClick(function()

            SafeSendGameCustomMessage(game, 
                "Sending Faction invitation...",
                {

                    type =
                        "inviteToFaction",

                    targetPlayerID =
                        targetID

                },

                function(result)

                    if result ~= nil
                        and result.message ~= nil then

                        UI.Alert(
                            result.message
                        );

                    end


                    ShowDiplomacyMenu(
                        parent,
                        game
                    );

                end
            );

        end);

end

            -- =================================================
            -- WAR ACTIONS
            -- =================================================

            else


                UI.CreateButton(row)
                    .SetText(
                        "OFFER PEACE"
                    )
                    .SetOnClick(function()


                        SafeSendGameCustomMessage(game, 
                            "Sending peace offer...",
                            {

                                type =
                                    "sendPeaceOffer",

                                targetPlayerID =
                                    playerID
                            },

                            function(
                                result
                            )

                                ShowDiplomacyMenu(
                                    parent,
                                    game
                                );

                            end
                        );

                    end);
            end


            UI.CreateLabel(area)
                .SetText(
                    " "
                );

        end

    end


    if not foundRelation then


        UI.CreateLabel(area)
            .SetText(
                "No other active nations found."
            );
    end


    -- =====================================================
    -- INCOMING PEACE OFFERS
    -- =====================================================

    UI.CreateLabel(area)
        .SetText(
            "\nPEACE OFFERS"
        );


    local foundPeaceOffer =
        false;


    for _, offer
        in ipairs(
            pendingPeaceOffers
        ) do


        if offer.toPlayerID
            == ourID then


            foundPeaceOffer =
                true;


            local fromPlayer =
                game.Game.Players[
                    offer.fromPlayerID
                ];


local fromName =
    GetPlayerName(
        game,
        offer.fromPlayerID
    );


            local group =
                UI.CreateVerticalLayoutGroup(
                    area
                );


            UI.CreateLabel(group)
                .SetText(
                    fromName ..
                    " is offering peace."
                );


            local buttons =
                UI.CreateHorizontalLayoutGroup(
                    group
                );


            local fromID =
                offer.fromPlayerID;


            UI.CreateButton(buttons)
                .SetText(
                    "ACCEPT"
                )
                .SetOnClick(function()


                    SafeSendGameCustomMessage(game, 
                        "Accepting peace offer...",
                        {

                            type =
                                "acceptPeaceOffer",

                            fromPlayerID =
                                fromID
                        },

                        function(
                            result
                        )

                            ShowDiplomacyMenu(
                                parent,
                                game
                            );

                        end
                    );

                end);


            UI.CreateButton(buttons)
                .SetText(
                    "REJECT"
                )
                .SetOnClick(function()


                    SafeSendGameCustomMessage(game, 
                        "Rejecting peace offer...",
                        {

                            type =
                                "rejectPeaceOffer",

                            fromPlayerID =
                                fromID
                        },

                        function(
                            result
                        )

                            ShowDiplomacyMenu(
                                parent,
                                game
                            );

                        end
                    );

                end);

        end

    end


    if not foundPeaceOffer then


        UI.CreateLabel(area)
            .SetText(
                "No incoming peace offers."
            );
    end


    -- =====================================================
    -- INCOMING NAP OFFERS
    -- =====================================================

    UI.CreateLabel(area)
        .SetText(
            "\nNON-AGGRESSION PACT OFFERS"
        );


    local foundNAPOffer =
        false;


    for _, offer
        in ipairs(
            pendingNAPOffers
        ) do


        if offer.toPlayerID
            == ourID then


            foundNAPOffer =
                true;


            local fromPlayer =
                game.Game.Players[
                    offer.fromPlayerID
                ];




local fromName =
    GetPlayerName(
        game,
        offer.fromPlayerID
    );

local group =
    UI.CreateVerticalLayoutGroup(
        area
    );

UI.CreateLabel(group)
                .SetText(
                    fromName ..
                    " proposed a " ..
                    tostring(
                        offer.duration
                        or 3
                    ) ..
                    "-turn Non-Aggression Pact."
                );


            local buttons =
                UI.CreateHorizontalLayoutGroup(
                    group
                );


            local fromID =
                offer.fromPlayerID;


            UI.CreateButton(buttons)
                .SetText(
                    "ACCEPT"
                )
                .SetOnClick(function()


                    SafeSendGameCustomMessage(game, 
                        "Accepting Non-Aggression Pact...",
                        {

                            type =
                                "acceptNAPOffer",

                            fromPlayerID =
                                fromID
                        },

                        function(
                            result
                        )

                            ShowDiplomacyMenu(
                                parent,
                                game
                            );

                        end
                    );

                end);


            UI.CreateButton(buttons)
                .SetText(
                    "REJECT"
                )
                .SetOnClick(function()


                    SafeSendGameCustomMessage(game, 
                        "Rejecting Non-Aggression Pact...",
                        {

                            type =
                                "rejectNAPOffer",

                            fromPlayerID =
                                fromID
                        },

                        function(
                            result
                        )

                            ShowDiplomacyMenu(
                                parent,
                                game
                            );

                        end
                    );

                end);

        end

    end


    if not foundNAPOffer then


        UI.CreateLabel(area)
            .SetText(
                "No incoming Non-Aggression Pact offers."
            );
    end

-- =====================================================
-- INCOMING ALLIANCE OFFERS
-- =====================================================

UI.CreateLabel(area)
    .SetText(
        "\nALLIANCE OFFERS"
    );


local foundAllianceOffer =
    false;


for _, offer
    in ipairs(
        pendingAllianceOffers
    ) do


    if offer.toPlayerID
        == ourID then


        foundAllianceOffer =
            true;


        local fromName =
            GetPlayerName(
                game,
                offer.fromPlayerID
            );


        local group =
            UI.CreateVerticalLayoutGroup(
                area
            );


        UI.CreateLabel(group)
            .SetText(
                fromName ..
                " proposed an Alliance."
            );


        local buttons =
            UI.CreateHorizontalLayoutGroup(
                group
            );


        local fromID =
            offer.fromPlayerID;


        UI.CreateButton(buttons)
            .SetText(
                "ACCEPT"
            )
            .SetOnClick(function()


                SafeSendGameCustomMessage(game, 
                    "Accepting Alliance proposal...",
                    {

                        type =
                            "acceptAllianceOffer",

                        fromPlayerID =
                            fromID
                    },

                    function(result)

                        if result ~= nil
                            and result.message ~= nil then

                            UI.Alert(
                                result.message
                            );

                        end


                        ShowDiplomacyMenu(
                            parent,
                            game
                        );

                    end
                );

            end);


        UI.CreateButton(buttons)
            .SetText(
                "REJECT"
            )
            .SetOnClick(function()


                SafeSendGameCustomMessage(game, 
                    "Rejecting Alliance proposal...",
                    {

                        type =
                            "rejectAllianceOffer",

                        fromPlayerID =
                            fromID
                    },

                    function(result)

                        if result ~= nil
                            and result.message ~= nil then

                            UI.Alert(
                                result.message
                            );

                        end


                        ShowDiplomacyMenu(
                            parent,
                            game
                        );

                    end
                );

            end);

    end

end


if not foundAllianceOffer then

    UI.CreateLabel(area)
        .SetText(
            "No incoming Alliance offers."
        );

end

-- =====================================================
-- FACTIONS
-- =====================================================

UI.CreateLabel(area)
    .SetText(
        "\nFACTIONS"
    );


UI.CreateLabel(area).SetText("Factions share discovered strategic intelligence automatically; Faction and alliance intelligence sharing is managed here.").SetColor("#9CCBFF");

if ourFaction == nil then

    UI.CreateLabel(area)
        .SetText(
            "Your nation does not currently belong to a Faction."
        );


    local factionNameInput =
        CreateWideTextInput(
            area
        )
            .SetPlaceholderText(
                "Enter Faction name..."
            );


    UI.CreateButton(area)
        .SetText(
            "CREATE FACTION"
        )
        .SetInteractable(not IsViewerMode(game))
        .SetOnClick(function()

            local factionName =
                factionNameInput.GetText();


            SafeSendGameCustomMessage(game, 
                "Creating Faction...",
                {

                    type =
                        "createFaction",

                    factionName =
                        factionName

                },

                function(result)

                    if result ~= nil
                        and result.message ~= nil then

                        UI.Alert(
                            result.message
                        );

                    end


                    ShowDiplomacyMenu(
                        parent,
                        game
                    );

                end
            );

        end);


else

    UI.CreateLabel(area)
        .SetText(
            "Faction: " ..
            tostring(
                ourFaction.name
                or "Unnamed Faction"
            )
        );


    local leaderName =
        GetPlayerName(
            game,
            ourFaction.leaderPlayerID
        );


    UI.CreateLabel(area)
        .SetText(
            "Leader: " ..
            leaderName
        );


    UI.CreateLabel(area)
        .SetText(
            "Members:"
        );


    for memberID, isMember in pairs(
        ourFaction.members
        or {}
    ) do

        if isMember == true then

            local memberName =
                GetPlayerName(
                    game,
                    memberID
                );


            local memberGroup =
                UI.CreateHorizontalLayoutGroup(
                    area
                );


            local memberText =
                memberName;


            if memberID
                == ourFaction.leaderPlayerID then

                memberText =
                    memberText ..
                    " | LEADER";

            end


            UI.CreateLabel(memberGroup)
                .SetText(
                    memberText
                );


            if ourFaction.leaderPlayerID
                == ourID
                and memberID
                ~= ourID then

                local removableID =
                    memberID;


                UI.CreateButton(memberGroup).SetText("PROMOTE TO LEADER").SetOnClick(function()
                    SafeSendGameCustomMessage(game,"Transferring Faction leadership...",{type="promoteFactionLeader",targetPlayerID=removableID},function(result) if result and result.message then UI.Alert(result.message); end; ShowDiplomacyMenu(parent,game); end);
                end);

                UI.CreateButton(memberGroup)
                    .SetText(
                        "REMOVE"
                    )
                    .SetOnClick(function()

                        SafeSendGameCustomMessage(game, 
                            "Removing Faction member...",
                            {

                                type =
                                    "removeFactionMember",

                                targetPlayerID =
                                    removableID

                            },

                            function(result)

                                if result ~= nil
                                    and result.message ~= nil then

                                    UI.Alert(
                                        result.message
                                    );

                                end


                                ShowDiplomacyMenu(
                                    parent,
                                    game
                                );

                            end
                        );

                    end);

            end

        end

    end


    UI.CreateLabel(area).SetText("FACTION MILITARY EXERCISE").SetColor("#D4AF37");
    local function ExerciseTroopsPerTurn(memberID, bonusPercent)
        local memberNation=(economy.nations or {})[memberID] or {}; local readiness=math.max(0,math.min(100,tonumber(memberNation.resourceMilitaryReadiness) or 100)); local unrest=math.max(0,math.min(100,tonumber(memberNation.resourceUnrest) or 0));
        local penalty=(unrest>=80 and 35) or (unrest>=60 and 20) or (unrest>=40 and 10) or (unrest>=20 and 5) or 0; local base=math.max(1,math.floor(tonumber(GetClientSetting("ArmyRecruiterArmiesPerTurn",4)) or 4)); local total=0;
        local recruiters=((economy.armyRecruiters or {}).territories or {}); local standing=game.LatestStanding;
        for tid,lvl in pairs(recruiters) do local ntid=tonumber(tid) or tid; local terr=standing and standing.Territories and standing.Territories[ntid] or nil; if terr and terr.OwnerPlayerID==memberID then local mult=math.max(0,100-penalty+(tonumber(bonusPercent) or 0)); total=total+math.max(0,math.floor(base*(tonumber(lvl) or 0)*readiness/100*mult/100+0.5)); end end
        return total;
    end
    local ex=ourFaction.militaryExercise or {}; local turn=tonumber((economy or {}).currentEconomyTurn or (Mod.PublicGameData or {}).tradeTurn) or 0;
    if ex.active==true and turn<=tonumber(ex.endTurn or 0) then
        UI.CreateLabel(area).SetText("ACTIVE | Ends Turn "..tostring(ex.endTurn).." | Recruiter boosts apply only to members who contribute.").SetColor("#79D279");
        local mine=(ex.contributions or {})[ourID];
        if mine then local normal=ExerciseTroopsPerTurn(ourID,0); local boosted=ExerciseTroopsPerTurn(ourID,mine.bonusPercent); UI.CreateLabel(area).SetText("Your contribution: "..tostring(mine.commerce).." Commerce | +"..tostring(mine.bonusPercent).."% | CURRENT Recruiter output "..tostring(normal).." -> "..tostring(boosted).." troops/turn (+"..tostring(math.max(0,boosted-normal))..")").SetColor("#8FD694");
        else
            UI.CreateLabel(area).SetText("Choose once per exercise. Buttons show your CURRENT exact Recruiter output after Readiness and Unrest.").SetColor("#FFFFFF");
            local cr=UI.CreateVerticalLayoutGroup(area); for _,tier in ipairs({{50,10},{100,20},{200,40},{300,60}}) do local a=tier[1]; local pct=tier[2]; local normal=ExerciseTroopsPerTurn(ourID,0); local boosted=ExerciseTroopsPerTurn(ourID,pct); UI.CreateButton(cr).SetText(tostring(a).." Commerce | +"..tostring(pct).."% | "..tostring(normal).." -> "..tostring(boosted).." troops/turn (+"..tostring(math.max(0,boosted-normal))..")").SetOnClick(function() SafeSendGameCustomMessage(game,"Contributing to Faction exercise...",{type="contributeFactionExercise",amount=a},function(r) if r and r.message then UI.Alert(r.message); end; ShowDiplomacyMenu(parent,game); end); end); end
        end
        UI.CreateLabel(area).SetText("MEMBER PARTICIPATION").SetColor("#FFD166");
        for memberID,isMember in pairs(ourFaction.members or {}) do if isMember then local c=(ex.contributions or {})[memberID]; local normal=ExerciseTroopsPerTurn(memberID,0); local boosted=c and ExerciseTroopsPerTurn(memberID,c.bonusPercent) or normal; UI.CreateLabel(area).SetText(GetPlayerName(game,memberID).." | "..(c and (tostring(c.commerce).." Commerce | +"..tostring(c.bonusPercent).."% | "..tostring(normal).." -> "..tostring(boosted).." troops/turn") or ("No contribution | Current "..tostring(normal).." troops/turn"))).SetColor(c and "#8FD694" or "#AAAAAA"); end end
    else
        local cd=tonumber(ex.cooldownUntilTurn or 0); if cd>turn then UI.CreateLabel(area).SetText("COOLDOWN | Next exercise available Turn "..tostring(cd)).SetColor("#FFB366"); elseif ourFaction.leaderPlayerID==ourID then UI.CreateButton(area).SetText("START MILITARY EXERCISE").SetOnClick(function() SafeSendGameCustomMessage(game,"Starting Faction military exercise...",{type="startFactionExercise"},function(r) if r and r.message then UI.Alert(r.message); end; ShowDiplomacyMenu(parent,game); end); end); else UI.CreateLabel(area).SetText("No active exercise. The Faction leader may start one when cooldown is ready.").SetColor("#888888"); end
    end

    if ourFaction.leaderPlayerID
        ~= ourID then

        UI.CreateButton(area)
            .SetText(
                "LEAVE FACTION"
            )
            .SetOnClick(function()

                SafeSendGameCustomMessage(game, 
                    "Leaving Faction...",
                    {

                        type =
                            "leaveFaction"

                    },

                    function(result)

                        if result ~= nil
                            and result.message ~= nil then

                            UI.Alert(
                                result.message
                            );

                        end


                        ShowDiplomacyMenu(
                            parent,
                            game
                        );

                    end
                );

            end);

    else

        UI.CreateLabel(area)
            .SetText(
                "As Faction leader, you manage invitations and membership."
            );



    UI.CreateButton(area)
        .SetText(
            "DISBAND FACTION"
        )
        .SetOnClick(function()

            SafeSendGameCustomMessage(game, 
                "Disbanding Faction...",
                {

                    type =
                        "disbandFaction"

                },

                function(result)

                    if result ~= nil
                        and result.message ~= nil then

                        UI.Alert(
                            result.message
                        );

                    end


                    ShowDiplomacyMenu(
                        parent,
                        game
                    );

                end
            );

        end);

end
    end



-- =====================================================
-- INCOMING FACTION INVITATIONS
-- =====================================================

UI.CreateLabel(area)
    .SetText(
        "\nFACTION INVITATIONS"
    );


local foundFactionInvite =
    false;


for _, invite in ipairs(
    pendingFactionInvites
) do

    if invite.toPlayerID
        == ourID then

        foundFactionInvite =
            true;


        local faction =
            factions[
                invite.factionID
            ];


        local factionName =
            faction ~= nil
            and faction.name
            or "Unknown Faction";


        local inviterName =
            GetPlayerName(
                game,
                invite.fromPlayerID
            );


        local inviteGroup =
            UI.CreateVerticalLayoutGroup(
                area
            );


        UI.CreateLabel(inviteGroup)
            .SetText(
                inviterName ..
                " invited you to join \"" ..
                tostring(
                    factionName
                ) ..
                "\"."
            );


        local buttons =
            UI.CreateHorizontalLayoutGroup(
                inviteGroup
            );


        local selectedFactionID =
            invite.factionID;


        UI.CreateButton(buttons)
            .SetText(
                "ACCEPT"
            )
            .SetOnClick(function()

                SafeSendGameCustomMessage(game, 
                    "Accepting Faction invitation...",
                    {

                        type =
                            "acceptFactionInvite",

                        factionID =
                            selectedFactionID

                    },

                    function(result)

                        if result ~= nil
                            and result.message ~= nil then

                            UI.Alert(
                                result.message
                            );

                        end


                        ShowDiplomacyMenu(
                            parent,
                            game
                        );

                    end
                );

            end);


        UI.CreateButton(buttons)
            .SetText(
                "REJECT"
            )
            .SetOnClick(function()

                SafeSendGameCustomMessage(game, 
                    "Rejecting Faction invitation...",
                    {

                        type =
                            "rejectFactionInvite",

                        factionID =
                            selectedFactionID

                    },

                    function(result)

                        if result ~= nil
                            and result.message ~= nil then

                            UI.Alert(
                                result.message
                            );

                        end


                        ShowDiplomacyMenu(
                            parent,
                            game
                        );

                    end
                );

            end);

    end

end


if not foundFactionInvite then

    UI.CreateLabel(area)
        .SetText(
            "No incoming Faction invitations."
        );

end

    -- =====================================================
    -- DIPLOMACY HISTORY
    -- =====================================================

    UI.CreateLabel(area)
        .SetText(
            "\nDIPLOMACY HISTORY"
        );


    if #history == 0 then


        UI.CreateLabel(area)
            .SetText(
                "No diplomacy events yet."
            );


    else


        local startIndex =
            math.max(
                1,
                #history - 9
            );


        for i =
            #history,
            startIndex,
            -1 do


            local event =
                history[
                    i
                ];


            UI.CreateLabel(area)
                .SetText(
                    "Turn " ..
                    tostring(
                        event.turn
                        or "?"
                    ) ..
                    " - " ..
                    tostring(
                        event.message
                        or event.type
                        or "Diplomacy event"
                    )
                );

        end

    end
end


function ShowTradeAgreementsMenu(parent, game)

    local area =
        CreateContentArea(parent);

    UI.CreateLabel(area)
        .SetText(
            "TRADE AGREEMENTS"
        );

    UI.CreateLabel(area)
        .SetText(
            "Stable recurring income based on the Commerce strength of your partners."
        );

    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );

    local nav =
        UI.CreateHorizontalLayoutGroup(area);

    UI.CreateButton(nav)
        .SetText(
            "Find Partners"
        )
        .SetOnClick(function()

            ShowFindPartners(
                parent,
                game
            );

        end);

    UI.CreateButton(nav)
        .SetText(
            "My Agreements"
        )
        .SetOnClick(function()

            ShowMyAgreements(
                parent,
                game
            );

        end);

    UI.CreateLabel(area)
        .SetText(
            "\nUse Find Partners to review nations and send proposals. Use My Agreements to manage incoming, outgoing, and active agreements."
        );
end


function ShowMarketsMenu(
    parent,
    game
)

    local area =
        CreateContentArea(
            parent
        );

    UI.CreateLabel(area)
        .SetText(
            "MARKETS"
        );

    UI.CreateLabel(area)
        .SetText(
            "Stocks | Portfolio | Rankings | Price History"
        );

    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );

    -- WORLD TRENDS: compact public rankings.  Military and Commerce lists intentionally
    -- show rank/name only, not exact opponent values.
    local trendData = Mod.PublicGameData or {};
    local trendEconomy = trendData.globalEconomy or {};
    local trendMarket = trendEconomy.market or {};
    UI.CreateLabel(area).SetText("WORLD TRENDS").SetColor("#67D5FF");

    local companies={};
    for _,company in pairs(trendMarket.companies or {}) do
        if company and company.active==true and company.delisted~=true and company.status=="trading" then
            local cp=tonumber(company.currentPrice or company.startingPrice) or 0;
            local pp=tonumber(company.previousPrice) or cp;
            local change=pp>0 and ((cp-pp)/pp)*100 or 0;
            table.insert(companies,{name=tostring(company.name or "Company"),change=change,id=company.id});
        end
    end
    table.sort(companies,function(a,b) return a.change>b.change; end);
    UI.CreateLabel(area).SetText("TOP FLAGSHIP STOCKS").SetColor("#D4AF37");
    if #companies==0 then UI.CreateLabel(area).SetText("No public flagship stocks are trading yet.").SetColor("#888888"); end
    for i=1,math.min(10,#companies) do
        local c=companies[i]; local sign=c.change>=0 and "+" or "";
        UI.CreateLabel(area).SetText(tostring(i)..". "..c.name.." | "..sign..string.format("%.1f",c.change).."%").SetColor(c.change>=0 and "#79D279" or "#FF7B7B");
    end

    local milList={};
    local storedRanks = trendMarket.rankings or {};
    if storedRanks.strongestMilitaries and #storedRanks.strongestMilitaries>0 then
        for _,pid in ipairs(storedRanks.strongestMilitaries) do table.insert(milList,{id=pid,value=0}); end
    else
        local militaryTotals={};
        if game and game.LatestStanding and game.LatestStanding.Territories then
            for tid,terr in pairs(game.LatestStanding.Territories) do
                local oid=terr and terr.OwnerPlayerID or nil;
                if oid and oid>=0 and game.Game.Players[oid]~=nil then
                    local a=terr.NumArmies and terr.NumArmies.NumArmies or 0;
                    militaryTotals[oid]=(militaryTotals[oid] or 0)+(tonumber(a) or 0);
                end
            end
        end
        for pid,v in pairs(militaryTotals) do table.insert(milList,{id=pid,value=v}); end
        table.sort(milList,function(a,b) return a.value>b.value; end);
    end
    local rankTurn = trendEconomy.currentEconomyTurn or trendData.tradeTurn or 0;
    UI.CreateLabel(area).SetText("LIVE RANKINGS — recalculated each turn | Turn "..tostring(rankTurn)).SetColor("#67D5FF");
    UI.CreateLabel(area).SetText("STRONGEST MILITARIES — exact troop totals hidden").SetColor("#FF9C66");
    for i=1,math.min(10,#milList) do local x=milList[i]; UI.CreateLabel(area).SetText(tostring(i)..". "..GetPlayerName(game,x.id)).SetColor(GetPlayerUIColor(game,x.id,"#FFFFFF")); end

    local cashList={};
    if storedRanks.commerceReserves and #storedRanks.commerceReserves>0 then
        for _,pid in ipairs(storedRanks.commerceReserves) do table.insert(cashList,{id=pid,value=0}); end
    else
        for pid,pl in pairs(game.Game.Players or {}) do
            if pl and not pl.Surrendered then table.insert(cashList,{id=pid,value=GetPlayerGold(game,pid) or 0}); end
        end
        table.sort(cashList,function(a,b) return a.value>b.value; end);
    end
    UI.CreateLabel(area).SetText("LARGEST COMMERCE RESERVES — exact balances hidden").SetColor("#79D279");
    for i=1,math.min(10,#cashList) do local x=cashList[i]; UI.CreateLabel(area).SetText(tostring(i)..". "..GetPlayerName(game,x.id)).SetColor(GetPlayerUIColor(game,x.id,"#FFFFFF")); end

    UI.CreateLabel(area).SetText("----------------------------------------");

    local ourNationForMarket = GetOurNationState(game) or {};
    local marketTurn = trendEconomy.currentEconomyTurn or trendData.tradeTurn or 1;
    if ourNationForMarket.setupComplete==true and (ourNationForMarket.flagshipCompanyID==nil or ourNationForMarket.flagshipCompanyCreated~=true) then
        local readyTurn=tonumber(ourNationForMarket.flagshipRebuildAvailableTurn) or 0;
        if marketTurn>=readyTurn then
            UI.CreateLabel(area).SetText("YOUR NATION DOES NOT CURRENTLY CONTROL A FLAGSHIP COMPANY").SetColor("#FFB366");
            UI.CreateButton(area).SetText("ESTABLISH NEW FLAGSHIP").SetOnClick(function()
                game.CreateDialog(function(root,setMaxSize,setScrollable,dialogGame,closeDialog)
                    setMaxSize(520,430); setScrollable(true);
                    UI.CreateLabel(root).SetText("ESTABLISH REPLACEMENT FLAGSHIP").SetColor("#D4AF37");
                    UI.CreateLabel(root).SetText("Choose a new company name and strategy. Your ideology, taxes and national economic policy stay unchanged.").SetColor("#BBBBBB");
                    local nameInput=UI.CreateTextInputField(root).SetPreferredWidth(260);
                    nameInput.SetPlaceholderText("New flagship name...");
                    local selectedStrategy="Balanced";
                    local stratLabel=UI.CreateLabel(root).SetText("Strategy: Balanced");
                    local sr=UI.CreateHorizontalLayoutGroup(root);
                    for _,st in ipairs({"Growth","Balanced","Dividend"}) do local strategy=st; UI.CreateButton(sr).SetText(st).SetOnClick(function() selectedStrategy=strategy; stratLabel.SetText("Strategy: "..strategy); end); end
                    UI.CreateButton(root).SetText("CREATE FLAGSHIP").SetOnClick(function()
                        local nm=tostring(nameInput.GetText() or "");
                        SafeSendGameCustomMessage(dialogGame,"Creating replacement flagship...",{type="rebuildFlagship",companyName=nm,companyStrategy=selectedStrategy},function(result)
                            if result and result.message then UI.Alert(result.message); end
                            closeDialog();
                        end);
                    end);
                end);
            end);
        else
            UI.CreateLabel(area).SetText("Replacement flagship available on Turn "..tostring(readyTurn)..".").SetColor("#FFB366");
        end
        UI.CreateLabel(area).SetText("----------------------------------------");
    end

    UI.CreateButton(area)
        .SetText(
            "BUY OTHER PLAYERS’ FLAGSHIP SHARES / STOCK MARKET"
        )
        .SetOnClick(function()

            ShowStockMarket(
                parent,
                game
            );

        end);
    UI.CreateLabel(area).SetText("Select any publicly traded player flagship, open VIEW / TRADE COMPANY, then choose how many shares to buy. Dividend companies emphasize recurring payouts; Growth companies emphasize price appreciation.").SetColor("#BBBBBB");

    UI.CreateButton(area)
        .SetText(
            "MY PORTFOLIO"
        )
        .SetOnClick(function()

            ShowStockPortfolio(
                parent,
                game
            );

        end);

    UI.CreateButton(area)
        .SetText(
            "MARKET OVERVIEW"
        )
        .SetOnClick(function()

            ShowMarketOverview(
                parent,
                game
            );

        end);

    UI.CreateButton(area)
    .SetText(
        "MARKET NEWS"
    )
    .SetOnClick(function()

        ShowMarketNews(
            parent,
            game
        );

    end);
    
UI.CreateButton(area)
    .SetText(
        "GLOBAL MARKET ETF"
    )
    .SetOnClick(function()

        ShowMarketETF(
            parent,
            game
        );

    end);

    UI.CreateLabel(area).SetText("----------------------------------------");

    UI.CreateButton(area)
        .SetText("TRADE AGREEMENTS")
        .SetOnClick(function()
            ShowTradeAgreementsMenu(parent, game);
        end);

    UI.CreateButton(area)
        .SetText("INVESTMENTS")
        .SetOnClick(function()
            ShowInvestments(parent, game);
        end);

    UI.CreateButton(area)
        .SetText("AI MANAGER")
        .SetOnClick(function()
            ShowAIManagerMenu(parent, game);
        end);

    UI.CreateButton(area)
        .SetText("GLOBAL ECONOMY")
        .SetOnClick(function()
            ShowGlobalEconomy(parent, game, "all");
        end);

end



-- =========================================================
-- SHARED TAX / IDEOLOGY PREVIEW
-- =========================================================

function GetPolicyPreviewText(game, taxPolicy, ideology, economicStrategy, companyStrategy)
    local taxCommerce,taxMarket,taxInvestment,taxConfidence=0,0,0,0;
    if taxPolicy=="Low" then taxCommerce=-10; taxMarket=10; taxInvestment=10; taxConfidence=5;
    elseif taxPolicy=="High" then taxCommerce=10; taxMarket=-10; taxInvestment=-10; taxConfidence=-5; end
    local ideologyEffects={
        ["Free Market"]={-3,8,6,2}, ["Capitalist"]={-2,6,5,3}, ["Social Democratic"]={2,2,3,2},
        ["State Capitalist"]={4,1,5,4}, ["Socialist"]={5,-5,1,1}, ["Communist"]={7,-9,-2,0},
        ["Fascist"]={3,-2,1,3}, ["Nationalist"]={2,-1,0,2}
    };
    local ie=ideologyEffects[ideology] or {0,0,0,0};
    local strategyEffects={Growth={5,4,5,2},Balanced={0,0,0,0},Conservative={-3,-2,-3,4}};
    local se=strategyEffects[economicStrategy] or {0,0,0,0};
    local commerce=taxCommerce+ie[1]+se[1]; local market=taxMarket+ie[2]+se[2]; local investment=taxInvestment+ie[3]+se[3]; local confidence=taxConfidence+ie[4]+se[4];
    local currentCommerce=0; if game and game.Us then currentCommerce=GetPlayerIncome(game,GetLocalPlayerID(game)) or 0; end
    local projected=math.floor(currentCommerce*(1+commerce/100)+0.5);
    local function sg(v,suf) return (v>0 and "+" or "")..tostring(v)..(suf or ""); end
    local companyText="Select a company strategy";
    if companyStrategy=="Growth" then companyText="Growth Company: price fundamentals x1.35 | dividend pool 1% of owner income | random volatility scale 30%";
    elseif companyStrategy=="Balanced" then companyText="Balanced Company: price fundamentals x1.00 | dividend pool 2% of owner income | random volatility scale 25%";
    elseif companyStrategy=="Dividend" then companyText="Dividend Company: price fundamentals x0.45 | dividend pool 4%-6% of owner income | random volatility scale 15%"; end
    return "LIVE NUMERICAL PREVIEW\n"..
        "Base Commerce/Turn: "..tostring(currentCommerce).."\n"..
        "Policy Commerce Modifier: "..sg(commerce,"%").." => ~"..tostring(projected).." Commerce/turn\n"..
        "Market Modifier: "..sg(market,"%").." | Investment Return Modifier: "..sg(investment,"%").." | Company Confidence: "..sg(confidence,"").."\n"..
        "Economic Strategy: "..tostring(economicStrategy or "None").." => Commerce "..sg(se[1],"%")..", Market "..sg(se[2],"%")..", Investment "..sg(se[3],"%")..", Confidence "..sg(se[4],"").."\n"..
        companyText;
end

function ShowTaxationMenu(
    parent,
    game
)

    local area =
        CreateContentArea(
            parent
        );

    local nation =
        GetOurNationState(
            game
        );


    UI.CreateLabel(area)
        .SetText(
            "TAXATION & IDEOLOGY"
        );


    if nation == nil
        or nation.setupComplete ~= true then

        UI.CreateLabel(area)
            .SetText(
                "Complete National Setup to access taxation and ideology details."
            );

        return;
    end


    UI.CreateLabel(area)
        .SetText(
            "Current Tax Policy: " ..
            tostring(
                nation.taxPolicy
                or "Standard"
            )
        );


    UI.CreateLabel(area)
        .SetText(
            "Current Ideology: " ..
            tostring(
                nation.ideology
                or "Unknown"
            )
        );


    UI.CreateLabel(area)
        .SetText(
            "--------------------------------"
        );


    UI.CreateLabel(area)
        .SetText(
            GetPolicyPreviewText(
                game,
                nation.taxPolicy
                    or "Standard",
                nation.ideology
                    or "Social Democratic",
                nation.economicStrategy or "Balanced",
                nation.companyStrategy or "Balanced"
            )
        );


    UI.CreateLabel(area)
        .SetText(
            "--------------------------------"
        );


    UI.CreateLabel(area)
        .SetText(
            "Low Tax\n" ..
            "-10% Commerce | +10% Market | +10% Investment | +5 Confidence\n\n" ..

            "Standard Tax\n" ..
            "0% Commerce | 0% Market | 0% Investment | 0 Confidence\n\n" ..

            "High Tax\n" ..
            "+10% Commerce | -10% Market | -10% Investment | -5 Confidence"
        );

end


function ShowUnitedNationsMenu(parent, game)

    local area =
        CreateContentArea(
            parent
        );

    local data =
        Mod.PublicGameData
        or {};

    local economy =
        data.globalEconomy
        or {};

    local un =
        economy.unitedNations
        or data.unitedNations
        or {};

    UI.CreateLabel(area)
        .SetText(
            "UNITED NATIONS / SECURITY COUNCIL"
        );

    if GetClientSetting(
        "UnitedNationsEnabled",
        true
    ) ~= true
        or un.enabled == false
    then

        UI.CreateLabel(area)
            .SetText(
                "The host has disabled the United Nations."
            );

        return;
    end

    local currentTurn =
        data.tradeTurn
        or 0;

    local proposalCooldownTurns =
        GetClientSetting(
            "UNProposalCooldownTurns",
            2
        );

    local lastProposalTurn =
        (un.lastProposalTurnByPlayer or {})[
            GetLocalPlayerID(game)
        ];

    local proposalCooldownRemaining = 0;
    if lastProposalTurn ~= nil then
        proposalCooldownRemaining =
            math.max(
                0,
                proposalCooldownTurns
                - (currentTurn - lastProposalTurn)
            );
    end

    local startTurn =
        GetClientSetting(
            "UnitedNationsStartTurn",
            2
        );

    if currentTurn < startTurn then

        UI.CreateLabel(area)
            .SetText(
                "The United Nations becomes active on Turn "
                .. tostring(startTurn)
                .. ". Current turn: "
                .. tostring(currentTurn)
            );

        return;
    end

    local function ContainsPlayer(
        list,
        playerID
    )

        for _, value
            in ipairs(
                list
                or {}
            )
        do

            if value == playerID then
                return true;
            end
        end

        return false;
    end

    local permanent =
        un.permanentMembers
        or {};

    local rotating =
        un.rotatingMembers
        or {};

    local usID =
        game ~= nil
        and game.Us ~= nil
        and GetLocalPlayerID(game)
        or nil;

    local usPermanent =
        usID ~= nil
        and ContainsPlayer(
            permanent,
            usID
        );

    local usCouncil =
        usPermanent
        or (
            usID ~= nil
            and ContainsPlayer(
                rotating,
                usID
            )
        );

    UI.CreateLabel(area)
        .SetText(
            "SECURITY COUNCIL"
        );

    local function AddMemberGrid(
        title,
        members
    )

        UI.CreateLabel(area)
            .SetText(
                title
            );

        local row =
            nil;

        for index, playerID
            in ipairs(
                members
                or {}
            )
        do

            if (
                index - 1
            )
                % 3
                == 0
            then

                row =
                    UI.CreateHorizontalLayoutGroup(
                        area
                    );

            end

            UI.CreateLabel(row)
                .SetText(
                    GetPlayerName(
                        game,
                        playerID
                    )
                )
                .SetColor(
                    GetPlayerUIColor(
                        game,
                        playerID,
                        "#FFFFFF"
                    )
                );

        end

        if #(
            members
            or {}
        ) == 0 then

            UI.CreateLabel(area)
                .SetText(
                    "No seats assigned yet."
                );

        end
    end

    AddMemberGrid(
        "Permanent Members (veto)",
        permanent
    );

    AddMemberGrid(
        "Rotating Members",
        rotating
    );

    if un.chairPlayerID ~= nil then

        UI.CreateLabel(area)
            .SetText(
                "Chair: "
                .. GetPlayerName(
                    game,
                    un.chairPlayerID
                )
                .. " | Vice Chair: "
                .. (
                    un.viceChairPlayerID ~= nil
                    and GetPlayerName(
                        game,
                        un.viceChairPlayerID
                    )
                    or "None"
                )
            );

    end

    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );

    UI.CreateLabel(area)
        .SetText(
            "ACTIVE RESOLUTIONS"
        );

    local active =
        un.activeResolutions
        or {};

    if #active == 0 then

        UI.CreateLabel(area)
            .SetText(
                "No active Security Council resolutions."
            );

    end

    for _, resolution
        in ipairs(
            active
        )
    do

        local targetName =
            resolution.targetPlayerID ~= nil
            and GetPlayerName(
                game,
                resolution.targetPlayerID
            )
            or "None";

        local proposerName =
            resolution.proposerPlayerID ~= nil
            and GetPlayerName(
                game,
                resolution.proposerPlayerID
            )
            or "Unknown";

        local yesVotes =
            0;

        local noVotes =
            0;

        local abstainVotes =
            0;

        for _, vote
            in pairs(
                resolution.votes
                or {}
            )
        do

            if vote == "YES" then
                yesVotes = yesVotes + 1;
            elseif vote == "NO" then
                noVotes = noVotes + 1;
            else
                abstainVotes = abstainVotes + 1;
            end
        end

        UI.CreateLabel(area)
            .SetText(
                "#"
                .. tostring(
                    resolution.id
                )
                .. " "
                .. string.upper(
                    tostring(
                        resolution.resolutionType
                        or "resolution"
                    )
                )
                .. " | Target: "
                .. targetName
                .. "\nProposed by: "
                .. proposerName
                .. " | Voting closes Turn "
                .. tostring(
                    resolution.voteEndsTurn
                    or "?"
                )
                .. ((resolution.effectDurationTurns ~= nil) and (" | Effect: " .. tostring(resolution.effectDurationTurns) .. " turn(s)") or "")
                .. "\nYES "
                .. tostring(yesVotes)
                .. " | NO "
                .. tostring(noVotes)
                .. " | ABSTAIN "
                .. tostring(abstainVotes)
            );

        if usCouncil then

            local row =
                UI.CreateHorizontalLayoutGroup(
                    area
                );

            local resolutionID =
                resolution.id;

            local function Vote(
                vote
            )

                SafeSendGameCustomMessage(game, 
                    "Submitting UN vote...",
                    {
                        type =
                            "voteUNResolution",

                        resolutionID =
                            resolutionID,

                        vote =
                            vote
                    },
                    function(result)

                        if result ~= nil
                            and result.message ~= nil
                        then

                            UI.Alert(
                                result.message
                            );

                        end

                        ShowUnitedNationsMenu(
                            parent,
                            game
                        );

                    end
                );

            end

            UI.CreateButton(row)
                .SetText(
                    "YES"
                )
                .SetOnClick(
                    function()
                        Vote("YES");
                    end
                );

            UI.CreateButton(row)
                .SetText(
                    usPermanent
                    and "NO / VETO"
                    or "NO"
                )
                .SetOnClick(
                    function()
                        Vote("NO");
                    end
                );

            UI.CreateButton(row)
                .SetText(
                    "ABSTAIN"
                )
                .SetOnClick(
                    function()
                        Vote("ABSTAIN");
                    end
                );

        end
    end

    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );

    UI.CreateLabel(area)
        .SetText(
            "PROPOSE RESOLUTION"
        );

    local selectedType =
        "sanctions";

    local selectedTargetID =
        nil;

    local proposalLabel =
        UI.CreateLabel(area);

    local effectLabel =
        UI.CreateLabel(area);

    local sanctionMinTurns = math.max(1, math.floor(tonumber(GetClientSetting("UNSanctionMinTurns", 2)) or 2));
    local sanctionMaxTurns = math.max(sanctionMinTurns, math.floor(tonumber(GetClientSetting("UNSanctionMaxTurns", 6)) or 6));
    local ceasefireMinTurns = math.max(1, math.floor(tonumber(GetClientSetting("UNCeasefireMinTurns", 2)) or 2));
    local ceasefireMaxTurns = math.max(ceasefireMinTurns, math.floor(tonumber(GetClientSetting("UNCeasefireMaxTurns", 6)) or 6));
    local selectedEffectDuration = sanctionMinTurns;
    local aidMin=math.max(1,math.floor(tonumber(GetClientSetting("UNAidMinimumCommerce",50)) or 50));
    local aidMax=math.max(aidMin,math.floor(tonumber(GetClientSetting("UNAidMaximumCommerce",1000)) or 1000));
    local aidStep=math.max(1,math.floor(tonumber(GetClientSetting("UNAidStepCommerce",50)) or 50));
    local selectedAidAmount=aidMin;

    local function UNResolutionEffectText(resolutionType)
        if resolutionType == "sanctions" then
            return "RESULT IF PASSED: Target loses 10% Commerce each turn for " .. tostring(selectedEffectDuration) .. " turn(s).";
        elseif resolutionType == "embargo" then
            return "RESULT IF PASSED: Trade Agreement income and Resource Trade deliveries involving the target are paused for 3 turns.";
        elseif resolutionType == "aid" then
            return "RESULT IF PASSED: Target immediately receives "..tostring(selectedAidAmount).." Commerce.";
        elseif resolutionType == "condemnation" then
            return "RESULT IF PASSED: Target is formally condemned for 3 turns and gains +5 Unrest when the unrest system is active.";
        elseif resolutionType == "ceasefire" then
            return "RESULT IF PASSED: Forces peace and prevents a new war declaration for " .. tostring(selectedEffectDuration) .. " turn(s).";
        end
        return "";
    end

    local function RefreshProposalLabel()

        local durationText = "";
        if selectedType == "sanctions" or selectedType == "ceasefire" then
            durationText = " | Duration: " .. tostring(selectedEffectDuration) .. " turn(s)";
        elseif selectedType == "aid" then
            durationText = " | Aid: "..tostring(selectedAidAmount).." Commerce";
        end
        proposalLabel.SetText(
            "Type: "
            .. string.upper(
                selectedType
            )
            .. " | Target: "
            .. (
                selectedTargetID ~= nil
                and GetPlayerName(
                    game,
                    selectedTargetID
                )
                or "None"
            )
            .. durationText
        );

        effectLabel.SetText(
            UNResolutionEffectText(
                selectedType
            )
        );

    end

    RefreshProposalLabel();

    UI.CreateLabel(area)
        .SetText(
            "Proposal Cooldown: "
            .. (
                proposalCooldownRemaining > 0
                and (tostring(proposalCooldownRemaining) .. " turn(s) remaining")
                or "READY"
            )
            .. " | Host setting: "
            .. tostring(proposalCooldownTurns)
            .. " turn(s) between proposals per player."
        );

    UI.CreateLabel(area)
        .SetText(
            "Permanent-member NO votes veto a resolution. Otherwise the configured YES-vote threshold determines passage."
        );

    local typeRow1 =
        UI.CreateHorizontalLayoutGroup(
            area
        );

    local typeRow2 =
        UI.CreateHorizontalLayoutGroup(
            area
        );

    local RefreshTargetSearch = nil;

    local function AddTypeButton(
        row,
        label,
        value
    )

        UI.CreateButton(row)
            .SetText(
                label
            )
            .SetOnClick(
                function()

                    selectedType =
                        value;
                    if selectedType == "ceasefire" then
                        selectedEffectDuration = ceasefireMinTurns;
                    elseif selectedType == "sanctions" then
                        selectedEffectDuration = sanctionMinTurns;
                    end

                    selectedTargetID = nil;
                    RefreshProposalLabel();
                    if RefreshTargetSearch ~= nil then RefreshTargetSearch(); end

                end
            );

    end

    AddTypeButton(typeRow1, "SANCTIONS", "sanctions");
    AddTypeButton(typeRow1, "EMBARGO", "embargo");
    AddTypeButton(typeRow1, "AID", "aid");
    AddTypeButton(typeRow2, "CONDEMN", "condemnation");
    AddTypeButton(typeRow2, "CEASEFIRE", "ceasefire");

    UI.CreateLabel(area).SetText("SANCTION / CEASEFIRE DURATION").SetColor("#FFD166");
    local durationRow = UI.CreateHorizontalLayoutGroup(area);
    UI.CreateButton(durationRow).SetText("-1 TURN").SetOnClick(function()
        local minTurns = selectedType == "ceasefire" and ceasefireMinTurns or sanctionMinTurns;
        selectedEffectDuration = math.max(minTurns, selectedEffectDuration - 1);
        RefreshProposalLabel();
    end);
    UI.CreateButton(durationRow).SetText("+1 TURN").SetOnClick(function()
        local maxTurns = selectedType == "ceasefire" and ceasefireMaxTurns or sanctionMaxTurns;
        selectedEffectDuration = math.min(maxTurns, selectedEffectDuration + 1);
        RefreshProposalLabel();
    end);
    UI.CreateLabel(area).SetText(
        "Host limits | Sanctions: " .. tostring(sanctionMinTurns) .. "-" .. tostring(sanctionMaxTurns)
        .. " turns | Ceasefire: " .. tostring(ceasefireMinTurns) .. "-" .. tostring(ceasefireMaxTurns) .. " turns"
    ).SetColor("#B0BEC5");
    UI.CreateLabel(area).SetText("AID AMOUNT").SetColor("#79D279");
    local aidRow=UI.CreateHorizontalLayoutGroup(area);
    UI.CreateButton(aidRow).SetText("-"..tostring(aidStep)).SetOnClick(function() selectedAidAmount=math.max(aidMin,selectedAidAmount-aidStep); RefreshProposalLabel(); end);
    UI.CreateButton(aidRow).SetText("+"..tostring(aidStep)).SetOnClick(function() selectedAidAmount=math.min(aidMax,selectedAidAmount+aidStep); RefreshProposalLabel(); end);
    UI.CreateLabel(area).SetText("Host limits | Aid: "..tostring(aidMin).."-"..tostring(aidMax).." Commerce | Step: "..tostring(aidStep)).SetColor("#B0BEC5");

    UI.CreateLabel(area)
        .SetText(
            "Search Target Nation"
        );

    local targetSearch =
        CreateWideTextInput(
            area
        );

    local searchHost =
        UI.CreateVerticalLayoutGroup(
            area
        );

    RefreshTargetSearch = function()

        if not UI.IsDestroyed(
            searchHost
        ) then

            UI.Destroy(
                searchHost
            );

        end

        searchHost =
            UI.CreateVerticalLayoutGroup(
                area
            );

        local query =
            string.lower(
                targetSearch.GetText()
                or ""
            );

        local matches =
            {};

        for playerID, player
            in pairs(
                game.Game.Players
                or {}
            )
        do

            if playerID ~= usID
                and player.Surrendered ~= true
            then

                local name =
                    GetPlayerName(
                        game,
                        playerID
                    );

                local eligibleTarget = true;
                if selectedType == "ceasefire" then
                    local sa,sb=tostring(usID),tostring(playerID);
                    local relKey = sa < sb and (sa.."|"..sb) or (sb.."|"..sa);
                    local rel = (((economy or {}).diplomacy or {}).relationships or {})[relKey];
                    eligibleTarget = rel ~= nil and rel.status == "war";
                end

                if eligibleTarget and (
                    query == ""
                    or string.find(
                        string.lower(name),
                        query,
                        1,
                        true
                    ) ~= nil
                )
                then

                    table.insert(
                        matches,
                        {
                            id = playerID,
                            name = name
                        }
                    );

                end
            end
        end

        table.sort(
            matches,
            function(a, b)
                return a.name < b.name;
            end
        );

        local row =
            nil;

        for index, item
            in ipairs(
                matches
            )
        do

            if index > 60 then
                break;
            end

            if (
                index - 1
            )
                % 3
                == 0
            then

                row =
                    UI.CreateHorizontalLayoutGroup(
                        searchHost
                    );

            end

            local capturedID =
                item.id;

            UI.CreateButton(row)
                .SetText(
                    item.name
                )
                .SetTextColor(
                    GetPlayerUIColor(
                        game,
                        item.id,
                        "#FFFFFF"
                    )
                )
                .SetOnClick(
                    function()

                        selectedTargetID =
                            capturedID;

                        RefreshProposalLabel();

                    end
                );

        end
    end

    targetSearch.SetOnValueChanged(
        function()
            RefreshTargetSearch();
        end
    );

    RefreshTargetSearch();

    UI.CreateButton(area)
        .SetText(
            "SUBMIT TO SECURITY COUNCIL"
        )
        .SetOnClick(
            function()

                if selectedTargetID == nil then

                    UI.Alert(
                        "Select a target nation first."
                    );

                    return;
                end

                SafeSendGameCustomMessage(game, 
                    "Submitting UN resolution...",
                    {
                        type =
                            "proposeUNResolution",

                        resolutionType =
                            selectedType,

                        targetPlayerID =
                            selectedTargetID,

                        durationTurns =
                            selectedEffectDuration,

                        aidAmount =
                            selectedAidAmount
                    },
                    function(result)

                        if result ~= nil
                            and result.message ~= nil
                        then

                            UI.Alert(
                                result.message
                            );

                        end

                        ShowUnitedNationsMenu(
                            parent,
                            game
                        );

                    end
                );

            end
        );

    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );

    UI.CreateLabel(area)
        .SetText(
            "RECENT UN HISTORY"
        );

    local history =
        un.resolutionHistory
        or {};

    if #history == 0 then

        UI.CreateLabel(area)
            .SetText(
                "No completed resolutions yet."
            );

    else

        for index = 1,
            math.min(
                10,
                #history
            )
        do

            local item =
                history[index];

            UI.CreateLabel(area)
                .SetText(
                    "#"
                    .. tostring(
                        item.id
                        or "?"
                    )
                    .. " "
                    .. string.upper(
                        tostring(
                            item.resolutionType
                            or "resolution"
                        )
                    )
                    .. " - "
                    .. tostring(
                        item.status
                        or "UNKNOWN"
                    )
                    .. " | Target: "
                    .. (
                        item.targetPlayerID ~= nil
                        and GetPlayerName(
                            game,
                            item.targetPlayerID
                        )
                        or "None"
                    )
                );

        end
    end
end


function ShowCustomizeTabs(
    parent,
    game,
    tabsHost
)

    local area = CreateContentArea(parent);

    UI.CreateLabel(area).SetText("CUSTOMIZE TABS").SetColor("#90A4AE");
    UI.CreateLabel(area).SetText("Choose which optional top-level sections are shown. Hiding a tab does not disable its systems.");
    UI.CreateLabel(area).SetText("Overview and Diplomacy remain available because they contain core national and relationship information.");
    UI.CreateLabel(area).SetText("----------------------------------------");

    local marketsBox = UI.CreateCheckBox(area)
        .SetText("Show Markets")
        .SetIsChecked(PlayerTabVisibility.markets ~= false);

    local resourcesBox = UI.CreateCheckBox(area)
        .SetText("Show Resources")
        .SetIsChecked(PlayerTabVisibility.resources ~= false);

    local militaryBox = UI.CreateCheckBox(area)
        .SetText("Show Military")
        .SetIsChecked(PlayerTabVisibility.military ~= false);

    local unBox = UI.CreateCheckBox(area)
        .SetText("Show United Nations")
        .SetIsChecked(PlayerTabVisibility.unitedNations ~= false);

    local helpBox = UI.CreateCheckBox(area)
        .SetText("Show How It Works")
        .SetIsChecked(PlayerTabVisibility.howItWorks ~= false);

    local data = Mod.PublicGameData or {};
    local economy = data.globalEconomy or {};
    local ourNation = game ~= nil and game.Us ~= nil and (economy.nations or {})[GetLocalPlayerID(game)] or nil;

    local warEventAlertsBox = UI.CreateCheckBox(area)
        .SetText("Show War Event Pop-up Alerts")
        .SetIsChecked(ourNation == nil or ourNation.showWarEventAlerts ~= false);

    UI.CreateLabel(area).SetText("War Event alerts can be hidden without disabling the underlying decision or consequence.");

    UI.CreateButton(area).SetText("APPLY TAB CHANGES").SetOnClick(function()
        PlayerTabVisibility.markets = marketsBox.GetIsChecked();
        PlayerTabVisibility.resources = resourcesBox.GetIsChecked();
        PlayerTabVisibility.military = militaryBox.GetIsChecked();
        PlayerTabVisibility.unitedNations = unBox.GetIsChecked();
        PlayerTabVisibility.howItWorks = helpBox.GetIsChecked();

        -- Legacy standalone tabs are intentionally folded into the new navigation.
        PlayerTabVisibility.investments = false;
        PlayerTabVisibility.taxation = false;
        PlayerTabVisibility.globalEconomy = false;

        SafeSendGameCustomMessage(game,
            "Updating war event alert preference...",
            { type = "setWarEventAlerts", enabled = warEventAlertsBox.GetIsChecked() },
            function(result) end
        );

        BuildMainTabs(tabsHost, parent, game);
        UI.Alert("Menu tabs updated. Hidden sections remain active and can be restored here.");
    end);

    UI.CreateButton(area).SetText("RESET TABS TO DEFAULT").SetOnClick(function()
        PlayerTabVisibility.markets = true;
        PlayerTabVisibility.resources = true;
        PlayerTabVisibility.military = true;
        PlayerTabVisibility.unitedNations = true;
        PlayerTabVisibility.howItWorks = true;
        PlayerTabVisibility.investments = false;
        PlayerTabVisibility.taxation = false;
        PlayerTabVisibility.globalEconomy = false;

        SafeSendGameCustomMessage(game,
            "Restoring war event alerts...",
            { type = "setWarEventAlerts", enabled = true },
            function(result) end
        );

        BuildMainTabs(tabsHost, parent, game);
        UI.Alert("Default United Frontier tabs restored.");
    end);
end


-- =========================================================
-- STRATEGIC RESOURCES UI
-- =========================================================

local RESOURCE_UI_TYPES = {
    "Oil", "Gas", "Uranium", "Iron", "Food", "Rare Earths",
    "Coal", "Copper", "Lithium"
};

local RESOURCE_UI_COLORS = {
    Oil = "#D6A84B",
    Gas = "#64B5F6",
    Uranium = "#C792EA",
    Iron = "#B0BEC5",
    Food = "#9CCC65",
    ["Rare Earths"] = "#4DD0E1",
    Coal = "#8D8D8D",
    Copper = "#D28B5C",
    Lithium = "#E573C7"
};

local function ResourceUIColor(resourceName)
    return RESOURCE_UI_COLORS[resourceName] or "#FFFFFF";
end

local function ResourceTypeAvailable(resourceName)
    if resourceName == "Coal" or resourceName == "Copper" or resourceName == "Lithium" then
        return GetClientSetting("AdvancedResourcesEnabled", true);
    end
    return true;
end

local function ResourceAmountText(values)
    local parts = {};
    for _, resourceName in ipairs(RESOURCE_UI_TYPES) do
        if ResourceTypeAvailable(resourceName) then
            table.insert(parts, resourceName .. ": " .. tostring((values or {})[resourceName] or 0));
        end
    end
    return table.concat(parts, " | ");
end

function ShowResourcesMenu(parent, game)
    local area = CreateContentArea(parent);
    local data = Mod.PublicGameData or {};
    local economy = data.globalEconomy or {};
    local resources = economy.resources or {};
    local ourID = GetLocalPlayerID(game);
    local nation = ourID ~= nil and (economy.nations or {})[ourID] or {};

    UI.CreateLabel(area).SetText("STRATEGIC RESOURCES").SetColor("#67D5FF");
    local privateView = Mod.PlayerGameData or {};
    local strategicIntel = privateView.strategicIntel or {};
    local knownResources = strategicIntel.knownResources or {};
    UI.CreateLabel(area).SetText("PRIVATE RESOURCE INTELLIGENCE").SetColor("#FFD166");
    UI.CreateLabel(area).SetText("Resource locations are private. You know your own deposits, deposits directly bordering your nation, and intelligence shared by allies or your Faction.").SetColor("#BBBBBB");

    local filterRow = UI.CreateHorizontalLayoutGroup(area);
    local resourceFilters = {
        {"My Resources", "MY RESOURCES"},
        {"Neighboring", "NEIGHBORS"},
        {"Shared Intel", "ALLY / FACTION"},
        {"All Known", "ALL KNOWN"}
    };
    for _,filterDef in ipairs(resourceFilters) do
        local key=filterDef[1]; local label=filterDef[2];
        UI.CreateButton(filterRow).SetText((ResourceIntelFilter==key and "▶ " or "")..label).SetOnClick(function()
            ResourceIntelFilter=key; ShowResourcesMenu(parent,game);
        end);
    end

    local function resourceReasonGroup(reason)
        if reason == "Owned" or reason == "Your Resource" then return "My Resources"; end
        if reason == "Border" or reason == "Neighboring Resource" then return "Neighboring"; end
        if reason == "Shared Intelligence" or reason == "Ally Intel" or reason == "Faction Intel" then return "Shared Intel"; end
        if reason == "Strategic Intelligence" then return "All Known"; end
        return "All Known";
    end
    local reasonText = {
        ["Owned"]="Your Resource", ["Your Resource"]="Your Resource",
        ["Border"]="Neighboring Resource", ["Neighboring Resource"]="Neighboring Resource",
        ["Shared Intelligence"]="Shared Intel", ["Ally Intel"]="Ally Intel", ["Faction Intel"]="Faction Intel",
        ["Strategic Intelligence"]="Strategic Intel"
    };
    local reasonColor = {
        ["Owned"]="#8FD694", ["Your Resource"]="#8FD694",
        ["Border"]="#FFD166", ["Neighboring Resource"]="#FFD166",
        ["Shared Intelligence"]="#62B6FF", ["Ally Intel"]="#62B6FF", ["Faction Intel"]="#62B6FF",
        ["Strategic Intelligence"]="#C792EA"
    };

    local knownIDs = {};
    for territoryID,_ in pairs(knownResources) do table.insert(knownIDs, tonumber(territoryID) or territoryID); end
    table.sort(knownIDs, function(a,b) return tonumber(a) < tonumber(b); end);
    local shownKnown = 0;
    for _,territoryID in ipairs(knownIDs) do
        local info = knownResources[territoryID];
        local group = resourceReasonGroup(info.reason);
        if ResourceIntelFilter == "All Known" or ResourceIntelFilter == group then
            local details = game.Map and game.Map.Territories and game.Map.Territories[territoryID] or nil;
            local parts = {};
            for _,resourceName in ipairs(RESOURCE_UI_TYPES) do
                local amount = info.resources and tonumber(info.resources[resourceName]) or 0;
                if amount ~= nil and amount > 0 then table.insert(parts, resourceName .. " Lv." .. tostring(amount)); end
            end
            if #parts > 0 and shownKnown < 30 then
                shownKnown = shownKnown + 1;
                local row = UI.CreateHorizontalLayoutGroup(area);
                local why = reasonText[info.reason] or tostring(info.reason or "Known");
                UI.CreateLabel(row).SetText((details and details.Name or ("Territory " .. tostring(territoryID))) .. " | " .. table.concat(parts, ", ") .. " | " .. why).SetColor(reasonColor[info.reason] or "#DDEEFF");
                local capturedID = territoryID;
                UI.CreateButton(row).SetText("SHOW").SetOnClick(function()
                    if UFMenuClose ~= nil then UFMenuClose(); end
                    game.HighlightTerritories({capturedID});
                    -- Keep only a tiny return control over the map instead of the full mod menu.
                    game.CreateDialog(function(backRoot, setMaxSize, setScrollable, dialogGame, closeDialog)
                        setMaxSize(340, 165); setScrollable(false);
                        UI.CreateLabel(backRoot).SetText(details and details.Name or ("Territory "..tostring(capturedID))).SetColor("#67D5FF");
                        UI.CreateButton(backRoot).SetText("← BACK TO RESOURCES").SetOnClick(function()
                            closeDialog();
                            dialogGame.CreateDialog(function(resourceRoot, sm, ss, resourceGame, closeResource)
                                sm(900, 760); ss(true);
                                local oldClose = UFMenuClose; UFMenuClose = closeResource;
                                ShowResourcesMenu(resourceRoot, resourceGame);
                                UFMenuClose = oldClose;
                            end);
                        end);
                    end);
                end);

                if group == "My Resources" then
                    local maxLvl = math.max(1, math.min(5, math.floor(tonumber(GetClientSetting("ResourceFacilityMaxLevel",5)) or 5)));
                    local upgradable = {};
                    for _,resourceName in ipairs(RESOURCE_UI_TYPES) do
                        local lvl = info.resources and tonumber(info.resources[resourceName]) or 0;
                        if lvl > 0 and lvl < maxLvl then table.insert(upgradable,{name=resourceName,level=lvl}); end
                    end
                    if #upgradable > 0 then
                        UI.CreateButton(row).SetText("UPGRADE").SetOnClick(function()
                            if #upgradable == 1 then
                                local item=upgradable[1];
                                SafeSendGameCustomMessage(game,"Scheduling resource upgrade...",{type="buildResourceFacility",territoryID=capturedID,resource=item.name},function(result)
                                    if result and result.message then UI.Alert(result.message); end
                                    ShowResourcesMenu(parent,game);
                                end);
                            else
                                game.CreateDialog(function(upRoot,setMaxSize,setScrollable,dialogGame,closeDialog)
                                    setMaxSize(420,340); setScrollable(true);
                                    UI.CreateLabel(upRoot).SetText("UPGRADE RESOURCE — "..(details and details.Name or tostring(capturedID))).SetColor("#67D5FF");
                                    for _,item in ipairs(upgradable) do
                                        local rname=item.name; local rlvl=item.level;
                                        UI.CreateButton(upRoot).SetText(rname.." L"..tostring(rlvl).." → L"..tostring(rlvl+1)).SetOnClick(function()
                                            SafeSendGameCustomMessage(dialogGame,"Scheduling resource upgrade...",{type="buildResourceFacility",territoryID=capturedID,resource=rname},function(result)
                                                if result and result.message then UI.Alert(result.message); end
                                                closeDialog();
                                            end);
                                        end);
                                    end
                                end);
                            end
                        end);
                    else
                        UI.CreateLabel(row).SetText("MAX").SetColor("#79D279");
                    end
                end
            end
        end
    end
    if shownKnown == 0 then UI.CreateLabel(area).SetText("No resource locations match this filter.").SetColor("#AAAAAA"); end
    UI.CreateLabel(area).SetText("----------------------------------------");

    if IsViewerMode(game) then
        ShowViewerModeNotice(area, "Viewer mode: resource production exists normally, but personal stockpiles, trades, Recruiters, and facility actions require an active player.");
        return;
    end

    if GetClientSetting("ResourcesEnabled", true) ~= true then
        UI.CreateLabel(area).SetText("The host has disabled Strategic Resources.");
        return;
    end

    UI.CreateLabel(area).SetText("NATIONAL RESOURCE STATUS").SetColor("#8FD694");
    UI.CreateLabel(area).SetText("Production / Need / Stockpile / Net").SetColor("#B0BEC5");

    for _, resourceName in ipairs(RESOURCE_UI_TYPES) do
        if ResourceTypeAvailable(resourceName) then
            local production = tonumber((nation.resourceProduction or {})[resourceName]) or 0;
            local effective = tonumber((nation.resourceEffective or {})[resourceName]) or production;
            local need = tonumber((nation.resourceRequirements or {})[resourceName]) or 0;
            local recruiterLevels = nation.armyRecruiterLevels or 0;
            if resourceName == "Oil" or resourceName == "Food" or resourceName == "Iron" then
                need = need + recruiterLevels;
            end

            local balance = effective - need;
            local stockpile = math.max(0, tonumber((nation.resourceStockpile or {})[resourceName]) or 0);
            local uncoveredShortage = math.max(0, tonumber((nation.resourceShortages or {})[resourceName]) or 0);
            local status = "STABLE";
            local statusColor = "#D7D7D7";

            if uncoveredShortage > 0 then
                status = "SHORTAGE";
                statusColor = "#FF6B6B";
            elseif balance < 0 then
                status = "STOCKPILE COVERED";
                statusColor = "#FFD166";
            elseif balance > 0 then
                status = "SURPLUS";
                statusColor = "#72D572";
            end

            if resourceName == "Uranium" and status ~= "SHORTAGE" then
                statusColor = "#C792EA";
            end

            local prefix = balance > 0 and "+" or "";
            UI.CreateLabel(area).SetText(
                resourceName .. "  |  "
                .. tostring(production) .. " / " .. tostring(need)
                .. "  |  Stock " .. tostring(stockpile)
                .. "  |  " .. prefix .. tostring(balance)
                .. "  " .. status
            ).SetColor(ResourceUIColor(resourceName));
        end
    end

    UI.CreateLabel(area).SetText("----------------------------------------");
    UI.CreateLabel(area).SetText("NATIONAL EFFECTS").SetColor("#8AB4F8");

    local penalty = nation.resourcePenaltyPercent or 0;
    local readiness = nation.resourceMilitaryReadiness or 100;
    local unrest = nation.resourceUnrest or 0;
    local mobilizationBurden = nation.resourceMobilizationCommercePenaltyPercent or 0;

    UI.CreateLabel(area).SetText(
        "Readiness: " .. tostring(readiness) .. "%"
        .. " | Commerce Penalty: -" .. tostring(penalty) .. "%"
        .. " | Mobilization: -" .. tostring(mobilizationBurden) .. "%"
        .. " | Unrest: " .. tostring(unrest)
    );

    local shortages = nation.resourceShortages or {};
    local shortageParts = {};
    for resourceName, amount in pairs(shortages) do
        table.insert(shortageParts, resourceName .. " -" .. tostring(amount));
    end
    table.sort(shortageParts);
    if #shortageParts > 0 then
        UI.CreateLabel(area).SetText("SHORTAGES: " .. table.concat(shortageParts, ", ")).SetColor("#FF6B6B");
    else
        UI.CreateLabel(area).SetText("SHORTAGES: None").SetColor("#72D572");
    end

    UI.CreateLabel(area).SetText("Map/resource rules and detailed shortage mechanics are explained under How It Works.").SetColor("#B0BEC5");

    UI.CreateLabel(area).SetText("----------------------------------------");
    UI.CreateLabel(area).SetText("DEVELOP RESOURCE FACILITY");
    UI.CreateLabel(area).SetText("Choose a resource, select a territory, then confirm the build or upgrade. Full construction/refund rules are in How It Works.");

    local facilityBaseCost =
        math.max(
            1,
            math.floor(
                tonumber(
                    GetClientSetting(
                        "ResourceFacilityBaseCost",
                        100
                    )
                )
                or 100
            )
        );

    local facilityMaxLevel =
        math.max(
            1,
            math.floor(
                tonumber(
                    GetClientSetting(
                        "ResourceFacilityMaxLevel",
                        3
                    )
                )
                or 3
            )
        );

    local costParts = {
        "New facility: " .. tostring(facilityBaseCost * 3) .. " Commerce"
    };

    for level = 1, facilityMaxLevel - 1 do
        table.insert(
            costParts,
            "Level " .. tostring(level) .. " -> " .. tostring(level + 1)
                .. ": " .. tostring(facilityBaseCost * (level + 1)) .. " Commerce"
        );
    end

    UI.CreateLabel(area).SetText(
        "Development Costs | " .. table.concat(costParts, " | ")
    );
    UI.CreateLabel(area).SetText("Uranium facilities use the host's Uranium cost multiplier and are normally the most expensive strategic resource.").SetColor("#C792EA");

    local selectedResource = "Oil";
    local selectedLabel = UI.CreateLabel(area).SetText("Selected Resource: Oil").SetColor(ResourceUIColor("Oil"));

    local row = nil;
    local visibleIndex = 0;
    for _, resourceName in ipairs(RESOURCE_UI_TYPES) do
        if ResourceTypeAvailable(resourceName) then
            visibleIndex = visibleIndex + 1;
            if (visibleIndex - 1) % 3 == 0 then row = UI.CreateHorizontalLayoutGroup(area); end
            local captured = resourceName;
            UI.CreateButton(row)
                .SetText(captured)
                .SetOnClick(function()
                    selectedResource = captured;
                    selectedLabel.SetText("Selected Resource: " .. captured); selectedLabel.SetColor(ResourceUIColor(captured));
                end);
        end
    end

    local territoryStatus = UI.CreateLabel(area).SetText("");
    UI.CreateButton(area)
        .SetText("SELECT TERRITORY TO BUILD / UPGRADE")
        .SetOnClick(function()
            local chosenResource = selectedResource;
            territoryStatus.SetText("Select one of your territories on the map.");
            UI.InterceptNextTerritoryClick(function(terrDetails)
                if terrDetails == nil then return; end
                local territoryID = terrDetails.ID;
                local territoryName = terrDetails.Name or ("Territory "..tostring(territoryID));
                game.CreateDialog(function(root,setMaxSize,setScrollable,dialogGame,closeDialog)
                    setMaxSize(650,620); setScrollable(false,true);
                    local box=UI.CreateVerticalLayoutGroup(root);
                    UI.CreateLabel(box).SetText("RESOURCE DEVELOPMENT — "..territoryName).SetColor("#67D5FF");
                    UI.CreateLabel(box).SetText("Resources currently present on this territory:").SetColor("#BBBBBB");
                    local rdata=((Mod.PublicGameData or {}).globalEconomy or {}).resources or {};
                    local nodes=(rdata.territories or {})[territoryID] or (rdata.territories or {})[tostring(territoryID)] or {};
                    local any=false;
                    for _,rn in ipairs(RESOURCE_UI_TYPES) do
                        local lvl=tonumber(nodes[rn]) or 0;
                        if lvl>0 then any=true; UI.CreateLabel(box).SetText(rn.." — Lv."..tostring(lvl)).SetColor(ResourceUIColor(rn)); end
                    end
                    if not any then UI.CreateLabel(box).SetText("No developed resource facilities currently shown here.").SetColor("#888888"); end
                    local current=tonumber(nodes[chosenResource]) or 0;
                    local base=math.max(1,math.floor(tonumber(GetClientSetting("ResourceFacilityBaseCost",100)) or 100));
                    local maxLvl=math.max(1,math.floor(tonumber(GetClientSetting("ResourceFacilityMaxLevel",5)) or 5));
                    local nextLvl=current+1;
                    local cost=current<=0 and base*3 or base*nextLvl;
                    if chosenResource=="Uranium" then
                        local mult=math.max(100,math.min(500,tonumber(GetClientSetting("UraniumFacilityCostMultiplier",200)) or 200));
                        cost=math.max(1,math.floor(cost*mult/100+0.5));
                    end
                    UI.CreateLabel(box).SetText("Selected: "..chosenResource.." | Current Lv."..tostring(current).." → Lv."..tostring(nextLvl)).SetColor(ResourceUIColor(chosenResource));
                    if current>=maxLvl then
                        UI.CreateLabel(box).SetText("This facility is already at the host maximum level (Lv."..tostring(maxLvl)..").").SetColor("#FF8A80");
                    else
                        UI.CreateLabel(box).SetText("Cost: "..tostring(cost).." Commerce").SetColor("#FFD166");
                        UI.CreateButton(box).SetText("CONFIRM "..string.upper(chosenResource).." DEVELOPMENT").SetOnClick(function()
                            SafeSendGameCustomMessage(dialogGame,"Scheduling resource facility...",{type="buildResourceFacility",territoryID=territoryID,resource=chosenResource},function(result)
                                if result and result.message then UI.Alert(result.message); end; closeDialog();
                            end);
                        end);
                    end
                    UI.CreateButton(box).SetText("CANCEL").SetOnClick(function() closeDialog(); end);
                end);
            end);
            if UFMenuClose ~= nil then UFMenuClose(); end
        end);

    UI.CreateLabel(area).SetText("----------------------------------------");
    UI.CreateLabel(area).SetText("Recruiting Stations have moved to the Military tab.").SetColor("#D4AF37");

    if GetClientSetting("ResourceTradingEnabled", true) == true then
        UI.CreateLabel(area).SetText("----------------------------------------");
        UI.CreateLabel(area).SetText("RESOURCE MARKET & TRADE").SetColor("#64B5F6");
        UI.CreateLabel(area).SetText("Create resource-for-Commerce contracts, review incoming offers, and manage active trades. Detailed timing rules are in How It Works.");

        local tradeResource = "Oil";
        local tradeAmount = 1;
        local tradePrice = 25;
        local targetPlayerID = nil;
        local tradeLabel = UI.CreateLabel(area).SetText("Selected: 1 Oil @ 25 Commerce/unit | Partner: None").SetColor(ResourceUIColor("Oil"));

        local function RefreshTradeLabel()
            local targetName = targetPlayerID and GetPlayerName(game, targetPlayerID) or "None";
            tradeLabel.SetText(
                "Selected: " .. tostring(tradeAmount) .. " " .. tradeResource ..
                " @ " .. tostring(tradePrice) .. " Commerce/unit | Partner: " .. targetName
            );
            tradeLabel.SetColor(ResourceUIColor(tradeResource));
        end

        local rrow = nil;
        local resourceButtonIndex = 0;
        for _, resourceName in ipairs({"Oil","Gas","Iron","Food","Uranium","Rare Earths","Coal","Copper","Lithium"}) do
            if ResourceTypeAvailable(resourceName) then
                resourceButtonIndex = resourceButtonIndex + 1;
                if (resourceButtonIndex - 1) % 3 == 0 then
                    rrow = UI.CreateHorizontalLayoutGroup(area);
                end
                local captured = resourceName;
                UI.CreateButton(rrow).SetText(captured).SetOnClick(function()
                    tradeResource = captured; RefreshTradeLabel();
                end);
            end
        end

        local amountRow = UI.CreateHorizontalLayoutGroup(area);
        UI.CreateButton(amountRow).SetText("-1 UNIT").SetOnClick(function()
            tradeAmount = math.max(1, tradeAmount - 1); RefreshTradeLabel();
        end);
        UI.CreateButton(amountRow).SetText("+1 UNIT").SetOnClick(function()
            tradeAmount = math.min(10, tradeAmount + 1); RefreshTradeLabel();
        end);
        UI.CreateButton(amountRow).SetText("-5 COMMERCE").SetOnClick(function()
            tradePrice = math.max(0, tradePrice - 5); RefreshTradeLabel();
        end);
        UI.CreateButton(amountRow).SetText("+5 COMMERCE").SetOnClick(function()
            tradePrice = math.min(500, tradePrice + 5); RefreshTradeLabel();
        end);

        UI.CreateLabel(area).SetText("Search Trade Partner");
        local searchInput = CreateWideTextInput(area);
        local searchHost = UI.CreateVerticalLayoutGroup(area);

        local function RefreshResourcePartnerSearch()
            if not UI.IsDestroyed(searchHost) then UI.Destroy(searchHost); end
            searchHost = UI.CreateVerticalLayoutGroup(area);
            local query = string.lower(searchInput.GetText() or "");
            local matches = {};
            for playerID, player in pairs(game.Game.Players or {}) do
                if playerID ~= GetLocalPlayerID(game) and not player.Surrendered then
                    local name = GetPlayerName(game, playerID);
                    if query == "" or string.find(string.lower(name), query, 1, true) ~= nil then
                        table.insert(matches, {id=playerID, name=name});
                    end
                end
            end
            table.sort(matches, function(a,b) return a.name < b.name; end);
            local prow = nil;
            for index, item in ipairs(matches) do
                if index > 30 then break; end
                if (index - 1) % 3 == 0 then prow = UI.CreateHorizontalLayoutGroup(searchHost); end
                local capturedID = item.id;
                UI.CreateButton(prow)
                    .SetText(item.name)
                    .SetTextColor(GetPlayerUIColor(game, item.id, "#FFFFFF"))
                    .SetOnClick(function()
                        targetPlayerID = capturedID;
                        RefreshTradeLabel();
                    end);
            end
        end

        searchInput.SetOnValueChanged(function() RefreshResourcePartnerSearch(); end);
        RefreshResourcePartnerSearch();

        local tradeActionRow = UI.CreateHorizontalLayoutGroup(area);
        UI.CreateButton(tradeActionRow).SetText("SEND OFFER").SetOnClick(function()
            if targetPlayerID == nil then UI.Alert("Select a trade partner first."); return; end
            SafeSendGameCustomMessage(game,
                "Sending resource trade offer...",
                {type="proposeResourceTrade", targetPlayerID=targetPlayerID, resource=tradeResource, amount=tradeAmount, pricePerUnit=tradePrice},
                function(result)
                    if result ~= nil and result.message ~= nil then UI.Alert(result.message); end
                    ShowResourcesMenu(parent, game);
                end
            );
        end);
        UI.CreateButton(tradeActionRow).SetText("REQUEST RESOURCE").SetOnClick(function()
            if targetPlayerID == nil then UI.Alert("Select a resource partner first."); return; end
            SafeSendGameCustomMessage(game,
                "Sending resource request...",
                {type="requestResourceTrade", targetPlayerID=targetPlayerID, resource=tradeResource, amount=tradeAmount, pricePerUnit=tradePrice},
                function(result)
                    if result ~= nil and result.message ~= nil then UI.Alert(result.message); end
                    ShowResourcesMenu(parent, game);
                end
            );
        end);

        UI.CreateLabel(area).SetText("INCOMING OFFERS");
        local foundIncoming = false;
        for _, offer in ipairs(resources.pendingOffers or {}) do
            if offer.toPlayerID == GetLocalPlayerID(game) then
                foundIncoming = true;
                local offerID = offer.id;
                local offerRow = UI.CreateHorizontalLayoutGroup(area);
                local incomingText;
                if offer.kind == "request" then
                    incomingText = GetPlayerName(game, offer.fromPlayerID) .. " REQUESTS " .. tostring(offer.amount) .. " " .. offer.resource
                        .. " @ " .. tostring(offer.pricePerUnit) .. " Commerce/unit";
                else
                    incomingText = GetPlayerName(game, offer.fromPlayerID) .. " OFFERS " .. tostring(offer.amount) .. " " .. offer.resource
                        .. " @ " .. tostring(offer.pricePerUnit) .. " Commerce/unit";
                end
                UI.CreateLabel(offerRow).SetText(incomingText).SetColor(ResourceUIColor(offer.resource));
                UI.CreateButton(offerRow).SetText("ACCEPT").SetOnClick(function()
                    SafeSendGameCustomMessage(game, "Accepting resource trade...", {type="acceptResourceTrade", offerID=offerID}, function(result)
                        if result ~= nil and result.message ~= nil then UI.Alert(result.message); end
                        ShowResourcesMenu(parent, game);
                    end);
                end);
                UI.CreateButton(offerRow).SetText("REJECT").SetOnClick(function()
                    SafeSendGameCustomMessage(game, "Rejecting resource trade...", {type="rejectResourceTrade", offerID=offerID}, function(result)
                        if result ~= nil and result.message ~= nil then UI.Alert(result.message); end
                        ShowResourcesMenu(parent, game);
                    end);
                end);
            end
        end
        if not foundIncoming then UI.CreateLabel(area).SetText("No incoming resource offers."); end

        UI.CreateLabel(area).SetText("ACTIVE CONTRACTS");
        local foundActive = false;
        for tradeIndex, trade in ipairs(resources.activeTrades or {}) do
            if trade.fromPlayerID == GetLocalPlayerID(game) or trade.toPlayerID == GetLocalPlayerID(game) then
                foundActive = true;
                local capturedIndex = tradeIndex;
                local direction = trade.fromPlayerID == GetLocalPlayerID(game) and "EXPORT" or "IMPORT";
                local otherID = trade.fromPlayerID == GetLocalPlayerID(game) and trade.toPlayerID or trade.fromPlayerID;
                local activeRow = UI.CreateHorizontalLayoutGroup(area);
                UI.CreateLabel(activeRow).SetText(
                    direction .. " " .. tostring(trade.amount) .. " " .. trade.resource ..
                    " with " .. GetPlayerName(game, otherID) .. " @ " .. tostring(trade.pricePerUnit) ..
                    " | Last delivered: " .. tostring(trade.lastTransferred or 0)
                ).SetColor(ResourceUIColor(trade.resource));
                UI.CreateButton(activeRow).SetText("CANCEL").SetOnClick(function()
                    SafeSendGameCustomMessage(game, "Canceling resource contract...", {type="cancelResourceTrade", tradeIndex=capturedIndex}, function(result)
                        if result ~= nil and result.message ~= nil then UI.Alert(result.message); end
                        ShowResourcesMenu(parent, game);
                    end);
                end);
            end
        end
        if not foundActive then UI.CreateLabel(area).SetText("No active resource contracts."); end
    end
end


-- =========================================================
-- MILITARY COMMAND UI (UNITED FRONTIER)
-- =========================================================

function UFPrivateMilitaryState()
    return (Mod.PlayerGameData or {}).ownMilitary or {
        airbases={}, forwardAirstrips={}, missileSilos={}, powerGrids={}, cyberFacilities={}, airWings={}, specialForces={}, assetCondition={}
    };
end

local function UFCountTableEntries(tbl)
    local total=0; for _,v in pairs(tbl or {}) do if (tonumber(v) or 0)>0 then total=total+1; end end; return total;
end

local function UFShowTerritorySelector(parent, game, waitText, payloadBase)
    if IsViewerMode(game) then UI.Alert("Viewer mode cannot perform military purchases."); return; end
    UI.InterceptNextTerritoryClick(function(terrDetails)
        if terrDetails == nil then return; end
        local territoryID=terrDetails.ID;
        local territoryName=terrDetails.Name or ("Territory "..tostring(territoryID));
        game.CreateDialog(function(root,setMaxSize,setScrollable,dialogGame,closeDialog)
            setMaxSize(620,520); setScrollable(false,true);
            local box=UI.CreateVerticalLayoutGroup(root);
            local actionType=tostring((payloadBase or {}).type or "");
            local kind=tostring((payloadBase or {}).kind or "");
            local title="MILITARY DEVELOPMENT";
            local state=UFPrivateMilitaryState();
            local detail="";
            if actionType=="buildArmyRecruiter" then title="RECRUITING STATION"; detail="Build / upgrade Recruiting Station";
            elseif actionType=="purchaseAirWing" then title="AIR WING"; detail="Station an Air Wing at this Airbase";
            elseif actionType=="purchaseSpecialForces" then title="SPECIAL FORCES"; detail="Train Special Forces here";
            elseif actionType=="launchMissile" then title="MISSILE TARGET"; detail="Confirm strategic strike target";
            elseif actionType=="specialForcesMission" then title="SPECIAL FORCES OPERATION"; detail="Confirm covert mission target";
            elseif actionType=="airWingMission" then title="AIR WING MISSION"; detail="Confirm air-operation target";
            elseif actionType=="buildStrategicMilitary" then
                local names={Airbase="AIRBASE",ForwardAirstrip="FORWARD AIRSTRIP",MissileSilo="MISSILE SILO",PowerGrid="POWER GRID",CyberFacility="CYBER FACILITY"};
                title=names[kind] or "MILITARY STRUCTURE"; detail="Build / upgrade "..string.lower(title);
            end
            UI.CreateLabel(box).SetText(title.." — "..territoryName).SetColor(kind=="PowerGrid" and "#FFE066" or "#8FBF6F");
            UI.CreateLabel(box).SetText(detail).SetColor("#BBBBBB");
            UI.CreateLabel(box).SetText("Military infrastructure details are tracked in Military > Infrastructure. Border contact and ally/Faction intelligence determine foreign detail access.").SetColor("#62B6FF");
            local current=0;
            if actionType=="buildStrategicMilitary" then
                local map={Airbase="airbases",ForwardAirstrip="forwardAirstrips",MissileSilo="missileSilos",PowerGrid="powerGrids",CyberFacility="cyberFacilities"};
                current=tonumber((state[map[kind] or ""] or {})[territoryID]) or 0;
                UI.CreateLabel(box).SetText("Current Level: "..tostring(current).." | Next Level: "..tostring(current+1));
            elseif actionType=="purchaseAirWing" then
                UI.CreateLabel(box).SetText("Airbase Level: "..tostring(tonumber((state.airbases or {})[territoryID]) or 0).." | Air Wings here: "..tostring(tonumber((state.airWings or {})[territoryID]) or 0));
            end
            if actionType=="launchMissile" then
                UI.CreateLabel(box).SetText("Weapon: "..tostring((payloadBase or {}).weapon or "Conventional").." | Target: "..territoryName).SetColor("#FFB366");
            elseif actionType=="specialForcesMission" then
                UI.CreateLabel(box).SetText("Mission: "..tostring((payloadBase or {}).mission or "Recon").." | Target: "..territoryName).SetColor("#D995FF");
                UI.CreateLabel(box).SetText("The Special Forces unit remains based on your territory. The operation projects outward and reports SUCCESS, FAILED, DAMAGED, DISABLED, or DESTROYED.").SetColor("#BBBBBB");
            elseif actionType=="airWingMission" then
                UI.CreateLabel(box).SetText("Mission: "..tostring((payloadBase or {}).mission or "Recon").." | Target: "..territoryName).SetColor("#62B6FF");
                UI.CreateLabel(box).SetText("SAM coverage can INTERCEPT the mission. Results resolve on turn advancement.").SetColor("#BBBBBB");
            elseif actionType=="hqCyberDisrupt" then
                title="CYBER FACILITY OPERATION";
                UI.CreateLabel(box).SetText("Cyber Target: "..territoryName).SetColor("#D995FF");
                UI.CreateLabel(box).SetText("Result will report NO DAMAGE, DISABLED, or FAILED after confirmation.").SetColor("#BBBBBB");
            end
            UI.CreateButton(box).SetText("CONFIRM").SetOnClick(function()
                local payload={}; for k,v in pairs(payloadBase or {}) do payload[k]=v; end;
                if actionType=="launchMissile" then payload.targetTerritoryID=territoryID; else payload.territoryID=territoryID; end
                SafeSendGameCustomMessage(dialogGame,waitText,payload,function(result)
                    if result and result.message then UI.Alert(result.message); end; closeDialog();
                end);
            end);
            UI.CreateButton(box).SetText("CANCEL").SetOnClick(function() closeDialog(); end);
        end);
    end);
    if UFMenuClose ~= nil then UFMenuClose(); end
end

function ShowArmyRecruitersMenu(parent, game)
    local area = CreateContentArea(parent);
    local data = Mod.PublicGameData or {};
    local economy = data.globalEconomy or {};
    local ourID = GetLocalPlayerID(game);
    local nation = ourID ~= nil and (economy.nations or {})[ourID] or {};
    UI.CreateLabel(area).SetText("RECRUITING STATIONS").SetColor("#D4AF37");
    if IsViewerMode(game) then ShowViewerModeNotice(area,"Viewer mode: building/upgrading requires an active player."); return; end
    local recruiterCost=math.max(25,math.floor(tonumber(GetClientSetting("ArmyRecruiterBaseCost",250)) or 250));
    local recruiterMax=math.max(1,math.floor(tonumber(GetClientSetting("ArmyRecruiterMaxPerPlayer",3)) or 3));
    local recruiterArmies=math.max(1,math.floor(tonumber(GetClientSetting("ArmyRecruiterArmiesPerTurn",4)) or 4));
    UI.CreateLabel(area).SetText("Stations: "..tostring(nation.armyRecruiterCount or 0).."/"..tostring(recruiterMax).." | Output: "..tostring(recruiterArmies).." armies per level/turn");
    UI.CreateButton(area).SetText("SELECT TERRITORY TO BUILD / UPGRADE").SetOnClick(function()
        UFShowTerritorySelector(parent,game,"Building Recruiting Station...",{type="buildArmyRecruiter"});
    end);
    UI.CreateButton(area).SetText("BACK TO MILITARY").SetOnClick(function() ShowMilitaryMenu(parent,game); end);
end

local function UFAddStructureAction(area,parent,game,label,kind,cost,maxText,color)
    UI.CreateLabel(area).SetText(label).SetColor(color or "#FFFFFF");
    UI.CreateLabel(area).SetText("Base Cost: "..tostring(cost).." Commerce"..(maxText or ""));
    UI.CreateButton(area).SetText("SELECT TERRITORY TO BUILD / UPGRADE").SetOnClick(function()
        UFShowTerritorySelector(parent,game,"Developing "..label.."...",{type="buildStrategicMilitary",kind=kind});
    end);
end


function ShowMissileCommandMenu(parent, game)
    local area=CreateContentArea(parent);
    local state=UFPrivateMilitaryState();
    local silos=state.missileSilos or {};
    local stock=state.missileInventory or {};
    UI.CreateLabel(area).SetText("MISSILE COMMAND").SetColor("#FF7B7B");
    UI.CreateLabel(area).SetText("Select a silo, resupply missiles, then choose a weapon and target. Strikes resolve on turn advancement.").SetColor("#BBBBBB");
    local selectedSilo=nil;
    local selectedLabel=UI.CreateLabel(area).SetText("Selected Silo: None").SetColor("#FFD166");
    local found=false;
    for tid,lvl in pairs(silos) do
        found=true;
        local ntid=tonumber(tid) or tid;
        local td=game.Map and game.Map.Territories and game.Map.Territories[ntid] or nil;
        local inv=stock[ntid] or stock[tostring(ntid)] or {Conventional=0,EMP=0,Nuclear=0};
        local row=UI.CreateHorizontalLayoutGroup(area);
        UI.CreateButton(row).SetText((td and td.Name or tostring(ntid)).." | Lv."..tostring(lvl)).SetOnClick(function()
            selectedSilo=ntid; selectedLabel.SetText("Selected Silo: "..(td and td.Name or tostring(ntid)).." | Lv."..tostring(lvl));
        end);
        UI.CreateLabel(row).SetText("C:"..tostring(inv.Conventional or 0).."  EMP:"..tostring(inv.EMP or 0).."  N:"..tostring(inv.Nuclear or 0));
    end
    if not found then UI.CreateLabel(area).SetText("You do not control a Missile Silo yet.").SetColor("#888888"); end
    UI.CreateLabel(area).SetText("RESUPPLY").SetColor("#FFD166");
    local rr=UI.CreateHorizontalLayoutGroup(area);
    for _,weapon in ipairs({"Conventional","EMP","Nuclear"}) do
        local w=weapon;
        UI.CreateButton(rr).SetText("BUY "..string.upper(w)).SetOnClick(function()
            if selectedSilo==nil then UI.Alert("Select a Missile Silo first."); return; end
            SafeSendGameCustomMessage(game,"Resupplying missile...",{type="resupplyMissile",siloTerritoryID=selectedSilo,weapon=w},function(result)
                if result and result.message then UI.Alert(result.message); end; ShowMissileCommandMenu(parent,game);
            end);
        end);
    end
    UI.CreateLabel(area).SetText("LAUNCH STRIKE").SetColor("#FF7B7B");
    local lr=UI.CreateHorizontalLayoutGroup(area);
    for _,weapon in ipairs({"Conventional","EMP"}) do
        local w=weapon;
        UI.CreateButton(lr).SetText(string.upper(w)).SetOnClick(function()
            if selectedSilo==nil then UI.Alert("Select a Missile Silo first."); return; end
            UFShowTerritorySelector(parent,game,"Scheduling "..w.." missile strike...",{type="launchMissile",siloTerritoryID=selectedSilo,weapon=w});
        end);
    end
    UI.CreateLabel(area).SetText("NUCLEAR YIELD").SetColor("#FF5A5A");
    local nr=UI.CreateHorizontalLayoutGroup(area);
    for _,y in ipairs({"Low","Medium","High"}) do
        local yy=y;
        UI.CreateButton(nr).SetText(string.upper(yy)).SetOnClick(function()
            if selectedSilo==nil then UI.Alert("Select a Missile Silo first."); return; end
            local lvl=tonumber(silos[selectedSilo]) or 1; local need=(yy=="High" and 3) or (yy=="Medium" and 2) or 1;
            if lvl<need then UI.Alert(yy.." nuclear yield requires Missile Silo Lv."..tostring(need).." or higher."); return; end
            UFShowTerritorySelector(parent,game,"Scheduling Nuclear strike...",{type="launchMissile",siloTerritoryID=selectedSilo,weapon="Nuclear",yield=yy});
        end);
    end
    UI.CreateLabel(area).SetText("HOST DAMAGE SETTINGS").SetColor("#FFD166");
    UI.CreateLabel(area).SetText("Conventional: "..tostring(GetClientSetting("ConventionalMissileArmyDamagePercent",20)).."% armies | "..tostring(GetClientSetting("ConventionalMissileStructureDamagePercent",30)).."% infrastructure | "..tostring(GetClientSetting("ConventionalMissileCityDamagePercent",15)).."% city/territory").SetColor("#BBBBBB");
    UI.CreateLabel(area).SetText("Nuclear armies: Low "..tostring(GetClientSetting("NuclearLowDamagePercent",35)).."% | Medium "..tostring(GetClientSetting("NuclearMediumDamagePercent",55)).."% | High "..tostring(GetClientSetting("NuclearHighDamagePercent",75)).."% | Infrastructure "..tostring(GetClientSetting("NuclearStructureDamagePercent",70)).."%").SetColor("#BBBBBB");
    UI.CreateLabel(area).SetText("EMP base disable: "..tostring(GetClientSetting("EMPBaseDisableTurns",3)).." turn(s). Strike reports list troop, city/territory, resource, Recruiter, and strategic-infrastructure effects.").SetColor("#AAAAAA");
    local recent=state.hqRecentResults or {}; local shown=0;
    for i=math.max(1,#recent-7),#recent do
        local r=recent[i];
        if r and string.find(tostring(r.action or ""),"Missile Strike",1,true) then
            if shown==0 then UI.CreateLabel(area).SetText("RECENT MISSILE REPORTS").SetColor("#FFB366"); end
            shown=shown+1;
            local rc=(r.result=="INTERCEPTED" and "#79C7FF") or (r.result=="NO DAMAGE" and "#BBBBBB") or (r.result=="DESTROYED" and "#FF5A5A") or "#FFB366";
            UI.CreateLabel(area).SetText("Turn "..tostring(r.turn or "?").." | "..tostring(r.action or "Strike").." | "..tostring(r.result or "RESULT").."\n"..tostring(r.detail or "No additional detail")).SetColor(rc);
        end
    end
    if shown==0 then UI.CreateLabel(area).SetText("No missile strike reports yet.").SetColor("#777777"); end
    UI.CreateButton(area).SetText("BACK TO MILITARY").SetOnClick(function() ShowMilitaryMenu(parent,game); end);
end

function ShowMilitaryRepairsMenu(parent, game)
    local area=CreateContentArea(parent); local state=UFPrivateMilitaryState(); local turn=(((Mod.PublicGameData or {}).globalEconomy or {}).currentEconomyTurn) or 1;
    UI.CreateLabel(area).SetText("DAMAGE & REPAIRS").SetColor("#FFD166");
    UI.CreateLabel(area).SetText("Every strategic installation has 10 HP. 10/10 = full health; 0/10 = destroyed. EMP can temporarily disable an installation without removing HP.").SetColor("#BBBBBB");
    local mapping={Airbase=state.airbases,ForwardAirstrip=state.forwardAirstrips,MissileSilo=state.missileSilos,PowerGrid=state.powerGrids,CyberFacility=state.cyberFacilities}; local shown=0;
    local function row(kind,tid,lvl)
        local c=(state.assetCondition or {})[tostring(kind)..":"..tostring(tid)] or {}; local damage=tonumber(c.damage) or 0; local health=math.max(0,10-math.ceil(damage/10)); local disabled=(tonumber(c.disabledUntil) or 0)>turn; if damage<=0 and not disabled then return; end; shown=shown+1;
        local td=game.Map and game.Map.Territories and game.Map.Territories[tid] or nil; local status=disabled and "DISABLED" or (health<=0 and "DESTROYED" or "DAMAGED"); local color=disabled and "#FFB366" or "#FF7B7B";
        local g=UI.CreateHorizontalLayoutGroup(area); UI.CreateLabel(g).SetText(kind.." | "..(td and td.Name or tostring(tid)).." | "..status.." | "..tostring(health).."/10 HP").SetColor(color).SetFlexibleWidth(1);
        if health>0 then UI.CreateButton(g).SetText("REPAIR TO 10/10").SetOnClick(function() SafeSendGameCustomMessage(game,"Repairing asset...",{type="repairMilitaryAsset",kind=kind,territoryID=tid},function(r) if r and r.message then UI.Alert(r.message); end; ShowMilitaryRepairsMenu(parent,game); end); end); end
    end
    for kind,tbl in pairs(mapping) do for tid,lvl in pairs(tbl or {}) do row(kind,tonumber(tid) or tid,lvl); end end
    if shown==0 then UI.CreateLabel(area).SetText("All strategic infrastructure is currently 10/10 HP and operational.").SetColor("#79D279"); end
    UI.CreateButton(area).SetText("BACK TO MILITARY").SetOnClick(function() ShowMilitaryMenu(parent,game); end);
end

function ShowMilitaryMenu(parent, game)
    local area=CreateContentArea(parent); local state=UFPrivateMilitaryState(); local intel=(Mod.PlayerGameData or {}).strategicIntel or {};
    local data=Mod.PublicGameData or {}; local economy=data.globalEconomy or {}; local ourID=GetLocalPlayerID(game); local standing=game.LatestStanding;
    UI.CreateLabel(area).SetText("MILITARY INFRASTRUCTURE").SetColor("#8FBF6F");
    UI.CreateLabel(area).SetText("Infrastructure details follow the same private-intelligence model as Resources. Enemy Air Wings and Special Forces use normal fog visibility and are no longer globally visible.").SetColor("#BBBBBB");
    local filterRow=UI.CreateHorizontalLayoutGroup(area); local filters={{"My Infrastructure","MY INFRASTRUCTURE"},{"Neighbors","NEIGHBORS"},{"Shared Intel","ALLY / FACTION"},{"All Known","ALL KNOWN"}};
    for _,fd in ipairs(filters) do local key,label=fd[1],fd[2]; UI.CreateButton(filterRow).SetText((MilitaryIntelFilter==key and "▶ " or "")..label).SetOnClick(function() MilitaryIntelFilter=key; ShowMilitaryMenu(parent,game); end); end
    local function hp(kind,tid)
        local c=(state.assetCondition or {})[tostring(kind)..":"..tostring(tid)] or {}; return math.max(0,10-math.ceil((tonumber(c.damage) or 0)/10));
    end
    local function addRow(kind,tid,level,count,color,note,upgradeSpec,ownerState,healthOverride)
        local td=game.Map and game.Map.Territories and game.Map.Territories[tid] or nil; local row=UI.CreateHorizontalLayoutGroup(area); local useState=ownerState or state;
        local c=(useState.assetCondition or {})[tostring(kind)..":"..tostring(tid)] or {}; local health=healthOverride~=nil and tonumber(healthOverride) or math.max(0,10-math.ceil((tonumber(c.damage) or 0)/10));
        local txt=(td and td.Name or tostring(tid)).." | "..kind..(level and (" Lv."..tostring(level)) or "")..(count and count>1 and (" x"..tostring(count)) or "").." | "..tostring(health).."/10 HP"..(note and (" | "..note) or "");
        UI.CreateLabel(row).SetText(txt).SetColor(color or "#DDEEFF"); local captured=tid;
        UI.CreateButton(row).SetText("SHOW").SetOnClick(function()
            if UFMenuClose then UFMenuClose(); end; game.HighlightTerritories({captured}); game.CreateDialog(function(backRoot,setMaxSize,setScrollable,dialogGame,closeDialog)
                setMaxSize(330,130); setScrollable(false); UI.CreateLabel(backRoot).SetText("Location highlighted."); UI.CreateButton(backRoot).SetText("← BACK").SetOnClick(function() closeDialog(); dialogGame.CreateDialog(function(r,sm,ss,g,c) sm(900,760); ss(true); local old=UFMenuClose; UFMenuClose=c; ShowMilitaryMenu(r,g); UFMenuClose=old; end); end);
            end);
        end);
        if upgradeSpec then if upgradeSpec.maxed then UI.CreateLabel(row).SetText("MAX").SetColor("#79D279"); else local nl=(tonumber(level) or 0)+1; local cost=(tonumber(upgradeSpec.baseCost) or 250)*nl; UI.CreateButton(row).SetText("UPGRADE L"..tostring(nl).." — "..tostring(cost)).SetOnClick(function() SafeSendGameCustomMessage(game,"Upgrading "..kind.."...",{type="buildStrategicMilitary",kind=upgradeSpec.kind,territoryID=captured},function(r) if r and r.message then UI.Alert(r.message); end; ShowMilitaryMenu(parent,game); end); end); end end
        if health<10 and ownerState==nil then UI.CreateButton(row).SetText("REPAIR TO 10/10").SetOnClick(function() SafeSendGameCustomMessage(game,"Repairing asset...",{type="repairMilitaryAsset",kind=kind,territoryID=captured},function(r) if r and r.message then UI.Alert(r.message); end; ShowMilitaryMenu(parent,game); end); end); end
    end
    local maxes={Airbase=GetClientSetting("AirbaseMaxLevel",3),ForwardAirstrip=1,MissileSilo=GetClientSetting("MissileSiloMaxLevel",3),PowerGrid=3,CyberFacility=GetClientSetting("CyberFacilityMaxLevel",3)};
    local costs={Airbase=GetClientSetting("AirbaseBaseCost",350),ForwardAirstrip=GetClientSetting("ForwardAirstripBaseCost",175),MissileSilo=GetClientSetting("MissileSiloBaseCost",500),PowerGrid=GetClientSetting("PowerGridBaseCost",300),CyberFacility=GetClientSetting("CyberFacilityBaseCost",450)};
    if MilitaryIntelFilter=="My Infrastructure" or MilitaryIntelFilter=="All Known" then
        UI.CreateLabel(area).SetText("YOUR INFRASTRUCTURE").SetColor("#8FD694"); local shown=0;
        for kind,mapname in pairs({Airbase="airbases",ForwardAirstrip="forwardAirstrips",MissileSilo="missileSilos",PowerGrid="powerGrids",CyberFacility="cyberFacilities"}) do for tid,lvl in pairs(state[mapname] or {}) do shown=shown+1; addRow(kind,tonumber(tid) or tid,lvl,nil,kind=="PowerGrid" and "#FFE066" or "#8FD694",nil,{kind=kind,baseCost=costs[kind],maxed=(tonumber(lvl) or 0)>=(tonumber(maxes[kind]) or 1)}); end end
        if shown==0 then UI.CreateLabel(area).SetText("No strategic infrastructure constructed yet.").SetColor("#888888"); end
    end
    if MilitaryIntelFilter~="My Infrastructure" then
        UI.CreateLabel(area).SetText("KNOWN FOREIGN INFRASTRUCTURE").SetColor("#FFD166"); local shown=0;
        for _,item in pairs(intel.knownMilitary or {}) do
            local reason=tostring(item.reason or "Known");
            local group=(reason=="Shared Intelligence" and "Shared Intel") or (reason=="Border" and "Neighbors") or "All Known";
            local include=(MilitaryIntelFilter=="All Known") or (MilitaryIntelFilter==group);
            if include then shown=shown+1; addRow(tostring(item.kind),item.territoryID,item.level,item.count,"#62B6FF",reason,nil,{},item.health); end
        end
        if shown==0 then UI.CreateLabel(area).SetText("No foreign infrastructure matches this filter.").SetColor("#888888"); end
    end
    UI.CreateLabel(area).SetText("----------------------------------------"); UI.CreateLabel(area).SetText("BUILD & MANAGE").SetColor("#FFFFFF");
    UI.CreateButton(area).SetText("RECRUITING STATIONS").SetOnClick(function() ShowArmyRecruitersMenu(parent,game); end);
    if GetClientSetting("PowerGridEnabled",true) then UFAddStructureAction(area,parent,game,"POWER / ELECTRICAL GRID","PowerGrid",GetClientSetting("PowerGridBaseCost",300)," | required for Airbases, Missile Silos & Cyber Facilities","#FFE066"); end
    if GetClientSetting("AirbasesEnabled",true) then UFAddStructureAction(area,parent,game,"AIRBASE","Airbase",GetClientSetting("AirbaseBaseCost",350)," | requires Grid","#62B6FF"); end
    if GetClientSetting("ForwardAirstripsEnabled",true) then UFAddStructureAction(area,parent,game,"FORWARD AIRSTRIP","ForwardAirstrip",GetClientSetting("ForwardAirstripBaseCost",175),"","#82CFFF"); end
    if GetClientSetting("MissileSilosEnabled",true) then UFAddStructureAction(area,parent,game,"MISSILE SILO","MissileSilo",GetClientSetting("MissileSiloBaseCost",500)," | requires Grid","#FF7B7B"); UI.CreateButton(area).SetText("MISSILE COMMAND / TARGETING").SetOnClick(function() ShowMissileCommandMenu(parent,game); end); end
    if GetClientSetting("CyberFacilitiesEnabled",true) then
        UFAddStructureAction(area,parent,game,"CYBER FACILITY","CyberFacility",GetClientSetting("CyberFacilityBaseCost",450)," | requires Grid","#C792EA");
        UI.CreateButton(area).SetText("LAUNCH CYBER DISRUPTION").SetOnClick(function() UFShowTerritorySelector(parent,game,"Launching cyber operation...",{type="hqCyberDisrupt"}); end);
    end
    if GetClientSetting("AirWingsEnabled",true) then UI.CreateButton(area).SetText("PURCHASE AIR WING").SetOnClick(function() UFShowTerritorySelector(parent,game,"Purchasing Air Wing...",{type="purchaseAirWing"}); end); end
    if GetClientSetting("SpecialForcesEnabled",true) then UI.CreateButton(area).SetText("TRAIN SPECIAL FORCES").SetOnClick(function() UFShowTerritorySelector(parent,game,"Training Special Forces...",{type="purchaseSpecialForces"}); end); end
    UI.CreateLabel(area).SetText("CORE RULE: Recruiters remain fully usable even if Air Wings, Special Forces, Cyber, Airbases, Silos, or other optional systems are disabled by the host.").SetColor("#79D279");
end


function BuildMainTabs(
    tabsHost,
    contentHost,
    game
)

    if MainTabsArea ~= nil and not UI.IsDestroyed(MainTabsArea) then
        UI.Destroy(MainTabsArea);
    end

    MainTabsArea = UI.CreateVerticalLayoutGroup(tabsHost);
    local tabs = {};

    local function QueueTab(key, label, buttonColor, textColor, onClick)
        table.insert(tabs, {
            key = key,
            label = label,
            buttonColor = buttonColor,
            textColor = textColor,
            onClick = onClick
        });
    end

    QueueTab("overview", "Overview", "#4169E1", "#FFFFFF", function()
        ShowOverview(contentHost, game);
    end);

    if PlayerTabVisibility.markets ~= false then
        QueueTab("markets", "Markets", "#2F6F8F", "#FFFFFF", function()
            ShowMarketsMenu(contentHost, game);
        end);
    end

    if PlayerTabVisibility.resources ~= false and GetClientSetting("ResourcesEnabled", true) then
        QueueTab("resources", "Resources", "#2E8B57", "#FFFFFF", function()
            ShowResourcesMenu(contentHost, game);
        end);
    end

    if PlayerTabVisibility.military ~= false then
        QueueTab("military", "Military", "#556B2F", "#FFFFFF", function()
            ShowMilitaryMenu(contentHost, game);
        end);
    end

    QueueTab("diplomacy", "Diplomacy", "#FF7D00", "#FFFFFF", function()
        ShowDiplomacyMenu(contentHost, game);
    end);

    if PlayerTabVisibility.unitedNations ~= false and GetClientSetting("UnitedNationsEnabled", true) then
        QueueTab("unitedNations", "United Nations", "#2F4F4F", "#FFFFFF", function()
            ShowUnitedNationsMenu(contentHost, game);
        end);
    end

    if PlayerTabVisibility.howItWorks ~= false then
        QueueTab("help", "How It Works", "#606060", "#FFFFFF", function()
            ShowHowItWorks(contentHost);
        end);
    end

    QueueTab("customize", "Customize Tabs", "#455A64", "#FFFFFF", function()
        ShowCustomizeTabs(contentHost, game, tabsHost);
    end);

    local row = nil;
    for index, tab in ipairs(tabs) do
        if (index - 1) % 2 == 0 then
            row = UI.CreateHorizontalLayoutGroup(MainTabsArea);
        end

        local tabButton = UI.CreateButton(row)
            .SetText(MainTabText(tab.key, tab.label))
            .SetColor(tab.buttonColor)
            .SetTextColor(tab.textColor)
            .SetFlexibleWidth(1)
            .SetPreferredHeight(40)
            .SetOnClick(function()
                ActiveMainTab = tab.key;
                BuildMainTabs(tabsHost, contentHost, game);
                tab.onClick();
            end);

        if ActiveMainTab == tab.key then
            tabButton.SetPreferredHeight(44);
        end
    end
end


function Client_PresentMenuUI(
    rootParent,
    setMaxSize,
    setScrollable,
    game,
    close
)

    ContentArea = nil;
    MainTabsArea = nil;
    ActiveMainTab = "overview";
    UFMenuClose = close;

    setMaxSize(
        1100,
        760
    );

    setScrollable(
        false,
        true
    );

    local main =
        UI.CreateVerticalLayoutGroup(
            rootParent
        );

    local tabsHost =
        UI.CreateVerticalLayoutGroup(
            main
        );

    local contentHost =
        UI.CreateVerticalLayoutGroup(
            main
        );

    BuildMainTabs(
        tabsHost,
        contentHost,
        game
    );

    if IsNationalSetupComplete(
        game
    ) then

        ShowOverview(
            contentHost,
            game
        );

    else

        ShowNationalSetup(
            contentHost,
            game
        );

    end
end


function ClearContent()

    if ContentArea ~= nil then

        if not UI.IsDestroyed(
            ContentArea
        ) then

            UI.Destroy(
                ContentArea
            );
        end

        ContentArea = nil;
    end
end


function CreateContentArea(parent)

    ClearContent();

    ContentArea =
        UI.CreateVerticalLayoutGroup(
            parent
        );

    return ContentArea;
end


function TradePairKey(
    playerA,
    playerB
)

    local a =
        tostring(playerA);

    local b =
        tostring(playerB);

    if a < b then
        return a .. "|" .. b;
    else
        return b .. "|" .. a;
    end
end


function GetCooldownTurnsRemaining(
    data,
    playerA,
    playerB
)

    local cooldowns =
        data.cooldowns or {};

    local currentTurn =
        data.tradeTurn or 0;

    local key =
        TradePairKey(
            playerA,
            playerB
        );

    local untilTurn =
        cooldowns[key];

    if untilTurn == nil then
        return 0;
    end

    local remaining =
        untilTurn
        - currentTurn;

    if remaining < 0 then
        remaining = 0;
    end

    return remaining;
end


function CountOurActiveAgreements(
    data,
    game
)

    local count = 0;

    for _, agreement
        in pairs(
            data.activeAgreements
            or {}
        ) do

        if agreement.player1
            == GetLocalPlayerID(game)

            or agreement.player2
            == GetLocalPlayerID(game) then

            count =
                count + 1;
        end
    end

    return count;
end


function GetPlayerName(
    game,
    playerID
)

    if game == nil or game.Game == nil or playerID == nil then
        return "No Active Player";
    end

    local player =
        game.Game.Players[
            playerID
        ];

    if player == nil then
        return "Unknown Player";
    end

    return player.DisplayName(
        nil,
        false
    );
end


function GetPlayerIncome(
    game,
    playerID
)

    if game == nil or game.Game == nil or playerID == nil then
        return 0;
    end

    local player =
        game.Game.Players[
            playerID
        ];

    if player == nil then
        return 0;
    end

    local info =
        player.Income(
            0,
            game.LatestStanding,
            true,
            false
        );

    if info == nil then
        return 0;
    end

    return info.Total or 0;
end
function GetPlayerGold(
    game,
    playerID
)

    if game == nil or playerID == nil or game.LatestStanding == nil then
        return 0;
    end


    return game.LatestStanding.NumResources(
        playerID,
        WL.ResourceType.Gold
    );

end

function CalculateTradeBonus(
    partnerIncome
)

    local percent =
        ClientTradeBonusPercent();

    return math.floor(
        (
            partnerIncome
            * (
                percent / 100
            )
        )
        + 0.5
    );
end


function CountOutsideProjectInvestors(
    project
)

    local count = 0;

    for _, investment
        in pairs(
            project.investments
            or {}
        ) do

        if investment.playerID
            ~= project.creatorID then

            count =
                count + 1;
        end
    end

    return count;
end


function GetOurProjectInvestment(
    project,
    game
)

    local amount = 0;

    for _, investment
        in pairs(
            project.investments
            or {}
        ) do

        if investment.playerID
            == GetLocalPlayerID(game) then

            amount =
                investment.amount
                or 0;

            break;
        end
    end

    return amount;
end


function GetEventCategory(
    eventType
)

    if eventType
        == "agreement_signed" then

        return "signed";
    end

    if eventType
        == "proposal_sent" then

        return "proposals";
    end

    if eventType
        == "proposal_rejected" then

        return "rejected";
    end

    if eventType
        == "agreement_canceled"

        or eventType
        == "agreement_ended"

        or eventType
        == "agreement_replaced" then

        return "canceled";
    end

    if eventType
        == "investment_created"

        or eventType
        == "investment_made"

        or eventType
        == "investment_funded" then

        return "investments";
    end

    if eventType
        == "investment_success" then

        return "success";
    end

    if eventType
        == "investment_failure"

        or eventType
        == "investment_expired" then

        return "failed";
    end

    if eventType
        == "ai_concern" then

        return "ai";
    end

    return "other";
end


function EventPassesFilter(
    eventType,
    filter
)

    if filter == "all" then
        return true;
    end

    return GetEventCategory(
        eventType
    ) == filter;
end
function ShowOverview(
    parent,
    game
)

    local area =
        CreateContentArea(
            parent
        );


    local data =
        Mod.PublicGameData or {};

    local economy = data.globalEconomy or {};


    local activeCount =
        CountOurActiveAgreements(
            data,
            game
        );


    local incomingCount = 0;
    local outgoingCount = 0;
    local totalBonus = 0;


    for _, proposal
        in pairs(
            data.pendingProposals
            or {}
        ) do


        if proposal.toPlayerID
            == GetLocalPlayerID(game) then

            incomingCount =
                incomingCount + 1;


        elseif proposal.fromPlayerID
            == GetLocalPlayerID(game) then

            outgoingCount =
                outgoingCount + 1;
        end
    end


    for _, agreement
        in pairs(
            data.activeAgreements
            or {}
        ) do


        local otherID = nil;


        if agreement.player1
            == GetLocalPlayerID(game) then

            otherID =
                agreement.player2;


        elseif agreement.player2
            == GetLocalPlayerID(game) then

            otherID =
                agreement.player1;
        end


        if otherID ~= nil then


            totalBonus =
                totalBonus
                + CalculateTradeBonus(
                    GetPlayerIncome(
                        game,
                        otherID
                    )
                );
        end
    end


    local openProjects = 0;
    local activeProjects = 0;


    for _, project
        in pairs(
            data.investmentProjects
            or {}
        ) do


        if project.status
            == "funding" then

            openProjects =
                openProjects + 1;


        elseif project.status
            == "active" then

            activeProjects =
                activeProjects + 1;
        end
    end


    -- =====================================================
    -- NATIONAL SETUP / ECONOMIC REFORM
    -- =====================================================

    local nation =
        GetOurNationState(
            game
        );


    if nation == nil
        or nation.setupComplete ~= true then


        UI.CreateLabel(area)
            .SetText(
                "NATIONAL SETUP REQUIRED"
            ).SetColor("#FFD166");


        UI.CreateLabel(area)
            .SetText(
                "Complete your national economic setup to establish your ideology, economic strategy, tax policy, and flagship company."
            );


        UI.CreateButton(area)
            .SetText(
                "OPEN NATIONAL SETUP"
            )
            .SetOnClick(function()

                ShowNationalSetup(
                    parent,
                    game
                );

            end);


        UI.CreateLabel(area)
            .SetText(
                "----------------------------------------"
            );


    else


        UI.CreateLabel(area)
            .SetText(
                "YOUR NATION"
            ).SetColor("#7FB3FF");


        UI.CreateLabel(area)
            .SetText(
                "Ideology: " ..
                tostring(
                    nation.ideology
                    or "Unknown"
                )
            );


        UI.CreateLabel(area)
            .SetText(
                "Economic Strategy: " ..
                tostring(
                    nation.economicStrategy
                    or "Unknown"
                )
            );


        UI.CreateLabel(area)
            .SetText(
                "Tax Policy: " ..
                tostring(
                    nation.taxPolicy
                    or "Standard"
                )
            );


        UI.CreateLabel(area)
            .SetText(
                "Flagship Company: " ..
                tostring(
                    nation.flagshipCompanyName
                    or "Unknown"
                )
            );


        UI.CreateLabel(area)
            .SetText(
                "Company Strategy: " ..
                tostring(
                    nation.companyStrategy
                    or "Unknown"
                )
            );


        -- =================================================
        -- ACTIVE ECONOMIC REFORM
        -- =================================================

        if nation.reformActive == true then


            local economyData =
                (
                    Mod.PublicGameData
                    or {}
                ).globalEconomy
                or {};


            local currentTurn =
                economyData.currentEconomyTurn
                or 1;


            local reformEndTurn =
                nation.reformEndTurn
                or currentTurn;


            local turnsRemaining =
                reformEndTurn
                - currentTurn;


            if turnsRemaining < 0 then

                turnsRemaining =
                    0;

            end


            UI.CreateLabel(area)
                .SetText(
                    "ECONOMIC REFORM IN PROGRESS"
                );


            UI.CreateLabel(area)
                .SetText(
                    "Temporary Reform Penalty: -15% Economic Confidence"
                );


            UI.CreateLabel(area)
                .SetText(
                    "Turns Remaining: " ..
                    tostring(
                        turnsRemaining
                    )
                );


            UI.CreateLabel(area)
                .SetText(
                    "Your new policies remain in effect after reform. The temporary penalty disappears when the reform period ends."
                );


        else


            UI.CreateButton(area)
                .SetText(
                    "VIEW / REFORM NATIONAL POLICY"
                )
                .SetOnClick(function()

                    ShowNationalSetup(
                        parent,
                        game
                    );

                end);

        end


        if GetClientSetting(
            "PlayerAIManagerEnabled",
            true
        ) == true then

            UI.CreateButton(area)
                .SetText(
                    "AI MANAGER"
                )
                .SetOnClick(function()

                    ShowAIManagerMenu(
                        parent,
                        game
                    );

                end);

        end

        UI.CreateLabel(area)
            .SetText(
                "----------------------------------------"
            );

    end


    -- =====================================================
    -- NATIONAL COMMAND DASHBOARD
    -- =====================================================
    local ourID = GetLocalPlayerID(game);
    if ourID ~= nil and nation ~= nil and nation.setupComplete == true then
        UI.CreateLabel(area).SetText("COMMAND DASHBOARD").SetColor("#67D5FF");
        local commerce = GetPlayerGold(game, ourID) or 0;
        local income = GetPlayerIncome(game, ourID) or 0;
        local readiness = tonumber(nation.resourceMilitaryReadiness) or 100;
        local unrest=math.max(0,math.min(100,tonumber(nation.resourceUnrest) or 0));
        local unrestCommercePenalty=(unrest>=80 and 20) or (unrest>=60 and 12) or (unrest>=40 and 7) or (unrest>=20 and 3) or 0;
        local unrestRecruiterPenalty=(unrest>=80 and 35) or (unrest>=60 and 20) or (unrest>=40 and 10) or (unrest>=20 and 5) or 0;
        UI.CreateLabel(area).SetText("Commerce: "..tostring(commerce).." | Income: +"..tostring(income).." | Military Readiness: "..tostring(math.floor(readiness+0.5)).."% | Unrest: "..tostring(unrest).."/100").SetColor("#E0E0E0");
        UI.CreateLabel(area).SetText("Unrest Effects: Commerce -"..tostring(unrestCommercePenalty).."% | Recruiter Production -"..tostring(unrestRecruiterPenalty).."%").SetColor(unrest>=60 and "#FF7B7B" or (unrest>=20 and "#FFB366" or "#8FD694"));

        if nation.aiManagerEnabled == true then
            UI.CreateLabel(area).SetText(
                "AI Manager ACTIVE | Reserved Budget: "..tostring(nation.aiManagerTurnBudget or nation.aiManagerBudget or 0)..
                " | Spent: "..tostring(nation.aiManagerSpentThisTurn or 0)..
                " | Remaining: "..tostring(nation.aiManagerBudgetRemaining or 0)
            ).SetColor("#FFD166");
        end

        local diplomacy = economy.diplomacy or {};
        local allianceNames = {};
        for _,alliance in pairs(diplomacy.alliances or {}) do
            if alliance and alliance.active == true and (alliance.player1 == ourID or alliance.player2 == ourID) then
                local other = alliance.player1 == ourID and alliance.player2 or alliance.player1;
                local suffix = alliance.sharedIntelligence == true and " [Intel]" or "";
                table.insert(allianceNames,GetPlayerName(game,other)..suffix);
            end
        end
        table.sort(allianceNames);
        local factionID=(diplomacy.playerFaction or {})[ourID];
        local faction=factionID and (diplomacy.factions or {})[factionID] or nil;
        if #allianceNames>0 or faction~=nil then
            local allianceText=#allianceNames>0 and table.concat(allianceNames,", ") or "None";
            local factionText=faction and tostring(faction.name or ("Faction "..tostring(factionID))) or "None";
            UI.CreateLabel(area).SetText("Allies: "..allianceText.." | Faction: "..factionText).SetColor("#62B6FF");
        else
            UI.CreateLabel(area).SetText("Allies: None | Faction: None").SetColor("#9E9E9E");
        end

        local warNames={};
        for _,relationship in pairs(diplomacy.relationships or {}) do
            if relationship and relationship.status=="war" and (relationship.player1==ourID or relationship.player2==ourID) then
                local other=relationship.player1==ourID and relationship.player2 or relationship.player1;
                table.insert(warNames,GetPlayerName(game,other));
            end
        end
        table.sort(warNames);
        if #warNames>0 then
            UI.CreateLabel(area).SetText("WAR STATUS: At war with "..table.concat(warNames,", ").." | War Economy Priority").SetColor("#FF7B7B");
        else
            UI.CreateLabel(area).SetText("WAR STATUS: At Peace").SetColor("#8FD694");
        end

        local shortageParts={};
        for _,rn in ipairs(RESOURCE_UI_TYPES or {}) do
            local amount=tonumber((nation.resourceShortages or {})[rn]) or 0;
            if amount>0 then table.insert(shortageParts,rn.." -"..tostring(amount)); end
        end
        if #shortageParts>0 then
            UI.CreateLabel(area).SetText("RESOURCE ALERT: "..table.concat(shortageParts," | ")).SetColor("#FF6B6B");
        else
            UI.CreateLabel(area).SetText("Resources: No uncovered shortages").SetColor("#8FD694");
        end

        local ownMilitary=(Mod.PlayerGameData or {}).ownMilitary or {};
        local function countMap(tbl) local n=0; for _,v in pairs(tbl or {}) do if (tonumber(v) or 0)>0 then n=n+1; end end return n; end
        local airWingCount=0; for _,v in pairs(ownMilitary.airWings or {}) do airWingCount=airWingCount+(tonumber(v) or 0); end
        local sfCount=0; for _,v in pairs(ownMilitary.specialForces or {}) do sfCount=sfCount+(tonumber(v) or 0); end
        UI.CreateLabel(area).SetText(
            "Military | Airbases: "..tostring(countMap(ownMilitary.airbases))..
            " | Cyber: "..tostring(countMap(ownMilitary.cyberFacilities))..
            " | Silos: "..tostring(countMap(ownMilitary.missileSilos))..
            " | Grids: "..tostring(countMap(ownMilitary.powerGrids))..
            " | Air Wings: "..tostring(airWingCount).." | Special Forces: "..tostring(sfCount)
        ).SetColor("#A5D6A7");

        local market=economy.market or {};
        local flagship=nil;
        for _,company in pairs(market.companies or {}) do if company.ownerPlayerID==ourID then flagship=company; break; end end
        if flagship~=nil then
            local cp=tonumber(flagship.currentPrice or flagship.startingPrice) or 0;
            local pp=tonumber(flagship.previousPrice) or cp;
            local pct=pp>0 and ((cp-pp)/pp*100) or 0;
            local sign=pct>=0 and "+" or "";
            UI.CreateLabel(area).SetText(
                "Flagship: "..tostring(flagship.name or nation.flagshipCompanyName or "Company")..
                " | "..string.format("%.2f",cp).." Commerce/share | "..sign..string.format("%.1f",pct).."% last turn"..
                " | Bought: "..tostring(flagship.buyVolumeThisTurn or 0).." | Sold: "..tostring(flagship.sellVolumeThisTurn or 0)
            ).SetColor(pct>=0 and "#81C784" or "#EF9A9A");
        end

        local quick=UI.CreateHorizontalLayoutGroup(area);
        UI.CreateButton(quick).SetText("MILITARY").SetOnClick(function() ShowMilitaryMenu(parent,game); end);
        UI.CreateButton(quick).SetText("RESOURCES").SetOnClick(function() ShowResourcesMenu(parent,game); end);
        UI.CreateButton(quick).SetText("DIPLOMACY").SetOnClick(function() ShowDiplomacyMenu(parent,game); end);
        UI.CreateButton(quick).SetText("MARKETS").SetOnClick(function() ShowMarketsMenu(parent,game); end);
        UI.CreateLabel(area).SetText("----------------------------------------");
    end

    -- =====================================================
    -- TRADE ECONOMY
    -- =====================================================

    UI.CreateLabel(area)
        .SetText(
            "TRADE & INVESTMENT ECONOMY"
        ).SetColor("#64B5F6");


    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );


    UI.CreateLabel(area)
        .SetText(
            "YOUR TRADE ECONOMY"
        ).SetColor("#81C784");


    UI.CreateLabel(area)
        .SetText(
            "Active Agreements: " ..
            tostring(
                activeCount
            ) ..
            " / " ..
            tostring(
                ClientMaxAgreements()
            )
        );


    UI.CreateLabel(area)
        .SetText(
            "Incoming Proposals: " ..
            tostring(
                incomingCount
            )
        );


    UI.CreateLabel(area)
        .SetText(
            "Outgoing Proposals: " ..
            tostring(
                outgoingCount
            )
        );


    UI.CreateLabel(area)
        .SetText(
            "Current Trade Bonus: +" ..
            tostring(
                totalBonus
            ) ..
            " Commerce/turn"
        );


    UI.CreateLabel(area)
        .SetText(
            "Trade Benefit Rate: " ..
            tostring(
                ClientTradeBonusPercent()
            ) ..
            "% of partner Commerce income"
        );


    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );


    -- =====================================================
    -- INVESTMENTS
    -- =====================================================

    UI.CreateLabel(area)
        .SetText(
            "GLOBAL INVESTMENT MARKET"
        ).SetColor("#BA68C8");


    UI.CreateLabel(area)
        .SetText(
            "Open Projects: " ..
            tostring(
                openProjects
            )
        );


    UI.CreateLabel(area)
        .SetText(
            "Active Projects: " ..
            tostring(
                activeProjects
            )
        );


    UI.CreateLabel(area)
        .SetText(
            "Archived Projects: " ..
            tostring(
                #(
                    data.completedInvestmentProjects
                    or {}
                )
            )
        );


    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );


    -- =====================================================
    -- HOST RULES
    -- =====================================================

    UI.CreateLabel(area)
        .SetText(
            "HOST RULES"
        ).SetColor("#B0BEC5");


    UI.CreateLabel(area)
        .SetText(
            "Maximum Agreements: " ..
            tostring(
                ClientMaxAgreements()
            )
        );


    UI.CreateLabel(area)
        .SetText(
            "Trade Bonus: " ..
            tostring(
                ClientTradeBonusPercent()
            ) ..
            "%"
        );


    UI.CreateLabel(area)
        .SetText(
            "Trade Cooldown: " ..
            tostring(
                ClientTradeCooldownTurns()
            ) ..
            " turn(s)"
        );

end
function ShowFindPartners(parent, game)
    local area=CreateContentArea(parent); local data=Mod.PublicGameData or {};
    UI.CreateLabel(area).SetText("FIND TRADE PARTNERS").SetColor("#64B5F6");
    if IsViewerMode(game) then ShowViewerModeNotice(area,"Find Partners is unavailable in viewer/reviewer mode."); return; end
    local ourID=GetLocalPlayerID(game); local ourAgreementCount=CountOurActiveAgreements(data,game);
    if ourAgreementCount>=ClientMaxAgreements() then UI.CreateLabel(area).SetText("You already have the maximum number of active Trade Agreements.").SetColor("#FFB366"); return; end
    UI.CreateLabel(area).SetText("Search by nation name. Every result shows exact Commerce income and your projected trade bonus.").SetColor("#BBBBBB");
    local search=CreateWideTextInput(area,240).SetPlaceholderText("Search nation...");
    local filters=UI.CreateHorizontalLayoutGroup(area); local host=UI.CreateVerticalLayoutGroup(area);
    local refresh=nil;
    for _,fd in ipairs({{"ALL","ALL"},{"PLAYER","PLAYERS"},{"AI","AI"},{"AVAILABLE","AVAILABLE"},{"EXISTING","EXISTING"}}) do
        local key,label=fd[1],fd[2]; UI.CreateButton(filters).SetText((TradePartnerFilter==key and "▶ " or "")..label).SetOnClick(function() TradePartnerFilter=key; refresh(); end);
    end
    local function relationState(targetID)
        local hasAgreement=false; for _,a in pairs(data.activeAgreements or {}) do if (a.player1==ourID and a.player2==targetID) or (a.player1==targetID and a.player2==ourID) then hasAgreement=true; break; end end
        local pending=false; for _,p in pairs(data.pendingProposals or {}) do if (p.fromPlayerID==ourID and p.toPlayerID==targetID) or (p.fromPlayerID==targetID and p.toPlayerID==ourID) then pending=true; break; end end
        local count=0; for _,a in pairs(data.activeAgreements or {}) do if a.player1==targetID or a.player2==targetID then count=count+1; end end
        local cd=GetCooldownTurnsRemaining(data,ourID,targetID);
        return hasAgreement,pending,count,cd;
    end
    refresh=function()
        if host and not UI.IsDestroyed(host) then UI.Destroy(host); end; host=UI.CreateVerticalLayoutGroup(area);
        local q=string.lower(search.GetText() or ""); local list={};
        for pid,p in pairs(game.Game.Players or {}) do if pid~=ourID and p.Surrendered~=true then
            local name=GetPlayerName(game,pid); local ag,pend,count,cd=relationState(pid); local available=(not ag and not pend and cd<=0 and count<ClientMaxAgreements());
            local f=TradePartnerFilter; local match=(f=="ALL") or (f=="AI" and p.IsAI==true) or (f=="PLAYER" and p.IsAI~=true) or (f=="AVAILABLE" and available) or (f=="EXISTING" and (ag or pend));
            if match and (q=="" or string.find(string.lower(name),q,1,true)) then table.insert(list,{id=pid,name=name,p=p,ag=ag,pend=pend,count=count,cd=cd,available=available}); end
        end end
        table.sort(list,function(a,b) return a.name<b.name; end); if #list==0 then UI.CreateLabel(host).SetText("No nations match this search/filter.").SetColor("#888888"); return; end
        for _,x in ipairs(list) do local income=GetPlayerIncome(game,x.id) or 0; local bonus=CalculateTradeBonus(income); local g=UI.CreateHorizontalLayoutGroup(host);
            local status=x.ag and "ACTIVE" or (x.pend and "PENDING" or (x.cd>0 and ("COOLDOWN "..tostring(x.cd)) or (x.count>=ClientMaxAgreements() and "AT LIMIT" or "AVAILABLE")));
            UI.CreateLabel(g).SetText(x.name.." | "..(x.p.IsAI and "AI" or "Player").." | Income "..tostring(income).." | Your bonus +"..tostring(bonus).."/turn | "..status).SetColor(x.available and "#8FD694" or "#DDDDDD");
            if x.available then local tid=x.id; UI.CreateButton(g).SetText("PROPOSE").SetOnClick(function() SafeSendGameCustomMessage(game,"Sending trade proposal...",{type="proposeTrade",targetPlayerID=tid},function(r) if r and r.message then UI.Alert(r.message); end; ShowFindPartners(parent,game); end); end); end
        end
    end
    search.SetOnValueChanged(function() refresh(); end); refresh();
end

function ShowMyAgreements(
    parent,
    game
)

    local area =
        CreateContentArea(
            parent
        );


    local data =
        Mod.PublicGameData or {};


    local ourID =
        GetLocalPlayerID(game);


    UI.CreateLabel(area)
        .SetText(
            "MY TRADE AGREEMENTS"
        );

    if IsViewerMode(game) then
        ShowViewerModeNotice(area, "My Agreements is unavailable in viewer/reviewer mode because no active player is associated with this view.");
        return;
    end


    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );


    UI.CreateLabel(area)
        .SetText(
            "INCOMING PROPOSALS"
        );


    local incomingFound =
        false;


    for _, proposal
        in pairs(
            data.pendingProposals
            or {}
        ) do


        if proposal.toPlayerID
            == ourID then


            incomingFound =
                true;


            local fromID =
                proposal.fromPlayerID;


            local fromName =
                GetPlayerName(
                    game,
                    fromID
                );


            local expectedBonus =
                CalculateTradeBonus(
                    GetPlayerIncome(
                        game,
                        fromID
                    )
                );


            local group =
                UI.CreateVerticalLayoutGroup(
                    area
                );


            UI.CreateLabel(group)
                .SetText(
                    fromName
                );


            UI.CreateLabel(group)
                .SetText(
                    "Estimated Benefit: +" ..
                    tostring(
                        expectedBonus
                    ) ..
                    " Commerce/turn"
                );


            local buttons =
                UI.CreateHorizontalLayoutGroup(
                    group
                );


            UI.CreateButton(buttons)
                .SetText(
                    "ACCEPT"
                )
                .SetOnClick(function()


                    SafeSendGameCustomMessage(game, 
                        "Accepting trade proposal...",

                        {

                            type =
                                "acceptTrade",

                            fromPlayerID =
                                fromID

                        },

                        function(result)


                            UI.Alert(
                                result
                                and result.message
                                or
                                "Trade request processed."
                            );


                            if result ~= nil
                                and result.success then


                                ShowMyAgreements(
                                    parent,
                                    game
                                );

                            end

                        end
                    );

                end);


            UI.CreateButton(buttons)
                .SetText(
                    "REJECT"
                )
                .SetOnClick(function()


                    SafeSendGameCustomMessage(game, 
                        "Rejecting trade proposal...",

                        {

                            type =
                                "rejectTrade",

                            fromPlayerID =
                                fromID

                        },

                        function(result)


                            UI.Alert(
                                result
                                and result.message
                                or
                                "Trade request processed."
                            );


                            ShowMyAgreements(
                                parent,
                                game
                            );

                        end
                    );

                end);


            UI.CreateLabel(group)
                .SetText(
                    "----------------------------------------"
                );

        end

    end


    if not incomingFound then


        UI.CreateLabel(area)
            .SetText(
                "No incoming trade proposals."
            );

    end


    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );


    UI.CreateLabel(area)
        .SetText(
            "OUTGOING PROPOSALS"
        );


    local outgoingFound =
        false;


    for _, proposal
        in pairs(
            data.pendingProposals
            or {}
        ) do


        if proposal.fromPlayerID
            == ourID then


            outgoingFound =
                true;


            local targetName =
                GetPlayerName(
                    game,
                    proposal.toPlayerID
                );


            UI.CreateLabel(area)
                .SetText(
                    "Waiting for response from " ..
                    targetName
                );

        end

    end


    if not outgoingFound then


        UI.CreateLabel(area)
            .SetText(
                "No outgoing trade proposals."
            );

    end


    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );


    UI.CreateLabel(area)
        .SetText(
            "ACTIVE AGREEMENTS"
        );


    local activeFound =
        false;


    for _, agreement
        in pairs(
            data.activeAgreements
            or {}
        ) do


        local otherID =
            nil;


        if agreement.player1
            == ourID then


            otherID =
                agreement.player2;


        elseif agreement.player2
            == ourID then


            otherID =
                agreement.player1;

        end


        if otherID ~= nil then


            activeFound =
                true;


            local selectedOtherID =
                otherID;


            local otherName =
                GetPlayerName(
                    game,
                    selectedOtherID
                );


            local partnerIncome =
                GetPlayerIncome(
                    game,
                    selectedOtherID
                );


            local bonus =
                CalculateTradeBonus(
                    partnerIncome
                );


            local group =
                UI.CreateVerticalLayoutGroup(
                    area
                );


            UI.CreateLabel(group)
                .SetText(
                    otherName
                );


            UI.CreateLabel(group)
                .SetText(
                    "Partner Commerce: " ..
                    tostring(
                        partnerIncome
                    )
                );


            UI.CreateLabel(group)
                .SetText(
                    "Current Benefit: +" ..
                    tostring(
                        bonus
                    ) ..
                    " Commerce/turn"
                );


            UI.CreateLabel(group)
                .SetText(
                    "Agreement Started: Turn " ..
                    tostring(
                        agreement.startedTurn
                        or 0
                    )
                );


            UI.CreateButton(group)
                .SetText(
                    "CANCEL AGREEMENT"
                )
                .SetOnClick(function()


                    SafeSendGameCustomMessage(game, 
                        "Canceling trade agreement...",

                        {

                            type =
                                "cancelTrade",

                            otherPlayerID =
                                selectedOtherID

                        },

                        function(result)


                            UI.Alert(
                                result
                                and result.message
                                or
                                "Trade request processed."
                            );


                            if result ~= nil
                                and result.success then


                                ShowMyAgreements(
                                    parent,
                                    game
                                );

                            end

                        end
                    );

                end);


            UI.CreateLabel(group)
                .SetText(
                    "----------------------------------------"
                );

        end

    end


    if not activeFound then


        UI.CreateLabel(area)
            .SetText(
                "You do not currently have any active Trade Agreements."
            );

    end

end

function ShowStockMarket(
    parent,
    game
)

    local area =
        CreateContentArea(
            parent
        );

    local data =
        Mod.PublicGameData
        or {};

    local economy =
        data.globalEconomy
        or {};

    local market =
        economy.market
        or {};

    local companies =
        market.companies
        or {};

    local ourNation =
        (
            economy.nations
            or {}
        )[
            GetLocalPlayerID(game)
        ]
        or {};

    UI.CreateLabel(area)
        .SetText(
            "GLOBAL STOCK MARKET"
        );

    local navigation =
        UI.CreateHorizontalLayoutGroup(
            area
        );

    UI.CreateButton(navigation)
        .SetText(
            "MY PORTFOLIO"
        )
        .SetFlexibleWidth(1)
        .SetOnClick(function()

            ShowStockPortfolio(
                parent,
                game
            );

        end);

    UI.CreateButton(navigation)
        .SetText(
            "MARKET OVERVIEW"
        )
        .SetFlexibleWidth(1)
        .SetOnClick(function()

            ShowMarketOverview(
                parent,
                game
            );

        end);

    UI.CreateLabel(area)
        .SetText(
            "Quick Search"
        );

    local searchInput =
        CreateWideTextInput(
            area
        )
            .SetPlaceholderText(
                "Search company, strategy, or owner..."
            );

    local resultsHost =
        UI.CreateVerticalLayoutGroup(
            area
        );

    local resultsGroup =
        nil;

    local function RenderCompanies()

        if resultsGroup ~= nil
            and not UI.IsDestroyed(
                resultsGroup
            )
        then

            UI.Destroy(
                resultsGroup
            );

        end

        resultsGroup =
            UI.CreateVerticalLayoutGroup(
                resultsHost
            );

        local searchText =
            string.lower(
                searchInput.GetText()
                or ""
            );

        local matches =
            {};

        for companyID, company
            in pairs(companies)
        do

            if company.active == true
                and company.delisted ~= true
            then

                local ownerName =
                    "";

                if company.ownerPlayerID ~= nil then
                    ownerName =
                        GetPlayerName(
                            game,
                            company.ownerPlayerID
                        );
                end

                local searchable =
                    string.lower(
                        tostring(
                            company.name
                            or ""
                        ) ..
                        " " ..
                        tostring(
                            company.strategy
                            or ""
                        ) ..
                        " " ..
                        tostring(ownerName)
                    );

                if searchText == ""
                    or string.find(
                        searchable,
                        searchText,
                        1,
                        true
                    ) ~= nil
                then

                    table.insert(
                        matches,
                        {
                            id = companyID,
                            company = company,
                            ownerName = ownerName
                        }
                    );

                end

            end

        end

        table.sort(
            matches,
            function(a, b)

                return string.lower(
                    tostring(
                        a.company.name
                        or ""
                    )
                ) < string.lower(
                    tostring(
                        b.company.name
                        or ""
                    )
                );

            end
        );

        if #matches == 0 then

            UI.CreateLabel(
                resultsGroup
            )
                .SetText(
                    "No listed companies match your search."
                );

            return;
        end

        for _, entry
            in ipairs(matches)
        do

            local companyID =
                entry.id;

            local company =
                entry.company;

            local group =
                UI.CreateVerticalLayoutGroup(
                    resultsGroup
                );

            local currentPrice =
                company.currentPrice
                or company.startingPrice
                or 0;

            local previousPrice =
                company.previousPrice
                or currentPrice;

            local changePercent =
                0;

            if previousPrice > 0 then

                changePercent =
                    (
                        (
                            currentPrice
                            - previousPrice
                        )
                        / previousPrice
                    )
                    * 100;

            end

            local ownedShares =
                (
                    ourNation.stockHoldings
                    or {}
                )[
                    companyID
                ]
                or 0;

            local companyLabel =
                UI.CreateLabel(group)
                    .SetText(
                        tostring(
                            company.name
                            or "Unknown Company"
                        )
                    );

            companyLabel.SetColor(
                "#D4AF37"
            );

            local summaryRow =
                UI.CreateHorizontalLayoutGroup(
                    group
                );

            UI.CreateLabel(summaryRow)
                .SetText(
                    "Price: " ..
                    tostring(currentPrice) ..
                    " | Available: " ..
                    tostring(
                        company.sharesAvailable
                        or 0
                    )
                )
                .SetFlexibleWidth(1);

            local changeLabel =
                UI.CreateLabel(summaryRow)
                    .SetText(
                        string.format(
                            "%+.1f%%",
                            changePercent
                        )
                    );

            if changePercent > 0 then
                changeLabel.SetColor("#32CD32");
            elseif changePercent < 0 then
                changeLabel.SetColor("#FF4C4C");
            end

            local detailsRow =
                UI.CreateHorizontalLayoutGroup(
                    group
                );

            UI.CreateLabel(detailsRow)
                .SetText(
                    "Strategy: " ..
                    tostring(
                        company.strategy
                        or "Unknown"
                    )
                )
                .SetFlexibleWidth(1);

            UI.CreateLabel(detailsRow)
                .SetText(
                    "Your Shares: " ..
                    tostring(ownedShares)
                )
                .SetFlexibleWidth(1);

            if entry.ownerName ~= "" then

                UI.CreateLabel(group)
                    .SetText(
                        "Owner: " ..
                        tostring(
                            entry.ownerName
                        ) ..
                        " | Market Cap: " ..
                        tostring(
                            company.marketCap
                            or 0
                        )
                    );

            end

            UI.CreateButton(group)
                .SetText(
                    "VIEW / TRADE COMPANY"
                )
                .SetOnClick(function()

                    ShowCompanyDetails(
                        parent,
                        game,
                        companyID
                    );

                end);

            UI.CreateLabel(group)
                .SetText(
                    "----------------------------------------"
                );

        end

    end

    searchInput.SetOnValueChanged(function()

        RenderCompanies();

    end);

    RenderCompanies();

end

function ShowCompanyDetails(
    parent,
    game,
    companyID
)

    local area =
        CreateContentArea(
            parent
        );

    local viewerMode = IsViewerMode(game);
    if viewerMode then
        ShowViewerModeNotice(area, "Viewer/reviewer mode: company information is visible, but personal buy/sell and owner controls require an active player.");
    end

    local data =
        Mod.PublicGameData
        or {};

    local economy =
        data.globalEconomy
        or {};

    local market =
        economy.market
        or {};

    local company =
        (
            market.companies
            or {}
        )[
            companyID
        ];

    if company == nil then

        UI.CreateLabel(area)
            .SetText(
                "Company not found."
            );

        return;
    end

UI.CreateButton(area)
    .SetText(
        "BACK TO MARKET"
    )
    .SetOnClick(function()

        ShowStockMarket(
            parent,
            game
        );

    end);

    local currentPrice =
        company.currentPrice
        or company.startingPrice
        or 0;

    local previousPrice =
        company.previousPrice
        or currentPrice;

    local changePercent =
        0;

    if previousPrice > 0 then

        changePercent =
            (
                (
                    currentPrice
                    - previousPrice
                )
                / previousPrice
            )
            * 100;

    end

    local companyLabel =
        UI.CreateLabel(area)
            .SetText(
                tostring(
                    company.name
                    or
                    "Unknown Company"
                )
            );

    companyLabel.SetColor(
        "#D4AF37"
    );

    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );

    local statsRow1 =
        UI.CreateHorizontalLayoutGroup(
            area
        );

    UI.CreateLabel(statsRow1)
        .SetText(
            "Price: " ..
            tostring(currentPrice) ..
            " gold"
        )
        .SetFlexibleWidth(1);

    local changeLabel =
        UI.CreateLabel(statsRow1)
            .SetText(
                "Change: " ..
                string.format(
                    "%.1f%%",
                    changePercent
                )
            )
            .SetFlexibleWidth(1);

    if changePercent > 0 then

        changeLabel.SetColor(
            "#32CD32"
        );

    elseif changePercent < 0 then

        changeLabel.SetColor(
            "#FF4C4C"
        );

    end

    local statsRow2 =
        UI.CreateHorizontalLayoutGroup(
            area
        );

    UI.CreateLabel(statsRow2)
        .SetText(
            "Market Cap: " ..
            tostring(
                company.marketCap
                or 0
            )
        )
        .SetFlexibleWidth(1);

    UI.CreateLabel(statsRow2)
        .SetText(
            "Total Shares: " ..
            tostring(
                company.totalShares
                or 0
            )
        )
        .SetFlexibleWidth(1);

    local statsRow3 =
        UI.CreateHorizontalLayoutGroup(
            area
        );

    UI.CreateLabel(statsRow3)
        .SetText(
            "Available: " ..
            tostring(
                company.sharesAvailable
                or 0
            )
        )
        .SetFlexibleWidth(1);

    UI.CreateLabel(statsRow3)
        .SetText(
            "Strategy: " ..
            tostring(
                company.strategy
                or "Unknown"
            )
        )
        .SetFlexibleWidth(1);

    local statsRow4 =
        UI.CreateHorizontalLayoutGroup(
            area
        );

    UI.CreateLabel(statsRow4)
        .SetText(
            "Dividend/Share: " ..
            string.format(
                "%.2f",
                company.dividendPerShare
                or 0
            )
        )
        .SetFlexibleWidth(1);

    UI.CreateLabel(statsRow4)
        .SetText(
            "Dividends Paid: " ..
            tostring(
                company.totalDividendsPaid
                or 0
            )
        )
        .SetFlexibleWidth(1);

-- ============================================
-- FLAGSHIP ACQUISITIONS
-- ============================================

local localPlayerID = GetLocalPlayerID(game);
local ownerNation = (economy.nations or {})[company.ownerPlayerID] or {};
local currentTurn = economy.currentEconomyTurn or data.tradeTurn or 1;
local acquisitionPremium = tonumber(GetClientSetting("AcquisitionPremiumPercent",150)) or 150;
local estimatedAcquisitionPrice = math.max(1, math.floor(((tonumber(company.marketCap) or ((tonumber(company.currentPrice) or 1)*(tonumber(company.totalShares) or 100))) * acquisitionPremium / 100) + 0.5));
market.acquisitionOffers = market.acquisitionOffers or {};
local companyOffers = market.acquisitionOffers[companyID] or {};

UI.CreateLabel(area).SetText("----------------------------------------");
UI.CreateLabel(area).SetText("FLAGSHIP ACQUISITION").SetColor("#FFB366");

if company.ownerPlayerID == localPlayerID then
    local acceptOn = company.allowAcquisitionOffers == true;
    UI.CreateLabel(area).SetText("Acquisition Offers: "..(acceptOn and "ON" or "OFF")).SetColor(acceptOn and "#79D279" or "#FF7B7B");
    UI.CreateButton(area).SetText(acceptOn and "TURN ACQUISITION OFFERS OFF" or "TURN ACQUISITION OFFERS ON").SetInteractable(not viewerMode).SetOnClick(function()
        SafeSendGameCustomMessage(game,"Updating acquisition preference...",{type="toggleAcquisitionOffers",companyID=companyID},function(result)
            if result and result.message then UI.Alert(result.message); end
            ShowCompanyDetails(parent,game,companyID);
        end);
    end);
    local offerCount=0;
    for buyerID,offer in pairs(companyOffers) do
        if offer and offer.status=="pending" then
            offerCount=offerCount+1;
            local row=UI.CreateHorizontalLayoutGroup(area);
            UI.CreateLabel(row).SetText(GetPlayerName(game,buyerID).." | Offer: "..tostring(offer.price or 0).." Commerce").SetColor(GetPlayerUIColor(game,buyerID,"#FFFFFF"));
            UI.CreateButton(row).SetText("ACCEPT").SetOnClick(function()
                SafeSendGameCustomMessage(game,"Accepting acquisition...",{type="acceptAcquisitionOffer",companyID=companyID,buyerID=buyerID},function(result)
                    if result and result.message then UI.Alert(result.message); end
                    ShowMarketsMenu(parent,game);
                end);
            end);
            UI.CreateButton(row).SetText("REJECT").SetOnClick(function()
                SafeSendGameCustomMessage(game,"Rejecting acquisition...",{type="rejectAcquisitionOffer",companyID=companyID,buyerID=buyerID},function(result)
                    if result and result.message then UI.Alert(result.message); end
                    ShowCompanyDetails(parent,game,companyID);
                end);
            end);
        end
    end
    if offerCount==0 then UI.CreateLabel(area).SetText("No pending acquisition offers.").SetColor("#888888"); end
elseif company.allowAcquisitionOffers == true then
    UI.CreateLabel(area).SetText("Estimated acquisition offer: "..tostring(estimatedAcquisitionPrice).." Commerce").SetColor("#FFD166");
    UI.CreateLabel(area).SetText("If accepted, existing shareholders receive a buyout payout and the buyer's flagship receives a stock-price/confidence boost.").SetColor("#BBBBBB");
    UI.CreateButton(area).SetText("MAKE ACQUISITION OFFER").SetInteractable(not viewerMode).SetOnClick(function()
        SafeSendGameCustomMessage(game,"Sending acquisition offer...",{type="makeAcquisitionOffer",companyID=companyID},function(result)
            if result and result.message then UI.Alert(result.message); end
            ShowCompanyDetails(parent,game,companyID);
        end);
    end);
else
    UI.CreateLabel(area).SetText("This flagship is not accepting acquisition offers.").SetColor("#888888");
end

-- ============================================
-- TRADE SHARES
-- ============================================

local yourNation =
    (
        economy.nations
        or {}
    )[
        GetLocalPlayerID(game)
    ]
    or {};

local yourShares =
    (
        yourNation.stockHoldings
        or {}
    )[
        companyID
    ]
    or 0;

local availableGold =
    GetPlayerGold(
        game,
        GetLocalPlayerID(game)
    );

UI.CreateLabel(area)
    .SetText(
        "----------------------------------------"
    );

UI.CreateLabel(area)
    .SetText(
        "TRADE SHARES"
    );

UI.CreateLabel(area)
    .SetText(
        "Available Gold: " ..
        tostring(availableGold) ..
        " | Your Shares: " ..
        tostring(yourShares)
    );

local selectedBuyShares =
    1;

local buyPreview =
    UI.CreateLabel(area);

local function UpdateBuyPreview()

    local availableShares =
        company.sharesAvailable
        or 0;

    if availableShares <= 0 then

        selectedBuyShares =
            0;

        buyPreview.SetText(
            "No public shares are currently available."
        );

        return;

    end

    selectedBuyShares =
        math.max(
            1,
            math.min(
                selectedBuyShares,
                availableShares
            )
        );

    buyPreview.SetText(
        "Buy " ..
        tostring(selectedBuyShares) ..
        " share(s) | Cost: " ..
        tostring(
            selectedBuyShares
            * currentPrice
        ) ..
        " gold"
    );

end

local buyButtons =
    UI.CreateHorizontalLayoutGroup(
        area
    );

UI.CreateButton(buyButtons)
    .SetText("-1")
    .SetFlexibleWidth(1)
    .SetOnClick(function()

        selectedBuyShares =
            math.max(
                1,
                selectedBuyShares - 1
            );

        UpdateBuyPreview();

    end);

UI.CreateButton(buyButtons)
    .SetText("+1")
    .SetFlexibleWidth(1)
    .SetOnClick(function()

        selectedBuyShares =
            selectedBuyShares + 1;

        UpdateBuyPreview();

    end);

UI.CreateButton(buyButtons)
    .SetText("+5")
    .SetFlexibleWidth(1)
    .SetOnClick(function()

        selectedBuyShares =
            selectedBuyShares + 5;

        UpdateBuyPreview();

    end);

local buyButton =
    UI.CreateButton(area)
        .SetText(
            "BUY SHARES"
        )
        .SetInteractable(
            (company.sharesAvailable or 0) > 0 and not viewerMode
        )
        .SetOnClick(function()

            if selectedBuyShares <= 0 then
                return;
            end

            SafeSendGameCustomMessage(game, 
                "Buying shares...",
                {
                    type = "buyStock",
                    companyID = companyID,
                    shares = selectedBuyShares
                },
                function(result)

                    if result ~= nil
                        and result.success == true
                    then

                        ShowCompanyDetails(
                            parent,
                            game,
                            companyID
                        );

                    elseif result ~= nil
                        and result.message ~= nil
                    then

                        UI.Alert(
                            tostring(
                                result.message
                            )
                        );

                    end

                end
            );

        end);

UpdateBuyPreview();

local protectedFounderShares =
    0;

if company.founderPlayerID == GetLocalPlayerID(game) then

    protectedFounderShares =
        company.founderShares
        or 0;

end

local sellableShares =
    math.max(
        0,
        yourShares
        - protectedFounderShares
    );

local selectedSellShares =
    sellableShares > 0
    and 1
    or 0;

local sellPreview =
    UI.CreateLabel(area);

local function UpdateSellPreview()

    if sellableShares <= 0 then

        selectedSellShares =
            0;

        sellPreview.SetText(
            "No sellable shares available."
        );

        return;

    end

    selectedSellShares =
        math.max(
            1,
            math.min(
                selectedSellShares,
                sellableShares
            )
        );

    sellPreview.SetText(
        "Sell " ..
        tostring(selectedSellShares) ..
        " share(s) | Value: " ..
        tostring(
            selectedSellShares
            * currentPrice
        ) ..
        " gold"
    );

end

local sellButtons =
    UI.CreateHorizontalLayoutGroup(
        area
    );

UI.CreateButton(sellButtons)
    .SetText("-1")
    .SetFlexibleWidth(1)
    .SetOnClick(function()

        selectedSellShares =
            math.max(
                1,
                selectedSellShares - 1
            );

        UpdateSellPreview();

    end);

UI.CreateButton(sellButtons)
    .SetText("+1")
    .SetFlexibleWidth(1)
    .SetOnClick(function()

        selectedSellShares =
            selectedSellShares + 1;

        UpdateSellPreview();

    end);

UI.CreateButton(sellButtons)
    .SetText("+5")
    .SetFlexibleWidth(1)
    .SetOnClick(function()

        selectedSellShares =
            selectedSellShares + 5;

        UpdateSellPreview();

    end);

UI.CreateButton(area)
    .SetText(
        "SELL SHARES"
    )
    .SetInteractable(
        sellableShares > 0 and not viewerMode
    )
    .SetOnClick(function()

        if selectedSellShares <= 0 then
            return;
        end

        SafeSendGameCustomMessage(game, 
            "Selling shares...",
            {
                type = "sellStock",
                companyID = companyID,
                shares = selectedSellShares
            },
            function(result)

                if result ~= nil
                    and result.success == true
                then

                    ShowCompanyDetails(
                        parent,
                        game,
                        companyID
                    );

                elseif result ~= nil
                    and result.message ~= nil
                then

                    UI.Alert(
                        tostring(
                            result.message
                        )
                    );

                end

            end
        );

    end);

UpdateSellPreview();

UI.CreateLabel(area)
    .SetText(
        "----------------------------------------"
    );

local ownerName =
    "Unknown";

if company.ownerPlayerID ~= nil
    and game.Game ~= nil
    and game.Game.Players ~= nil
    and game.Game.Players[
        company.ownerPlayerID
    ] ~= nil then

    ownerName =
        game.Game.Players[
            company.ownerPlayerID
        ].DisplayName(
            nil,
            false
        );

end

local ownerLabel =
    UI.CreateLabel(area)
        .SetText(
            "Owner Nation: " ..
            tostring(ownerName)
        );

ownerLabel.SetColor(
    "#D4AF37"
);

UI.CreateLabel(area)
    .SetText(
        "SHAREHOLDERS"
    );

local foundShareholder =
    false;

for playerID, nation
    in pairs(
        economy.nations
        or {}
    ) do

    local heldShares =
        (
            nation.stockHoldings
            or {}
        )[
            companyID
        ]
        or 0;

    if heldShares > 0 then

        foundShareholder =
            true;

        local playerName =
            "Unknown";

        if game.Game ~= nil
            and game.Game.Players ~= nil
            and game.Game.Players[
                playerID
            ] ~= nil then

            playerName =
                game.Game.Players[
                    playerID
                ].DisplayName(
                    nil,
                    false
                );

        end

        local ownershipPercent =
            0;

        if (
            company.totalShares
            or 0
        ) > 0 then

            ownershipPercent =
                (
                    heldShares
                    / company.totalShares
                )
                * 100;

        end

        UI.CreateLabel(area)
            .SetText(
                tostring(playerName) ..
                " | " ..
                tostring(heldShares) ..
                " shares | " ..
                string.format(
                    "%.1f%%",
                    ownershipPercent
                )
            );

    end
end

if not foundShareholder then

    UI.CreateLabel(area)
        .SetText(
            "No shareholders recorded."
        );

end

-- ============================================
-- FLAGSHIP OWNER CONTROLS
-- ============================================

if company.ownerPlayerID == GetLocalPlayerID(game)
    or company.founderPlayerID == GetLocalPlayerID(game)
then

    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );

    UI.CreateLabel(area)
        .SetText(
            "FLAGSHIP OWNER CONTROLS"
        );

    UI.CreateLabel(area)
        .SetText(
            "Shares Available: "
            .. tostring(
                company.sharesAvailable
                or 0
            )
        );

    local currentTurn =
        economy.currentEconomyTurn
        or data.tradeTurn
        or 1;

    local lastIssueTurn =
    company.lastShareIssueTurn;

local cooldownRemaining =
    0;

if lastIssueTurn ~= nil then

    cooldownRemaining =
        math.max(
            0,
            5
            - (
                currentTurn
                - lastIssueTurn
            )
        );

end

    if cooldownRemaining > 0 then

        UI.CreateLabel(area)
            .SetText(
                "Share Issuance Cooldown: "
                .. tostring(
                    cooldownRemaining
                )
                .. " turn(s) remaining"
            );

    else

        UI.CreateLabel(area)
            .SetText(
                "Issue New Public Shares"
            );

        local function IssueShares(
            amount
        )

            SafeSendGameCustomMessage(game, 
                "Issuing new shares...",
                {
                    type =
                        "issueShares",

                    companyID =
                        companyID,

                    shares =
                        amount
                },
                function(result)

                    if result ~= nil
                        and result.success == true
                    then

                        ShowStockMarket(
                            parent,
                            game
                        );

                    end

                end
            );

        end

        local issueButtons =
            UI.CreateHorizontalLayoutGroup(
                area
            );

        UI.CreateButton(issueButtons)
            .SetText(
                "+10"
            )
            .SetFlexibleWidth(1)
            .SetOnClick(function()

                IssueShares(
                    10
                );

            end);

        UI.CreateButton(issueButtons)
            .SetText(
                "+25"
            )
            .SetFlexibleWidth(1)
            .SetOnClick(function()

                IssueShares(
                    25
                );

            end);

        UI.CreateButton(issueButtons)
            .SetText(
                "+50"
            )
            .SetFlexibleWidth(1)
            .SetOnClick(function()

                IssueShares(
                    50
                );

            end);

        UI.CreateLabel(area)
            .SetText(
                "Issuing shares dilutes existing ownership percentages."
            );

    end

end

UI.CreateLabel(area)
    .SetText(
        "----------------------------------------"
    );

UI.CreateLabel(area)
    .SetText(
        "YOUR POSITION"
    );

local yourCostBasis =
    (
        yourNation.stockCostBasis
        or {}
    )[
        companyID
    ]
    or 0;

local yourPositionValue =
    yourShares
    * currentPrice;
local averageCost =
    0;

if yourShares > 0 then

    averageCost =
        yourCostBasis
        / yourShares;

end
local unrealizedProfit =
    yourPositionValue
    - yourCostBasis;

UI.CreateLabel(area)
    .SetText(
        "Shares Owned: " ..
        tostring(yourShares)
    );

UI.CreateLabel(area)
    .SetText(
        "Position Value: " ..
        tostring(yourPositionValue) ..
        " gold"
    );

UI.CreateLabel(area)
    .SetText(
        "Cost Basis: " ..
        tostring(yourCostBasis) ..
        " gold"
    );
UI.CreateLabel(area)
    .SetText(
        "Average Cost: " ..
        string.format(
            "%.2f",
            averageCost
        ) ..
        " gold/share"
    );

local profitLabel =
    UI.CreateLabel(area)
        .SetText(
            "Unrealized P/L: " ..
            tostring(unrealizedProfit) ..
            " gold"
        );

if unrealizedProfit > 0 then

    profitLabel.SetColor(
        "#32CD32"
    );

elseif unrealizedProfit < 0 then

    profitLabel.SetColor(
        "#FF4C4C"
    );

end

UI.CreateLabel(area)
    .SetText(
        "----------------------------------------"
    );

UI.CreateLabel(area)
    .SetText(
        "PRICE HISTORY"
    );

local history =
    company.priceHistory
    or {};

if #history == 0 then

    UI.CreateLabel(area)
        .SetText(
            "No price history available yet."
        );

else

    local startIndex =
        math.max(
            1,
            #history - 9
        );

    local previousHistoryPrice =
        nil;

    for index = startIndex, #history do

        local entry =
            history[index];

        local historyPrice =
            entry.price
            or 0;

        local historyLabel =
            UI.CreateLabel(area)
                .SetText(
                    "Turn " ..
                    tostring(
                        entry.turn
                        or "?"
                    ) ..
                    " | " ..
                    tostring(
                        historyPrice
                    ) ..
                    " gold"
                );

        if previousHistoryPrice ~= nil then

            if historyPrice > previousHistoryPrice then

                historyLabel.SetColor(
                    "#32CD32"
                );

            elseif historyPrice < previousHistoryPrice then

                historyLabel.SetColor(
                    "#FF4C4C"
                );

            end

        else

            historyLabel.SetColor(
                "#D4AF37"
            );

        end

        previousHistoryPrice =
            historyPrice;

    end

end
local sparkline =
    "";

if #history > 0 then

    local startIndex =
        math.max(
            1,
            #history - 9
        );

    for index = startIndex, #history do

        local entry =
            history[index];

        local historyPrice =
            entry.price
            or 0;

        local previousPrice =
            historyPrice;

        if index > startIndex then

            previousPrice =
                history[
                    index - 1
                ].price
                or historyPrice;

        end

        if historyPrice > previousPrice then

            sparkline =
                sparkline ..
                "▲ ";

        elseif historyPrice < previousPrice then

            sparkline =
                sparkline ..
                "▼ ";

        else

            sparkline =
                sparkline ..
                "● ";

        end

    end

end

local trendGroup =
    UI.CreateHorizontalLayoutGroup(
        area
    );

UI.CreateLabel(trendGroup)
    .SetText(
        "Trend: "
    );

local startIndex =
    math.max(
        1,
        #history - 9
    );

for index = startIndex, #history do

    local entry =
        history[index];

    local historyPrice =
        entry.price
        or 0;

    local symbol =
        "●";

    local symbolColor =
        "#D4AF37";

    if index > startIndex then

        local previousPrice =
            history[
                index - 1
            ].price
            or historyPrice;

        if historyPrice > previousPrice then

            symbol =
                "▲";

            symbolColor =
                "#32CD32";

        elseif historyPrice < previousPrice then

            symbol =
                "▼";

            symbolColor =
                "#FF4C4C";

        end

    end

    local symbolLabel =
        UI.CreateLabel(
            trendGroup
        )
            .SetText(
                symbol
            );

    symbolLabel.SetColor(
        symbolColor
    );

end

end

function ShowStockPortfolio(
    parent,
    game
)

    local area =
        CreateContentArea(
            parent
        );

    local data =
        Mod.PublicGameData
        or {};

    if data.globalEconomy == nil then

    UI.CreateLabel(area)
        .SetText(
            "Portfolio data is still initializing. Please check again after the economy updates."
        );

    return;

end

    local economy =
        data.globalEconomy
        or {};

    if IsViewerMode(game) then
        UI.CreateLabel(area).SetText("STOCK PORTFOLIO");
        ShowViewerModeNotice(area, "Portfolio unavailable in viewer/reviewer mode because no active player is associated with this view.");
        UI.CreateButton(area).SetText("BACK TO MARKET").SetOnClick(function()
            ShowStockMarket(parent, game);
        end);
        return;
    end
    
    if economy.nations == nil
    or economy.market == nil
then

    UI.CreateLabel(area)
        .SetText(
            "Portfolio data is still initializing."
        );

    return;

end

    local nation =
        (
            economy.nations
            or {}
        )[
            GetLocalPlayerID(game)
        ]
        or {};

    local market =
        economy.market
        or {};

    local totalValue =
        0;

    local totalCostBasis =
        0;

    UI.CreateLabel(area)
        .SetText(
            "STOCK PORTFOLIO"
        );

    UI.CreateButton(area)
    .SetText(
        "BACK TO MARKET"
    )
    .SetOnClick(function()

        ShowStockMarket(
            parent,
            game
        );

    end);

    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );

    for companyID, shares
        in pairs(
            nation.stockHoldings
            or {}
        ) do

        if shares > 0 then

            local company =
                (
                    market.companies
                    or {}
                )[
                    companyID
                ];

            if company ~= nil then

                local price =
                    company.currentPrice
                    or company.startingPrice
                    or 0;

                local positionValue =
                    shares
                    * price;

                local costBasis =
                    (
                        nation.stockCostBasis
                        or {}
                    )[
                        companyID
                    ]
                    or 0;

                local profit =
                    positionValue
                    - costBasis;

                totalValue =
                    totalValue
                    + positionValue;

                totalCostBasis =
                    totalCostBasis
                    + costBasis;

                local companyLabel =
                    UI.CreateLabel(area)
                        .SetText(
                            tostring(
                                company.name
                                or
                                "Unknown Company"
                            )
                        );

                companyLabel.SetColor(
                    "#D4AF37"
                );

                UI.CreateLabel(area)
                    .SetText(
                        "Shares: " ..
                        tostring(shares) ..
                        " | Value: " ..
                        tostring(positionValue) ..
                        " commerce"
                    );

                local profitLabel =
                    UI.CreateLabel(area)
                        .SetText(
                            "Unrealized P/L: " ..
                            tostring(profit) ..
                            " commerce"
                        );

                if profit > 0 then

                    profitLabel.SetColor(
                        "#32CD32"
                    );

                elseif profit < 0 then

                    profitLabel.SetColor(
                        "#FF4C4C"
                    );

                end

                UI.CreateLabel(area)
                    .SetText(
                        "----------------------------------------"
                    );

            end
        end
    end

-- =========================================
-- GLOBAL MARKET ETF POSITION
-- =========================================

local etf =
    market.etf
    or {};

local etfShares =
    nation.etfShares
    or 0;

local etfPrice =
    etf.currentPrice
    or etf.startingPrice
    or 100;

local etfValue =
    etfShares
    * etfPrice;

local etfCostBasis =
    nation.etfCostBasis
    or 0;

local etfProfit =
    etfValue
    - etfCostBasis;


if etfShares > 0 then

    UI.CreateLabel(area)
        .SetText(
            "GLOBAL MARKET ETF"
        )
        .SetColor(
            "#D4AF37"
        );

    UI.CreateLabel(area)
        .SetText(
            "Shares: " ..
            tostring(
                etfShares
            ) ..
            " | Value: " ..
            string.format(
                "%.2f",
                etfValue
            ) ..
            " gold"
        );

    local etfProfitLabel =
        UI.CreateLabel(area)
            .SetText(
                "Unrealized P/L: " ..
                string.format(
                    "%.2f",
                    etfProfit
                ) ..
                " gold"
            );

    if etfProfit > 0 then

        etfProfitLabel.SetColor(
            "#32CD32"
        );

    elseif etfProfit < 0 then

        etfProfitLabel.SetColor(
            "#FF4C4C"
        );

    end

    UI.CreateLabel(area)
        .SetText(
            "ETF Dividends Received: " ..
            tostring(
                nation.etfDividendsReceived
                or 0
            ) ..
            " gold"
        );

    UI.CreateLabel(area)
        .SetText(
            "Realized ETF Profit: " ..
            string.format(
                "%.2f",
                nation.realizedETFProfit
                or 0
            ) ..
            " gold"
        );

    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );

end


-- Include ETF in overall portfolio totals

totalValue =
    totalValue
    + etfValue;

totalCostBasis =
    totalCostBasis
    + etfCostBasis;

    local totalProfit =
        totalValue
        - totalCostBasis;

    UI.CreateLabel(area)
        .SetText(
            "TOTAL PORTFOLIO VALUE: " ..
            tostring(totalValue) ..
            " gold"
        );

    UI.CreateLabel(area)
        .SetText(
            "TOTAL COST BASIS: " ..
            tostring(totalCostBasis) ..
            " gold"
        );

    local totalProfitLabel =
        UI.CreateLabel(area)
            .SetText(
                "TOTAL UNREALIZED P/L: " ..
                tostring(totalProfit) ..
                " gold"
            );

    if totalProfit > 0 then

        totalProfitLabel.SetColor(
            "#32CD32"
        );

    elseif totalProfit < 0 then

        totalProfitLabel.SetColor(
            "#FF4C4C"
        );

    end

    UI.CreateLabel(area)
        .SetText(
            "Realized Profit: " ..
            tostring(
                nation.realizedStockProfit
                or 0
            ) ..
            " gold"
        );

    UI.CreateLabel(area)
        .SetText(
            "Dividends Received: " ..
            tostring(
                nation.dividendsReceived
                or 0
            ) ..
            " gold"
        );

end


function ShowMarketOverview(
    parent,
    game
)

    local area =
        CreateContentArea(
            parent
        );

    local data =
        Mod.PublicGameData
        or {};

    local economy =
        data.globalEconomy
        or {};

    local market =
        economy.market
        or {};

    local companies =
        market.companies
        or {};

    UI.CreateLabel(area)
        .SetText(
            "MARKET OVERVIEW"
        );

    UI.CreateButton(area)
        .SetText(
            "BACK TO MARKET"
        )
        .SetOnClick(function()

            ShowStockMarket(
                parent,
                game
            );

        end);

    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );

    local topGainer =
        nil;

    local topLoser =
        nil;

    local largestCompany =
        nil;

    local mostTradedCompany =
    nil;

local mostTradedVolume =
    -1;

    local topGainPercent =
        nil;

    local topLossPercent =
        nil;

    for _, company
        in pairs(companies) do

        if company.active == true
            and company.delisted ~= true then

            local currentPrice =
                company.currentPrice
                or company.startingPrice
                or 0;

            local previousPrice =
                company.previousPrice
                or currentPrice;

            local changePercent =
                0;

            if previousPrice > 0 then

                changePercent =
                    (
                        (
                            currentPrice
                            - previousPrice
                        )
                        / previousPrice
                    )
                    * 100;

            end

            if topGainPercent == nil
                or changePercent > topGainPercent then

                topGainPercent =
                    changePercent;

                topGainer =
                    company;

            end

            if topLossPercent == nil
                or changePercent < topLossPercent then

                topLossPercent =
                    changePercent;

                topLoser =
                    company;

            end

            if largestCompany == nil
                or (
                    company.marketCap
                    or 0
                ) > (
                    largestCompany.marketCap
                    or 0
                ) then

                largestCompany =
                    company;

end
            local tradeVolume =
    company.lastTurnVolume
    or 0;

if mostTradedCompany == nil
    or tradeVolume > mostTradedVolume then

    mostTradedVolume =
        tradeVolume;

    mostTradedCompany =
        company;

end
            end
        end

    UI.CreateLabel(area)
        .SetText(
            "MARKET LEADERS"
        );

    if topGainer ~= nil then

        local gainerLabel =
            UI.CreateLabel(area)
                .SetText(
                    "Top Gainer: " ..
                    tostring(
                        topGainer.name
                    ) ..
                    " | +" ..
                    string.format(
                        "%.1f%%",
                        topGainPercent
                    )
                );

        gainerLabel.SetColor(
            "#32CD32"
        );

    end

    if topLoser ~= nil then

        local loserLabel =
            UI.CreateLabel(area)
                .SetText(
                    "Top Loser: " ..
                    tostring(
                        topLoser.name
                    ) ..
                    " | " ..
                    string.format(
                        "%.1f%%",
                        topLossPercent
                    )
                );

        loserLabel.SetColor(
            "#FF4C4C"
        );

    end

    if largestCompany ~= nil then

        local largestLabel =
            UI.CreateLabel(area)
                .SetText(
                    "Largest Market Cap: " ..
                    tostring(
                        largestCompany.name
                    ) ..
                    " | " ..
                    tostring(
                        largestCompany.marketCap
                        or 0
                    ) ..
                    " commerce"
                );

        largestLabel.SetColor(
            "#D4AF37"
        );

    end

if mostTradedCompany ~= nil
    and mostTradedVolume >= 0 then

    local mostTradedLabel =
        UI.CreateLabel(area)
            .SetText(
                "Most Traded: " ..
                tostring(
                    mostTradedCompany.name
                ) ..
                " | " ..
                tostring(
                    mostTradedVolume
                ) ..
                " shares"
            );

    mostTradedLabel.SetColor(
        "#D4AF37"
    );

end
UI.CreateLabel(area).SetText("----------------------------------------");
UI.CreateLabel(area).SetText("TOP 5 GAINERS / TOP 5 DECLINERS");

local rankedMoves = {};
for _, company in pairs(companies) do
    if company.active == true and company.delisted ~= true then
        local cp = company.currentPrice or company.startingPrice or 1;
        local pp = company.previousPrice or cp;
        local pct = pp > 0 and ((cp - pp) / pp * 100) or 0;
        table.insert(rankedMoves, {company=company, pct=pct});
    end
end
table.sort(rankedMoves, function(a,b) return a.pct > b.pct; end);

UI.CreateLabel(area).SetText("TOP 5 STOCKS").SetColor("#32CD32");
for i=1,math.min(5,#rankedMoves) do
    local entry = rankedMoves[i];
    local company = entry.company;
    local ownerNation = (economy.nations or {})[company.ownerPlayerID] or {};
    UI.CreateLabel(area).SetText(
        tostring(i) .. ". " .. tostring(company.name or "Company") ..
        " | " .. string.format("%+.1f%%", entry.pct) ..
        " | Confidence " .. tostring(math.floor((company.confidence or 50)+0.5)) .. "%" ..
        " | Unrest " .. tostring(math.floor((ownerNation.resourceUnrest or 0)+0.5))
    );
end

UI.CreateLabel(area).SetText("TOP 5 DOWNTREND STOCKS").SetColor("#FF4C4C");
for offset=0,math.min(4,#rankedMoves-1) do
    local entry = rankedMoves[#rankedMoves-offset];
    local company = entry.company;
    local ownerNation = (economy.nations or {})[company.ownerPlayerID] or {};
    UI.CreateLabel(area).SetText(
        tostring(offset+1) .. ". " .. tostring(company.name or "Company") ..
        " | " .. string.format("%+.1f%%", entry.pct) ..
        " | Confidence " .. tostring(math.floor((company.confidence or 50)+0.5)) .. "%" ..
        " | Unrest " .. tostring(math.floor((ownerNation.resourceUnrest or 0)+0.5))
    );
end

-- =========================================
-- GLOBAL MARKET ETF OVERVIEW
-- =========================================

local etf =
    market.etf
    or {};

local etfPrice =
    etf.currentPrice
    or etf.startingPrice
    or 100;

local etfPreviousPrice =
    etf.previousPrice
    or etfPrice;

local etfChangePercent =
    0;

if etfPreviousPrice > 0 then

    etfChangePercent =
        (
            etfPrice
            - etfPreviousPrice
        )
        / etfPreviousPrice
        * 100;

end


UI.CreateLabel(area)
    .SetText(
        "----------------------------------------"
    );

local etfTitle =
    UI.CreateLabel(area)
        .SetText(
            "GLOBAL MARKET ETF"
        );

etfTitle.SetColor(
    "#D4AF37"
);


UI.CreateLabel(area)
    .SetText(
        "Price: " ..
        string.format(
            "%.2f",
            etfPrice
        ) ..
        " Commerce"
    );


local etfChangeLabel =
    UI.CreateLabel(area)
        .SetText(
            "Turn Change: " ..
            string.format(
                "%.2f%%",
                etfChangePercent
            )
        );

if etfChangePercent > 0 then

    etfChangeLabel.SetColor(
        "#32CD32"
    );

elseif etfChangePercent < 0 then

    etfChangeLabel.SetColor(
        "#FF4C4C"
    );

end


UI.CreateLabel(area)
    .SetText(
        "ETF Members: " ..
        tostring(
            #(
                etf.memberCompanyIDs
                or {}
            )
        )
    );

end

function ShowMarketNews(
    parent,
    game
)

    local area =
        CreateContentArea(
            parent
        );

    local data =
        Mod.PublicGameData
        or {};

    local economy =
        data.globalEconomy
        or {};

    local market =
        economy.market
        or {};

    local news =
        market.news
        or {};

    UI.CreateLabel(area)
        .SetText(
            "MARKET NEWS"
        );

    UI.CreateButton(area)
        .SetText(
            "BACK TO MARKET"
        )
        .SetOnClick(function()

            ShowStockMarket(
                parent,
                game
            );

        end);

    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );

    if #news == 0 then

        UI.CreateLabel(area)
            .SetText(
                "No major market news yet."
            );

        return;
    end

    local startIndex =
        math.max(
            1,
            #news - 14
        );

    for index = #news, startIndex, -1 do

        local entry =
            news[index];

        local headline =
            UI.CreateLabel(area)
                .SetText(
                    "Turn " ..
                    tostring(
                        entry.turn
                        or "?"
                    ) ..
                    " | " ..
                    tostring(
                        entry.message
                        or
                        "Market update."
                    )
                );

        if entry.type == "war_bond" then

            headline.SetColor(
                "#D4AF37"
            );

        elseif entry.type == "stock_split" then

            headline.SetColor(
                "#D4AF37"
            );

        elseif entry.type == "dividend" then

            headline.SetColor(
                "#32CD32"
            );

        elseif entry.type == "etf_rebalance" then

    headline.SetColor(
        "#D4AF37"
    );

elseif entry.type == "etf_dividend" or entry.type == "etf_bonus" then

    headline.SetColor(
        "#32CD32"
    );

        elseif entry.type == "major_move" then

            local message =
                string.lower(
                    tostring(
                        entry.message
                        or ""
                    )
                );

            if string.find(
                message,
                "fell"
            ) then

                headline.SetColor(
                    "#FF4C4C"
                );

            else

                headline.SetColor(
                    "#32CD32"
                );

            end

        end

    end

end

function ShowMarketETF(
    parent,
    game
)

    local area =
        CreateContentArea(
            parent
        );

    local viewerMode = IsViewerMode(game);
    if viewerMode then
        ShowViewerModeNotice(area, "Viewer/reviewer mode: ETF information is visible, but personal ETF and War Bond transactions require an active player.");
    end

    local data =
        Mod.PublicGameData
        or {};

    local economy =
        data.globalEconomy
        or {};

    local market =
        economy.market
        or {};

    local etf =
        market.etf
        or {};

    local nation =
        (
            economy.nations
            and economy.nations[
                GetLocalPlayerID(game)
            ]
        )
        or {};


    -- =========================================
    -- HEADER
    -- =========================================

    UI.CreateLabel(area)
        .SetText(
            etf.name
            or "GLOBAL MARKET ETF"
        )
        .SetColor(
            "#D4AF37"
        );

    UI.CreateButton(area)
        .SetText(
            "BACK TO MARKETS"
        )
        .SetOnClick(function()

            ShowMarketsMenu(
                parent,
                game
            );

        end);

    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );


    -- =========================================
    -- ETF PRICE
    -- =========================================

    local currentPrice =
        etf.currentPrice
        or 100;

    local previousPrice =
        etf.previousPrice
        or currentPrice;

    local changePercent =
        0;

    if previousPrice > 0 then

        changePercent =
            (
                currentPrice
                - previousPrice
            )
            / previousPrice
            * 100;

    end

    UI.CreateLabel(area)
        .SetText(
            "ETF Price: " ..
            string.format(
                "%.2f",
                currentPrice
            ) ..
            " Commerce"
        );

    local changeLabel =
        UI.CreateLabel(area)
            .SetText(
                "Turn Change: " ..
                string.format(
                    "%.2f%%",
                    changePercent
                )
            );

    if changePercent > 0 then

        changeLabel.SetColor(
            "#32CD32"
        );

    elseif changePercent < 0 then

        changeLabel.SetColor(
            "#FF4C4C"
        );

    end

    UI.CreateLabel(area)
        .SetText(
            "Shares Available: " ..
            tostring(
                etf.sharesAvailable
                or 0
            )
        );

    UI.CreateLabel(area)
    .SetText(
        "Dividend / Share: " ..
        string.format(
            "%.2f",
            etf.dividendPerShare
            or 0
        ) ..
        " Commerce"
    );

UI.CreateLabel(area)
    .SetText(
        "Total ETF Dividends Paid: " ..
        tostring(
            etf.totalDividendsPaid
            or 0
        ) ..
        " Commerce"
    );

    local currentTurn = economy.currentEconomyTurn or data.tradeTurn or 0;
    local lastRebalance = etf.lastRebalanceTurn or 0;
    local turnsUntil = math.max(0, 5 - (currentTurn - lastRebalance));
    UI.CreateLabel(area).SetText(
        "ETF Rebalance: every 5 turns | Next in " .. tostring(turnsUntil) .. " turn(s)"
    );
    UI.CreateLabel(area).SetText(
        "Your ETF 5-Turn Bonus This Cycle: +" .. tostring(nation.etfBonusThisTurn or 0) ..
        " Commerce | Lifetime ETF Rebalance Bonuses: " .. tostring(nation.etfRebalanceBonusesReceived or 0)
    );

    -- =========================================
    -- ETF MEMBERS
    -- =========================================

    UI.CreateLabel(area)
        .SetText(
            ""
        );

    UI.CreateLabel(area)
        .SetText(
            "TOP 5 ETF COMPANIES"
        )
        .SetColor(
            "#D4AF37"
        );

    local memberIDs =
        etf.memberCompanyIDs
        or {};

    if #memberIDs == 0 then

        UI.CreateLabel(area)
            .SetText(
                "ETF members will be selected after market processing."
            );

    else

        for index,companyID in ipairs(
            memberIDs
        ) do

            local company =
                market.companies
                and market.companies[
                    companyID
                ];

            if company ~= nil then

                local companyName =
                    company.name
                    or (
                        "Company " ..
                        tostring(
                            companyID
                        )
                    );

                local companyPrice =
                    company.currentPrice
                    or company.startingPrice
                    or 1;

                UI.CreateLabel(area)
                    .SetText(
                        tostring(index) ..
                        ". " ..
                        tostring(companyName) ..
                        " | " ..
                        string.format(
                            "%.2f",
                            companyPrice
                        ) ..
                        " Commerce"
                    )
                    .SetColor(
                        "#D4AF37"
                    );

            end

        end

    end


    -- War Bonds removed from United Frontier. Markets now focus on flagship stocks, ETF and investments.

    -- =========================================
    -- PLAYER ETF POSITION
    -- =========================================

    UI.CreateLabel(area)
        .SetText(
            ""
        );

    UI.CreateLabel(area)
        .SetText(
            "YOUR ETF POSITION"
        );

    local ownedShares =
        nation.etfShares
        or 0;

    local costBasis =
        nation.etfCostBasis
        or 0;

    local positionValue =
        ownedShares
        * currentPrice;

    local unrealizedProfit =
        positionValue
        - costBasis;

    UI.CreateLabel(area)
        .SetText(
            "Shares Owned: " ..
            tostring(
                ownedShares
            )
        );

    UI.CreateLabel(area)
        .SetText(
            "Position Value: " ..
            string.format(
                "%.2f",
                positionValue
            ) ..
            " Commerce"
        );

    UI.CreateLabel(area)
        .SetText(
            "Cost Basis: " ..
            string.format(
                "%.2f",
                costBasis
            ) ..
            " Commerce"
        );

    UI.CreateLabel(area)
    .SetText(
        "ETF Dividends Received: " ..
        tostring(
            nation.etfDividendsReceived
            or 0
        ) ..
        " Commerce"
    );

UI.CreateLabel(area)
    .SetText(
        "Realized ETF Profit: " ..
        string.format(
            "%.2f",
            nation.realizedETFProfit
            or 0
        ) ..
        " Commerce"
    );

    local profitLabel =
        UI.CreateLabel(area)
            .SetText(
                "Unrealized P/L: " ..
                string.format(
                    "%.2f",
                    unrealizedProfit
                ) ..
                " Commerce"
            );

    if unrealizedProfit > 0 then

        profitLabel.SetColor(
            "#32CD32"
        );

    elseif unrealizedProfit < 0 then

        profitLabel.SetColor(
            "#FF4C4C"
        );

    end
-- =========================================
-- BUY ETF
-- =========================================

local buyShares =
    1;

local buyPreview =
    UI.CreateLabel(area);

local function UpdateBuyPreview()

    if buyShares < 1 then
        buyShares = 1;
    end

    local availableShares =
        etf.sharesAvailable
        or 0;

    if availableShares > 0
        and buyShares > availableShares then

        buyShares =
            availableShares;
    end

    local totalCost =
        buyShares
        * currentPrice;

    buyPreview.SetText(
        "Buy " ..
        tostring(buyShares) ..
        " share(s) | Cost: " ..
        string.format(
            "%.2f",
            totalCost
        ) ..
        " Commerce"
    );

end


UI.CreateButton(area)
    .SetText("-1")
    .SetOnClick(function()

        buyShares =
            math.max(
                1,
                buyShares - 1
            );

        UpdateBuyPreview();

    end);


UI.CreateButton(area)
    .SetText("+1")
    .SetOnClick(function()

        buyShares =
            buyShares + 1;

        UpdateBuyPreview();

    end);


UI.CreateButton(area)
    .SetText("+5")
    .SetOnClick(function()

        buyShares =
            buyShares + 5;

        UpdateBuyPreview();

    end);


UI.CreateButton(area)
    .SetText("BUY ETF")
    .SetInteractable(not viewerMode)
    .SetOnClick(function()

        if buyShares <= 0 then
            return;
        end

        SafeSendGameCustomMessage(game, 
            "Buy ETF",
            {
                type =
                    "buyETF",

                shares =
                    buyShares
            },
            function()

                ShowMarketETF(
                    parent,
                    game
                );

            end
        );

    end);


UpdateBuyPreview();


-- =========================================
-- SELL ETF
-- =========================================

local sellShares =
    1;

local sellPreview =
    UI.CreateLabel(area);

local function UpdateSellPreview()

    if ownedShares <= 0 then

        sellShares =
            0;

    elseif sellShares > ownedShares then

        sellShares =
            ownedShares;

    elseif sellShares < 1 then

        sellShares =
            1;

    end

    local totalValue =
        sellShares
        * currentPrice;

    sellPreview.SetText(
        "Sell " ..
        tostring(sellShares) ..
        " share(s) | Value: " ..
        string.format(
            "%.2f",
            totalValue
        ) ..
        " Commerce"
    );

end


UI.CreateButton(area)
    .SetText("-1")
    .SetOnClick(function()

        sellShares =
            sellShares - 1;

        UpdateSellPreview();

    end);


UI.CreateButton(area)
    .SetText("+1")
    .SetOnClick(function()

        sellShares =
            sellShares + 1;

        UpdateSellPreview();

    end);


UI.CreateButton(area)
    .SetText("+5")
    .SetOnClick(function()

        sellShares =
            sellShares + 5;

        UpdateSellPreview();

    end);


UI.CreateButton(area)
    .SetText("SELL ETF")
    .SetInteractable(not viewerMode)
    .SetOnClick(function()

        if sellShares <= 0 then
            return;
        end

        SafeSendGameCustomMessage(game, 
            "Sell ETF",
            {
                type =
                    "sellETF",

                shares =
                    sellShares
            },
            function()

                ShowMarketETF(
                    parent,
                    game
                );

            end
        );

    end);


UpdateSellPreview();

end

function ShowInvestments(
    parent,
    game
)

    local area =
        CreateContentArea(
            parent
        );


    UI.CreateLabel(area)
        .SetText(
            "INVESTMENTS"
        );


    UI.CreateLabel(area)
        .SetText(
            "Create multinational development projects, invest in other nations, and track project outcomes."
        );


    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );


    local nav =
        UI.CreateHorizontalLayoutGroup(
            area
        );


    UI.CreateButton(nav)
        .SetText(
            "Project Catalog"
        )
        .SetOnClick(function()


            ShowInvestmentCatalog(
                parent,
                game
            );

        end);


    UI.CreateButton(nav)
        .SetText(
            "Open Projects"
        )
        .SetOnClick(function()


            ShowOpenInvestmentProjects(
                parent,
                game
            );

        end);


    UI.CreateButton(nav)
        .SetText(
            "My Projects"
        )
        .SetOnClick(function()


            ShowMyInvestmentProjects(
                parent,
                game
            );

        end);


    UI.CreateButton(nav)
        .SetText(
            "My Investments"
        )
        .SetOnClick(function()


            ShowMyInvestments(
                parent,
                game
            );

        end);


    UI.CreateButton(nav)
        .SetText(
            "Archive"
        )
        .SetOnClick(function()


            ShowInvestmentArchive(
                parent,
                game
            );

        end);


    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );


    local data =
        Mod.PublicGameData or {};


    local openCount = 0;
    local activeCount = 0;


    for _, project
        in pairs(
            data.investmentProjects
            or {}
        ) do


        if project.status
            == "funding" then


            openCount =
                openCount + 1;


        elseif project.status
            == "active" then


            activeCount =
                activeCount + 1;

        end

    end


    UI.CreateLabel(area)
        .SetText(
            "Open Funding Projects: " ..
            tostring(
                openCount
            )
        );


    UI.CreateLabel(area)
        .SetText(
            "Projects in Development: " ..
            tostring(
                activeCount
            )
        );


    UI.CreateLabel(area)
        .SetText(
            "Archived Projects: " ..
            tostring(
                #(
                    data.completedInvestmentProjects
                    or {}
                )
            )
        );

end


function FindInvestmentType(
    typeID
)

    for _, projectType
        in ipairs(
            InvestmentProjectTypes
        ) do


        if projectType.id
            == typeID then


            return projectType;

        end

    end


    return nil;

end


function ShowInvestmentCatalog(
    parent,
    game
)

    local area =
        CreateContentArea(
            parent
        );


    UI.CreateLabel(area)
        .SetText(
            "INVESTMENT PROJECT CATALOG"
        );


    UI.CreateLabel(area)
        .SetText(
            "Select a project category to review its funding size, duration, risk, and possible outcome."
        );


    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );


    for _, projectType
        in ipairs(
            InvestmentProjectTypes
        ) do


        local typeID =
            projectType.id;


        local group =
            UI.CreateVerticalLayoutGroup(
                area
            );


        UI.CreateLabel(group)
            .SetText(
                projectType.name
            );


        UI.CreateLabel(group)
            .SetText(
                "Maximum Funding Goal: " ..
                tostring(
                    projectType.maxGoal
                ) ..
                " gold"
            );


        UI.CreateLabel(group)
            .SetText(
                "Development Duration: " ..
                tostring(
                    projectType.duration
                ) ..
                " turns"
            );


        UI.CreateLabel(group)
            .SetText(
                "Success Chance: " ..
                tostring(
                    projectType.successChance
                ) ..
                "%"
            );


        UI.CreateLabel(group)
            .SetText(
                "Success Return: +" ..
                tostring(
                    projectType.successReturn
                ) ..
                "%"
            );


        UI.CreateLabel(group)
            .SetText(
                "Failure Recovery: " ..
                tostring(
                    projectType.failureRecovery
                ) ..
                "%"
            );


        UI.CreateLabel(group)
            .SetText(
                "Risk: " ..
                tostring(
                    projectType.risk
                )
            );


        UI.CreateButton(group)
            .SetText(
                "CREATE " ..
                string.upper(
                    projectType.name
                )
            )
            .SetOnClick(function()


                ShowCreateInvestmentProject(
                    parent,
                    game,
                    typeID
                );

            end);


        UI.CreateLabel(group)
            .SetText(
                "----------------------------------------"
            );

    end

end


function ShowCreateInvestmentProject(
    parent,
    game,
    projectTypeID
)

    local area =
        CreateContentArea(
            parent
        );

    if IsViewerMode(game) then
        ShowViewerModeNotice(area, "Creating an investment project requires an active player and is unavailable in viewer/reviewer mode.");
        return;
    end


    local projectType =
        FindInvestmentType(
            projectTypeID
        );


    if projectType == nil then


        UI.CreateLabel(area)
            .SetText(
                "Investment project type could not be found."
            );


        return;

    end


    local fundingGoal =
        math.min(
            500,
            projectType.maxGoal
        );


    if fundingGoal < 200 then

        fundingGoal =
            200;

    end


    local creatorContribution =
        math.ceil(
            fundingGoal
            * 0.20
        );


    local investorLimit =
        4;
local availableGold =
    GetPlayerGold(
        game,
        GetLocalPlayerID(game)
    );

local goldLabel =
    UI.CreateLabel(area);

    UI.CreateLabel(area)
        .SetText(
            "CREATE " ..
            string.upper(
                projectType.name
            )
        );


    UI.CreateLabel(area)
        .SetText(
            "Risk: " ..
            tostring(
                projectType.risk
            ) ..
            " | Success: " ..
            tostring(
                projectType.successChance
            ) ..
            "% | Return: +" ..
            tostring(
                projectType.successReturn
            ) ..
            "%"
        );


    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );


    local preview =
        UI.CreateLabel(area);


    local function UpdatePreview()


        local minimumContribution =
            math.ceil(
                fundingGoal
                * 0.20
            );


        if creatorContribution
            < minimumContribution then


            creatorContribution =
                minimumContribution;

        end


        if creatorContribution
            > fundingGoal then


            creatorContribution =
                fundingGoal;

        end
local remainingGold =
    availableGold
    - creatorContribution;

if remainingGold < 0 then
    remainingGold = 0;
end

goldLabel.SetText(
    "Available Gold: " ..
    tostring(availableGold) ..
    "\nCommitted Gold: " ..
    tostring(creatorContribution) ..
    "\nRemaining Gold: " ..
    tostring(remainingGold)
);

        if fundingGoal < 200 then

            fundingGoal =
                200;

        end


        if fundingGoal
            > projectType.maxGoal then


            fundingGoal =
                projectType.maxGoal;

        end


        preview.SetText(
            "Funding Goal: " ..
            tostring(
                fundingGoal
            ) ..
            " gold\n" ..

            "Your Contribution: " ..
            tostring(
                creatorContribution
            ) ..
            " gold\n" ..

            "Minimum Required: " ..
            tostring(
                math.ceil(
                    fundingGoal
                    * 0.20
                )
            ) ..
            " gold\n" ..

            "Outside Investor Limit: " ..
            tostring(
                investorLimit
            )
        );

    end


    UpdatePreview();


    UI.CreateLabel(area)
        .SetText(
            "FUNDING GOAL"
        );


    local fundingButtons =
        UI.CreateHorizontalLayoutGroup(
            area
        );


    UI.CreateButton(fundingButtons)
        .SetText(
            "-100"
        )
        .SetOnClick(function()


            fundingGoal =
                math.max(
                    200,
                    fundingGoal - 100
                );


            UpdatePreview();

        end);


    UI.CreateButton(fundingButtons)
        .SetText(
            "+100"
        )
        .SetOnClick(function()


            fundingGoal =
                math.min(
                    projectType.maxGoal,
                    fundingGoal + 100
                );


            UpdatePreview();

        end);


    UI.CreateButton(fundingButtons)
        .SetText(
            "MAX"
        )
        .SetOnClick(function()


            fundingGoal =
                projectType.maxGoal;


            UpdatePreview();

        end);


    UI.CreateLabel(area)
        .SetText(
            "YOUR CONTRIBUTION"
        );


    local contributionButtons =
        UI.CreateHorizontalLayoutGroup(
            area
        );


    UI.CreateButton(contributionButtons)
        .SetText(
            "-100"
        )
        .SetOnClick(function()


            creatorContribution =
                creatorContribution
                - 100;


            UpdatePreview();

        end);


    UI.CreateButton(contributionButtons)
        .SetText(
            "+100"
        )
        .SetOnClick(function()


            creatorContribution =
                creatorContribution
                + 100;


            UpdatePreview();

        end);


    UI.CreateButton(contributionButtons)
        .SetText(
            "MIN"
        )
        .SetOnClick(function()


            creatorContribution =
                math.ceil(
                    fundingGoal
                    * 0.20
                );


            UpdatePreview();

        end);


    UI.CreateButton(contributionButtons)
        .SetText(
            "FULL"
        )
        .SetOnClick(function()


            creatorContribution =
                fundingGoal;


            UpdatePreview();

        end);


    UI.CreateLabel(area)
        .SetText(
            "OUTSIDE INVESTOR LIMIT"
        );


    local investorButtons =
        UI.CreateHorizontalLayoutGroup(
            area
        );


    UI.CreateButton(investorButtons)
        .SetText(
            "-"
        )
        .SetOnClick(function()


            investorLimit =
                math.max(
                    2,
                    investorLimit - 1
                );


            UpdatePreview();

        end);


    UI.CreateButton(investorButtons)
        .SetText(
            "+"
        )
        .SetOnClick(function()


            investorLimit =
                math.min(
                    6,
                    investorLimit + 1
                );


            UpdatePreview();

        end);


    UI.CreateButton(area)
        .SetText(
            "PUBLISH PROJECT"
        )
        .SetOnClick(function()

            local currentGold =
    GetPlayerGold(
        game,
        GetLocalPlayerID(game)
    );

if creatorContribution > currentGold then

    UI.Alert(
        "You do not have enough gold for this contribution.\n\n" ..
        "Available Gold: " ..
        tostring(currentGold) ..
        "\nRequired Gold: " ..
        tostring(creatorContribution)
    );

    return;
end

            SafeSendGameCustomMessage(game, 
                "Publishing project...",

                {

                    type =
                        "publishInvestmentProject",

                    projectTypeID =
                        projectType.id,

                    fundingGoal =
                        fundingGoal,

                    creatorContribution =
                        creatorContribution,

                    investorLimit =
                        investorLimit

                },

                function(result)


                    UI.Alert(
                        result
                        and result.message
                        or
                        "Project request processed."
                    );


                    if result ~= nil
                        and result.success then


                        ShowMyInvestmentProjects(
                            parent,
                            game
                        );

                    end

                end
            );

        end);


    UI.CreateButton(area)
        .SetText(
            "Back"
        )
        .SetOnClick(function()


            ShowInvestmentCatalog(
                parent,
                game
            );

        end);

end
function ShowOpenInvestmentProjects(
    parent,
    game
)

    local area =
        CreateContentArea(
            parent
        );

    if IsViewerMode(game) then
        ShowViewerModeNotice(area, "Investment participation requires an active player and is unavailable in viewer/reviewer mode.");
        return;
    end


    local data =
        Mod.PublicGameData or {};


    UI.CreateLabel(area)
        .SetText(
            "OPEN INVESTMENT PROJECTS"
        );


    local found =
        false;


    for _, project
        in pairs(
            data.investmentProjects
            or {}
        ) do


        if project.status
            == "funding" then


            found =
                true;


            local selectedID =
                project.id;


            local creatorName =
                GetPlayerName(
                    game,
                    project.creatorID
                );


            local remaining =
                project.fundingGoal
                - project.currentFunding;


            local group =
                UI.CreateVerticalLayoutGroup(
                    area
                );


            UI.CreateLabel(group)
                .SetText(
                    project.projectName
                );


            UI.CreateLabel(group)
                .SetText(
                    "Creator: " ..
                    creatorName
                );


            if project.createdByAI then


                UI.CreateLabel(group)
                    .SetText(
                        "Creator Type: AI Nation"
                    );
            end


            UI.CreateLabel(group)
                .SetText(
                    "Risk: " ..
                    tostring(
                        project.risk
                    ) ..
                    " | Success: " ..
                    tostring(
                        project.successChance
                    ) ..
                    "%"
                );


            UI.CreateLabel(group)
                .SetText(
                    "Funding: " ..
                    tostring(
                        project.currentFunding
                    ) ..
                    " / " ..
                    tostring(
                        project.fundingGoal
                    )
                );


            UI.CreateLabel(group)
                .SetText(
                    "Remaining: " ..
                    tostring(
                        remaining
                    ) ..
                    " gold"
                );


            UI.CreateLabel(group)
                .SetText(
                    "Outside Investors: " ..
                    tostring(
                        CountOutsideProjectInvestors(
                            project
                        )
                    ) ..
                    " / " ..
                    tostring(
                        project.investorLimit
                    )
                );


            if project.creatorID
                ~= GetLocalPlayerID(game) then


                local alreadyInvested =
                    GetOurProjectInvestment(
                        project,
                        game
                    );


                local cap =
                    math.floor(
                        project.fundingGoal
                        * 0.25
                    );


                local remainingCap =
                    math.max(
                        0,
                        cap
                        - alreadyInvested
                    );


                UI.CreateLabel(group)
                    .SetText(
                        "You Invested: " ..
                        tostring(
                            alreadyInvested
                        )
                    );


                UI.CreateLabel(group)
                    .SetText(
                        "Your Remaining Cap: " ..
                        tostring(
                            remainingCap
                        )
                    );


                local maximum =
                    math.min(
                        remaining,
                        remainingCap
                    );


                if maximum > 0 then


                    local amount =
                        math.min(
                            50,
                            maximum
                        );


                    local amountLabel =
                        UI.CreateLabel(group);
                    
                    local availableGold =
    GetPlayerGold(
        game,
        GetLocalPlayerID(game)
    );

local goldLabel =
    UI.CreateLabel(group);

                    local function UpdateAmount()


local remainingGold =
    availableGold
    - amount;

if remainingGold < 0 then
    remainingGold = 0;
end

amountLabel.SetText(
    "Investment Amount: " ..
    tostring(amount)
);

goldLabel.SetText(
    "Available Gold: " ..
    tostring(availableGold) ..
    "\nCommitted Gold: " ..
    tostring(amount) ..
    "\nRemaining Gold: " ..
    tostring(remainingGold)
);

end
                    UpdateAmount();


                    local buttons =
                        UI.CreateHorizontalLayoutGroup(
                            group
                        );


                    UI.CreateButton(buttons)
                        .SetText("-50")
                        .SetOnClick(function()


                            amount =
                                math.max(
                                    1,
                                    amount - 50
                                );


                            UpdateAmount();

                        end);


                    UI.CreateButton(buttons)
                        .SetText("+50")
                        .SetOnClick(function()


                            amount =
                                math.min(
                                    maximum,
                                    amount + 50
                                );


                            UpdateAmount();

                        end);


                    UI.CreateButton(buttons)
                        .SetText("MAX")
                        .SetOnClick(function()


                            amount =
                                maximum;


                            UpdateAmount();

                        end);


                    UI.CreateButton(group)
                        .SetText(
                            "INVEST GOLD"
                        )
                        .SetOnClick(function()

local currentGold =
    GetPlayerGold(
        game,
        GetLocalPlayerID(game)
    );

if amount > currentGold then

    UI.Alert(
        "You do not have enough gold for this investment.\n\n" ..
        "Available Gold: " ..
        tostring(currentGold) ..
        "\nRequired Gold: " ..
        tostring(amount)
    );

    return;
end

                            SafeSendGameCustomMessage(game, 
                                "Investing...",

                                {
                                    type =
                                        "investInProject",

                                    projectID =
                                        selectedID,

                                    amount =
                                        amount
                                },

                                function(result)


                                    UI.Alert(
                                        result
                                        and result.message
                                        or
                                        "Investment processed."
                                    );


                                    ShowOpenInvestmentProjects(
                                        parent,
                                        game
                                    );

                                end
                            );

                        end);
                end


            else


                UI.CreateLabel(group)
                    .SetText(
                        "This is your project."
                    );
            end


            UI.CreateLabel(group)
                .SetText(
                    "----------------------------------------"
                );
        end
    end


    if not found then


        UI.CreateLabel(area)
            .SetText(
                "There are no projects currently accepting funding."
            );
    end
end


-- =========================================================
-- MY INVESTMENTS
-- =========================================================

function ShowMyInvestments(
    parent,
    game
)

    local area =
        CreateContentArea(
            parent
        );

    if IsViewerMode(game) then
        ShowViewerModeNotice(area, "My Investments is unavailable in viewer/reviewer mode because no active player is associated with this view.");
        return;
    end


    local data =
        Mod.PublicGameData or {};


    UI.CreateLabel(area)
        .SetText(
            "MY INVESTMENTS"
        );

        local pendingActions =
    data.pendingInvestmentActions
    or {};

local pendingFound =
    false;

for _, action
    in pairs(pendingActions) do

    if action.type == "invest"
        and action.playerID == GetLocalPlayerID(game) then

        pendingFound =
            true;

        local pendingProject =
            nil;

        for _, project
            in pairs(
                data.investmentProjects
                or {}
            ) do

            if project.id
                == action.projectID then

                pendingProject =
                    project;

                break;
            end
        end

        local projectName =
            "Unknown Project";

        if pendingProject ~= nil then

            projectName =
                pendingProject.projectName
                or projectName;

        end

        local selectedProjectID =
            action.projectID;

        UI.CreateLabel(area)
            .SetText(
                "PENDING: " ..
                tostring(projectName) ..
                " | " ..
                tostring(
                    action.amount
                    or 0
                ) ..
                " gold"
            );

        UI.CreateButton(area)
            .SetText(
                "CANCEL PENDING INVESTMENT"
            )
            .SetOnClick(function()

                SafeSendGameCustomMessage(game, 
                    "Cancelling investment...",

                    {
                        type =
                            "cancelPendingInvestment",

                        projectID =
                            selectedProjectID
                    },

                    function(result)

                        UI.Alert(
                            result
                            and result.message
                            or
                            "Cancellation processed."
                        );

                        ShowMyInvestments(
                            parent,
                            game
                        );

                    end
                );

            end);

    end
end

if pendingFound then

    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );

end

    local found =
        false;


    for _, project
        in pairs(
            data.investmentProjects
            or {}
        ) do


        if project.creatorID
            ~= GetLocalPlayerID(game) then


            local amount =
                GetOurProjectInvestment(
                    project,
                    game
                );


            if amount > 0 then


                found =
                    true;


                UI.CreateLabel(area)
                    .SetText(
                        project.projectName ..
                        " | Invested: " ..
                        tostring(
                            amount
                        ) ..
                        " | Status: " ..
                        tostring(
                            project.status
                        )
                    );


                if project.status
                    == "active"

                    and project.completionTurn
                    ~= nil then


                    local remaining =
                        project.completionTurn
                        - (
                            data.tradeTurn
                            or 0
                        );


                    UI.CreateLabel(area)
                        .SetText(
                            "Completion in " ..
                            tostring(
                                math.max(
                                    0,
                                    remaining
                                )
                            ) ..
                            " turn(s)"
                        );
                end
            end
        end
    end


    if not found then


        UI.CreateLabel(area)
            .SetText(
                "You currently have no active outside investments."
            );
    end


    UI.CreateLabel(area)
        .SetText(
            "Completed investments can be reviewed in the Archive."
        );
end


-- =========================================================
-- MY PROJECTS
-- =========================================================

function ShowMyInvestmentProjects(
    parent,
    game
)

    local area =
        CreateContentArea(
            parent
        );

    if IsViewerMode(game) then
        ShowViewerModeNotice(area, "My Investment Projects is unavailable in viewer/reviewer mode because no active player is associated with this view.");
        return;
    end


    local data =
        Mod.PublicGameData or {};


    UI.CreateLabel(area)
        .SetText(
            "MY PROJECTS"
        );


    local found =
        false;


    for _, project
        in pairs(
            data.investmentProjects
            or {}
        ) do


        if project.creatorID
            == GetLocalPlayerID(game) then


            found =
                true;


            local group =
                UI.CreateVerticalLayoutGroup(
                    area
                );


            UI.CreateLabel(group)
                .SetText(
                    project.projectName
                );


            UI.CreateLabel(group)
                .SetText(
                    "Status: " ..
                    tostring(
                        project.status
                    )
                );


            UI.CreateLabel(group)
                .SetText(
                    "Funding: " ..
                    tostring(
                        project.currentFunding
                    ) ..
                    " / " ..
                    tostring(
                        project.fundingGoal
                    )
                );


            UI.CreateLabel(group)
                .SetText(
                    "Your Contribution: " ..
                    tostring(
                        project.creatorContribution
                    )
                );


            UI.CreateLabel(group)
                .SetText(
                    "Outside Investors: " ..
                    tostring(
                        CountOutsideProjectInvestors(
                            project
                        )
                    ) ..
                    " / " ..
                    tostring(
                        project.investorLimit
                    )
                );


            if project.status
                == "funding"

                and project.fundingDeadline
                ~= nil then


                UI.CreateLabel(group)
                    .SetText(
                        "Funding Window: " ..
                        tostring(
                            math.max(
                                0,
                                project.fundingDeadline
                                - (
                                    data.tradeTurn
                                    or 0
                                )
                            )
                        ) ..
                        " turn(s)"
                    );
            end


            if project.status
                == "active"

                and project.completionTurn
                ~= nil then


                UI.CreateLabel(group)
                    .SetText(
                        "Completion: " ..
                        tostring(
                            math.max(
                                0,
                                project.completionTurn
                                - (
                                    data.tradeTurn
                                    or 0
                                )
                            )
                        ) ..
                        " turn(s)"
                    );
            end


            UI.CreateLabel(group)
                .SetText(
                    "----------------------------------------"
                );
        end
    end


    if not found then


        UI.CreateLabel(area)
            .SetText(
                "You do not currently have an active project."
            );
    end


    UI.CreateLabel(area)
        .SetText(
            "Finished projects remain permanently available in the Archive."
        );
end


-- =========================================================
-- INVESTMENT ARCHIVE
-- =========================================================
function ShowInvestmentArchive(
    parent,
    game
)

    local area =
        CreateContentArea(
            parent
        );


    local data =
        Mod.PublicGameData or {};


    local archive =
        data.completedInvestmentProjects
        or {};


    UI.CreateLabel(area)
        .SetText(
            "COMPLETED PROJECT ARCHIVE"
        );


    UI.CreateLabel(area)
        .SetText(
            "Finished, failed, and expired projects remain recorded here."
        );


    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );


    if #archive == 0 then


        UI.CreateLabel(area)
            .SetText(
                "No projects have been archived yet."
            );


        return;
    end


    for i =
        #archive,
        1,
        -1 do


        local project =
            archive[i];


        local selectedProject =
            project;


        local creator =
            GetPlayerName(
                game,
                project.creatorID
            );


        local resultText =
            tostring(
                project.result
                or project.status
                or "Unknown"
            );


        UI.CreateLabel(area)
            .SetText(
                tostring(
                    project.projectName
                ) ..
                " | " ..
                creator ..
                " | Result: " ..
                string.upper(
                    resultText
                )
            );


        UI.CreateButton(area)
            .SetText(
                "View Project #" ..
                tostring(
                    project.id
                )
            )
            .SetOnClick(function()

                ShowArchivedProjectDetails(
                    parent,
                    game,
                    selectedProject
                );

            end);


        UI.CreateLabel(area)
            .SetText(
                "----------------------------------------"
            );
    end
end


function ShowArchivedProjectDetails(
    parent,
    game,
    project
)

    local area =
        CreateContentArea(
            parent
        );


    UI.CreateLabel(area)
        .SetText(
            "PROJECT ARCHIVE DETAILS"
        );


    UI.CreateLabel(area)
        .SetText(
            tostring(
                project.projectName
            )
        );


    UI.CreateLabel(area)
        .SetText(
            "Creator: " ..
            GetPlayerName(
                game,
                project.creatorID
            )
        );


    if project.createdByAI then


        UI.CreateLabel(area)
            .SetText(
                "Created By: AI Nation"
            );
    else


        UI.CreateLabel(area)
            .SetText(
                "Created By: Human Nation"
            );
    end


    UI.CreateLabel(area)
        .SetText(
            "Result: " ..
            string.upper(
                tostring(
                    project.result
                    or project.status
                    or "Unknown"
                )
            )
        );


    UI.CreateLabel(area)
        .SetText(
            "Funding Goal: " ..
            tostring(
                project.fundingGoal
                or 0
            )
        );


    UI.CreateLabel(area)
        .SetText(
            "Final Funding: " ..
            tostring(
                project.currentFunding
                or 0
            )
        );


    UI.CreateLabel(area)
        .SetText(
            "Risk: " ..
            tostring(
                project.risk
                or "Unknown"
            )
        );


    UI.CreateLabel(area)
        .SetText(
            "Success Chance: " ..
            tostring(
                project.successChance
                or 0
            ) ..
            "%"
        );


    UI.CreateLabel(area)
        .SetText(
            "Success Return: +" ..
            tostring(
                project.successReturn
                or 0
            ) ..
            "%"
        );


    UI.CreateLabel(area)
        .SetText(
            "Failure Recovery: " ..
            tostring(
                project.failureRecovery
                or 0
            ) ..
            "%"
        );


    UI.CreateLabel(area)
        .SetText(
            "Created Turn: " ..
            tostring(
                project.createdTurn
                or "?"
            )
        );


    if project.startedTurn
        ~= nil then


        UI.CreateLabel(area)
            .SetText(
                "Development Started: Turn " ..
                tostring(
                    project.startedTurn
                )
            );
    end


    UI.CreateLabel(area)
        .SetText(
            "Ended Turn: " ..
            tostring(
                project.endedTurn
                or "?"
            )
        );


    if project.resolutionRoll
        ~= nil then


        UI.CreateLabel(area)
            .SetText(
                "Resolution Roll: " ..
                tostring(
                    project.resolutionRoll
                ) ..
                " / 100"
            );
    end


    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );


    UI.CreateLabel(area)
        .SetText(
            "INVESTORS"
        );


    for _, investment
        in pairs(
            project.investments
            or {}
        ) do


        local name =
            GetPlayerName(
                game,
                investment.playerID
            );


        local role =
            "Investor";


        if investment.isCreator then
            role = "Creator";
        end


        UI.CreateLabel(area)
            .SetText(
                name ..
                " (" ..
                role ..
                ") | Invested: " ..
                tostring(
                    investment.amount
                    or 0
                ) ..
                " | Payout: " ..
                tostring(
                    investment.payout
                    or 0
                )
            );
    end


    UI.CreateButton(area)
        .SetText(
            "Back to Archive"
        )
        .SetOnClick(function()

            ShowInvestmentArchive(
                parent,
                game
            );

        end);
end


function ShowInvestmentHistory(
    parent,
    game
)

    local area =
        CreateContentArea(
            parent
        );


    local data =
        Mod.PublicGameData or {};


    local history =
        data.investmentHistory
        or {};


    UI.CreateLabel(area)
        .SetText(
            "GLOBAL INVESTMENT HISTORY"
        );


    if #history == 0 then


        UI.CreateLabel(area)
            .SetText(
                "No investment events recorded yet."
            );


        return;
    end


    local shown = 0;


    for i =
        #history,
        1,
        -1 do


        if shown
            >= MAX_VISIBLE_HISTORY then

            break;
        end


        local event =
            history[i];


        UI.CreateLabel(area)
            .SetText(
                "Turn " ..
                tostring(
                    event.turn
                    or "?"
                ) ..
                " - " ..
                tostring(
                    event.message
                    or "Investment event"
                )
            );


        shown =
            shown + 1;
    end
end
function ShowAIManagerMenu(
    parent,
    game
)

    local area =
        CreateContentArea(
            parent
        );

    UI.CreateButton(area)
        .SetText(
            "BACK TO OVERVIEW"
        )
        .SetOnClick(function()

            ShowOverview(
                parent,
                game
            );

        end);

    UI.CreateLabel(area)
        .SetText(
            "AI MANAGER"
        );

    UI.CreateLabel(area)
        .SetText(
            "Optional national automation. The AI Manager reserves a turn budget and can use it for Markets, Investments, strategic Resources, Recruiters, and military infrastructure. It does not change diplomacy, ideology, or tax policy. If disabled, manual control returns on the following turn."
        );

    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );

    if GetClientSetting(
        "PlayerAIManagerEnabled",
        true
    ) ~= true then

        UI.CreateLabel(area)
            .SetText(
                "The host has disabled the AI Manager."
            );

        return;
    end

    local nation =
        GetOurNationState(
            game
        );

    if nation == nil
        or nation.setupComplete ~= true then

        UI.CreateLabel(area)
            .SetText(
                "Complete National Setup before using the AI Manager."
            );

        return;
    end

    local economy =
        (
            Mod.PublicGameData
            or {}
        ).globalEconomy
        or {};

    local enabled =
        nation.aiManagerEnabled == true;

    local cancelTurn =
        nation.aiManagerCancelTurn;

    local statusText =
        enabled
        and "ACTIVE"
        or "OFF";

    if enabled
        and cancelTurn ~= nil then

        statusText =
            "CANCEL PENDING - stops on Turn " ..
            tostring(
                cancelTurn
            );

    end

    UI.CreateLabel(area)
        .SetText(
            "Status: " ..
            statusText
        );

    UI.CreateLabel(area)
        .SetText(
            "Current Budget: " ..
            tostring(
                nation.aiManagerBudget
                or 100
            ) ..
            " Commerce per turn"
        );

    if enabled then

        UI.CreateLabel(area)
            .SetText(
                "Budget Remaining This Turn: " ..
                tostring(
                    nation.aiManagerBudgetRemaining
                    or 0
                )
            );

        UI.CreateLabel(area).SetText(
            "AI Manager This Turn | Starting Commerce: " .. tostring(nation.aiManagerCommerceBefore or 0) ..
            " | Budget: " .. tostring(nation.aiManagerTurnBudget or 0) ..
            " | Spent: -" .. tostring(nation.aiManagerSpentThisTurn or 0) ..
            " | Projected Commerce After Manager: " .. tostring(nation.aiManagerCommerceAfter or 0)
        );
        UI.CreateLabel(area).SetText(
            "Spending Breakdown | Markets: " .. tostring(nation.aiManagerMarketSpentThisTurn or 0) ..
            " | Investments/Projects: " .. tostring(nation.aiManagerInvestmentSpentThisTurn or 0) ..
            " | Resources/Military: " .. tostring(nation.aiManagerMilitarySpentThisTurn or 0)
        );

    end

    UI.CreateLabel(area)
        .SetText(
            "Set the maximum amount of Commerce the manager may reserve and spend in one turn. It can now use authorized budget for Markets, Investments, Resources, Recruiters, and strategic infrastructure. Minimum: 25."
        );

    local budgetInput =
        CreateWideTextInput(
            area
        );

    budgetInput.SetText(
        tostring(
            nation.aiManagerBudget
            or 100
        )
    );

    local quickBudgetRow =
        UI.CreateHorizontalLayoutGroup(
            area
        );

    local function SetBudgetText(value)
        budgetInput.SetText(
            tostring(value)
        );
    end

    UI.CreateButton(quickBudgetRow)
        .SetText("100")
        .SetOnClick(function() SetBudgetText(100); end);

    UI.CreateButton(quickBudgetRow)
        .SetText("250")
        .SetOnClick(function() SetBudgetText(250); end);

    UI.CreateButton(quickBudgetRow)
        .SetText("500")
        .SetOnClick(function() SetBudgetText(500); end);

    UI.CreateButton(quickBudgetRow)
        .SetText("1000")
        .SetOnClick(function() SetBudgetText(1000); end);

    local actionRow =
        UI.CreateHorizontalLayoutGroup(
            area
        );

    local function SendManagerUpdate(
        shouldEnable
    )

        local budget =
            tonumber(
                budgetInput.GetText()
            );

        if budget == nil then

            UI.Alert(
                "Enter a valid budget amount."
            );

            return;
        end

        budget =
            math.max(
                25,
                math.floor(
                    budget
                )
            );

        SafeSendGameCustomMessage(game, 
            "Updating AI Manager...",
            {
                type =
                    "updateAIManager",

                enabled =
                    shouldEnable,

                budget =
                    budget
            },
            function(result)

                if result ~= nil
                    and result.message ~= nil then

                    UI.Alert(
                        result.message
                    );

                end

                ShowAIManagerMenu(
                    parent,
                    game
                );

            end
        );

    end

    UI.CreateButton(actionRow)
        .SetText(
            enabled
            and "UPDATE BUDGET"
            or "ENABLE MANAGER"
        )
        .SetOnClick(function()
            SendManagerUpdate(true);
        end);

    if enabled
        and cancelTurn == nil then

        UI.CreateButton(actionRow)
            .SetText(
                "CANCEL MANAGER"
            )
            .SetOnClick(function()
                SendManagerUpdate(false);
            end);

    end

    UI.CreateLabel(area)
        .SetText(
            "Cancellation rule: once requested, cancellation becomes effective on the next economy turn."
        );

end


function ShowGlobalEconomy(
    parent,
    game,
    filter
)

    local area =
        CreateContentArea(
            parent
        );


    local data =
        Mod.PublicGameData or {};


    local history =
        data.tradeHistory
        or {};


    UI.CreateLabel(area)
        .SetText(
            "GLOBAL ECONOMY & INVESTMENTS"
        ).SetColor("#64B5F6");

    UI.CreateLabel(area)
        .SetText(
            "Trade agreements, investment funding, project results, and AI economic activity in one feed."
        ).SetColor("#B0BEC5");


    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );


    UI.CreateLabel(area).SetText("TRADE ACTIVITY").SetColor("#81C784");
    local tradeTabs = UI.CreateHorizontalLayoutGroup(area);

    local function EconomyFilterButton(row, label, value)
        UI.CreateButton(row).SetText(label).SetOnClick(function()
            ShowGlobalEconomy(parent, game, value);
        end);
    end

    EconomyFilterButton(tradeTabs, "ALL", "all");
    EconomyFilterButton(tradeTabs, "SIGNED", "signed");
    EconomyFilterButton(tradeTabs, "PROPOSALS", "proposals");
    EconomyFilterButton(tradeTabs, "REJECTED", "rejected");
    EconomyFilterButton(tradeTabs, "CANCELED", "canceled");

    UI.CreateLabel(area).SetText("INVESTMENT ACTIVITY").SetColor("#BA68C8");
    local investmentTabs = UI.CreateHorizontalLayoutGroup(area);
    EconomyFilterButton(investmentTabs, "ALL INVESTMENTS", "investments");
    EconomyFilterButton(investmentTabs, "SUCCESSFUL", "success");
    EconomyFilterButton(investmentTabs, "FAILED", "failed");
    EconomyFilterButton(investmentTabs, "AI ACTIVITY", "ai");

    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );


    local shown =
        0;


    local found =
        false;


    for i =
        #history,
        1,
        -1 do


        if shown
            >= MAX_VISIBLE_HISTORY then

            break;
        end


        local event =
            history[i];


        if EventPassesFilter(
            event.type,
            filter or "all"
        ) then


            found =
                true;


            UI.CreateLabel(area)
                .SetText(
                    "Turn " ..
                    tostring(
                        event.turn
                        or "?"
                    ) ..
                    " - " ..
                    tostring(
                        event.message
                        or "Economic event"
                    )
                );


            shown =
                shown + 1;
        end
    end


    if not found then


        UI.CreateLabel(area)
            .SetText(
                "No events match this category yet."
            );
    end


    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );


    UI.CreateButton(area)
        .SetText(
            "Investment History"
        )
        .SetOnClick(function()

            ShowInvestmentHistory(
                parent,
                game
            );

        end);
end


function ShowHowItWorks(parent)

    local area = CreateContentArea(parent);

    local function Section(title, text, color)
        UI.CreateLabel(area).SetText("----------------------------------------");
        UI.CreateLabel(area).SetText(title).SetColor(color or "#8FBF6F");
        UI.CreateLabel(area).SetText(text).SetColor("#D0D0D0");
    end

    UI.CreateLabel(area).SetText("HOW IT WORKS - UNITED FRONTIER").SetColor("#FFFFFF");
    UI.CreateLabel(area).SetText(
        "United Frontier combines Commerce, Markets, Resources, Diplomacy, the UN, strategic infrastructure, Air Wings, Special Forces, Cyber Facilities, Factions, and Smart AI. Action screens stay short; this guide holds the deeper rules."
    ).SetColor("#BBBBBB");

    Section("QUICK START",
        "1. Complete National Setup.\n\n" ..
        "2. Use Overview as your command dashboard for Commerce, Unrest, alerts, allies, war status, resource warnings, military assets, and AI Manager spending.\n\n" ..
        "3. Markets contains stocks, ETF, investments, War Bonds, AI Manager, and Global Economy activity.\n\n" ..
        "4. Resources shows production, need, stockpile, shortages, private resource intelligence, facility development, offers, requests, and contracts.\n\n" ..
        "5. Military contains Recruiters, Power Grids, Airbases, Forward Airstrips, Missile Silos, Cyber Facilities, Air Wings, and Special Forces.\n\n" ..
        "6. Diplomacy contains alliances, Factions, Current Wars, Join War, peace, shared intelligence, and Faction Military Exercises.",
        "#FFFFFF");

    Section("COMMERCE & MARKETS",
        "Commerce is the mod's usable national economic power. It pays for investments, market activity, resource facilities, military infrastructure, Air Wings, Special Forces, Recruiters, and other strategic development.\n\n" ..
        "Flagship companies may follow Growth, Balanced, or Dividend strategies. Stocks, ETF holdings, dividends, Investment Projects, and optional flagship acquisitions are managed under Markets. Owners can turn acquisition offers on or off. If an acquisition is accepted, target shareholders receive a buyout payout, the buyer's flagship receives a market boost, and the acquired nation may establish a replacement flagship after the host-defined cooldown.",
        "#72C7FF");

    Section("AI MANAGER",
        "When enabled by the host, a human player may give AI Manager a Commerce budget for the turn. That amount is reserved from the player's usable Commerce and can be allocated across Markets, Investments, Strategic Resources, Recruiters, and military development.\n\n" ..
        "If the player cancels AI Manager during the turn, the current reserved budget remains committed for that turn. Full manual Commerce control returns on the next turn. This prevents same-turn toggle/refund exploits.",
        "#80CBC4");

    Section("STRATEGIC RESOURCES",
        "The nine resources are Oil, Gas, Uranium, Iron, Food, Rare Earths, Coal, Copper, and Lithium.\n\n" ..
        "Oil supports air operations, logistics and strategic mobility. Gas supports energy and industry. Uranium is the rarest and most expensive strategic resource and supports nuclear capability. Iron supports military construction and infrastructure. Food supports armies and recruitment. Rare Earths support advanced guidance, aircraft and cyber technology. Coal supports industry and backup energy. Copper supports communications, the grid and electronics. Lithium supports advanced batteries, aircraft and missile technology.\n\n" ..
        "Positive net production is stored in the national stockpile. A later deficit consumes stockpile first; only the uncovered shortage creates penalties. Existing armies are never deleted because of resource shortages.",
        "#7ED957");

    Section("RESOURCE FACILITIES & LEVELS",
        "A resource territory may hold resource development levels, but the mod never stacks multiple copies of the same facility icon to represent upgrades. A facility progresses through levels and the same logical facility is upgraded.\n\n" ..
        "The current visual resource tier is capped at Level 5 so the mod stays comfortably below War.app's 100 custom-structure-image limit. Uranium does not automatically appear just because a nation is wealthy; the host controls Uranium distribution and its facility cost multiplier.",
        "#FFD166");

    Section("PRIVATE RESOURCE INTELLIGENCE",
        "Resource locations are NOT globally exposed as normal map structure icons.\n\n" ..
        "You know: your own resource deposits; foreign resource territories directly bordering your own territory; faction-shared resources; and resources from an ally with Shared Intelligence enabled.\n\n" ..
        "Example: France naturally learns resource territories directly bordering France. A China-Russia border resource does not become visible to France merely because it is on an international border.\n\n" ..
        "Use the Resources filters: My Resources, Neighbors, Ally/Faction, and All Known. SHOW closes the full menu, highlights the known territory, and leaves a small Back control.",
        "#C792EA");

    Section("RESOURCE MARKET & TRADE",
        "Players can OFFER a resource or REQUEST a resource from another nation. Accepted contracts transfer resources for Commerce while active. Incoming offers/requests and active contracts are shown separately.\n\n" ..
        "Trade deliveries affect the effective resource balance before stockpile shortage resolution. Embargoes can interrupt deliveries while the underlying contract remains tracked.",
        "#4DD0E1");

    Section("MILITARY MAP ASSETS",
        "Recruiting Stations, Airbases, Forward Airstrips, Missile Silos, Power Grids, Cyber Facilities, Air Wings, and Special Forces have a visible map presence.\n\n" ..
        "Recruiters, Airbases, Airstrips, Silos, Power Grids and Cyber Facilities use structure-style map assets. Air Wings and Special Forces use visible custom special-unit icons. A structure upgrade replaces its tier rather than creating duplicate icons.\n\n" ..
        "Military Infrastructure uses My Infrastructure, Neighbors, Ally/Faction, and All Known filters. SHOW highlights a known installation and returns through a small Back control. Air Wings and Special Forces use normal game fog instead of forced global visibility.",
        "#FFB74D");

    Section("CYBER FACILITIES",
        "Cyber Facilities provide offensive cyber capability directly. They require an operational Power Grid and can launch one cyber disruption operation per turn during an active war. Higher facility levels improve offensive capability, while the target's Cyber Facilities provide defensive resistance.\n\n" ..
        "Cyber Facilities are optional. If the host disables them, Recruiters and the rest of the enabled military systems continue to work normally.",
        "#C792EA");

    Section("ALLIANCES, FACTIONS & SHARING",
        "Faction membership automatically enables strategic intelligence sharing among faction members.\n\n" ..
        "Normal alliances do not automatically reveal private intelligence. Allied players can separately request Shared Intelligence and Joint Strategic Warning. Shared Intelligence controls access to private resource/military discoveries; Joint Strategic Warning is reserved for coordinated warning and strategic-defense behavior.\n\n" ..
        "If the alliance ends, ongoing sharing ends. Previously learned intelligence may remain as historical/last-known information.",
        "#64B5F6");

    Section("RECRUITING STATIONS",
        "Recruiters are visible military structures that generate armies each turn according to their level and the nation's Military Readiness. Upgrading changes the same Recruiter structure tier instead of creating another Recruiter icon.\n\n" ..
        "Smart AI prefers Recruiters behind the frontline when geography allows, using safer interior or second-line territories rather than wasting major production directly on exposed borders.",
        "#D4AF37");

    Section("AIRBASES, AIRSTRIPS & AIR WINGS",
        "Airbases are the main air infrastructure and may be upgraded. Forward Airstrips are cheaper, more limited forward facilities.\n\n" ..
        "Air Wings are custom special units stationed through Airbases. The host chooses how many real aircraft one Air Wing represents for scenario scale. Airbase capacity limits how many Air Wings may be stationed there.\n\n" ..
        "When the host enables Airbases or Forward Airstrips, United Frontier restricts War.app Airlift Cards so the origin and destination must contain enabled airport infrastructure. If the host disables BOTH Airbases and Forward Airstrips, this restriction is lifted and Airlift Cards follow normal War.app rules. The mod does not create Airlift Cards itself; the host must enable them in normal game settings. AI nations can use valid Airlift routes to move rear-area armies toward threatened or active fronts. Air Wings remain visible purchasable units; this release does not include a separate Air Wing mission menu.",
        "#62B6FF");

    Section("INFRASTRUCTURE HEALTH",
        "Strategic military infrastructure uses a simple 10-point health scale. 10/10 is fully intact and 0/10 is destroyed. Conventional strategic attacks remove health in whole-point steps; repair restores an installation to 10/10. EMP effects can disable systems temporarily without necessarily removing HP.\n\n" ..
        "SAM Sites are not part of United Frontier. Missile outcomes use the configured strike rules, infrastructure HP, and other enabled strategic systems.",
        "#79D279");

    Section("MISSILE SILOS",
        "Missile Silos are visible strategic structures with limited missile inventory and resupply. Conventional missiles damage armies/assets. EMP strikes disable systems and can spread from stronger Silos. Nuclear strikes use Low/Medium/High yield (limited by Silo level) and can damage armies, cities/territories, resource facilities, and strategic assets across the target and nearby territories.\n\n" ..
        "A Silo's visible location does not automatically expose every sensitive detail about its level, inventory, readiness or strategic capability; those details can be intelligence-sensitive.",
        "#FF7B7B");

    Section("POWER / ELECTRICAL GRID",
        "Power Grids are strategic infrastructure required for Airbases, Missile Silos, and Cyber Facilities. If the Grid is disabled or destroyed, dependent strategic systems cannot operate until power is restored.\n\n" ..
        "Grid locations follow the same military-infrastructure intelligence rules as other strategic installations: your own, directly bordering, faction/shared-intelligence, or otherwise discovered locations appear in the Military Infrastructure filters.",
        "#FFE066");

    Section("SPECIAL FORCES",
        "Special Forces are visible custom special units, separate from normal War.app infantry. The host configures how much normal-army combat strength each Special Forces unit represents, along with purchase cost and the maximum per player. The configured strength controls attack, defense, damage-to-kill, and damage absorption. This release keeps them as visible purchasable units without a separate covert-operation mission menu.",
        "#D995FF");

    Section("TERRITORY SELECTION",
        "United Frontier uses one consistent map-selection flow: choose an action; the mod dialog closes; click a territory; a fresh confirmation dialog opens; review the selected territory and its current information; then confirm.\n\n" ..
        "This avoids stale/destroyed UI callbacks and reduces accidental purchases. Resource development also shows the existing resource levels on the selected territory before confirmation.",
        "#FFFFFF");

    Section("DAMAGE, DESTRUCTION & REPAIR",
        "Every strategic installation has 10 HP. Damaged or EMP-disabled assets can be repaired from Military > Damage & Repairs; 0/10 HP means the installation is destroyed and must be rebuilt.\n\n" ..
        "Capture and strategic attacks can remove or damage assets instead of automatically transferring every military installation intact. Repair costs are intended to scale with damage, structure level, and national economic capacity.",
        "#EF9A9A");

    Section("SMART AI",
        "Smart AI uses a national-planning approach rather than isolated random purchases. It evaluates its economy, resources, diplomacy, borders, war status, infrastructure and reserves.\n\n" ..
        "At peace Smart AI maintains reserves, develops resources, and places Recruiters/infrastructure in safer locations. In serious war it shifts toward War Economy: Recruiters, resources, repairs, enabled Air Wings, Silos, Cyber Facilities and military spending gain priority while disabled host systems are ignored.\n\n" ..
        "The AI should not hoard large Commerce balances without a defined goal. It can reserve for a specific purchase, reinforce weak fronts, preserve a reaction reserve, and still attack favorable targets.",
        "#FFCC80");

    Section("DIPLOMACY & CURRENT WARS",
        "Diplomacy contains relations, alliances, Factions, Current Wars, Join War, peace, NAPs, shared-intelligence requests, Faction leadership controls, and Military Exercises. Wars remain inside Diplomacy rather than using a separate top-level Wars tab.\n\n" ..
        "Current Wars groups coalition conflicts into one entry and preserves the original cause. Join War lets an eligible human choose a side subject to diplomacy safety checks. AI allies and faction partners may also enter an ally's conflict, while AI nations can proactively seek Alliances when trade/NAP relationships and strategic conditions make cooperation useful. Trade Agreements are available to human players from both Markets and Diplomacy.",
        "#FFB74D");

    Section("UNITED NATIONS",
        "The optional Security Council supports sanctions, embargoes, aid, condemnations and ceasefires. Permanent members may have veto power. Host settings define council size, voting rules and proposal cooldowns.\n\n" ..
        "Sanctions and Ceasefires use host-configurable minimum and maximum durations so neither hosts nor players are forced into a fixed 3-turn duration. A passed Ceasefire forces peace and blocks a new declaration for the chosen duration.",
        "#90CAF9");

    Section("VISIBILITY SUMMARY",
        "RESOURCES: private. Reveal through ownership, direct border, Faction, or accepted Shared Intelligence.\n\n" ..
        "MILITARY ASSET LOCATIONS: visible map assets.\n\n" ..
        "MILITARY INFRASTRUCTURE DETAILS: reveal through ownership, direct border, Faction, or accepted Shared Intelligence.\n\n" ..
        "POWER GRID: required for Airbases, Missile Silos, and Cyber Facilities.\n\n" ..
        "Hiding a UI tab does not disable the underlying system; host configuration controls system availability.",
        "#FFFFFF");
end


-- =========================================================
-- NATIONAL SETUP / ECONOMIC REFORM
-- =========================================================

function GetOurNationState(game)

    local data =
        Mod.PublicGameData or {};


    local economy =
        data.globalEconomy or {};


    local nations =
        economy.nations or {};


    local ourID = GetLocalPlayerID(game);
    if ourID == nil then
        return nil;
    end

    return nations[ourID];
end


function IsNationalSetupComplete(game)

    local nation =
        GetOurNationState(
            game
        );


    return nation ~= nil
        and nation.setupComplete == true;
end
function ShowNationalSetup(
    parent,
    game
)

    local area =
        CreateContentArea(
            parent
        );


    local nation =
        GetOurNationState(
            game
        );


    local isReform =
        nation ~= nil
        and nation.setupComplete == true;


    local economy =
        (
            Mod.PublicGameData
            or {}
        ).globalEconomy
        or {};


    local currentTurn =
        economy.currentEconomyTurn
        or 1;


    -- =====================================================
    -- ACTIVE REFORM
    -- =====================================================

    if isReform
        and nation.reformActive == true then


        local reformEndTurn =
            nation.reformEndTurn
            or currentTurn;


        local turnsRemaining =
            reformEndTurn
            - currentTurn;


        if turnsRemaining < 0 then

            turnsRemaining =
                0;

        end


        UI.CreateLabel(area)
            .SetText(
                "ECONOMIC REFORM IN PROGRESS"
            );


        UI.CreateLabel(area)
            .SetText(
                "Your new national policies are already active."
            );


        UI.CreateLabel(area)
            .SetText(
                "----------------------------------------"
            );


        UI.CreateLabel(area)
            .SetText(
                "Ideology: " ..
                tostring(
                    nation.ideology
                    or "Unknown"
                )
            );


        UI.CreateLabel(area)
            .SetText(
                "Economic Strategy: " ..
                tostring(
                    nation.economicStrategy
                    or "Unknown"
                )
            );


        UI.CreateLabel(area)
            .SetText(
                "Tax Policy: " ..
                tostring(
                    nation.taxPolicy
                    or "Standard"
                )
            );


        UI.CreateLabel(area)
            .SetText(
                "Flagship Company: " ..
                tostring(
                    nation.flagshipCompanyName
                    or "Unknown"
                )
            );


        UI.CreateLabel(area)
            .SetText(
                "Company Strategy: " ..
                tostring(
                    nation.companyStrategy
                    or "Unknown"
                )
            );


        UI.CreateLabel(area)
            .SetText(
                "----------------------------------------"
            );


        UI.CreateLabel(area)
            .SetText(
                "Temporary Economic Confidence Penalty: -" ..
                tostring(
                    nation.reformPenaltyPercent
                    or 15
                ) ..
                "%"
            );


        UI.CreateLabel(area)
            .SetText(
                "Effective Economic Confidence: " ..
                tostring(
                    nation.effectiveEconomicConfidence
                    or 85
                ) ..
                "%"
            );


        UI.CreateLabel(area)
            .SetText(
                "Turns Remaining: " ..
                tostring(
                    turnsRemaining
                )
            );


        UI.CreateLabel(area)
            .SetText(
                "When reform ends, the temporary confidence penalty disappears automatically. Your new ideology and strategies remain."
            );


        UI.CreateButton(area)
            .SetText(
                "BACK TO OVERVIEW"
            )
            .SetOnClick(function()


                ShowOverview(
                    parent,
                    game
                );

            end);


        return;

    end


    -- =====================================================
    -- TITLE
    -- =====================================================

    if isReform then


        UI.CreateLabel(area)
            .SetText(
                "NATIONAL POLICY & ECONOMIC REFORM"
            );


        UI.CreateLabel(area)
            .SetText(
                "You may change your nation's economic direction, but major policy changes create temporary economic uncertainty."
            );


        UI.CreateLabel(area)
            .SetText(
                "Major Reform: -15% Economic Confidence for 3 turns."
            );


        UI.CreateLabel(area)
            .SetText(
                "Changing only your tax policy does not trigger the full reform penalty."
            );


        UI.CreateLabel(area)
            .SetText(
                "Your flagship company's name remains unchanged."
            );


    else


        UI.CreateLabel(area)
            .SetText(
                "NATIONAL ECONOMIC SETUP"
            );


        UI.CreateLabel(area)
            .SetText(
                "Establish your nation's starting economic identity."
            );


        UI.CreateLabel(area)
            .SetText(
                "Choose an ideology, economic strategy, starting tax policy, flagship company, and company strategy."
            );

    end


    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );


    -- =====================================================
    -- SELECTION STATE
    -- =====================================================

    local selectedIdeology =
        isReform
        and nation.ideology
        or nil;


    local selectedEconomicStrategy =
        isReform
        and nation.economicStrategy
        or nil;


    local selectedTaxPolicy =
        isReform
        and (
            nation.taxPolicy
            or "Standard"
        )
        or "Standard";


    local selectedCompanyStrategy =
        isReform
        and nation.companyStrategy
        or nil;

    local ideologyEffectsLabel =
    nil;

    local policyPreviewLabel =
    nil;

    local companyNameInput =
        nil;


    local ideologyLabel =
        UI.CreateLabel(
            area
        );


    local economicStrategyLabel =
        UI.CreateLabel(
            area
        );


    local taxLabel =
        UI.CreateLabel(
            area
        );


    local companyStrategyLabel =
        UI.CreateLabel(
            area
        );

local function GetIdeologyEffectsText(
    ideology
)

    if ideology == "Free Market" then
        return "Ideology Effects - Free Market\nGovernment Commerce: -3% | Market: +8% | Investment: +6% | Company Confidence: +2";
    elseif ideology == "Capitalist" then
        return "Ideology Effects - Capitalist\nGovernment Commerce: -2% | Market: +6% | Investment: +5% | Company Confidence: +3";
    elseif ideology == "Social Democratic" then
        return "Ideology Effects - Social Democratic\nGovernment Commerce: +2% | Market: +2% | Investment: +3% | Company Confidence: +2";
    elseif ideology == "State Capitalist" then
        return "Ideology Effects - State Capitalist\nGovernment Commerce: +4% | Market: +1% | Investment: +5% | Company Confidence: +4";
    elseif ideology == "Socialist" then
        return "Ideology Effects - Socialist\nGovernment Commerce: +5% | Market: -5% | Investment: +1% | Company Confidence: +1";
    elseif ideology == "Communist" then
        return "Ideology Effects - Communist\nGovernment Commerce: +7% | Market: -9% | Investment: -2% | Company Confidence: +0";
    elseif ideology == "Fascist" then
        return "Ideology Effects - Fascist\nGovernment Commerce: +3% | Market: -2% | Investment: +1% | Company Confidence: +3";
    elseif ideology == "Nationalist" then
        return "Ideology Effects - Nationalist\nGovernment Commerce: +2% | Market: -1% | Investment: +0% | Company Confidence: +2";
    end

    return "Ideology Effects: None";
end

    local function UpdateSelections()


        ideologyLabel.SetText(
            "Selected Ideology: " ..
            tostring(
                selectedIdeology
                or "None"
            )
        );


        economicStrategyLabel.SetText(
            "Selected Economic Strategy: " ..
            tostring(
                selectedEconomicStrategy
                or "None"
            )
        );


        taxLabel.SetText(
            "Selected Tax Policy: " ..
            tostring(
                selectedTaxPolicy
                or "None"
            )
        );

        if ideologyEffectsLabel ~= nil then

    ideologyEffectsLabel.SetText(
        GetIdeologyEffectsText(
            selectedIdeology
        )
    );

end

if policyPreviewLabel ~= nil then

    policyPreviewLabel.SetText(
        GetPolicyPreviewText(
            game,
            selectedTaxPolicy,
            selectedIdeology,
            selectedEconomicStrategy,
            selectedCompanyStrategy
        )
    );

end

        companyStrategyLabel.SetText(
            "Selected Company Strategy: " ..
            tostring(
                selectedCompanyStrategy
                or "None"
            )
        );

    end


    UpdateSelections();


    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );


    -- =====================================================
    -- IDEOLOGY
    -- =====================================================

    UI.CreateLabel(area)
        .SetText(
            "1. IDEOLOGY"
        );


    local ideologyRow1 =
        UI.CreateHorizontalLayoutGroup(
            area
        );


    UI.CreateButton(
        ideologyRow1
    )
        .SetText(
            "Free Market"
        )
        .SetOnClick(function()


            selectedIdeology =
                "Free Market";


            UpdateSelections();

        end);


    UI.CreateButton(
        ideologyRow1
    )
        .SetText(
            "Capitalist"
        )
        .SetOnClick(function()


            selectedIdeology =
                "Capitalist";


            UpdateSelections();

        end);


    UI.CreateButton(
        ideologyRow1
    )
        .SetText(
            "Social Democratic"
        )
        .SetOnClick(function()


            selectedIdeology =
                "Social Democratic";


            UpdateSelections();

        end);


    local ideologyRow2 =
        UI.CreateHorizontalLayoutGroup(
            area
        );


    UI.CreateButton(
        ideologyRow2
    )
        .SetText(
            "State Capitalist"
        )
        .SetOnClick(function()


            selectedIdeology =
                "State Capitalist";


            UpdateSelections();

        end);


    UI.CreateButton(
        ideologyRow2
    )
        .SetText(
            "Socialist"
        )
        .SetOnClick(function()


            selectedIdeology =
                "Socialist";


            UpdateSelections();

        end);


    local ideologyRow3 =
        UI.CreateHorizontalLayoutGroup(
            area
        );

    UI.CreateButton(ideologyRow3)
        .SetText("Communist")
        .SetOnClick(function()
            selectedIdeology = "Communist";
            UpdateSelections();
        end);

    UI.CreateButton(ideologyRow3)
        .SetText("Fascist")
        .SetOnClick(function()
            selectedIdeology = "Fascist";
            UpdateSelections();
        end);

    UI.CreateButton(ideologyRow3)
        .SetText("Nationalist")
        .SetOnClick(function()
            selectedIdeology = "Nationalist";
            UpdateSelections();
        end);

    UI.CreateLabel(area)
        .SetText(
            "Free Market | Commerce -3% | Market +8% | Investment +6% | Confidence +2\n" ..
            "Capitalist | Commerce -2% | Market +6% | Investment +5% | Confidence +3\n" ..
            "Social Democratic | Commerce +2% | Market +2% | Investment +3% | Confidence +2\n" ..
            "State Capitalist | Commerce +4% | Market +1% | Investment +5% | Confidence +4\n" ..
            "Socialist | Commerce +5% | Market -5% | Investment +1% | Confidence +1\n" ..
            "Communist | Commerce +7% | Market -9% | Investment -2% | Confidence +0\n" ..
            "Fascist | Commerce +3% | Market -2% | Investment +1% | Confidence +3\n" ..
            "Nationalist | Commerce +2% | Market -1% | Investment +0% | Confidence +2"
        );


    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );


    -- =====================================================
    -- ECONOMIC STRATEGY
    -- =====================================================

    UI.CreateLabel(area)
        .SetText(
            "2. ECONOMIC STRATEGY"
        );


    local strategyRow =
        UI.CreateHorizontalLayoutGroup(
            area
        );


    UI.CreateButton(
        strategyRow
    )
        .SetText(
            "Growth"
        )
        .SetOnClick(function()


            selectedEconomicStrategy =
                "Growth";


            UpdateSelections();

        end);


    UI.CreateButton(
        strategyRow
    )
        .SetText(
            "Balanced"
        )
        .SetOnClick(function()


            selectedEconomicStrategy =
                "Balanced";


            UpdateSelections();

        end);


    UI.CreateButton(
        strategyRow
    )
        .SetText(
            "Conservative"
        )
        .SetOnClick(function()


            selectedEconomicStrategy =
                "Conservative";


            UpdateSelections();

        end);


    UI.CreateLabel(area)
        .SetText(
            "Growth | Commerce +5% | Market +4% | Investment +5% | Confidence +2\n" ..
            "Balanced | Commerce 0% | Market 0% | Investment 0% | Confidence +0\n" ..
            "Conservative | Commerce -3% | Market -2% | Investment -3% | Confidence +4"
        );


    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );


    -- =====================================================
    -- TAX POLICY
    -- =====================================================

    UI.CreateLabel(area)
        .SetText(
            "3. TAX POLICY"
        );


    local taxRow =
        UI.CreateHorizontalLayoutGroup(
            area
        );


    UI.CreateButton(
        taxRow
    )
        .SetText(
            "Low"
        )
        .SetOnClick(function()


            selectedTaxPolicy =
                "Low";


            UpdateSelections();

        end);


    UI.CreateButton(
        taxRow
    )
        .SetText(
            "Standard"
        )
        .SetOnClick(function()


            selectedTaxPolicy =
                "Standard";


            UpdateSelections();

        end);


    UI.CreateButton(
        taxRow
    )
        .SetText(
            "High"
        )
        .SetOnClick(function()


            selectedTaxPolicy =
                "High";


            UpdateSelections();

        end);


UI.CreateLabel(area)
    .SetText(
        "Low Tax\n" ..
        "Commerce: -10% | Market: +10% | Investment: +10% | Company Confidence: +5\n\n" ..

        "Standard Tax\n" ..
        "Commerce: 0% | Market: 0% | Investment: 0% | Company Confidence: 0\n\n" ..

        "High Tax\n" ..
        "Commerce: +10% | Market: -10% | Investment: -10% | Company Confidence: -5"
    );

ideologyEffectsLabel =
    UI.CreateLabel(area);

ideologyEffectsLabel.SetText(
    GetIdeologyEffectsText(
        selectedIdeology
    )
);

policyPreviewLabel =
    UI.CreateLabel(area);

policyPreviewLabel.SetText(
    GetPolicyPreviewText(
        game,
        selectedTaxPolicy,
        selectedIdeology,
        selectedEconomicStrategy,
        selectedCompanyStrategy
    )
);

UI.CreateLabel(area)
    .SetText(
        "--------------------------------"
    );

    -- =====================================================
    -- FLAGSHIP COMPANY
    -- =====================================================

    UI.CreateLabel(area)
        .SetText(
            "4. FLAGSHIP COMPANY"
        );


    if isReform then


        UI.CreateLabel(area)
            .SetText(
                "Current Company: " ..
                tostring(
                    nation.flagshipCompanyName
                    or "Unknown"
                )
            );


        UI.CreateLabel(area)
            .SetText(
                "Corporate renaming will be handled separately from national economic reform."
            );


    else


        UI.CreateLabel(area)
            .SetText(
                "Enter a unique company name between 2 and 40 characters."
            );


        companyNameInput =
            CreateWideTextInput(
                area
            )
                .SetPlaceholderText(
                    "Enter flagship company name..."
                );

    end


    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );


    -- =====================================================
    -- COMPANY STRATEGY
    -- =====================================================

    UI.CreateLabel(area)
        .SetText(
            "5. COMPANY STRATEGY"
        );


    local companyStrategyRow =
        UI.CreateHorizontalLayoutGroup(
            area
        );


    UI.CreateButton(
        companyStrategyRow
    )
        .SetText(
            "Growth"
        )
        .SetOnClick(function()


            selectedCompanyStrategy =
                "Growth";


            UpdateSelections();

        end);


    UI.CreateButton(
        companyStrategyRow
    )
        .SetText(
            "Balanced"
        )
        .SetOnClick(function()


            selectedCompanyStrategy =
                "Balanced";


            UpdateSelections();

        end);


    UI.CreateButton(
        companyStrategyRow
    )
        .SetText(
            "Dividend"
        )
        .SetOnClick(function()


            selectedCompanyStrategy =
                "Dividend";


            UpdateSelections();

        end);


    UI.CreateLabel(area)
        .SetText(
            "Growth Company | Price fundamentals x1.35 | Dividend pool 1% of owner income | Random volatility scale 30%\n" ..
            "Balanced Company | Price fundamentals x1.00 | Dividend pool 2% of owner income | Random volatility scale 25%\n" ..
            "Dividend Company | Price fundamentals x0.45 | Dividend pool 4%-6% of owner income | Random volatility scale 15%"
        );


    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );


    -- =====================================================
    -- DIPLOMACY ACKNOWLEDGEMENT
    -- =====================================================

    if not isReform then


        UI.CreateLabel(area)
            .SetText(
                "6. DIPLOMACY RULE"
            );


        UI.CreateLabel(area)
            .SetText(
                "When formal diplomacy is enabled, nations must officially declare WAR before attacking another nation. Confirming National Setup acknowledges this rule."
            );


        UI.CreateLabel(area)
            .SetText(
                "----------------------------------------"
            );

    end


    -- =====================================================
    -- FINAL REVIEW
    -- =====================================================

    UI.CreateLabel(area)
        .SetText(
            isReform
            and "PROPOSED NATIONAL POLICY"
            or "YOUR STARTING NATIONAL POLICY"
        );


    UpdateSelections();


    if isReform then


        UI.CreateLabel(area)
            .SetText(
                "Major Change: ideology, economic strategy, or company strategy.\n" ..
                "Major Reform Penalty: -15% Economic Confidence for 3 turns.\n" ..
                "Tax-only Change: no full economic reform penalty."
            );

    end


    UI.CreateLabel(area)
        .SetText(
            "----------------------------------------"
        );


    -- =====================================================
    -- SUBMIT
    -- =====================================================

    UI.CreateButton(area)
        .SetText(
            isReform
            and "CONFIRM ECONOMIC REFORM"
            or "CONFIRM NATIONAL SETUP"
        )
        .SetOnClick(function()


            if selectedIdeology
                == nil then


                UI.Alert(
                    "Please choose an ideology."
                );


                return;

            end


            if selectedEconomicStrategy
                == nil then


                UI.Alert(
                    "Please choose an economic strategy."
                );


                return;

            end


            if selectedTaxPolicy
                == nil then


                UI.Alert(
                    "Please choose a tax policy."
                );


                return;

            end


            if selectedCompanyStrategy
                == nil then


                UI.Alert(
                    "Please choose a company strategy."
                );


                return;

            end


            -- =================================================
            -- EXISTING NATION -> REFORM
            -- =================================================

            if isReform then


                if selectedIdeology
                        == nation.ideology

                    and selectedEconomicStrategy
                        == nation.economicStrategy

                    and selectedTaxPolicy
                        == nation.taxPolicy

                    and selectedCompanyStrategy
                        == nation.companyStrategy
                then


                    UI.Alert(
                        "No national policies were changed."
                    );


                    return;

                end


                SafeSendGameCustomMessage(game, 
                    "Submitting economic reform...",

                    {

                        type =
                            "reformNationalSetup",

                        ideology =
                            selectedIdeology,

                        economicStrategy =
                            selectedEconomicStrategy,

                        taxPolicy =
                            selectedTaxPolicy,

                        companyStrategy =
                            selectedCompanyStrategy

                    },

                    function(result)


                        UI.Alert(
                            result
                            and result.message
                            or
                            "Economic reform request processed."
                        );


                        if result ~= nil
                            and result.success then


                            ShowOverview(
                                parent,
                                game
                            );

                        end

                    end
                );


                return;

            end


            -- =================================================
            -- FIRST NATIONAL SETUP
            -- =================================================

            local companyName =
                companyNameInput.GetText();


            if companyName == nil
                or string.len(
                    companyName
                ) < 2 then


                UI.Alert(
                    "Please enter a flagship company name with at least 2 characters."
                );


                return;

            end


            SafeSendGameCustomMessage(game, 
                "Saving National Setup...",

                {

                    type =
                        "saveNationalSetup",

                    ideology =
                        selectedIdeology,

                    economicStrategy =
                        selectedEconomicStrategy,

                    taxPolicy =
                        selectedTaxPolicy,

                    companyName =
                        companyName,

                    companyStrategy =
                        selectedCompanyStrategy,

                    warRulesAcknowledged =
                        true

                },

                function(result)


                    UI.Alert(
                        result
                        and result.message
                        or
                        "National Setup request processed."
                    );


                    if result ~= nil
                        and result.success then


                        ShowOverview(
                            parent,
                            game
                        );

                    end

                end
            );

        end);


    if isReform then


        UI.CreateButton(area)
            .SetText(
                "CANCEL / BACK TO OVERVIEW"
            )
            .SetOnClick(function()


                ShowOverview(
                    parent,
                    game
                );

            end);

    end

end