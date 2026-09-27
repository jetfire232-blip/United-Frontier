-- =========================================================
-- GLOBAL ECONOMY, TRADE, INVESTMENTS & DIPLOMACY
-- SERVER ADVANCE TURN
--
-- Handles:
-- 1. Dynamic trade income bonuses
-- 2. Strategic AI trade proposals
-- 3. Stable AI trade relationships
-- 4. Economic decline tracking
-- 5. AI partner replacement
-- 6. Trade cooldowns
-- 7. AI project creation
-- 8. AI investment decisions
-- 9. Investment funding deadlines
-- 10. Investment success/failure
-- 11. Investment payouts/refunds
-- 12. Permanent ended-project records
-- 13. Delayed war declarations
-- 14. Peace / war relationship processing
-- 15. Non-Aggression Pact expiration
-- 16. Diplomacy cleanup
-- 17. Strategic AI diplomacy
-- =========================================================


-- =========================================================
-- DEFAULT SETTINGS
-- =========================================================

local DEFAULT_MAX_AGREEMENTS = 3;
local DEFAULT_TRADE_BONUS_PERCENT = 10;
local DEFAULT_COOLDOWN_TURNS = 3;
local DEFAULT_AI_PROPOSAL_CHANCE = 35;

local DEFAULT_AI_MIN_AGREEMENT_TURNS = 3;
local DEFAULT_AI_REPLACEMENT_PERCENT = 50;
local DEFAULT_DECLINE_TURNS = 3;

local DEFAULT_AI_INVESTMENT_RESERVE_PERCENT = 40;
local DEFAULT_AI_PROJECT_CHANCE = 15;
local DEFAULT_AI_INVEST_CHANCE = 30;


-- =========================================================
-- DIPLOMACY DEFAULTS
-- =========================================================

local DEFAULT_WAR_DECLARATION_DELAY = 1;
local DEFAULT_PEACE_COOLDOWN_TURNS = 3;

local DEFAULT_NAP_DURATION_TURNS = 3;

local DEFAULT_AI_WAR_CHANCE = 8;
local DEFAULT_AI_PEACE_CHANCE = 20;
local DEFAULT_AI_NAP_CHANCE = 8;

local DEFAULT_AI_MIN_WAR_TURNS = 3;

local MAX_DIPLOMACY_HISTORY = 150;


-- =========================================================
-- HISTORY / INVESTMENT LIMITS
-- =========================================================

local MAX_TRADE_HISTORY = 75;
local MAX_INVESTMENT_HISTORY = 100;
local MAX_ARCHIVED_PROJECTS = 100;

local FUNDING_WINDOW_TURNS = 3;

local CREATOR_MIN_PERCENT = 20;
local OUTSIDE_INVESTOR_MAX_PERCENT = 25;

local MIN_INVESTORS = 2;
local MAX_INVESTORS = 6;


-- =========================================================
-- INVESTMENT PROJECT DEFINITIONS
-- =========================================================

local INVESTMENT_TYPES = {

    port = {
        id = "port",
        name = "Port Expansion",
        maxGoal = 1200,
        duration = 3,
        successReturn = 15,
        failureRecovery = 90,
        successChance = 90,
        risk = "Low"
    },

    commercial = {
        id = "commercial",
        name = "Commercial District",
        maxGoal = 1500,
        duration = 4,
        successReturn = 22,
        failureRecovery = 80,
        successChance = 82,
        risk = "Low-Medium"
    },

    infrastructure = {
        id = "infrastructure",
        name = "Infrastructure Corridor",
        maxGoal = 1800,
        duration = 5,
        successReturn = 28,
        failureRecovery = 80,
        successChance = 78,
        risk = "Medium"
    },

    industrial = {
        id = "industrial",
        name = "Industrial Development",
        maxGoal = 2000,
        duration = 5,
        successReturn = 35,
        failureRecovery = 70,
        successChance = 72,
        risk = "Medium"
    },

    resource = {
        id = "resource",
        name = "Resource Development",
        maxGoal = 2400,
        duration = 4,
        successReturn = 45,
        failureRecovery = 55,
        successChance = 65,
        risk = "Medium-High"
    },

    technology = {
        id = "technology",
        name = "Technology Venture",
        maxGoal = 3000,
        duration = 6,
        successReturn = 70,
        failureRecovery = 35,
        successChance = 55,
        risk = "High"
    },

    space = {
        id = "space",
        name = "Space Exploration",
        maxGoal = 4000,
        duration = 8,
        successReturn = 100,
        failureRecovery = 20,
        successChance = 45,
        risk = "Very High"
    }
};


local INVESTMENT_TYPE_ORDER = {
    "port",
    "commercial",
    "infrastructure",
    "industrial",
    "resource",
    "technology",
    "space"
};


-- =========================================================
-- SETTINGS HELPERS
-- =========================================================

function GetSetting(
    name,
    defaultValue
)

    local settings =
        Mod.Settings or {};


    if settings[name] == nil then
        return defaultValue;
    end


    return settings[name];
end


function GetMaxAgreements()

    return GetSetting(
        "MaxTradeAgreements",
        DEFAULT_MAX_AGREEMENTS
    );
end


function GetTradeBonusPercent()

    return GetSetting(
        "TradeBonusPercent",
        DEFAULT_TRADE_BONUS_PERCENT
    );
end


function GetTradeCooldownTurns()

    return GetSetting(
        "TradeCooldownTurns",
        DEFAULT_COOLDOWN_TURNS
    );
end


function GetAIProposalChance()

    return GetSetting(
        "AIProposalChance",
        DEFAULT_AI_PROPOSAL_CHANCE
    );
end


function GetAIMinimumAgreementTurns()

    return GetSetting(
        "AIMinimumAgreementTurns",
        DEFAULT_AI_MIN_AGREEMENT_TURNS
    );
end


function GetAIReplacementPercent()

    return GetSetting(
        "AIReplacementPercent",
        DEFAULT_AI_REPLACEMENT_PERCENT
    );
end


function GetEconomicDeclineTurns()

    return GetSetting(
        "EconomicDeclineTurns",
        DEFAULT_DECLINE_TURNS
    );
end


function GetAIInvestmentsEnabled()

    return GetSetting(
        "AIInvestmentsEnabled",
        true
    );
end


function GetAIProjectsEnabled()

    return GetSetting(
        "AIProjectsEnabled",
        true
    );
end


function GetAIProjectChance()

    return GetSetting(
        "AIProjectChance",
        DEFAULT_AI_PROJECT_CHANCE
    );
end


function GetAIInvestChance()

    return GetSetting(
        "AIInvestChance",
        DEFAULT_AI_INVEST_CHANCE
    );
end


function GetAIReservePercent()

    return GetSetting(
        "AIInvestmentReservePercent",
        DEFAULT_AI_INVESTMENT_RESERVE_PERCENT
    );
end


-- =========================================================
-- DIPLOMACY SETTINGS HELPERS
-- =========================================================

function GetWarDeclarationDelay()

    local delay =
        tonumber(
            GetSetting(
                "WarDeclarationDelay",
                DEFAULT_WAR_DECLARATION_DELAY
            )
        )
        or DEFAULT_WAR_DECLARATION_DELAY;


    delay =
        math.floor(
            delay
        );


    if delay < 0 then
        delay = 0;
    end


    if delay > 3 then
        delay = 3;
    end


    return delay;
end


function GetPeaceCooldownTurns()

    local turns =
        tonumber(
            GetSetting(
                "PeaceCooldownTurns",
                DEFAULT_PEACE_COOLDOWN_TURNS
            )
        )
        or DEFAULT_PEACE_COOLDOWN_TURNS;


    turns =
        math.floor(
            turns
        );


    if turns < 0 then
        turns = 0;
    end


    return turns;
end


function GetAIWarChance()

    local chance =
        tonumber(
            GetSetting(
                "AIWarChance",
                DEFAULT_AI_WAR_CHANCE
            )
        )
        or DEFAULT_AI_WAR_CHANCE;


    if chance < 0 then
        chance = 0;
    end


    if chance > 100 then
        chance = 100;
    end


    return chance;
end


function GetAIPeaceChance()

    local chance =
        tonumber(
            GetSetting(
                "AIPeaceChance",
                DEFAULT_AI_PEACE_CHANCE
            )
        )
        or DEFAULT_AI_PEACE_CHANCE;


    if chance < 0 then
        chance = 0;
    end


    if chance > 100 then
        chance = 100;
    end


    return chance;
end


function GetAINAPChance()

    local chance =
        tonumber(
            GetSetting(
                "AINAPChance",
                DEFAULT_AI_NAP_CHANCE
            )
        )
        or DEFAULT_AI_NAP_CHANCE;


    if chance < 0 then
        chance = 0;
    end


    if chance > 100 then
        chance = 100;
    end


    return chance;
end


function GetAIMinimumWarTurns()

    local turns =
        tonumber(
            GetSetting(
                "AIMinimumWarTurns",
                DEFAULT_AI_MIN_WAR_TURNS
            )
        )
        or DEFAULT_AI_MIN_WAR_TURNS;


    turns =
        math.floor(
            turns
        );


    if turns < 1 then
        turns = 1;
    end


    return turns;
end


-- =========================================================
-- DATA
-- =========================================================

function GetEconomicData()

    local data =
        Mod.PublicGameData or {};


    if data.pendingProposals == nil then
        data.pendingProposals = {};
    end


    if data.activeAgreements == nil then
        data.activeAgreements = {};
    end


    if data.cooldowns == nil then
        data.cooldowns = {};
    end


    if data.tradeHistory == nil then
        data.tradeHistory = {};
    end


    if data.tradeTurn == nil then
        data.tradeTurn = 0;
    end


    -- AI MEMORY

    if data.aiTradeMemory == nil then
        data.aiTradeMemory = {};
    end


    -- INVESTMENTS

    if data.investmentProjects == nil then
        data.investmentProjects = {};
    end


    if data.investmentHistory == nil then
        data.investmentHistory = {};
    end


    if data.completedInvestmentProjects == nil then
        data.completedInvestmentProjects = {};
    end


    if data.nextInvestmentProjectID == nil then
        data.nextInvestmentProjectID = 1;
    end

if data.pendingInvestmentActions == nil then
    data.pendingInvestmentActions = {};
end

    return data;
end

-- =========================================================
-- PLAYER HELPERS
-- =========================================================

function GetEconomicPlayer(
    game,
    playerID
)

    if game.Game == nil
        or game.Game.Players == nil then

        return nil;
    end


    return game.Game.Players[
        playerID
    ];
end


function GetEconomicPlayerName(
    game,
    playerID
)

    local player =
        GetEconomicPlayer(
            game,
            playerID
        );


    if player == nil then
        return "Unknown Player";
    end


    return player.DisplayName(
        nil,
        false
    );
end


function IsPlayerAvailable(
    game,
    playerID
)

    local player =
        GetEconomicPlayer(
            game,
            playerID
        );


    if player == nil then
        return false;
    end


    if player.Surrendered then
        return false;
    end


    return true;
end
-- =========================================================
-- GLOBAL ECONOMY / NATIONAL STATE
-- =========================================================

local REFORM_DURATION_TURNS = 3;
local REFORM_PENALTY_PERCENT = 15;


function EnsureGlobalEconomyData(
    data
)

    if data.globalEconomy == nil then

        data.globalEconomy =
            {};
    end


    local economy =
        data.globalEconomy;


    if economy.version == nil then

        economy.version =
            2;
    end


    if economy.initialized == nil then

        economy.initialized =
            true;
    end


    if economy.currentEconomyTurn == nil then

        economy.currentEconomyTurn =
            data.tradeTurn
            or 0;
    end


    if economy.nations == nil then

        economy.nations =
            {};
    end


    -- =====================================================
    -- DIPLOMACY
    -- =====================================================

    if economy.diplomacy == nil then

        economy.diplomacy =
            {};
    end


    if economy.diplomacy.relationships == nil then

        economy.diplomacy.relationships =
            {};
    end


    if economy.diplomacy.pendingWarDeclarations == nil then

        economy.diplomacy.pendingWarDeclarations =
            {};
    end


    if economy.diplomacy.pendingPeaceOffers == nil then

        economy.diplomacy.pendingPeaceOffers =
            {};
    end


    if economy.diplomacy.pendingNAPOffers == nil then

        economy.diplomacy.pendingNAPOffers =
            {};
    end

    if economy.diplomacy.pendingAllianceOffers == nil then

    economy.diplomacy.pendingAllianceOffers =
        {};
end


if economy.diplomacy.alliances == nil then

    economy.diplomacy.alliances =
        {};
end

    if economy.diplomacy.nonAggressionPacts == nil then

        economy.diplomacy.nonAggressionPacts =
            {};
    end


    if economy.diplomacy.history == nil then

        economy.diplomacy.history =
            {};
    end


    -- =====================================================
    -- MARKET
    -- =====================================================

    if economy.market == nil then

        economy.market =
            {};
    end


    if economy.market.companies == nil then

        economy.market.companies =
            {};
    end


    if economy.market.transactions == nil then

        economy.market.transactions =
            {};
    end


    if economy.market.priceHistory == nil then

        economy.market.priceHistory =
            {};
    end


    if economy.market.nextCompanyID == nil then

        economy.market.nextCompanyID =
            1;
    end

if economy.market.etf == nil then

    economy.market.etf =
        {
            name =
                "Global Market ETF",

            active =
                true,

            currentPrice =
                100,

            previousPrice =
                100,

            startingPrice =
                100,

            memberCompanyIDs =
                {},

            memberCount =
                5,

            lastRebalanceTurn =
                0,

            rebalanceInterval =
                5,

            priceHistory =
                {},

            dividendPerShare =
                0,

            totalDividendsPaid =
                0,

            totalShares =
                1000,

            sharesAvailable =
                1000
        };

end

    -- =====================================================
    -- WORLD / REPORT DATA
    -- =====================================================

    if economy.worldEvents == nil then

        economy.worldEvents =
            {};
    end


    if economy.pendingWorldReportEvents == nil then

        economy.pendingWorldReportEvents =
            {};
    end


    if economy.transactionLedger == nil then

        economy.transactionLedger =
            {};
    end


    if economy.economicRankings == nil then

        economy.economicRankings =
            {};
    end


    data.globalEconomy =
        economy;


    return economy;
end


function EconomyPairKey(
    playerA,
    playerB
)

    local a =
        tostring(
            playerA
        );


    local b =
        tostring(
            playerB
        );


    if a < b then

        return
            a ..
            "|" ..
            b;
    end


    return
        b ..
        "|" ..
        a;
end


function GetDiplomacyData(
    data
)

    local economy =
        EnsureGlobalEconomyData(
            data
        );


    economy.diplomacy =
        economy.diplomacy
        or {};


    local diplomacy =
        economy.diplomacy;


    diplomacy.relationships =
        diplomacy.relationships
        or {};


    diplomacy.pendingWarDeclarations =
        diplomacy.pendingWarDeclarations
        or {};


    diplomacy.pendingPeaceOffers =
        diplomacy.pendingPeaceOffers
        or {};


    diplomacy.pendingNAPOffers =
        diplomacy.pendingNAPOffers
        or {};

diplomacy.pendingAllianceOffers =
    diplomacy.pendingAllianceOffers
    or {};


diplomacy.alliances =
    diplomacy.alliances
    or {};

    diplomacy.nonAggressionPacts =
        diplomacy.nonAggressionPacts
        or {};


    diplomacy.history =
        diplomacy.history
        or {};


    return diplomacy;
end


function GetCurrentDiplomacyTurn(
    data
)

    local economy =
        EnsureGlobalEconomyData(
            data
        );


    return
        economy.currentEconomyTurn
        or data.tradeTurn
        or 1;
end


function GetDiplomacyRelationship(
    data,
    playerA,
    playerB
)

    local diplomacy =
        GetDiplomacyData(
            data
        );


    local key =
        EconomyPairKey(
            playerA,
            playerB
        );


    local relationship =
        diplomacy.relationships[
            key
        ];


    if relationship == nil then


        local startsAtWar =
            GetSetting(
                "PlayersStartAtWar",
                false
            );


        relationship =
        {

            player1 =
                playerA,

            player2 =
                playerB,

            status =
                startsAtWar
                and "war"
                or "peace",

            sinceTurn =
                GetCurrentDiplomacyTurn(
                    data
                ),

            lastChangedTurn =
                GetCurrentDiplomacyTurn(
                    data
                ),

            peaceCooldownUntil =
                0,

            pendingWarDeclaration =
                false,

            pendingWarFrom =
                nil,

            pendingWarTo =
                nil,

            warActivatesTurn =
                nil
        };


        diplomacy.relationships[
            key
        ] =
            relationship;
    end


    return relationship;
end


function IsDiplomacyWar(
    data,
    playerA,
    playerB
)

    local relationship =
        GetDiplomacyRelationship(
            data,
            playerA,
            playerB
        );


    return
        relationship.status
        == "war";
end


function GetActiveDiplomacyNAP(
    data,
    playerA,
    playerB
)

    local diplomacy =
        GetDiplomacyData(
            data
        );


    local key =
        EconomyPairKey(
            playerA,
            playerB
        );


    local pact =
        diplomacy.nonAggressionPacts[
            key
        ];


    if pact == nil then

        return nil;
    end


    if pact.active
        ~= true then

        return nil;
    end


    local currentTurn =
        GetCurrentDiplomacyTurn(
            data
        );


    if currentTurn
        >= (
            pact.endTurn
            or currentTurn
        ) then

        return nil;
    end


    return pact;
end

-- =========================================================
-- ALLIANCE HELPERS
-- =========================================================

function GetActiveAlliance(
    data,
    playerA,
    playerB
)

    local diplomacy =
        GetDiplomacyData(
            data
        );


    local key =
        EconomyPairKey(
            playerA,
            playerB
        );


    local alliance =
        diplomacy.alliances[
            key
        ];


    if alliance == nil
        or alliance.active ~= true then

        return nil;

    end


    return alliance;
end


function HasPendingAllianceOffer(
    data,
    playerA,
    playerB
)

    local diplomacy =
        GetDiplomacyData(
            data
        );


    for _, offer in pairs(
        diplomacy.pendingAllianceOffers
    ) do

        if
            (
                offer.fromPlayerID == playerA
                and offer.toPlayerID == playerB
            )
            or
            (
                offer.fromPlayerID == playerB
                and offer.toPlayerID == playerA
            )
        then

            return true;

        end

    end


    return false;
end


function RemovePendingAllianceOffersBetween(
    data,
    playerA,
    playerB
)

    local diplomacy =
        GetDiplomacyData(
            data
        );


    for i =
        #diplomacy.pendingAllianceOffers,
        1,
        -1 do

        local offer =
            diplomacy.pendingAllianceOffers[
                i
            ];


        if
            (
                offer.fromPlayerID == playerA
                and offer.toPlayerID == playerB
            )
            or
            (
                offer.fromPlayerID == playerB
                and offer.toPlayerID == playerA
            )
        then

            table.remove(
                diplomacy.pendingAllianceOffers,
                i
            );

        end

    end

end

function EnsureEconomyNation(
    game,
    data,
    playerID
)

    local economy =
        EnsureGlobalEconomyData(
            data
        );


    local nation =
        economy.nations[
            playerID
        ];


    if nation == nil then


        local player =
            GetEconomicPlayer(
                game,
                playerID
            );


        nation =
        {

            playerID =
                playerID,

            initialized =
                true,

            eliminated =
                false,

            isAI =
                player ~= nil
                and player.IsAI
                or false,


            -- =============================================
            -- NATIONAL SETUP
            -- =============================================

            setupComplete =
                false,

            ideology =
                nil,

            economicStrategy =
                nil,

            taxPolicy =
                "Standard",

            taxPolicyLastChangedTurn =
                0,


            -- =============================================
            -- ECONOMIC REFORM
            -- =============================================

            reformActive =
                false,

            reformStartedTurn =
                nil,

            reformEndTurn =
                nil,

            reformPenaltyPercent =
                0,

            reformCount =
                0,

            lastReformTurn =
                nil,


            baseEconomicConfidence =
                100,

            effectiveEconomicConfidence =
                100,


            -- =============================================
            -- DIPLOMACY
            -- =============================================

            relationships =
                {},

            pendingWarDeclarations =
                {},

            pendingPeaceOffers =
                {},

            nonAggressionPacts =
                {},

            lastPeaceTurn =
                {},


            -- =============================================
            -- COMPANIES
            -- =============================================

            companies =
                {},

            companySlotsUnlocked =
                1,

            flagshipCompanyCreated =
                false,

            flagshipCompanyID =
                nil,

            flagshipCompanyName =
                nil,

            companyStrategy =
                nil,


            -- =============================================
            -- STOCKS
            -- =============================================

            stockHoldings =
                {},

            stockCostBasis =
                {},

            realizedStockProfit =
                0,

            dividendsReceived =
                0,


            -- =============================================
            -- ETF
            -- =============================================

            etfShares =
                0,

            etfCostBasis =
                0,

            etfDividendsReceived =
                0,


            -- =============================================
            -- BONDS
            -- =============================================

            bondsOwned =
                {},

            bondsIssued =
                {},

            creditRating =
                "BBB",

            creditScore =
                50,


            -- =============================================
            -- UNITED NATIONS
            -- =============================================

            publicEnemyLevel =
                0,

            sanctions =
                {},

            unEligible =
                true,

            unLeadershipRole =
                nil,


            -- =============================================
            -- AI
            -- =============================================

            aiProfile =
                nil,

            aiDynamicReservePercent =
                GetSetting(
                    "AIBaseReservePercent",
                    40
                ),

            aiLastStrategicReviewTurn =
                0,

            aiLastDiplomacyReviewTurn =
                0,


            -- =============================================
            -- PLAYER AI MANAGER
            -- =============================================

            aiManagerEnabled =
                false,

            aiManagerBudget =
                100,

            aiManagerBudgetRemaining =
                0,

            aiManagerCancelTurn =
                nil,

            aiManagerLastProcessedTurn =
                0,


            -- =============================================
            -- NOTIFICATIONS
            -- =============================================

            personalEventQueue =
                {},

            lastTurnReportSeen =
                0
        };


        economy.nations[
            playerID
        ] =
            nation;
    end


    if nation.companies == nil then

        nation.companies =
            {};
    end


    if nation.personalEventQueue == nil then

        nation.personalEventQueue =
            {};
    end


    if nation.baseEconomicConfidence == nil then

        nation.baseEconomicConfidence =
            100;
    end


    if nation.effectiveEconomicConfidence == nil then

        nation.effectiveEconomicConfidence =
            nation.baseEconomicConfidence;
    end


    if nation.reformActive == nil then

        nation.reformActive =
            false;
    end


    if nation.reformPenaltyPercent == nil then

        nation.reformPenaltyPercent =
            0;
    end


    -- =====================================================
    -- BACKWARD-COMPATIBILITY FOR EXISTING GAMES
    -- =====================================================

    if nation.relationships == nil then

        nation.relationships =
            {};
    end


    if nation.pendingWarDeclarations == nil then

        nation.pendingWarDeclarations =
            {};
    end


    if nation.pendingPeaceOffers == nil then

        nation.pendingPeaceOffers =
            {};
    end


    if nation.nonAggressionPacts == nil then

        nation.nonAggressionPacts =
            {};
    end


    if nation.lastPeaceTurn == nil then

        nation.lastPeaceTurn =
            {};
    end


    if nation.aiLastDiplomacyReviewTurn == nil then

        nation.aiLastDiplomacyReviewTurn =
            0;
    end


    return nation;
end


-- =========================================================
-- WORLD / PERSONAL EVENTS
-- =========================================================

function AddEconomyWorldEvent(
    economy,
    eventType,
    playerID,
    headline,
    extra
)

    economy.worldEvents =
        economy.worldEvents
        or {};


    economy.pendingWorldReportEvents =
        economy.pendingWorldReportEvents
        or {};


    local event =
    {

        turn =
            economy.currentEconomyTurn
            or 1,

        type =
            eventType,

        playerID =
            playerID,

        headline =
            headline
    };


    if extra ~= nil then


        if type(extra)
            == "table" then


            for key, value
                in pairs(
                    extra
                ) do


                event[key] =
                    value;
            end


        else


            -- Backward compatibility:
            -- existing economy code passes companyID
            -- directly as the fifth argument.

            event.companyID =
                extra;
        end
    end


    table.insert(
        economy.worldEvents,
        event
    );


    local reportEvent =
    {

        turn =
            event.turn,

        type =
            event.type,

        playerID =
            event.playerID,

        headline =
            event.headline
    };


    if event.companyID
        ~= nil then


        reportEvent.companyID =
            event.companyID;
    end


    if event.otherPlayerID
        ~= nil then


        reportEvent.otherPlayerID =
            event.otherPlayerID;
    end


    if event.endTurn
        ~= nil then


        reportEvent.endTurn =
            event.endTurn;
    end


    if event.activatesTurn
        ~= nil then


        reportEvent.activatesTurn =
            event.activatesTurn;
    end


    table.insert(
        economy.pendingWorldReportEvents,
        reportEvent
    );
end


function AddEconomyPersonalEvent(
    nation,
    currentTurn,
    eventType,
    message
)

    nation.personalEventQueue =
        nation.personalEventQueue
        or {};


    table.insert(
        nation.personalEventQueue,
        {

            turn =
                currentTurn,

            type =
                eventType,

            message =
                message
        }
    );
end
function EconomyCompanyNameExists(
    economy,
    companyName
)

    local normalized =
        string.lower(
            tostring(
                companyName
            )
        );


    for _, company
        in pairs(
            economy.market.companies
            or {}
        ) do


        if company.name ~= nil
            and string.lower(
                tostring(
                    company.name
                )
            ) == normalized then


            return true;

        end

    end


    return false;

end


function BuildAICompanyName(
    game,
    economy,
    playerID
)

    local nationName =
        GetEconomicPlayerName(
            game,
            playerID
        );


    local base =
        tostring(
            nationName
        ) ..
        " Holdings";


    if string.len(
        base
    ) > 40 then


        base =
            string.sub(
                base,
                1,
                40
            );

    end


    if not EconomyCompanyNameExists(
        economy,
        base
    ) then


        return base;

    end


    local suffix =
        " " ..
        tostring(
            playerID
        );


    local allowedLength =
        40
        - string.len(
            suffix
        );


    return
        string.sub(
            base,
            1,
            allowedLength
        )
        ..
        suffix;

end


-- =========================================================
-- AI TURN 1 NATIONAL SETUP
-- =========================================================

function ChooseAINationalProfile(
    game,
    playerID
)

    local income =
        GetCommerceIncome(
            game,
            playerID
        );


    local selector =
        (
            playerID
            +
            math.floor(
                income
            )
        )
        % 5;


    if selector == 0 then


        return
            "Free Market",
            "Growth",
            "Low",
            "Growth",
            "Growth";


    elseif selector == 1 then


        return
            "Capitalist",
            "Growth",
            "Standard",
            "Balanced",
            "Investor";


    elseif selector == 2 then


        return
            "Social Democratic",
            "Balanced",
            "Standard",
            "Dividend",
            "Balanced";


    elseif selector == 3 then


        return
            "State Capitalist",
            "Balanced",
            "High",
            "Balanced",
            "Planner";


    else


        return
            "Socialist",
            "Conservative",
            "High",
            "Dividend",
            "Conservative";

    end

end


function CompleteAINationalSetup(
    game,
    data,
    playerID
)

    local economy =
        EnsureGlobalEconomyData(
            data
        );


    local nation =
        EnsureEconomyNation(
            game,
            data,
            playerID
        );


    if nation.setupComplete then

        return;

    end


    local ideology,
        economicStrategy,
        taxPolicy,
        companyStrategy,
        aiProfile =
        ChooseAINationalProfile(
            game,
            playerID
        );


    local companyName =
        BuildAICompanyName(
            game,
            economy,
            playerID
        );


    local companyID =
        economy.market.nextCompanyID
        or 1;


    economy.market.nextCompanyID =
        companyID
        + 1;


    local founderPercent =
        GetSetting(
            "FounderSharePercent",
            20
        );


    if founderPercent < 0 then

        founderPercent =
            0;

    end


    if founderPercent > 100 then

        founderPercent =
            100;

    end


    local totalShares =
        100;


    local founderShares =
        math.floor(
            (
                totalShares
                *
                (
                    founderPercent
                    / 100
                )
            )
            + 0.5
        );


    local publicShares =
        totalShares
        - founderShares;


    local currentTurn =
        economy.currentEconomyTurn
        or data.tradeTurn
        or 1;

    local startingPrice =
    CalculateStartingStockPrice(
        game,
        playerID
    );

    economy.market.companies[
        companyID
    ] =
    {

        id =
            companyID,

        name =
            companyName,

        ownerPlayerID =
            playerID,

        founderPlayerID =
            playerID,

        strategy =
            companyStrategy,

        ideology =
            ideology,

        nationStrategy =
            economicStrategy,

        createdTurn =
            currentTurn,

status =
    "trading",


        totalShares =
            totalShares,

        founderShares =
            founderShares,

        publicShares =
            publicShares,

        sharesAvailable =
            publicShares,


startingPrice =
    startingPrice,

currentPrice =
    startingPrice,

previousPrice =
    startingPrice,

marketCap =
    totalShares
    * startingPrice,


        dividendPerShare =
            0,

        totalDividendsPaid =
            0,


        priceHistory =
        {

            {

                turn =
                    currentTurn,

price =
    startingPrice

            }

        },


        etfMember =
            false,

        etfMemberTurns =
            0,


        confidence =
            50,

        effectiveConfidence =
            50,

        reformPenaltyPercent =
            0,


        volatility =
            GetSetting(
                "StockVolatilityPercent",
                10
            ),


        active =
            true,

        delisted =
            false

    };


    table.insert(
        nation.companies,
        companyID
    );


    nation.setupComplete =
        true;


    nation.setupCompletedTurn =
        currentTurn;


    nation.ideology =
        ideology;


    nation.economicStrategy =
        economicStrategy;


    nation.taxPolicy =
        taxPolicy;


    nation.taxPolicyLastChangedTurn =
        currentTurn;

nation.stockHoldings =
    nation.stockHoldings
    or {};

nation.stockCostBasis =
    nation.stockCostBasis
    or {};

nation.stockHoldings[
    companyID
] =
    founderShares;

nation.stockCostBasis[
    companyID
] =
    0;

    nation.flagshipCompanyCreated =
        true;


    nation.flagshipCompanyID =
        companyID;


    nation.flagshipCompanyName =
        companyName;


    nation.companyStrategy =
        companyStrategy;


    nation.aiProfile =
        aiProfile;


    nation.baseEconomicConfidence =
        100;


    nation.effectiveEconomicConfidence =
        100;


    AddEconomyPersonalEvent(
        nation,
        currentTurn,
        "national_setup_complete",
        "AI National Setup completed automatically."
    );


    local aiName =
        GetEconomicPlayerName(
            game,
            playerID
        );


    AddEconomyWorldEvent(
        economy,
        "national_setup_complete",
        playerID,
        aiName ..
        " completed its national economic setup and established " ..
        companyName ..
        ".",
        companyID
    );

end


function EnsureAINationalSetups(
    game,
    data
)

    for playerID, player
        in pairs(
            game.Game.Players
        ) do


        if player.IsAI
            and IsPlayerAvailable(
                game,
                playerID
            ) then


            local nation =
                EnsureEconomyNation(
                    game,
                    data,
                    playerID
                );


            if nation.setupComplete
                ~= true then


                CompleteAINationalSetup(
                    game,
                    data,
                    playerID
                );

            end

        end

    end

end
-- =========================================================
-- ELIMINATION STATE
-- =========================================================

function UpdateEconomyNationActivity(
    game,
    data
)

    local economy =
        EnsureGlobalEconomyData(
            data
        );


    for playerID, _
        in pairs(
            game.Game.Players
        ) do


        local nation =
            EnsureEconomyNation(
                game,
                data,
                playerID
            );


        if IsPlayerAvailable(
            game,
            playerID
        ) then


            nation.eliminated =
                false;


        elseif nation.eliminated
            ~= true then


            nation.eliminated =
                true;


            nation.unEligible =
                false;


            nation.reformActive =
                false;


            nation.reformPenaltyPercent =
                0;


            nation.effectiveEconomicConfidence =
                0;


            local nationName =
                GetEconomicPlayerName(
                    game,
                    playerID
                );


            AddEconomyWorldEvent(
                economy,
                "nation_eliminated",
                playerID,
                nationName ..
                " is no longer economically active.",
                nil
            );

        end

    end

end


-- =========================================================
-- ECONOMIC REFORM PROCESSING
-- =========================================================

function ProcessEconomicReforms(
    game,
    data
)

    local economy =
        EnsureGlobalEconomyData(
            data
        );


    local currentTurn =
        economy.currentEconomyTurn
        or data.tradeTurn
        or 1;


    for playerID, nation
        in pairs(
            economy.nations
            or {}
        ) do


        if nation.eliminated
            ~= true then


            local baseConfidence =
                nation.baseEconomicConfidence
                or 100;


            local penalty =
                0;


            if nation.reformActive
                == true then


                local reformEndTurn =
                    nation.reformEndTurn
                    or currentTurn;


                if currentTurn
                    >= reformEndTurn then


                    nation.reformActive =
                        false;


                    nation.reformStartedTurn =
                        nil;


                    nation.reformEndTurn =
                        nil;


                    nation.reformPenaltyPercent =
                        0;


                    penalty =
                        0;


                    AddEconomyPersonalEvent(
                        nation,
                        currentTurn,
                        "economic_reform_completed",
                        "Economic reform is complete. The temporary confidence penalty has ended."
                    );


                    local nationName =
                        GetEconomicPlayerName(
                            game,
                            playerID
                        );


                    AddEconomyWorldEvent(
                        economy,
                        "economic_reform_completed",
                        playerID,
                        nationName ..
                        " completed its economic reform.",
                        nil
                    );


                else


                    penalty =
                        nation.reformPenaltyPercent
                        or REFORM_PENALTY_PERCENT;

                end

            end


            nation.effectiveEconomicConfidence =
                math.max(
                    0,

                    math.floor(
                        (
                            baseConfidence
                            *
                            (
                                1
                                -
                                (
                                    penalty
                                    / 100
                                )
                            )
                        )
                        + 0.5
                    )
                );


            -- Keep the flagship company's confidence
            -- synchronized with the nation's reform.

            local companyID =
                nation.flagshipCompanyID;


            if companyID ~= nil
                and economy.market ~= nil
                and economy.market.companies ~= nil then


                local company =
                    economy.market.companies[
                        companyID
                    ];


                if company ~= nil then


                    company.reformPenaltyPercent =
                        penalty;


                    local baseCompanyConfidence =
                        company.confidence
                        or 50;

                    local taxConfidenceModifier =
    GetTaxCompanyConfidenceModifier(
        nation
    );

