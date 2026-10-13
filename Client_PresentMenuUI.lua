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
DiplomacyPlayerFilter = DiplomacyPlayerFilter or "ALL";
MarketNewsFilter = MarketNewsFilter or "ALL";
StrategicReportFilter = StrategicReportFilter or "ALL";


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



function ShowFactionMenu(parent, game)
    local area = CreateContentArea(parent);
    local data = Mod.PublicGameData or {};
    local economy = data.globalEconomy or {};
    local diplomacy = economy.diplomacy or {};
    local factions = diplomacy.factions or {};
    local pendingFactionInvites = diplomacy.pendingFactionInvites or {};
    local playerFaction = diplomacy.playerFaction or {};
    local ourID = GetLocalPlayerID(game);
    local ourFactionID = ourID ~= nil and playerFaction[ourID] or nil;
    local ourFaction = ourFactionID ~= nil and factions[ourFactionID] or nil;

    UI.CreateLabel(area).SetText("FACTION COMMAND").SetColor("#D4AF37");
    UI.CreateLabel(area).SetText("Faction membership, leadership, invitations and Military Exercises are managed here.").SetColor("#9CCBFF");
    UI.CreateButton(area).SetText("← BACK TO DIPLOMACY").SetOnClick(function() ShowDiplomacyMenu(parent,game); end);

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


                    ShowFactionMenu(
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
                    SafeSendGameCustomMessage(game,"Transferring Faction leadership...",{type="promoteFactionLeader",targetPlayerID=removableID},function(result) if result and result.message then UI.Alert(result.message); end; ShowFactionMenu(parent,game); end);
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


                                ShowFactionMenu(
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
        local penalty=(unrest>=80 and 35) or (unrest>=60 and 20) or (unrest>=40 and 10) or (unrest>=20 and 5) or 0; local ideologyBonus=GetClientIdeologyRecruiterModifierPercent(memberNation); local base=math.max(1,math.floor(tonumber(GetClientSetting("ArmyRecruiterArmiesPerTurn",4)) or 4)); local total=0;
        local recruiters=((economy.armyRecruiters or {}).territories or {}); local standing=game.LatestStanding;
        for tid,lvl in pairs(recruiters) do local ntid=tonumber(tid) or tid; local terr=standing and standing.Territories and standing.Territories[ntid] or nil; if terr and terr.OwnerPlayerID==memberID then local mult=math.max(0,100+ideologyBonus-penalty+(tonumber(bonusPercent) or 0)); total=total+math.max(0,math.floor(base*(tonumber(lvl) or 0)*readiness/100*mult/100+0.5)); end end
        return total;
    end
    local ex=ourFaction.militaryExercise or {}; local turn=tonumber((economy or {}).currentEconomyTurn or (Mod.PublicGameData or {}).tradeTurn) or 0;
    if ex.active==true and turn<=tonumber(ex.endTurn or 0) then
        UI.CreateLabel(area).SetText("ACTIVE | Ends Turn "..tostring(ex.endTurn).." | Recruiter boosts apply only to members who contribute.").SetColor("#79D279");
        local mine=(ex.contributions or {})[ourID];
        if mine then local normal=ExerciseTroopsPerTurn(ourID,0); local boosted=ExerciseTroopsPerTurn(ourID,mine.bonusPercent); UI.CreateLabel(area).SetText("Your contribution: "..tostring(mine.commerce).." Commerce | +"..tostring(mine.bonusPercent).."% | CURRENT Recruiter output "..tostring(normal).." -> "..tostring(boosted).." troops/turn (+"..tostring(math.max(0,boosted-normal))..")").SetColor("#8FD694");
        else
            UI.CreateLabel(area).SetText("Choose once per exercise. Buttons show your CURRENT exact Recruiter output after Readiness and Unrest.").SetColor("#FFFFFF");
            local cr=UI.CreateVerticalLayoutGroup(area); for _,tier in ipairs({{50,10},{100,20},{200,40},{300,60}}) do local a=tier[1]; local pct=tier[2]; local normal=ExerciseTroopsPerTurn(ourID,0); local boosted=ExerciseTroopsPerTurn(ourID,pct); UI.CreateButton(cr).SetText(tostring(a).." Commerce | +"..tostring(pct).."% | "..tostring(normal).." -> "..tostring(boosted).." troops/turn (+"..tostring(math.max(0,boosted-normal))..")").SetOnClick(function() SafeSendGameCustomMessage(game,"Contributing to Faction exercise...",{type="contributeFactionExercise",amount=a},function(r) if r and r.message then UI.Alert(r.message); end; ShowFactionMenu(parent,game); end); end); end
        end
        UI.CreateLabel(area).SetText("MEMBER PARTICIPATION").SetColor("#FFD166");
        for memberID,isMember in pairs(ourFaction.members or {}) do if isMember then local c=(ex.contributions or {})[memberID]; local normal=ExerciseTroopsPerTurn(memberID,0); local boosted=c and ExerciseTroopsPerTurn(memberID,c.bonusPercent) or normal; UI.CreateLabel(area).SetText(GetPlayerName(game,memberID).." | "..(c and (tostring(c.commerce).." Commerce | +"..tostring(c.bonusPercent).."% | "..tostring(normal).." -> "..tostring(boosted).." troops/turn") or ("No contribution | Current "..tostring(normal).." troops/turn"))).SetColor(c and "#8FD694" or "#AAAAAA"); end end
    else
        local cd=tonumber(ex.cooldownUntilTurn or 0); if cd>turn then UI.CreateLabel(area).SetText("COOLDOWN | Next exercise available Turn "..tostring(cd)).SetColor("#FFB366"); elseif ourFaction.leaderPlayerID==ourID then UI.CreateButton(area).SetText("START MILITARY EXERCISE").SetOnClick(function() SafeSendGameCustomMessage(game,"Starting Faction military exercise...",{type="startFactionExercise"},function(r) if r and r.message then UI.Alert(r.message); end; ShowFactionMenu(parent,game); end); end); else UI.CreateLabel(area).SetText("No active exercise. The Faction leader may start one when cooldown is ready.").SetColor("#888888"); end
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


                        ShowFactionMenu(
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


                    ShowFactionMenu(
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


                        ShowFactionMenu(
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


                        ShowFactionMenu(
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



    UI.CreateButton(area).SetText("← BACK TO DIPLOMACY").SetOnClick(function() ShowDiplomacyMenu(parent,game); end);
end

function ShowDiplomacyMenu(
    parent,
    game,
    focusPlayerID
)

    local area;
    if focusPlayerID then
        area = UI.CreateVerticalLayoutGroup(parent);
    else
        area = CreateContentArea(parent);
    end


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

local playerFilterButtons =
    {};

    local selectedDiplomacyPlayerID =
    focusPlayerID;

local selectedDiplomacyPlayerName =
    focusPlayerID and GetPlayerName(game, focusPlayerID) or nil;

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
    UI.CreateButton(economyRow).SetText("FACTIONS").SetOnClick(function() ShowFactionMenu(parent,game); end);

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

    -- Short vertical lines remain readable on mobile screens.
    UI.CreateLabel(selectedDiplomacyOverviewGroup).SetText(
        "Relationship: "..string.upper(tostring(status)).." | Commerce/Turn: "..tostring(GetPlayerIncome(game,targetID))
    ).SetColor(status=="war" and "#FF7B7B" or "#8FD694");
    UI.CreateLabel(selectedDiplomacyOverviewGroup).SetText(
        "Ideology: "..tostring(targetNation.ideology or "Unknown").." | Tax: "..tostring(targetNation.taxPolicy or "Unknown")
    );
    UI.CreateLabel(selectedDiplomacyOverviewGroup).SetText(
        "Economy: "..tostring(targetNation.economicStrategy or "Unknown").." | Company: "..tostring(targetNation.companyStrategy or "Unknown")
    );
    UI.CreateLabel(selectedDiplomacyOverviewGroup).SetText(
        "NAP: "..(hasNAP and "ACTIVE" or "NONE").." | Alliance: "..(isAllied and "ACTIVE" or "NONE")
    ).SetColor((hasNAP or isAllied) and "#62B6FF" or "#BBBBBB");

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

UI.CreateLabel(selectedDiplomacyOverviewGroup).SetText("KNOWN SECURITY & INTELLIGENCE").SetColor("#FFD166");
UI.CreateLabel(selectedDiplomacyOverviewGroup).SetText("Only information your nation has legitimately discovered is shown.").SetColor("#888888");
local playerData=Mod.PlayerGameData or {};
local strategicIntel=playerData.strategicIntel or {};
local knownCounts={}; local knownTotal=0;
for _,item in pairs(strategicIntel.knownMilitary or {}) do
    if item and item.ownerPlayerID==targetID then
        local kind=tostring(item.kind or "Asset");
        knownCounts[kind]=(knownCounts[kind] or 0)+1;
        knownTotal=knownTotal+1;
    end
end
if knownTotal==0 then
    UI.CreateLabel(selectedDiplomacyOverviewGroup).SetText("Known strategic assets: None discovered.").SetColor("#888888");
else
    local knownParts={};
    for kind,count in pairs(knownCounts) do table.insert(knownParts,kind.." "..tostring(count)); end
    table.sort(knownParts);
    UI.CreateLabel(selectedDiplomacyOverviewGroup).SetText("Known assets: "..table.concat(knownParts," | ")).SetColor("#62B6FF");
end
local targetReports={};
for _,report in ipairs((playerData.ownMilitary or {}).intelligenceReports or {}) do
    if report and report.targetPlayerID==targetID then table.insert(targetReports,report); end
end
table.sort(targetReports,function(a,b) return (tonumber(a.turn) or 0)>(tonumber(b.turn) or 0); end);
if #targetReports==0 then
    UI.CreateLabel(selectedDiplomacyOverviewGroup).SetText("Recent missions involving this player: None.").SetColor("#888888");
else
    for index=1,math.min(3,#targetReports) do
        local report=targetReports[index];
        UI.CreateLabel(selectedDiplomacyOverviewGroup).SetText(
            "T"..tostring(report.turn or "?").." | "..tostring(report.title or "Mission").." | "..tostring(report.result or "REPORT")
        ).SetColor(report.result=="SUCCESS" and "#79D279" or "#FFB366");
        UI.CreateLabel(selectedDiplomacyOverviewGroup).SetText(tostring(report.detail or "")).SetColor("#BBBBBB");
    end
end

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

    for filterKey, filterButton in pairs(playerFilterButtons) do
        if filterButton ~= nil and not UI.IsDestroyed(filterButton) then
            local labels = {
                ALL = "ALL",
                PLAYERS = "PLAYERS",
                AI = "AI",
                WAR = "AT WAR",
                PEACE = "AT PEACE"
            };
            filterButton.SetText(
                (DiplomacyPlayerFilter == filterKey and "▶ " or "") ..
                tostring(labels[filterKey] or filterKey)
            );
        end
    end

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

            local relationshipStatus = "peace";
            if ourID ~= nil then
                local a = tostring(ourID);
                local b = tostring(playerID);
                local relationshipKey = a < b and (a .. "|" .. b) or (b .. "|" .. a);
                local relationship = relationships[relationshipKey];
                if relationship ~= nil and relationship.status ~= nil then
                    relationshipStatus = relationship.status;
                end
            end

            local matchesFilter =
                DiplomacyPlayerFilter == "ALL"
                or (DiplomacyPlayerFilter == "PLAYERS" and player.IsAI ~= true)
                or (DiplomacyPlayerFilter == "AI" and player.IsAI == true)
                or (DiplomacyPlayerFilter == "WAR" and ourID ~= nil and relationshipStatus == "war")
                or (DiplomacyPlayerFilter == "PEACE" and ourID ~= nil and relationshipStatus ~= "war");

            if matchesFilter
                and (searchText == ""
                or string.find(
                    lowerName,
                    searchText,
                    1,
                    true
                ) ~= nil)
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

        if (index - 1) % 4 == 0 then

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

            game.CreateDialog(function(root, setMaxSize, setScrollable, dialogGame, closeDialog)
                setMaxSize(850, 650);
                setScrollable(true);
                ShowDiplomacyMenu(root, dialogGame, targetID);
                UI.CreateButton(root).SetText("CLOSE").SetOnClick(function()
                    closeDialog();
                end);
            end);

        end);

    end

end

    if not focusPlayerID then
    UI.CreateLabel(area)
        .SetText(
            "DIPLOMACY"
        );

    UI.CreateLabel(area)
        .SetText(
            "Filter, search, or tap a player to open their overview."
        );

    local function AddPlayerFilterButton(row, key, label)
        local button = UI.CreateButton(row)
            .SetText((DiplomacyPlayerFilter == key and "▶ " or "") .. label)
            .SetFlexibleWidth(1)
            .SetPreferredHeight(38);
        playerFilterButtons[key] = button;
        button.SetOnClick(function()
            DiplomacyPlayerFilter = key;
            RefreshPlayerSearchResults();
        end);
    end

    local filterRowOne = UI.CreateHorizontalLayoutGroup(area);
    AddPlayerFilterButton(filterRowOne, "ALL", "ALL");
    AddPlayerFilterButton(filterRowOne, "PLAYERS", "PLAYERS");
    AddPlayerFilterButton(filterRowOne, "AI", "AI");

    local filterRowTwo = UI.CreateHorizontalLayoutGroup(area);
    AddPlayerFilterButton(filterRowTwo, "WAR", "AT WAR");
    AddPlayerFilterButton(filterRowTwo, "PEACE", "AT PEACE");

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

    else
        selectedDiplomacyOverviewHost = UI.CreateVerticalLayoutGroup(area);
    end
    RefreshPlayerSearchResults();
    RefreshSelectedDiplomacyOverview();

    if not focusPlayerID then
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
                                if focusPlayerID then UI.Destroy(area); ShowDiplomacyMenu(parent, game, focusPlayerID); else ShowDiplomacyMenu(parent, game); end;
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
                                if focusPlayerID then UI.Destroy(area); ShowDiplomacyMenu(parent, game, focusPlayerID); else ShowDiplomacyMenu(parent, game); end;
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
                        if focusPlayerID then UI.Destroy(area); ShowDiplomacyMenu(parent, game, focusPlayerID); else ShowDiplomacyMenu(parent, game); end;
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
                        if focusPlayerID then UI.Destroy(area); ShowDiplomacyMenu(parent, game, focusPlayerID); else ShowDiplomacyMenu(parent, game); end;
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
                        if focusPlayerID then UI.Destroy(area); ShowDiplomacyMenu(parent, game, focusPlayerID); else ShowDiplomacyMenu(parent, game); end;
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


    end
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
            and focusPlayerID ~= nil and playerID == focusPlayerID
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


            row = UI.CreateHorizontalLayoutGroup(row);
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

                                    if focusPlayerID then UI.Destroy(area); ShowDiplomacyMenu(parent, game, focusPlayerID); else ShowDiplomacyMenu(parent, game); end;

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

                if focusPlayerID then UI.Destroy(area); ShowDiplomacyMenu(parent, game, focusPlayerID); else ShowDiplomacyMenu(parent, game); end;

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
                if focusPlayerID then UI.Destroy(area); ShowDiplomacyMenu(parent, game, focusPlayerID); else ShowDiplomacyMenu(parent, game); end;
            end);
        end);
    end

    if not warningShared then
        UI.CreateButton(row).SetText("REQUEST JOINT STRATEGIC WARNING").SetOnClick(function()
            SafeSendGameCustomMessage(game, "Sending alliance intelligence-sharing request...", {
                type="requestHeadquartersSharing", targetPlayerID=alliedPlayerID, shareType="JointStrategicWarning"
            }, function(result)
                if result and result.message then UI.Alert(result.message); end
                if focusPlayerID then UI.Destroy(area); ShowDiplomacyMenu(parent, game, focusPlayerID); else ShowDiplomacyMenu(parent, game); end;
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


                    if focusPlayerID then UI.Destroy(area); ShowDiplomacyMenu(parent, game, focusPlayerID); else ShowDiplomacyMenu(parent, game); end;

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


                    if focusPlayerID then UI.Destroy(area); ShowDiplomacyMenu(parent, game, focusPlayerID); else ShowDiplomacyMenu(parent, game); end;

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

                                if focusPlayerID then UI.Destroy(area); ShowDiplomacyMenu(parent, game, focusPlayerID); else ShowDiplomacyMenu(parent, game); end;

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
                focusPlayerID and "This player is no longer active." or "Click a player above to open their overview and actions."
            );
    end


    if focusPlayerID then return; end

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

                            if focusPlayerID then UI.Destroy(area); ShowDiplomacyMenu(parent, game, focusPlayerID); else ShowDiplomacyMenu(parent, game); end;

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

                            if focusPlayerID then UI.Destroy(area); ShowDiplomacyMenu(parent, game, focusPlayerID); else ShowDiplomacyMenu(parent, game); end;

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

                            if focusPlayerID then UI.Destroy(area); ShowDiplomacyMenu(parent, game, focusPlayerID); else ShowDiplomacyMenu(parent, game); end;

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

                            if focusPlayerID then UI.Destroy(area); ShowDiplomacyMenu(parent, game, focusPlayerID); else ShowDiplomacyMenu(parent, game); end;

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


                        if focusPlayerID then UI.Destroy(area); ShowDiplomacyMenu(parent, game, focusPlayerID); else ShowDiplomacyMenu(parent, game); end;

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


                        if focusPlayerID then UI.Destroy(area); ShowDiplomacyMenu(parent, game, focusPlayerID); else ShowDiplomacyMenu(parent, game); end;

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

-- Faction management moved to the dedicated FACTIONS tab.

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

    UI.CreateLabel(area).SetText("WHAT WOULD YOU LIKE TO DO?").SetColor("#FFD166");
    UI.CreateLabel(area).SetText("Buy Shares: choose a company and quantity. My Portfolio: review or sell holdings. ETF: buy a fund covering the global market.").SetColor("#BBBBBB");
    local marketActions = {
        {"BUY SHARES", ShowStockMarket}, {"PORTFOLIO", ShowStockPortfolio},
        {"OVERVIEW", ShowMarketOverview}, {"NEWS & ECONOMY", ShowMarketNews},
        {"GLOBAL ETF", ShowMarketETF}, {"TRADE", ShowTradeAgreementsMenu},
        {"INVESTMENTS", ShowInvestments}, {"AI MANAGER", ShowAIManagerMenu},
        {"HOW IT WORKS", function(p,g) ShowHowItWorks(p,g); end}
    };
    local shortcutRow;
    for index, entry in ipairs(marketActions) do
        if (index-1)%2 == 0 then shortcutRow = UI.CreateHorizontalLayoutGroup(area); end
        local action = entry[2];
        UI.CreateButton(shortcutRow).SetText(entry[1]).SetFlexibleWidth(1).SetPreferredHeight(42).SetOnClick(function() action(parent,game); end);
    end
    UI.CreateLabel(area).SetText("Tap How It Works for simple purchase, profit, loss, and shortage examples.").SetColor("#BBBBBB");


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


end



-- =========================================================
-- SHARED TAX / IDEOLOGY PREVIEW
-- =========================================================

function GetClientIdeologyRecruiterModifierPercent(ideologyOrNation)
    local ideology=type(ideologyOrNation)=="table" and ideologyOrNation.ideology or ideologyOrNation;
    ideology=ideology or "Social Democratic";
    if ideology=="Free Market" then return -15;
    elseif ideology=="Capitalist" then return -10;
    elseif ideology=="Social Democratic" then return 0;
    elseif ideology=="State Capitalist" then return 5;
    elseif ideology=="Socialist" then return 10;
    elseif ideology=="Communist" then return 15;
    elseif ideology=="Fascist" then return 10;
    elseif ideology=="Nationalist" then return 5;
    end
    return 0;
end

function GetPolicyPreviewData(game, taxPolicy, ideology, economicStrategy, companyStrategy)
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
    local projected=math.max(0,math.floor(currentCommerce*(1+commerce/100)+0.5));

    local currentPrice=math.floor(15+math.sqrt(math.max(0,currentCommerce))*2+0.5);
    currentPrice=math.max(10,math.min(150,currentPrice));
    local nation=GetOurNationState(game) or {};
    local economy=((Mod.PublicGameData or {}).globalEconomy or {}); local companies=((economy.market or {}).companies or {});
    for _,company in pairs(companies) do
        if company and (company.id==nation.flagshipCompanyID or company.ownerPlayerID==GetLocalPlayerID(game)) and company.active==true and company.delisted~=true then
            currentPrice=tonumber(company.currentPrice or company.startingPrice) or currentPrice; break;
        end
    end
    -- A fixed +5% base move makes the selected Market modifier readable. The
    -- actual turn still uses live income, demand, confidence and volatility.
    local baseMarketMove=5; local modifiedMarketMove=baseMarketMove*(1+market/100);
    local baseMarketPrice=currentPrice*(1+baseMarketMove/100); local modifiedMarketPrice=currentPrice*(1+modifiedMarketMove/100);
    local baseInvestmentReturn=25; local modifiedInvestmentReturn=baseInvestmentReturn*(1+investment/100);
    local recruiterBase=math.max(1,math.floor(tonumber(GetClientSetting("ArmyRecruiterArmiesPerTurn",4)) or 4)); local recruiterLevel=3;
    local recruiterModifier=GetClientIdeologyRecruiterModifierPercent(ideology);
    local recruiterBaseOutput=recruiterBase*recruiterLevel;
    local recruiterOutput=math.max(0,math.floor(recruiterBaseOutput*(1+recruiterModifier/100)+0.5));
    return {
        commerce=commerce,currentCommerce=currentCommerce,projectedCommerce=projected,
        market=market,currentPrice=currentPrice,baseMarketMove=baseMarketMove,modifiedMarketMove=modifiedMarketMove,
        baseMarketPrice=baseMarketPrice,modifiedMarketPrice=modifiedMarketPrice,
        investment=investment,baseInvestmentReturn=baseInvestmentReturn,modifiedInvestmentReturn=modifiedInvestmentReturn,
        confidence=confidence,recruiterModifier=recruiterModifier,recruiterBase=recruiterBase,recruiterLevel=recruiterLevel,recruiterBaseOutput=recruiterBaseOutput,recruiterOutput=recruiterOutput,
        strategyEffects=se,companyStrategy=companyStrategy,economicStrategy=economicStrategy
    };
end

function GetPolicyPreviewText(game, taxPolicy, ideology, economicStrategy, companyStrategy)
    local p=GetPolicyPreviewData(game,taxPolicy,ideology,economicStrategy,companyStrategy);
    local function sg(v,suf) return (v>0 and "+" or "")..tostring(v)..(suf or ""); end
    local companyText="Select a company strategy";
    if companyStrategy=="Growth" then companyText="Growth Company: price fundamentals x1.35 | dividend pool 1% of owner income | random volatility scale 30%";
    elseif companyStrategy=="Balanced" then companyText="Balanced Company: price fundamentals x1.00 | dividend pool 2% of owner income | random volatility scale 25%";
    elseif companyStrategy=="Dividend" then companyText="Dividend Company: price fundamentals x0.45 | dividend pool 4%-6% of owner income | random volatility scale 15%"; end
    return "LIVE NUMERICAL PREVIEW\n"..
        "COMMERCE: "..tostring(p.currentCommerce).." -> "..tostring(p.projectedCommerce).." /turn ("..sg(p.commerce,"%")..")\n"..
        "MARKET LIVE PRICE: "..string.format("%.2f",p.currentPrice).." | example +5.00% move: "..string.format("%.2f",p.baseMarketPrice).." -> "..string.format("%.2f",p.modifiedMarketPrice).." ("..sg(p.market,"%").." modifier)\n"..
        "INVESTMENT: 100 at 25% base return pays "..string.format("%.2f",100+p.baseInvestmentReturn).." -> "..string.format("%.2f",100+p.modifiedInvestmentReturn).." total ("..sg(p.investment,"%")..")\n"..
        "RECRUITER LEVEL "..tostring(p.recruiterLevel).." EXAMPLE: "..tostring(p.recruiterBaseOutput).." -> "..tostring(p.recruiterOutput).." armies/turn (Ideology "..sg(p.recruiterModifier,"%")..")\n"..
        "CONFIDENCE MODIFIER: "..sg(p.confidence,"").."\n"..
        "Economic Strategy: "..tostring(economicStrategy or "None").." => Commerce "..sg(p.strategyEffects[1],"%")..", Market "..sg(p.strategyEffects[2],"%")..", Investment "..sg(p.strategyEffects[3],"%")..", Confidence "..sg(p.strategyEffects[4],"").."\n"..
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
    local ideologyRecruiter=GetClientIdeologyRecruiterModifierPercent(nation); local readiness=math.max(0,math.min(100,tonumber(nation.resourceMilitaryReadiness) or 100)); local unrest=math.max(0,math.min(100,tonumber(nation.resourceUnrest) or 0)); local unrestPenalty=(unrest>=80 and 35) or (unrest>=60 and 20) or (unrest>=40 and 10) or (unrest>=20 and 5) or 0;
    local livePerLevel=math.max(0,math.floor(recruiterArmies*readiness/100*math.max(0,100+ideologyRecruiter-unrestPenalty)/100+0.5));
    local sign=ideologyRecruiter>0 and "+" or "";
    UI.CreateLabel(area).SetText("Stations: "..tostring(nation.armyRecruiterCount or 0).."/"..tostring(recruiterMax).." | Base: "..tostring(recruiterArmies).." armies per level/turn");
    UI.CreateLabel(area).SetText("LIVE PER LEVEL: "..tostring(recruiterArmies).." -> "..tostring(livePerLevel).." | Ideology "..sign..tostring(ideologyRecruiter).."% | Readiness "..tostring(math.floor(readiness)).."% | Unrest -"..tostring(unrestPenalty).."%").SetColor(livePerLevel>=recruiterArmies and "#79D279" or "#FF7B7B");
    UI.CreateLabel(area).SetText("Last full-turn production: "..tostring(nation.armyRecruiterArmiesGeneratedThisTurn or 0).." armies from "..tostring(nation.armyRecruiterLevels or 0).." total Recruiter level(s).").SetColor("#67D5FF");
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
    UI.CreateLabel(area).SetText("Silo construction/upgrades require 1 Uranium per level. Nuclear missile resupply consumes 1 additional Uranium. Select a silo, resupply missiles, then choose a weapon and target. Strikes resolve on turn advancement.").SetColor("#BBBBBB");
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
    UI.CreateLabel(area).SetText("Infrastructure intelligence follows the same private model as Resources. Power Grids and Cyber Facilities never broadcast global map icons. Enemy Air Wings and Special Forces use normal fog visibility and are no longer globally visible.").SetColor("#BBBBBB");
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
    if GetClientSetting("MissileSilosEnabled",true) then UFAddStructureAction(area,parent,game,"MISSILE SILO","MissileSilo",GetClientSetting("MissileSiloBaseCost",500)," | requires Grid + 1 Uranium per level","#FF7B7B"); UI.CreateButton(area).SetText("MISSILE COMMAND / TARGETING").SetOnClick(function() ShowMissileCommandMenu(parent,game); end); end
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

    QueueTab("factions", "Factions", "#8A6D1D", "#FFFFFF", function()
        ShowFactionMenu(contentHost, game);
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
        local ideologyRecruiterModifier=GetClientIdeologyRecruiterModifierPercent(nation);
        UI.CreateLabel(area).SetText("Recruiter Ideology: "..tostring(nation.ideology or "None").." | "..(ideologyRecruiterModifier>0 and "+" or "")..tostring(ideologyRecruiterModifier).."% troop production").SetColor(ideologyRecruiterModifier>=0 and "#79D279" or "#FF7B7B");
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

        -- Fast, private security briefing. Only the local player's legitimately
        -- available PlayerGameData is used here.
        UI.CreateLabel(area).SetText("SECURITY REPORTS").SetColor("#FFD166");
        local securityState=(Mod.PlayerGameData or {}).ownMilitary or {};
        local pendingSecurityAlerts=0;
        for _,alert in ipairs(securityState.counterIntelAlerts or {}) do
            if tostring(alert.status or "") == "PENDING" then pendingSecurityAlerts=pendingSecurityAlerts+1; end
        end
        local securityItems={};
        local function addSecurityItem(category,turn,title,result,detail,color)
            table.insert(securityItems,{category=category,turn=tonumber(turn) or 0,title=title,result=result,detail=detail,color=color});
        end
        for _,report in ipairs(securityState.intelligenceReports or {}) do
            addSecurityItem("INTEL / CYBER",report.turn,report.title or "Intelligence",report.result or "REPORT",report.detail or "",report.incoming==true and "#FFB366" or "#62B6FF");
        end
        for _,report in ipairs(securityState.hqRecentResults or {}) do
            addSecurityItem("MISSILE / STRATEGIC",report.turn,report.action or "Strategic Event",report.result or "REPORT",report.detail or "","#FF9B71");
        end
        for _,report in ipairs(securityState.airWingReports or {}) do
            addSecurityItem("AIR MISSION",report.turn,report.mission or "Air Mission",report.result or "REPORT",(report.target and ("Target: "..tostring(report.target).." | ") or "")..tostring(report.detail or ""),"#82CFFF");
        end
        for _,warning in ipairs(securityState.strategicWarnings or {}) do
            addSecurityItem("WARNING",warning.turn,"Advance Warning","URGENT",warning.text or "Strategic threat detected.","#FF6B6B");
        end
        table.sort(securityItems,function(a,b) return a.turn>b.turn; end);
        UI.CreateLabel(area).SetText(
            "Pending counterintelligence alerts: "..tostring(pendingSecurityAlerts)..
            " | Stored reports: "..tostring(#securityItems)
        ).SetColor(pendingSecurityAlerts>0 and "#FF7B7B" or "#8FD694");
        if #securityItems==0 then
            UI.CreateLabel(area).SetText("No intelligence, cyber, missile, or air-mission reports yet.").SetColor("#888888");
        else
            for index=1,math.min(4,#securityItems) do
                local item=securityItems[index];
                UI.CreateLabel(area).SetText(
                    "T"..tostring(item.turn).." | "..item.category.." | "..tostring(item.title).." | "..tostring(item.result)
                ).SetColor(item.color);
                if tostring(item.detail or "")~="" then UI.CreateLabel(area).SetText(tostring(item.detail)).SetColor("#BBBBBB"); end
            end
        end
        UI.CreateButton(area).SetText("OPEN ALL SECURITY REPORTS").SetPreferredHeight(40).SetOnClick(function()
            ShowStrategicReportsMenu(parent,game,"all");
        end);
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
    local search=CreateWideTextInput(area,300).SetPlaceholderText("Search nation...");
    local filters=nil; local host=UI.CreateVerticalLayoutGroup(area);
    local refresh=nil;
    for index,fd in ipairs({{"ALL","ALL"},{"PLAYER","PLAYERS"},{"AI","AI"},{"AVAILABLE","AVAILABLE"},{"EXISTING","EXISTING"}}) do
        if (index-1)%2==0 then filters=UI.CreateHorizontalLayoutGroup(area); end
        local key,label=fd[1],fd[2];
        UI.CreateButton(filters).SetText((TradePartnerFilter==key and "▶ " or "")..label).SetFlexibleWidth(1).SetPreferredHeight(38).SetOnClick(function() TradePartnerFilter=key; refresh(); end);
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
        for _,x in ipairs(list) do local income=GetPlayerIncome(game,x.id) or 0; local bonus=CalculateTradeBonus(income); local g=UI.CreateVerticalLayoutGroup(host);
            local status=x.ag and "ACTIVE" or (x.pend and "PENDING" or (x.cd>0 and ("COOLDOWN "..tostring(x.cd)) or (x.count>=ClientMaxAgreements() and "AT LIMIT" or "AVAILABLE")));
            UI.CreateLabel(g).SetText(x.name.." | "..(x.p.IsAI and "AI" or "PLAYER")).SetColor(GetPlayerUIColor(game,x.id,"#FFFFFF"));
            UI.CreateLabel(g).SetText("Income: "..tostring(income).." | Your bonus: +"..tostring(bonus).."/turn").SetColor(x.available and "#8FD694" or "#DDDDDD");
            UI.CreateLabel(g).SetText("Status: "..status).SetColor(x.available and "#79D279" or "#FFB366");
            if x.available then local tid=x.id; UI.CreateButton(g).SetText("PROPOSE TRADE").SetPreferredHeight(38).SetOnClick(function() SafeSendGameCustomMessage(game,"Sending trade proposal...",{type="proposeTrade",targetPlayerID=tid},function(r) if r and r.message then UI.Alert(r.message); end; ShowFindPartners(parent,game); end); end); end
            UI.CreateLabel(g).SetText("----------------------------------------").SetColor("#555555");
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
local targetMarketCap = math.max(0,tonumber(company.marketCap) or ((tonumber(company.currentPrice) or 1)*(tonumber(company.totalShares) or 100)));
local totalSharesForAcquisition = math.max(1,tonumber(company.totalShares) or 100);
local activeCompanyCount=0; local activeMarketCapTotal=0; local targetMarketRank=1;
for _,peer in pairs(market.companies or {}) do
    if peer and peer.active==true and peer.delisted~=true and peer.status=="trading" then
        local peerCap=math.max(0,tonumber(peer.marketCap) or ((tonumber(peer.currentPrice) or 1)*(tonumber(peer.totalShares) or 100)));
        activeCompanyCount=activeCompanyCount+1;
        activeMarketCapTotal=activeMarketCapTotal+peerCap;
        if peerCap>targetMarketCap then targetMarketRank=targetMarketRank+1; end
    end
end
local averageActiveMarketCap=activeCompanyCount>0 and math.floor(activeMarketCapTotal/activeCompanyCount+0.5) or targetMarketCap;
local acquisitionBoost=math.max(0,tonumber(GetClientSetting("AcquisitionBuyerStockBoostPercent",15)) or 15);
local localTargetShares=math.max(0,tonumber((((economy.nations or {})[localPlayerID] or {}).stockHoldings or {})[companyID]) or 0);

UI.CreateLabel(area).SetText("VALUE COMPARISON").SetColor("#FFD166");
UI.CreateLabel(area).SetText("Target market cap: "..tostring(targetMarketCap).." Commerce").SetColor("#DDDDDD");
UI.CreateLabel(area).SetText("Market position: #"..tostring(targetMarketRank).." of "..tostring(activeCompanyCount).." | Active-company average: "..tostring(averageActiveMarketCap)).SetColor("#9CCBFF");
UI.CreateLabel(area).SetText("Offer formula: "..tostring(acquisitionPremium).."% of market cap = "..tostring(estimatedAcquisitionPrice).." Commerce").SetColor("#FFB366");

local function ShowAcquisitionImpact(buyerID,offerPrice)
    local finalPrice=math.max(1,math.floor(tonumber(offerPrice) or estimatedAcquisitionPrice));
    local payoutPerShare=finalPrice/totalSharesForAcquisition;
    UI.CreateLabel(area).SetText("TARGET INVESTORS").SetColor("#79D279");
    UI.CreateLabel(area).SetText("Estimated cash payout: "..string.format("%.2f",payoutPerShare).." Commerce per target share.").SetColor("#BBBBBB");
    if localTargetShares>0 then
        UI.CreateLabel(area).SetText("Your "..tostring(localTargetShares).." target shares: "..tostring(math.floor(payoutPerShare*localTargetShares)).." Commerce cash-out.").SetColor("#79D279");
    end
    if company.ownerPlayerID==localPlayerID then
        local paidToOtherShareholders=0;
        for holderID,holderNation in pairs(economy.nations or {}) do
            if holderID~=localPlayerID then
                local holderShares=math.max(0,tonumber(((holderNation.stockHoldings or {})[companyID])) or 0);
                paidToOtherShareholders=paidToOtherShareholders+math.floor(payoutPerShare*holderShares);
            end
        end
        local projectedSellerTotal=math.max(0,finalPrice-paidToOtherShareholders);
        UI.CreateLabel(area).SetText("SELLER SETTLEMENT").SetColor("#FFD166");
        UI.CreateLabel(area).SetText("Other shareholders: "..tostring(paidToOtherShareholders).." Commerce | Your projected total proceeds: "..tostring(projectedSellerTotal).." Commerce.").SetColor("#FFD166");
        UI.CreateLabel(area).SetText("Your total includes your own share cash-out plus the remaining company-sale value.").SetColor("#BBBBBB");
    end

    local buyerNation=(economy.nations or {})[buyerID] or {};
    local buyerCompanyID=buyerNation.flagshipCompanyID;
    local buyerCompany=buyerCompanyID and (market.companies or {})[buyerCompanyID] or nil;
    UI.CreateLabel(area).SetText("BUYER FLAGSHIP IMPACT").SetColor("#67D5FF");
    if buyerCompany and buyerCompany.active==true and buyerCompany.delisted~=true then
        local oldPrice=math.max(1,tonumber(buyerCompany.currentPrice or buyerCompany.startingPrice) or 1);
        local newPrice=math.max(1,math.floor(oldPrice*(1+acquisitionBoost/100)+0.5));
        local gainPerShare=newPrice-oldPrice;
        local oldConfidence=math.max(0,math.min(100,tonumber(buyerCompany.confidence) or 50));
        local newConfidence=math.min(100,oldConfidence+8);
        UI.CreateLabel(area).SetText(tostring(buyerCompany.name or "Buyer flagship")..": "..tostring(oldPrice).." → "..tostring(newPrice).." per share ("..tostring(acquisitionBoost).."% setting).").SetColor("#67D5FF");
        UI.CreateLabel(area).SetText("Each existing buyer-flagship share gains about "..tostring(gainPerShare).." in displayed value; confidence "..tostring(oldConfidence).." → "..tostring(newConfidence)..". This is market value, not an immediate cash dividend.").SetColor("#BBBBBB");
    else
        UI.CreateLabel(area).SetText(GetPlayerName(game,buyerID).." has no active flagship to receive the stock-price and confidence boost.").SetColor("#888888");
    end
end

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
            UI.CreateLabel(area).SetText(GetPlayerName(game,buyerID).." | Offer: "..tostring(offer.price or 0).." Commerce").SetColor(GetPlayerUIColor(game,buyerID,"#FFFFFF"));
            local row=UI.CreateHorizontalLayoutGroup(area);
            UI.CreateButton(row).SetText("ACCEPT").SetFlexibleWidth(1).SetPreferredHeight(38).SetOnClick(function()
                SafeSendGameCustomMessage(game,"Accepting acquisition...",{type="acceptAcquisitionOffer",companyID=companyID,buyerID=buyerID},function(result)
                    if result and result.message then UI.Alert(result.message); end
                    ShowMarketsMenu(parent,game);
                end);
            end);
            UI.CreateButton(row).SetText("REJECT").SetFlexibleWidth(1).SetPreferredHeight(38).SetOnClick(function()
                SafeSendGameCustomMessage(game,"Rejecting acquisition...",{type="rejectAcquisitionOffer",companyID=companyID,buyerID=buyerID},function(result)
                    if result and result.message then UI.Alert(result.message); end
                    ShowCompanyDetails(parent,game,companyID);
                end);
            end);
            ShowAcquisitionImpact(buyerID,offer.price);
        end
    end
    if offerCount==0 then UI.CreateLabel(area).SetText("No pending acquisition offers.").SetColor("#888888"); end
elseif company.allowAcquisitionOffers == true then
    UI.CreateLabel(area).SetText("Estimated acquisition offer: "..tostring(estimatedAcquisitionPrice).." Commerce").SetColor("#FFD166");
    ShowAcquisitionImpact(localPlayerID,estimatedAcquisitionPrice);
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

    local ourNation=GetOurNationState(game);
    if ourNation~=nil and ourNation.setupComplete==true then
        local live=GetPolicyPreviewData(game,ourNation.taxPolicy,ourNation.ideology,ourNation.economicStrategy,ourNation.companyStrategy);
        local function sg(v,suf) return (v>0 and "+" or "")..tostring(v)..(suf or ""); end
        UI.CreateLabel(area).SetText("YOUR LIVE POLICY IMPACT").SetColor("#FFFFFF");
        UI.CreateLabel(area).SetText("Commerce: "..tostring(live.currentCommerce).." -> "..tostring(live.projectedCommerce).." /turn | "..sg(live.commerce,"%")).SetColor(live.commerce>=0 and "#79D279" or "#FF7B7B");
        UI.CreateLabel(area).SetText("Stock price: "..string.format("%.2f",live.currentPrice).." | example +5.00% move: "..string.format("%.2f",live.baseMarketPrice).." -> "..string.format("%.2f",live.modifiedMarketPrice).." | Market "..sg(live.market,"%")).SetColor(live.market>=0 and "#67D5FF" or "#FF7B7B");
        UI.CreateLabel(area).SetText("Investment example: 100 at 25% base return | payout "..string.format("%.2f",100+live.baseInvestmentReturn).." -> "..string.format("%.2f",100+live.modifiedInvestmentReturn).." | "..sg(live.investment,"%")).SetColor(live.investment>=0 and "#D98CFF" or "#FF7B7B");
        UI.CreateLabel(area).SetText("Recruiter Level "..tostring(live.recruiterLevel).." example: "..tostring(live.recruiterBaseOutput).." -> "..tostring(live.recruiterOutput).." armies/turn | Ideology "..sg(live.recruiterModifier,"%")).SetColor(live.recruiterModifier>=0 and "#FFB366" or "#FF7B7B");
        UI.CreateLabel(area).SetText("Stock movement still changes with live income, trading demand, confidence, and random volatility.").SetColor("#AAAAAA");
        UI.CreateLabel(area).SetText("----------------------------------------");
    end

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
UI.CreateLabel(area).SetText("STOCK RANKINGS").SetColor("#FFFFFF");

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

UI.CreateLabel(area).SetText("TOP 5 GROWTH STOCKS").SetColor("#32CD32");
for i=1,math.min(5,#rankedMoves) do
    local entry = rankedMoves[i];
    local company = entry.company;
    local ownerNation = (economy.nations or {})[company.ownerPlayerID] or {};
    UI.CreateLabel(area).SetText(
        tostring(i) .. ". " .. tostring(company.name or "Company") ..
        " | " .. string.format("%+.1f%%", entry.pct) ..
        " | Price " .. string.format("%.2f",tonumber(company.currentPrice or company.startingPrice) or 0) ..
        " | Confidence " .. tostring(math.floor((company.confidence or 50)+0.5)) .. "%" ..
        " | Unrest " .. tostring(math.floor((ownerNation.resourceUnrest or 0)+0.5))
    );
end

local rankedDividends={};
for _,company in pairs(companies) do
    if company.active==true and company.delisted~=true then
        local price=math.max(0.01,tonumber(company.currentPrice or company.startingPrice) or 0.01);
        local dividend=math.max(0,tonumber(company.dividendPerShare) or 0);
        table.insert(rankedDividends,{company=company,dividend=dividend,yield=(dividend/price)*100});
    end
end
table.sort(rankedDividends,function(a,b)
    if a.dividend==b.dividend then return a.yield>b.yield; end
    return a.dividend>b.dividend;
end);
UI.CreateLabel(area).SetText("TOP 5 DIVIDEND STOCKS").SetColor("#79D279");
if #rankedDividends==0 then UI.CreateLabel(area).SetText("No active dividend stocks yet.").SetColor("#888888"); end
for i=1,math.min(5,#rankedDividends) do
    local entry=rankedDividends[i]; local company=entry.company;
    UI.CreateLabel(area).SetText(
        tostring(i)..". "..tostring(company.name or "Company")..
        " | "..string.format("%.2f",entry.dividend).." Commerce/share"..
        " | Yield "..string.format("%.2f%%",entry.yield)..
        " | Total paid "..tostring(company.totalDividendsPaid or 0)
    ).SetColor(entry.dividend>0 and "#79D279" or "#BBBBBB");
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

function ShowMarketNewsLegacy(
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

function ShowMarketNews(parent,game)
    local area=CreateContentArea(parent);
    local data=Mod.PublicGameData or {};
    local economy=data.globalEconomy or {};
    local market=economy.market or {};

    UI.CreateLabel(area).SetText("MARKET & GLOBAL ECONOMY NEWS").SetColor("#67D5FF");
    UI.CreateLabel(area).SetText("Acquisitions, stock events, dividends, trade, investments, and global economic activity in one feed.").SetColor("#BBBBBB");
    UI.CreateButton(area).SetText("BACK TO MARKET").SetOnClick(function() ShowMarketsMenu(parent,game); end);

    local filters={{"ALL","ALL"},{"BIG EVENTS","BIG"},{"STOCKS","STOCKS"},{"DIVIDENDS","DIVIDENDS"},{"GLOBAL ECONOMY","GLOBAL"}};
    local filterRow=nil;
    for index,item in ipairs(filters) do
        if (index-1)%2==0 then filterRow=UI.CreateHorizontalLayoutGroup(area); end
        local label,value=item[1],item[2];
        UI.CreateButton(filterRow).SetText((MarketNewsFilter==value and "▶ " or "")..label).SetFlexibleWidth(1).SetPreferredHeight(38).SetOnClick(function()
            MarketNewsFilter=value; ShowMarketNews(parent,game);
        end);
    end
    UI.CreateLabel(area).SetText("----------------------------------------");

    local combined={}; local seen={}; local sequence=0;
    local labels={acquisition="ACQUISITION",stock_split="STOCK SPLIT",etf_rebalance="ETF REBALANCE",war_bond="WAR BOND",major_move="PRICE MOVE",dividend="DIVIDEND",etf_dividend="ETF DIVIDEND",etf_bonus="ETF BONUS"};
    local function addEntry(turn,eventType,message,category,color,priority)
        local key=tostring(turn).."|"..tostring(message);
        if seen[key] then return; end
        seen[key]=true; sequence=sequence+1;
        table.insert(combined,{turn=tonumber(turn) or 0,eventType=tostring(eventType or "update"),message=tostring(message or "Economic update."),category=category or "GLOBAL",color=color or "#BBBBBB",priority=priority or 1,sequence=sequence});
    end
    for _,entry in ipairs(market.news or {}) do
        local typ=tostring(entry.type or "market_update");
        local category="STOCKS"; local color="#62B6FF"; local priority=2;
        if typ=="acquisition" then category="BIG"; color="#FFB347"; priority=5;
        elseif typ=="stock_split" or typ=="etf_rebalance" or typ=="war_bond" then category="BIG"; color="#D4AF37"; priority=4;
        elseif typ=="dividend" or typ=="etf_dividend" or typ=="etf_bonus" then category="DIVIDENDS"; color="#79D279"; priority=3;
        elseif typ=="major_move" then category="STOCKS"; priority=3; color=string.find(string.lower(tostring(entry.message or "")),"fell",1,true) and "#FF7B7B" or "#32CD32"; end
        addEntry(entry.turn,typ,entry.message,category,color,priority);
    end
    for _,entry in ipairs(data.tradeHistory or {}) do
        local typ=tostring(entry.type or "economic_update");
        local category=GetEventCategory(typ);
        local label=(category=="investments" or category=="success" or category=="failed") and "INVESTMENT" or (category=="ai" and "AI ECONOMY" or "TRADE");
        local color=(category=="success" and "#79D279") or (category=="failed" and "#FF7B7B") or (category=="investments" and "#D995FF") or "#81C784";
        addEntry(entry.turn,label,entry.message,"GLOBAL",color,2);
    end
    for _,entry in ipairs(economy.worldEvents or {}) do
        addEntry(entry.turn,entry.type or "WORLD EVENT",entry.headline or entry.message,"GLOBAL","#9CCBFF",2);
    end
    table.sort(combined,function(a,b)
        if a.turn==b.turn then if a.priority==b.priority then return a.sequence>b.sequence; end; return a.priority>b.priority; end
        return a.turn>b.turn;
    end);

    local shown=0;
    for _,entry in ipairs(combined) do
        local passes=MarketNewsFilter=="ALL" or entry.category==MarketNewsFilter;
        if passes and shown<25 then
            local typeLabel=labels[entry.eventType] or string.upper(string.gsub(entry.eventType,"_"," "));
            UI.CreateLabel(area).SetText("TURN "..tostring(entry.turn).." | "..typeLabel).SetColor(entry.color);
            UI.CreateLabel(area).SetText(entry.message).SetColor("#DDDDDD");
            UI.CreateLabel(area).SetText("----------------------------------------").SetColor("#444444");
            shown=shown+1;
        end
    end
    if shown==0 then UI.CreateLabel(area).SetText("No news matches this category yet.").SetColor("#888888"); end
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

    Section("WORKED EXAMPLES — ILLUSTRATIVE NUMBERS",
        "Stocks: At 20 Commerce per share, 5 shares cost 100 before any applicable fees. At a later price of 24, those shares are worth 120; at 16, they are worth 80. A displayed gain becomes realized when you sell. Dividends depend on the company and game settings; they are not guaranteed.\n\n" ..
        "ETF: Buy units of the global fund instead of choosing a single flagship. Its value can rise or fall with the market. Review the displayed price and total before confirming.\n\n" ..
        "Resources: With production 4 and need 7, the deficit is 3. A stockpile of 5 covers this turn and leaves 2. If the same deficit continues next turn, 1 remains uncovered. Build production or arrange a resource contract.\n\n" ..
        "Diplomacy: Click a player name to open their overview and available actions. At peace, you may see Declare War, Propose NAP, or Propose Alliance. An active pact or alliance can restrict war. At war, Offer Peace becomes available.", "#FFD166");

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
        "Recruiting Stations, Airbases, Forward Airstrips and Missile Silos can have a visible map presence. Power Grids and Cyber Facilities are PRIVATE infrastructure: their map icons are suppressed and their locations are revealed only through the Military Infrastructure intelligence screen.\n\n" ..
        "Recruiters, Airbases, Airstrips and Silos use structure-style map assets. Power Grids and Cyber Facilities are stored privately and do not broadcast standing icons. Air Wings and Special Forces use custom special-unit icons under normal fog. A visible structure upgrade replaces its tier rather than creating duplicate icons.\n\n" ..
        "Military Infrastructure uses My Infrastructure, Neighbors, Ally/Faction, and All Known filters. SHOW highlights a known installation and returns through a small Back control. Air Wings and Special Forces use normal game fog instead of forced global visibility.",
        "#FFB74D");

    Section("CYBER FACILITIES",
        "Cyber Facilities provide offensive cyber capability directly. Their locations are PRIVATE like resources and are not globally exposed as standing icons. They require an operational Power Grid and can launch one cyber disruption operation per turn during an active war. Higher facility levels improve offensive capability, while the target's Cyber Facilities provide defensive resistance.\n\n" ..
        "Cyber Facilities are optional. If the host disables them, Recruiters and the rest of the enabled military systems continue to work normally.",
        "#C792EA");

    Section("ALLIANCES, FACTIONS & SHARING",
        "Faction membership automatically enables strategic intelligence sharing among faction members.\n\n" ..
        "Normal alliances do not automatically reveal private intelligence. Allied players can separately request Shared Intelligence and Joint Strategic Warning. Shared Intelligence controls access to private resource/military discoveries; Joint Strategic Warning is reserved for coordinated warning and strategic-defense behavior.\n\n" ..
        "If the alliance ends, ongoing sharing ends. Previously learned intelligence may remain as historical/last-known information.",
        "#64B5F6");

    Section("RECRUITING STATIONS",
        "Recruiters are visible military structures that generate armies each turn according to their level, national Ideology, Military Readiness, Unrest, and active Faction exercise bonuses. Free Market and Capitalist systems accept lower troop production for stronger private-market benefits; state-directed and military-focused systems receive higher troop output. Every Recruiter screen shows the exact live before-and-after number. Upgrading changes the same Recruiter structure tier instead of creating another Recruiter icon.\n\n" ..
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
        "Missile Silos are strategic structures with limited missile inventory and resupply. Building or upgrading a Silo consumes 1 Uranium per level, and each Nuclear missile resupply consumes 1 additional Uranium. Conventional missiles damage armies/assets. EMP strikes disable systems and can spread from stronger Silos. Nuclear strikes use Low/Medium/High yield (limited by Silo level) and can damage armies, cities/territories, resource facilities, and strategic assets across the target and nearby territories.\n\n" ..
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
        "Diplomacy contains relations, alliances, Factions, Current Wars, Join War, peace, NAPs, shared-intelligence requests, Faction leadership controls, and Military Exercises. Wars remain inside Diplomacy rather than using a separate top-level Wars tab. Use ALL, PLAYERS, AI, AT WAR, and AT PEACE to shorten the player list, then search or tap a name to open that player's overview.\n\n" ..
        "Current Wars groups coalition conflicts into one entry and preserves the original cause. Join War lets an eligible human choose a side subject to diplomacy safety checks. AI allies and faction partners may also enter an ally's conflict, while AI nations can proactively seek Alliances when trade/NAP relationships and strategic conditions make cooperation useful. Trade Agreements are available to human players from both Markets and Diplomacy.\n\n" ..
        "GIFT CARDS: Peaceful territory gifts remain allowed. If the host enables the wartime Gift Card restriction, a Gift Card sent directly between two nations that are officially at war is rejected by the server. Gift Cards therefore cannot replace combat or evade the official-war rules.",
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
            )
            .SetColor("#FFD166");


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
            )
            .SetColor("#FFD166");


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
            )
            .SetColor("#67D5FF");


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

    local policyPreviewLabels =
    nil;

    local companyNameInput =
        nil;


    local ideologyLabel =
        UI.CreateLabel(
            area
        ).SetColor("#C792EA");


    local economicStrategyLabel =
        UI.CreateLabel(
            area
        ).SetColor("#67D5FF");


    local taxLabel =
        UI.CreateLabel(
            area
        ).SetColor("#FFD166");


    local companyStrategyLabel =
        UI.CreateLabel(
            area
        ).SetColor("#79D279");

local function GetIdeologyEffectsText(
    ideology
)

    if ideology == "Free Market" then
        return "Ideology Effects - Free Market\nGovernment Commerce: -3% | Market: +8% | Investment: +6% | Confidence: +2 | Recruiters: -15%";
    elseif ideology == "Capitalist" then
        return "Ideology Effects - Capitalist\nGovernment Commerce: -2% | Market: +6% | Investment: +5% | Confidence: +3 | Recruiters: -10%";
    elseif ideology == "Social Democratic" then
        return "Ideology Effects - Social Democratic\nGovernment Commerce: +2% | Market: +2% | Investment: +3% | Confidence: +2 | Recruiters: 0%";
    elseif ideology == "State Capitalist" then
        return "Ideology Effects - State Capitalist\nGovernment Commerce: +4% | Market: +1% | Investment: +5% | Confidence: +4 | Recruiters: +5%";
    elseif ideology == "Socialist" then
        return "Ideology Effects - Socialist\nGovernment Commerce: +5% | Market: -5% | Investment: +1% | Confidence: +1 | Recruiters: +10%";
    elseif ideology == "Communist" then
        return "Ideology Effects - Communist\nGovernment Commerce: +7% | Market: -9% | Investment: -2% | Confidence: +0 | Recruiters: +15%";
    elseif ideology == "Fascist" then
        return "Ideology Effects - Fascist\nGovernment Commerce: +3% | Market: -2% | Investment: +1% | Confidence: +3 | Recruiters: +10%";
    elseif ideology == "Nationalist" then
        return "Ideology Effects - Nationalist\nGovernment Commerce: +2% | Market: -1% | Investment: +0% | Confidence: +2 | Recruiters: +5%";
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

if policyPreviewLabels ~= nil then
    local p=GetPolicyPreviewData(game,selectedTaxPolicy,selectedIdeology,selectedEconomicStrategy,selectedCompanyStrategy);
    local function sg(v,suf) return (v>0 and "+" or "")..tostring(v)..(suf or ""); end
    policyPreviewLabels.commerce.SetText("COMMERCE / TURN | "..tostring(p.currentCommerce).." -> "..tostring(p.projectedCommerce).." | "..sg(p.commerce,"%"));
    policyPreviewLabels.commerce.SetColor(p.commerce>=0 and "#79D279" or "#FF7B7B");
    policyPreviewLabels.market.SetText("MARKET LIVE PRICE | "..string.format("%.2f",p.currentPrice).." | example +5.00% move: "..string.format("%.2f",p.baseMarketPrice).." -> "..string.format("%.2f",p.modifiedMarketPrice).." | modifier "..sg(p.market,"%"));
    policyPreviewLabels.market.SetColor(p.market>=0 and "#67D5FF" or "#FF7B7B");
    policyPreviewLabels.investment.SetText("INVESTMENT EXAMPLE | 100 at 25% base return | payout "..string.format("%.2f",100+p.baseInvestmentReturn).." -> "..string.format("%.2f",100+p.modifiedInvestmentReturn).." | modifier "..sg(p.investment,"%"));
    policyPreviewLabels.investment.SetColor(p.investment>=0 and "#D98CFF" or "#FF7B7B");
    policyPreviewLabels.recruiter.SetText("RECRUITER LEVEL "..tostring(p.recruiterLevel).." EXAMPLE | "..tostring(p.recruiterBaseOutput).." -> "..tostring(p.recruiterOutput).." armies/turn | ideology "..sg(p.recruiterModifier,"%"));
    policyPreviewLabels.recruiter.SetColor(p.recruiterModifier>=0 and "#FFB366" or "#FF7B7B");
    policyPreviewLabels.confidence.SetText("COMPANY CONFIDENCE | modifier "..sg(p.confidence,"").." | 10 confidence changes stock movement by 0.6 percentage points");
    policyPreviewLabels.confidence.SetColor(p.confidence>=0 and "#FFD166" or "#FF7B7B");
    local se=p.strategyEffects;
    policyPreviewLabels.strategy.SetText("Selected Economic Strategy: "..tostring(selectedEconomicStrategy or "None").." | Commerce "..sg(se[1],"%").." | Market "..sg(se[2],"%").." | Investment "..sg(se[3],"%").." | Confidence "..sg(se[4],""));
    local companyText="Select a company strategy";
    if selectedCompanyStrategy=="Growth" then companyText="Growth Company | price fundamentals x1.35 | dividend pool 1% | volatility scale 30%";
    elseif selectedCompanyStrategy=="Balanced" then companyText="Balanced Company | price fundamentals x1.00 | dividend pool 2% | volatility scale 25%";
    elseif selectedCompanyStrategy=="Dividend" then companyText="Dividend Company | price fundamentals x0.45 | dividend pool 4%-6% | volatility scale 15%"; end
    policyPreviewLabels.company.SetText(companyText);
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
        )
        .SetColor("#C792EA");


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
            "Free Market | Commerce -3% | Market +8% | Investment +6% | Confidence +2 | Recruiters -15%\n" ..
            "Capitalist | Commerce -2% | Market +6% | Investment +5% | Confidence +3 | Recruiters -10%\n" ..
            "Social Democratic | Commerce +2% | Market +2% | Investment +3% | Confidence +2 | Recruiters 0%\n" ..
            "State Capitalist | Commerce +4% | Market +1% | Investment +5% | Confidence +4 | Recruiters +5%\n" ..
            "Socialist | Commerce +5% | Market -5% | Investment +1% | Confidence +1 | Recruiters +10%\n" ..
            "Communist | Commerce +7% | Market -9% | Investment -2% | Confidence +0 | Recruiters +15%\n" ..
            "Fascist | Commerce +3% | Market -2% | Investment +1% | Confidence +3 | Recruiters +10%\n" ..
            "Nationalist | Commerce +2% | Market -1% | Investment +0% | Confidence +2 | Recruiters +5%"
        )
        .SetColor("#D8C7FF");


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
        )
        .SetColor("#67D5FF");


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
        )
        .SetColor("#A9E4FF");


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
        )
        .SetColor("#FFD166");


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
    )
    .SetColor("#FFE49A");

ideologyEffectsLabel =
    UI.CreateLabel(area).SetColor("#C792EA");

ideologyEffectsLabel.SetText(
    GetIdeologyEffectsText(
        selectedIdeology
    )
);

UI.CreateLabel(area).SetText("LIVE NUMERICAL PREVIEW").SetColor("#FFFFFF");
UI.CreateLabel(area).SetText("Tap any policy above. Percentages and their actual before -> after numbers update immediately.").SetColor("#AAAAAA");
policyPreviewLabels={
    commerce=UI.CreateLabel(area),
    market=UI.CreateLabel(area),
    investment=UI.CreateLabel(area),
    recruiter=UI.CreateLabel(area),
    confidence=UI.CreateLabel(area),
    strategy=UI.CreateLabel(area).SetColor("#8FD694"),
    company=UI.CreateLabel(area).SetColor("#8FD694")
};
UpdateSelections();

UI.CreateLabel(area)
    .SetText("WHAT CONFIDENCE & UNREST ACTUALLY DO")
    .SetColor("#FFD166");
UI.CreateLabel(area)
    .SetText(
        "Company Confidence directly changes flagship stock-price movement each turn around a neutral 50 baseline: " ..
        "40 = -0.6 percentage points | 50 = 0.0 | 60 = +0.6 | 75 = +1.5 | 100 = +3.0. " ..
        "The confidence component is capped at -3.0 to +3.0 percentage points per turn."
    )
    .SetColor("#79D279");
UI.CreateLabel(area)
    .SetText(
        "Unrest penalties: 0-19 = no penalty | 20-39 = Commerce -3%, Recruiters -5% | " ..
        "40-59 = Commerce -7%, Recruiters -10% | 60-79 = Commerce -12%, Recruiters -20% | " ..
        "80-100 = Commerce -20%, Recruiters -35%. Overview always shows your current Unrest and exact active penalties."
    )
    .SetColor("#FFB366");
UI.CreateLabel(area)
    .SetText(
        "Ideology Recruiter tradeoff: Free Market -15% | Capitalist -10% | Social Democratic 0% | " ..
        "State Capitalist +5% | Socialist +10% | Communist +15% | Fascist +10% | Nationalist +5%. " ..
        "The live result also includes Readiness, Unrest, and Faction exercise bonuses."
    )
    .SetColor("#D8C7FF");

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
        )
        .SetColor("#79D279");


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
        )
        .SetColor("#8FD694");


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
        )
        .SetColor("#B9F6CA");


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
-- =========================================================
-- UNITED FRONTIER V4 UI OVERRIDES
-- Concise player-facing screens for infrastructure, intelligence,
-- missile command/defense, factions, and AI Manager.
-- =========================================================

UFV4MissileSilo = UFV4MissileSilo or nil;
UFV4MissileBuyQty = UFV4MissileBuyQty or {Conventional=1,EMP=1,Nuclear=1,Interceptor=1};
UFV4MissileLaunchQty = UFV4MissileLaunchQty or {Conventional=1,EMP=1,Nuclear=1};

local function UFV4ClampInt(v,lo,hi)
    return math.max(lo,math.min(hi,math.floor(tonumber(v) or lo)));
end

local function UFV4AssetHP(state,kind,tid,level)
    local maxHP=math.max(10,math.max(1,math.floor(tonumber(level) or 1))*10);
    local c=(state.assetCondition or {})[tostring(kind)..":"..tostring(tid)] or {};
    local missing=tonumber(c.damageHP);
    if missing==nil then missing=math.floor(maxHP*math.max(0,math.min(100,tonumber(c.damage) or 0))/100+0.5); end
    return math.max(0,maxHP-math.max(0,missing)),maxHP,c;
end

local function UFV4StructureName(kind)
    local n={Airbase="Airbase",ForwardAirstrip="Forward Airstrip",MissileSilo="Missile Command",PowerGrid="Power Grid",CyberFacility="Intelligence Agency"};
    return n[kind] or tostring(kind);
end

local function UFV4MaxLevel(kind)
    local m={
        Airbase=GetClientSetting("AirbaseMaxLevel",4),
        ForwardAirstrip=GetClientSetting("ForwardAirstripMaxLevel",3),
        MissileSilo=GetClientSetting("MissileSiloMaxLevel",4),
        PowerGrid=GetClientSetting("PowerGridMaxLevel",4),
        CyberFacility=GetClientSetting("CyberFacilityMaxLevel",4)
    };
    return math.max(1,math.floor(tonumber(m[kind]) or 1));