local ideologyConfidenceModifier =
    GetIdeologyCompanyConfidenceModifier(
        nation
    );

local totalConfidenceModifier =
    taxConfidenceModifier
    + ideologyConfidenceModifier;

baseCompanyConfidence =
    math.max(
        0,
        math.min(
            100,
            baseCompanyConfidence
            + totalConfidenceModifier
        )
    );

                    company.effectiveConfidence =
                        math.max(
                            0,

                            math.floor(
                                (
                                    baseCompanyConfidence
                                    *
                                    (
                                        1
                                        -
                                        (
                                            penalty
                                            / 100
                                        )
                                    )
                                )
                                + 0.5
                            )
                        );

                end

            end

        end

    end

end


-- =========================================================
-- DIPLOMACY HISTORY
-- =========================================================

function AddDiplomacyHistory(
    data,
    eventType,
    player1,
    player2,
    message,
    extra
)

    local diplomacy =
        GetDiplomacyData(
            data
        );


    local event =
    {

        turn =
            GetCurrentDiplomacyTurn(
                data
            ),

        type =
            eventType,

        player1 =
            player1,

        player2 =
            player2,

        message =
            message
    };


    if extra ~= nil
        and type(extra)
        == "table" then


        for key, value
            in pairs(
                extra
            ) do


            event[key] =
                value;
        end
    end


    table.insert(
        diplomacy.history,
        event
    );


    while #diplomacy.history
        > MAX_DIPLOMACY_HISTORY do


        table.remove(
            diplomacy.history,
            1
        );
    end

end


-- =========================================================
-- DIPLOMACY TRADE CLEANUP
-- =========================================================

function RemoveDiplomacyTradeAgreement(
    game,
    data,
    playerA,
    playerB
)

    local removed =
        false;


    for i =
        #data.activeAgreements,
        1,
        -1 do


        local agreement =
            data.activeAgreements[
                i
            ];


        if
            (
                agreement.player1
                == playerA
                and agreement.player2
                == playerB
            )
            or
            (
                agreement.player1
                == playerB
                and agreement.player2
                == playerA
            )
        then


            table.remove(
                data.activeAgreements,
                i
            );


            removed =
                true;
        end
    end


    if removed then


        local nameA =
            GetEconomicPlayerName(
                game,
                playerA
            );


        local nameB =
            GetEconomicPlayerName(
                game,
                playerB
            );


        AddTradeHistory(
            data,
            "agreement_ended_war",
            nameA ..
            " and " ..
            nameB ..
            " had their trade agreement terminated because war began.",
            playerA,
            playerB,
            false
        );
    end


    return removed;
end


function RemoveDiplomacyPendingTrade(
    data,
    playerA,
    playerB
)

    for i =
        #data.pendingProposals,
        1,
        -1 do


        local proposal =
            data.pendingProposals[
                i
            ];


        if
            (
                proposal.fromPlayerID
                == playerA
                and proposal.toPlayerID
                == playerB
            )
            or
            (
                proposal.fromPlayerID
                == playerB
                and proposal.toPlayerID
                == playerA
            )
        then


            table.remove(
                data.pendingProposals,
                i
            );
        end
    end

end


-- =========================================================
-- DIPLOMACY OFFER CLEANUP
-- =========================================================

function RemovePeaceOffersBetween(
    data,
    playerA,
    playerB
)

    local diplomacy =
        GetDiplomacyData(
            data
        );


    for i =
        #diplomacy.pendingPeaceOffers,
        1,
        -1 do


        local offer =
            diplomacy.pendingPeaceOffers[
                i
            ];


        if
            (
                offer.fromPlayerID
                == playerA
                and offer.toPlayerID
                == playerB
            )
            or
            (
                offer.fromPlayerID
                == playerB
                and offer.toPlayerID
                == playerA
            )
        then


            table.remove(
                diplomacy.pendingPeaceOffers,
                i
            );
        end
    end

end


function RemoveNAPOffersBetween(
    data,
    playerA,
    playerB
)

    local diplomacy =
        GetDiplomacyData(
            data
        );


    for i =
        #diplomacy.pendingNAPOffers,
        1,
        -1 do


        local offer =
            diplomacy.pendingNAPOffers[
                i
            ];


        if
            (
                offer.fromPlayerID
                == playerA
                and offer.toPlayerID
                == playerB
            )
            or
            (
                offer.fromPlayerID
                == playerB
                and offer.toPlayerID
                == playerA
            )
        then


            table.remove(
                diplomacy.pendingNAPOffers,
                i
            );
        end
    end

end


-- =========================================================
-- START WAR
-- =========================================================

function ActivateDiplomacyWar(
    game,
    data,
    playerA,
    playerB,
    reason,
    conflictID
)

    local diplomacy =
        GetDiplomacyData(
            data
        );


    local relationship =
        GetDiplomacyRelationship(
            data,
            playerA,
            playerB
        );


    local currentTurn =
        GetCurrentDiplomacyTurn(
            data
        );


    relationship.status =
        "war";


    relationship.sinceTurn =
        currentTurn;


    relationship.lastChangedTurn =
        currentTurn;


    relationship.pendingWarDeclaration =
        false;


    relationship.pendingWarFrom =
        nil;


    relationship.pendingWarTo =
        nil;


    relationship.warActivatesTurn =
        nil;

    relationship.warReason =
        reason
        or relationship.warReason
        or "Territorial Dispute";

    relationship.warConflictID =
        conflictID
        or relationship.warConflictID;


    local key =
        EconomyPairKey(
            playerA,
            playerB
        );

    diplomacy.warStats = diplomacy.warStats or {};
    diplomacy.warEventHistory = diplomacy.warEventHistory or {};
    diplomacy.nextWarEventID = diplomacy.nextWarEventID or 1;

    diplomacy.warStats[key] = {
        key = key,
        player1 = playerA,
        player2 = playerB,
        startTurn = currentTurn,
        endTurn = nil,
        active = true,
        reason = relationship.warReason,
        conflictID = relationship.warConflictID,
        attacks = 0,
        casualties = {
            [tostring(playerA)] = 0,
            [tostring(playerB)] = 0
        },
        territoriesCaptured = {
            [tostring(playerA)] = 0,
            [tostring(playerB)] = 0
        },
        economicImpact = {
            [tostring(playerA)] = 0,
            [tostring(playerB)] = 0
        }
    };


    diplomacy.warConflicts = diplomacy.warConflicts or {};
    diplomacy.nextWarConflictID = diplomacy.nextWarConflictID or 1;
    local resolvedConflictID = relationship.warConflictID;
    if resolvedConflictID == nil then
        resolvedConflictID = diplomacy.nextWarConflictID;
        diplomacy.nextWarConflictID = resolvedConflictID + 1;
        relationship.warConflictID = resolvedConflictID;
    end
    local conflict = diplomacy.warConflicts[resolvedConflictID];
    if conflict == nil then
        conflict = {
            id = resolvedConflictID,
            cause = relationship.warReason,
            startTurn = currentTurn,
            active = true,
            sideA = {},
            sideB = {}
        };
        diplomacy.warConflicts[resolvedConflictID] = conflict;
    end
    conflict.active = true;
    conflict.cause = conflict.cause or relationship.warReason;
    conflict.sideA = conflict.sideA or {};
    conflict.sideB = conflict.sideB or {};
    conflict.sideA[playerA] = true;
    conflict.sideB[playerB] = true;

    diplomacy.pendingWarDeclarations[
        key
    ] =
        nil;


    local pact =
        diplomacy.nonAggressionPacts[
            key
        ];


    if pact ~= nil then


        pact.active =
            false;


        diplomacy.nonAggressionPacts[
            key
        ] =
            nil;
    end


    RemovePeaceOffersBetween(
        data,
        playerA,
        playerB
    );


    RemoveNAPOffersBetween(
        data,
        playerA,
        playerB
    );


    RemoveDiplomacyPendingTrade(
        data,
        playerA,
        playerB
    );


    RemoveDiplomacyTradeAgreement(
        game,
        data,
        playerA,
        playerB
    );


    local nameA =
        GetEconomicPlayerName(
            game,
            playerA
        );


    local nameB =
        GetEconomicPlayerName(
            game,
            playerB
        );


    local message =
        nameA ..
        " and " ..
        nameB ..
        " are now officially at war.";


    AddDiplomacyHistory(
        data,
        "war_started",
        playerA,
        playerB,
        message,
        {

            reason =
                reason
                or "declaration"
        }
    );


    AddEconomyWorldEvent(
        data.globalEconomy,
        "war_started",
        playerA,
        message,
        {

            otherPlayerID =
                playerB
        }
    );

end


-- =========================================================
-- START PEACE
-- =========================================================

function ActivateDiplomacyPeace(
    game,
    data,
    playerA,
    playerB,
    reason
)

    local diplomacy =
        GetDiplomacyData(
            data
        );


    local relationship =
        GetDiplomacyRelationship(
            data,
            playerA,
            playerB
        );


    local currentTurn =
        GetCurrentDiplomacyTurn(
            data
        );


    relationship.status =
        "peace";


    relationship.sinceTurn =
        currentTurn;


    relationship.lastChangedTurn =
        currentTurn;


    relationship.pendingWarDeclaration =
        false;


    relationship.pendingWarFrom =
        nil;


    relationship.pendingWarTo =
        nil;


    relationship.warActivatesTurn =
        nil;


    relationship.peaceCooldownUntil =
        currentTurn
        + GetPeaceCooldownTurns();


    local key =
        EconomyPairKey(
            playerA,
            playerB
        );

    diplomacy.warStats = diplomacy.warStats or {};
    local warStats = diplomacy.warStats[key];
    if warStats ~= nil then
        warStats.active = false;
        warStats.endTurn = currentTurn;
    end

    -- Keep coalition conflict records in sync with the actual pairwise war
    -- relationships. Older builds could leave warConflicts.active=true after
    -- peace, which made finished wars appear again in Current Wars.
    local conflictID = relationship.warConflictID;
    local conflict = conflictID and (diplomacy.warConflicts or {})[conflictID] or nil;
    if conflict ~= nil then
        local conflictStillActive = false;
        for sideAID, sideAActive in pairs(conflict.sideA or {}) do
            if sideAActive == true then
                for sideBID, sideBActive in pairs(conflict.sideB or {}) do
                    if sideBActive == true then
                        local crossRelationship = GetDiplomacyRelationship(data, sideAID, sideBID);
                        if crossRelationship ~= nil and crossRelationship.status == "war" then
                            conflictStillActive = true;
                            break;
                        end
                    end
                end
            end
            if conflictStillActive then break; end
        end
        conflict.active = conflictStillActive;
        if not conflictStillActive then
            conflict.endTurn = currentTurn;
        end
    end


    diplomacy.pendingWarDeclarations[
        key
    ] =
        nil;


    RemovePeaceOffersBetween(
        data,
        playerA,
        playerB
    );


    local nameA =
        GetEconomicPlayerName(
            game,
            playerA
        );


    local nameB =
        GetEconomicPlayerName(
            game,
            playerB
        );


    local message =
        nameA ..
        " and " ..
        nameB ..
        " are now at peace.";


    AddDiplomacyHistory(
        data,
        "peace_started",
        playerA,
        playerB,
        message,
        {

            reason =
                reason
                or "agreement",

            cooldownUntil =
                relationship.peaceCooldownUntil
        }
    );


    AddEconomyWorldEvent(
        data.globalEconomy,
        "peace_started",
        playerA,
        message,
        {

            otherPlayerID =
                playerB
        }
    );

end


-- =========================================================
-- PROCESS DELAYED WAR DECLARATIONS
-- =========================================================

function ProcessPendingWarDeclarations(
    game,
    data
)

    local diplomacy =
        GetDiplomacyData(
            data
        );


    local currentTurn =
        GetCurrentDiplomacyTurn(
            data
        );


    local keysToActivate =
        {};


    for key, declaration
        in pairs(
            diplomacy.pendingWarDeclarations
        ) do


        local fromPlayerID =
            declaration.fromPlayerID;


        local toPlayerID =
            declaration.toPlayerID;


        if fromPlayerID == nil
            or toPlayerID == nil then


            diplomacy.pendingWarDeclarations[
                key
            ] =
                nil;


        elseif not IsPlayerAvailable(
            game,
            fromPlayerID
        )
        or not IsPlayerAvailable(
            game,
            toPlayerID
        ) then


            diplomacy.pendingWarDeclarations[
                key
            ] =
                nil;


        else


            local fromNation =
                EnsureEconomyNation(
                    game,
                    data,
                    fromPlayerID
                );


            local toNation =
                EnsureEconomyNation(
                    game,
                    data,
                    toPlayerID
                );


            if fromNation.setupComplete
                ~= true
                or toNation.setupComplete
                ~= true
                or fromNation.eliminated
                == true
                or toNation.eliminated
                == true then


                diplomacy.pendingWarDeclarations[
                    key
                ] =
                    nil;


            else


                local activatesTurn =
                    declaration.activatesTurn
                    or declaration.warStartTurn
                    or currentTurn;


                if currentTurn
                    >= activatesTurn then


                    table.insert(
                        keysToActivate,
                        {

                            key =
                                key,

                            fromPlayerID =
                                fromPlayerID,

                            toPlayerID =
                                toPlayerID,

                            warReason =
                                declaration.warReason,

                            conflictID =
                                declaration.conflictID
                        }
                    );
                end

            end

        end

    end


    for _, entry
        in ipairs(
            keysToActivate
        ) do


        if diplomacy.pendingWarDeclarations[
            entry.key
        ] ~= nil then


            ActivateDiplomacyWar(
                game,
                data,
                entry.fromPlayerID,
                entry.toPlayerID,
                entry.warReason or "Territorial Dispute",
                entry.conflictID
            );
        end
    end

end


-- =========================================================
-- PROCESS NON-AGGRESSION PACT EXPIRATION
-- =========================================================

function ProcessDiplomacyNAPExpirations(
    game,
    data
)

    local diplomacy =
        GetDiplomacyData(
            data
        );


    local currentTurn =
        GetCurrentDiplomacyTurn(
            data
        );


    for key, pact
        in pairs(
            diplomacy.nonAggressionPacts
        ) do


        if pact == nil
            or pact.active
            ~= true then


            diplomacy.nonAggressionPacts[
                key
            ] =
                nil;


        else


            local endTurn =
                pact.endTurn
                or currentTurn;


            if currentTurn
                >= endTurn then


                local playerA =
                    pact.player1;


                local playerB =
                    pact.player2;


                diplomacy.nonAggressionPacts[
                    key
                ] =
                    nil;


                if playerA ~= nil
                    and playerB ~= nil then


                    local nameA =
                        GetEconomicPlayerName(
                            game,
                            playerA
                        );


                    local nameB =
                        GetEconomicPlayerName(
                            game,
                            playerB
                        );


                    local message =
                        "The Non-Aggression Pact between " ..
                        nameA ..
                        " and " ..
                        nameB ..
                        " has expired.";


                    AddDiplomacyHistory(
                        data,
                        "nap_expired",
                        playerA,
                        playerB,
                        message,
                        {

                            endedTurn =
                                currentTurn
                        }
                    );


                    AddEconomyWorldEvent(
                        data.globalEconomy,
                        "nap_expired",
                        playerA,
                        message,
                        {

                            otherPlayerID =
                                playerB
                        }
                    );

                end

            end

        end

    end

end


-- =========================================================
-- CLEAN INVALID DIPLOMACY OFFERS
-- =========================================================

function CleanupDiplomacyOffers(
    game,
    data
)

    local diplomacy =
        GetDiplomacyData(
            data
        );


    for i =
        #diplomacy.pendingPeaceOffers,
        1,
        -1 do


        local offer =
            diplomacy.pendingPeaceOffers[
                i
            ];


        if offer.fromPlayerID == nil
            or offer.toPlayerID == nil
            or not IsPlayerAvailable(
                game,
                offer.fromPlayerID
            )
            or not IsPlayerAvailable(
                game,
                offer.toPlayerID
            )
            or not IsDiplomacyWar(
                data,
                offer.fromPlayerID,
                offer.toPlayerID
            ) then


            table.remove(
                diplomacy.pendingPeaceOffers,
                i
            );
        end
    end


    for i =
        #diplomacy.pendingNAPOffers,
        1,
        -1 do


        local offer =
            diplomacy.pendingNAPOffers[
                i
            ];


        if offer.fromPlayerID == nil
            or offer.toPlayerID == nil
            or not IsPlayerAvailable(
                game,
                offer.fromPlayerID
            )
            or not IsPlayerAvailable(
                game,
                offer.toPlayerID
            )
            or IsDiplomacyWar(
                data,
                offer.fromPlayerID,
                offer.toPlayerID
            ) then


            table.remove(
                diplomacy.pendingNAPOffers,
                i
            );
        end
    end


for i =
    #diplomacy.pendingAllianceOffers,
    1,
    -1 do

    local offer =
        diplomacy.pendingAllianceOffers[
            i
        ];


    if offer.fromPlayerID == nil
        or offer.toPlayerID == nil
        or not IsPlayerAvailable(
            game,
            offer.fromPlayerID
        )
        or not IsPlayerAvailable(
            game,
            offer.toPlayerID
        )
        or IsDiplomacyWar(
            data,
            offer.fromPlayerID,
            offer.toPlayerID
        )
        or GetActiveAlliance(
            data,
            offer.fromPlayerID,
            offer.toPlayerID
        ) ~= nil then

        table.remove(
            diplomacy.pendingAllianceOffers,
            i
        );

    end

end
end

-- =========================================================
-- DIPLOMACY TURN PROCESSOR
-- =========================================================

function ProcessDiplomacyTurn(
    game,
    data
)

    GetDiplomacyData(
        data
    );





    ProcessDiplomacyNAPExpirations(
        game,
        data
    );


    CleanupDiplomacyOffers(
        game,
        data
    );

end
-- =========================================================
-- GLOBAL ECONOMY FOUNDATION
-- =========================================================

function ProcessGlobalEconomyFoundation(
    game,
    data
)

    local economy =
        EnsureGlobalEconomyData(
            data
        );


    economy.currentEconomyTurn =
        data.tradeTurn
        or economy.currentEconomyTurn
        or 1;


    UpdateEconomyNationActivity(
        game,
        data
    );


    -- AI players cannot use the human Turn 1 setup UI.

    EnsureAINationalSetups(
        game,
        data
    );


    ProcessEconomicReforms(
        game,
        data
    );


    -- Diplomacy is processed only after nation activity
    -- and AI setup are current for this turn.

    ProcessDiplomacyTurn(
        game,
        data
    );

end


-- =========================================================
-- HISTORY
-- =========================================================

function AddTradeHistory(
    data,
    eventType,
    message,
    player1,
    player2,
    aiActivity
)

    table.insert(
        data.tradeHistory,
        {

            turn =
                data.tradeTurn,

            type =
                eventType,

            message =
                message,

            player1 =
                player1,

            player2 =
                player2,

            aiActivity =
                aiActivity
                or false
        }
    );


    while #data.tradeHistory
        > MAX_TRADE_HISTORY do


        table.remove(
            data.tradeHistory,
            1
        );
    end

end


function AddInvestmentHistory(
    data,
    eventType,
    message,
    projectID,
    playerID,
    aiActivity
)

    table.insert(
        data.investmentHistory,
        {

            turn =
                data.tradeTurn,

            type =
                eventType,

            message =
                message,

            projectID =
                projectID,

            playerID =
                playerID,

            aiActivity =
                aiActivity
                or false
        }
    );


    while #data.investmentHistory
        > MAX_INVESTMENT_HISTORY do


        table.remove(
            data.investmentHistory,
            1
        );
    end

end


-- =========================================================
-- COMMERCE INCOME
-- =========================================================
-- Cache Income() once per player per advance turn. Several AI systems ask for
-- the same value repeatedly, which becomes expensive in large/Mega Games.

local TURN_COMMERCE_INCOME_CACHE = {};

function GetCommerceIncome(game, playerID)
    if TURN_COMMERCE_INCOME_CACHE[playerID] ~= nil then
        return TURN_COMMERCE_INCOME_CACHE[playerID];
    end

    local player = GetEconomicPlayer(game, playerID);
    if player == nil then
        TURN_COMMERCE_INCOME_CACHE[playerID] = 0;
        return 0;
    end

    local standing = game.ServerGame and game.ServerGame.LatestTurnStanding;
    if standing == nil then
        TURN_COMMERCE_INCOME_CACHE[playerID] = 0;
        return 0;
    end

    local info = player.Income(0, standing, true, false);
    local total = info ~= nil and (info.Total or 0) or 0;
    TURN_COMMERCE_INCOME_CACHE[playerID] = total;
    return total;
end

function GetTaxCommerceModifierPercent(
    nation
)

    if nation == nil then
        return 0;
    end

    local taxPolicy =
        nation.taxPolicy
        or "Standard";

    if taxPolicy == "Low" then

        return -10;

    elseif taxPolicy == "High" then

        return 10;

    end

    return 0;

end

function GetIdeologyTaxCommerceModifierPercent(
    nation
)

    if nation == nil then
        return 0;
    end

    local ideology =
        nation.ideology
        or "Social Democratic";

    if ideology == "Free Market" then
        return -3;
    elseif ideology == "Capitalist" then
        return -2;
    elseif ideology == "Social Democratic" then
        return 2;
    elseif ideology == "State Capitalist" then
        return 4;
    elseif ideology == "Socialist" then
        return 5;
    elseif ideology == "Communist" then
        return 7;
    elseif ideology == "Fascist" then
        return 3;
    elseif ideology == "Nationalist" then
        return 2;
    end

    return 0;
end

function CalculateTaxCommerceAdjustment(
    game,
    playerID,
    nation
)

    local baseCommerce =
        GetCommerceIncome(
            game,
            playerID
        );

    if baseCommerce <= 0 then
        return 0;
    end

local taxModifierPercent =
    GetTaxCommerceModifierPercent(
        nation
    );

local ideologyModifierPercent =
    GetIdeologyTaxCommerceModifierPercent(
        nation
    );

local modifierPercent =
    taxModifierPercent
    + ideologyModifierPercent;

    if modifierPercent == 0 then
        return 0;
    end

local adjustment =
    baseCommerce
    * modifierPercent
    / 100;

if adjustment >= 0 then

    return math.floor(
        adjustment
        + 0.5
    );

end

return math.ceil(
    adjustment
    - 0.5
);

end

function GetTaxMarketModifierPercent(
    nation
)

    if nation == nil then
        return 0;
    end

    local taxPolicy =
        nation.taxPolicy
        or "Standard";

    if taxPolicy == "Low" then

        return 10;

    elseif taxPolicy == "High" then

        return -10;

    end

    return 0;

end

function GetIdeologyMarketModifierPercent(
    nation
)

    if nation == nil then
        return 0;
    end

    local ideology =
        nation.ideology
        or "Social Democratic";

    if ideology == "Free Market" then
        return 8;
    elseif ideology == "Capitalist" then
        return 6;
    elseif ideology == "Social Democratic" then
        return 2;
    elseif ideology == "State Capitalist" then
        return 1;
    elseif ideology == "Socialist" then
        return -5;
    elseif ideology == "Communist" then
        return -9;
    elseif ideology == "Fascist" then
        return -2;
    elseif ideology == "Nationalist" then
        return -1;
    end

    return 0;
end

function GetTaxInvestmentModifierPercent(
    nation
)

    if nation == nil then
        return 0;
    end

    local taxPolicy =
        nation.taxPolicy
        or "Standard";

    if taxPolicy == "Low" then

        return 10;

    elseif taxPolicy == "High" then

        return -10;

    end

    return 0;

end

function GetIdeologyInvestmentModifierPercent(
    nation
)

    if nation == nil then
        return 0;
    end

    local ideology =
        nation.ideology
        or "Social Democratic";

    if ideology == "Free Market" then
        return 6;
    elseif ideology == "Capitalist" then
        return 5;
    elseif ideology == "Social Democratic" then
        return 3;
    elseif ideology == "State Capitalist" then
        return 5;
    elseif ideology == "Socialist" then
        return 1;
    elseif ideology == "Communist" then
        return -2;
    elseif ideology == "Fascist" then
        return 1;
    elseif ideology == "Nationalist" then
        return 0;
    end

    return 0;
end

function GetTaxCompanyConfidenceModifier(
    nation
)

    if nation == nil then
        return 0;
    end

    local taxPolicy =
        nation.taxPolicy
        or "Standard";

    if taxPolicy == "Low" then

        return 5;

    elseif taxPolicy == "High" then

        return -5;

    end

    return 0;

end

function GetIdeologyCompanyConfidenceModifier(
    nation
)

    if nation == nil then
        return 0;
    end

    local ideology =
        nation.ideology
        or "Social Democratic";

    if ideology == "Free Market" then
        return 2;
    elseif ideology == "Capitalist" then
        return 3;
    elseif ideology == "Social Democratic" then
        return 2;
    elseif ideology == "State Capitalist" then
        return 4;
    elseif ideology == "Socialist" then
        return 1;
    elseif ideology == "Communist" then
        return 0;
    elseif ideology == "Fascist" then
        return 3;
    elseif ideology == "Nationalist" then
        return 2;
    end

    return 0;
end

function CalculateStartingStockPrice(
    game,
    playerID
)

    local income =
        GetCommerceIncome(
            game,
            playerID
        );

    local price =
        15
        + math.sqrt(
            math.max(
                income,
                0
            )
        ) * 2;

    if price < 10 then
        price = 10;
    end

    if price > 150 then
        price = 150;
    end

    return
        math.floor(
            price
            + 0.5
        );

end

function CalculateStockPriceChangePercent(
    company,
    ownerIncome
)

    local previousIncome =
        company.lastOwnerIncome
        or ownerIncome;

    local incomeChangePercent =
        0;

    if previousIncome > 0 then

        incomeChangePercent =
            (
                (
                    ownerIncome
                    - previousIncome
                )
                / previousIncome
            )
            * 100;

    end

    local fundamentalChange =
        math.max(
            -8,
            math.min(
                8,
                incomeChangePercent
                * 0.50
            )
        );

    local strategyMultiplier =
        1;

    if company.strategy
        == "Growth" then

        -- Growth companies retain more earnings and therefore receive a
        -- stronger capital-appreciation multiplier.
        strategyMultiplier =
            1.35;

    elseif company.strategy
        == "Dividend" then

        -- Dividend companies return more value as cash and should generally
        -- appreciate more slowly than Growth names.
        strategyMultiplier =
            0.45;

    end

    local volatility =
        company.volatility
        or 10;

    local randomScale = 0.25;
    if company.strategy == "Dividend" then
        randomScale = 0.15;
    elseif company.strategy == "Growth" then
        randomScale = 0.30;
    end

    local randomChange =
        math.random(
            -volatility,
            volatility
        )
        * randomScale;

    local buyVolume =
    company.buyVolumeThisTurn
    or 0;

local sellVolume =
    company.sellVolumeThisTurn
    or 0;

local totalShares =
    company.totalShares
    or 100;

local demandChange =
    0;

if totalShares > 0 then

    demandChange =
        (
            (
                buyVolume
                - sellVolume
            )
            / totalShares
        )
        * 25;

end

demandChange =
    math.max(
        -5,
        math.min(
            5,
            demandChange
        )
    );

local totalChange =
    (
        fundamentalChange
        * strategyMultiplier
    )
    + demandChange
    + randomChange;

    totalChange =
        math.max(
            -15,
            math.min(
                15,
                totalChange
            )
        );

    return totalChange;

end
function CalculateCompanyDividendPool(
    company,
    ownerIncome
)

    if ownerIncome <= 0 then
        return 0;
    end

    local payoutPercent =
        2;

    if company.strategy
        == "Growth" then

        payoutPercent =
            1;

    elseif company.strategy
        == "Dividend" then

        payoutPercent =
            4;

        -- Successful Dividend flagships reward holders primarily through
        -- rising distributions rather than Growth-style price acceleration.
        local growth = tonumber(company.ownerIncomeGrowthPercent) or 0;
        if growth >= 15 then
            payoutPercent = 6;
        elseif growth >= 5 then
            payoutPercent = 5;
        end

    end

    return
        math.floor(
            ownerIncome
            * (
                payoutPercent
                / 100
            )
            + 0.5
        );

end

function CalculateTradeBonus(
    partnerIncome
)

    local percent =
        GetTradeBonusPercent();


    return math.floor(
        (
            partnerIncome
            * (
                percent
                / 100
            )
        )
        + 0.5
    );

end


-- =========================================================
-- STORED GOLD / RESOURCE CHANGES
-- =========================================================

local TURN_STORED_GOLD_CACHE = {};

function GetStoredGold(game, playerID)
    if TURN_STORED_GOLD_CACHE[playerID] ~= nil then
        return TURN_STORED_GOLD_CACHE[playerID];
    end

    local standing = game.ServerGame and game.ServerGame.LatestTurnStanding;
    if standing == nil then
        TURN_STORED_GOLD_CACHE[playerID] = 0;
        return 0;
    end

    local gold = standing.NumResources(playerID, WL.ResourceType.Gold) or 0;
    TURN_STORED_GOLD_CACHE[playerID] = gold;
    return gold;
end


function GetPlannedResourceChange(
    changes,
    playerID
)

    return
        changes[
            playerID
        ]
        or 0;

end


function GetAvailableGold(
    game,
    changes,
    playerID
)

    return
        GetStoredGold(
            game,
            playerID
        )
        +
        GetPlannedResourceChange(
            changes,
            playerID
        );

end

function GetAIMarketSpendableGold(
    game,
    changes,
    playerID
)

    local availableGold =
        GetAvailableGold(
            game,
            changes,
            playerID
        );

    if availableGold <= 0 then
        return 0;
    end

local data =
    GetEconomicData();

local nation =
    EnsureEconomyNation(
        game,
        data,
        playerID
    );

local reservePercent =
    40;

if nation ~= nil then

    reservePercent =
        nation.aiDynamicReservePercent
        or GetSetting(
            "AIBaseReservePercent",
            40
        );

end

reservePercent =
    math.max(
        0,
        math.min(
            90,
            reservePercent
        )
    );

-- Protect the AI nation's strategic Commerce reserve.
local protectedReserve =
    math.floor(
        availableGold
        * reservePercent
        / 100
    );

    local spendableGold =
        availableGold
        - protectedReserve;

    -- Markets may use up to 40% of remaining Commerce.
    -- The 50% reserve above still prevents overspending.
    local marketLimit =
        math.floor(
            availableGold
            * 0.40
        );

    if spendableGold > marketLimit then
        spendableGold =
            marketLimit;
    end

    -- Very poor AI nations should stay out of Markets.
    if availableGold < 50 then
        return 0;
    end

    return math.max(
        0,
        spendableGold
    );

end

function CalculateAIStockScore(
    company,
    nation
)

    if company == nil
        or company.active == false
        or company.delisted == true
        or company.status ~= "trading" then

        return -100;

    end

    local score = 30;

    local currentPrice =
        company.currentPrice
        or company.startingPrice
        or 1;

    local previousPrice =
        company.previousPrice
        or currentPrice;

    if previousPrice > 0 then

        local changePercent =
            (
                currentPrice
                - previousPrice
            )
            / previousPrice
            * 100;

        if changePercent >= 1
            and changePercent <= 8 then

            score =
                score
                + 8;

        elseif changePercent > 8 then

            score =
                score
                - 4;

        elseif changePercent <= -3
            and changePercent >= -10 then

            score =
                score
                + 5;

        elseif changePercent < -10 then

            score =
                score
                - 10;

        end

    end

    local confidence =
        company.confidence
        or 50;

    score =
        score
        + (
            confidence
            - 50
        ) * 0.20;

    if company.strategy == "Dividend" then

        score =
            score
            + 4;

    elseif company.strategy == "Growth" then

        score =
            score
            + 3;

    end