end

local function UFV4BaseCost(kind)
    local c={
        Airbase=GetClientSetting("AirbaseBaseCost",350),
        ForwardAirstrip=GetClientSetting("ForwardAirstripBaseCost",175),
        MissileSilo=GetClientSetting("MissileSiloBaseCost",500),
        PowerGrid=GetClientSetting("PowerGridBaseCost",300),
        CyberFacility=GetClientSetting("CyberFacilityBaseCost",450)
    };
    return math.max(0,math.floor(tonumber(c[kind]) or 0));
end

local function UFV4ResourceCostText(kind)
    if kind=="Airbase" then return " + "..tostring(GetClientSetting("AirbaseOilPerLevel",1)).." Oil + "..tostring(GetClientSetting("AirbaseIronPerLevel",1)).." Iron"; end
    if kind=="ForwardAirstrip" then return " + "..tostring(GetClientSetting("ForwardAirstripOilPerLevel",1)).." Oil"; end
    if kind=="MissileSilo" then return " + 1 Uranium"; end
    return "";
end

local function UFV4PlayerButtons(area,game,title,onPick)
    UI.CreateLabel(area).SetText(title).SetColor("#9CCBFF");
    local economy=((Mod.PublicGameData or {}).globalEconomy or {}); local ourID=GetLocalPlayerID(game); local shown=0;
    local ids={}; for pid,n in pairs(economy.nations or {}) do if pid~=ourID and n and n.eliminated~=true then table.insert(ids,pid); end end
    table.sort(ids,function(a,b) return tostring(GetPlayerName(game,a))<tostring(GetPlayerName(game,b)); end);
    local row=nil;
    for i,pid in ipairs(ids) do
        if (i-1)%3==0 then row=UI.CreateHorizontalLayoutGroup(area); end
        local captured=pid;
        UI.CreateButton(row)
            .SetText(GetPlayerName(game,pid))
            .SetTextColor(GetPlayerUIColor(game,pid,"#FFFFFF"))
            .SetFlexibleWidth(1)
            .SetPreferredHeight(38)
            .SetOnClick(function() onPick(captured); end);
        shown=shown+1;
    end
    if shown==0 then UI.CreateLabel(area).SetText("No eligible nations.").SetColor("#888888"); end
end

function ShowIntelligenceTargetMenu(parent,game,mode)
    local area=CreateContentArea(parent); local state=UFPrivateMilitaryState();
    local title=(mode=="Financial" and "FINANCIAL ESPIONAGE") or (mode=="Cyber" and "CYBER OPERATION") or "INTELLIGENCE OPERATION";
    local cost=(mode=="Financial" and 100) or (mode=="Cyber" and 100) or 75;
    UI.CreateLabel(area).SetText(title).SetColor(mode=="Cyber" and "#C792EA" or "#62B6FF");
    UI.CreateLabel(area).SetText("Cost: "..tostring(cost).." Commerce | One use of this operation type per turn").SetColor("#FFD166");
    if mode=="Financial" then UI.CreateLabel(area).SetText("Lv.3 Intelligence only. Success steals up to 10% of target reserves (max 250); a bad failure can backfire.").SetColor("#BBBBBB");
    elseif mode=="Cyber" then UI.CreateLabel(area).SetText("Attempts to disable an eligible Grid, Airbase, Missile Command, or Intelligence Agency. Lv.2 is stronger.").SetColor("#BBBBBB");
    else UI.CreateLabel(area).SetText("Recon improves with Intelligence Lv.1–3. Lv.2 reveals hidden infrastructure/resources; Lv.3 adds exact missile intelligence.").SetColor("#BBBBBB"); end
    UFV4PlayerButtons(area,game,"SELECT TARGET NATION",function(pid)
        local typ=(mode=="Financial" and "launchFinancialEspionage") or (mode=="Cyber" and "launchAgencyCyberOperation") or "launchIntelligenceOperation";
        SafeSendGameCustomMessage(game,"Launching operation...",{type=typ,targetPlayerID=pid,targetKind="Auto"},function(r)
            if r and r.message then UI.Alert(r.message); end; ShowIntelligenceAgencyMenu(parent,game);
        end);
    end);
    UI.CreateButton(area).SetText("BACK TO INTELLIGENCE AGENCY").SetOnClick(function() ShowIntelligenceAgencyMenu(parent,game); end);