if nation ~= nil then

    local aiProfile =
        nation.aiProfile
        or "Balanced";

    local ideology =
        nation.ideology
        or "Social Democratic";


    -- =========================================
    -- AI INVESTMENT PROFILE
    -- =========================================

    if aiProfile == "Growth" then

        if company.strategy == "Growth" then

            score =
                score
                + 8;

        elseif company.strategy == "Dividend" then

            score =
                score
                - 3;

        end


    elseif aiProfile == "Investor" then

        if company.strategy == "Balanced" then

            score =
                score
                + 6;

        elseif company.strategy == "Growth" then

            score =
                score
                + 4;

        elseif company.strategy == "Dividend" then

            score =
                score
                + 2;

        end


    elseif aiProfile == "Balanced" then

        if company.strategy == "Balanced" then

            score =
                score
                + 5;

        elseif company.strategy == "Dividend" then

            score =
                score
                + 4;

        elseif company.strategy == "Growth" then

            score =
                score
                + 2;

        end


    elseif aiProfile == "Planner" then

        if company.strategy == "Balanced" then

            score =
                score
                + 6;

        end

        if nation.flagshipCompanyID
            == company.id then

            score =
                score
                + 6;

        end


    elseif aiProfile == "Conservative" then

        if company.strategy == "Dividend" then

            score =
                score
                + 8;

        elseif company.strategy == "Growth" then

            score =
                score
                - 4;

        end

        if confidence < 45 then

            score =
                score
                - 8;

        end

    end


    -- =========================================
    -- IDEOLOGY MARKET PREFERENCE
    -- =========================================

    if ideology == "Free Market" then

        if company.strategy == "Growth" then

            score =
                score
                + 5;

        end


    elseif ideology == "Capitalist" then

        if company.strategy == "Growth" then

            score =
                score
                + 4;

        elseif company.strategy == "Balanced" then

            score =
                score
                + 3;

        end


    elseif ideology == "Social Democratic" then

        if company.strategy == "Dividend" then

            score =
                score
                + 4;

        elseif company.strategy == "Balanced" then

            score =
                score
                + 3;

        end


    elseif ideology == "State Capitalist" then

        if nation.flagshipCompanyID
            == company.id then

            score =
                score
                + 5;

        end


    elseif ideology == "Socialist" then

        if company.strategy == "Dividend" then

            score =
                score
                + 5;

        elseif company.strategy == "Growth" then

            score =
                score
                - 3;

        end

    elseif ideology == "Communist" then

        if nation.flagshipCompanyID == company.id then
            score = score + 5;
        else
            score = score - 5;
        end

    elseif ideology == "Fascist" then

        if nation.flagshipCompanyID == company.id then
            score = score + 6;
        elseif company.strategy == "Balanced" then
            score = score + 2;
        end

    elseif ideology == "Nationalist" then

        if nation.flagshipCompanyID == company.id then
            score = score + 7;
        elseif company.strategy == "Growth" then
            score = score - 1;
        end

    end

end


    local availableShares =
        company.sharesAvailable
        or 0;

    if availableShares <= 0 then

        score =
            score
            - 100;

    end

    return score;

end

function ChooseAIStockToBuy(
    economy,
    nation,
    spendableGold
)

    if economy == nil
        or economy.market == nil
        or economy.market.companies == nil
        or spendableGold <= 0 then

        return nil;
    end

    local bestCompany =
        nil;

    local bestScore =
        -999;

    for companyID,company in pairs(
        economy.market.companies
    ) do
local score =
    CalculateAIStockScore(
        company,
        nation
    );

        local ownedShares =
            (
                nation.stockHoldings
                and nation.stockHoldings[
                    companyID
                ]
            )
            or 0;

        local totalShares =
            company.totalShares
            or 100;

        if totalShares > 0 then

            local ownershipPercent =
                (
                    ownedShares
                    / totalShares
                )
                * 100;

            if ownershipPercent >= 15 then

                score =
                    score
                    - 20;

            elseif ownershipPercent >= 10 then

                score =
                    score
                    - 10;

            end

        end

        local price =
            company.currentPrice
            or company.startingPrice
            or 1;

        if price > spendableGold then

            score =
                score
                - 100;

        end

        if score > bestScore then

            bestScore =
                score;

            bestCompany =
                company;

        end

    end

    if bestScore < 20 then
        return nil;
    end

    return bestCompany;

end

function ProcessAIMarketBuying(
    game,
    data,
    changes,
    playerID
)

    local economy =
        data.globalEconomy;

    if economy == nil
        or economy.market == nil
        or economy.market.companies == nil then

        return;
    end

    local nation =
        EnsureEconomyNation(
            game,
            data,
            playerID
        );

    if nation == nil then
        return;
    end

    local strategicState =
    nation.aiStrategicState
    or "stable";

    nation.stockHoldings =
        nation.stockHoldings
        or {};

    nation.stockCostBasis =
        nation.stockCostBasis
        or {};

    local currentTurn =
    economy.currentEconomyTurn
    or data.tradeTurn
    or 1;

local lastTradeTurn =
    nation.lastAIMarketTradeTurn
    or -999;

if currentTurn
    - lastTradeTurn
    < 2 then

    return;
end

    local spendableGold =
        GetAIMarketSpendableGold(
            game,
            changes,
            playerID
        );

    if spendableGold <= 0 then
        return;
    end

    if nation.aiManagerEnabled == true then

        spendableGold =
            math.min(
                spendableGold,
                nation.aiManagerBudgetRemaining
                or 0
            );

        if spendableGold <= 0 then
            return;
        end

    end

    if strategicState == "recovery"
    or strategicState == "strained" then

    return;

end

if strategicState == "war" then

    spendableGold =
        math.floor(
            spendableGold
            * 0.35
        );

elseif strategicState == "threatened" then

    spendableGold =
        math.floor(
            spendableGold
            * 0.60
        );

elseif strategicState == "expansion" then

    spendableGold =
        math.floor(
            spendableGold
            * 1.15
        );

end

    local company =
        ChooseAIStockToBuy(
            economy,
            nation,
            spendableGold
        );

    if company == nil then
        return;
    end

    local price =
        company.currentPrice
        or company.startingPrice
        or 1;

    if price <= 0 then
        return;
    end

    local maxSharesByGold =
        math.floor(
            spendableGold
            / price
        );

    local availableShares =
        company.sharesAvailable
        or 0;

    local sharesToBuy =
        math.min(
            maxSharesByGold,
            availableShares,
            3
        );

    if sharesToBuy <= 0 then
        return;
    end

    local totalCost =
        sharesToBuy
        * price;

    AddResourceChange(
        changes,
        playerID,
        -totalCost
    );

    if nation.aiManagerEnabled == true then

        nation.aiManagerBudgetRemaining =
            math.max(
                0,
                (
                    nation.aiManagerBudgetRemaining
                    or 0
                )
                - totalCost
            );

    end

    nation.stockHoldings[
        company.id
    ] =
        (
            nation.stockHoldings[
                company.id
            ]
            or 0
        )
        + sharesToBuy;

    nation.stockCostBasis[
        company.id
    ] =
        (
            nation.stockCostBasis[
                company.id
            ]
            or 0
        )
        + totalCost;

local primarySharesRemaining =
    company.primarySharesRemaining
    or 0;

local primarySharesSold =
    math.min(
        sharesToBuy,
        primarySharesRemaining
    );

if primarySharesSold > 0 then

    company.primarySharesRemaining =
        math.max(
            0,
            primarySharesRemaining
            - primarySharesSold
        );

    local founderPlayerID =
        company.founderPlayerID;

local founderProceedsPercent =
    85;

if company.strategy == "Growth" then

    founderProceedsPercent =
        100;

elseif company.strategy == "Dividend" then

    founderProceedsPercent =
        70;

end

local founderProceeds =
    math.floor(
        (
            primarySharesSold
            * price
            * founderProceedsPercent
            / 100
        )
        + 0.5
    );

    if founderPlayerID ~= nil
        and founderPlayerID ~= playerID then

AddResourceChange(
    changes,
    founderPlayerID,
    founderProceeds
);

    end

end

    company.sharesAvailable =
        availableShares
        - sharesToBuy;

    company.buyVolumeThisTurn =
        (
            company.buyVolumeThisTurn
            or 0
        )
        + sharesToBuy;

        nation.lastAIMarketTradeTurn =
    currentTurn;
end

function ProcessAIMarketSelling(
    game,
    data,
    changes,
    playerID
)

    local economy =
        data.globalEconomy;

    if economy == nil
        or economy.market == nil
        or economy.market.companies == nil then

        return;
    end

    local nation =
        EnsureEconomyNation(
            game,
            data,
            playerID
        );

    if nation == nil
        or nation.stockHoldings == nil then

        return;
    end

    nation.stockCostBasis =
        nation.stockCostBasis
        or {};

    nation.realizedStockProfit =
        nation.realizedStockProfit
        or 0;

    local currentTurn =
        economy.currentEconomyTurn
        or data.tradeTurn
        or 1;

    local lastTradeTurn =
        nation.lastAIMarketTradeTurn
        or -999;

    if currentTurn
        - lastTradeTurn
        < 2 then

        return;
    end

    local worstCompany =
        nil;

    local worstCompanyID =
        nil;

    local worstScore =
        999;

    local worstSellableShares =
        0;

    for companyID,ownedShares in pairs(
        nation.stockHoldings
    ) do

        local company =
            economy.market.companies[
                companyID
            ];

        if company ~= nil
            and ownedShares > 0
            and company.active ~= false
            and company.delisted ~= true then

            local protectedFounderShares =
                0;

            if company.founderPlayerID
                == playerID then

                protectedFounderShares =
                    company.founderShares
                    or 0;

            end

            local sellableShares =
                math.max(
                    0,
                    ownedShares
                    - protectedFounderShares
                );

            if sellableShares > 0 then

                local score =
                    30;

                local currentPrice =
                    company.currentPrice
                    or company.startingPrice
                    or 1;

                local previousPrice =
                    company.previousPrice
                    or currentPrice;

                if previousPrice > 0 then

                    local changePercent =
                        (
                            currentPrice
                            - previousPrice
                        )
                        / previousPrice
                        * 100;

                    if changePercent <= -10 then

                        score =
                            score
                            - 20;

                    elseif changePercent <= -5 then

                        score =
                            score
                            - 10;

                    elseif changePercent >= 5 then

                        score =
                            score
                            + 5;

                    end

                end

                local confidence =
                    company.confidence
                    or 50;

                score =
                    score
                    + (
                        confidence
                        - 50
                    ) * 0.20;

                    local aiProfile =
    nation.aiProfile
    or "Balanced";

local ideology =
    nation.ideology
    or "Social Democratic";


-- =========================================
-- AI SELLING PROFILE
-- Higher score = AI is more willing to hold
-- Lower score = AI is more willing to sell
-- =========================================

if aiProfile == "Growth" then

    if company.strategy == "Growth" then

        score =
            score
            + 6;

    elseif company.strategy == "Dividend" then

        score =
            score
            - 2;

    end


elseif aiProfile == "Investor" then

    if company.strategy == "Balanced" then

        score =
            score
            + 5;

    elseif company.strategy == "Growth" then

        score =
            score
            + 3;

    end


elseif aiProfile == "Balanced" then

    if company.strategy == "Balanced" then

        score =
            score
            + 4;

    elseif company.strategy == "Dividend" then

        score =
            score
            + 3;

    end


elseif aiProfile == "Planner" then

    if nation.flagshipCompanyID
        == company.id then

        score =
            score
            + 8;

    elseif company.strategy == "Balanced" then

        score =
            score
            + 4;

    end


elseif aiProfile == "Conservative" then

    if company.strategy == "Dividend" then

        score =
            score
            + 7;

    elseif company.strategy == "Growth" then

        score =
            score
            - 4;

    end

    if confidence < 45 then

        score =
            score
            - 6;

    end

end


-- =========================================
-- IDEOLOGY SELLING PREFERENCE
-- =========================================

if ideology == "Free Market" then

    if company.strategy == "Growth" then

        score =
            score
            + 4;

    end


elseif ideology == "Capitalist" then

    if company.strategy == "Growth"
        or company.strategy == "Balanced" then

        score =
            score
            + 3;

    end


elseif ideology == "Social Democratic" then

    if company.strategy == "Dividend"
        or company.strategy == "Balanced" then

        score =
            score
            + 3;

    end


elseif ideology == "State Capitalist" then

    if nation.flagshipCompanyID
        == company.id then

        score =
            score
            + 6;

    end


elseif ideology == "Socialist" then

    if company.strategy == "Dividend" then
        score = score + 4;
    elseif company.strategy == "Growth" then
        score = score - 3;
    end

elseif ideology == "Communist" then

    if nation.flagshipCompanyID == company.id then
        score = score + 6;
    else
        score = score - 4;
    end

elseif ideology == "Fascist" then

    if nation.flagshipCompanyID == company.id then
        score = score + 6;
    end

elseif ideology == "Nationalist" then

    if nation.flagshipCompanyID == company.id then
        score = score + 7;
    end

end

                if score < worstScore then

                    worstScore =
                        score;

                    worstCompany =
                        company;

                    worstCompanyID =
                        companyID;

                    worstSellableShares =
                        sellableShares;

                end

            end

        end

    end

    if worstCompany == nil
        or worstScore > 18 then

        return;
    end

    local sharesToSell =
        math.min(
            worstSellableShares,
            2
        );

    if sharesToSell <= 0 then
        return;
    end

    local price =
        worstCompany.currentPrice
        or worstCompany.startingPrice
        or 1;

    local totalValue =
        sharesToSell
        * price;

    local oldCostBasis =
        nation.stockCostBasis[
            worstCompanyID
        ]
        or 0;

    local costRemoved =
        0;

    if worstSellableShares > 0 then

        costRemoved =
            oldCostBasis
            * (
                sharesToSell
                / worstSellableShares
            );

    end

    nation.stockHoldings[
        worstCompanyID
    ] =
        nation.stockHoldings[
            worstCompanyID
        ]
        - sharesToSell;

    nation.stockCostBasis[
        worstCompanyID
    ] =
        math.max(
            0,
            oldCostBasis
            - costRemoved
        );

    nation.realizedStockProfit =
        nation.realizedStockProfit
        + (
            totalValue
            - costRemoved
        );

    worstCompany.sharesAvailable =
        (
            worstCompany.sharesAvailable
            or 0
        )
        + sharesToSell;

    worstCompany.sellVolumeThisTurn =
        (
            worstCompany.sellVolumeThisTurn
            or 0
        )
        + sharesToSell;

    AddResourceChange(
        changes,
        playerID,
        totalValue
    );

    nation.lastAIMarketTradeTurn =
        currentTurn;

end

function AddResourceChange(
    changes,
    playerID,
    amount
)

    if changes[
        playerID
    ] == nil then


        changes[
            playerID
        ] =
            0;
    end


    changes[
        playerID
    ] =
        changes[
            playerID
        ]
        + amount;

end
-- =========================================================
-- TRADE HELPERS
-- =========================================================

function TradePairKey(
    playerA,
    playerB
)

    local a =
        tostring(
            playerA
        );

    local b =
        tostring(
            playerB
        );


    if a < b then

        return
            a ..
            "|" ..
            b;

    else

        return
            b ..
            "|" ..
            a;
    end

end


function CountAgreements(
    data,
    playerID
)

    local count =
        0;


    for _, agreement
        in pairs(
            data.activeAgreements
        ) do


        if agreement.player1
            == playerID
            or agreement.player2
            == playerID then


            count =
                count
                + 1;
        end
    end


    return count;

end


function HasAgreement(
    data,
    playerA,
    playerB
)

    for _, agreement
        in pairs(
            data.activeAgreements
        ) do


        if
            (
                agreement.player1
                == playerA
                and
                agreement.player2
                == playerB
            )
            or
            (
                agreement.player1
                == playerB
                and
                agreement.player2
                == playerA
            )
        then


            return true;
        end
    end


    return false;

end


function HasPendingTrade(
    data,
    playerA,
    playerB
)

    for _, proposal
        in pairs(
            data.pendingProposals
        ) do


        if
            (
                proposal.fromPlayerID
                == playerA
                and
                proposal.toPlayerID
                == playerB
            )
            or
            (
                proposal.fromPlayerID
                == playerB
                and
                proposal.toPlayerID
                == playerA
            )
        then


            return true;
        end
    end


    return false;

end


function IsTradeCooldown(
    data,
    playerA,
    playerB
)

    local key =
        TradePairKey(
            playerA,
            playerB
        );


    local untilTurn =
        data.cooldowns[
            key
        ];


    if untilTurn == nil then

        return false;
    end


    return
        data.tradeTurn
        < untilTurn;

end


function StartTradeCooldown(
    data,
    playerA,
    playerB
)

    local key =
        TradePairKey(
            playerA,
            playerB
        );


    data.cooldowns[
        key
    ] =
        data.tradeTurn
        + GetTradeCooldownTurns();

end


-- =========================================================
-- TRADE ELIGIBILITY
-- =========================================================

function IsNationEconomyReady(
    game,
    data,
    playerID
)

    if not IsPlayerAvailable(
        game,
        playerID
    ) then


        return false;
    end


    local nation =
        EnsureEconomyNation(
            game,
            data,
            playerID
        );


    if nation.eliminated
        == true then


        return false;
    end


    if nation.setupComplete
        ~= true then


        return false;
    end


    return true;

end


function CanNationsTrade(
    game,
    data,
    playerA,
    playerB
)

    if playerA == nil
        or playerB == nil
        or playerA
        == playerB then


        return false;
    end


    if not IsNationEconomyReady(
        game,
        data,
        playerA
    )
    or not IsNationEconomyReady(
        game,
        data,
        playerB
    ) then


        return false;
    end


    if IsDiplomacyWar(
        data,
        playerA,
        playerB
    ) then


        return false;
    end


    return true;

end


-- =========================================================
-- TRADE CLEANUP
-- =========================================================

function CleanupTradeData(
    game,
    data
)

    -- =====================================================
    -- ACTIVE AGREEMENTS
    -- =====================================================

    for i =
        #data.activeAgreements,
        1,
        -1 do


        local agreement =
            data.activeAgreements[
                i
            ];


        local player1 =
            agreement.player1;


        local player2 =
            agreement.player2;


        local playerUnavailable =
            not IsPlayerAvailable(
                game,
                player1
            )
            or
            not IsPlayerAvailable(
                game,
                player2
            );


        local nationNotReady =
            false;


        if not playerUnavailable then


            nationNotReady =
                not IsNationEconomyReady(
                    game,
                    data,
                    player1
                )
                or
                not IsNationEconomyReady(
                    game,
                    data,
                    player2
                );
        end


        local atWar =
            false;


        if not playerUnavailable then


            atWar =
                IsDiplomacyWar(
                    data,
                    player1,
                    player2
                );
        end


        if playerUnavailable
            or nationNotReady
            or atWar then


            local name1 =
                GetEconomicPlayerName(
                    game,
                    player1
                );


            local name2 =
                GetEconomicPlayerName(
                    game,
                    player2
                );


            if atWar then


                AddTradeHistory(
                    data,
                    "agreement_ended_war",
                    name1 ..
                    " and " ..
                    name2 ..
                    " had their trade agreement terminated because they are at war.",
                    player1,
                    player2,
                    false
                );


            else


                AddTradeHistory(
                    data,
                    "agreement_ended",
                    name1 ..
                    " and " ..
                    name2 ..
                    " had their trade agreement ended because a nation was no longer economically active.",
                    player1,
                    player2,
                    false
                );
            end


            table.remove(
                data.activeAgreements,
                i
            );
        end
    end


    -- =====================================================
    -- PENDING TRADE PROPOSALS
    -- =====================================================

    for i =
        #data.pendingProposals,
        1,
        -1 do


        local proposal =
            data.pendingProposals[
                i
            ];


        local fromPlayerID =
            proposal.fromPlayerID;


        local toPlayerID =
            proposal.toPlayerID;


        local removeProposal =
            false;


        if fromPlayerID == nil
            or toPlayerID == nil then


            removeProposal =
                true;


        elseif not IsPlayerAvailable(
            game,
            fromPlayerID
        )
        or not IsPlayerAvailable(
            game,
            toPlayerID
        ) then


            removeProposal =
                true;


        elseif not IsNationEconomyReady(
            game,
            data,
            fromPlayerID
        )
        or not IsNationEconomyReady(
            game,
            data,
            toPlayerID
        ) then


            removeProposal =
                true;


        elseif IsDiplomacyWar(
            data,
            fromPlayerID,
            toPlayerID
        ) then


            removeProposal =
                true;
        end


        if removeProposal then


            table.remove(
                data.pendingProposals,
                i
            );
        end
    end


    -- =====================================================
    -- EXPIRED TRADE COOLDOWNS
    -- =====================================================

    for key, untilTurn
        in pairs(
            data.cooldowns
        ) do


        if data.tradeTurn
            >= untilTurn then


            data.cooldowns[
                key
            ] =
                nil;
        end
    end

end
-- =========================================================
-- AI ECONOMIC MEMORY
-- =========================================================

function GetAITradeMemory(
    data,
    aiPlayerID,
    partnerID
)

    if data.aiTradeMemory[
        aiPlayerID
    ] == nil then


        data.aiTradeMemory[
            aiPlayerID
        ] =
            {};
    end


    if data.aiTradeMemory[
        aiPlayerID
    ][
        partnerID
    ] == nil then


        data.aiTradeMemory[
            aiPlayerID
        ][
            partnerID
        ] =
        {

            lastIncome =
                nil,

            declineStreak =
                0,

            concernLogged =
                false
        };
    end


    return data.aiTradeMemory[
        aiPlayerID
    ][
        partnerID
    ];

end


function UpdateAITradeMemory(
    game,
    data
)

    local declineThreshold =
        GetEconomicDeclineTurns();


    for _, agreement
        in pairs(
            data.activeAgreements
        ) do


        local pairsToCheck =
        {

            {

                aiID =
                    agreement.player1,

                partnerID =
                    agreement.player2
            },

            {

                aiID =
                    agreement.player2,

                partnerID =
                    agreement.player1
            }
        };


        for _, pair
            in ipairs(
                pairsToCheck
            ) do


            local aiPlayer =
                GetEconomicPlayer(
                    game,
                    pair.aiID
                );


            if aiPlayer ~= nil
                and aiPlayer.IsAI
                and CanNationsTrade(
                    game,
                    data,
                    pair.aiID,
                    pair.partnerID
                ) then


                local income =
                    GetCommerceIncome(
                        game,
                        pair.partnerID
                    );


                local memory =
                    GetAITradeMemory(
                        data,
                        pair.aiID,
                        pair.partnerID
                    );


                if memory.lastIncome
                    ~= nil then


                    if income
                        < memory.lastIncome then


                        memory.declineStreak =
                            memory.declineStreak
                            + 1;


                    elseif income
                        > memory.lastIncome then


                        memory.declineStreak =
                            math.max(
                                0,
                                memory.declineStreak
                                - 1
                            );


                        if memory.declineStreak
                            < declineThreshold then


                            memory.concernLogged =
                                false;
                        end

                    end

                end


                memory.lastIncome =
                    income;


                -- Log concern only once,
                -- not every turn.

                if memory.declineStreak
                    >= declineThreshold

                    and not memory.concernLogged then


                    local aiName =
                        GetEconomicPlayerName(
                            game,
                            pair.aiID
                        );


                    local partnerName =
                        GetEconomicPlayerName(
                            game,
                            pair.partnerID
                        );


                    AddTradeHistory(
                        data,
                        "ai_concern",
                        aiName ..
                        " has become concerned about the declining economy of trade partner " ..
                        partnerName ..
                        ".",
                        pair.aiID,
                        pair.partnerID,
                        true
                    );


                    memory.concernLogged =
                        true;

                end

            end

        end

    end

end


function GetPartnerDeclineStreak(
    data,
    aiPlayerID,
    partnerID
)

    if data.aiTradeMemory[
        aiPlayerID
    ] == nil then


        return 0;
    end


    local memory =
        data.aiTradeMemory[
            aiPlayerID
        ][
            partnerID
        ];


    if memory == nil then

        return 0;
    end


    return memory.declineStreak
        or 0;

end


-- =========================================================
-- AI TRADE ACCEPTANCE
-- =========================================================

function AIWouldAcceptTrade(
    game,
    data,
    aiPlayerID,
    proposerID
)

    -- AI cannot trade with nations that are
    -- economically inactive or officially at war.

    if not CanNationsTrade(
        game,
        data,
        aiPlayerID,
        proposerID
    ) then


        return false;
    end


    if CountAgreements(
        data,
        aiPlayerID
    ) >= GetMaxAgreements() then


        return false;
    end


    local aiIncome =
        GetCommerceIncome(
            game,
            aiPlayerID
        );


    local proposerIncome =
        GetCommerceIncome(
            game,
            proposerID
        );


    local chance =
        50;


    if proposerIncome
        >= aiIncome * 1.75 then


        chance =
            chance + 30;


    elseif proposerIncome
        >= aiIncome * 1.25 then


        chance =
            chance + 20;


    elseif proposerIncome
        >= aiIncome * 0.80 then


        chance =
            chance + 10;


    elseif proposerIncome
        < aiIncome * 0.50 then


        chance =
            chance - 20;


    elseif proposerIncome
        < aiIncome * 0.75 then


        chance =
            chance - 10;
    end


    local existing =
        CountAgreements(
            data,
            aiPlayerID
        );


    chance =
        chance
        - (
            existing * 8
        );


    if chance < 10 then

        chance =
            10;
    end


    if chance > 95 then

        chance =
            95;
    end


    return
        math.random(
            1,
            100
        )
        <= chance;

end


-- =========================================================
-- FIND BEST TRADE CANDIDATE
-- =========================================================

function FindBestTradeCandidate(
    game,
    data,
    aiPlayerID
)

    local bestID =
        nil;


    local bestIncome =
        -1;


    for playerID, _
        in pairs(
            game.Game.Players
        ) do


        if playerID
            ~= aiPlayerID

            and CanNationsTrade(
                game,
                data,
                aiPlayerID,
                playerID
            )

            and CountAgreements(
                data,
                playerID
            )
            < GetMaxAgreements()

            and not HasAgreement(
                data,
                aiPlayerID,
                playerID
            )

            and not HasPendingTrade(
                data,
                aiPlayerID,
                playerID
            )

            and not IsTradeCooldown(
                data,
                aiPlayerID,
                playerID
            )
        then


            local income =
                GetCommerceIncome(
                    game,
                    playerID
                );


            if income
                > bestIncome then


                bestIncome =
                    income;


                bestID =
                    playerID;
            end

        end

    end


    return
        bestID,
        bestIncome;

end


-- =========================================================
-- FIND REPLACEABLE AGREEMENT
-- =========================================================

function FindAIWeakestReplaceableAgreement(
    game,
    data,
    aiPlayerID
)

    local weakestIndex =
        nil;


    local weakestPartnerID =
        nil;


    local weakestScore =
        nil;


    local weakestActualIncome =
        nil;


    local minimumAge =
        GetAIMinimumAgreementTurns();


    local declineThreshold =
        GetEconomicDeclineTurns();


    for index, agreement
        in ipairs(
            data.activeAgreements
        ) do


        local partnerID =
            nil;


        if agreement.player1
            == aiPlayerID then


            partnerID =
                agreement.player2;


        elseif agreement.player2
            == aiPlayerID then


            partnerID =
                agreement.player1;
        end


        if partnerID ~= nil
            and CanNationsTrade(
                game,
                data,
                aiPlayerID,
                partnerID
            ) then


            local startedTurn =
                agreement.startedTurn
                or data.tradeTurn;


            local agreementAge =
                data.tradeTurn
                - startedTurn;


            -- AI doesn't churn newly signed deals.

            if agreementAge
                >= minimumAge then


                local income =
                    GetCommerceIncome(
                        game,
                        partnerID
                    );


                local score =
                    income;


                local declineStreak =
                    GetPartnerDeclineStreak(
                        data,
                        aiPlayerID,
                        partnerID
                    );


                -- Sustained decline makes the partner
                -- look economically weaker to the AI.

                if declineStreak
                    >= declineThreshold then


                    score =
                        score * 0.75;
                end


                if weakestScore == nil
                    or score
                    < weakestScore then


                    weakestScore =
                        score;


                    weakestActualIncome =
                        income;


                    weakestIndex =
                        index;


                    weakestPartnerID =
                        partnerID;
                end

            end

        end

    end


    return
        weakestIndex,
        weakestPartnerID,
        weakestScore,
        weakestActualIncome;

end


-- =========================================================
-- AI PARTNER REPLACEMENT
-- =========================================================

function AIConsiderTradeReplacement(
    game,
    data,
    aiPlayerID
)

    if not IsNationEconomyReady(
        game,
        data,
        aiPlayerID
    ) then


        return;
    end


    if CountAgreements(
        data,
        aiPlayerID
    ) < GetMaxAgreements() then


        return;
    end


    local bestID,
        bestIncome =
        FindBestTradeCandidate(
            game,
            data,
            aiPlayerID
        );


    if bestID == nil then

        return;
    end


    local weakestIndex,
        weakestPartner,
        weakestScore,
        weakestActualIncome =
        FindAIWeakestReplaceableAgreement(
            game,
            data,
            aiPlayerID
        );


    if weakestIndex == nil
        or weakestScore == nil then


        return;
    end


    local requiredImprovement =
        1
        + (
            GetAIReplacementPercent()
            / 100
        );


    if bestIncome
        >= weakestScore
        * requiredImprovement then


        local aiName =
            GetEconomicPlayerName(
                game,
                aiPlayerID
            );


        local oldName =
            GetEconomicPlayerName(
                game,
                weakestPartner
            );


        local newName =
            GetEconomicPlayerName(
                game,
                bestID
            );


        table.remove(
            data.activeAgreements,
            weakestIndex
        );


        StartTradeCooldown(
            data,
            aiPlayerID,
            weakestPartner
        );


        AddTradeHistory(
            data,
            "agreement_replaced",
            aiName ..
            " ended its trade agreement with " ..
            oldName ..
            " after identifying a stronger economic opportunity with " ..
            newName ..
            ".",
            aiPlayerID,
            weakestPartner,
            true
        );
    end

end


-- =========================================================
-- AI TRADE PROPOSALS
-- =========================================================

function AIConsiderTradeProposal(
    game,
    data,
    aiPlayerID
)

    if not IsNationEconomyReady(
        game,
        data,
        aiPlayerID
    ) then


        return;
    end


    if CountAgreements(
        data,
        aiPlayerID
    ) >= GetMaxAgreements() then


        return;
    end


    if math.random(
        1,
        100
    ) > GetAIProposalChance() then


        return;
    end


    local targetID =
        FindBestTradeCandidate(
            game,
            data,
            aiPlayerID
        );


    if targetID == nil then

        return;
    end


    -- Recheck immediately before creating the agreement
    -- or proposal in case diplomacy state changed.

    if not CanNationsTrade(
        game,
        data,
        aiPlayerID,
        targetID
    ) then


        return;
    end


    local target =
        GetEconomicPlayer(
            game,
            targetID
        );


    if target == nil then

        return;
    end


    local aiName =
        GetEconomicPlayerName(
            game,
            aiPlayerID
        );


    local targetName =
        GetEconomicPlayerName(
            game,
            targetID
        );


    -- =====================================================
    -- AI -> AI
    -- =====================================================

    if target.IsAI then


        if AIWouldAcceptTrade(
            game,
            data,
            targetID,
            aiPlayerID
        ) then


            table.insert(
                data.activeAgreements,
                {

                    player1 =
                        aiPlayerID,

                    player2 =
                        targetID,

                    startedTurn =
                        data.tradeTurn
                }
            );


            AddTradeHistory(
                data,
                "agreement_signed",
                aiName ..
                " and " ..
                targetName ..
                " signed a trade agreement.",
                aiPlayerID,
                targetID,
                true
            );


        else


            StartTradeCooldown(
                data,
                aiPlayerID,
                targetID
            );


            AddTradeHistory(
                data,
                "proposal_rejected",
                targetName ..
                " rejected a trade proposal from " ..
                aiName ..
                ".",
                aiPlayerID,
                targetID,
                true
            );
        end


    -- =====================================================
    -- AI -> HUMAN
    -- =====================================================

    else


        table.insert(
            data.pendingProposals,
            {

                fromPlayerID =
                    aiPlayerID,

                toPlayerID =
                    targetID,

                createdTurn =
                    data.tradeTurn
            }
        );


        AddTradeHistory(
            data,
            "proposal_sent",
            aiName ..
            " sent a trade proposal to " ..
            targetName ..
            ".",
            aiPlayerID,
            targetID,
            true
        );
    end

end
-- =========================================================
-- INVESTMENT HELPERS
-- =========================================================

function CountOutsideInvestors(
    project
)

    local count =
        0;


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


function FindInvestmentByPlayer(
    project,
    playerID
)

    for _, investment
        in pairs(
            project.investments
            or {}
        ) do


        if investment.playerID
            == playerID then


            return investment;
        end
    end


    return nil;

end


function AIHasOpenProject(
    data,
    aiPlayerID
)

    for _, project
        in pairs(
            data.investmentProjects
        ) do


        if project.creatorID
            == aiPlayerID

            and
            (
                project.status
                == "funding"

                or

                project.status
                == "active"
            )
        then


            return true;
        end
    end


    return false;

end


-- =========================================================
-- AI CHOOSES PROJECT TYPE
-- =========================================================

function AIChooseInvestmentType(
    availableGold
)

    local eligible =
        {};


    for _, typeID
        in ipairs(
            INVESTMENT_TYPE_ORDER
        ) do


        local projectType =
            INVESTMENT_TYPES[
                typeID
            ];


        -- AI must be capable of funding
        -- at least 20% of a 200-gold project.

        if availableGold >= 40 then


            table.insert(
                eligible,
                projectType
            );
        end
    end


    if #eligible == 0 then

        return nil;
    end


    -- Richer nations are somewhat more willing
    -- to use the high-risk categories.

    local maximumIndex =
        #eligible;


    if availableGold < 150 then


        maximumIndex =
            math.min(
                maximumIndex,
                2
            );


    elseif availableGold < 300 then


        maximumIndex =
            math.min(
                maximumIndex,
                4
            );


    elseif availableGold < 500 then


        maximumIndex =
            math.min(
                maximumIndex,
                6
            );
    end


    return eligible[
        math.random(
            1,
            maximumIndex
        )
    ];

end


-- =========================================================
-- AI PROJECT CREATION
-- =========================================================

function AIConsiderProjectCreation(
    game,
    data,
    aiPlayerID,
    resourceChanges
)

    if not GetAIProjectsEnabled() then

        return;
    end


    if not IsNationEconomyReady(
        game,
        data,
        aiPlayerID
    ) then


        return;
    end


    local nation =
        EnsureEconomyNation(
            game,
            data,
            aiPlayerID
        );

    local managedHuman =
        nation ~= nil
        and nation.isAI ~= true
        and nation.aiManagerEnabled == true;


    if AIHasOpenProject(
        data,
        aiPlayerID
    ) then

        return;
    end


    if not managedHuman
        and math.random(
            1,
            100
        ) > GetAIProjectChance() then

        return;
    end


    local currentGold =
        GetAvailableGold(
            game,
            resourceChanges,
            aiPlayerID
        );


    if currentGold < 100 then

        return;
    end


local strategicState =
    nation.aiStrategicState
    or "stable";