end

function ShowStrategicReportsMenuLegacy(parent,game,focus)
    local area=CreateContentArea(parent); local state=UFPrivateMilitaryState(); local turn=tonumber((((Mod.PublicGameData or {}).globalEconomy or {}).currentEconomyTurn)) or 0;
    UI.CreateLabel(area).SetText("STRATEGIC REPORTS").SetColor("#FFD166");
    UI.CreateLabel(area).SetText("Latest intelligence, counterintelligence, and missile results in one place.").SetColor("#BBBBBB");

    UI.CreateLabel(area).SetText("INTELLIGENCE REPORTS").SetColor("#62B6FF"); local ir=state.intelligenceReports or {};
    if #ir==0 then UI.CreateLabel(area).SetText("No intelligence reports yet.").SetColor("#777777"); end
    for i=#ir,math.max(1,#ir-7),-1 do local r=ir[i]; if r then
        local color=(r.result=="SUCCESS" and "#79D279") or ((r.result=="FAILED" or r.result=="BLOCKED" or r.result=="BACKFIRED") and "#FF7B7B") or "#FFD166";
        UI.CreateLabel(area).SetText("Turn "..tostring(r.turn or "?").." | "..tostring(r.title or "Report").." | "..tostring(r.result or "").." | expires T"..tostring(r.expiresTurn or "?")).SetColor(color);
        UI.CreateLabel(area).SetText(tostring(r.detail or "")).SetColor("#BBBBBB");
        if r.result=="SUCCESS" and r.incoming~=true and r.shared~=true then local rid=tostring(r.id or ""); UI.CreateButton(area).SetText("SHARE WITH FACTION").SetOnClick(function()
            SafeSendGameCustomMessage(game,"Sharing intelligence...",{type="shareIntelReport",reportID=rid},function(x) if x and x.message then UI.Alert(x.message); end; ShowStrategicReportsMenu(parent,game,focus); end);
        end); end
    end end

    UI.CreateLabel(area).SetText("MISSILE / STRATEGIC REPORTS").SetColor("#FF9B71"); local mr=state.hqRecentResults or {};
    if #mr==0 then UI.CreateLabel(area).SetText("No missile reports yet.").SetColor("#777777"); end
    for i=#mr,math.max(1,#mr-7),-1 do local r=mr[i]; if r then
        UI.CreateLabel(area).SetText("Turn "..tostring(r.turn or "?").." | "..tostring(r.action or "Strategic Event").." | "..tostring(r.result or "")).SetColor("#FFB366");
        UI.CreateLabel(area).SetText(tostring(r.detail or "")).SetColor("#BBBBBB");
    end end
    local w=state.strategicWarnings or {}; if #w>0 then UI.CreateLabel(area).SetText("ADVANCE WARNINGS — INTELLIGENCE LV.3").SetColor("#FF6B6B"); for i=#w,math.max(1,#w-4),-1 do UI.CreateLabel(area).SetText("Turn "..tostring(w[i].turn or "?").." | "..tostring(w[i].text or "Warning")).SetColor("#FFB3B3"); end end
    UI.CreateButton(area).SetText("BACK TO MILITARY").SetOnClick(function() ShowMilitaryMenu(parent,game); end);
end

function ShowStrategicReportsMenu(parent,game,focus)
    local area=CreateContentArea(parent); local state=UFPrivateMilitaryState();
    if focus=="all" then StrategicReportFilter="ALL";
    elseif focus=="intel" or focus=="CyberFacility" then StrategicReportFilter="INTEL";
    elseif focus=="missile" or focus=="MissileSilo" then StrategicReportFilter="MISSILE";
    elseif focus=="air" then StrategicReportFilter="AIR"; end
    UI.CreateLabel(area).SetText("SECURITY & MISSION REPORTS").SetColor("#FFD166");
    UI.CreateLabel(area).SetText("Intelligence, cyber defense, missile/silo activity, air missions, and advance warnings in one readable feed.").SetColor("#BBBBBB");

    local filters={{"ALL","ALL"},{"INTEL / CYBER","INTEL"},{"MISSILES / SILOS","MISSILE"},{"AIR MISSIONS","AIR"},{"WARNINGS","WARNING"}};
    local row=nil;
    for index,item in ipairs(filters) do
        if (index-1)%2==0 then row=UI.CreateHorizontalLayoutGroup(area); end
        local label,value=item[1],item[2];
        UI.CreateButton(row).SetText((StrategicReportFilter==value and "▶ " or "")..label).SetFlexibleWidth(1).SetPreferredHeight(38).SetOnClick(function()
            StrategicReportFilter=value; ShowStrategicReportsMenu(parent,game);
        end);
    end

    local pending=0;
    for _,alert in ipairs(state.counterIntelAlerts or {}) do if tostring(alert.status or "")=="PENDING" then pending=pending+1; end end
    UI.CreateLabel(area).SetText("Pending counterintelligence decisions: "..tostring(pending)).SetColor(pending>0 and "#FF7B7B" or "#8FD694");
    local events={}; local sequence=0;
    local function add(category,turn,title,result,detail,color,report)
        sequence=sequence+1; table.insert(events,{category=category,turn=tonumber(turn) or 0,title=tostring(title or "Report"),result=tostring(result or "REPORT"),detail=tostring(detail or ""),color=color,sequence=sequence,report=report});
    end
    for _,report in ipairs(state.intelligenceReports or {}) do
        local color=(report.result=="SUCCESS" and "#79D279") or ((report.result=="FAILED" or report.result=="BLOCKED" or report.result=="BACKFIRED") and "#FF7B7B") or "#FFD166";
        add("INTEL",report.turn,report.title,report.result,report.detail,color,report);
    end
    for _,report in ipairs(state.hqRecentResults or {}) do add("MISSILE",report.turn,report.action or "Strategic Event",report.result,report.detail,"#FF9B71",report); end
    for _,report in ipairs(state.airWingReports or {}) do add("AIR",report.turn,report.mission or "Air Mission",report.result,(report.target and ("Target: "..tostring(report.target).." | ") or "")..tostring(report.detail or ""),"#82CFFF",report); end
    for _,warning in ipairs(state.strategicWarnings or {}) do add("WARNING",warning.turn,"Advance Warning","URGENT",warning.text,"#FF6B6B",warning); end
    table.sort(events,function(a,b) if a.turn==b.turn then return a.sequence>b.sequence; end; return a.turn>b.turn; end);

    local shown=0;
    for _,event in ipairs(events) do
        if (StrategicReportFilter=="ALL" or event.category==StrategicReportFilter) and shown<20 then
            UI.CreateLabel(area).SetText("TURN "..tostring(event.turn).." | "..event.category.." | "..event.title.." | "..event.result).SetColor(event.color);
            if event.detail~="" then UI.CreateLabel(area).SetText(event.detail).SetColor("#BBBBBB"); end
            local report=event.report;
            if event.category=="INTEL" and report and report.result=="SUCCESS" and report.incoming~=true and report.shared~=true then
                local rid=tostring(report.id or ""); UI.CreateButton(area).SetText("SHARE WITH FACTION").SetOnClick(function()
                    SafeSendGameCustomMessage(game,"Sharing intelligence...",{type="shareIntelReport",reportID=rid},function(x) if x and x.message then UI.Alert(x.message); end; ShowStrategicReportsMenu(parent,game); end);
                end);
            end
            UI.CreateLabel(area).SetText("----------------------------------------").SetColor("#444444"); shown=shown+1;
        end
    end
    if shown==0 then UI.CreateLabel(area).SetText("No reports match this category yet.").SetColor("#888888"); end
    UI.CreateButton(area).SetText("BACK TO MILITARY").SetOnClick(function() ShowMilitaryMenu(parent,game); end);
end