local reservePercent =
    GetSetting(
        "AIBaseReservePercent",
        40
    );

if nation ~= nil then

    reservePercent =
        nation.aiDynamicReservePercent
        or reservePercent;

end

reservePercent =
    math.max(
        0,
        math.min(
            90,
            reservePercent
        )
    );

local reserve =
    math.floor(
        currentGold
        * reservePercent
        / 100
    );

local spendable =
    currentGold
    - reserve;

if nation ~= nil
    and nation.aiManagerEnabled == true then

    spendable =
        math.min(
            spendable,
            nation.aiManagerBudgetRemaining
            or 0
        );

end

    if strategicState == "recovery"
    or strategicState == "strained"
    or strategicState == "war"
    or strategicState == "threatened" then

    return;

end

if strategicState == "expansion" then

    spendable =
        math.floor(
            spendable
            * 1.20
        );

end

    if spendable < 40 then

        return;
    end


    local projectType =
        AIChooseInvestmentType(
            spendable
        );


    if projectType == nil then

        return;
    end


    -- AI puts in 25% itself.
    -- Therefore fundingGoal cannot exceed 4x spendable.

    local maxAffordableGoal =
        spendable * 4;


    local fundingGoal =
        math.min(
            projectType.maxGoal,
            maxAffordableGoal
        );


    fundingGoal =
        math.floor(
            fundingGoal / 100
        )
        * 100;


    if fundingGoal < 200 then

        fundingGoal =
            200;
    end


    if fundingGoal
        > projectType.maxGoal then


        fundingGoal =
            projectType.maxGoal;
    end


    local creatorContribution =
        math.ceil(
            fundingGoal * 0.25
        );


    if creatorContribution
        > spendable then


        return;
    end


    local investorLimit =
        math.random(
            MIN_INVESTORS,
            MAX_INVESTORS
        );


    local projectID =
        data.nextInvestmentProjectID;


    data.nextInvestmentProjectID =
        projectID + 1;


    local project =
    {

        id =
            projectID,

        projectTypeID =
            projectType.id,

        projectName =
            projectType.name,

        creatorID =
            aiPlayerID,

        fundingGoal =
            fundingGoal,

        currentFunding =
            creatorContribution,

        creatorContribution =
            creatorContribution,

        investorLimit =
            investorLimit,

        investments =
        {

            {

                playerID =
                    aiPlayerID,

                amount =
                    creatorContribution,

                isCreator =
                    true
            }
        },

        risk =
            projectType.risk,

        duration =
            projectType.duration,

        successReturn =
            projectType.successReturn,

        failureRecovery =
            projectType.failureRecovery,

        successChance =
            projectType.successChance,

        status =
            "funding",

        createdTurn =
            data.tradeTurn,

        fundingDeadline =
            data.tradeTurn
            + FUNDING_WINDOW_TURNS,

        createdByAI =
            true
    };


    table.insert(
        data.investmentProjects,
        project
    );


    AddResourceChange(
        resourceChanges,
        aiPlayerID,
        -creatorContribution
    );

    if nation ~= nil
        and nation.aiManagerEnabled == true then

        nation.aiManagerBudgetRemaining =
            math.max(
                0,
                (
                    nation.aiManagerBudgetRemaining
                    or 0
                )
                - creatorContribution
            );

    end


    local aiName =
        GetEconomicPlayerName(
            game,
            aiPlayerID
        );


    local message =
        aiName ..
        " opened a " ..
        tostring(
            fundingGoal
        ) ..
        "-gold " ..
        projectType.name ..
        " investment project.";


    AddInvestmentHistory(
        data,
        "project_created",
        message,
        projectID,
        aiPlayerID,
        true
    );


    AddTradeHistory(
        data,
        "investment_created",
        message,
        aiPlayerID,
        nil,
        true
    );

end


-- =========================================================
-- PROJECT INVESTMENT SCORE
-- =========================================================

function CalculateProjectScore(
    project
)

    local successChance =
        (
            project.successChance
            or 0
        )
        / 100;


    local failureChance =
        1
        - successChance;


    local successMultiplier =
        1
        + (
            (
                project.successReturn
                or 0
            )
            / 100
        );


    local failureMultiplier =
        (
            project.failureRecovery
            or 0
        )
        / 100;


    local expectedMultiplier =
        (
            successChance
            * successMultiplier
        )
        +
        (
            failureChance
            * failureMultiplier
        );


    local expectedProfit =
        expectedMultiplier
        - 1;


    local duration =
        project.duration
        or 1;


    -- Reward expected value,
    -- penalize long lockups.

    return
        expectedProfit
        / duration;

end


-- =========================================================
-- AI INVESTS IN OPEN PROJECT
-- =========================================================

function AIConsiderInvestment(
    game,
    data,
    aiPlayerID,
    resourceChanges
)

    if not GetAIInvestmentsEnabled() then

        return;
    end


    if not IsNationEconomyReady(
        game,
        data,
        aiPlayerID
    ) then


        return;
    end


    local nation =
        EnsureEconomyNation(
            game,
            data,
            aiPlayerID
        );

    local managedHuman =
        nation ~= nil
        and nation.isAI ~= true
        and nation.aiManagerEnabled == true;


    if not managedHuman
        and math.random(
            1,
            100
        ) > GetAIInvestChance() then

        return;
    end


    local currentGold =
        GetAvailableGold(
            game,
            resourceChanges,
            aiPlayerID
        );


    if currentGold <= 0 then

        return;
    end


local strategicState =
    nation.aiStrategicState
    or "stable";

local reservePercent =
    GetSetting(
        "AIBaseReservePercent",
        40
    );

if nation ~= nil then

    reservePercent =
        nation.aiDynamicReservePercent
        or reservePercent;

end

reservePercent =
    math.max(
        0,
        math.min(
            90,
            reservePercent
        )
    );

local reserve =
    math.floor(
        currentGold
        * reservePercent
        / 100
    );

local spendable =
    currentGold
    - reserve;

if nation ~= nil
    and nation.aiManagerEnabled == true then

    spendable =
        math.min(
            spendable,
            nation.aiManagerBudgetRemaining
            or 0
        );

end

    if strategicState == "recovery"
    or strategicState == "strained"
    or strategicState == "war" then

    return;

end

if strategicState == "threatened" then

    spendable =
        math.floor(
            spendable
            * 0.50
        );

elseif strategicState == "expansion" then

    spendable =
        math.floor(
            spendable
            * 1.20
        );

end

    if spendable < 25 then

        return;
    end


    local bestProject =
        nil;


    local bestScore =
        nil;


    for _, project
        in pairs(
            data.investmentProjects
        ) do


        if project.status
            == "funding"

            and project.creatorID
            ~= aiPlayerID
        then


            local creatorReady =
                IsNationEconomyReady(
                    game,
                    data,
                    project.creatorID
                );


            local atWar =
                false;


            if creatorReady then


                atWar =
                    IsDiplomacyWar(
                        data,
                        aiPlayerID,
                        project.creatorID
                    );
            end


            -- New foreign investments are prohibited
            -- while the investor and project creator
            -- are officially at war.

            if creatorReady
                and not atWar then


                local existing =
                    FindInvestmentByPlayer(
                        project,
                        aiPlayerID
                    );


                local outsideCount =
                    CountOutsideInvestors(
                        project
                    );


                local hasSlot =
                    existing ~= nil
                    or
                    outsideCount
                    < (
                        project.investorLimit
                        or 0
                    );


                if hasSlot then


                    local investorCap =
                        math.floor(
                            (
                                project.fundingGoal
                                or 0
                            )
                            * (
                                OUTSIDE_INVESTOR_MAX_PERCENT
                                / 100
                            )
                        );


                    local alreadyInvested =
                        0;


                    if existing ~= nil then


                        alreadyInvested =
                            existing.amount
                            or 0;
                    end


                    local remainingCap =
                        investorCap
                        - alreadyInvested;


                    local remainingFunding =
                        (
                            project.fundingGoal
                            or 0
                        )
                        -
                        (
                            project.currentFunding
                            or 0
                        );


                    if remainingCap > 0
                        and remainingFunding > 0 then


                        local score =
                            CalculateProjectScore(
                                project
                            );


                        if bestScore == nil
                            or score > bestScore then


                            bestScore =
                                score;


                            bestProject =
                                project;
                        end
                    end

                end

            end

        end

    end


    if bestProject == nil then

        return;
    end


    -- Final diplomacy recheck immediately before money moves.

    if IsDiplomacyWar(
        data,
        aiPlayerID,
        bestProject.creatorID
    ) then


        return;
    end


    local existing =
        FindInvestmentByPlayer(
            bestProject,
            aiPlayerID
        );


    local alreadyInvested =
        0;


    if existing ~= nil then


        alreadyInvested =
            existing.amount
            or 0;
    end


    local investorCap =
        math.floor(
            bestProject.fundingGoal
            * (
                OUTSIDE_INVESTOR_MAX_PERCENT
                / 100
            )
        );


    local remainingCap =
        investorCap
        - alreadyInvested;


    local remainingFunding =
        bestProject.fundingGoal
        - bestProject.currentFunding;


    -- AI doesn't dump all spendable money.
    -- It invests up to 30% of spendable gold.

    local desiredAmount =
        math.floor(
            spendable * 0.30
        );


    local amount =
        math.min(
            desiredAmount,
            remainingCap,
            remainingFunding
        );


    amount =
        math.floor(
            amount
        );


    if amount < 10 then

        return;
    end


    AddResourceChange(
        resourceChanges,
        aiPlayerID,
        -amount
    );

    if nation ~= nil
        and nation.aiManagerEnabled == true then

        nation.aiManagerBudgetRemaining =
            math.max(
                0,
                (
                    nation.aiManagerBudgetRemaining
                    or 0
                )
                - amount
            );

    end


    if existing ~= nil then


        existing.amount =
            alreadyInvested
            + amount;


    else


        table.insert(
            bestProject.investments,
            {

                playerID =
                    aiPlayerID,

                amount =
                    amount,

                isCreator =
                    false
            }
        );
    end


    bestProject.currentFunding =
        bestProject.currentFunding
        + amount;


    local aiName =
        GetEconomicPlayerName(
            game,
            aiPlayerID
        );


    local creatorName =
        GetEconomicPlayerName(
            game,
            bestProject.creatorID
        );


    local message =
        aiName ..
        " invested " ..
        tostring(
            amount
        ) ..
        " gold in " ..
        creatorName ..
        "'s " ..
        tostring(
            bestProject.projectName
        ) ..
        ".";


    AddInvestmentHistory(
        data,
        "investment_made",
        message,
        bestProject.id,
        aiPlayerID,
        true
    );


    AddTradeHistory(
        data,
        "investment_made",
        message,
        aiPlayerID,
        bestProject.creatorID,
        true
    );

end
-- =========================================================
-- INVESTMENT RESOURCE HELPERS
-- =========================================================

function AddInvestmentPayout(
    resourceChanges,
    playerID,
    amount
)

    amount =
        math.floor(
            amount + 0.5
        );


    if amount <= 0 then

        return;
    end


    AddResourceChange(
        resourceChanges,
        playerID,
        amount
    );

end


-- =========================================================
-- ARCHIVE PROJECT
-- =========================================================

function ArchiveInvestmentProject(
    data,
    project
)

    local archive =
    {

        id =
            project.id,

        projectTypeID =
            project.projectTypeID,

        projectName =
            project.projectName,

        creatorID =
            project.creatorID,

        fundingGoal =
            project.fundingGoal,

        currentFunding =
            project.currentFunding,

        creatorContribution =
            project.creatorContribution,

        investorLimit =
            project.investorLimit,

        investments =
            project.investments,

        risk =
            project.risk,

        duration =
            project.duration,

        successReturn =
            project.successReturn,

        failureRecovery =
            project.failureRecovery,

        successChance =
            project.successChance,

        createdTurn =
            project.createdTurn,

        startedTurn =
            project.startedTurn,

        endedTurn =
            project.endedTurn,

        status =
            project.status,

        result =
            project.result,

        resolutionRoll =
            project.resolutionRoll,

        createdByAI =
            project.createdByAI
            or false
    };


    table.insert(
        data.completedInvestmentProjects,
        archive
    );


    while #data.completedInvestmentProjects
        > MAX_ARCHIVED_PROJECTS do


        table.remove(
            data.completedInvestmentProjects,
            1
        );
    end

end


-- =========================================================
-- EXPIRE UNFUNDED PROJECT
-- =========================================================

function ExpireInvestmentProject(
    game,
    data,
    project,
    resourceChanges
)

    project.status =
        "expired";


    project.result =
        "expired";


    project.endedTurn =
        data.tradeTurn;


    for _, investment
        in pairs(
            project.investments
            or {}
        ) do


        AddInvestmentPayout(
            resourceChanges,
            investment.playerID,
            investment.amount
            or 0
        );


        investment.payout =
            investment.amount
            or 0;
    end


    local creatorName =
        GetEconomicPlayerName(
            game,
            project.creatorID
        );


    local message =
        creatorName ..
        "'s " ..
        tostring(
            project.projectName
        ) ..
        " did not reach its funding goal. All investors were refunded.";


    AddInvestmentHistory(
        data,
        "project_expired",
        message,
        project.id,
        project.creatorID,
        false
    );


    AddTradeHistory(
        data,
        "investment_expired",
        message,
        project.creatorID,
        nil,
        false
    );

end


-- =========================================================
-- RESOLVE ACTIVE PROJECT
-- =========================================================

function ResolveInvestmentProject(
    game,
    data,
    project,
    resourceChanges
)

    local roll =
        math.random(
            1,
            100
        );


    project.resolutionRoll =
        roll;


    project.endedTurn =
        data.tradeTurn;


    local success =
        roll
        <= (
            project.successChance
            or 0
        );


    local creatorName =
        GetEconomicPlayerName(
            game,
            project.creatorID
        );


    if success then

local creatorNation =
    (
        data.globalEconomy
        and data.globalEconomy.nations
        and data.globalEconomy.nations[
            project.creatorID
        ]
    )
    or nil;

local taxInvestmentModifier =
    GetTaxInvestmentModifierPercent(
        creatorNation
    );

local adjustedSuccessReturn =
    project.successReturn
    or 0;

local ideologyInvestmentModifier =
    GetIdeologyInvestmentModifierPercent(
        creatorNation
    );

local totalInvestmentModifier =
    taxInvestmentModifier
    + ideologyInvestmentModifier;

adjustedSuccessReturn =
    adjustedSuccessReturn
    * (
        1
        + totalInvestmentModifier / 100
    );

        project.status =
            "completed";


        project.result =
            "success";


        for _, investment
            in pairs(
                project.investments
                or {}
            ) do


            local principal =
                investment.amount
                or 0;


            local payout =
                principal
                * (
                    1
                    + (
                        (
                            adjustedSuccessReturn
                            
                        )
                        / 100
                    )
                );


            payout =
                math.floor(
                    payout + 0.5
                );


            investment.payout =
                payout;


            AddInvestmentPayout(
                resourceChanges,
                investment.playerID,
                payout
            );
        end


        local message =
            creatorName ..
            "'s " ..
            tostring(
                project.projectName
            ) ..
            " succeeded. Investors earned +" ..
            tostring(
                project.successReturn
                or 0
            ) ..
            "% on their invested gold.";


        AddInvestmentHistory(
            data,
            "project_success",
            message,
            project.id,
            project.creatorID,
            false
        );


        AddTradeHistory(
            data,
            "investment_success",
            message,
            project.creatorID,
            nil,
            false
        );


    else


        project.status =
            "failed";


        project.result =
            "failure";


        for _, investment
            in pairs(
                project.investments
                or {}
            ) do


            local principal =
                investment.amount
                or 0;


            local payout =
                principal
                * (
                    (
                        project.failureRecovery
                        or 0
                    )
                    / 100
                );


            payout =
                math.floor(
                    payout + 0.5
                );


            investment.payout =
                payout;


            AddInvestmentPayout(
                resourceChanges,
                investment.playerID,
                payout
            );
        end


        local message =
            creatorName ..
            "'s " ..
            tostring(
                project.projectName
            ) ..
            " failed. Investors recovered " ..
            tostring(
                project.failureRecovery
                or 0
            ) ..
            "% of their principal.";


        AddInvestmentHistory(
            data,
            "project_failure",
            message,
            project.id,
            project.creatorID,
            false
        );


        AddTradeHistory(
            data,
            "investment_failure",
            message,
            project.creatorID,
            nil,
            false
        );
    end

end

function ProcessPendingInvestmentActions(
    game,
    data,
    resourceChanges
)

    local actions =
        data.pendingInvestmentActions
        or {};

    for i = #actions, 1, -1 do

        local action =
            actions[i];

        if action.type == "invest" then

            local project =
                nil;

            for _, candidate
                in pairs(
                    data.investmentProjects
                    or {}
                ) do

                if candidate.id
                    == action.projectID then

                    project =
                        candidate;

                    break;
                end
            end

            if project ~= nil
                and project.status
                == "funding" then

                local playerID =
                    action.playerID;

                local amount =
                    math.floor(
                        action.amount
                        or 0
                    );

                local availableGold =
                    GetAvailableGold(
                        game,
                        resourceChanges,
                        playerID
                    );

                local remainingFunding =
                    (
                        project.fundingGoal
                        or 0
                    )
                    -
                    (
                        project.currentFunding
                        or 0
                    );

                if amount > remainingFunding then
                    amount =
                        remainingFunding;
                end

                if amount > availableGold then
                    amount =
                        availableGold;
                end

                if amount > 0 then

                    local existing =
                        nil;

                    for _, investment
                        in pairs(
                            project.investments
                            or {}
                        ) do

                        if investment.playerID
                            == playerID then

                            existing =
                                investment;

                            break;
                        end
                    end

                    AddResourceChange(
                        resourceChanges,
                        playerID,
                        -amount
                    );

                    if existing ~= nil then

                        existing.amount =
                            (
                                existing.amount
                                or 0
                            )
                            + amount;

                    else

                        table.insert(
                            project.investments,
                            {
                                playerID =
                                    playerID,

                                amount =
                                    amount,

                                isCreator =
                                    false
                            }
                        );

                    end

                    project.currentFunding =
                        (
                            project.currentFunding
                            or 0
                        )
                        + amount;

                    local investorName =
                        GetEconomicPlayerName(
                            game,
                            playerID
                        );

                    local creatorName =
                        GetEconomicPlayerName(
                            game,
                            project.creatorID
                        );

                    local message =
                        investorName ..
                        " invested " ..
                        tostring(amount) ..
                        " gold in " ..
                        creatorName ..
                        "'s " ..
                        tostring(
                            project.projectName
                        ) ..
                        ".";

                    AddInvestmentHistory(
                        data,
                        "investment_made",
                        message,
                        project.id,
                        playerID,
                        false
                    );

                    AddTradeHistory(
                        data,
                        "investment_made",
                        message,
                        playerID,
                        project.creatorID,
                        false
                    );

                end
            end

            table.remove(
                actions,
                i
            );
        end
    end

    data.pendingInvestmentActions =
        actions;

end
-- =========================================================
-- PROCESS PROJECTS
-- =========================================================
function ProcessStockMarket(
    game,
    data
)

    local economy =
        EnsureGlobalEconomyData(
            data
        );

    local market =
        economy.market
        or {};

    local companies =
        market.companies
        or {};

    local currentTurn =
        economy.currentEconomyTurn
        or data.tradeTurn
        or 1;

    for _, company
        in pairs(companies) do

        if company.active == true
            and company.delisted ~= true
            and company.status == "trading" then

            local ownerIncome =
                GetCommerceIncome(
                    game,
                    company.ownerPlayerID
                );

            local changePercent =
                CalculateStockPriceChangePercent(
                    company,
                    ownerIncome
                );

local ownerNation =
    economy.nations[
        company.ownerPlayerID
    ];

local taxMarketModifier =
    GetTaxMarketModifierPercent(
        ownerNation
    );

local ideologyMarketModifier =
    GetIdeologyMarketModifierPercent(
        ownerNation
    );

local totalMarketModifier =
    taxMarketModifier
    + ideologyMarketModifier;

if totalMarketModifier ~= 0 then

    if changePercent >= 0 then

        changePercent =
            changePercent
            * (
                1
                + totalMarketModifier / 100
            );

    else

        changePercent =
            changePercent
            * (
                1
                - totalMarketModifier / 100
            );

    end

end

            if math.abs(
    changePercent
) >= 8 then

    economy.market.news =
        economy.market.news
        or {};

    local direction =
        "rose";

    if changePercent < 0 then
        direction =
            "fell";
    end

    table.insert(
        economy.market.news,
        {
            turn =
                currentTurn,

            type =
                "major_move",

            companyID =
                company.id,

            message =
                tostring(
                    company.name
                ) ..
                " " ..
                direction ..
                " " ..
                string.format(
                    "%.1f%%",
                    math.abs(
                        changePercent
                    )
                ) ..
                " this turn."
        }
    );

end

            local oldPrice =
                company.currentPrice
                or company.startingPrice
                or 1;

            local newPrice =
                oldPrice
                * (
                    1
                    + (
                        changePercent
                        / 100
                    )
                );

            newPrice =
                math.max(
                    1,
                    newPrice
                );

            newPrice =
                math.floor(
                    newPrice
                    + 0.5
                );

            company.previousPrice =
                oldPrice;

            company.currentPrice =
                newPrice;

            if company.currentPrice >= 700 then

    company.currentPrice =
        math.floor(
            company.currentPrice
            / 2
            + 0.5
        );

    company.previousPrice =
        math.floor(
            company.previousPrice
            / 2
            + 0.5
        );

    company.totalShares =
        (
            company.totalShares
            or 0
        )
        * 2;

    company.publicShares =
        (
            company.publicShares
            or 0
        )
        * 2;

    company.founderShares =
        (
            company.founderShares
            or 0
        )
        * 2;

    company.sharesAvailable =
        (
            company.sharesAvailable
            or 0
        )
        * 2;

    for _, nation
        in pairs(
            economy.nations
            or {}
        ) do

        nation.stockHoldings =
            nation.stockHoldings
            or {};

        nation.stockCostBasis =
    nation.stockCostBasis
    or {};

        local heldShares =
            nation.stockHoldings[
                company.id
            ]
            or 0;

        if heldShares > 0 then

            nation.stockHoldings[
                company.id
            ] =
                heldShares
                * 2;

        end

    end

    newPrice =
        company.currentPrice;
economy.market.news =
    economy.market.news
    or {};

table.insert(
    economy.market.news,
    {
        turn =
            currentTurn,

        type =
            "stock_split",

        companyID =
            company.id,

        message =
            tostring(
                company.name
            ) ..
            " completed a 2-for-1 stock split."
    }
);

end
-- Repair invalid share totals before recalculating market cap.
if company.totalShares == nil
    or company.totalShares <= 0
then

    local repairedTotalShares =
        company.sharesAvailable
        or 0;

    for _, marketNation
        in pairs(
            economy.nations
            or {}
        ) do

        local holdings =
            marketNation.stockHoldings
            or {};

        repairedTotalShares =
            repairedTotalShares
            + (
                holdings[
                    company.id
                ]
                or 0
            );

    end

    if repairedTotalShares > 0 then

        company.totalShares =
            repairedTotalShares;

    end

end

            company.marketCap =
                (
                    company.totalShares
                    or 0
                )
                * newPrice;

            local previousOwnerIncome = company.lastOwnerIncome or ownerIncome;
            if previousOwnerIncome > 0 then
                company.ownerIncomeGrowthPercent =
                    ((ownerIncome - previousOwnerIncome) / previousOwnerIncome) * 100;
            else
                company.ownerIncomeGrowthPercent = 0;
            end

            company.lastOwnerIncome =
                ownerIncome;

            company.lastTurnBuyVolume =
    company.buyVolumeThisTurn
    or 0;

company.lastTurnSellVolume =
    company.sellVolumeThisTurn
    or 0;

company.lastTurnVolume =
    company.lastTurnBuyVolume
    + company.lastTurnSellVolume;

            company.buyVolumeThisTurn =
    0;

company.sellVolumeThisTurn =
    0;

            company.priceHistory =
                company.priceHistory
                or {};

            table.insert(
                company.priceHistory,
                {
                    turn =
                        currentTurn,

                    price =
                        newPrice,

                    changePercent =
                        changePercent
                }
            );

            while #company.priceHistory > 30 do

                table.remove(
                    company.priceHistory,
                    1
                );

            end

        end
    end

end

function TrimMarketNews(
    market
)

    if market == nil then
        return;
    end

    market.news =
        market.news
        or {};

    while #market.news > 100 do

        table.remove(
            market.news,
            1
        );

    end

end

function ProcessMarketETF(
    game,
    data,
    resourceChanges
)

    local economy =
        EnsureGlobalEconomyData(
            data
        );

    if economy == nil
        or economy.market == nil
        or economy.market.etf == nil then

        return;
    end

    local market =
        economy.market;

    local etf =
        market.etf;

    local currentTurn =
        economy.currentEconomyTurn
        or data.tradeTurn
        or 1;


    -- =========================================
    -- FIND ACTIVE COMPANIES
    -- =========================================

    local rankedCompanies =
        {};

    for companyID,company in pairs(
        market.companies
        or {}
    ) do

        if company ~= nil
            and company.active ~= false
            and company.delisted ~= true
            and company.status == "trading" then

            table.insert(
                rankedCompanies,
                {
                    id =
                        companyID,

                    company =
                        company
                }
            );

        end

    end


    table.sort(
        rankedCompanies,
        function(a,b)

            local aCap =
                a.company.marketCap
                or 0;

            local bCap =
                b.company.marketCap
                or 0;

            return aCap > bCap;

        end
    );


    -- =========================================
    -- REBALANCE ETF
    -- =========================================

    -- Global ETF is intentionally refreshed every 5 turns so holdings stay
    -- current without reshuffling every single market tick.
    local rebalanceInterval = 5;
    etf.rebalanceInterval = rebalanceInterval;

    local lastRebalanceTurn =
        etf.lastRebalanceTurn
        or 0;

    local needsRebalance =
        #(
            etf.memberCompanyIDs
            or {}
        ) == 0
        or (
            currentTurn
            - lastRebalanceTurn
            >= rebalanceInterval
        );


    if needsRebalance then

        etf.memberCompanyIDs =
            {};

        for _,company in pairs(
            market.companies
            or {}
        ) do

            company.etfMember =
                false;

        end

        local memberLimit =
            math.min(
                etf.memberCount
                or 5,

                #rankedCompanies
            );

        for i = 1,memberLimit do

            local entry =
                rankedCompanies[
                    i
                ];

            table.insert(
                etf.memberCompanyIDs,
                entry.id
            );

            entry.company.etfMember =
                true;

            entry.company.etfMemberTurns =
                (
                    entry.company.etfMemberTurns
                    or 0
                )
                + 1;

        end

        etf.lastRebalanceTurn =
            currentTurn;

        market.news =
    market.news
    or {};

table.insert(
    market.news,
    {
        turn =
            currentTurn,

        type =
            "etf_rebalance",

        message =
            "Global Market ETF rebalanced its Top " ..
            tostring(
                #(
                    etf.memberCompanyIDs
                    or {}
                )
            ) ..
            " holdings."
    }
);

        -- ETF holders receive a visible diversification/performance bonus on
        -- each 5-turn rebalance cycle.  This is separate from normal ETF
        -- dividends so players can clearly see the benefit of holding the ETF.
        local bonusPaid = 0;
        for playerID, nation in pairs(economy.nations or {}) do
            nation.etfBonusThisTurn = 0;
            nation.etfRebalanceBonusesReceived = nation.etfRebalanceBonusesReceived or 0;
            local shares = math.max(0, tonumber(nation.etfShares) or 0);
            if shares > 0 then
                local price = tonumber(etf.currentPrice or etf.startingPrice) or 100;
                local positionValue = shares * price;
                local bonus = math.max(1, math.floor(positionValue * 0.01 + 0.5));
                nation.etfBonusThisTurn = bonus;
                nation.etfRebalanceBonusesReceived = nation.etfRebalanceBonusesReceived + bonus;
                bonusPaid = bonusPaid + bonus;
                if resourceChanges ~= nil then
                    AddResourceChange(resourceChanges, playerID, bonus);
                end
            end
        end
        etf.lastHolderBonusPaid = bonusPaid;
        etf.lastHolderBonusTurn = currentTurn;
        if bonusPaid > 0 then
            table.insert(market.news, {
                turn = currentTurn,
                type = "etf_bonus",
                message = "Global Market ETF paid " .. tostring(bonusPaid) .. " Commerce in 5-turn holder bonuses."
            });
        end

    end


    -- =========================================
    -- CALCULATE ETF PRICE MOVEMENT
    -- =========================================

    local totalChange =
        0;

    local validMembers =
        0;

    for _,companyID in ipairs(
        etf.memberCompanyIDs
        or {}
    ) do

        local company =
            market.companies[
                companyID
            ];

        if company ~= nil then

            local currentPrice =
                company.currentPrice
                or 1;

            local previousPrice =
                company.previousPrice
                or currentPrice;

            if previousPrice > 0 then

                local changePercent =
                    (
                        currentPrice
                        - previousPrice
                    )
                    / previousPrice
                    * 100;

                totalChange =
                    totalChange
                    + changePercent;

                validMembers =
                    validMembers
                    + 1;

            end

        end

    end


    if validMembers <= 0 then
        return;
    end


    local averageChange =
        totalChange
        / validMembers;

    local oldETFPrice =
        etf.currentPrice
        or etf.startingPrice
        or 100;

    local newETFPrice =
        oldETFPrice
        * (
            1
            + averageChange
            / 100
        );

    if newETFPrice < 1 then
        newETFPrice = 1;
    end

    newETFPrice =
        math.floor(
            newETFPrice
            * 100
            + 0.5
        )
        / 100;


    etf.previousPrice =
        oldETFPrice;

    etf.currentPrice =
        newETFPrice;


    -- =========================================
    -- ETF PRICE HISTORY
    -- =========================================

    etf.priceHistory =
        etf.priceHistory
        or {};

    table.insert(
        etf.priceHistory,
        {
            turn =
                currentTurn,

            price =
                newETFPrice,

            changePercent =
                averageChange
        }
    );

    while #etf.priceHistory > 30 do

        table.remove(
            etf.priceHistory,
            1
        );

    end

end

function ProcessCompanyDividends(
    game,
    data,
    resourceChanges
)

    local economy =
        EnsureGlobalEconomyData(
            data
        );

    for _, company
        in pairs(
            economy.market.companies
            or {}
        ) do

        if company.active == true
            and company.delisted ~= true
            and company.status == "trading" then

            local ownerIncome =
                GetCommerceIncome(
                    game,
                    company.ownerPlayerID
                );

            local dividendPool =
                CalculateCompanyDividendPool(
                    company,
                    ownerIncome
                );

            local totalShares =
                company.totalShares
                or 0;

            if dividendPool > 0
                and totalShares > 0 then

                local dividendPerShare =
                    dividendPool
                    / totalShares;

                company.dividendPerShare =
                    dividendPerShare;

                local paidTotal =
                    0;

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
                            company.id
                        ]
                        or 0;

                    if heldShares > 0 then

                    nation.stockDividendCarry =
    nation.stockDividendCarry
    or {};

local previousCarry =
    nation.stockDividendCarry[
        company.id
    ]
    or 0;

local exactPayout =
    (
        heldShares
        * dividendPerShare
    )
    + previousCarry;

local payout =
    math.floor(
        exactPayout
    );

nation.stockDividendCarry[
    company.id
] =
    exactPayout
    - payout;



                        if payout > 0 then

                            AddResourceChange(
                                resourceChanges,
                                playerID,
                                payout
                            );

                            nation.dividendsReceived =
                                (
                                    nation.dividendsReceived
                                    or 0
                                )
                                + payout;

                            paidTotal =
                                paidTotal
                                + payout;

                        end
                    end
                end

                company.totalDividendsPaid =
                    (
                        company.totalDividendsPaid
                        or 0
                    )
                    + paidTotal;
if paidTotal > 0 then

    economy.market.news =
        economy.market.news
        or {};

    table.insert(
        economy.market.news,
        {
            turn =
                economy.currentEconomyTurn
                or data.tradeTurn
                or 1,

            type =
                "dividend",

            companyID =
                company.id,

            message =
                tostring(
                    company.name
                ) ..
                " paid " ..
                tostring(
                    paidTotal
                ) ..
                " gold in dividends this turn."
        }
    );

end
            else

                company.dividendPerShare =
                    0;

            end
        end
    end

end

function ProcessETFDividends(
    game,
    data,
    resourceChanges
)

    local economy =
        EnsureGlobalEconomyData(
            data
        );

    if economy == nil
        or economy.market == nil
        or economy.market.etf == nil then

        return;
    end

    local market =
        economy.market;

    local etf =
        market.etf;

    if etf.active ~= true then
        return;
    end

    local memberIDs =
        etf.memberCompanyIDs
        or {};

    if #memberIDs == 0 then

        etf.dividendPerShare =
            0;

        return;
    end


    -- =========================================
    -- CALCULATE ETF DIVIDEND YIELD
    -- =========================================

    local totalYield =
        0;

    local validMembers =
        0;

    for _,companyID in ipairs(
        memberIDs
    ) do

        local company =
            market.companies[
                companyID
            ];

        if company ~= nil
            and company.active ~= false
            and company.delisted ~= true then

            local companyPrice =
                company.currentPrice
                or company.startingPrice
                or 1;

            local dividendPerShare =
                company.dividendPerShare
                or 0;

            if companyPrice > 0 then

                totalYield =
                    totalYield
                    + (
                        dividendPerShare
                        / companyPrice
                    );

                validMembers =
                    validMembers
                    + 1;

            end

        end

    end


    if validMembers <= 0 then

        etf.dividendPerShare =
            0;

        return;
    end


    local averageYield =
        totalYield
        / validMembers;

    local etfPrice =
        etf.currentPrice
        or etf.startingPrice
        or 100;

    local etfDividendPerShare =
        etfPrice
        * averageYield;

    etf.dividendPerShare =
        etfDividendPerShare;


    -- =========================================
    -- PAY ETF HOLDERS
    -- =========================================

    local paidTotal =
        0;

    for playerID,nation in pairs(
        economy.nations
        or {}
    ) do

        local heldShares =
            nation.etfShares
            or 0;

        if heldShares > 0 then

            local payout =
                math.floor(
                    heldShares
                    * etfDividendPerShare
                    + 0.5
                );

            if payout > 0 then

                AddResourceChange(
                    resourceChanges,
                    playerID,
                    payout
                );

                nation.etfDividendsReceived =
                    (
                        nation.etfDividendsReceived
                        or 0
                    )
                    + payout;

                paidTotal =
                    paidTotal
                    + payout;

            end

        end

    end


    etf.totalDividendsPaid =
        (
            etf.totalDividendsPaid
            or 0
        )
        + paidTotal;

        if paidTotal > 0 then

    market.news =
        market.news
        or {};

    table.insert(
        market.news,
        {
            turn =
                economy.currentEconomyTurn
                or data.tradeTurn
                or 1,

            type =
                "etf_dividend",

            message =
                "Global Market ETF paid " ..
                tostring(
                    paidTotal
                ) ..
                " Commerce in dividends this turn."
        }
    );