function ShowIntelligenceAgencyMenu(parent,game)
    local area=CreateContentArea(parent); local state=UFPrivateMilitaryState();
    UI.CreateLabel(area).SetText("INTELLIGENCE AGENCY").SetColor("#C792EA");
    local agencyTid=nil; local facilityLevel=0; for tid,lvl in pairs(state.cyberFacilities or {}) do if (tonumber(lvl) or 0)>facilityLevel then agencyTid=tonumber(tid) or tid; facilityLevel=tonumber(lvl) or 0; end end
    if agencyTid==nil then
        UI.CreateLabel(area).SetText("No Intelligence Agency built. Only one may exist at a time.").SetColor("#FFD166");
        UI.CreateLabel(area).SetText("Build Cost: "..tostring(UFV4BaseCost("CyberFacility")).." Commerce | requires operational Power Grid").SetColor("#BBBBBB");
        UI.CreateButton(area).SetText("SELECT TERRITORY TO BUILD").SetOnClick(function() UFShowTerritorySelector(parent,game,"Building Intelligence Agency...",{type="buildStrategicMilitary",kind="CyberFacility"}); end);
        UI.CreateButton(area).SetText("BACK TO MILITARY").SetOnClick(function() ShowMilitaryMenu(parent,game); end); return;
    end
    local td=game.Map and game.Map.Territories and game.Map.Territories[agencyTid] or nil; local hp,maxHP=UFV4AssetHP(state,"CyberFacility",agencyTid,facilityLevel);
    UI.CreateLabel(area).SetText("Agency: "..(td and td.Name or tostring(agencyTid)).." | Facility Lv."..tostring(facilityLevel).." | "..tostring(hp).."/"..tostring(maxHP).." HP").SetColor("#E0B3FF");
    local row=UI.CreateHorizontalLayoutGroup(area);
    if facilityLevel<UFV4MaxLevel("CyberFacility") then local nextL=facilityLevel+1; local c=UFV4BaseCost("CyberFacility")*nextL; UI.CreateButton(row).SetText("UPGRADE FACILITY L"..tostring(nextL).." — "..tostring(c)).SetOnClick(function() SafeSendGameCustomMessage(game,"Upgrading Intelligence Agency...",{type="buildStrategicMilitary",kind="CyberFacility",territoryID=agencyTid},function(r) if r and r.message then UI.Alert(r.message); end; ShowIntelligenceAgencyMenu(parent,game); end); end); else UI.CreateLabel(row).SetText("FACILITY MAX").SetColor("#79D279"); end
    if hp<maxHP then UI.CreateButton(row).SetText("REPAIR TO "..tostring(maxHP).."/"..tostring(maxHP)).SetOnClick(function() SafeSendGameCustomMessage(game,"Repairing Intelligence Agency...",{type="repairMilitaryAsset",kind="CyberFacility",territoryID=agencyTid},function(r) if r and r.message then UI.Alert(r.message); end; ShowIntelligenceAgencyMenu(parent,game); end); end); end

    local function branch(name,field,maxL,base,color)
        local cur=math.max(0,math.floor(tonumber(state[field]) or 0)); local g=UI.CreateHorizontalLayoutGroup(area); UI.CreateLabel(g).SetText(name.." | Lv."..tostring(cur).."/"..tostring(maxL)..(cur>=maxL and " MAX" or "")).SetColor(color).SetFlexibleWidth(1);
        if cur<maxL then local n=cur+1; local cost=base*n; UI.CreateButton(g).SetText("UPGRADE L"..tostring(n).." — "..tostring(cost)).SetOnClick(function() SafeSendGameCustomMessage(game,"Upgrading "..name.."...",{type="upgradeAgencyCapability",branch=name},function(r) if r and r.message then UI.Alert(r.message); end; ShowIntelligenceAgencyMenu(parent,game); end); end); end
    end
    branch("Intelligence","intelligenceOperationsLevel",3,300,"#62B6FF");
    branch("Cyber","cyberOperationsLevel",2,350,"#C792EA");
    branch("Counterintelligence","counterIntelligenceLevel",2,250,"#79D279");

    local intel=math.floor(tonumber(state.intelligenceOperationsLevel) or 0); local cyber=math.floor(tonumber(state.cyberOperationsLevel) or 0); local counter=math.floor(tonumber(state.counterIntelligenceLevel) or 0);
    UI.CreateLabel(area).SetText("OPERATIONS").SetColor("#FFFFFF");
    if intel>=1 then UI.CreateButton(area).SetText("RUN INTELLIGENCE OPERATION — 75").SetOnClick(function() ShowIntelligenceTargetMenu(parent,game,"Intelligence"); end); end
    if intel>=3 then UI.CreateButton(area).SetText("FINANCIAL ESPIONAGE — 100").SetOnClick(function() ShowIntelligenceTargetMenu(parent,game,"Financial"); end); end
    if cyber>=1 then UI.CreateButton(area).SetText("LAUNCH CYBER OPERATION — 100").SetOnClick(function() ShowIntelligenceTargetMenu(parent,game,"Cyber"); end); end

    UI.CreateLabel(area).SetText("COUNTERINTELLIGENCE ALERTS").SetColor("#FFD166"); local pending=0;
    for _,a in ipairs(state.counterIntelAlerts or {}) do if tostring(a.status or "") == "PENDING" then pending=pending+1; local opid=tonumber(a.opID); UI.CreateLabel(area).SetText("Turn "..tostring(a.turn or "?").." | Suspicious "..tostring(a.kind or "foreign").." operation | Attacker: UNKNOWN").SetColor("#FFB366"); local rr=UI.CreateHorizontalLayoutGroup(area);
        if counter>=1 then UI.CreateButton(rr).SetText("COUNTER — 75").SetOnClick(function() SafeSendGameCustomMessage(game,"Countering operation...",{type="counterIntelResponse",opID=opid,action="Counter"},function(r) if r and r.message then UI.Alert(r.message); end; ShowIntelligenceAgencyMenu(parent,game); end); end); end
        if counter>=2 then UI.CreateButton(rr).SetText("TRACE — 50").SetOnClick(function() SafeSendGameCustomMessage(game,"Tracing operation...",{type="counterIntelResponse",opID=opid,action="Trace"},function(r) if r and r.message then UI.Alert(r.message); end; ShowIntelligenceAgencyMenu(parent,game); end); end); end
        UI.CreateButton(rr).SetText("IGNORE").SetOnClick(function() SafeSendGameCustomMessage(game,"Resolving operation...",{type="counterIntelResponse",opID=opid,action="Ignore"},function(r) if r and r.message then UI.Alert(r.message); end; ShowIntelligenceAgencyMenu(parent,game); end); end);
    end end
    if pending==0 then UI.CreateLabel(area).SetText("No detected foreign operations.").SetColor("#888888"); end
    UI.CreateButton(area).SetText("VIEW ALL REPORTS").SetOnClick(function() ShowStrategicReportsMenu(parent,game,"intel"); end);
    UI.CreateButton(area).SetText("BACK TO MILITARY").SetOnClick(function() ShowMilitaryMenu(parent,game); end);
end

function ShowMissileCommandMenu(parent,game)
    local area=CreateContentArea(parent); local state=UFPrivateMilitaryState(); local silos=state.missileSilos or {};
    UI.CreateLabel(area).SetText("MISSILE COMMAND & DEFENSE").SetColor("#FF7B7B");
    UI.CreateLabel(area).SetText("Stockpile missiles, launch salvos, and maintain interceptors. Each incoming missile resolves separately.").SetColor("#BBBBBB");
    local list={}; for tid,lvl in pairs(silos) do if (tonumber(lvl) or 0)>0 then table.insert(list,{tid=tonumber(tid) or tid,lvl=tonumber(lvl) or 1}); end end; table.sort(list,function(a,b) return tostring(a.tid)<tostring(b.tid); end);
    if #list==0 then UI.CreateLabel(area).SetText("No Missile Command site built.").SetColor("#FFD166"); UI.CreateButton(area).SetText("BACK TO MILITARY").SetOnClick(function() ShowMilitaryMenu(parent,game); end); return; end
    if UFV4MissileSilo==nil or (tonumber(silos[UFV4MissileSilo]) or 0)<=0 then UFV4MissileSilo=list[1].tid; end
    UI.CreateLabel(area).SetText("SELECT COMMAND SITE").SetColor("#FFD166"); local srow=UI.CreateHorizontalLayoutGroup(area);
    for _,s in ipairs(list) do local c=s.tid; local td=game.Map and game.Map.Territories and game.Map.Territories[c] or nil; UI.CreateButton(srow).SetText((c==UFV4MissileSilo and "▶ " or "")..(td and td.Name or tostring(c)).." L"..tostring(s.lvl)).SetOnClick(function() UFV4MissileSilo=c; ShowMissileCommandMenu(parent,game); end); end
    local inv=((state.missileInventory or {})[UFV4MissileSilo]) or {Conventional=0,EMP=0,Nuclear=0}; local interceptors=math.max(0,math.floor(tonumber(state.interceptorInventory) or 0));
    UI.CreateLabel(area).SetText("STOCKPILE | Conventional "..tostring(inv.Conventional or 0).." | EMP "..tostring(inv.EMP or 0).." | Nuclear "..tostring(inv.Nuclear or 0).." | Interceptors "..tostring(interceptors)).SetColor("#9CCBFF");

    local costs={Conventional=100,EMP=175,Nuclear=300,Interceptor=GetClientSetting("MissileInterceptorCost",125)};
    local function qtyRow(weapon)
        local row=UI.CreateHorizontalLayoutGroup(area); local label=UI.CreateLabel(row).SetText(weapon.." x"..tostring(UFV4MissileBuyQty[weapon] or 1)).SetFlexibleWidth(1);
        UI.CreateButton(row).SetText("−").SetOnClick(function() UFV4MissileBuyQty[weapon]=UFV4ClampInt((UFV4MissileBuyQty[weapon] or 1)-1,1,50); ShowMissileCommandMenu(parent,game); end);
        UI.CreateButton(row).SetText("+").SetOnClick(function() UFV4MissileBuyQty[weapon]=UFV4ClampInt((UFV4MissileBuyQty[weapon] or 1)+1,1,50); ShowMissileCommandMenu(parent,game); end);
        local q=UFV4MissileBuyQty[weapon] or 1; local extra=weapon=="Nuclear" and (" + "..tostring(q).." Uranium") or "";
        UI.CreateButton(row).SetText("BUY — "..tostring((tonumber(costs[weapon]) or 0)*q)..extra).SetOnClick(function() SafeSendGameCustomMessage(game,"Purchasing missiles...",{type="resupplyMissile",siloTerritoryID=UFV4MissileSilo,weapon=weapon,quantity=q},function(r) if r and r.message then UI.Alert(r.message); end; ShowMissileCommandMenu(parent,game); end); end);
    end
    UI.CreateLabel(area).SetText("RESUPPLY").SetColor("#79D279"); qtyRow("Conventional"); qtyRow("EMP"); qtyRow("Nuclear"); qtyRow("Interceptor");

    local launchWeapon="Conventional";
    UI.CreateLabel(area).SetText("LAUNCH SALVO").SetColor("#FF8A80");
    local function launchRow(weapon,available,yield)
        local row=UI.CreateHorizontalLayoutGroup(area); local q=UFV4ClampInt(UFV4MissileLaunchQty[weapon] or 1,1,math.max(1,available)); UFV4MissileLaunchQty[weapon]=q;
        UI.CreateLabel(row).SetText(weapon.." | available "..tostring(available).." | launch "..tostring(q)).SetFlexibleWidth(1);
        UI.CreateButton(row).SetText("−").SetOnClick(function() UFV4MissileLaunchQty[weapon]=UFV4ClampInt(q-1,1,math.max(1,available)); ShowMissileCommandMenu(parent,game); end);
        UI.CreateButton(row).SetText("+").SetOnClick(function() UFV4MissileLaunchQty[weapon]=UFV4ClampInt(q+1,1,math.max(1,available)); ShowMissileCommandMenu(parent,game); end);
        UI.CreateButton(row).SetText("TARGET").SetInteractable(available>0).SetOnClick(function() UFShowTerritorySelector(parent,game,"Scheduling missile salvo...",{type="launchMissile",siloTerritoryID=UFV4MissileSilo,weapon=weapon,quantity=q,yield=yield or "Low"}); end);
    end
    launchRow("Conventional",tonumber(inv.Conventional) or 0,"Low"); launchRow("EMP",tonumber(inv.EMP) or 0,"Low");
    UI.CreateLabel(area).SetText("NUCLEAR YIELD: choose before targeting").SetColor("#FF6B6B");
    local ny=UFV4NuclearYield or "Low"; local yr=UI.CreateHorizontalLayoutGroup(area); for _,y in ipairs({"Low","Medium","High"}) do local cy=y; UI.CreateButton(yr).SetText((ny==y and "▶ " or "")..string.upper(y)).SetOnClick(function() UFV4NuclearYield=cy; ShowMissileCommandMenu(parent,game); end); end
    launchRow("Nuclear",tonumber(inv.Nuclear) or 0,UFV4NuclearYield or "Low");

    local cc=GetClientSetting("MissileDefenseConventionalChance",70); local ec=GetClientSetting("MissileDefenseEMPChance",55); local nc=GetClientSetting("MissileDefenseNuclearChance",40);
    UI.CreateLabel(area).SetText("MISSILE DEFENSE | Interceptors "..tostring(interceptors).." | C "..tostring(cc).."% | EMP "..tostring(ec).."% | Nuclear "..tostring(nc).."%").SetColor("#79D279");
    UI.CreateLabel(area).SetText("One interceptor is consumed for each incoming interception attempt.").SetColor("#BBBBBB");
    UI.CreateButton(area).SetText("REPORTS / WARNINGS").SetOnClick(function() ShowStrategicReportsMenu(parent,game,"missile"); end);
    UI.CreateButton(area).SetText("BACK TO MILITARY").SetOnClick(function() ShowMilitaryMenu(parent,game); end);
end

function ShowMilitaryMenu(parent,game)
    local area=CreateContentArea(parent); local state=UFPrivateMilitaryState(); local intel=(Mod.PlayerGameData or {}).strategicIntel or {};
    UI.CreateLabel(area).SetText("MILITARY").SetColor("#8FBF6F");
    local quickActions = {
        {"RECRUITMENT", function() ShowArmyRecruitersMenu(parent,game); end},
        {"INTELLIGENCE", function() ShowIntelligenceAgencyMenu(parent,game); end, GetClientSetting("CyberFacilitiesEnabled",true)},
        {"MISSILES", function() ShowMissileCommandMenu(parent,game); end, GetClientSetting("MissileSilosEnabled",true)},
        {"REPORTS", function() ShowStrategicReportsMenu(parent,game); end}
    };
    local quick=nil; local quickIndex=0;
    for _,entry in ipairs(quickActions) do
        if entry[3]~=false then
            if quickIndex%2==0 then quick=UI.CreateHorizontalLayoutGroup(area); end
            quickIndex=quickIndex+1;
            UI.CreateButton(quick).SetText(entry[1]).SetFlexibleWidth(1).SetPreferredHeight(42).SetOnClick(entry[2]);
        end
    end

    UI.CreateLabel(area).SetText("MILITARY INFRASTRUCTURE").SetColor("#8FBF6F");
    UI.CreateLabel(area).SetText("Power Grids and Intelligence Agencies are private. Foreign details appear only when legitimately discovered.").SetColor("#BBBBBB");
    local filterRow=nil; local filters={{"My Infrastructure","MY ASSETS"},{"Neighbors","NEIGHBORS"},{"Shared Intel","ALLY / FACTION"},{"All Known","ALL KNOWN"}};
    for index,fd in ipairs(filters) do
        if (index-1)%2==0 then filterRow=UI.CreateHorizontalLayoutGroup(area); end
        local key,label=fd[1],fd[2];
        UI.CreateButton(filterRow).SetText((MilitaryIntelFilter==key and "▶ " or "")..label).SetFlexibleWidth(1).SetPreferredHeight(40).SetOnClick(function() MilitaryIntelFilter=key; ShowMilitaryMenu(parent,game); end);
    end

    local function addOwn(kind,tid,lvl)
        local td=game.Map and game.Map.Territories and game.Map.Territories[tid] or nil; local hp,maxHP=UFV4AssetHP(state,kind,tid,lvl); local row=UI.CreateHorizontalLayoutGroup(area); local name=UFV4StructureName(kind);
        UI.CreateLabel(row).SetText((td and td.Name or tostring(tid)).." | "..name.." Lv."..tostring(lvl).." | "..tostring(hp).."/"..tostring(maxHP).." HP").SetColor(kind=="PowerGrid" and "#FFE066" or (kind=="CyberFacility" and "#D7A6FF" or "#8FD694")).SetFlexibleWidth(1);
        local captured=tid; UI.CreateButton(row).SetText("SHOW").SetOnClick(function() if UFMenuClose then UFMenuClose(); end; game.HighlightTerritories({captured}); game.CreateDialog(function(r,sm,ss,g,c) sm(330,130); ss(false); UI.CreateLabel(r).SetText(name.." location highlighted."); UI.CreateButton(r).SetText("← BACK").SetOnClick(function() c(); g.CreateDialog(function(rr,smm,sss,gg,cc) smm(900,760); sss(true); local old=UFMenuClose; UFMenuClose=cc; ShowMilitaryMenu(rr,gg); UFMenuClose=old; end); end); end); end);
        local maxL=UFV4MaxLevel(kind); if (tonumber(lvl) or 0)<maxL then local nl=(tonumber(lvl) or 0)+1; local cost=UFV4BaseCost(kind)*nl; UI.CreateButton(row).SetText("UPGRADE L"..tostring(nl).." — "..tostring(cost)..UFV4ResourceCostText(kind)).SetOnClick(function() SafeSendGameCustomMessage(game,"Upgrading "..name.."...",{type="buildStrategicMilitary",kind=kind,territoryID=captured},function(r) if r and r.message then UI.Alert(r.message); end; ShowMilitaryMenu(parent,game); end); end); else UI.CreateLabel(row).SetText("MAX").SetColor("#79D279"); end
        if hp<maxHP then UI.CreateButton(row).SetText("REPAIR").SetOnClick(function() SafeSendGameCustomMessage(game,"Repairing "..name.."...",{type="repairMilitaryAsset",kind=kind,territoryID=captured},function(r) if r and r.message then UI.Alert(r.message); end; ShowMilitaryMenu(parent,game); end); end); end
        if kind=="CyberFacility" or kind=="MissileSilo" then UI.CreateButton(row).SetText("REPORTS").SetOnClick(function() ShowStrategicReportsMenu(parent,game,kind); end); end
    end
    if MilitaryIntelFilter=="My Infrastructure" or MilitaryIntelFilter=="All Known" then
        UI.CreateLabel(area).SetText("YOUR INFRASTRUCTURE").SetColor("#8FD694"); local shown=0;
        local maps={{"Airbase","airbases"},{"ForwardAirstrip","forwardAirstrips"},{"MissileSilo","missileSilos"},{"PowerGrid","powerGrids"},{"CyberFacility","cyberFacilities"}};
        for _,m in ipairs(maps) do for tid,lvl in pairs(state[m[2]] or {}) do if (tonumber(lvl) or 0)>0 then shown=shown+1; addOwn(m[1],tonumber(tid) or tid,tonumber(lvl) or 1); end end end
        if shown==0 then UI.CreateLabel(area).SetText("No strategic infrastructure built yet.").SetColor("#888888"); end
    end
    if MilitaryIntelFilter~="My Infrastructure" then
        UI.CreateLabel(area).SetText("KNOWN FOREIGN INFRASTRUCTURE").SetColor("#FFD166"); local shown=0;
        for _,item in pairs(intel.knownMilitary or {}) do local reason=tostring(item.reason or "Known"); local group=(reason=="Shared Intelligence" or reason=="Faction Intel" or reason=="Ally Intel") and "Shared Intel" or ((reason=="Border" or reason=="Neighboring") and "Neighbors" or "All Known"); if MilitaryIntelFilter=="All Known" or MilitaryIntelFilter==group then shown=shown+1; local td=game.Map and game.Map.Territories and game.Map.Territories[item.territoryID] or nil; UI.CreateLabel(area).SetText((td and td.Name or tostring(item.territoryID)).." | "..tostring(item.kind or "Infrastructure").." Lv."..tostring(item.level or "?").." | "..reason).SetColor("#62B6FF"); end end
        if shown==0 then UI.CreateLabel(area).SetText("No foreign infrastructure matches this filter.").SetColor("#888888"); end
    end

    UI.CreateLabel(area).SetText("BUILD & MANAGE").SetColor("#FFFFFF");
    local function build(kind,color,extra)
        local cost=UFV4BaseCost(kind); UI.CreateLabel(area).SetText(UFV4StructureName(kind).." | Lv.1 cost: "..tostring(cost).." Commerce"..UFV4ResourceCostText(kind)..(extra or "")).SetColor(color);
        UI.CreateButton(area).SetText("SELECT TERRITORY TO BUILD / UPGRADE").SetOnClick(function() UFShowTerritorySelector(parent,game,"Building / upgrading "..UFV4StructureName(kind).."...",{type="buildStrategicMilitary",kind=kind}); end);
    end
    if GetClientSetting("PowerGridEnabled",true) then build("PowerGrid","#FFE066"," | powers Airbase, Missile Command, Intelligence Agency"); end
    if GetClientSetting("AirbasesEnabled",true) then build("Airbase","#62B6FF"," | airlift endpoint"); end
    if GetClientSetting("ForwardAirstripsEnabled",true) then build("ForwardAirstrip","#82CFFF"," | airlift endpoint"); end
    if GetClientSetting("MissileSilosEnabled",true) then build("MissileSilo","#FF7B7B"," | requires operational Grid"); end
    if GetClientSetting("CyberFacilitiesEnabled",true) then
        local has=false; for _,lvl in pairs(state.cyberFacilities or {}) do if (tonumber(lvl) or 0)>0 then has=true; break; end end
        if not has then build("CyberFacility","#C792EA"," | ONE per nation | requires operational Grid"); else UI.CreateLabel(area).SetText("Intelligence Agency: already established. Upgrade it from its Agency screen or infrastructure row.").SetColor("#C792EA"); end
    end
    if GetClientSetting("AirWingsEnabled",true) then UI.CreateButton(area).SetText("PURCHASE AIR WING").SetOnClick(function() UFShowTerritorySelector(parent,game,"Purchasing Air Wing...",{type="purchaseAirWing"}); end); end
    if GetClientSetting("SpecialForcesEnabled",true) then UI.CreateButton(area).SetText("TRAIN SPECIAL FORCES").SetOnClick(function() UFShowTerritorySelector(parent,game,"Training Special Forces...",{type="purchaseSpecialForces"}); end); end
end