end

end

function ProcessInvestmentProjects(
    game,
    data,
    resourceChanges
)


    for i =
        #data.investmentProjects,
        1,
        -1 do


        local project =
            data.investmentProjects[
                i
            ];


        if project.status
            == "funding" then


            if (
                project.currentFunding
                or 0
            ) >= (
                project.fundingGoal
                or 0
            ) then


                project.currentFunding =
                    project.fundingGoal;


                project.status =
                    "active";


                project.startedTurn =
                    data.tradeTurn;


                project.completionTurn =
                    data.tradeTurn
                    + (
                        project.duration
                        or 1
                    );


                local creatorName =
                    GetEconomicPlayerName(
                        game,
                        project.creatorID
                    );


                local message =
                    creatorName ..
                    "'s " ..
                    tostring(
                        project.projectName
                    ) ..
                    " reached full funding and entered development.";


                AddInvestmentHistory(
                    data,
                    "project_funded",
                    message,
                    project.id,
                    project.creatorID,
                    false
                );


                AddTradeHistory(
                    data,
                    "investment_funded",
                    message,
                    project.creatorID,
                    nil,
                    false
                );


            elseif project.fundingDeadline
                ~= nil

                and data.tradeTurn
                >= project.fundingDeadline then


                ExpireInvestmentProject(
                    game,
                    data,
                    project,
                    resourceChanges
                );


                ArchiveInvestmentProject(
                    data,
                    project
                );


                table.remove(
                    data.investmentProjects,
                    i
                );
            end


        elseif project.status
            == "active" then


            if project.completionTurn
                ~= nil

                and data.tradeTurn
                >= project.completionTurn then


                ResolveInvestmentProject(
                    game,
                    data,
                    project,
                    resourceChanges
                );


                ArchiveInvestmentProject(
                    data,
                    project
                );


                table.remove(
                    data.investmentProjects,
                    i
                );
            end
        end
    end

end
-- =========================================================
-- DIPLOMACY QUERY HELPERS
-- =========================================================

function HasPendingDiplomacyWar(
    data,
    playerA,
    playerB
)

    local diplomacy =
        GetDiplomacyData(
            data
        );


    local key =
        EconomyPairKey(
            playerA,
            playerB
        );


    return
        diplomacy.pendingWarDeclarations[
            key
        ]
        ~= nil;

end


function HasPendingDiplomacyPeace(
    data,
    playerA,
    playerB
)

    local diplomacy =
        GetDiplomacyData(
            data
        );


    for _, offer
        in ipairs(
            diplomacy.pendingPeaceOffers
        ) do


        if
            (
                offer.fromPlayerID
                == playerA
                and offer.toPlayerID
                == playerB
            )
            or
            (
                offer.fromPlayerID
                == playerB
                and offer.toPlayerID
                == playerA
            )
        then


            return true;
        end
    end


    return false;

end


function HasPendingDiplomacyNAP(
    data,
    playerA,
    playerB
)

    local diplomacy =
        GetDiplomacyData(
            data
        );


    for _, offer
        in ipairs(
            diplomacy.pendingNAPOffers
        ) do


        if
            (
                offer.fromPlayerID
                == playerA
                and offer.toPlayerID
                == playerB
            )
            or
            (
                offer.fromPlayerID
                == playerB
                and offer.toPlayerID
                == playerA
            )
        then


            return true;
        end
    end


    return false;

end


function GetDiplomacyPeaceCooldownRemaining(
    data,
    playerA,
    playerB
)

    local relationship =
        GetDiplomacyRelationship(
            data,
            playerA,
            playerB
        );


    local currentTurn =
        GetCurrentDiplomacyTurn(
            data
        );


    local cooldownUntil =
        relationship.peaceCooldownUntil
        or 0;


    if currentTurn
        >= cooldownUntil then


        return 0;
    end


    return
        cooldownUntil
        - currentTurn;

end


function GetDefaultNAPDuration()

    local duration =
        tonumber(
            GetSetting(
                "DefaultNAPDurationTurns",
                DEFAULT_NAP_DURATION_TURNS
            )
        )
        or DEFAULT_NAP_DURATION_TURNS;


    duration =
        math.floor(
            duration
        );


    if duration < 1 then

        duration =
            1;
    end


    if duration > 20 then

        duration =
            20;
    end


    return duration;

end


-- =========================================================
-- AI WAR DECLARATION
-- =========================================================

local SelectAIWarReason;
local PlayersShareLandBorder;

function QueueAIWarDeclaration(
    game,
    data,
    aiPlayerID,
    targetPlayerID
)

    if aiPlayerID == targetPlayerID then

        return false;
    end


    if not IsNationEconomyReady(
        game,
        data,
        aiPlayerID
    )
    or not IsNationEconomyReady(
        game,
        data,
        targetPlayerID
    ) then


        return false;
    end


    if IsDiplomacyWar(
        data,
        aiPlayerID,
        targetPlayerID
    ) then


        return false;
    end

    if GetActiveAlliance(
    data,
    aiPlayerID,
    targetPlayerID
) ~= nil then

    return false;
end

    if GetActiveDiplomacyNAP(
        data,
        aiPlayerID,
        targetPlayerID
    ) ~= nil then


        return false;
    end


    if GetDiplomacyPeaceCooldownRemaining(
        data,
        aiPlayerID,
        targetPlayerID
    ) > 0 then


        return false;
    end


    if HasPendingDiplomacyWar(
        data,
        aiPlayerID,
        targetPlayerID
    ) then


        return false;
    end


    local diplomacy =
        GetDiplomacyData(
            data
        );


    local currentTurn =
        GetCurrentDiplomacyTurn(
            data
        );


    local delay =
        GetWarDeclarationDelay();

    local warReason =
        SelectAIWarReason(
            game,
            data,
            aiPlayerID,
            targetPlayerID
        );

    diplomacy.nextWarConflictID = diplomacy.nextWarConflictID or 1;
    diplomacy.warConflicts = diplomacy.warConflicts or {};
    local conflictID = diplomacy.nextWarConflictID;
    diplomacy.nextWarConflictID = conflictID + 1;
    diplomacy.warConflicts[conflictID] = {
        id = conflictID,
        cause = warReason,
        startTurn = currentTurn,
        active = delay <= 0,
        sideA = {[aiPlayerID] = true},
        sideB = {[targetPlayerID] = true}
    };


    local aiName =
        GetEconomicPlayerName(
            game,
            aiPlayerID
        );


    local targetName =
        GetEconomicPlayerName(
            game,
            targetPlayerID
        );


    if delay <= 0 then


        local declarationMessage =
            aiName ..
            " declared war on " ..
            targetName ..
            ".";


        AddDiplomacyHistory(
            data,
            "war_declared",
            aiPlayerID,
            targetPlayerID,
            declarationMessage,
            {

                activatesTurn =
                    currentTurn,

                aiActivity =
                    true
            }
        );


        AddEconomyWorldEvent(
            data.globalEconomy,
            "war_declared",
            aiPlayerID,
            declarationMessage,
            {

                otherPlayerID =
                    targetPlayerID,

                activatesTurn =
                    currentTurn
            }
        );


        ActivateDiplomacyWar(
            game,
            data,
            aiPlayerID,
            targetPlayerID,
            warReason,
            conflictID
        );


        return true;
    end


    local key =
        EconomyPairKey(
            aiPlayerID,
            targetPlayerID
        );


    local activatesTurn =
        currentTurn
        + delay;


    diplomacy.pendingWarDeclarations[
        key
    ] =
    {

        fromPlayerID =
            aiPlayerID,

        toPlayerID =
            targetPlayerID,

        declaredTurn =
            currentTurn,

        activatesTurn =
            activatesTurn,

        delay =
            delay,

        active =
            true,

        aiActivity =
            true,

        warReason =
            warReason,

        conflictID =
            conflictID
    };


    local relationship =
        GetDiplomacyRelationship(
            data,
            aiPlayerID,
            targetPlayerID
        );


    relationship.pendingWarDeclaration =
        true;


    relationship.pendingWarFrom =
        aiPlayerID;


    relationship.pendingWarTo =
        targetPlayerID;


    relationship.warActivatesTurn =
        activatesTurn;

    relationship.warReason =
        warReason;

    relationship.warConflictID =
        conflictID;


    local message =
        aiName ..
        " declared war on " ..
        targetName ..
        ". War will become active on Diplomacy Turn " ..
        tostring(
            activatesTurn
        ) ..
        ".";


    AddDiplomacyHistory(
        data,
        "war_declared",
        aiPlayerID,
        targetPlayerID,
        message,
        {

            activatesTurn =
                activatesTurn,

            aiActivity =
                true
        }
    );


    AddEconomyWorldEvent(
        data.globalEconomy,
        "war_declared",
        aiPlayerID,
        message,
        {

            otherPlayerID =
                targetPlayerID,

            activatesTurn =
                activatesTurn
        }
    );


    return true;

end


-- =========================================================
-- AI WAR BORDER / REASON HELPERS
-- =========================================================

local AI_WAR_BORDER_CACHE_TURN = nil;
local AI_WAR_BORDER_CACHE = nil;

local function BuildAIWarBorderCache(game, data)
    local turn = data.tradeTurn or 0;
    if AI_WAR_BORDER_CACHE ~= nil and AI_WAR_BORDER_CACHE_TURN == turn then
        return AI_WAR_BORDER_CACHE;
    end

    local borders = {};
    local standing = game.ServerGame and game.ServerGame.LatestTurnStanding;
    if standing ~= nil and standing.Territories ~= nil then
        for territoryID, terrStanding in pairs(standing.Territories) do
            local owner = terrStanding and terrStanding.OwnerPlayerID or nil;
            local details = game.Map and game.Map.Territories and game.Map.Territories[territoryID] or nil;
            if owner ~= nil and owner ~= WL.PlayerID.Neutral and details ~= nil then
                borders[owner] = borders[owner] or {};
                for connectedID, _ in pairs(details.ConnectedTo or {}) do
                    local other = standing.Territories[connectedID];
                    local otherOwner = other and other.OwnerPlayerID or nil;
                    if otherOwner ~= nil and otherOwner ~= WL.PlayerID.Neutral and otherOwner ~= owner then
                        borders[owner][otherOwner] = true;
                    end
                end
            end
        end
    end

    AI_WAR_BORDER_CACHE_TURN = turn;
    AI_WAR_BORDER_CACHE = borders;
    return borders;
end

PlayersShareLandBorder = function(game, data, playerA, playerB)
    local borders = BuildAIWarBorderCache(game, data);
    return borders[playerA] ~= nil and borders[playerA][playerB] == true;
end

SelectAIWarReason = function(game, data, aiPlayerID, targetPlayerID)
    local economy = data.globalEconomy or {};
    local aiNation = (economy.nations or {})[aiPlayerID] or {};
    local targetNation = (economy.nations or {})[targetPlayerID] or {};
    local shortages = aiNation.resourceShortages or {};
    for _, amount in pairs(shortages) do
        if (tonumber(amount) or 0) > 0 then
            return "Resource Security";
        end
    end

    if aiNation.ideology ~= nil and targetNation.ideology ~= nil and aiNation.ideology ~= targetNation.ideology then
        return "Ideological Conflict";
    end

    local aiIncome = GetCommerceIncome(game, aiPlayerID);
    local targetIncome = GetCommerceIncome(game, targetPlayerID);
    if targetIncome > aiIncome * 1.15 then
        return "National Defense / Border Threat";
    end

    if HasAgreement(data, aiPlayerID, targetPlayerID) then
        return "Economic Conflict";
    end

    return "Territorial Dispute";
end

-- =========================================================
-- AI WAR TARGET
-- =========================================================

function FindAIWarTarget(
    game,
    data,
    aiPlayerID
)

    local candidates =
        {};


    local aiIncome =
        GetCommerceIncome(
            game,
            aiPlayerID
        );


    for playerID, _
        in pairs(
            game.Game.Players
        ) do


        if playerID
            ~= aiPlayerID

            and IsNationEconomyReady(
                game,
                data,
                playerID
            )

            and not IsDiplomacyWar(
                data,
                aiPlayerID,
                playerID
            )

            and GetActiveAlliance(
    data,
    aiPlayerID,
    playerID
) == nil

            and GetActiveDiplomacyNAP(
                data,
                aiPlayerID,
                playerID
            ) == nil

            and GetDiplomacyPeaceCooldownRemaining(
                data,
                aiPlayerID,
                playerID
            ) <= 0

            and not HasPendingDiplomacyWar(
                data,
                aiPlayerID,
                playerID
            )
            -- Independent AI declarations require an actual shared land
            -- border.  Distant wars can still happen later through joining a
            -- faction/coalition conflict, but random cross-map declarations do not.
            and PlayersShareLandBorder(
                game,
                data,
                aiPlayerID,
                playerID
            )
        then


            local targetIncome =
                GetCommerceIncome(
                    game,
                    playerID
                );


            local score =
                100;


            -- AI is more willing to challenge economically
            -- weaker nations, but stronger nations remain
            -- possible targets.

            if targetIncome
                < aiIncome * 0.60 then


                score =
                    score + 35;


            elseif targetIncome
                < aiIncome then


                score =
                    score + 20;


            elseif targetIncome
                > aiIncome * 1.50 then


                score =
                    score - 25;
            end


            -- Existing trade makes immediate hostility
            -- somewhat less attractive.

            if HasAgreement(
                data,
                aiPlayerID,
                playerID
            ) then


                score =
                    score - 25;
            end


            table.insert(
                candidates,
                {

                    playerID =
                        playerID,

                    score =
                        score
                }
            );
        end

    end


    if #candidates == 0 then

        return nil;
    end


    table.sort(
        candidates,

        function(
            a,
            b
        )

            return
                a.score
                > b.score;
        end
    );


    -- Choose among the strongest few candidates rather
    -- than making every AI completely deterministic.

    local selectionPool =
        math.min(
            #candidates,
            3
        );


    return candidates[
        math.random(
            1,
            selectionPool
        )
    ].playerID;

end


-- =========================================================
-- AI PEACE DECISION
-- =========================================================

function AIWouldAcceptPeace(
    game,
    data,
    aiPlayerID,
    otherPlayerID
)

    if not IsDiplomacyWar(
        data,
        aiPlayerID,
        otherPlayerID
    ) then


        return false;
    end


    local relationship =
        GetDiplomacyRelationship(
            data,
            aiPlayerID,
            otherPlayerID
        );


    local currentTurn =
        GetCurrentDiplomacyTurn(
            data
        );


    local warStarted =
        relationship.sinceTurn
        or currentTurn;


    local warAge =
        currentTurn
        - warStarted;


    if warAge
        < GetAIMinimumWarTurns() then


        return false;
    end


    local aiIncome =
        GetCommerceIncome(
            game,
            aiPlayerID
        );


    local otherIncome =
        GetCommerceIncome(
            game,
            otherPlayerID
        );


    local chance =
        GetAIPeaceChance();
    
    local nation =
    EnsureEconomyNation(
        game,
        data,
        aiPlayerID
    );

local aiProfile =
    "Balanced";

if nation ~= nil then

    aiProfile =
        EnsureAIProfile(
            nation,
            aiPlayerID
        );

end


    if otherIncome
        > aiIncome * 1.50 then


        chance =
            chance + 30;


    elseif otherIncome
        > aiIncome * 1.15 then


        chance =
            chance + 15;


    elseif aiIncome
        > otherIncome * 1.75 then


        chance =
            chance - 10;
    end

    if aiProfile == "Growth" then

    chance =
        chance - 10;

elseif aiProfile == "Investor" then

    chance =
        chance + 10;

elseif aiProfile == "Planner" then

    chance =
        chance + 5;

elseif aiProfile == "Conservative" then

    chance =
        chance + 15;

end

    if warAge >= 6 then

        chance =
            chance + 15;
    end


    if warAge >= 10 then

        chance =
            chance + 20;
    end


    if chance < 5 then

        chance =
            5;
    end


    if chance > 90 then

        chance =
            90;
    end


    return
        math.random(
            1,
            100
        )
        <= chance;

end


-- =========================================================
-- AI PROPOSES PEACE
-- =========================================================

function AIConsiderPeace(
    game,
    data,
    aiPlayerID
)

    for otherPlayerID, otherPlayer
        in pairs(
            game.Game.Players
        ) do


        if otherPlayerID
            ~= aiPlayerID

            and IsNationEconomyReady(
                game,
                data,
                otherPlayerID
            )

            and IsDiplomacyWar(
                data,
                aiPlayerID,
                otherPlayerID
            )

            and not HasPendingDiplomacyPeace(
                data,
                aiPlayerID,
                otherPlayerID
            )
        then


            if AIWouldAcceptPeace(
                game,
                data,
                aiPlayerID,
                otherPlayerID
            ) then


                local aiName =
                    GetEconomicPlayerName(
                        game,
                        aiPlayerID
                    );


                local otherName =
                    GetEconomicPlayerName(
                        game,
                        otherPlayerID
                    );


                -- AI vs AI can settle immediately.

                if otherPlayer.IsAI then


                    if AIWouldAcceptPeace(
                        game,
                        data,
                        otherPlayerID,
                        aiPlayerID
                    ) then


                        ActivateDiplomacyPeace(
                            game,
                            data,
                            aiPlayerID,
                            otherPlayerID,
                            "ai_mutual_peace"
                        );


                        return;
                    end


                -- AI -> HUMAN creates a real offer
                -- for the human player to accept or reject.

                else


                    local diplomacy =
                        GetDiplomacyData(
                            data
                        );


                    local currentTurn =
                        GetCurrentDiplomacyTurn(
                            data
                        );


                    table.insert(
                        diplomacy.pendingPeaceOffers,
                        {

                            fromPlayerID =
                                aiPlayerID,

                            toPlayerID =
                                otherPlayerID,

                            offeredTurn =
                                currentTurn,

                            active =
                                true,

                            aiActivity =
                                true
                        }
                    );


                    local message =
                        aiName ..
                        " offered peace to " ..
                        otherName ..
                        ".";


                    AddDiplomacyHistory(
                        data,
                        "peace_offered",
                        aiPlayerID,
                        otherPlayerID,
                        message,
                        {

                            aiActivity =
                                true
                        }
                    );


                    AddEconomyWorldEvent(
                        data.globalEconomy,
                        "peace_offered",
                        aiPlayerID,
                        message,
                        {

                            otherPlayerID =
                                otherPlayerID
                        }
                    );


                    return;
                end

            end

        end

    end

end


-- =========================================================
-- AI RESPONDS TO INCOMING PEACE OFFERS
-- =========================================================

function ProcessAIIncomingPeaceOffers(
    game,
    data
)

    local diplomacy =
        GetDiplomacyData(
            data
        );


    for i =
        #diplomacy.pendingPeaceOffers,
        1,
        -1 do


        local offer =
            diplomacy.pendingPeaceOffers[
                i
            ];


        local targetPlayer =
            GetEconomicPlayer(
                game,
                offer.toPlayerID
            );


        if targetPlayer ~= nil
            and targetPlayer.IsAI then


            local fromPlayerID =
                offer.fromPlayerID;


            local toPlayerID =
                offer.toPlayerID;


            if not IsNationEconomyReady(
                game,
                data,
                fromPlayerID
            )
            or not IsNationEconomyReady(
                game,
                data,
                toPlayerID
            ) then


                table.remove(
                    diplomacy.pendingPeaceOffers,
                    i
                );


            elseif AIWouldAcceptPeace(
                game,
                data,
                toPlayerID,
                fromPlayerID
            ) then


                table.remove(
                    diplomacy.pendingPeaceOffers,
                    i
                );


                ActivateDiplomacyPeace(
                    game,
                    data,
                    fromPlayerID,
                    toPlayerID,
                    "ai_accepted_offer"
                );


            else


                local fromName =
                    GetEconomicPlayerName(
                        game,
                        fromPlayerID
                    );


                local aiName =
                    GetEconomicPlayerName(
                        game,
                        toPlayerID
                    );


                table.remove(
                    diplomacy.pendingPeaceOffers,
                    i
                );


                local message =
                    aiName ..
                    " rejected a peace offer from " ..
                    fromName ..
                    ".";


                AddDiplomacyHistory(
                    data,
                    "peace_rejected",
                    fromPlayerID,
                    toPlayerID,
                    message,
                    {

                        aiActivity =
                            true
                    }
                );


                AddEconomyWorldEvent(
                    data.globalEconomy,
                    "peace_rejected",
                    toPlayerID,
                    message,
                    {

                        otherPlayerID =
                            fromPlayerID
                    }
                );
            end
        end
    end

end


-- =========================================================
-- CREATE NON-AGGRESSION PACT
-- =========================================================

function CreateDiplomacyNAP(
    game,
    data,
    playerA,
    playerB,
    duration,
    reason
)

    if IsDiplomacyWar(
        data,
        playerA,
        playerB
    ) then


        return false;
    end


    local diplomacy =
        GetDiplomacyData(
            data
        );


    local currentTurn =
        GetCurrentDiplomacyTurn(
            data
        );


    duration =
        tonumber(
            duration
        )
        or GetDefaultNAPDuration();


    duration =
        math.floor(
            duration
        );


    if duration < 1 then

        duration =
            1;
    end


    if duration > 20 then

        duration =
            20;
    end


    local key =
        EconomyPairKey(
            playerA,
            playerB
        );


    local endTurn =
        currentTurn
        + duration;


    diplomacy.nonAggressionPacts[
        key
    ] =
    {

        player1 =
            playerA,

        player2 =
            playerB,

        startTurn =
            currentTurn,

        endTurn =
            endTurn,

        duration =
            duration,

        active =
            true
    };


    RemoveNAPOffersBetween(
        data,
        playerA,
        playerB
    );


    local nameA =
        GetEconomicPlayerName(
            game,
            playerA
        );


    local nameB =
        GetEconomicPlayerName(
            game,
            playerB
        );


    local message =
        nameA ..
        " and " ..
        nameB ..
        " entered a " ..
        tostring(
            duration
        ) ..
        "-turn Non-Aggression Pact.";


    AddDiplomacyHistory(
        data,
        "nap_started",
        playerA,
        playerB,
        message,
        {

            endTurn =
                endTurn,

            reason =
                reason
                or "agreement"
        }
    );


    AddEconomyWorldEvent(
        data.globalEconomy,
        "nap_started",
        playerA,
        message,
        {

            otherPlayerID =
                playerB,

            endTurn =
                endTurn
        }
    );


    return true;

end


-- =========================================================
-- AI RESPONDS TO INCOMING NAP OFFERS
-- =========================================================

function ProcessAIIncomingNAPOffers(
    game,
    data
)

    local diplomacy =
        GetDiplomacyData(
            data
        );


    for i =
        #diplomacy.pendingNAPOffers,
        1,
        -1 do


        local offer =
            diplomacy.pendingNAPOffers[
                i
            ];


        local targetPlayer =
            GetEconomicPlayer(
                game,
                offer.toPlayerID
            );


        if targetPlayer ~= nil
            and targetPlayer.IsAI then


            local fromPlayerID =
                offer.fromPlayerID;


            local toPlayerID =
                offer.toPlayerID;


            if not IsNationEconomyReady(
                game,
                data,
                fromPlayerID
            )
            or not IsNationEconomyReady(
                game,
                data,
                toPlayerID
            )
            or IsDiplomacyWar(
                data,
                fromPlayerID,
                toPlayerID
            ) then


                table.remove(
                    diplomacy.pendingNAPOffers,
                    i
                );


            else


                local chance =
                    60;


                if HasAgreement(
                    data,
                    fromPlayerID,
                    toPlayerID
                ) then


                    chance =
                        chance + 20;
                end


                local accepted =
                    math.random(
                        1,
                        100
                    )
                    <= chance;


                if accepted then


                    local duration =
                        offer.duration
                        or GetDefaultNAPDuration();


                    table.remove(
                        diplomacy.pendingNAPOffers,
                        i
                    );


                    CreateDiplomacyNAP(
                        game,
                        data,
                        fromPlayerID,
                        toPlayerID,
                        duration,
                        "ai_accepted_offer"
                    );


                else


                    local fromName =
                        GetEconomicPlayerName(
                            game,
                            fromPlayerID
                        );


                    local aiName =
                        GetEconomicPlayerName(
                            game,
                            toPlayerID
                        );


                    table.remove(
                        diplomacy.pendingNAPOffers,
                        i
                    );


                    local message =
                        aiName ..
                        " rejected a Non-Aggression Pact proposal from " ..
                        fromName ..
                        ".";


                    AddDiplomacyHistory(
                        data,
                        "nap_rejected",
                        fromPlayerID,
                        toPlayerID,
                        message,
                        {

                            aiActivity =
                                true
                        }
                    );
                end
            end
        end
    end

end

-- =========================================================
-- AI RESPONDS TO INCOMING ALLIANCE OFFERS
-- =========================================================

function ProcessAIIncomingAllianceOffers(
    game,
    data
)

    local diplomacy =
        GetDiplomacyData(
            data
        );


    for i =
        #diplomacy.pendingAllianceOffers,
        1,
        -1 do

        local offer =
            diplomacy.pendingAllianceOffers[
                i
            ];


        local targetPlayer =
            GetEconomicPlayer(
                game,
                offer.toPlayerID
            );


        if targetPlayer ~= nil
            and targetPlayer.IsAI then

            local fromPlayerID =
                offer.fromPlayerID;

            local toPlayerID =
                offer.toPlayerID;


            if not IsNationEconomyReady(
                game,
                data,
                fromPlayerID
            )
                or not IsNationEconomyReady(
                    game,
                    data,
                    toPlayerID
                )
                or IsDiplomacyWar(
                    data,
                    fromPlayerID,
                    toPlayerID
                )
            then

                table.remove(
                    diplomacy.pendingAllianceOffers,
                    i
                );


            else

                local chance =
                    45;


                if HasAgreement(
                    data,
                    fromPlayerID,
                    toPlayerID
                ) then

                    chance =
                        chance + 20;

                end


                if GetActiveDiplomacyNAP(
                    data,
                    fromPlayerID,
                    toPlayerID
                ) ~= nil then

                    chance =
                        chance + 20;

                end


                if chance > 90 then

                    chance =
                        90;

                end


                local accepted =
                    math.random(
                        1,
                        100
                    )
                    <= chance;


                local fromName =
                    GetEconomicPlayerName(
                        game,
                        fromPlayerID
                    );


                local aiName =
                    GetEconomicPlayerName(
                        game,
                        toPlayerID
                    );


                table.remove(
                    diplomacy.pendingAllianceOffers,
                    i
                );


                if accepted then

                    local pairKey =
                        EconomyPairKey(
                            fromPlayerID,
                            toPlayerID
                        );


                    diplomacy.alliances[
                        pairKey
                    ] =
                    {

                        player1 =
                            fromPlayerID,

                        player2 =
                            toPlayerID,

                        startTurn =
                            GetCurrentDiplomacyTurn(
                                data
                            ),

                        active =
                            true
                    };


                    AddDiplomacyHistory(
                        data,
                        "alliance_formed",
                        fromPlayerID,
                        toPlayerID,
                        fromName ..
                        " and " ..
                        aiName ..
                        " formed an Alliance.",
                        {
                            aiActivity =
                                true
                        }
                    );


                else

                    AddDiplomacyHistory(
                        data,
                        "alliance_rejected",
                        fromPlayerID,
                        toPlayerID,
                        aiName ..
                        " rejected the Alliance proposal from " ..
                        fromName ..
                        ".",
                        {
                            aiActivity =
                                true
                        }
                    );

                end

            end

        end

    end

end

-- =========================================================
-- AI INCOMING FACTION INVITES
-- =========================================================

function ProcessAIIncomingFactionInvites(
    game,
    data
)

    local diplomacy =
        GetDiplomacyData(
            data
        );


    diplomacy.factions =
        diplomacy.factions or {};

    diplomacy.pendingFactionInvites =
        diplomacy.pendingFactionInvites or {};

    diplomacy.playerFaction =
        diplomacy.playerFaction or {};


    for i =
        #diplomacy.pendingFactionInvites,
        1,
        -1 do

        local invite =
            diplomacy.pendingFactionInvites[
                i
            ];


        local targetPlayer =
            GetEconomicPlayer(
                game,
                invite.toPlayerID
            );


        if targetPlayer ~= nil
            and targetPlayer.IsAI then


            local faction =
                diplomacy.factions[
                    invite.factionID
                ];


            local fromPlayerID =
                invite.fromPlayerID;

            local toPlayerID =
                invite.toPlayerID;


            -- Invalid invite
            if faction == nil
                or diplomacy.playerFaction[
                    toPlayerID
                ] ~= nil
                or not IsNationEconomyReady(
                    game,
                    data,
                    fromPlayerID
                )
                or not IsNationEconomyReady(
                    game,
                    data,
                    toPlayerID
                )
                or IsDiplomacyWar(
                    data,
                    fromPlayerID,
                    toPlayerID
                ) then


                table.remove(
                    diplomacy.pendingFactionInvites,
                    i
                );


            else

                -- Placeholder AI logic.
                -- We will replace this during the full AI pass later.
                local accepted =
                    math.random(
                        1,
                        100
                    ) <= 50;


                local aiName =
                    GetEconomicPlayerName(
                        game,
                        toPlayerID
                    );


                local factionName =
                    tostring(
                        faction.name
                        or "Faction"
                    );


                table.remove(
                    diplomacy.pendingFactionInvites,
                    i
                );


                if accepted then

                    faction.members =
                        faction.members or {};


                    faction.members[
                        toPlayerID
                    ] =
                        true;


                    diplomacy.playerFaction[
                        toPlayerID
                    ] =
                        invite.factionID;


                    AddDiplomacyHistory(
                        data,
                        "faction_joined",
                        toPlayerID,
                        fromPlayerID,
                        aiName ..
                        " joined the Faction \"" ..
                        factionName ..
                        "\".",
                        {
                            factionID =
                                invite.factionID,

                            aiActivity =
                                true
                        }
                    );


                else

                    AddDiplomacyHistory(
                        data,
                        "faction_invite_rejected",
                        toPlayerID,
                        fromPlayerID,
                        aiName ..
                        " rejected the invitation to join \"" ..
                        factionName ..
                        "\".",
                        {
                            factionID =
                                invite.factionID,

                            aiActivity =
                                true
                        }
                    );

                end

            end

        end

    end

end

-- =========================================================
-- AI CONSIDERS NEW NON-AGGRESSION PACT
-- =========================================================

function AIConsiderNAP(
    game,
    data,
    aiPlayerID
)

    if math.random(
        1,
        100
    ) > GetAINAPChance() then


        return;
    end


    local candidates =
        {};


    for playerID, _
        in pairs(
            game.Game.Players
        ) do


        if playerID
            ~= aiPlayerID

            and IsNationEconomyReady(
                game,
                data,
                playerID
            )

            and not IsDiplomacyWar(
                data,
                aiPlayerID,
                playerID
            )

            and GetActiveDiplomacyNAP(
                data,
                aiPlayerID,
                playerID
            ) == nil

            and not HasPendingDiplomacyNAP(
                data,
                aiPlayerID,
                playerID
            )

            and not HasPendingDiplomacyWar(
                data,
                aiPlayerID,
                playerID
            )
        then


            table.insert(
                candidates,
                playerID
            );
        end
    end


    if #candidates == 0 then

        return;
    end


    local targetPlayerID =
        candidates[
            math.random(
                1,
                #candidates
            )
        ];


    local target =
        GetEconomicPlayer(
            game,
            targetPlayerID
        );


    if target == nil then

        return;
    end


    local duration =
        GetDefaultNAPDuration();


    if target.IsAI then


        CreateDiplomacyNAP(
            game,
            data,
            aiPlayerID,
            targetPlayerID,
            duration,
            "ai_mutual_nap"
        );


    else


        local diplomacy =
            GetDiplomacyData(
                data
            );


        local currentTurn =
            GetCurrentDiplomacyTurn(
                data
            );


        table.insert(
            diplomacy.pendingNAPOffers,
            {

                fromPlayerID =
                    aiPlayerID,

                toPlayerID =
                    targetPlayerID,

                duration =
                    duration,

                offeredTurn =
                    currentTurn,

                active =
                    true,

                aiActivity =
                    true
            }
        );


        local aiName =
            GetEconomicPlayerName(
                game,
                aiPlayerID
            );


        local targetName =
            GetEconomicPlayerName(
                game,
                targetPlayerID
            );


        local message =
            aiName ..
            " proposed a " ..
            tostring(
                duration
            ) ..
            "-turn Non-Aggression Pact to " ..
            targetName ..
            ".";


        AddDiplomacyHistory(
            data,
            "nap_offered",
            aiPlayerID,
            targetPlayerID,
            message,
            {

                duration =
                    duration,

                aiActivity =
                    true
            }
        );
    end

end


-- =========================================================
-- AI CONSIDERS WAR
-- =========================================================