function ShowFactionMenu(parent,game)
    local area=CreateContentArea(parent); local economy=((Mod.PublicGameData or {}).globalEconomy or {}); local dip=economy.diplomacy or {}; local factions=dip.factions or {}; local ourID=GetLocalPlayerID(game); local ourFID=(dip.playerFaction or {})[ourID]; local our=ourFID and factions[ourFID] or nil;
    UI.CreateLabel(area).SetText("FACTIONS").SetColor("#D4AF37"); UI.CreateLabel(area).SetText("Public directory, membership, exercises, intelligence sharing, chat, and Faction wars.").SetColor("#BBBBBB");
    local alerts=((dip.factionAlerts or {})[ourID]) or {}; for i=#alerts,1,-1 do local a=alerts[i]; if a and a.seen~=true then UI.CreateLabel(area).SetText("⚠ "..tostring(a.kind or "FACTION NOTICE").." | "..tostring(a.text or "New Faction event")).SetColor("#FFB366"); local aid=tostring(a.id or ""); UI.CreateButton(area).SetText("ACKNOWLEDGE").SetOnClick(function() SafeSendGameCustomMessage(game,"Acknowledging...",{type="ackFactionAlert",alertID=aid},function(r) ShowFactionMenu(parent,game); end); end); break; end end
    UI.CreateLabel(area).SetText("FACTION DIRECTORY").SetColor("#9CCBFF"); local ids={}; for id,_ in pairs(factions) do table.insert(ids,id); end; table.sort(ids,function(a,b) return tonumber(a or 0)<tonumber(b or 0); end);
    if #ids==0 then UI.CreateLabel(area).SetText("No Factions have been created yet.").SetColor("#888888"); end
    for _,fid in ipairs(ids) do local f=factions[fid]; local count=0; local memberIDs={}; for pid,v in pairs(f.members or {}) do if v then count=count+1; table.insert(memberIDs,pid); end end; table.sort(memberIDs,function(a,b) return tostring(GetPlayerName(game,a))<tostring(GetPlayerName(game,b)); end); local leader=GetPlayerName(game,f.leaderPlayerID); local n=((economy.nations or {})[f.leaderPlayerID]) or {}; local ideology=tostring(n.ideology or "Mixed / Unknown");
        UI.CreateLabel(area).SetText(tostring(f.name or ("Faction "..tostring(fid)))).SetColor(fid==ourFID and "#79D279" or "#DDEEFF");
        UI.CreateLabel(area).SetText("Leader: "..leader.." | Members: "..tostring(count)).SetColor(GetPlayerUIColor(game,f.leaderPlayerID,"#FFFFFF"));
        UI.CreateLabel(area).SetText("Alignment: "..ideology).SetColor("#D4AF37");
        local memberRow=nil;
        for index,pid in ipairs(memberIDs) do
            if (index-1)%3==0 then memberRow=UI.CreateHorizontalLayoutGroup(area); end
            UI.CreateLabel(memberRow).SetText(GetPlayerName(game,pid)).SetColor(GetPlayerUIColor(game,pid,"#FFFFFF")).SetFlexibleWidth(1);
        end
        if our==nil then local cfid=fid; UI.CreateButton(area).SetText("REQUEST TO JOIN").SetOnClick(function() SafeSendGameCustomMessage(game,"Sending join request...",{type="requestJoinFaction",factionID=cfid},function(r) if r and r.message then UI.Alert(r.message); end; ShowFactionMenu(parent,game); end); end); end
    end
    if our==nil then
        UI.CreateLabel(area).SetText("CREATE A FACTION").SetColor("#D4AF37"); local inp=CreateWideTextInput(area).SetPlaceholderText("Faction name"); UI.CreateButton(area).SetText("CREATE").SetOnClick(function() SafeSendGameCustomMessage(game,"Creating Faction...",{type="createFaction",factionName=inp.GetText()},function(r) if r and r.message then UI.Alert(r.message); end; ShowFactionMenu(parent,game); end); end);
    else
        UI.CreateLabel(area).SetText("YOUR FACTION — "..tostring(our.name or ourFID)).SetColor("#79D279"); UI.CreateLabel(area).SetText("Leader: "..GetPlayerName(game,our.leaderPlayerID));
        UI.CreateLabel(area).SetText("MEMBERS").SetColor("#9CCBFF");
        for pid,v in pairs(our.members or {}) do if v then
            local cp=pid; local rr=UI.CreateHorizontalLayoutGroup(area); local txt=GetPlayerName(game,pid)..(pid==our.leaderPlayerID and " | LEADER" or ""); UI.CreateLabel(rr).SetText(txt).SetColor(GetPlayerUIColor(game,pid,"#FFFFFF")).SetFlexibleWidth(1);
            if our.leaderPlayerID==ourID and pid~=ourID then
                UI.CreateButton(rr).SetText("PROMOTE").SetOnClick(function() SafeSendGameCustomMessage(game,"Transferring leadership...",{type="promoteFactionLeader",targetPlayerID=cp},function(r) if r and r.message then UI.Alert(r.message); end; ShowFactionMenu(parent,game); end); end);
                UI.CreateButton(rr).SetText("REMOVE").SetOnClick(function() SafeSendGameCustomMessage(game,"Removing member...",{type="removeFactionMember",targetPlayerID=cp},function(r) if r and r.message then UI.Alert(r.message); end; ShowFactionMenu(parent,game); end); end);
            end
        end end
        if our.leaderPlayerID==ourID then
            UI.CreateLabel(area).SetText("INVITE NATION").SetColor("#9CCBFF");
            UFV4PlayerButtons(area,game,"SELECT NATION TO INVITE",function(pid)
                SafeSendGameCustomMessage(game,"Sending Faction invitation...",{type="inviteToFaction",targetPlayerID=pid},function(r) if r and r.message then UI.Alert(r.message); end; ShowFactionMenu(parent,game); end);
            end);
            UI.CreateLabel(area).SetText("JOIN REQUESTS").SetColor("#FFD166"); local jr=0; for pid,v in pairs(our.joinRequests or {}) do if v then jr=jr+1; local cp=pid; local rr=UI.CreateHorizontalLayoutGroup(area); UI.CreateLabel(rr).SetText(GetPlayerName(game,pid)).SetFlexibleWidth(1); UI.CreateButton(rr).SetText("ACCEPT").SetOnClick(function() SafeSendGameCustomMessage(game,"Accepting member...",{type="respondFactionJoinRequest",targetPlayerID=cp,accept=true},function(r) if r and r.message then UI.Alert(r.message); end; ShowFactionMenu(parent,game); end); end); UI.CreateButton(rr).SetText("DECLINE").SetOnClick(function() SafeSendGameCustomMessage(game,"Declining request...",{type="respondFactionJoinRequest",targetPlayerID=cp,accept=false},function(r) ShowFactionMenu(parent,game); end); end); end end; if jr==0 then UI.CreateLabel(area).SetText("No pending join requests.").SetColor("#888888"); end
            UI.CreateLabel(area).SetText("FACTION WAR").SetColor("#FF7B7B"); for _,tfid in ipairs(ids) do if tfid~=ourFID then local cf=tfid; local tf=factions[tfid]; UI.CreateButton(area).SetText("DECLARE WAR — "..tostring(tf.name or tfid)).SetOnClick(function() SafeSendGameCustomMessage(game,"Declaring Faction war...",{type="declareFactionWar",targetFactionID=cf,reason="Faction Conflict"},function(r) if r and r.message then UI.Alert(r.message); end; ShowFactionMenu(parent,game); end); end); end end
        end
        UI.CreateLabel(area).SetText("MILITARY EXERCISE").SetColor("#D4AF37"); local ex=our.militaryExercise or {}; local turn=tonumber(economy.currentEconomyTurn or economy.tradeTurn) or 0;
        if ex.active==true and turn<=tonumber(ex.endTurn or 0) then
            UI.CreateLabel(area).SetText("ACTIVE through Turn "..tostring(ex.endTurn).." | boosts your Recruiter output only if you contribute.").SetColor("#79D279"); local nation=(economy.nations or {})[ourID] or {}; local base=math.max(1,math.floor(tonumber(GetClientSetting("ArmyRecruiterArmiesPerTurn",4)) or 4)); local levels=math.max(0,math.floor(tonumber(nation.armyRecruiterLevels) or tonumber(nation.armyRecruiterCount) or 0)); local readiness=math.max(0,math.min(100,tonumber(nation.resourceMilitaryReadiness) or 100)); local unrest=tonumber(nation.resourceUnrest) or 0; local penalty=(unrest>=80 and 35) or (unrest>=60 and 20) or (unrest>=40 and 10) or (unrest>=20 and 5) or 0; local ideologyBonus=GetClientIdeologyRecruiterModifierPercent(nation); local normal=math.max(0,math.floor(base*levels*readiness/100*math.max(0,100+ideologyBonus-penalty)/100+0.5));
            if (ex.contributions or {})[ourID]==nil then for i=1,4 do local cost=math.max(0,math.floor(tonumber(GetClientSetting("FactionExerciseTier"..tostring(i).."Cost",({50,100,200,300})[i])) or 0)); local bonus=math.max(0,math.floor(tonumber(GetClientSetting("FactionExerciseTier"..tostring(i).."Bonus",({10,20,40,60})[i])) or 0)); local boosted=math.max(0,math.floor(base*levels*readiness/100*math.max(0,100+ideologyBonus-penalty+bonus)/100+0.5)); local cc=cost; UI.CreateButton(area).SetText(tostring(cost).." Commerce | "..tostring(normal).." → "..tostring(boosted).." troops/turn (+"..tostring(boosted-normal)..")").SetOnClick(function() SafeSendGameCustomMessage(game,"Joining exercise...",{type="contributeFactionExercise",amount=cc},function(r) if r and r.message then UI.Alert(r.message); end; ShowFactionMenu(parent,game); end); end); end else local c=(ex.contributions or {})[ourID]; UI.CreateLabel(area).SetText("Your contribution: "..tostring(c.commerce or 0).." Commerce | Recruiter bonus +"..tostring(c.bonusPercent or 0).."%").SetColor("#9CCBFF"); end
        else if our.leaderPlayerID==ourID then UI.CreateButton(area).SetText("START MILITARY EXERCISE").SetOnClick(function() SafeSendGameCustomMessage(game,"Starting exercise...",{type="startFactionExercise"},function(r) if r and r.message then UI.Alert(r.message); end; ShowFactionMenu(parent,game); end); end); end end
        UI.CreateLabel(area).SetText("FACTION CHAT").SetColor("#9CCBFF"); local chat=our.chat or {}; for i=math.max(1,#chat-5),#chat do local m=chat[i]; if m then UI.CreateLabel(area).SetText("T"..tostring(m.turn or "?").." "..GetPlayerName(game,m.playerID)..": "..tostring(m.text or "")).SetColor("#BBBBBB"); end end; local ci=CreateWideTextInput(area).SetPlaceholderText("Message faction..."); UI.CreateButton(area).SetText("SEND").SetOnClick(function() SafeSendGameCustomMessage(game,"Sending message...",{type="sendFactionChat",message=ci.GetText()},function(r) if r and r.message then UI.Alert(r.message); end; ShowFactionMenu(parent,game); end); end);
        if our.leaderPlayerID~=ourID then UI.CreateButton(area).SetText("LEAVE FACTION").SetOnClick(function() SafeSendGameCustomMessage(game,"Leaving Faction...",{type="leaveFaction"},function(r) if r and r.message then UI.Alert(r.message); end; ShowFactionMenu(parent,game); end); end); else UI.CreateButton(area).SetText("DISBAND FACTION").SetOnClick(function() SafeSendGameCustomMessage(game,"Disbanding Faction...",{type="disbandFaction"},function(r) if r and r.message then UI.Alert(r.message); end; ShowFactionMenu(parent,game); end); end); end
    end
    UI.CreateButton(area).SetText("BACK TO DIPLOMACY").SetOnClick(function() ShowDiplomacyMenu(parent,game); end);
end

function ShowAIManagerMenu(parent,game)
    local area=CreateContentArea(parent); local nation=GetOurNationState(game);
    UI.CreateLabel(area).SetText("AI MANAGER").SetColor("#62B6FF"); UI.CreateButton(area).SetText("BACK TO OVERVIEW").SetOnClick(function() ShowOverview(parent,game); end);
    if GetClientSetting("PlayerAIManagerEnabled",true)~=true then UI.CreateLabel(area).SetText("Disabled by host.").SetColor("#FF7B7B"); return; end
    if nation==nil or nation.setupComplete~=true then UI.CreateLabel(area).SetText("Complete National Setup first.").SetColor("#FFD166"); return; end
    UI.CreateLabel(area).SetText("Status: "..(nation.aiManagerEnabled==true and "ACTIVE" or "OFF")).SetColor(nation.aiManagerEnabled==true and "#79D279" or "#BBBBBB");
    UI.CreateLabel(area).SetText("Recurring budget: "..tostring(nation.aiManagerBudget or 100).." per turn").SetColor("#BBBBBB");
    UI.CreateLabel(area).SetText("One-time budget next turn: "..tostring(nation.aiManagerOneTimeBudget or 0)).SetColor("#BBBBBB");
    UI.CreateLabel(area).SetText("LAST TURN SPENDING").SetColor("#9CCBFF");
    UI.CreateLabel(area).SetText("Total: "..tostring(nation.aiManagerSpentThisTurn or 0).." | Markets: "..tostring(nation.aiManagerMarketSpentThisTurn or 0)).SetColor("#BBBBBB");
    UI.CreateLabel(area).SetText("Economy: "..tostring(nation.aiManagerInvestmentSpentThisTurn or 0).." | Resources/Military: "..tostring(nation.aiManagerMilitarySpentThisTurn or 0)).SetColor("#BBBBBB");
    local function AddBudgetPresets(input,values)
        local presetRow=nil;
        for index,v in ipairs(values) do
            if (index-1)%2==0 then presetRow=UI.CreateHorizontalLayoutGroup(area); end
            local cv=v;
            UI.CreateButton(presetRow).SetText(tostring(v)).SetFlexibleWidth(1).SetPreferredHeight(38).SetOnClick(function() input.SetText(tostring(cv)); end);
        end
    end
    UI.CreateLabel(area).SetText("RECURRING BUDGET").SetColor("#FFD166"); local bi=CreateWideTextInput(area,300).SetText(tostring(nation.aiManagerBudget or 100)); AddBudgetPresets(bi,{100,250,500,1000,2500});
    UI.CreateButton(area).SetText("UPDATE / ACTIVATE").SetOnClick(function() local b=tonumber(bi.GetText()); if not b then UI.Alert("Enter a valid budget."); return; end; SafeSendGameCustomMessage(game,"Updating AI Manager...",{type="updateAIManager",enabled=true,budget=math.max(25,math.floor(b))},function(r) if r and r.message then UI.Alert(r.message); end; ShowAIManagerMenu(parent,game); end); end);
    UI.CreateLabel(area).SetText("ONE-TIME EXTRA BUDGET").SetColor("#D7A6FF"); local oi=CreateWideTextInput(area,300).SetText(tostring(nation.aiManagerOneTimeBudget or 1000)); AddBudgetPresets(oi,{500,1000,2500,5000});
    UI.CreateButton(area).SetText("AUTHORIZE NEXT TURN").SetOnClick(function() local b=tonumber(oi.GetText()); if not b then UI.Alert("Enter a valid amount."); return; end; SafeSendGameCustomMessage(game,"Authorizing one-time AI budget...",{type="fundAIManagerOnce",amount=math.floor(b)},function(r) if r and r.message then UI.Alert(r.message); end; ShowAIManagerMenu(parent,game); end); end);
    if nation.aiManagerEnabled==true then UI.CreateButton(area).SetText("PAUSE MANAGER NEXT TURN").SetOnClick(function() SafeSendGameCustomMessage(game,"Pausing AI Manager...",{type="updateAIManager",enabled=false,budget=nation.aiManagerBudget or 100},function(r) if r and r.message then UI.Alert(r.message); end; ShowAIManagerMenu(parent,game); end); end); end
    UI.CreateLabel(area).SetText("The manager prioritizes urgent needs, economy, resources, military, then market opportunities. Full rules are in How It Works.").SetColor("#888888");
end


function ShowHowItWorks(parent)
    local area=CreateContentArea(parent);
    local function Section(title,text,color)
        UI.CreateLabel(area).SetText(title).SetColor(color or "#FFD166");
        UI.CreateLabel(area).SetText(text).SetColor("#BBBBBB");
    end
    UI.CreateLabel(area).SetText("HOW UNITED FRONTIER WORKS").SetColor("#67D5FF");
    UI.CreateLabel(area).SetText("Deep strategy, simple controls: every action shows its cost, effect, and result.").SetColor("#FFFFFF");
    Section("MARKETS — START HERE", "BUY SHARES opens the company list. Choose a flagship, open VIEW / TRADE COMPANY, choose a quantity, and review the total before buying. PORTFOLIO shows holdings and selling options. OVERVIEW ranks Growth and Dividend stocks. NEWS & ECONOMY combines acquisitions, price events, dividends, trade, investments, and global activity.", "#67D5FF");
    Section("EXAMPLE: SHARE PURCHASE", "Illustrative prices: 5 shares at 20 Commerce cost 100 before any applicable fees. If the price later reaches 24, the holding is worth 120. If it falls to 16, it is worth 80. You realize the gain or loss by selling; dividends depend on the company and game settings.", "#79D279");
    Section("MARKET RANKINGS — WHAT THE NUMBERS MEAN", "Top 5 Growth ranks the largest percentage price increases from the previous turn. Example: 20 → 24 is +20%. Top 5 Dividend ranks dividend Commerce paid per share and shows yield. Example: a 2 Commerce dividend at a 40 Commerce stock price is a 5% displayed yield. A high yield can still carry price risk.", "#79D279");
    Section("EXAMPLE: FLAGSHIP ACQUISITION", "Illustrative host settings: target market cap 3,000 × 150% premium = 4,500 Commerce purchase price. With 100 total shares, the cash-out value is 45 per share. An investor holding 20 shares receives 900 Commerce automatically. All other shareholders are paid first; the seller receives the remaining sale value plus the cash-out on shares the seller held. If the buyer flagship is 30 and the boost setting is 15%, its new displayed price is 35 after rounding (+5/share), and confidence increases by 8. That price boost is market value, not an instant cash dividend.", "#FFB347");
    Section("EXAMPLE: RESOURCE SHORTAGE", "Production 4 minus need 7 leaves a deficit of 3. A stockpile of 5 covers this turn and leaves 2. Next turn, the same deficit would leave 1 uncovered. Increase production or arrange a resource contract before the reserve runs out.", "#FFD166");
    Section("EXAMPLE: PLAYER ACTIONS", "Click a player name in Diplomacy. Their mobile overview shows relationship, Commerce/turn, policy, agreements, flagship, discovered strategic assets, and up to 3 recent missions involving that player. Private assets are never exposed unless your nation legitimately discovered them. At peace, you may propose a pact or alliance; at war, you may offer peace.", "#C792EA");
    Section("1. GETTING STARTED","Complete National Setup. Your ideology, economic strategy, taxes, and company strategy show hard numerical effects before you confirm. If setup is left incomplete through the host deadline, missing choices are assigned automatically. An unfinished target is never immune from war.","#FFD166");
    Section("2. ECONOMY, CONFIDENCE & UNREST","Commerce funds national actions. Company Confidence directly affects flagship market movement. Unrest reduces Commerce and Recruiter production in visible tiers: 20–39 = -3% Commerce / -5% Recruiters; 40–59 = -7% / -10%; 60–79 = -12% / -20%; 80–100 = -20% / -35%.","#79D279");
    Section("3. RESOURCES","Resource locations are private. You learn them through ownership, borders, faction/alliance intelligence, or successful intelligence operations. Oil and Iron are used by Airbases; Oil by Forward Airstrips; Uranium is required to develop Missile Command and to buy Nuclear missiles.","#67D5FF");
    Section("4. MILITARY INFRASTRUCTURE","Upgrading strengthens the SAME installation; it does not create another icon. Lv.1 = 10 max HP, Lv.2 = 20, Lv.3 = 30, Lv.4 = 40. Existing damage carries into an upgrade, so upgrading is not a free repair. Power Grids and Intelligence Agencies stay hidden.","#8FBF6F");
    Section("5. AIR OPERATIONS & AIRLIFT","If Airbases or Forward Airstrips are enabled, War.app Airlift Cards require an enabled airport at BOTH origin and destination. If the host disables both airport systems, normal War.app Airlift behavior is restored. AI nations follow the same routing rule.","#62B6FF");
    Section("6. INTELLIGENCE AGENCY","Each nation may operate ONE Agency. Intelligence Operations has 3 levels; Cyber Operations 2; Counterintelligence 2. Intelligence Lv.2 reveals deeper hidden infrastructure/resources and allows faction sharing. Lv.3 unlocks Financial Espionage and strategic missile warnings. Cyber disrupts eligible systems. Detected operations give the defender a same-turn COUNTER / TRACE / IGNORE choice; unanswered operations resolve when the turn advances.","#C792EA");
    Section("7. MISSILE COMMAND & DEFENSE","Missile Command stores Conventional, EMP, Nuclear, and Interceptor missiles. Use +/- controls to buy or launch several at once. Every missile in a salvo resolves separately. Nuclear purchases consume Uranium. Interceptors are consumed one per defense attempt; the host controls interception chances.","#FF7B7B");
    Section("8. DIPLOMACY & FACTIONS","Diplomacy handles nation-to-nation wars, peace, NAPs, alliances, and trade. Factions have a public directory, leader/member management, join requests, chat, shared intelligence, Military Exercises, and Faction wars. A Faction leader may declare war on another Faction; all members are notified and member wars propagate automatically.","#D4AF37");
    Section("9. FACTION MILITARY EXERCISES","The Faction leader starts the exercise. Each member chooses a host-configured Commerce tier. The button shows hard troop numbers such as 10 → 14 troops/turn. The bonus applies only during the exercise; then a cooldown begins.","#D4AF37");
    Section("10. UNITED NATIONS","Security Council resolutions include sanctions, embargoes, aid, condemnation, and ceasefires. Aid uses an adjustable Commerce amount within host limits instead of a hidden fixed value. Resolution effects and durations are shown before submission.","#90CAF9");
    Section("11. SECURITY REPORTS","Overview shows a quick private briefing: pending counterintelligence decisions, total stored reports, and the latest 4 results. OPEN ALL SECURITY REPORTS provides filters for Intel/Cyber, Missiles/Silos, Air Missions, and Warnings. Every entry shows turn, type, result, and the actual effect—for example Commerce stolen, infrastructure disrupted, missile result, interception, or air-mission outcome.","#FFFFFF");
    Section("12. AI MANAGER","Human players may authorize a recurring budget plus a one-time extra budget. The manager prioritizes urgent shortages, economy, resources/military, then market opportunities. AI nations use the same infrastructure/resource/airlift rules and use active countermeasures when they detect foreign operations.","#62B6FF");
end