function AIConsiderWar(
    game,
    data,
    aiPlayerID
)

local nation =
    EnsureEconomyNation(
        game,
        data,
        aiPlayerID
    );

if nation == nil then
    return;
end

local aiProfile =
    EnsureAIProfile(
        nation,
        aiPlayerID
    );

local warChance =
    GetAIWarChance();

if aiProfile == "Growth" then

    warChance =
        warChance + 10;

elseif aiProfile == "Investor" then

    warChance =
        warChance - 5;

elseif aiProfile == "Planner" then

    warChance =
        warChance - 5;

elseif aiProfile == "Conservative" then

    warChance =
        warChance - 10;

end

warChance =
    math.max(
        1,
        math.min(
            100,
            warChance
        )
    );

if math.random(
    1,
    100
) > warChance then

    return;
end


    local targetPlayerID =
        FindAIWarTarget(
            game,
            data,
            aiPlayerID
        );


    if targetPlayerID == nil then

        return;
    end


    QueueAIWarDeclaration(
        game,
        data,
        aiPlayerID,
        targetPlayerID
    );

end


-- =========================================================
-- TURN PERFORMANCE CACHE / LARGE-GAME SCHEDULING
-- =========================================================
-- Mega Games can have 100+ players. Build one map/diplomacy snapshot per turn
-- and stagger non-urgent AI reviews rather than repeating full scans per AI.

local ADVANCE_TURN_PERFORMANCE_CACHE = nil;
local ADVANCE_TURN_ORDER_DATA_CACHE = nil;
local ADVANCE_TURN_BORDER_CACHE = {};

local function BuildAdvanceTurnPerformanceCache(game, data)
    local turn = data and data.tradeTurn or 0;
    if ADVANCE_TURN_PERFORMANCE_CACHE ~= nil
        and ADVANCE_TURN_PERFORMANCE_CACHE.turn == turn
    then
        return ADVANCE_TURN_PERFORMANCE_CACHE;
    end

    local cache = {
        turn = turn,
        playerCount = 0,
        ownedTerritories = {},
        atWar = {},
        playerThreat = {},
        territoryThreat = {},
        warPairs = {}
    };

    for playerID, player in pairs(game.Game.Players or {}) do
        if player ~= nil and not player.Surrendered then
            cache.playerCount = cache.playerCount + 1;
            cache.ownedTerritories[playerID] = {};
        end
    end

    local diplomacy = GetDiplomacyData(data);
    for _, relationship in pairs(diplomacy.relationships or {}) do
        if relationship ~= nil
            and relationship.status == "war"
            and relationship.player1 ~= nil
            and relationship.player2 ~= nil
        then
            local p1 = relationship.player1;
            local p2 = relationship.player2;
            cache.atWar[p1] = true;
            cache.atWar[p2] = true;
            cache.warPairs[EconomyPairKey(p1, p2)] = true;
        end
    end

    local standing = game.ServerGame and game.ServerGame.LatestTurnStanding;
    if standing ~= nil and standing.Territories ~= nil then
        for territoryID, territoryStanding in pairs(standing.Territories) do
            local owner = territoryStanding and territoryStanding.OwnerPlayerID or nil;
            if owner ~= nil and cache.ownedTerritories[owner] ~= nil then
                table.insert(cache.ownedTerritories[owner], territoryID);
            end
        end

        -- One map pass calculates enough local threat information for reserve
        -- planning and city placement. This replaces a full-map defense scan
        -- for every AI nation.
        for territoryID, territoryStanding in pairs(standing.Territories) do
            local owner = territoryStanding and territoryStanding.OwnerPlayerID or nil;
            local details = game.Map and game.Map.Territories and game.Map.Territories[territoryID] or nil;
            if owner ~= nil and details ~= nil and cache.ownedTerritories[owner] ~= nil then
                local threat = 0;
                for connectedID, _ in pairs(details.ConnectedTo or {}) do
                    local connected = standing.Territories[connectedID];
                    local otherOwner = connected and connected.OwnerPlayerID or nil;
                    if otherOwner ~= nil
                        and otherOwner ~= owner
                        and otherOwner ~= WL.PlayerID.Neutral
                        and cache.warPairs[EconomyPairKey(owner, otherOwner)] == true
                    then
                        local armies = connected.NumArmies and connected.NumArmies.NumArmies or 0;
                        threat = threat + math.floor(armies * 0.50) + 4;
                    end
                end
                cache.territoryThreat[territoryID] = threat;
                cache.playerThreat[owner] = math.max(cache.playerThreat[owner] or 0, threat);
            end
        end
    end

    ADVANCE_TURN_PERFORMANCE_CACHE = cache;
    return cache;
end

local function GetPerformanceCadence(game, data, workType)
    local count = BuildAdvanceTurnPerformanceCache(game, data).playerCount or 0;

    if count >= 100 then
        if workType == "diplomacy" then return 4; end
        if workType == "trade" then return 4; end
        if workType == "city" then return 4; end
        if workType == "economy" then return 2; end
    elseif count >= 50 then
        if workType == "diplomacy" then return 2; end
        if workType == "trade" then return 2; end
        if workType == "city" then return 2; end
    elseif count >= 25 then
        if workType == "diplomacy" then return 2; end
        if workType == "trade" then return 2; end
        if workType == "city" then return 2; end
    end

    return 1;
end

local function ShouldRunAIWork(data, playerID, cadence)
    cadence = math.max(1, cadence or 1);
    if cadence <= 1 then return true; end
    local id = math.abs(tonumber(playerID) or 0);
    return (((data.tradeTurn or 0) + id) % cadence) == 0;
end

local function GetStaggeredAIPhase(data, playerID, cadence, phaseCount)
    cadence = math.max(1, cadence or 1);
    phaseCount = math.max(1, phaseCount or 1);
    local id = math.abs(tonumber(playerID) or 0);
    return math.floor(((data.tradeTurn or 0) + id) / cadence) % phaseCount;
end

-- =========================================================
-- AI DIPLOMACY TURN
-- =========================================================

function ProcessAIDiplomacy(
    game,
    data
)

    -- First resolve offers humans or other nations
    -- previously sent to AI players.

    ProcessAIIncomingPeaceOffers(
        game,
        data
    );


    ProcessAIIncomingNAPOffers(
        game,
        data
    );

ProcessAIIncomingAllianceOffers(
    game,
    data
);

ProcessAIIncomingFactionInvites(
    game,
    data
);
    -- Then allow each active AI nation to make strategic diplomacy decisions.
    -- Incoming offers above still resolve every turn; only proactive reviews
    -- are staggered in larger games.

    local diplomacyCadence = GetPerformanceCadence(game, data, "diplomacy");

    for playerID, player
        in pairs(
            game.Game.Players
        ) do


        if player.IsAI
            and IsNationEconomyReady(
                game,
                data,
                playerID
            )
            and ShouldRunAIWork(data, playerID, diplomacyCadence)
        then


            local nation =
                EnsureEconomyNation(
                    game,
                    data,
                    playerID
                );
            
            UpdateAIStrategicReserve(
    game,
    data,
    playerID
);

local strategicState =
    nation.aiStrategicState
    or "stable";


            nation.aiLastDiplomacyReviewTurn =
                GetCurrentDiplomacyTurn(
                    data
                );


-- Peace can always be considered.
AIConsiderPeace(
    game,
    data,
    playerID
);


if strategicState == "recovery"
    or strategicState == "strained" then

    -- Weak nations seek stability.
    AIConsiderNAP(
        game,
        data,
        playerID
    );


elseif strategicState == "threatened" then

    -- Threatened nations look for diplomatic protection
    -- and do not start additional wars.
    AIConsiderNAP(
        game,
        data,
        playerID
    );


elseif strategicState == "war" then

    -- Already at war:
    -- consider peace, but do not start another war
    -- or aggressively pursue new diplomacy here.


elseif strategicState == "stable" then

    AIConsiderNAP(
        game,
        data,
        playerID
    );

    AIConsiderWar(
        game,
        data,
        playerID
    );


elseif strategicState == "expansion" then

    AIConsiderNAP(
        game,
        data,
        playerID
    );

    AIConsiderWar(
        game,
        data,
        playerID
    );

end

        end

    end

end
-- =========================================================
-- APPLY RESOURCE CHANGES
-- =========================================================

function ApplyResourceChanges(
    resourceChanges,
    addNewOrder
)

    local addResources =
        {};


    local foundAny =
        false;


    for playerID, amount
        in pairs(
            resourceChanges
        ) do


        if amount ~= 0 then


            foundAny =
                true;


            addResources[
                playerID
            ] =
                {};


            addResources[
                playerID
            ][
                WL.ResourceType.Gold
            ] =
                amount;
        end
    end


    if not foundAny then

        return;
    end


    local event =
        WL.GameOrderEvent.Create(
            WL.PlayerID.Neutral,
            "International investment activity",
            nil,
            {},
            nil,
            {}
        );


    event.AddResourceOpt =
        addResources;


    addNewOrder(
        event
    );

end


-- =========================================================
-- APPLY TRADE INCOME
-- =========================================================

function ApplyTradeIncome(
    game,
    data,
    addNewOrder
)

    local incomeMods =
        {};


    for _, agreement
        in pairs(
            data.activeAgreements
        ) do


        -- Final diplomacy safety check.
        -- Trade income can only exist between nations
        -- that are currently permitted to trade.

        local un =
            data.globalEconomy
            and data.globalEconomy.unitedNations
            or data.unitedNations
            or {};

        local p1Embargoed =
            un.embargoes ~= nil
            and un.embargoes[agreement.player1] ~= nil
            and (un.embargoes[agreement.player1].untilTurn or 0) >= (data.tradeTurn or 0);

        local p2Embargoed =
            un.embargoes ~= nil
            and un.embargoes[agreement.player2] ~= nil
            and (un.embargoes[agreement.player2].untilTurn or 0) >= (data.tradeTurn or 0);

        if CanNationsTrade(
            game,
            data,
            agreement.player1,
            agreement.player2
        )
            and not p1Embargoed
            and not p2Embargoed
        then


            local income1 =
                GetCommerceIncome(
                    game,
                    agreement.player1
                );


            local income2 =
                GetCommerceIncome(
                    game,
                    agreement.player2
                );


            local bonus1 =
                CalculateTradeBonus(
                    income2
                );


            local bonus2 =
                CalculateTradeBonus(
                    income1
                );


            if bonus1 > 0 then


                table.insert(
                    incomeMods,

                    WL.IncomeMod.Create(
                        agreement.player1,
                        bonus1,
                        "Trade Agreement",
                        nil
                    )
                );
            end


            if bonus2 > 0 then


                table.insert(
                    incomeMods,

                    WL.IncomeMod.Create(
                        agreement.player2,
                        bonus2,
                        "Trade Agreement",
                        nil
                    )
                );
            end

        end

    end


    if #incomeMods == 0 then

        return;
    end


    local event =
        WL.GameOrderEvent.Create(
            WL.PlayerID.Neutral,
            "Trade Agreement income bonuses",
            nil,
            {},
            nil,
            incomeMods
        );


    addNewOrder(
        event
    );

end

function GetAIBestCityTerritory(game, data, playerID)
    local standing = game.ServerGame and game.ServerGame.LatestTurnStanding;
    if standing == nil or standing.Territories == nil then return nil; end

    local perf = BuildAdvanceTurnPerformanceCache(game, data);
    local owned = perf.ownedTerritories[playerID] or {};
    local bestTerritoryID = nil;
    local bestScore = -999999;

    for _, territoryID in ipairs(owned) do
        local territoryStanding = standing.Territories[territoryID];
        if territoryStanding ~= nil then
            local structures = territoryStanding.Structures or {};
            local cityCount = structures[WL.StructureType.City] or 0;
            local threat = perf.territoryThreat[territoryID] or 0;
            local score = -(cityCount * 2) - math.floor(threat * 0.25);
            if score > bestScore then
                bestScore = score;
                bestTerritoryID = territoryID;
            end
        end
    end

    return bestTerritoryID;
end

function AIConsiderCityConstruction(
    game,
    data,
    playerID,
    addNewOrder
)

if game == nil
    or game.Settings == nil
    or addNewOrder == nil
then
    return;
end

local settings =
    game.Settings;

    -- Not a commerce game.
    if settings.CommerceGame ~= true then
        return;
    end

    local cityBaseCost =
        settings.CommerceCityBaseCost;

    -- Cities disabled.
    if cityBaseCost == nil
        or cityBaseCost <= 0
    then
        return;
    end

    local nation =
        EnsureEconomyNation(
            game,
            data,
            playerID
        );

    if nation == nil then
        return;
    end

    local strategicState =
        nation.aiStrategicState
        or "stable";

    -- Do not spend on cities while under pressure.
if strategicState == "war" then
    return;
end

    local currentGold =
        GetAvailableGold(
            game,
            {},
            playerID
        );

    if currentGold <= 0 then
        return;
    end

    local territoryID =
        GetAIBestCityTerritory(
            game,
            data,
            playerID
        );

    if territoryID == nil then
        return;
    end

    local standing =
        game.ServerGame.LatestTurnStanding;

    local territoryStanding =
        standing.Territories[
            territoryID
        ];

    if territoryStanding == nil then
        return;
    end

    local structures =
        territoryStanding.Structures
        or {};

    local existingCities =
        structures[
            WL.StructureType.City
        ]
        or 0;

    -- Built-in default behavior:
    -- base cost + 1 per existing city on this territory.
    local cityCost =
        cityBaseCost
        + existingCities;

    local aiProfile =
        EnsureAIProfile(
            nation,
            playerID
        );

    local reserveMultiplier =
        1.0;

    if aiProfile == "Growth" then
        reserveMultiplier = 1.10;

    elseif aiProfile == "Investor" then
        reserveMultiplier = 1.00;

    elseif aiProfile == "Balanced" then
        reserveMultiplier = 1.00;

    elseif aiProfile == "Planner" then
        reserveMultiplier = 1.25;

    elseif aiProfile == "Conservative" then
        reserveMultiplier = 1.50;
    end

    if currentGold
        < math.ceil(
            cityCost
            * reserveMultiplier
        )
    then
        return;
    end

    local terrMod =
        WL.TerritoryModification.Create(
            territoryID
        );

    terrMod.AddStructuresOpt =
    {
        [WL.StructureType.City] =
            1
    };

    local event =
        WL.GameOrderEvent.Create(
            playerID,
            "AI built a city",
            {},
            {
                terrMod
            },
            nil,
            nil
        );

    event.AddResourceOpt =
    {
        [playerID] =
        {
            [WL.ResourceType.Gold] =
                -cityCost
        }
    };

    addNewOrder(
        event
    );

end

function EnsureAIProfile(
    nation,
    playerID
)

    if nation == nil then
        return "Balanced";
    end

    if nation.aiProfile ~= nil then
        return nation.aiProfile;
    end

    local profiles =
    {
        "Growth",
        "Investor",
        "Balanced",
        "Planner",
        "Conservative"
    };

    local profileIndex =
        (
            math.abs(
                tonumber(playerID)
                or 1
            )
            % #profiles
        )
        + 1;

    nation.aiProfile =
        profiles[
            profileIndex
        ];

    return nation.aiProfile;

end

function UpdateAIStrategicReserve(
    game,
    data,
    playerID
)

    local economy =
        data.globalEconomy;

    if economy == nil then
        return;
    end

    local nation =
        EnsureEconomyNation(
            game,
            data,
            playerID
        );
    local aiProfile =
    EnsureAIProfile(
        nation,
        playerID
    );

    local profileReserveAdjustment =
    0;

if aiProfile == "Growth" then

    profileReserveAdjustment =
        -10;

elseif aiProfile == "Investor" then

    profileReserveAdjustment =
        -5;

elseif aiProfile == "Balanced" then

    profileReserveAdjustment =
        0;

elseif aiProfile == "Planner" then

    profileReserveAdjustment =
        10;

elseif aiProfile == "Conservative" then

    profileReserveAdjustment =
        15;

end

    if nation == nil then
        return;
    end

    local currentTurn =
        economy.currentEconomyTurn
        or data.tradeTurn
        or 1;

    local lastReviewTurn =
        nation.aiLastStrategicReviewTurn
        or 0;

    -- Review every turn for now.
    if currentTurn <= lastReviewTurn then
        return;
    end

    local reservePercent =
        GetSetting(
            "AIBaseReservePercent",
            40
        );

    local currentGold =
        GetAvailableGold(
            game,
            {},
            playerID
        );

    local perf = BuildAdvanceTurnPerformanceCache(game, data);
    local atWar = perf.atWar[playerID] == true;

local strategicState =
    "stable";

local bestDefenseValue =
    perf.playerThreat[playerID]
    or 0;

if atWar then

    strategicState =
        "war";

elseif currentGold < 75 then

    strategicState =
        "recovery";

elseif currentGold < 150 then

    strategicState =
        "strained";

elseif bestDefenseValue >= 20 then

    strategicState =
        "threatened";

elseif currentGold >= 500 then

    strategicState =
        "expansion";

else

    strategicState =
        "stable";

end

if strategicState == "war" then

    -- War has started: unlock most of the saved war chest.
    reservePercent =
        10;

elseif strategicState == "threatened" then

    -- Build a larger reserve when danger is nearby.
    reservePercent =
        30;

elseif strategicState == "recovery" then

    reservePercent =
        30;

elseif strategicState == "strained" then

    reservePercent =
        25;

elseif strategicState == "expansion" then

    reservePercent =
        15
        + profileReserveAdjustment;

else

    -- Stable peacetime reserve.
    reservePercent =
        20
        + profileReserveAdjustment;

end

reservePercent =
    math.max(
        10,
        math.min(
            30,
            reservePercent
        )
    );

    nation.aiStrategicState =
    strategicState;

    nation.aiDynamicReservePercent =
        reservePercent;

    nation.aiLastStrategicReviewTurn =
        currentTurn;

end

function GetAIBorderStatus(
    game,
    data,
    playerID,
    territoryID
)

    if game == nil
        or game.Map == nil
        or game.Map.Territories == nil
        or game.Game == nil
        or game.Game.Players == nil
    then
        return false, false;
    end

    local territoryDetails =
        game.Map.Territories[
            territoryID
        ];

    if territoryDetails == nil then
        return false, false;
    end

    local standing =
        game.ServerGame
        .LatestTurnStanding;

    if standing == nil
        or standing.Territories == nil
    then
        return false, false;
    end

    local hasForeignBorder =
        false;

    local hasWarBorder =
        false;

    for connectedTerritoryID, _
        in pairs(
            territoryDetails.ConnectedTo
            or {}
        )
    do

        local connectedStanding =
            standing.Territories[
                connectedTerritoryID
            ];

        if connectedStanding ~= nil then

            local otherPlayerID =
                connectedStanding.OwnerPlayerID;

            if otherPlayerID ~= nil
                and otherPlayerID ~= playerID
            then

                local otherPlayer =
                    game.Game.Players[
                        otherPlayerID
                    ];

                -- Ignore neutral/unowned territory.
                if otherPlayer ~= nil
                    and not otherPlayer.Surrendered
                then

                    hasForeignBorder =
                        true;

                    if IsDiplomacyWar(
                        data,
                        playerID,
                        otherPlayerID
                    ) then

                        hasWarBorder =
                            true;

                        break;

                    end

                end

            end

        end

    end

    return
        hasForeignBorder,
        hasWarBorder;

end

function GetAITerritoryDefenseValue(
    game,
    data,
    playerID,
    territoryID
)

    if game == nil
        or game.Map == nil
        or game.Map.Territories == nil then

        return 0;
    end

    local territoryDetails =
        game.Map.Territories[
            territoryID
        ];

    if territoryDetails == nil then
        return 0;
    end

    local standing =
        game.ServerGame
            .LatestTurnStanding;

    if standing == nil
        or standing.Territories == nil then

        return 0;
    end

    local defenseValue =
        0;


    -- =========================================
    -- BONUS VALUE
    -- =========================================

    for _, bonusID
        in ipairs(
            territoryDetails.PartOfBonuses
            or {}
        ) do

        local bonus =
            game.Map.Bonuses[
                bonusID
            ];

        if bonus ~= nil then

            local bonusAmount =
                bonus.Amount
                or 0;

            local ownsAll =
                true;

            for _, bonusTerritoryID
                in ipairs(
                    bonus.Territories
                    or {}
                ) do

                local bonusStanding =
                    standing.Territories[
                        bonusTerritoryID
                    ];

                if bonusStanding == nil
                    or bonusStanding.OwnerPlayerID
                    ~= playerID then

                    ownsAll =
                        false;

                    break;

                end

            end

            if ownsAll then

                defenseValue =
                    defenseValue
                    + (
                        bonusAmount
                        * 3
                    );

            else

                defenseValue =
                    defenseValue
                    + bonusAmount;

            end

        end

    end


    -- =========================================
    -- HOSTILE ADJACENT TERRITORIES
    -- =========================================

local hostileNeighborCount =
    0;

local friendlyNeighborCount =
    0;

    for connectedTerritoryID, _
        in pairs(
            territoryDetails.ConnectedTo
            or {}
        ) do

        local connectedStanding =
            standing.Territories[
                connectedTerritoryID
            ];

        if connectedStanding ~= nil then

            local connectedOwner =
                connectedStanding.OwnerPlayerID;

        if connectedOwner == playerID then

    friendlyNeighborCount =
        friendlyNeighborCount
        + 1;

end
            if connectedOwner ~= nil
                and connectedOwner ~= playerID
                and connectedOwner ~= WL.PlayerID.Neutral
                and IsDiplomacyWar(
                    data,
                    playerID,
                    connectedOwner
                )
            then

                hostileNeighborCount =
    hostileNeighborCount
    + 1;

                local enemyArmies =
                    0;

                if connectedStanding.NumArmies ~= nil then

                    enemyArmies =
                        connectedStanding.NumArmies.NumArmies
                        or 0;

                end

                defenseValue =
                    defenseValue
                    + math.floor(
                        enemyArmies
                        * 0.50
                    );

            end

        end

    end

    defenseValue =
    defenseValue
    + (
        hostileNeighborCount
        * 4
    );

if hostileNeighborCount > 0
    and friendlyNeighborCount <= 1
then

    defenseValue =
        defenseValue
        + 10;

end

    return math.max(
        0,
        defenseValue
    );

end

function GetAITerritoryAttackValue(
    game,
    data,
    playerID,
    territoryID
)

    if game == nil
        or game.Map == nil
        or game.Map.Territories == nil then

        return 0;
    end

    local territoryDetails =
        game.Map.Territories[
            territoryID
        ];

    if territoryDetails == nil then
        return 0;
    end

    local standing =
        game.ServerGame
            .LatestTurnStanding;

    if standing == nil
        or standing.Territories == nil then

        return 0;
    end

    local targetStanding =
        standing.Territories[
            territoryID
        ];

    if targetStanding == nil then
        return 0;
    end

    local attackValue =
        5;


    -- =========================================
    -- BONUS VALUE
    -- =========================================

    for _, bonusID
        in ipairs(
            territoryDetails.PartOfBonuses
            or {}
        ) do
 
        local bonus =
            game.Map.Bonuses[
                bonusID
            ];

        if bonus ~= nil then

            local bonusAmount =
                bonus.Amount
                or 0;

            local ownedCount =
                0;

            local totalCount =
                0;

            for _, bonusTerritoryID
                in ipairs(
                    bonus.Territories
                    or {}
                ) do

                totalCount =
                    totalCount
                    + 1;

                local bonusStanding =
                    standing.Territories[
                        bonusTerritoryID
                    ];

                if bonusStanding ~= nil
                    and bonusStanding.OwnerPlayerID
                    == playerID then

                    ownedCount =
                        ownedCount
                        + 1;

                end

            end

            attackValue =
                attackValue
                + bonusAmount;

            -- Very valuable if this capture would
            -- complete the bonus.
            if totalCount > 0
                and ownedCount
                == totalCount - 1 then

                attackValue =
                    attackValue
                    + (
                        bonusAmount
                        * 4
                    );

            end

local targetOwner =
    targetStanding.OwnerPlayerID;

if targetOwner ~= nil
    and targetOwner ~= playerID
    and targetOwner ~= WL.PlayerID.Neutral
then

    local enemyOwnsAll =
        true;

    for _, bonusTerritoryID
        in ipairs(
            bonus.Territories
            or {}
        ) do

        local bonusStanding =
            standing.Territories[
                bonusTerritoryID
            ];

        if bonusStanding == nil
            or bonusStanding.OwnerPlayerID
            ~= targetOwner
        then

            enemyOwnsAll =
                false;

            break;

        end

    end

    if enemyOwnsAll then

        attackValue =
            attackValue
            + (
                bonusAmount
                * 4
            );

    end

end

        end

    end


    -- =========================================
    -- TARGET DEFENDER STRENGTH
    -- =========================================

    local defendingArmies =
        0;

    if targetStanding.NumArmies ~= nil then

        defendingArmies =
            targetStanding.NumArmies.NumArmies
            or 0;

    end

    attackValue =
        attackValue
        - math.floor(
            defendingArmies
            * 0.25
        );


    return math.max(
        0,
        attackValue
    );

end

function GetAIBestDefenseTerritory(
    game,
    data,
    playerID
)

    if game == nil
        or game.Map == nil
        or game.Map.Territories == nil then

        return nil, 0;
    end

    local standing =
        game.ServerGame
            .LatestTurnStanding;

    if standing == nil
        or standing.Territories == nil then

        return nil, 0;
    end

    local bestTerritoryID =
        nil;

    local bestDefenseValue =
        0;

    for territoryID, territoryStanding
        in pairs(
            standing.Territories
        ) do

        if territoryStanding ~= nil
            and territoryStanding.OwnerPlayerID
            == playerID then

            local defenseValue =
                GetAITerritoryDefenseValue(
                    game,
                    data,
                    playerID,
                    territoryID
                );

            if defenseValue
                > bestDefenseValue then

                bestDefenseValue =
                    defenseValue;

                bestTerritoryID =
                    territoryID;

            end

        end

    end

    return
        bestTerritoryID,
        bestDefenseValue;

end

-- =========================================================
-- STRATEGIC RESOURCES
-- =========================================================

local RESOURCE_NAMES = {
    "Oil", "Gas", "Uranium", "Iron", "Food", "Rare Earths",
    "Coal", "Copper", "Lithium"
};

-- Resource map display uses one custom structure per territory.
-- The dominant resource selects the icon family and the image contains a
-- numeric badge for the combined facility level.  This avoids icon spam.
local RESOURCE_ICON_SAFE_NAMES = {
    Oil = "Oil", Gas = "Gas", Uranium = "Uranium", Iron = "Iron",
    Food = "Food", ["Rare Earths"] = "RareEarths", Coal = "Coal",
    Copper = "Copper", Lithium = "Lithium"
};

local function ResourceIconStructure(resourceName, totalLevel)
    local safe = RESOURCE_ICON_SAFE_NAMES[resourceName] or "Oil";
    local level = math.max(1, math.floor(tonumber(totalLevel) or 1));
    local suffix = level > 9 and "9plus" or tostring(level);
    return WL.StructureType.Custom("Resource" .. safe .. suffix);
end

local function GetPrimaryResource(nodes)
    local bestName = nil;
    local bestLevel = -1;
    for _, resourceName in ipairs(RESOURCE_NAMES) do
        local level = tonumber((nodes or {})[resourceName]) or 0;
        if level > bestLevel then
            bestName = resourceName;
            bestLevel = level;
        end
    end
    return bestName or "Oil";
end

local function GetTotalResourceLevel(nodes)
    local total = 0;
    for _, resourceName in ipairs(RESOURCE_NAMES) do
        total = total + math.max(0, tonumber((nodes or {})[resourceName]) or 0);
    end
    return total;
end

local function IsResourceCustomStructure(structureType)
    for _, safe in pairs(RESOURCE_ICON_SAFE_NAMES) do
        for level = 1, 9 do
            if structureType == WL.StructureType.Custom("Resource" .. safe .. tostring(level)) then
                return true;
            end
        end
        if structureType == WL.StructureType.Custom("Resource" .. safe .. "9plus") then
            return true;
        end
    end
    return false;
end

local function BuildResourceIconStructureTable(existingStructures, nodes)
    local structures = {};
    for structureType, count in pairs(existingStructures or {}) do
        if structureType ~= WL.StructureType.ResourceCache
            and not IsResourceCustomStructure(structureType)
        then
            structures[structureType] = count;
        end
    end

    local totalLevel = GetTotalResourceLevel(nodes);
    if totalLevel > 0 then
        local primary = GetPrimaryResource(nodes);
        structures[ResourceIconStructure(primary, totalLevel)] = 1;
    end
    return structures;
end

local function EnsureStrategicResourceState(data)
    local economy = data.globalEconomy;
    if economy == nil then return nil; end
    economy.resources = economy.resources or {
        enabled = GetSetting("ResourcesEnabled", true),
        advancedEnabled = GetSetting("AdvancedResourcesEnabled", true),
        randomizedPlacement = GetSetting("RandomizedResourcePlacement", false),
        territories = {}, pendingBuilds = {}, pendingOffers = {},
        activeTrades = {}, tradeHistory = {}, nextOfferID = 1
    };
    local r = economy.resources;
    r.mapIconsEnabled =
        GetSetting(
            "ResourceMapIconsEnabled",
            r.mapIconsEnabled ~= false
        );
    r.territories = r.territories or {};
    r.pendingBuilds = r.pendingBuilds or {};
    r.pendingOffers = r.pendingOffers or {};
    r.activeTrades = r.activeTrades or {};
    r.tradeHistory = r.tradeHistory or {};
    r.nextOfferID = r.nextOfferID or 1;
    return r;
end

local function EnsureNationResourceState(nation)
    nation.resourceProduction = nation.resourceProduction or {};
    nation.resourceEffective = nation.resourceEffective or {};
    nation.resourceStockpile = nation.resourceStockpile or {};
    nation.resourceStockpileChange = nation.resourceStockpileChange or {};
    nation.resourceShortages = nation.resourceShortages or {};
    nation.resourceRequirements = nation.resourceRequirements or {};
    if nation.resourceRequirementsInitialized == nil then nation.resourceRequirementsInitialized = false; end
    nation.resourcePenaltyPercent = nation.resourcePenaltyPercent or 0;
    nation.resourceMilitaryReadiness = nation.resourceMilitaryReadiness or 100;
    nation.resourceUnrest = nation.resourceUnrest or 0;
    nation.resourceBuildReservedGold = nation.resourceBuildReservedGold or 0;
end

local function EmptyResourceTable()
    local t = {};
    for _, resourceName in ipairs(RESOURCE_NAMES) do t[resourceName] = 0; end
    return t;
end

local function ProcessPendingResourceBuilds(game, data, resourceChanges, addNewOrder)
    local resources = EnsureStrategicResourceState(data);
    if resources == nil or resources.enabled ~= true then return; end
    local standing = game.ServerGame and game.ServerGame.LatestTurnStanding;
    if standing == nil or standing.Territories == nil then return; end

    local remaining = {};
    for _, build in ipairs(resources.pendingBuilds or {}) do
        local nation = data.globalEconomy.nations[build.playerID];
        if nation ~= nil then EnsureNationResourceState(nation); end
        local terr = standing.Territories[build.territoryID];
        local nodes = resources.territories[build.territoryID];
        local currentLevel = nodes and nodes[build.resource] or 0;

        if nation ~= nil
            and terr ~= nil
            and terr.OwnerPlayerID == build.playerID
            and currentLevel == build.fromLevel
        then
            resources.territories[build.territoryID] = nodes or {};
            nodes = resources.territories[build.territoryID];
            nodes[build.resource] = build.toLevel;
            local terrMod = WL.TerritoryModification.Create(build.territoryID);

            -- Refresh the single resource icon after the upgrade.  The dominant
            -- resource chooses the icon and the total facility level is baked into
            -- the icon badge, so the territory always shows exactly one resource icon.
            if resources.mapIconsEnabled ~= false
                and GetSetting("ResourceMapIconsEnabled", true) == true
            then
                terrMod.SetStructuresOpt =
                    BuildResourceIconStructureTable(
                        terr.Structures or {},
                        nodes
                    );
            end

            local event = WL.GameOrderEvent.Create(
                build.playerID,
                build.resource .. " facility upgraded to level " .. tostring(build.toLevel),
                {}, {terrMod}, nil, nil
            );
            addNewOrder(event);
            -- New builds are already paid when ordered. Keep legacy compatibility.
            if build.paid ~= true then
                AddResourceChange(resourceChanges, build.playerID, -(build.cost or 0));
            end
            nation.resourceBuildReservedGold = math.max(0, (nation.resourceBuildReservedGold or 0) - (build.cost or 0));
        else
            -- If a paid build cannot complete (most commonly because the territory was lost), refund it.
            if nation ~= nil and build.paid == true and (build.cost or 0) > 0 then
                AddResourceChange(resourceChanges, build.playerID, build.cost or 0);
            end
            if nation ~= nil then
                nation.resourceBuildReservedGold = math.max(0, (nation.resourceBuildReservedGold or 0) - (build.cost or 0));
            end
        end
    end
    resources.pendingBuilds = remaining;
end

local function EnsureArmyRecruiterState(data)
    local economy = data.globalEconomy;
    if economy == nil then return nil; end
    economy.armyRecruiters = economy.armyRecruiters or {enabled=true, territories={}, pendingBuilds={}};
    local r = economy.armyRecruiters;
    r.territories = r.territories or {}; r.pendingBuilds = r.pendingBuilds or {};
    r.enabled = GetSetting("ArmyRecruitersEnabled", true) == true;
    return r;
end

local function RecruiterStructureName(level)
    return "ArmyRecruiter" .. tostring(math.max(1, math.min(5, math.floor(tonumber(level) or 1))));
end

local function BuildRecruiterStructures(existing, level)
    local result = {};
    for structureType, amount in pairs(existing or {}) do
        local key = tostring(structureType);
        if string.find(key, "ArmyRecruiter", 1, true) == nil then result[structureType] = amount; end
    end
    if (tonumber(level) or 0) > 0 then result[WL.StructureType.Custom(RecruiterStructureName(level))] = 1; end
    return result;
end

local function ProcessPendingArmyRecruiters(game, data, resourceChanges, addNewOrder)
    local r = EnsureArmyRecruiterState(data); if r == nil or r.enabled ~= true then return; end
    local standing = game.ServerGame and game.ServerGame.LatestTurnStanding; if standing == nil then return; end
    local pending = r.pendingBuilds or {}; r.pendingBuilds = {};
    for _, build in ipairs(pending) do
        local terr = standing.Territories[build.territoryID];
        if terr ~= nil and terr.OwnerPlayerID == build.playerID then
            r.territories[build.territoryID] = build.toLevel;
            local mod = WL.TerritoryModification.Create(build.territoryID);
            mod.SetStructuresOpt = BuildRecruiterStructures(terr.Structures or {}, build.toLevel);
            addNewOrder(WL.GameOrderEvent.Create(build.playerID, "Army Recruiter upgraded to level " .. tostring(build.toLevel), {}, {mod}, nil, nil));
        else
            -- The order was prepaid; refund if ownership was lost before construction resolved.
            r.territories[build.territoryID] = build.fromLevel or nil;
            if build.paid == true and (build.cost or 0) > 0 then AddResourceChange(resourceChanges, build.playerID, build.cost or 0); end
        end
    end
end

local function ProcessArmyRecruiterProduction(game, data, addNewOrder)
    local r = EnsureArmyRecruiterState(data); if r == nil or r.enabled ~= true then return; end
    local economy = data.globalEconomy; local standing = game.ServerGame and game.ServerGame.LatestTurnStanding;
    if standing == nil then return; end
    for _, nation in pairs(economy.nations or {}) do nation.armyRecruiterCount=0; nation.armyRecruiterLevels=0; nation.armyRecruiterArmiesGeneratedThisTurn=0; end
    local base = math.max(1, math.floor(tonumber(GetSetting("ArmyRecruiterArmiesPerTurn", 4)) or 4));
    for territoryID, level in pairs(r.territories or {}) do
        level = math.max(0, math.floor(tonumber(level) or 0));
        local terr = standing.Territories[territoryID]; local owner = terr and terr.OwnerPlayerID or nil; local nation = owner and economy.nations[owner] or nil;
        if level > 0 and nation ~= nil and nation.eliminated ~= true then
            nation.armyRecruiterCount = (nation.armyRecruiterCount or 0) + 1; nation.armyRecruiterLevels = (nation.armyRecruiterLevels or 0) + level;
            local readiness = math.max(0, math.min(100, tonumber(nation.resourceMilitaryReadiness) or 100));
            local armies = math.max(0, math.floor(base * level * readiness / 100 + 0.5));
            if armies > 0 then
                addNewOrder(WL.GameOrderDeploy.Create(owner, armies, territoryID, true));
                nation.armyRecruiterArmiesGeneratedThisTurn = (nation.armyRecruiterArmiesGeneratedThisTurn or 0) + armies;
            end
        end
    end
end

local function ProcessStrategicResources(game, data, resourceChanges)
    local resources = EnsureStrategicResourceState(data);
    local economy = data.globalEconomy;
    if resources == nil or resources.enabled ~= true or economy == nil then return; end

    local standing = game.ServerGame and game.ServerGame.LatestTurnStanding;
    if standing == nil or standing.Territories == nil then return; end

    for playerID, nation in pairs(economy.nations or {}) do
        EnsureNationResourceState(nation);
        nation.resourceProduction = EmptyResourceTable();
        nation.resourceEffective = EmptyResourceTable();
        nation.resourceStockpileChange = EmptyResourceTable();
        nation.resourceShortages = {};
    end

    -- Performance-safe: iterate only cached resource territories, not the whole map.
    for territoryID, nodes in pairs(resources.territories or {}) do
        local terr = standing.Territories[territoryID];
        local owner = terr and terr.OwnerPlayerID or nil;
        local nation = owner and economy.nations[owner] or nil;
        if nation ~= nil and nation.eliminated ~= true then
            for resourceName, level in pairs(nodes) do
                nation.resourceProduction[resourceName] =
                    (nation.resourceProduction[resourceName] or 0) + (tonumber(level) or 0);
            end
        end
    end

    for _, nation in pairs(economy.nations or {}) do
        -- A nation's peacetime maintenance requirement is locked from its
        -- original production profile.  Losing any of that strategic base can
        -- therefore create a real shortage; later facilities/captures create
        -- surplus instead of permanently raising the baseline.
        if nation.resourceRequirementsInitialized ~= true then
            nation.resourceRequirements = {};
            for _, resourceName in ipairs(RESOURCE_NAMES) do
                nation.resourceRequirements[resourceName] = nation.resourceProduction[resourceName] or 0;
            end
            nation.resourceRequirementsInitialized = true;
        end

        for _, resourceName in ipairs(RESOURCE_NAMES) do
            nation.resourceEffective[resourceName] = nation.resourceProduction[resourceName] or 0;
        end
    end

    -- Recurring resource contracts transfer current-turn production before
    -- national stockpiles are updated. Unsold surplus can then be stored,
    -- while any remaining deficit can be covered from the stockpile.
    local goldRemaining = {};
    for playerID, nation in pairs(economy.nations or {}) do
        goldRemaining[playerID] = math.max(0, GetStoredGold(game, playerID));
    end

    local activeTrades = {};
    for _, trade in ipairs(resources.activeTrades or {}) do
        local seller = economy.nations[trade.fromPlayerID];
        local buyer = economy.nations[trade.toPlayerID];
        local un =
            economy.unitedNations
            or data.unitedNations
            or {};

        local sellerEmbargoed =
            un.embargoes ~= nil
            and un.embargoes[trade.fromPlayerID] ~= nil
            and (un.embargoes[trade.fromPlayerID].untilTurn or 0) >= (data.tradeTurn or 0);

        local buyerEmbargoed =
            un.embargoes ~= nil
            and un.embargoes[trade.toPlayerID] ~= nil
            and (un.embargoes[trade.toPlayerID].untilTurn or 0) >= (data.tradeTurn or 0);

        if seller ~= nil and buyer ~= nil
            and seller.eliminated ~= true and buyer.eliminated ~= true
            and not sellerEmbargoed
            and not buyerEmbargoed
        then
            local available = seller.resourceEffective[trade.resource] or 0;
            local desired = math.max(0, tonumber(trade.amount) or 0);
            local price = math.max(0, tonumber(trade.pricePerUnit) or 0);
            local affordable = desired;
            if price > 0 then
                affordable = math.floor((goldRemaining[trade.toPlayerID] or 0) / price);
            end
            local transferred = math.min(available, desired, affordable);
            if transferred > 0 then
                seller.resourceEffective[trade.resource] = available - transferred;
                buyer.resourceEffective[trade.resource] = (buyer.resourceEffective[trade.resource] or 0) + transferred;
                local payment = transferred * price;
                if payment > 0 then
                    AddResourceChange(resourceChanges, trade.fromPlayerID, payment);
                    AddResourceChange(resourceChanges, trade.toPlayerID, -payment);
                    goldRemaining[trade.toPlayerID] = math.max(0, (goldRemaining[trade.toPlayerID] or 0) - payment);
                end
                trade.lastTransferred = transferred;
                trade.lastProcessedTurn = data.tradeTurn or 0;
            else
                trade.lastTransferred = 0;
                trade.lastProcessedTurn = data.tradeTurn or 0;
            end
            table.insert(activeTrades, trade);
        elseif seller ~= nil and buyer ~= nil
            and seller.eliminated ~= true and buyer.eliminated ~= true
        then
            -- UN embargo pauses deliveries; it does not permanently delete
            -- the contract.  Delivery automatically resumes when the embargo expires.
            trade.lastTransferred = 0;
            trade.lastProcessedTurn = data.tradeTurn or 0;
            trade.pausedByUNEmbargo = true;
            table.insert(activeTrades, trade);
        end
    end
    resources.activeTrades = activeTrades;

    local basePenalty =
        math.max(
            0,
            tonumber(
                GetSetting(
                    "ResourceShortagePenaltyPercent",
                    3
                )
            )
            or 3
        );

    local unrestEnabled =
        GetSetting(
            "ResourceUnrestEnabled",
            true
        )
        == true;

    for playerID, nation
        in pairs(
            economy.nations
            or {}
        )
    do

        if nation.eliminated ~= true then

            local commerce =
                math.max(
                    1,
                    GetCommerceIncome(
                        game,
                        playerID
                    )
                );

            -- Fixed strategic maintenance baseline: the nation must maintain
            -- the production level it began the resource system with.
            local demands = {};
            for _, resourceName in ipairs(RESOURCE_NAMES) do
                demands[resourceName] = math.max(
                    0,
                    tonumber((nation.resourceRequirements or {})[resourceName]) or 0
                );
            end

            -- Army Recruiter levels increase military maintenance requirements.
            local recruiterState = EnsureArmyRecruiterState(data);
            local recruiterLevels = 0;
            if recruiterState ~= nil then
                for territoryID, level in pairs(recruiterState.territories or {}) do
                    local rt = standing.Territories[territoryID];
                    if rt ~= nil and rt.OwnerPlayerID == playerID then recruiterLevels = recruiterLevels + math.max(0, tonumber(level) or 0); end
                end
            end
            if recruiterLevels > 0 then
                demands.Oil = (demands.Oil or 0) + recruiterLevels;
                demands.Food = (demands.Food or 0) + recruiterLevels;
                demands.Iron = (demands.Iron or 0) + recruiterLevels;
            end

            local readinessPenalty =
                0;

            local commercePenalty =
                0;

            local unrestGain =
                0;

            for resourceName, demand
                in pairs(
                    demands
                )
            do

                local have =
                    nation.resourceEffective[
                        resourceName
                    ]
                    or 0;

                local stored =
                    math.max(
                        0,
                        tonumber((nation.resourceStockpile or {})[resourceName]) or 0
                    );

                local net = have - demand;

                if net >= 0 then

                    -- Any production left after this turn's requirements is
                    -- preserved for future turns instead of disappearing.
                    nation.resourceStockpile[resourceName] = stored + net;
                    nation.resourceStockpileChange[resourceName] = net;

                else

                    local missing = -net;
                    local fromStockpile = math.min(stored, missing);

                    nation.resourceStockpile[resourceName] = stored - fromStockpile;
                    nation.resourceStockpileChange[resourceName] = -fromStockpile;

                    local uncovered = missing - fromStockpile;

                    if uncovered > 0 then

                        nation.resourceShortages[
                            resourceName
                        ] =
                            uncovered;

                    -- Every resource has a distinct role.
                    if resourceName == "Oil" then

                        readinessPenalty =
                            readinessPenalty
                            + 15 * uncovered;

                    elseif resourceName == "Food" then

                        readinessPenalty =
                            readinessPenalty
                            + 10 * uncovered;

                        unrestGain =
                            unrestGain
                            + 3 * uncovered;

                    elseif resourceName == "Iron" then

                        readinessPenalty =
                            readinessPenalty
                            + 12 * uncovered;

                    elseif resourceName == "Gas" then

                        readinessPenalty =
                            readinessPenalty
                            + 5 * uncovered;

                        commercePenalty =
                            commercePenalty
                            + basePenalty * uncovered;

                    elseif resourceName == "Coal" then

                        commercePenalty =
                            commercePenalty
                            + 2 * uncovered;

                    elseif resourceName == "Copper" then

                        commercePenalty =
                            commercePenalty
                            + 2 * uncovered;

                    elseif resourceName == "Rare Earths" then

                        readinessPenalty =
                            readinessPenalty
                            + 3 * uncovered;

                        commercePenalty =
                            commercePenalty
                            + 1 * uncovered;

                    elseif resourceName == "Lithium" then

                        readinessPenalty =
                            readinessPenalty
                            + 2 * uncovered;

                        commercePenalty =
                            commercePenalty
                            + 1 * uncovered;

                    end

                    end

                end
            end

            -- Existing armies are never deleted.
            -- Readiness represents future mobilization efficiency.
            nation.resourceMilitaryReadiness =
                math.max(
                    50,
                    100
                    - math.min(
                        50,
                        readinessPenalty
                    )
                );

            -- Wartime decisions can temporarily raise or lower readiness without
            -- ever deleting armies already on the map.
            local warEventUntil =
                tonumber(
                    nation.warEventReadinessUntilTurn
                )
                or 0;

            if warEventUntil >= (data.tradeTurn or 0) then

                nation.resourceMilitaryReadiness =
                    math.max(
                        50,
                        math.min(
                            100,
                            nation.resourceMilitaryReadiness
                            + (tonumber(nation.warEventReadinessModifier) or 0)
                        )
                    );

            else

                nation.warEventReadinessModifier = 0;
                nation.warEventReadinessUntilTurn = 0;

            end

            nation.resourceMobilizationPenaltyPercent =
                100
                - nation.resourceMilitaryReadiness;

            -- Readiness does not remove armies already on the map.
            -- Instead it creates a future-mobilization burden by
            -- reducing the Commerce left available for new army purchases.
            nation.resourceMobilizationCommercePenaltyPercent =
                math.min(
                    15,
                    math.floor(
                        (
                            nation.resourceMobilizationPenaltyPercent
                            * 0.30
                        )
                        + 0.5
                    )
                );

            nation.resourcePenaltyPercent =
                math.min(
                    15,
                    commercePenalty
                );

            if unrestEnabled then

                if unrestGain > 0 then

                    nation.resourceUnrest =
                        math.min(
                            100,
                            (
                                nation.resourceUnrest
                                or 0
                            )
                            + unrestGain
                        );

                elseif next(
                    nation.resourceShortages
                    or {}
                ) ~= nil then

                    nation.resourceUnrest =
                        math.min(
                            100,
                            (
                                nation.resourceUnrest
                                or 0
                            )
                            + 1
                        );

                else

                    nation.resourceUnrest =
                        math.max(
                            0,
                            (
                                nation.resourceUnrest
                                or 0
                            )
                            - 2
                        );

                end
            end

            local totalResourceGoldPenaltyPercent =
                math.min(
                    25,
                    (
                        nation.resourcePenaltyPercent
                        or 0
                    )
                    + (
                        nation.resourceMobilizationCommercePenaltyPercent
                        or 0
                    )
                );

            if totalResourceGoldPenaltyPercent > 0 then

                local penaltyGold =
                    math.floor(
                        (
                            commerce
                            * totalResourceGoldPenaltyPercent
                            / 100
                        )
                        + 0.5
                    );

                if penaltyGold > 0 then

                    AddResourceChange(
                        resourceChanges,
                        playerID,
                        -penaltyGold
                    );

                end
            end

        end
    end

end



-- =========================================================
-- UNITED NATIONS / SECURITY COUNCIL
-- =========================================================

local function EnsureUnitedNationsState(data)

    local economy =
        data.globalEconomy;

    if economy == nil then
        return nil;
    end

    economy.unitedNations =
        economy.unitedNations
        or data.unitedNations
        or {
            enabled =
                GetSetting(
                    "UnitedNationsEnabled",
                    true
                ),

            activeResolutions = {},
            resolutionHistory = {},
            nextResolutionID = 1,
            lastProposalTurnByPlayer = {},
            permanentMembers = {},
            rotatingMembers = {},
            councilInitialized = false,
            lastCouncilRefreshTurn = 0,
            sanctions = {},
            embargoes = {},
            condemnations = {}
        };

    local un =
        economy.unitedNations;

    un.enabled =
        GetSetting(
            "UnitedNationsEnabled",
            un.enabled ~= false
        );

    un.activeResolutions =
        un.activeResolutions
        or {};

    un.resolutionHistory =
        un.resolutionHistory
        or {};

    un.nextResolutionID =
        un.nextResolutionID
        or 1;

    un.lastProposalTurnByPlayer =
        un.lastProposalTurnByPlayer
        or {};

    un.permanentMembers =
        un.permanentMembers
        or {};

    un.rotatingMembers =
        un.rotatingMembers
        or {};

    un.sanctions =
        un.sanctions
        or {};

    un.embargoes =
        un.embargoes
        or {};

    un.condemnations =
        un.condemnations
        or {};

    data.unitedNations =
        un;

    return un;
end


local function UNListContains(
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


local function UNPlayerAvailable(
    game,
    data,
    playerID
)

    local player =
        game.Game.Players[
            playerID
        ];

    local nation =
        data.globalEconomy
            .nations[
                playerID
            ];

    return player ~= nil
        and player.Surrendered ~= true
        and nation ~= nil
        and nation.eliminated ~= true;
end


local function UNPowerScore(
    game,
    data,
    playerID
)

    local nation =
        data.globalEconomy
            .nations[
                playerID
            ]
        or {};

    local commerce =
        math.max(
            0,
            GetCommerceIncome(
                game,
                playerID
            )
        );

    local readiness =
        nation.resourceMilitaryReadiness
        or 100;

    local gold =
        math.max(
            0,
            GetStoredGold(
                game,
                playerID
            )
        );

    return
        commerce
        + math.floor(
            gold * 0.15
        )
        + math.floor(
            readiness * 2
        );
end


local function UNEligiblePlayerIDs(
    game,
    data
)

    local ids =
        {};

    for playerID, _
        in pairs(
            game.Game.Players
            or {}
        )
    do

        if UNPlayerAvailable(
            game,
            data,
            playerID
        ) then

            table.insert(
                ids,
                playerID
            );

        end
    end

    table.sort(
        ids
    );

    return ids;
end


local function UNConfiguredPermanentPlayers(
    game,
    data
)

    local eligible =
        UNEligiblePlayerIDs(
            game,
            data
        );

    local configured =
        {};

    for index = 1, 5 do

        local slot =
            math.floor(
                tonumber(
                    GetSetting(
                        "UNPermanentSeatSlot"
                        .. tostring(index),
                        0
                    )
                )
                or 0
            );

        local playerID =
            slot > 0
            and eligible[
                slot
            ]
            or nil;

        if playerID ~= nil
            and not UNListContains(
                configured,
                playerID
            )
        then

            table.insert(
                configured,
                playerID
            );

        end
    end

    return configured;
end


local function UNChooseReplacementByCouncil(
    game,
    data,
    existingPermanent,
    existingRotating,
    candidates
)

    if #candidates == 0 then
        return nil;
    end

    local votes =
        {};

    for _, candidateID
        in ipairs(
            candidates
        )
    do

        votes[
            candidateID
        ] =
            0;
    end

    local council =
        {};

    for _, playerID
        in ipairs(
            existingPermanent
            or {}
        )
    do

        table.insert(
            council,
            playerID
        );
    end

    for _, playerID
        in ipairs(
            existingRotating
            or {}
        )
    do

        if not UNListContains(
            council,
            playerID
        ) then

            table.insert(
                council,
                playerID
            );

        end
    end

    for _, voterID
        in ipairs(
            council
        )
    do

        if UNPlayerAvailable(
            game,
            data,
            voterID
        ) then

            local bestCandidate =
                candidates[1];

            local bestScore =
                -1;

            for _, candidateID
                in ipairs(
                    candidates
                )
            do

                local score =
                    UNPowerScore(
                        game,
                        data,
                        candidateID
                    );

                if IsDiplomacyWar(
                    data,
                    voterID,
                    candidateID
                ) then

                    score =
                        score
                        - 100000;

                end

                if score > bestScore then

                    bestScore =
                        score;

                    bestCandidate =
                        candidateID;

                end
            end

            votes[
                bestCandidate
            ] =
                (
                    votes[
                        bestCandidate
                    ]
                    or 0
                )
                + 1;

        end
    end

    local winner =
        candidates[1];

    local winnerVotes =
        -1;

    for _, candidateID
        in ipairs(
            candidates
        )
    do

        local count =
            votes[
                candidateID
            ]
            or 0;

        if count > winnerVotes then

            winnerVotes =
                count;

            winner =
                candidateID;

        elseif count == winnerVotes
            and UNPowerScore(
                game,
                data,
                candidateID
            )
            >
            UNPowerScore(
                game,
                data,
                winner
            )
        then

            winner =
                candidateID;

        end
    end

    return winner;
end


local function RefreshUNSecurityCouncil(
    game,
    data,
    forceRefresh
)

    local un =
        EnsureUnitedNationsState(
            data
        );

    if un == nil
        or un.enabled ~= true
    then
        return;
    end

    local currentTurn =
        data.tradeTurn
        or 0;

    local startTurn =
        math.max(
            1,
            math.floor(
                tonumber(
                    GetSetting(
                        "UnitedNationsStartTurn",
                        2
                    )
                )
                or 2
            )
        );

    if currentTurn < startTurn then
        return;
    end

    local permanentCount =
        math.max(
            1,
            math.min(
                10,
                math.floor(
                    tonumber(
                        GetSetting(
                            "UNPermanentSeatCount",
                            5
                        )
                    )
                    or 5
                )
            )
        );

    local rotatingCount =
        math.max(
            0,
            math.min(
                50,
                math.floor(
                    tonumber(
                        GetSetting(
                            "UNRotatingSeatCount",
                            10
                        )
                    )
                    or 10
                )
            )
        );

    local eligible =
        UNEligiblePlayerIDs(
            game,
            data
        );

    table.sort(
        eligible,
        function(a, b)

            local scoreA =
                UNPowerScore(
                    game,
                    data,
                    a
                );

            local scoreB =
                UNPowerScore(
                    game,
                    data,
                    b
                );

            if scoreA == scoreB then
                return a < b;
            end

            return scoreA > scoreB;
        end
    );

    local configured =
        UNConfiguredPermanentPlayers(
            game,
            data
        );

    local oldPermanent =
        un.permanentMembers
        or {};

    local newPermanent =
        {};

    -- Host-configured slots always get first priority.
    for _, playerID
        in ipairs(
            configured
        )
    do

        if #newPermanent < permanentCount
            and UNPlayerAvailable(
                game,
                data,
                playerID
            )
        then

            table.insert(
                newPermanent,
                playerID
            );

        end
    end

    -- Preserve surviving permanent members.
    for _, playerID
        in ipairs(
            oldPermanent
        )
    do

        if #newPermanent >= permanentCount then
            break;
        end

        if UNPlayerAvailable(
            game,
            data,
            playerID
        )
            and not UNListContains(
                newPermanent,
                playerID
            )
        then

            table.insert(
                newPermanent,
                playerID
            );

        end
    end

    local replacementMode =
        math.max(
            1,
            math.min(
                3,
                math.floor(
                    tonumber(
                        GetSetting(
                            "UNReplacementMode",
                            1
                        )
                    )
                    or 1
                )
            )
        );

    while #newPermanent < permanentCount do

        local candidates =
            {};

        for _, playerID
            in ipairs(
                eligible
            )
        do

            if not UNListContains(
                newPermanent,
                playerID
            ) then

                table.insert(
                    candidates,
                    playerID
                );

            end
        end

        if #candidates == 0 then
            break;
        end

        local chosen =
            nil;

        if replacementMode == 2
            and #oldPermanent > 0
        then

            chosen =
                UNChooseReplacementByCouncil(
                    game,
                    data,
                    newPermanent,
                    un.rotatingMembers,
                    candidates
                );

        else

            chosen =
                candidates[1];

        end

        if chosen == nil then
            break;
        end

        table.insert(
            newPermanent,
            chosen
        );

    end

    un.permanentMembers =
        newPermanent;

    local shouldRotate =
        forceRefresh == true
        or un.councilInitialized ~= true
        or currentTurn
            - (
                un.lastCouncilRefreshTurn
                or 0
            )
            >= 5;

    if shouldRotate then

        local rotating =
            {};

        for _, playerID
            in ipairs(
                eligible
            )
        do

            if #rotating >= rotatingCount then
                break;
            end

            if not UNListContains(
                newPermanent,
                playerID
            ) then

                table.insert(
                    rotating,
                    playerID
                );

            end
        end

        un.rotatingMembers =
            rotating;

        un.lastCouncilRefreshTurn =
            currentTurn;

    else

        local rotating =
            {};

        for _, playerID
            in ipairs(
                un.rotatingMembers
                or {}
            )
        do

            if #rotating >= rotatingCount then
                break;
            end

            if UNPlayerAvailable(
                game,
                data,
                playerID
            )
                and not UNListContains(
                    newPermanent,
                    playerID
                )
            then

                table.insert(
                    rotating,
                    playerID
                );

            end
        end

        for _, playerID
            in ipairs(
                eligible
            )
        do

            if #rotating >= rotatingCount then
                break;
            end

            if not UNListContains(
                newPermanent,
                playerID
            )
                and not UNListContains(
                    rotating,
                    playerID
                )
            then

                table.insert(
                    rotating,
                    playerID
                );

            end
        end

        un.rotatingMembers =
            rotating;

    end

    un.councilInitialized =
        true;

    if GetSetting(
        "UNLeadershipEnabled",
        true
    ) == true then

        un.chairPlayerID =
            un.rotatingMembers[1]
            or un.permanentMembers[1];

        un.viceChairPlayerID =
            un.rotatingMembers[2]
            or un.permanentMembers[2]
            or un.chairPlayerID;

    end
end


local function UNCouncilMembers(
    un
)

    local members =
        {};

    for _, playerID
        in ipairs(
            un.permanentMembers
            or {}
        )
    do

        table.insert(
            members,
            playerID
        );
    end

    for _, playerID
        in ipairs(
            un.rotatingMembers
            or {}
        )
    do

        if not UNListContains(
            members,
            playerID
        ) then

            table.insert(
                members,
                playerID
            );

        end
    end

    return members;
end


local function UNRecordHistory(
    un,
    entry
)

    table.insert(
        un.resolutionHistory,
        1,
        entry
    );

    while #un.resolutionHistory > 50 do

        table.remove(
            un.resolutionHistory
        );

    end
end


local function UNApplyPassedResolution(
    game,
    data,
    un,
    resolution,
    resourceChanges
)

    local currentTurn =
        data.tradeTurn
        or 0;

    local targetID =
        resolution.targetPlayerID;

    local targetNation =
        targetID
        and data.globalEconomy.nations[
            targetID
        ]
        or nil;

    if resolution.resolutionType == "sanctions"
        and targetNation ~= nil
    then

        local untilTurn =
            currentTurn
            + 3;

        un.sanctions[
            targetID
        ] =
            {
                untilTurn =
                    untilTurn,

                percent =
                    10,

                resolutionID =
                    resolution.id
            };

        targetNation.unSanctionsUntilTurn =
            untilTurn;

        targetNation.unSanctionsPercent =
            10;

    elseif resolution.resolutionType == "embargo"
        and targetNation ~= nil
    then

        local untilTurn =
            currentTurn
            + 3;

        un.embargoes[
            targetID
        ] =
            {
                untilTurn =
                    untilTurn,

                resolutionID =
                    resolution.id
            };

        targetNation.unEmbargoUntilTurn =
            untilTurn;

    elseif resolution.resolutionType == "aid"
        and targetNation ~= nil
    then

        local aidGold =
            math.max(
                50,
                math.floor(
                    GetCommerceIncome(
                        game,
                        targetID
                    )
                    * 0.10
                )
            );

        AddResourceChange(
            resourceChanges,
            targetID,
            aidGold
        );

        resolution.effectValue =
            aidGold;

    elseif resolution.resolutionType == "condemnation"
        and targetNation ~= nil
    then

        local untilTurn =
            currentTurn
            + 3;

        un.condemnations[
            targetID
        ] =
            {
                untilTurn =
                    untilTurn,

                resolutionID =
                    resolution.id
            };

        targetNation.unCondemnationUntilTurn =
            untilTurn;

        if targetNation.resourceUnrest ~= nil then

            targetNation.resourceUnrest =
                math.min(
                    100,
                    targetNation.resourceUnrest
                    + 5
                );

        end

    elseif resolution.resolutionType == "ceasefire"
        and targetID ~= nil
        and resolution.proposerPlayerID ~= nil
        and IsDiplomacyWar(
            data,
            resolution.proposerPlayerID,
            targetID
        )
    then

        ActivateDiplomacyPeace(
            game,
            data,
            resolution.proposerPlayerID,
            targetID,
            "un_ceasefire"
        );

    end
end


local function ProcessUnitedNations(
    game,
    data,
    resourceChanges
)

    local un =
        EnsureUnitedNationsState(
            data
        );

    if un == nil
        or un.enabled ~= true
    then
        return;
    end

    local currentTurn =
        data.tradeTurn
        or 0;

    local startTurn =
        math.max(
            1,
            math.floor(
                tonumber(
                    GetSetting(
                        "UnitedNationsStartTurn",
                        2
                    )
                )
                or 2
            )
        );

    if currentTurn < startTurn then
        return;
    end

    RefreshUNSecurityCouncil(
        game,
        data,
        false
    );

    -- Existing sanctions are applied once per nation per turn.
    for playerID, sanction
        in pairs(
            un.sanctions
            or {}
        )
    do

        if sanction.untilTurn ~= nil
            and currentTurn <= sanction.untilTurn
            and UNPlayerAvailable(
                game,
                data,
                playerID
            )
        then

            local percent =
                math.max(
                    0,
                    tonumber(
                        sanction.percent
                    )
                    or 10
                );

            local amount =
                math.floor(
                    GetCommerceIncome(
                        game,
                        playerID
                    )
                    * percent
                    / 100
                    + 0.5
                );

            if amount > 0 then

                AddResourceChange(
                    resourceChanges,
                    playerID,
                    -amount
                );

            end

        elseif sanction.untilTurn ~= nil
            and currentTurn > sanction.untilTurn
        then

            un.sanctions[
                playerID
            ] =
                nil;

        end
    end

    for playerID, embargo
        in pairs(
            un.embargoes
            or {}
        )
    do

        if embargo.untilTurn ~= nil
            and currentTurn > embargo.untilTurn
        then

            un.embargoes[
                playerID
            ] =
                nil;

        end
    end

    for playerID, condemnation
        in pairs(
            un.condemnations
            or {}
        )
    do

        if condemnation.untilTurn ~= nil
            and currentTurn > condemnation.untilTurn
        then

            un.condemnations[
                playerID
            ] =
                nil;

        end
    end

    local council =
        UNCouncilMembers(
            un
        );

    local active =
        {};

    for _, resolution
        in ipairs(
            un.activeResolutions
            or {}
        )
    do

        resolution.votes =
            resolution.votes
            or {};

        -- AI council members vote automatically.
        for _, voterID
            in ipairs(
                council
            )
        do

            local player =
                game.Game.Players[
                    voterID
                ];

            if player ~= nil
                and player.IsAI == true
                and resolution.votes[
                    tostring(
                        voterID
                    )
                ] == nil
            then

                local vote =
                    "YES";

                if resolution.targetPlayerID == voterID then

                    vote =
                        "NO";

                elseif resolution.resolutionType == "aid" then

                    vote =
                        "YES";

                elseif resolution.targetPlayerID ~= nil
                    and IsDiplomacyWar(
                        data,
                        voterID,
                        resolution.targetPlayerID
                    )
                then

                    vote =
                        "YES";

                else

                    local deterministic =
                        (
                            voterID
                            * 31
                            + resolution.id
                            * 17
                            + currentTurn
                        )
                        % 100;

                    vote =
                        deterministic < 55
                        and "YES"
                        or "NO";

                end

                resolution.votes[
                    tostring(
                        voterID
                    )
                ] =
                    vote;

            end
        end

        if currentTurn >= (
            resolution.voteEndsTurn
            or currentTurn
        )
        then

            local yesVotes =
                0;

            local eligibleVotes =
                0;

            local vetoed =
                false;

            for _, voterID
                in ipairs(
                    council
                )
            do

                if UNPlayerAvailable(
                    game,
                    data,
                    voterID
                ) then

                    eligibleVotes =
                        eligibleVotes
                        + 1;

                    local vote =
                        resolution.votes[
                            tostring(
                                voterID
                            )
                        ]
                        or "ABSTAIN";

                    if vote == "YES" then

                        yesVotes =
                            yesVotes
                            + 1;

                    elseif vote == "NO"
                        and UNListContains(
                            un.permanentMembers,
                            voterID
                        )
                    then

                        vetoed =
                            true;

                    end

                end
            end

            local requirement =
                math.max(
                    50,
                    math.min(
                        100,
                        tonumber(
                            GetSetting(
                                "UNPassRequirementPercent",
                                60
                            )
                        )
                        or 60
                    )
                );

            local yesPercent =
                eligibleVotes > 0
                and (
                    yesVotes
                    * 100
                    / eligibleVotes
                )
                or 0;

            local passed =
                not vetoed
                and yesPercent >= requirement;

            resolution.status =
                passed
                and "PASSED"
                or (
                    vetoed
                    and "VETOED"
                    or "FAILED"
                );

            resolution.yesVotes =
                yesVotes;

            resolution.eligibleVotes =
                eligibleVotes;

            resolution.vetoed =
                vetoed;

            resolution.resolvedTurn =
                currentTurn;

            if passed then

                UNApplyPassedResolution(
                    game,
                    data,
                    un,
                    resolution,
                    resourceChanges
                );

            end

            UNRecordHistory(
                un,
                resolution
            );

        else

            table.insert(
                active,
                resolution
            );

        end
    end

    un.activeResolutions =
        active;
end


-- =========================================================
-- CURRENT WARS / INTERACTIVE WAR EVENTS
-- =========================================================

local function EnsureWarEventNationState(nation)
    if nation == nil then return; end
    if nation.showWarEventAlerts == nil then nation.showWarEventAlerts = true; end
    nation.lastWarEventTurn = nation.lastWarEventTurn or 0;
    nation.warEventReadinessModifier = nation.warEventReadinessModifier or 0;
    nation.warEventReadinessUntilTurn = nation.warEventReadinessUntilTurn or 0;
end

local function AddWarEventHistory(diplomacy, entry)
    diplomacy.warEventHistory = diplomacy.warEventHistory or {};
    table.insert(diplomacy.warEventHistory, 1, entry);
    while #diplomacy.warEventHistory > 80 do
        table.remove(diplomacy.warEventHistory);
    end
end

local function ApplyWarEventConsequence(
    game,
    data,
    resourceChanges,
    playerID,
    nation,
    consequence
)
    if nation == nil or consequence == nil then return; end

    local currentTurn = data.tradeTurn or 0;
    local goldDelta = math.floor(tonumber(consequence.goldDelta) or 0);
    local unrestDelta = math.floor(tonumber(consequence.unrestDelta) or 0);
    local readinessModifier = math.floor(tonumber(consequence.readinessModifier) or 0);
    local readinessDuration = math.max(0, math.floor(tonumber(consequence.readinessDuration) or 0));

    if goldDelta ~= 0 then
        AddResourceChange(resourceChanges, playerID, goldDelta);
    end

    if unrestDelta ~= 0 then
        nation.resourceUnrest = math.max(
            0,
            math.min(
                100,
                (nation.resourceUnrest or 0) + unrestDelta
            )
        );
    end

    if readinessModifier ~= 0 and readinessDuration > 0 then
        nation.warEventReadinessModifier = readinessModifier;
        nation.warEventReadinessUntilTurn = currentTurn + readinessDuration;
    end

    local diplomacy = GetDiplomacyData(data);
    diplomacy.warStats = diplomacy.warStats or {};
    local warKey = consequence.warKey;
    local stats = warKey and diplomacy.warStats[warKey] or nil;
    if stats ~= nil then
        stats.economicImpact = stats.economicImpact or {};
        if goldDelta < 0 then
            stats.economicImpact[tostring(playerID)] =
                (stats.economicImpact[tostring(playerID)] or 0) + math.abs(goldDelta);
        end
    end

    AddWarEventHistory(
        diplomacy,
        {
            id = consequence.eventID,
            turn = currentTurn,
            playerID = playerID,
            otherPlayerID = consequence.otherPlayerID,
            warKey = warKey,
            choice = consequence.choice,
            message = consequence.message or "Wartime decision resolved."
        }
    );
end

local function ProcessWarEvents(
    game,
    data,
    resourceChanges
)
    if GetSetting("WarEventsEnabled", true) ~= true then
        return;
    end

    local economy = data.globalEconomy;
    if economy == nil then return; end

    local diplomacy = GetDiplomacyData(data);
    diplomacy.warStats = diplomacy.warStats or {};
    diplomacy.warEventHistory = diplomacy.warEventHistory or {};
    diplomacy.nextWarEventID = diplomacy.nextWarEventID or 1;

    local currentTurn = data.tradeTurn or 0;
    local frequency = math.max(
        1,
        math.min(
            10,
            math.floor(tonumber(GetSetting("WarEventFrequencyTurns", 3)) or 3)
        )
    );

    -- Apply choices made since the previous turn.
    for playerID, nation in pairs(economy.nations or {}) do
        EnsureWarEventNationState(nation);
        if nation.pendingWarEventConsequence ~= nil then
            ApplyWarEventConsequence(
                game,
                data,
                resourceChanges,
                playerID,
                nation,
                nation.pendingWarEventConsequence
            );
            nation.pendingWarEventConsequence = nil;
        end
    end

    -- Human players have one turn to answer a war event.  If they do not,
    -- automatically apply the neutral/balanced response so events cannot remain
    -- pending forever or block later wartime decisions.
    for playerID, nation in pairs(economy.nations or {}) do
        EnsureWarEventNationState(nation);
        local pending = nation.pendingWarEvent;
        local player = game.Game.Players[playerID];
        if pending ~= nil
            and player ~= nil
            and player.IsAI ~= true
            and currentTurn > (pending.createdTurn or currentTurn)
        then
            local commerce = math.max(1, GetCommerceIncome(game, playerID));
            local cost = math.max(10, math.floor(commerce * 0.03 + 0.5));
            ApplyWarEventConsequence(
                game,
                data,
                resourceChanges,
                playerID,
                nation,
                {
                    eventID = pending.id,
                    warKey = pending.warKey,
                    otherPlayerID = pending.otherPlayerID,
                    choice = "AUTO_BALANCED_RESPONSE",
                    goldDelta = -cost,
                    unrestDelta = 0,
                    readinessModifier = 5,
                    readinessDuration = 2,
                    message = "No wartime choice was submitted in time. A balanced response was selected automatically."
                }
            );
            nation.pendingWarEvent = nil;
        end
    end

    -- Generate at most one unresolved event per human nation.  This keeps the
    -- system useful in Mega Games without creating a message storm.
    for relationshipKey, relationship in pairs(diplomacy.relationships or {}) do
        if relationship ~= nil and relationship.status == "war" then
            local player1 = relationship.player1;
            local player2 = relationship.player2;

            if player1 ~= nil and player2 ~= nil then
                local warKey = EconomyPairKey(player1, player2);
                local stats = diplomacy.warStats[warKey];
                if stats == nil then
                    stats = {
                        key = warKey,
                        player1 = player1,
                        player2 = player2,
                        startTurn = relationship.sinceTurn or currentTurn,
                        active = true,
                        attacks = 0,
                        casualties = {},
                        territoriesCaptured = {},
                        economicImpact = {}
                    };
                    diplomacy.warStats[warKey] = stats;
                else
                    stats.active = true;
                end

                for _, participantID in ipairs({player1, player2}) do
                    local nation = economy.nations[participantID];
                    local player = game.Game.Players[participantID];

                    if nation ~= nil
                        and nation.eliminated ~= true
                        and player ~= nil
                    then
                        EnsureWarEventNationState(nation);

                        local due =
                            nation.pendingWarEvent == nil
                            and (
                                currentTurn == (stats.startTurn or currentTurn)
                                or currentTurn - (nation.lastWarEventTurn or 0) >= frequency
                            );

                        if due then
                            local otherPlayerID = participantID == player1 and player2 or player1;
                            local eventID = diplomacy.nextWarEventID;
                            diplomacy.nextWarEventID = eventID + 1;
                            nation.lastWarEventTurn = currentTurn;

                            if player.IsAI == true then
                                local commerce = math.max(1, GetCommerceIncome(game, participantID));
                                local cost = math.max(10, math.floor(commerce * 0.03 + 0.5));
                                ApplyWarEventConsequence(
                                    game,
                                    data,
                                    resourceChanges,
                                    participantID,
                                    nation,
                                    {
                                        eventID = eventID,
                                        warKey = warKey,
                                        otherPlayerID = otherPlayerID,
                                        choice = "BALANCED_RESPONSE",
                                        goldDelta = -cost,
                                        unrestDelta = 0,
                                        readinessModifier = 5,
                                        readinessDuration = 2,
                                        message = "AI selected a balanced wartime mobilization response."
                                    }
                                );
                            else
                                nation.pendingWarEvent = {
                                    id = eventID,
                                    warKey = warKey,
                                    otherPlayerID = otherPlayerID,
                                    createdTurn = currentTurn,
                                    title = currentTurn == (stats.startTurn or currentTurn)
                                        and "WAR MOBILIZATION DECISION"
                                        or "WARTIME STRATEGY DECISION"
                                };
                            end
                        end
                    end
                end
            end
        end
    end
end


-- =========================================================
-- WAR BONDS
-- =========================================================

local function ProcessWarBonds(game, data, resourceChanges)
    local economy = data.globalEconomy;
    if economy == nil then return; end
    economy.warBonds = economy.warBonds or {nextHoldingID = 1, holdings = {}, maturityTurns = 5, returnPercent = 20};
    local market = economy.warBonds;
    market.holdings = market.holdings or {};
    local currentTurn = data.tradeTurn or economy.currentEconomyTurn or 0;
    local available = {};

    for _, holding in ipairs(market.holdings) do
        if holding.status == "active" and currentTurn >= (holding.maturesTurn or currentTurn + 1) then
            local issuerID = holding.issuerPlayerID;
            local buyerID = holding.buyerPlayerID;
            if available[issuerID] == nil then
                available[issuerID] = math.max(0, GetStoredGold(game, issuerID));
            end
            local due = math.max(0, math.floor(tonumber(holding.payout) or 0));
            local paid = math.min(due, available[issuerID] or 0);
            if paid > 0 then
                AddResourceChange(resourceChanges, issuerID, -paid);
                AddResourceChange(resourceChanges, buyerID, paid);
                available[issuerID] = math.max(0, (available[issuerID] or 0) - paid);
            end
            holding.paid = paid;
            holding.status = paid >= due and "matured" or "defaulted";
            holding.resolvedTurn = currentTurn;
            local buyerNation = (economy.nations or {})[buyerID];
            if buyerNation ~= nil then
                buyerNation.warBondPayoutsReceived = (buyerNation.warBondPayoutsReceived or 0) + paid;
            end
            economy.market = economy.market or {};
            economy.market.news = economy.market.news or {};
            table.insert(economy.market.news, {
                turn = currentTurn,
                type = "war_bond",
                message = "War Bond matured: " .. tostring(paid) .. "/" .. tostring(due) .. " Commerce paid."
            });
        end
    end
end

-- =========================================================
-- PUBLIC GAME DATA COMPACTION
-- =========================================================
-- War.app limits PublicGameData to 1,000,000 serialized bytes.  Global Affairs
-- stores many optional histories for UI/reporting, so large games can otherwise
-- grow past that limit after enough turns.  Keep gameplay-critical/live state,
-- but aggressively bound historical/report-only collections before every save.

local function TrimArrayKeepNewest(list, maxItems)
    if type(list) ~= "table" then return; end
    while #list > maxItems do
        table.remove(list, 1);
    end
end

local function TrimArrayKeepNewestFront(list, maxItems)
    if type(list) ~= "table" then return; end
    -- Some histories insert newest entries at index 1.
    while #list > maxItems do
        table.remove(list);
    end
end

local function CompactPublicGameData(data)
    if type(data) ~= "table" then return; end

    TrimArrayKeepNewest(data.tradeHistory, 30);
    TrimArrayKeepNewest(data.investmentHistory, 30);
    TrimArrayKeepNewest(data.completedInvestmentProjects, 30);

    local economy = data.globalEconomy;
    if type(economy) ~= "table" then return; end

    TrimArrayKeepNewest(economy.worldEvents, 30);
    TrimArrayKeepNewest(economy.pendingWorldReportEvents, 10);
    TrimArrayKeepNewest(economy.transactionLedger, 30);

    for _, nation in pairs(economy.nations or {}) do
        TrimArrayKeepNewest(nation.personalEventQueue, 10);
    end

    local market = economy.market;
    if type(market) == "table" then
        TrimArrayKeepNewest(market.transactions, 40);
        TrimArrayKeepNewest(market.news, 30);
        TrimArrayKeepNewest(market.priceHistory, 12);

        for _, company in pairs(market.companies or {}) do
            if type(company) == "table" then
                TrimArrayKeepNewest(company.priceHistory, 12);
            end
        end

        if type(market.etf) == "table" then
            TrimArrayKeepNewest(market.etf.priceHistory, 12);
        end
    end

    local diplomacy = economy.diplomacy;
    if type(diplomacy) == "table" then
        TrimArrayKeepNewest(diplomacy.history, 40);
        TrimArrayKeepNewestFront(diplomacy.warEventHistory, 30);

        -- Current Wars only needs active pairwise statistics/conflicts.  Finished
        -- wars remain represented by the bounded diplomacy/war-event histories.
        for key, stats in pairs(diplomacy.warStats or {}) do
            if type(stats) ~= "table" or stats.active == false then
                diplomacy.warStats[key] = nil;
            end
        end
        for conflictID, conflict in pairs(diplomacy.warConflicts or {}) do
            if type(conflict) ~= "table" or conflict.active == false then
                diplomacy.warConflicts[conflictID] = nil;
            end
        end
    end

    local resources = economy.resources;
    if type(resources) == "table" then
        TrimArrayKeepNewest(resources.tradeHistory, 20);
    end

    local un = economy.unitedNations;
    if type(un) == "table" then
        TrimArrayKeepNewest(un.resolutionHistory, 25);
    end
end

-- =========================================================
-- MAIN TURN HOOK
-- =========================================================

function Server_AdvanceTurn_Start(
    game,
    addNewOrder
)

    local data =
        GetEconomicData();

    -- Compact first so an older large save gets headroom before this turn adds
    -- any new market, diplomacy, resource, or war records.
    CompactPublicGameData(data);

    TURN_COMMERCE_INCOME_CACHE = {};
    TURN_STORED_GOLD_CACHE = {};
    ADVANCE_TURN_PERFORMANCE_CACHE = nil;
    ADVANCE_TURN_BORDER_CACHE = {};
    ADVANCE_TURN_ORDER_DATA_CACHE = data;
    AI_WAR_BORDER_CACHE = nil;
    AI_WAR_BORDER_CACHE_TURN = nil;

    data.tradeTurn =
        data.tradeTurn
        + 1;


    -- =====================================================
    -- GLOBAL ECONOMY / NATIONAL STATE / DIPLOMACY TIMERS
    -- =====================================================

    ProcessGlobalEconomyFoundation(
        game,
        data
    );


    local resourceChanges =
        {};


    -- =====================================================
    -- STRATEGIC RESOURCES
    -- =====================================================

    ProcessPendingResourceBuilds(
        game,
        data,
        resourceChanges,
        addNewOrder
    );

    ProcessPendingArmyRecruiters(game, data, resourceChanges, addNewOrder);

    ProcessStrategicResources(
        game,
        data,
        resourceChanges
    );

    ProcessArmyRecruiterProduction(game, data, addNewOrder);

    ProcessUnitedNations(
        game,
        data,
        resourceChanges
    );

    ProcessWarBonds(
        game,
        data,
        resourceChanges
    );


    -- =====================================================
    -- TRADE MAINTENANCE
    -- =====================================================

    CleanupTradeData(
        game,
        data
    );


    -- Track economic direction of AI partners.

    UpdateAITradeMemory(
        game,
        data
    );


    -- =====================================================
    -- AI DIPLOMACY
    -- =====================================================

    ProcessAIDiplomacy(
        game,
        data
    );

    -- Diplomacy decisions can start/end wars. Rebuild the lightweight threat
    -- cache before later AI economy/city work so the new war state is visible.
    ADVANCE_TURN_PERFORMANCE_CACHE = nil;
    ADVANCE_TURN_BORDER_CACHE = {};

    ProcessWarEvents(
        game,
        data,
        resourceChanges
    );


    -- Diplomacy decisions may have started a war,
    -- accepted peace, or created/expired an agreement.
    -- Run cleanup again before AI trade strategy so
    -- Trade can never operate on stale diplomatic state.

    CleanupTradeData(
        game,
        data
    );


    CleanupDiplomacyOffers(
        game,
        data
    );


    -- =====================================================
    -- AI TRADE STRATEGY
    -- =====================================================

    local aiTradeCadence = GetPerformanceCadence(game, data, "trade");

    for playerID, player
        in pairs(
            game.Game.Players
        ) do


        if player.IsAI
            and IsPlayerAvailable(
                game,
                playerID
            )
            and IsNationEconomyReady(
                game,
                data,
                playerID
            )
            and ShouldRunAIWork(data, playerID, aiTradeCadence)
        then


            AIConsiderTradeReplacement(
                game,
                data,
                playerID
            );


            AIConsiderTradeProposal(
                game,
                data,
                playerID
            );

        end

    end


    -- =====================================================
    -- EXISTING INVESTMENTS
    -- =====================================================

    ProcessPendingInvestmentActions(
    game,
    data,
    resourceChanges
);

    ProcessInvestmentProjects(
        game,
        data,
        resourceChanges
    );

    ProcessStockMarket(
    game,
    data
);

ProcessMarketETF(
    game,
    data,
    resourceChanges
);

ProcessCompanyDividends(
    game,
    data,
    resourceChanges
);

ProcessETFDividends(
    game,
    data,
    resourceChanges
);

TrimMarketNews(
    data.globalEconomy.market
);
    -- =====================================================
    -- AI INVESTMENT ECONOMY
    -- =====================================================

    local aiEconomyCadence = GetPerformanceCadence(game, data, "economy");
    local aiCityCadence = GetPerformanceCadence(game, data, "city");

    for playerID, player
        in pairs(
            game.Game.Players
        ) do


        if player.IsAI
            and IsPlayerAvailable(
                game,
                playerID
            )
            and IsNationEconomyReady(
                game,
                data,
                playerID
            )
        then

UpdateAIStrategicReserve(
    game,
    data,
    playerID
);

if ShouldRunAIWork(data, playerID, aiCityCadence) then
    AIConsiderCityConstruction(game, data, playerID, addNewOrder);
end

if ShouldRunAIWork(data, playerID, aiEconomyCadence) then
    local aiEconomyPhase = GetStaggeredAIPhase(
        data,
        playerID,
        aiEconomyCadence,
        2
    );

    if aiEconomyPhase == 0 then
        ProcessAIMarketSelling(game, data, resourceChanges, playerID);
        ProcessAIMarketBuying(game, data, resourceChanges, playerID);
    else
        AIConsiderProjectCreation(game, data, playerID, resourceChanges);
        AIConsiderInvestment(game, data, playerID, resourceChanges);
    end
end

end

end


    -- =====================================================
    -- HUMAN PLAYER AI MANAGER
    -- =====================================================

    if GetSetting(
        "PlayerAIManagerEnabled",
        true
    ) == true then

        local economy =
            data.globalEconomy
            or {};

        for playerID, player
            in pairs(
                game.Game.Players
            ) do

            if player ~= nil
                and player.IsAI ~= true
                and IsPlayerAvailable(
                    game,
                    playerID
                )
                and IsNationEconomyReady(
                    game,
                    data,
                    playerID
                )
            then

                local nation =
                    economy.nations
                    and economy.nations[
                        playerID
                    ]
                    or nil;

                if nation ~= nil
                    and nation.aiManagerEnabled == true then

                    local currentTurn =
                        economy.currentEconomyTurn
                        or data.tradeTurn
                        or 1;

                    if nation.aiManagerCancelTurn ~= nil
                        and currentTurn >= nation.aiManagerCancelTurn
                    then

                        nation.aiManagerEnabled =
                            false;

                        nation.aiManagerCancelTurn =
                            nil;

                        nation.aiManagerBudgetRemaining =
                            0;

                    else

                        local managerBudget =
                            math.max(
                                25,
                                math.floor(
                                    nation.aiManagerBudget
                                    or 100
                                )
                            );

                        local availableGold =
                            GetAvailableGold(
                                game,
                                resourceChanges,
                                playerID
                            );

                        nation.aiManagerBudgetRemaining =
                            math.max(
                                0,
                                math.min(
                                    managerBudget,
                                    availableGold
                                )
                            );

                        nation.aiManagerTurnBudget = nation.aiManagerBudgetRemaining;
                        nation.aiManagerSpentThisTurn = 0;
                        nation.aiManagerMarketSpentThisTurn = 0;
                        nation.aiManagerInvestmentSpentThisTurn = 0;
                        nation.aiManagerCommerceBefore = availableGold;
                        nation.aiManagerCommerceAfter = availableGold;

                        nation.aiStrategicState =
                            nation.aiStrategicState
                            or "stable";

                        nation.aiDynamicReservePercent =
                            nation.aiDynamicReservePercent
                            or GetSetting(
                                "AIBaseReservePercent",
                                40
                            );

                        local managerPhase =
                            (
                                data.tradeTurn
                                + playerID
                            )
                            % 2;

                        if managerPhase == 0 then

                            local before = nation.aiManagerBudgetRemaining or 0;
                            ProcessAIMarketSelling(
                                game,
                                data,
                                resourceChanges,
                                playerID
                            );

                            ProcessAIMarketBuying(
                                game,
                                data,
                                resourceChanges,
                                playerID
                            );
                            local after = nation.aiManagerBudgetRemaining or 0;
                            nation.aiManagerMarketSpentThisTurn = math.max(0, before - after);

                        else

                            local before = nation.aiManagerBudgetRemaining or 0;
                            AIConsiderProjectCreation(
                                game,
                                data,
                                playerID,
                                resourceChanges
                            );

                            AIConsiderInvestment(
                                game,
                                data,
                                playerID,
                                resourceChanges
                            );
                            local after = nation.aiManagerBudgetRemaining or 0;
                            nation.aiManagerInvestmentSpentThisTurn = math.max(0, before - after);

                        end

                        nation.aiManagerSpentThisTurn =
                            math.max(0, (nation.aiManagerTurnBudget or 0) - (nation.aiManagerBudgetRemaining or 0));
                        nation.aiManagerCommerceAfter =
                            math.max(0, (nation.aiManagerCommerceBefore or 0) - (nation.aiManagerSpentThisTurn or 0));

                        nation.aiManagerLastProcessedTurn =
                            currentTurn;

                    end

                end

            end

        end

    end


    -- AI investment activity above may have caused
    -- another project to reach full funding.

    ProcessInvestmentProjects(
        game,
        data,
        resourceChanges
    );


    -- Cleanup already ran after diplomacy decisions. Avoid another full
    -- trade/diplomacy scan here; market/investment work below cannot change
    -- diplomatic relationships.

    -- =====================================================
    -- SAVE
    -- =====================================================

    CompactPublicGameData(data);
    Mod.PublicGameData =
        data;


    -- =====================================================
    -- APPLY GOLD / TRADE INCOME
    -- =====================================================

-- =====================================================
-- TAX POLICY COMMERCE ADJUSTMENT
-- =====================================================

local economy =
    data.globalEconomy;

if economy ~= nil then

    for playerID, nation in pairs(
        economy.nations
        or {}
    ) do

        if nation.setupComplete == true
            and nation.eliminated ~= true then

            local taxAdjustment =
                CalculateTaxCommerceAdjustment(
                    game,
                    playerID,
                    nation
                );

            if taxAdjustment ~= 0 then

                AddResourceChange(
                    resourceChanges,
                    playerID,
                    taxAdjustment
                );

            end

        end

    end

end

    ApplyResourceChanges(
        resourceChanges,
        addNewOrder
    );


    ApplyTradeIncome(
        game,
        data,
        addNewOrder
    );

end
-- =========================================================
-- DIPLOMACY ATTACK ENFORCEMENT
-- =========================================================

local function RecordWarCombatStats(
    data,
    attackerID,
    defenderID,
    result
)

    if data == nil
        or attackerID == nil
        or defenderID == nil
        or result == nil
        or result.IsAttack ~= true
    then
        return;
    end

    if not IsDiplomacyWar(
        data,
        attackerID,
        defenderID
    ) then
        return;
    end

    local diplomacy =
        GetDiplomacyData(
            data
        );

    diplomacy.warStats =
        diplomacy.warStats
        or {};

    local key =
        EconomyPairKey(
            attackerID,
            defenderID
        );

    local stats =
        diplomacy.warStats[
            key
        ];

    if stats == nil then

        local relationship =
            GetDiplomacyRelationship(
                data,
                attackerID,
                defenderID
            );

        stats = {
            key = key,
            player1 = attackerID,
            player2 = defenderID,
            startTurn = relationship.sinceTurn or (data.tradeTurn or 0),
            active = true,
            attacks = 0,
            casualties = {},
            territoriesCaptured = {},
            economicImpact = {}
        };

        diplomacy.warStats[key] =
            stats;

    end

    stats.attacks =
        (stats.attacks or 0)
        + 1;

    stats.casualties =
        stats.casualties
        or {};

    stats.territoriesCaptured =
        stats.territoriesCaptured
        or {};

    local attackerLosses = 0;
    local defenderLosses = 0;

    if result.AttackingArmiesKilled ~= nil then
        attackerLosses =
            result.AttackingArmiesKilled.NumArmies
            or 0;
    end

    if result.DefendingArmiesKilled ~= nil then
        defenderLosses =
            result.DefendingArmiesKilled.NumArmies
            or 0;
    end

    stats.casualties[tostring(attackerID)] =
        (stats.casualties[tostring(attackerID)] or 0)
        + math.max(0, attackerLosses);

    stats.casualties[tostring(defenderID)] =
        (stats.casualties[tostring(defenderID)] or 0)
        + math.max(0, defenderLosses);

    if result.IsSuccessful == true then
        stats.territoriesCaptured[tostring(attackerID)] =
            (stats.territoriesCaptured[tostring(attackerID)] or 0)
            + 1;
    end

end


function Server_AdvanceTurn_Order(
    game,
    order,
    result,
    skipThisOrder,
    addNewOrder
)

    -- Only inspect Attack / Transfer orders.
    -- Other orders such as deployments, cards,
    -- purchases, and mod events are untouched.

if order == nil then
    return;
end


-- =====================================================
-- AI DEPLOYMENT ORDERS
-- =====================================================

if order.proxyType == "GameOrderDeploy" then

    local deployPlayerID =
        order.PlayerID;

    local deployPlayer =
        game.Game.Players[
            deployPlayerID
        ];

    if deployPlayer == nil
        or deployPlayer.IsAI ~= true
    then
        return;
    end

    local deployTerritoryID =
        order.DeployOn;

    local deployArmies =
        order.NumArmies
        or 0;

    local standing =
        game.ServerGame
            .LatestTurnStanding;

    if standing == nil
        or standing.Territories == nil
    then
        return;
    end

    local territoryStanding =
        standing.Territories[
            deployTerritoryID
        ];

    if territoryStanding == nil then
        return;
    end

    local currentArmies =
        0;

    if territoryStanding.NumArmies ~= nil then

        currentArmies =
            territoryStanding.NumArmies.NumArmies
            or 0;

    end

    local projectedArmies =
        currentArmies
        + deployArmies;

    local territoryDetails =
        game.Map.Territories[
            deployTerritoryID
        ];

    if territoryDetails == nil then
        return;
    end

    local data =
        ADVANCE_TURN_ORDER_DATA_CACHE
        or GetEconomicData();

    if data == nil then
        return;
    end

    local borderKey = tostring(deployPlayerID) .. ":" .. tostring(deployTerritoryID);
    local hasPeacefulForeignBorder = ADVANCE_TURN_BORDER_CACHE[borderKey];

    if hasPeacefulForeignBorder == nil then
        hasPeacefulForeignBorder = false;
        for connectedTerritoryID, _ in pairs(territoryDetails.ConnectedTo or {}) do
            local connectedStanding = standing.Territories[connectedTerritoryID];
            if connectedStanding ~= nil then
                local otherPlayerID = connectedStanding.OwnerPlayerID;
                if otherPlayerID ~= nil
                    and otherPlayerID ~= deployPlayerID
                    and otherPlayerID ~= WL.PlayerID.Neutral
                    and not IsDiplomacyWar(data, deployPlayerID, otherPlayerID)
                then
                    hasPeacefulForeignBorder = true;
                    break;
                end
            end
        end
        ADVANCE_TURN_BORDER_CACHE[borderKey] = hasPeacefulForeignBorder;
    end

    if hasPeacefulForeignBorder
        and projectedArmies > 20
    then

        skipThisOrder(
            WL.ModOrderControl.Skip
        );

        return;

    end

    return;

end

-- =====================================================
-- ATTACK / TRANSFER ORDERS
-- =====================================================

if order.proxyType
    ~= "GameOrderAttackTransfer" then

    return;
end


    -- War.app already calculated whether this order
    -- represents an attack or merely a transfer.

    if result == nil
        or result.IsAttack
        ~= true then


        return;
    end


    local attackerID =
        order.PlayerID;

    local attacker =
    game.Game.Players[
        attackerID
    ];

local attackerIsAI =
    attacker ~= nil
    and attacker.IsAI == true;

    if attackerID == nil then

        return;
    end


    local standing =
        game.ServerGame
            .LatestTurnStanding;


    if standing == nil
        or standing.Territories
        == nil then


        return;
    end

    local source =
    standing.Territories[
        order.From
    ];

if source == nil
    or source.NumArmies == nil then

    return;
end

    local destination =
        standing.Territories[
            order.To
        ];


    if destination == nil then

        return;
    end


    local defenderID =
        destination.OwnerPlayerID;


    if defenderID == nil then

        return;
    end


    -- =====================================================
    -- NEUTRAL TERRITORIES
    -- =====================================================
    --
    -- Diplomacy exists between nations.
    -- Neutral territories remain attackable normally.

    if defenderID
        == WL.PlayerID.Neutral then


        return;
    end


    -- =====================================================
    -- SELF / NON-HOSTILE MOVEMENT SAFETY
    -- =====================================================

    if defenderID
        == attackerID then


        return;
    end


    -- =====================================================
    -- ECONOMIC / NATIONAL SETUP SAFETY
    -- =====================================================

    local data =
        ADVANCE_TURN_ORDER_DATA_CACHE
        or GetEconomicData();


    if data == nil then

        return;
    end


local economy =
    data.globalEconomy;

local nations =
    economy
    and economy.nations
    or {};

local attackerNation =
    nations[
        attackerID
    ];

local defenderNation =
    nations[
        defenderID
    ];

    -- Nations that have not completed National Setup
    -- cannot participate in mod-controlled warfare.

if attackerNation == nil
    or defenderNation == nil
    or attackerNation.setupComplete
        ~= true
    or defenderNation.setupComplete
        ~= true
then

    skipThisOrder(
        WL.ModOrderControl.Skip
    );

    return;

end

    -- =====================================================
    -- OFFICIAL WAR CHECK
    -- =====================================================

if IsDiplomacyWar(
    data,
    attackerID,
    defenderID
) then

    if attackerIsAI then

        local sourceArmies =
            source.NumArmies.NumArmies
            or 0;

        local attackingArmies =
            0;

        if result.ActualArmies ~= nil then

            attackingArmies =
                result.ActualArmies.NumArmies
                or 0;

        end

        local remainingArmies =
            sourceArmies
            - attackingArmies;

local minimumDefense =
    5;

-- Keep a basic percentage of the source stack.
if sourceArmies >= 20 then

    minimumDefense =
        math.max(
            minimumDefense,
            math.floor(
                sourceArmies
                * 0.35
            )
        );

end

local defenderArmies =
    0;

if destination.NumArmies ~= nil then

    defenderArmies =
        destination.NumArmies.NumArmies
        or 0;

end


-- Avoid low-value attacks where the AI is
-- badly outmatched by the defender.


if defenderArmies > 0
    and attackingArmies
        < math.floor(
            defenderArmies
            * 1.15
        )
then

    skipThisOrder(
        WL.ModOrderControl.Skip
    );

    return;

end

        if remainingArmies
            < minimumDefense then

            skipThisOrder(
                WL.ModOrderControl.Skip
            );

            return;

        end

    end

    -- Record only attacks that survived all diplomacy / AI guardrails.
    RecordWarCombatStats(
        data,
        attackerID,
        defenderID,
        result
    );

    -- Normally Server_AdvanceTurn_End persists accumulated war statistics once.
    -- Keep a fallback write only if this hook ever runs without the turn cache.
    if ADVANCE_TURN_ORDER_DATA_CACHE == nil then
        CompactPublicGameData(data);
        Mod.PublicGameData = data;
    end

    return;

end


    -- =====================================================
    -- NO OFFICIAL WAR = ATTACK BLOCKED
    -- =====================================================
    --
    -- This automatically covers:
    --
    -- * normal peace
    -- * active Non-Aggression Pact
    -- * declaration delay
    -- * peace cooldown
    --
    -- None of those states count as official war.

    skipThisOrder(
        WL.ModOrderControl.Skip
    );

end
-- =========================================================
-- RESOURCE OWNERSHIP SNAPSHOT
-- =========================================================
-- Refreshes visible per-turn production after all attacks/captures resolve.
-- Full trade / shortage / readiness processing still occurs once at the next
-- normal resource-processing pass, avoiding double charging or duplicate trades.

local function RefreshStrategicResourceOwnershipSnapshot(
    game,
    data
)
    local resources = EnsureStrategicResourceState(data);
    local economy = data and data.globalEconomy or nil;
    if resources == nil or resources.enabled ~= true or economy == nil then
        return;
    end

    local standing = game.ServerGame and game.ServerGame.LatestTurnStanding;
    if standing == nil or standing.Territories == nil then
        return;
    end

    for _, nation in pairs(economy.nations or {}) do
        EnsureNationResourceState(nation);
        nation.resourceProduction = EmptyResourceTable();
    end

    for territoryID, nodes in pairs(resources.territories or {}) do
        local numericID = tonumber(territoryID) or territoryID;
        local terr = standing.Territories[numericID];
        local owner = terr and terr.OwnerPlayerID or nil;
        local nation = owner and economy.nations[owner] or nil;
        if nation ~= nil and nation.eliminated ~= true then
            for resourceName, level in pairs(nodes or {}) do
                nation.resourceProduction[resourceName] =
                    (nation.resourceProduction[resourceName] or 0)
                    + (tonumber(level) or 0);
            end
        end
    end

    -- Keep the UI snapshot coherent immediately after the capture.  The next
    -- resource-processing pass will apply contracts, shortages and readiness.
    for _, nation in pairs(economy.nations or {}) do
        nation.resourceEffective = nation.resourceEffective or {};
        for _, resourceName in ipairs(RESOURCE_NAMES) do
            nation.resourceEffective[resourceName] =
                nation.resourceProduction[resourceName] or 0;
        end
    end
end

-- =========================================================
-- END-OF-TURN DIPLOMACY
-- =========================================================

function Server_AdvanceTurn_End(
    game,
    addNewOrder
)

    local data =
        ADVANCE_TURN_ORDER_DATA_CACHE
        or GetEconomicData();


    ProcessPendingWarDeclarations(
        game,
        data
    );


    CleanupTradeData(
        game,
        data
    );


    CleanupDiplomacyOffers(
        game,
        data
    );

    -- Captured resource territories should be reflected in the UI as soon as
    -- the turn finishes instead of appearing one full turn late.
    RefreshStrategicResourceOwnershipSnapshot(
        game,
        data
    );

    CompactPublicGameData(data);
    Mod.PublicGameData =
        data;

    ADVANCE_TURN_ORDER_DATA_CACHE = nil;
    ADVANCE_TURN_BORDER_CACHE = {};
    ADVANCE_TURN_PERFORMANCE_CACHE = nil;
    TURN_COMMERCE_INCOME_CACHE = {};
    TURN_STORED_GOLD_CACHE = {};

end