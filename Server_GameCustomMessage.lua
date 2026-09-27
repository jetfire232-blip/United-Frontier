-- =========================================================
-- GLOBAL ECONOMY & DIPLOMACY
-- SERVER CUSTOM MESSAGES
--
-- Handles:
-- 1. National Setup
-- 2. Economic Reform
-- 3. Trade proposals
-- 4. Trade acceptance
-- 5. Trade rejection
-- 6. Trade cancellation
-- 7. Investment project publishing
-- 8. Investing in projects
-- 9. War declarations
-- 10. Peace offers
-- 11. Non-Aggression Pacts
-- =========================================================


local DEFAULT_MAX_AGREEMENTS = 3;
local DEFAULT_COOLDOWN_TURNS = 3;

local MAX_TRADE_HISTORY = 75;
local MAX_INVESTMENT_HISTORY = 100;

local CREATOR_MIN_PERCENT = 20;
local OUTSIDE_INVESTOR_MAX_PERCENT = 25;

local MIN_INVESTORS = 2;
local MAX_INVESTORS = 6;

local FUNDING_WINDOW_TURNS = 3;

local REFORM_DURATION_TURNS = 3;
local REFORM_PENALTY_PERCENT = 15;

local DEFAULT_WAR_DECLARATION_DELAY = 1;
local DEFAULT_PEACE_COOLDOWN_TURNS = 3;

local DEFAULT_NAP_DURATION_TURNS = 3;
local MIN_NAP_DURATION_TURNS = 1;
local MAX_NAP_DURATION_TURNS = 20;

local MAX_DIPLOMACY_HISTORY = 150;


-- =========================================================
-- NATIONAL SETUP DEFINITIONS
-- =========================================================

local VALID_IDEOLOGIES = {

    ["Free Market"] = true,
    ["Capitalist"] = true,
    ["Social Democratic"] = true,
    ["State Capitalist"] = true,
    ["Socialist"] = true,
    ["Communist"] = true,
    ["Fascist"] = true,
    ["Nationalist"] = true
};


local VALID_ECONOMIC_STRATEGIES = {

    ["Growth"] = true,
    ["Balanced"] = true,
    ["Conservative"] = true
};


local VALID_TAX_POLICIES = {

    ["Low"] = true,
    ["Standard"] = true,
    ["High"] = true
};


local VALID_COMPANY_STRATEGIES = {

    ["Growth"] = true,
    ["Balanced"] = true,
    ["Dividend"] = true
};


-- =========================================================
-- INVESTMENT PROJECT DEFINITIONS
-- =========================================================

local INVESTMENT_TYPES = {

    port = {

        name =
            "Port Expansion",

        maxGoal =
            1200,

        duration =
            3,

        successReturn =
            15,

        failureRecovery =
            90,

        successChance =
            90,

        risk =
            "Low"
    },


    commercial = {

        name =
            "Commercial District",

        maxGoal =
            1500,

        duration =
            4,

        successReturn =
            22,

        failureRecovery =
            80,

        successChance =
            82,

        risk =
            "Low-Medium"
    },


    infrastructure = {

        name =
            "Infrastructure Corridor",

        maxGoal =
            1800,

        duration =
            5,

        successReturn =
            28,

        failureRecovery =
            80,

        successChance =
            78,

        risk =
            "Medium"
    },


    industrial = {

        name =
            "Industrial Development",

        maxGoal =
            2000,

        duration =
            5,

        successReturn =
            35,

        failureRecovery =
            70,

        successChance =
            72,

        risk =
            "Medium"
    },


    resource = {

        name =
            "Resource Development",

        maxGoal =
            2400,

        duration =
            4,

        successReturn =
            45,

        failureRecovery =
            55,

        successChance =
            65,

        risk =
            "Medium-High"
    },


    technology = {

        name =
            "Technology Venture",

        maxGoal =
            3000,

        duration =
            6,

        successReturn =
            70,

        failureRecovery =
            35,

        successChance =
            55,

        risk =
            "High"
    },


    space = {
        name = "Space Exploration",
        maxGoal = 4000,
        duration = 8,
        successReturn = 100,
        failureRecovery = 20,
        successChance = 45,
        risk = "Very High"
    },

    agriculture = {
        name = "Agricultural Development",
        maxGoal = 1400,
        duration = 3,
        successReturn = 18,
        failureRecovery = 85,
        successChance = 86,
        risk = "Low"
    },

    energy = {
        name = "Energy Development",
        maxGoal = 2200,
        duration = 4,
        successReturn = 38,
        failureRecovery = 65,
        successChance = 70,
        risk = "Medium"
    },

    defense = {
        name = "Defense Industry Expansion",
        maxGoal = 2600,
        duration = 5,
        successReturn = 48,
        failureRecovery = 55,
        successChance = 64,
        risk = "Medium-High"
    },

    finance = {
        name = "Financial Center",
        maxGoal = 2800,
        duration = 5,
        successReturn = 55,
        failureRecovery = 50,
        successChance = 60,
        risk = "High"
    },

    logistics = {
        name = "Logistics & Supply Network",
        maxGoal = 1900,
        duration = 4,
        successReturn = 30,
        failureRecovery = 75,
        successChance = 76,
        risk = "Medium"
    }
};


-- =========================================================
-- SETTINGS
-- =========================================================

local function GetSetting(
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


local function GetMaxAgreements()

    return GetSetting(
        "MaxTradeAgreements",
        DEFAULT_MAX_AGREEMENTS
    );
end


local function GetCooldownTurns()

    return GetSetting(
        "TradeCooldownTurns",
        DEFAULT_COOLDOWN_TURNS
    );
end


-- =========================================================
-- DATA
-- =========================================================

local function GetData()

    local data =
        Mod.PublicGameData or {};


    -- =====================================================
    -- TRADE DATA
    -- =====================================================

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


    if data.aiTradeMemory == nil then
        data.aiTradeMemory = {};
    end


    -- =====================================================
    -- INVESTMENT DATA
    -- =====================================================

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

    -- =====================================================
    -- GLOBAL ECONOMY
    -- =====================================================

    if data.globalEconomy == nil then
        data.globalEconomy = {};
    end


    local economy =
        data.globalEconomy;


    if economy.version == nil then
        economy.version = 2;
    end


    if economy.initialized == nil then
        economy.initialized = true;
    end


    if economy.currentEconomyTurn == nil then
        economy.currentEconomyTurn = 1;
    end


    if economy.nations == nil then
        economy.nations = {};
    end


    -- =====================================================
    -- DIPLOMACY DATA
    -- =====================================================

    if economy.diplomacy == nil then
        economy.diplomacy = {};
    end


    if economy.diplomacy.relationships == nil then
        economy.diplomacy.relationships = {};
    end


    if economy.diplomacy.pendingWarDeclarations == nil then
        economy.diplomacy.pendingWarDeclarations = {};
    end


    if economy.diplomacy.pendingPeaceOffers == nil then
        economy.diplomacy.pendingPeaceOffers = {};
    end


    if economy.diplomacy.pendingNAPOffers == nil then
        economy.diplomacy.pendingNAPOffers = {};
    end

    if economy.diplomacy.pendingAllianceOffers == nil then
    economy.diplomacy.pendingAllianceOffers = {};
end

if economy.diplomacy.alliances == nil then
    economy.diplomacy.alliances = {};
end

if economy.diplomacy.factions == nil then
    economy.diplomacy.factions = {};
end

if economy.diplomacy.pendingFactionInvites == nil then
    economy.diplomacy.pendingFactionInvites = {};
end

if economy.diplomacy.playerFaction == nil then
    economy.diplomacy.playerFaction = {};
end

if economy.diplomacy.nextFactionID == nil then
    economy.diplomacy.nextFactionID = 1;
end

    if economy.diplomacy.nonAggressionPacts == nil then
        economy.diplomacy.nonAggressionPacts = {};
    end


    if economy.diplomacy.history == nil then
        economy.diplomacy.history = {};
    end


    if economy.market == nil then
        economy.market = {};
    end


    if economy.market.companies == nil then
        economy.market.companies = {};
    end


    if economy.market.transactions == nil then
        economy.market.transactions = {};
    end


    if economy.market.priceHistory == nil then
        economy.market.priceHistory = {};
    end


    if economy.market.nextCompanyID == nil then
        economy.market.nextCompanyID = 1;
    end


    if economy.worldEvents == nil then
        economy.worldEvents = {};
    end


    if economy.pendingWorldReportEvents == nil then
        economy.pendingWorldReportEvents = {};
    end


    if economy.turnReports == nil then
        economy.turnReports = {};
    end


    if economy.transactionLedger == nil then
        economy.transactionLedger = {};
    end


    if economy.economicRankings == nil then
        economy.economicRankings = {};
    end


    data.globalEconomy =
        economy;


    return data;
end


-- =========================================================
-- BASIC HELPERS
-- =========================================================

local function MakeInteger(value)

    local number =
        tonumber(value);


    if number == nil then
        return nil;
    end


    return math.floor(number);
end


local function TrimString(value)

    if value == nil then
        return "";
    end


    local text =
        tostring(value);


    text =
        string.gsub(
            text,
            "^%s+",
            ""
        );


    text =
        string.gsub(
            text,
            "%s+$",
            ""
        );


    return text;
end


local function PairKey(
    playerA,
    playerB
)

    local a =
        tostring(playerA);

    local b =
        tostring(playerB);


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


-- =========================================================
-- DIPLOMACY HELPERS
-- =========================================================

local GetPlayerName;
local AddWorldEvent;
local AddTradeHistory;


local function GetDiplomacyData(data)

    local economy =
        data.globalEconomy;


    economy.diplomacy =
        economy.diplomacy or {};


    local diplomacy =
        economy.diplomacy;


    diplomacy.relationships =
        diplomacy.relationships or {};


    diplomacy.pendingWarDeclarations =
        diplomacy.pendingWarDeclarations or {};


    diplomacy.pendingPeaceOffers =
        diplomacy.pendingPeaceOffers or {};


    diplomacy.pendingNAPOffers =
        diplomacy.pendingNAPOffers or {};

diplomacy.pendingAllianceOffers =
    diplomacy.pendingAllianceOffers or {};

diplomacy.alliances =
    diplomacy.alliances or {};

diplomacy.factions =
    diplomacy.factions or {};

diplomacy.pendingFactionInvites =
    diplomacy.pendingFactionInvites or {};

diplomacy.playerFaction =
    diplomacy.playerFaction or {};

diplomacy.nextFactionID =
    diplomacy.nextFactionID or 1;

    diplomacy.nonAggressionPacts =
        diplomacy.nonAggressionPacts or {};


    diplomacy.history =
        diplomacy.history or {};


    return diplomacy;
end


local function GetCurrentEconomyTurn(data)

    local economy =
        data.globalEconomy or {};


    return
        economy.currentEconomyTurn
        or data.tradeTurn
        or 1;
end


local function AddDiplomacyHistory(
    data,
    eventType,
    player1,
    player2,
    message,
    extra
)

    local diplomacy =
        GetDiplomacyData(data);


    local entry =
    {

        turn =
            GetCurrentEconomyTurn(data),

        type =
            eventType,

        player1 =
            player1,

        player2 =
            player2,

        message =
            message
    };


    if extra ~= nil then

        for key, value
            in pairs(extra) do

            entry[key] =
                value;
        end
    end


    table.insert(
        diplomacy.history,
        entry
    );


    while #diplomacy.history
        > MAX_DIPLOMACY_HISTORY do

        table.remove(
            diplomacy.history,
            1
        );
    end
end


local function GetRelationship(
    data,
    playerA,
    playerB
)

    local diplomacy =
        GetDiplomacyData(data);


    local key =
        PairKey(
            playerA,
            playerB
        );


    local relationship =
        diplomacy.relationships[key];


    if relationship == nil then

        local startAtWar =
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
                startAtWar
                and "war"
                or "peace",

            sinceTurn =
                GetCurrentEconomyTurn(data),

            lastChangedTurn =
                GetCurrentEconomyTurn(data),

            peaceCooldownUntil =
                0
        };


        diplomacy.relationships[key] =
            relationship;
    end


    return relationship;
end
local function IsAtWar(
    data,
    playerA,
    playerB
)

    local relationship =
        GetRelationship(
            data,
            playerA,
            playerB
        );


    return
        relationship.status
        == "war";
end


local function IsAtPeace(
    data,
    playerA,
    playerB
)

    local relationship =
        GetRelationship(
            data,
            playerA,
            playerB
        );


    return
        relationship.status
        == "peace";
end


local function GetActiveNAP(
    data,
    playerA,
    playerB
)

    local diplomacy =
        GetDiplomacyData(data);


    local key =
        PairKey(
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


    local currentTurn =
        GetCurrentEconomyTurn(data);


    if pact.active ~= true
        or currentTurn
        >= (
            pact.endTurn
            or currentTurn
        ) then

        return nil;
    end


    return pact;
end


local function HasPendingWarDeclaration(
    data,
    playerA,
    playerB
)

    local diplomacy =
        GetDiplomacyData(data);


    local key =
        PairKey(
            playerA,
            playerB
        );


    return
        diplomacy.pendingWarDeclarations[
            key
        ] ~= nil;
end


local function HasPendingPeaceOffer(
    data,
    playerA,
    playerB
)

    local diplomacy =
        GetDiplomacyData(data);


    for _, offer in pairs(
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


local function HasPendingNAPOffer(
    data,
    playerA,
    playerB
)

    local diplomacy =
        GetDiplomacyData(data);


    for _, offer in pairs(
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


local function GetPeaceCooldownRemaining(
    data,
    playerA,
    playerB
)

    local relationship =
        GetRelationship(
            data,
            playerA,
            playerB
        );


    local currentTurn =
        GetCurrentEconomyTurn(data);


    local untilTurn =
        relationship.peaceCooldownUntil
        or 0;


    local remaining =
        untilTurn
        - currentTurn;


    if remaining < 0 then

        remaining =
            0;
    end


    return remaining;
end


local function RemoveTradeAgreementBetween(
    data,
    playerA,
    playerB,
    reason
)

    for index =
        #data.activeAgreements,
        1,
        -1
    do

        local agreement =
            data.activeAgreements[index];


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
                index
            );


            if AddTradeHistory ~= nil then

                AddTradeHistory(
                    data,
                    "agreement_ended",
                    reason
                    or
                    "A trade agreement ended because the nations entered a state of war.",
                    playerA,
                    playerB,
                    false
                );
            end
        end
    end
end


local function CancelPendingTradeBetween(
    data,
    playerA,
    playerB
)

    for index =
        #data.pendingProposals,
        1,
        -1
    do

        local proposal =
            data.pendingProposals[index];


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
                index
            );
        end
    end
end


local function EndNAPBetween(
    data,
    playerA,
    playerB
)

    local diplomacy =
        GetDiplomacyData(data);


    local key =
        PairKey(
            playerA,
            playerB
        );


    diplomacy.nonAggressionPacts[
        key
    ] =
        nil;


    for index =
        #diplomacy.pendingNAPOffers,
        1,
        -1
    do

        local offer =
            diplomacy.pendingNAPOffers[
                index
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
                index
            );
        end
    end
end


local function EnterWar(
    data,
    game,
    playerA,
    playerB,
    source
)

    local diplomacy =
        GetDiplomacyData(data);


    local relationship =
        GetRelationship(
            data,
            playerA,
            playerB
        );


    local currentTurn =
        GetCurrentEconomyTurn(data);


    relationship.status =
        "war";


    relationship.sinceTurn =
        currentTurn;


    relationship.lastChangedTurn =
        currentTurn;


    relationship.lastWarTurn =
        currentTurn;


    local key =
        PairKey(
            playerA,
            playerB
        );


    diplomacy.pendingWarDeclarations[
        key
    ] =
        nil;


    for index =
        #diplomacy.pendingPeaceOffers,
        1,
        -1
    do

        local offer =
            diplomacy.pendingPeaceOffers[
                index
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
                index
            );
        end
    end


    EndNAPBetween(
        data,
        playerA,
        playerB
    );


    CancelPendingTradeBetween(
        data,
        playerA,
        playerB
    );


    local playerAName =
        GetPlayerName ~= nil
        and GetPlayerName(
            game,
            playerA
        )
        or tostring(
            playerA
        );


    local playerBName =
        GetPlayerName ~= nil
        and GetPlayerName(
            game,
            playerB
        )
        or tostring(
            playerB
        );


    local warMessage =
        playerAName ..
        " and " ..
        playerBName ..
        " are now officially at war.";


    RemoveTradeAgreementBetween(
        data,
        playerA,
        playerB,
        playerAName ..
        " and " ..
        playerBName ..
        " ended their trade agreement because war began."
    );


    AddDiplomacyHistory(
        data,
        "war_started",
        playerA,
        playerB,
        warMessage,
        {
            source =
                source
                or "declaration"
        }
    );


    if AddWorldEvent ~= nil then

        AddWorldEvent(
            data.globalEconomy,
            "war_started",
            playerA,
            warMessage,
            {
                otherPlayerID =
                    playerB
            }
        );
    end
end


local function EnterPeace(
    data,
    game,
    playerA,
    playerB
)

    local diplomacy =
        GetDiplomacyData(data);


    local relationship =
        GetRelationship(
            data,
            playerA,
            playerB
        );


    local currentTurn =
        GetCurrentEconomyTurn(data);


    relationship.status =
        "peace";


    relationship.sinceTurn =
        currentTurn;


    relationship.lastChangedTurn =
        currentTurn;


    relationship.lastPeaceTurn =
        currentTurn;


    local cooldownTurns =
        GetSetting(
            "PeaceCooldownTurns",
            DEFAULT_PEACE_COOLDOWN_TURNS
        );


    if cooldownTurns < 0 then

        cooldownTurns =
            0;
    end


    relationship.peaceCooldownUntil =
        currentTurn
        + cooldownTurns;


    local key =
        PairKey(
            playerA,
            playerB
        );


    diplomacy.pendingWarDeclarations[
        key
    ] =
        nil;


    for index =
        #diplomacy.pendingPeaceOffers,
        1,
        -1
    do

        local offer =
            diplomacy.pendingPeaceOffers[
                index
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
                index
            );
        end
    end


    local playerAName =
        GetPlayerName(
            game,
            playerA
        );


    local playerBName =
        GetPlayerName(
            game,
            playerB
        );


    local peaceMessage =
        playerAName ..
        " and " ..
        playerBName ..
        " have agreed to peace.";


    AddDiplomacyHistory(
        data,
        "peace_started",
        playerA,
        playerB,
        peaceMessage,
        {
            peaceCooldownUntil =
                relationship.peaceCooldownUntil
        }
    );


    if AddWorldEvent ~= nil then

        AddWorldEvent(
            data.globalEconomy,
            "peace_started",
            playerA,
            peaceMessage,
            {
                otherPlayerID =
                    playerB
            }
        );
    end
end


-- =========================================================
-- PLAYER HELPERS
-- =========================================================

local function GetPlayer(
    game,
    playerID
)

    if game.Game == nil
        or game.Game.Players == nil then

        return nil;
    end


    return
        game.Game.Players[
            playerID
        ];
end


GetPlayerName =
function(
    game,
    playerID
)

    local player =
        GetPlayer(
            game,
            playerID
        );


    if player == nil then

        return
            "Unknown Player";
    end


    return player.DisplayName(
        nil,
        false
    );
end


local function PlayerAvailable(
    game,
    playerID
)

    local player =
        GetPlayer(
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
-- NATIONAL STATE
-- =========================================================

local function EnsureNation(
    data,
    game,
    playerID
)

    local economy =
        data.globalEconomy;


    if economy.nations[playerID]
        ~= nil then

        local existingNation =
            economy.nations[
                playerID
            ];


        existingNation.relationships =
            existingNation.relationships
            or {};


        existingNation.pendingWarDeclarations =
            existingNation.pendingWarDeclarations
            or {};


        existingNation.pendingPeaceOffers =
            existingNation.pendingPeaceOffers
            or {};


        existingNation.nonAggressionPacts =
            existingNation.nonAggressionPacts
            or {};


        existingNation.lastPeaceTurn =
            existingNation.lastPeaceTurn
            or {};


        return existingNation;
    end


    local player =
        GetPlayer(
            game,
            playerID
        );


    local nation =
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


        -- =============================================
        -- ECONOMY
        -- =============================================

        commerceHistory =
            {},

        storedGoldHistory =
            {},

        economicRankHistory =
            {},

        economicPowerScore =
            0,

        currentEconomicRank =
            nil,


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
        -- TRADE
        -- =============================================

        tradeIncomeThisTurn =
            0,

        totalTradeIncome =
            0,


        -- =============================================
        -- INVESTMENTS
        -- =============================================

        totalProjectInvested =
            0,

        totalProjectReturned =
            0,

        projectProfitLoss =
            0,


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

        lastUNProposalTurn =
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


    economy.nations[playerID] =
        nation;


    data.globalEconomy =
        economy;


    return nation;
end
local function CalculateStartingStockPrice(
    game,
    playerID
)

    local player =
        game.Game.Players[
            playerID
        ];

    if player == nil
        or game.ServerGame == nil
        or game.ServerGame.LatestTurnStanding == nil then

        return 25;
    end

    local incomeInfo =
        player.Income(
            0,
            game.ServerGame.LatestTurnStanding,
            true,
            false
        );

    local income =
        0;

    if incomeInfo ~= nil then
        income =
            incomeInfo.Total
            or 0;
    end

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

local function CompanyNameExists(
    economy,
    companyName
)

    local normalized =
        string.lower(
            companyName
        );


    for _, company in pairs(
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


-- =========================================================
-- HISTORY
-- =========================================================

AddTradeHistory =
function(
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


local function AddInvestmentHistory(
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
-- WORLD / PERSONAL EVENTS
-- =========================================================

AddWorldEvent =
function(
    economy,
    eventType,
    playerID,
    headline,
    extra
)

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

        for key, value
            in pairs(extra) do

            event[key] =
                value;
        end
    end


    table.insert(
        economy.worldEvents,
        event
    );


    table.insert(
        economy.pendingWorldReportEvents,
        {

            turn =
                event.turn,

            type =
                event.type,

            playerID =
                event.playerID,

            headline =
                event.headline
        }
    );


    return event;
end


local function AddPersonalEvent(
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


local function AddLedgerEvent(
    economy,
    currentTurn,
    eventType,
    playerID,
    amount,
    description,
    extra
)

    local entry =
    {

        turn =
            currentTurn,

        type =
            eventType,

        playerID =
            playerID,

        amount =
            amount
            or 0,

        description =
            description
    };


    if extra ~= nil then

        for key, value
            in pairs(extra) do

            entry[key] =
                value;
        end
    end


    table.insert(
        economy.transactionLedger,
        entry
    );
end


-- =========================================================
-- GOLD
-- =========================================================

local function GetStoredGold(
    game,
    playerID
)

    if game.ServerGame == nil
        or game.ServerGame.LatestTurnStanding
            == nil then

        return 0;
    end


    return game.ServerGame
        .LatestTurnStanding
        .NumResources(
            playerID,
            WL.ResourceType.Gold
        );
end


local function RemoveGold(
    game,
    playerID,
    amount
)

    local currentGold =
        GetStoredGold(
            game,
            playerID
        );


    if currentGold < amount then
        return false;
    end


    game.ServerGame.SetPlayerResource(
        playerID,
        WL.ResourceType.Gold,
        currentGold - amount
    );


    return true;
end

local function AddGold(
    game,
    playerID,
    amount
)

    if amount <= 0 then
        return;
    end

    local currentGold =
        GetStoredGold(
            game,
            playerID
        );

    game.ServerGame.SetPlayerResource(
        playerID,
        WL.ResourceType.Gold,
        currentGold + amount
    );

end

-- =========================================================
-- TRADE HELPERS
-- =========================================================

local function CountActiveAgreements(
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
                count + 1;
        end
    end


    return count;
end


local function HasActiveAgreement(
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


            return true;
        end
    end


    return false;
end


local function HasPendingTrade(
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


            return true;
        end
    end


    return false;
end


local function StartCooldown(
    data,
    playerA,
    playerB
)

    local turns =
        GetCooldownTurns();


    if turns <= 0 then
        return;
    end


    local key =
        PairKey(
            playerA,
            playerB
        );


    data.cooldowns[key] =
        data.tradeTurn
        + turns;
end


local function IsOnCooldown(
    data,
    playerA,
    playerB
)

    local key =
        PairKey(
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


local function GetCommerceIncome(
    game,
    playerID
)

    local player =
        GetPlayer(
            game,
            playerID
        );


    if player == nil then
        return 0;
    end


    if game.ServerGame == nil
        or game.ServerGame.LatestTurnStanding
            == nil then

        return 0;
    end


    local incomeInfo =
        player.Income(
            0,
            game.ServerGame.LatestTurnStanding,
            true,
            false
        );


    if incomeInfo == nil then
        return 0;
    end


    return
        incomeInfo.Total
        or 0;
end


-- =========================================================
-- AI TRADE RESPONSE
-- =========================================================

local function EvaluateAITrade(
    game,
    data,
    aiPlayerID,
    proposerID
)

    local maxAgreements =
        GetMaxAgreements();


    if CountActiveAgreements(
        data,
        aiPlayerID
    ) >= maxAgreements then

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
        CountActiveAgreements(
            data,
            aiPlayerID
        );


    chance =
        chance
        - (
            existing * 8
        );


    if chance < 10 then
        chance = 10;
    end


    if chance > 95 then
        chance = 95;
    end


    return
        math.random(
            1,
            100
        )
        <= chance;
end


-- =========================================================
-- INVESTMENT HELPERS
-- =========================================================

local function FindInvestmentProject(
    data,
    projectID
)

    for index, project
        in ipairs(
            data.investmentProjects
        ) do


        if project.id
            == projectID then

            return
                project,
                index;
        end
    end


    return
        nil,
        nil;
end


local function FindInvestorEntry(
    project,
    playerID
)

    for index, investment
        in ipairs(
            project.investments
            or {}
        ) do


        if investment.playerID
            == playerID then

            return
                investment,
                index;
        end
    end


    return
        nil,
        nil;
end


local function CountOutsideInvestors(
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


local function ActivateProject(
    game,
    data,
    project
)

    if project.status
        ~= "funding" then

        return;
    end


    if (
        project.currentFunding
        or 0
    ) < (
        project.fundingGoal
        or 0
    ) then

        return;
    end


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
        GetPlayerName(
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
end


-- =========================================================
-- STRATEGIC RESOURCE HELPERS
-- =========================================================

local RESOURCE_TYPES = {
    ["Oil"] = true,
    ["Gas"] = true,
    ["Uranium"] = true,
    ["Iron"] = true,
    ["Food"] = true,
    ["Rare Earths"] = true,
    ["Coal"] = true,
    ["Copper"] = true,
    ["Lithium"] = true
};

local function EnsureResourceData(data)
    if data.globalEconomy == nil then return nil; end
    local economy = data.globalEconomy;
    economy.resources = economy.resources or {
        enabled = GetSetting("ResourcesEnabled", true),
        advancedEnabled = GetSetting("AdvancedResourcesEnabled", true),
        randomizedPlacement = GetSetting("RandomizedResourcePlacement", false),
        territories = {}, pendingBuilds = {}, pendingOffers = {},
        activeTrades = {}, tradeHistory = {}, nextOfferID = 1
    };
    local resources = economy.resources;
    resources.territories = resources.territories or {};
    resources.pendingBuilds = resources.pendingBuilds or {};
    resources.pendingOffers = resources.pendingOffers or {};
    resources.activeTrades = resources.activeTrades or {};
    resources.tradeHistory = resources.tradeHistory or {};
    resources.nextOfferID = resources.nextOfferID or 1;
    return resources;
end

local function EnsureNationResourceFields(nation)
    nation.resourceProduction = nation.resourceProduction or {};
    nation.resourceEffective = nation.resourceEffective or {};
    nation.resourceShortages = nation.resourceShortages or {};
    nation.resourcePenaltyPercent = nation.resourcePenaltyPercent or 0;
    nation.resourceMilitaryReadiness = nation.resourceMilitaryReadiness or 100;
    nation.resourceUnrest = nation.resourceUnrest or 0;
    nation.resourceBuildReservedGold = nation.resourceBuildReservedGold or 0;
end

local function IsAdvancedResource(resourceName)
    return resourceName == "Coal"
        or resourceName == "Copper"
        or resourceName == "Lithium";
end

local function FindResourceOffer(resources, offerID)
    for index, offer in ipairs(resources.pendingOffers or {}) do
        if offer.id == offerID then return index, offer; end
    end
    return nil, nil;
end



-- =========================================================
-- UNITED NATIONS HELPERS
-- =========================================================

local UN_RESOLUTION_TYPES = {
    sanctions = true,
    embargo = true,
    aid = true,
    condemnation = true,
    ceasefire = true
};

local function EnsureUNData(data)

    local economy =
        data.globalEconomy
        or {};

    data.globalEconomy =
        economy;

    economy.unitedNations =
        economy.unitedNations
        or data.unitedNations
        or {
            enabled = GetSetting("UnitedNationsEnabled", true),
            activeResolutions = {},
            resolutionHistory = {},
            nextResolutionID = 1,
            lastProposalTurnByPlayer = {},
            permanentMembers = {},
            rotatingMembers = {},
            sanctions = {},
            embargoes = {},
            condemnations = {}
        };

    local un =
        economy.unitedNations;

    un.activeResolutions =
        un.activeResolutions
        or {};

    un.resolutionHistory =
        un.resolutionHistory
        or {};

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

    un.nextResolutionID =
        un.nextResolutionID
        or 1;

    data.unitedNations =
        un;

    return un;
end


local function UNContains(
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


local function UNIsCouncilMember(
    un,
    playerID
)

    return
        UNContains(
            un.permanentMembers,
            playerID
        )
        or
        UNContains(
            un.rotatingMembers,
            playerID
        );
end


local function UNEmbargoActive(
    data,
    playerID
)

    local un =
        EnsureUNData(
            data
        );

    local embargo =
        un.embargoes[
            playerID
        ];

    return embargo ~= nil
        and (
            embargo.untilTurn
            or 0
        )
        >= (
            data.tradeTurn
            or 0
        );
end


-- =========================================================
-- PUBLIC GAME DATA COMPACTION
-- =========================================================
-- Keep the same bounded-history policy used by Server_AdvanceTurn so a custom
-- action cannot re-save an oversized PublicGameData table between turns.

local function TrimArrayKeepNewestForSave(list, maxItems)
    if type(list) ~= "table" then return; end
    while #list > maxItems do
        table.remove(list, 1);
    end
end

local function TrimArrayKeepNewestFrontForSave(list, maxItems)
    if type(list) ~= "table" then return; end
    while #list > maxItems do
        table.remove(list);
    end
end

local function CompactPublicGameDataForSave(data)
    if type(data) ~= "table" then return; end

    TrimArrayKeepNewestForSave(data.tradeHistory, 30);
    TrimArrayKeepNewestForSave(data.investmentHistory, 30);
    TrimArrayKeepNewestForSave(data.completedInvestmentProjects, 30);

    local economy = data.globalEconomy;
    if type(economy) ~= "table" then return; end

    TrimArrayKeepNewestForSave(economy.worldEvents, 30);
    TrimArrayKeepNewestForSave(economy.pendingWorldReportEvents, 10);
    TrimArrayKeepNewestForSave(economy.transactionLedger, 30);

    for _, nation in pairs(economy.nations or {}) do
        TrimArrayKeepNewestForSave(nation.personalEventQueue, 10);
    end

    local market = economy.market;
    if type(market) == "table" then
        TrimArrayKeepNewestForSave(market.transactions, 40);
        TrimArrayKeepNewestForSave(market.news, 30);
        TrimArrayKeepNewestForSave(market.priceHistory, 12);
        for _, company in pairs(market.companies or {}) do
            if type(company) == "table" then
                TrimArrayKeepNewestForSave(company.priceHistory, 12);
            end
        end
        if type(market.etf) == "table" then
            TrimArrayKeepNewestForSave(market.etf.priceHistory, 12);
        end
    end

    local diplomacy = economy.diplomacy;
    if type(diplomacy) == "table" then
        TrimArrayKeepNewestForSave(diplomacy.history, 40);
        TrimArrayKeepNewestFrontForSave(diplomacy.warEventHistory, 30);
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
        TrimArrayKeepNewestForSave(resources.tradeHistory, 20);
    end

    local un = economy.unitedNations;
    if type(un) == "table" then
        TrimArrayKeepNewestForSave(un.resolutionHistory, 25);
    end
end

-- =========================================================
-- MAIN HOOK
-- =========================================================

function Server_GameCustomMessage(
    game,
    playerID,
    payload,
    setReturn
)

    if payload == nil
        or payload.type == nil then


        setReturn({
            success = false,
            message =
                "Invalid request."
        });


        return;
    end


    local data =
        GetData();

    -- Compact as soon as a request arrives so large ongoing games can recover
    -- before this action writes PublicGameData again.
    CompactPublicGameDataForSave(data);

    local resourceData =
        EnsureResourceData(
            data
        );

    local unData =
        EnsureUNData(
            data
        );


    -- =====================================================
    -- MANDATORY NATIONAL SETUP SERVER LOCK
    -- =====================================================

    if payload.type
        ~= "saveNationalSetup" then


        if not PlayerAvailable(
            game,
            playerID
        ) then


            setReturn({
                success = false,
                message =
                    "This nation is not eligible to use the Global Economy."
            });


            return;
        end


        local setupNation =
            EnsureNation(
                data,
                game,
                playerID
            );


        if setupNation.eliminated
            == true then


            setReturn({
                success = false,
                message =
                    "Eliminated nations cannot use the Global Economy."
            });


            return;
        end


        if setupNation.setupComplete
            ~= true then


            setReturn({
                success = false,
                setupRequired = true,
                message =
                    "National Setup is required before you can use Trade Agreements, Investments, Diplomacy, Economic Reform, or other Global Economy systems."
            });


            return;
        end
    end


    -- =====================================================
    -- SAVE NATIONAL SETUP
    -- =====================================================

    if payload.type
        == "saveNationalSetup" then
        if not PlayerAvailable(
            game,
            playerID
        ) then


            setReturn({
                success = false,
                message =
                    "This nation is not eligible to complete National Setup."
            });


            return;
        end


        local nation =
            EnsureNation(
                data,
                game,
                playerID
            );


        if nation.eliminated then


            setReturn({
                success = false,
                message =
                    "Eliminated nations cannot complete National Setup."
            });


            return;
        end


        if nation.setupComplete then


            setReturn({
                success = false,
                message =
                    "Your National Setup has already been completed."
            });


            return;
        end


        local ideology =
            TrimString(
                payload.ideology
            );


        local economicStrategy =
            TrimString(
                payload.economicStrategy
            );


        local taxPolicy =
            TrimString(
                payload.taxPolicy
            );


        local companyName =
            TrimString(
                payload.companyName
            );


        local companyStrategy =
            TrimString(
                payload.companyStrategy
            );


        if not VALID_IDEOLOGIES[
            ideology
        ] then


            setReturn({
                success = false,
                message =
                    "Please select a valid ideology."
            });


            return;
        end


        if not VALID_ECONOMIC_STRATEGIES[
            economicStrategy
        ] then


            setReturn({
                success = false,
                message =
                    "Please select a valid economic strategy."
            });


            return;
        end


        if not VALID_TAX_POLICIES[
            taxPolicy
        ] then


            setReturn({
                success = false,
                message =
                    "Please select a valid starting tax policy."
            });


            return;
        end


        if not VALID_COMPANY_STRATEGIES[
            companyStrategy
        ] then


            setReturn({
                success = false,
                message =
                    "Please select a valid company strategy."
            });


            return;
        end


        local companyLength =
            string.len(
                companyName
            );


        if companyLength < 2 then


            setReturn({
                success = false,
                message =
                    "Your flagship company name must contain at least 2 characters."
            });


            return;
        end


        if companyLength > 40 then


            setReturn({
                success = false,
                message =
                    "Your flagship company name may not exceed 40 characters."
            });


            return;
        end


        if string.find(
            companyName,
            "[\r\n\t]"
        ) ~= nil then


            setReturn({
                success = false,
                message =
                    "Your flagship company name may not contain line breaks or tabs."
            });


            return;
        end


        local economy =
            data.globalEconomy;


        if CompanyNameExists(
            economy,
            companyName
        ) then


            setReturn({
                success = false,
                message =
                    "Another nation already uses that company name. Please choose a different flagship company name."
            });


            return;
        end


        -- =================================================
        -- CREATE FLAGSHIP COMPANY
        -- =================================================

        local companyID =
            economy.market.nextCompanyID
            or 1;


        economy.market.nextCompanyID =
            companyID + 1;


        local founderSharePercent =
            GetSetting(
                "FounderSharePercent",
                20
            );


        if founderSharePercent < 0 then
            founderSharePercent = 0;
        end


        if founderSharePercent > 100 then
            founderSharePercent = 100;
        end


        local totalShares =
            100;


        local founderShares =
            math.floor(
                totalShares
                * (
                    founderSharePercent
                    / 100
                )
                + 0.5
            );


        local publicShares =
            totalShares
            - founderShares;


        local currentTurn =
            economy.currentEconomyTurn
            or 1;


        local ownerName =
            GetPlayerName(
                game,
                playerID
            );

        local startingPrice =
    CalculateStartingStockPrice(
        game,
        playerID
    );

        local company =
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

publicShares =
    publicShares,

sharesAvailable =
    publicShares,

primarySharesRemaining =
    publicShares,

startingPrice =
    startingPrice,

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


        economy.market.companies[
            companyID
        ] =
            company;


        -- =================================================
        -- SAVE NATIONAL SETTINGS
        -- =================================================

        nation.ideology =
            ideology;


        nation.economicStrategy =
            economicStrategy;


        nation.taxPolicy =
            taxPolicy;


        nation.taxPolicyLastChangedTurn =
            currentTurn;


        nation.companies =
            nation.companies
            or {};


        table.insert(
            nation.companies,
            companyID
        );

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


        nation.companySlotsUnlocked =
            math.max(
                nation.companySlotsUnlocked
                or 1,
                1
            );


        nation.setupComplete =
            true;


        nation.setupCompletedTurn =
            currentTurn;


        nation.reformActive =
            false;


        nation.reformPenaltyPercent =
            0;


        AddPersonalEvent(
            nation,
            currentTurn,
            "national_setup_complete",
            "National Setup completed. " ..
            companyName ..
            " has been established as your flagship company."
        );


        local worldMessage =
            ownerName ..
            " completed its national economic setup and established " ..
            companyName ..
            ".";


        AddWorldEvent(
            economy,
            "national_setup_complete",
            playerID,
            worldMessage,
            {
                companyID =
                    companyID
            }
        );


        AddLedgerEvent(
            economy,
            currentTurn,
            "company_created",
            playerID,
            0,
            ownerName ..
            " created flagship company " ..
            companyName ..
            ".",
            {
                companyID =
                    companyID
            }
        );


        economy.nations[
            playerID
        ] =
            nation;


        data.globalEconomy =
            economy;


        CompactPublicGameDataForSave(data);
        Mod.PublicGameData =
            data;


        setReturn({

            success =
                true,

            setupComplete =
                true,

            companyID =
                companyID,

            companyName =
                companyName,

            message =
                "National Setup complete. " ..
                companyName ..
                " is now your flagship company."
        });


        return;
    end


    -- =====================================================
    -- PLAYER AI MANAGER
    -- =====================================================

    if payload.type
        == "updateAIManager" then

        if GetSetting(
            "PlayerAIManagerEnabled",
            true
        ) ~= true then

            setReturn({
                success = false,
                message =
                    "The host has disabled the AI Manager."
            });

            return;
        end

        local nation =
            EnsureNation(
                data,
                game,
                playerID
            );

        local economy =
            data.globalEconomy
            or {};

        local currentTurn =
            economy.currentEconomyTurn
            or data.tradeTurn
            or 1;

        local requestedEnabled =
            payload.enabled == true;

        local requestedBudget =
            tonumber(
                payload.budget
            )
            or nation.aiManagerBudget
            or 100;

        requestedBudget =
            math.max(
                25,
                math.min(
                    100000,
                    math.floor(
                        requestedBudget
                    )
                )
            );

        nation.aiManagerBudget =
            requestedBudget;

        if requestedEnabled then

            nation.aiManagerEnabled =
                true;

            nation.aiManagerCancelTurn =
                nil;

            setReturn({
                success = true,
                enabled = true,
                budget = requestedBudget,
                message =
                    "AI Manager enabled with a " ..
                    tostring(requestedBudget) ..
                    " gold per-turn spending budget."
            });

        else

            if nation.aiManagerEnabled == true then

                nation.aiManagerCancelTurn =
                    currentTurn + 1;

                setReturn({
                    success = true,
                    enabled = true,
                    pendingCancel = true,
                    cancelTurn =
                        nation.aiManagerCancelTurn,
                    budget = requestedBudget,
                    message =
                        "AI Manager cancellation scheduled. It will stop after one more turn."
                });

            else

                nation.aiManagerEnabled =
                    false;

                nation.aiManagerCancelTurn =
                    nil;

                setReturn({
                    success = true,
                    enabled = false,
                    budget = requestedBudget,
                    message =
                        "AI Manager is already disabled."
                });

            end

        end

        economy.nations[playerID] =
            nation;

        data.globalEconomy =
            economy;

        CompactPublicGameDataForSave(data);
        Mod.PublicGameData =
            data;

        return;
    end


    -- =====================================================
    -- ECONOMIC REFORM
    -- =====================================================

    if payload.type
        == "reformNationalSetup" then


        if not PlayerAvailable(
            game,
            playerID
        ) then


            setReturn({
                success = false,
                message =
                    "This nation is not eligible to begin an economic reform."
            });


            return;
        end


        local nation =
            EnsureNation(
                data,
                game,
                playerID
            );


        if nation.eliminated then


            setReturn({
                success = false,
                message =
                    "Eliminated nations cannot begin economic reforms."
            });


            return;
        end


        if nation.setupComplete
            ~= true then


            setReturn({
                success = false,
                message =
                    "You must complete National Setup before beginning an economic reform."
            });


            return;
        end


        local economy =
            data.globalEconomy;


        local currentTurn =
            economy.currentEconomyTurn
            or 1;


        if nation.reformActive
            == true then


            local reformEndTurn =
                nation.reformEndTurn
                or currentTurn;


            if currentTurn
                < reformEndTurn then


                local remaining =
                    reformEndTurn
                    - currentTurn;


                setReturn({

                    success =
                        false,

                    message =
                        "Your nation is already undergoing economic reform. " ..
                        tostring(
                            remaining
                        ) ..
                        " turn(s) remain."
                });


                return;
            end


            nation.reformActive =
                false;


            nation.reformEndTurn =
                nil;


            nation.reformPenaltyPercent =
                0;
        end


        local ideology =
            TrimString(
                payload.ideology
            );


        local economicStrategy =
            TrimString(
                payload.economicStrategy
            );


        local taxPolicy =
            TrimString(
                payload.taxPolicy
            );


        local companyStrategy =
            TrimString(
                payload.companyStrategy
            );


        if not VALID_IDEOLOGIES[
            ideology
        ] then


            setReturn({
                success = false,
                message =
                    "Please select a valid ideology."
            });


            return;
        end


        if not VALID_ECONOMIC_STRATEGIES[
            economicStrategy
        ] then


            setReturn({
                success = false,
                message =
                    "Please select a valid economic strategy."
            });


            return;
        end


        if not VALID_TAX_POLICIES[
            taxPolicy
        ] then


            setReturn({
                success = false,
                message =
                    "Please select a valid tax policy."
            });


            return;
        end


        if not VALID_COMPANY_STRATEGIES[
            companyStrategy
        ] then


            setReturn({
                success = false,
                message =
                    "Please select a valid company strategy."
            });


            return;
        end


        local ideologyChanged =
            ideology
            ~= nation.ideology;


        local economicStrategyChanged =
            economicStrategy
            ~= nation.economicStrategy;


        local taxChanged =
            taxPolicy
            ~= nation.taxPolicy;


        local companyStrategyChanged =
            companyStrategy
            ~= nation.companyStrategy;


        if not ideologyChanged
            and not economicStrategyChanged
            and not taxChanged
            and not companyStrategyChanged then


            setReturn({
                success = false,
                message =
                    "No national policies were changed."
            });


            return;
        end


        local fullReform =
            ideologyChanged
            or economicStrategyChanged
            or companyStrategyChanged;


        nation.previousIdeology =
            nation.ideology;


        nation.previousEconomicStrategy =
            nation.economicStrategy;


        nation.previousTaxPolicy =
            nation.taxPolicy;


        nation.previousCompanyStrategy =
            nation.companyStrategy;


        nation.ideology =
            ideology;


        nation.economicStrategy =
            economicStrategy;


        nation.taxPolicy =
            taxPolicy;


        nation.companyStrategy =
            companyStrategy;


        nation.taxPolicyLastChangedTurn =
            currentTurn;


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


                company.strategy =
                    companyStrategy;


                company.ideology =
                    ideology;


                company.nationStrategy =
                    economicStrategy;
            end
        end


        if fullReform then


            nation.reformActive =
                true;


            nation.reformStartedTurn =
                currentTurn;


            nation.reformEndTurn =
                currentTurn
                + REFORM_DURATION_TURNS;


            nation.reformPenaltyPercent =
                REFORM_PENALTY_PERCENT;


            nation.reformCount =
                (
                    nation.reformCount
                    or 0
                )
                + 1;


            nation.lastReformTurn =
                currentTurn;


            AddPersonalEvent(
                nation,
                currentTurn,
                "economic_reform_started",
                "Economic reform has begun. Your nation will experience a temporary -" ..
                tostring(
                    REFORM_PENALTY_PERCENT
                ) ..
                "% economic confidence penalty for " ..
                tostring(
                    REFORM_DURATION_TURNS
                ) ..
                " turns."
            );
        else


            -- Tax-only policy change.
            -- The Taxation system will later apply its
            -- dedicated host-configurable cooldown.

            nation.reformActive =
                false;


            nation.reformStartedTurn =
                nil;


            nation.reformEndTurn =
                nil;


            nation.reformPenaltyPercent =
                0;


            AddPersonalEvent(
                nation,
                currentTurn,
                "tax_policy_changed",
                "Your national tax policy has been changed to " ..
                taxPolicy ..
                "."
            );
        end


        local nationName =
            GetPlayerName(
                game,
                playerID
            );


        local eventType =
            nil;


        local headline =
            nil;


        if fullReform then


            eventType =
                "economic_reform_started";


            headline =
                nationName ..
                " has begun a major economic reform.";


        else


            eventType =
                "tax_policy_changed";


            headline =
                nationName ..
                " adjusted its national tax policy.";
        end


        AddWorldEvent(
            economy,
            eventType,
            playerID,
            headline,
            nil
        );


        AddLedgerEvent(
            economy,
            currentTurn,
            fullReform
                and "economic_reform"
                or "tax_policy_change",
            playerID,
            0,
            headline,
            nil
        );


        economy.nations[
            playerID
        ] =
            nation;


        data.globalEconomy =
            economy;


        CompactPublicGameDataForSave(data);
        Mod.PublicGameData =
            data;


        if fullReform then


            setReturn({

                success =
                    true,

                reformActive =
                    true,

                reformEndTurn =
                    nation.reformEndTurn,

                reformPenaltyPercent =
                    REFORM_PENALTY_PERCENT,

                message =
                    "Economic reform approved. Your new policies are active, but your nation will suffer a temporary -" ..
                    tostring(
                        REFORM_PENALTY_PERCENT
                    ) ..
                    "% economic confidence penalty for " ..
                    tostring(
                        REFORM_DURATION_TURNS
                    ) ..
                    " turns."
            });


        else


            setReturn({

                success =
                    true,

                reformActive =
                    false,

                message =
                    "Tax policy changed successfully."
            });
        end


        return;
    end


    -- =====================================================
    -- WAR REASON HELPERS
    -- =====================================================

    local allowedWarReasons = {
        ["Territorial Dispute"] = true,
        ["Resource Security"] = true,
        ["National Defense / Border Threat"] = true,
        ["Support an Ally"] = true,
        ["Economic Conflict"] = true,
        ["Ideological Conflict"] = true
    };

    -- =====================================================
    -- DECLARE WAR
    -- =====================================================

    if payload.type
        == "declareWar" then


        local targetPlayerID =
            MakeInteger(
                payload.targetPlayerID
            );

        local warReason = tostring(payload.reason or "Territorial Dispute");
        if allowedWarReasons[warReason] ~= true then
            warReason = "Territorial Dispute";
        end


        if targetPlayerID == nil then


            setReturn({
                success = false,
                message =
                    "Invalid nation."
            });


            return;
        end


        if targetPlayerID
            == playerID then


            setReturn({
                success = false,
                message =
                    "You cannot declare war on your own nation."
            });


            return;
        end


        if not PlayerAvailable(
            game,
            targetPlayerID
        ) then


            setReturn({
                success = false,
                message =
                    "That nation is no longer available."
            });


            return;
        end


        local targetNation =
            EnsureNation(
                data,
                game,
                targetPlayerID
            );


        if targetNation.eliminated
            == true then


            setReturn({
                success = false,
                message =
                    "You cannot declare war on an eliminated nation."
            });


            return;
        end


        -- =================================================
        -- NATIONAL SETUP PARTICIPATION RULE
        -- =================================================

        if targetNation.setupComplete
            ~= true then


            setReturn({
                success = false,
                message =
                    "That nation has not completed National Setup and is not yet participating in Global Diplomacy."
            });


            return;
        end


        local relationship =
            GetRelationship(
                data,
                playerID,
                targetPlayerID
            );


        if relationship.status
            == "war" then


            setReturn({
                success = false,
                message =
                    "Your nations are already at war."
            });


            return;
        end

-- =================================================
-- ACTIVE ALLIANCE
-- =================================================

local allianceKey =
    PairKey(
        playerID,
        targetPlayerID
    );

local allianceData =
    GetDiplomacyData(
        data
    );

local activeAlliance =
    allianceData.alliances[
        allianceKey
    ];


if activeAlliance ~= nil
    and activeAlliance.active == true then

    setReturn({
        success = false,
        message =
            "You cannot declare war on an allied nation. End the Alliance first."
    });

    return;
end

        -- =================================================
        -- NON-AGGRESSION PACT
        -- =================================================

        local activeNAP =
            GetActiveNAP(
                data,
                playerID,
                targetPlayerID
            );


        if activeNAP ~= nil then


            local currentTurn =
                GetCurrentEconomyTurn(
                    data
                );


            local turnsRemaining =
                (
                    activeNAP.endTurn
                    or currentTurn
                )
                - currentTurn;


            if turnsRemaining < 1 then

                turnsRemaining =
                    1;
            end


            setReturn({

                success =
                    false,

                napActive =
                    true,

                turnsRemaining =
                    turnsRemaining,

                message =
                    "You cannot declare war while a Non-Aggression Pact is active. " ..
                    tostring(
                        turnsRemaining
                    ) ..
                    " turn(s) remain."
            });


            return;
        end


        -- =================================================
        -- PEACE COOLDOWN
        -- =================================================

        local peaceCooldownRemaining =
            GetPeaceCooldownRemaining(
                data,
                playerID,
                targetPlayerID
            );


        if peaceCooldownRemaining > 0 then


            setReturn({

                success =
                    false,

                cooldownRemaining =
                    peaceCooldownRemaining,

                message =
                    "You recently made peace with this nation. War cannot be declared for another " ..
                    tostring(
                        peaceCooldownRemaining
                    ) ..
                    " turn(s)."
            });


            return;
        end


        -- =================================================
        -- EXISTING DECLARATION
        -- =================================================

        if HasPendingWarDeclaration(
            data,
            playerID,
            targetPlayerID
        ) then


            setReturn({
                success = false,
                message =
                    "A war declaration between these nations is already pending."
            });


            return;
        end


        local diplomacy =
            GetDiplomacyData(
                data
            );


        local currentTurn =
            GetCurrentEconomyTurn(
                data
            );


        local declarationDelay =
            MakeInteger(
                GetSetting(
                    "WarDeclarationDelay",
                    DEFAULT_WAR_DECLARATION_DELAY
                )
            )
            or DEFAULT_WAR_DECLARATION_DELAY;


        if declarationDelay < 0 then

            declarationDelay =
                0;
        end


        if declarationDelay > 3 then

            declarationDelay =
                3;
        end


        diplomacy.warConflicts = diplomacy.warConflicts or {};
        diplomacy.nextWarConflictID = diplomacy.nextWarConflictID or 1;
        local conflictID = diplomacy.nextWarConflictID;
        diplomacy.nextWarConflictID = conflictID + 1;
        diplomacy.warConflicts[conflictID] = {
            id = conflictID,
            cause = warReason,
            startTurn = currentTurn,
            active = declarationDelay == 0,
            sideA = {[playerID] = true},
            sideB = {[targetPlayerID] = true}
        };

        local declarerName =
            GetPlayerName(
                game,
                playerID
            );


        local targetName =
            GetPlayerName(
                game,
                targetPlayerID
            );


        -- =================================================
        -- IMMEDIATE WAR
        -- =================================================

        if declarationDelay == 0 then


            local declarationMessage =
                declarerName ..
                " declared war on " ..
                targetName ..
                ". Cause: " ..
                warReason ..
                ".";


            AddDiplomacyHistory(
                data,
                "war_declared",
                playerID,
                targetPlayerID,
                declarationMessage,
                {
                    declarationTurn =
                        currentTurn,

                    activatesTurn =
                        currentTurn,

                    delay =
                        0
                }
            );


            AddWorldEvent(
                data.globalEconomy,
                "war_declared",
                playerID,
                declarationMessage,
                {
                    otherPlayerID =
                        targetPlayerID
                }
            );


            relationship.warReason = warReason;
            relationship.warConflictID = conflictID;

            EnterWar(
                data,
                game,
                playerID,
                targetPlayerID,
                "declaration"
            );


            CompactPublicGameDataForSave(data);
            Mod.PublicGameData =
                data;


            setReturn({

                success =
                    true,

                warActive =
                    true,

                delay =
                    0,

                message =
                    "War has been declared on " ..
                    targetName ..
                    ". Your nations are now officially at war."
            });


            return;
        end


        -- =================================================
        -- DELAYED WAR DECLARATION
        -- =================================================

        local key =
            PairKey(
                playerID,
                targetPlayerID
            );


        local activatesTurn =
            currentTurn
            + declarationDelay;


        diplomacy.pendingWarDeclarations[
            key
        ] =
        {

            fromPlayerID =
                playerID,

            toPlayerID =
                targetPlayerID,

            declaredTurn =
                currentTurn,

            activatesTurn =
                activatesTurn,

            delay =
                declarationDelay,

            active =
                true,

            warReason =
                warReason,

            conflictID =
                conflictID
        };


        relationship.pendingWarDeclaration =
            true;


        relationship.pendingWarFrom =
            playerID;


        relationship.pendingWarTo =
            targetPlayerID;


        relationship.warActivatesTurn =
            activatesTurn;

        relationship.warReason =
            warReason;

        relationship.warConflictID =
            conflictID;


        local declarationMessage =
            declarerName ..
            " declared war on " ..
            targetName ..
            ". Cause: " ..
            warReason ..
            ". Hostilities will officially begin in " ..
            tostring(
                declarationDelay
            ) ..
            " turn(s).";


        AddDiplomacyHistory(
            data,
            "war_declared",
            playerID,
            targetPlayerID,
            declarationMessage,
            {
                declarationTurn =
                    currentTurn,

                activatesTurn =
                    activatesTurn,

                delay =
                    declarationDelay
            }
        );


        AddWorldEvent(
            data.globalEconomy,
            "war_declared",
            playerID,
            declarationMessage,
            {
                otherPlayerID =
                    targetPlayerID,

                activatesTurn =
                    activatesTurn
            }
        );


        CompactPublicGameDataForSave(data);
        Mod.PublicGameData =
            data;


        setReturn({

            success =
                true,

            warActive =
                false,

            declarationPending =
                true,

            delay =
                declarationDelay,

            activatesTurn =
                activatesTurn,

            message =
                "War declaration submitted against " ..
                targetName ..
                ". Official hostilities begin in " ..
                tostring(
                    declarationDelay
                ) ..
                " turn(s)."
        });


        return;
    end 
    -- =====================================================
    -- JOIN EXISTING WAR / ALLIANCE / FACTION COALITION
    -- =====================================================

    if payload.type == "joinWar" then
        local conflictID = MakeInteger(payload.conflictID);
        local side = tostring(payload.side or "");
        local diplomacy = GetDiplomacyData(data);
        diplomacy.warConflicts = diplomacy.warConflicts or {};
        diplomacy.warStats = diplomacy.warStats or {};

        local conflict = conflictID and diplomacy.warConflicts[conflictID] or nil;
        if conflict == nil or conflict.active == false or (side ~= "A" and side ~= "B") then
            setReturn({success=false, message="That war is no longer available to join."});
            return;
        end

        conflict.sideA = conflict.sideA or {};
        conflict.sideB = conflict.sideB or {};
        if conflict.sideA[playerID] == true or conflict.sideB[playerID] == true then
            setReturn({success=false, message="Your nation is already participating in this war."});
            return;
        end

        local ourSide = side == "A" and conflict.sideA or conflict.sideB;
        local enemySide = side == "A" and conflict.sideB or conflict.sideA;

        local function IsFactionMate(otherPlayerID)
            local ownFactionID = (diplomacy.playerFaction or {})[playerID];
            if ownFactionID == nil then return false; end
            local faction = (diplomacy.factions or {})[ownFactionID];
            return faction ~= nil and (faction.members or {})[otherPlayerID] == true;
        end

        local function IsActiveAlly(otherPlayerID)
            local alliance = (diplomacy.alliances or {})[PairKey(playerID, otherPlayerID)];
            return alliance ~= nil and alliance.active == true;
        end

        -- Human players may directly join either side of an active conflict.
        -- Alliance/faction ties remain strategically relevant, but are not a
        -- hard requirement for the manual Join War action. Contradictory
        -- diplomatic commitments are still blocked below.

        -- Do not silently turn an existing ally into an enemy.  The player
        -- must resolve contradictory diplomatic commitments first.
        for enemyID, participating in pairs(enemySide) do
            if participating == true and IsActiveAlly(enemyID) then
                setReturn({
                    success=false,
                    message="You are allied with " .. GetPlayerName(game, enemyID) .. ". End that Alliance before joining the opposing side."
                });
                return;
            end
        end

        for friendlyID, participating in pairs(ourSide) do
            if participating == true then
                local friendlyRelationship = GetRelationship(data, playerID, friendlyID);
                if friendlyRelationship ~= nil and friendlyRelationship.status == "war" then
                    setReturn({
                        success=false,
                        message="You are currently at war with " .. GetPlayerName(game, friendlyID) .. ". Make peace before joining that side."
                    });
                    return;
                end
            end
        end

        ourSide[playerID] = true;
        local currentTurn = GetCurrentEconomyTurn(data);
        local joinedAgainst = 0;

        for enemyID, participating in pairs(enemySide) do
            if participating == true and PlayerAvailable(game, enemyID) then
                local rel = GetRelationship(data, playerID, enemyID);

                if rel.status ~= "war" then
                    EnterWar(data, game, playerID, enemyID, "join_war");
                end

                rel = GetRelationship(data, playerID, enemyID);
                rel.warReason = "Support an Ally";
                rel.warConflictID = conflictID;

                local warKey = PairKey(playerID, enemyID);
                local stats = diplomacy.warStats[warKey];
                if stats == nil then
                    stats = {
                        key=warKey,
                        player1=playerID,
                        player2=enemyID,
                        startTurn=currentTurn,
                        active=true,
                        reason="Support an Ally",
                        conflictID=conflictID,
                        attacks=0,
                        casualties={[tostring(playerID)]=0,[tostring(enemyID)]=0},
                        territoriesCaptured={[tostring(playerID)]=0,[tostring(enemyID)]=0},
                        economicImpact={[tostring(playerID)]=0,[tostring(enemyID)]=0}
                    };
                    diplomacy.warStats[warKey] = stats;
                else
                    stats.active = true;
                    stats.reason = stats.reason or "Support an Ally";
                    stats.conflictID = conflictID;
                    stats.startTurn = stats.startTurn or currentTurn;
                    stats.casualties = stats.casualties or {};
                    stats.territoriesCaptured = stats.territoriesCaptured or {};
                    stats.economicImpact = stats.economicImpact or {};
                end

                joinedAgainst = joinedAgainst + 1;
            end
        end

        if joinedAgainst < 1 then
            ourSide[playerID] = nil;
            setReturn({success=false, message="There are no active enemy nations available to join against."});
            return;
        end

        local sideNames = {};
        for memberID, participating in pairs(ourSide) do
            if participating == true then
                table.insert(sideNames, GetPlayerName(game, memberID));
            end
        end
        table.sort(sideNames);

        AddDiplomacyHistory(
            data,
            "war_joined",
            playerID,
            0,
            GetPlayerName(game, playerID) .. " joined Conflict #" .. tostring(conflictID)
                .. " in support of " .. table.concat(sideNames, ", ") .. ".",
            {conflictID=conflictID, side=side, reason="Support an Ally"}
        );

        AddWorldEvent(
            data.globalEconomy,
            "war_joined",
            playerID,
            GetPlayerName(game, playerID) .. " joined Conflict #" .. tostring(conflictID)
                .. " in support of an allied/faction partner.",
            {conflictID=conflictID, side=side}
        );

        CompactPublicGameDataForSave(data);
        Mod.PublicGameData = data;
        setReturn({
            success=true,
            message="Your nation joined Conflict #" .. tostring(conflictID)
                .. " in support of " .. table.concat(sideNames, ", ") .. "."
        });
        return;
    end

    -- =====================================================
    -- WAR BOND PURCHASE
    -- =====================================================

    if payload.type == "buyWarBond" then
        local issuerID = MakeInteger(payload.issuerPlayerID);
        local amount = MakeInteger(payload.amount);
        if issuerID == nil or amount == nil or (amount ~= 100 and amount ~= 250 and amount ~= 500 and amount ~= 1000) then
            setReturn({success=false, message="Invalid War Bond purchase."});
            return;
        end
        local diplomacy = GetDiplomacyData(data);
        local atWar = false;
        for _, rel in pairs(diplomacy.relationships or {}) do
            if rel ~= nil and rel.status == "war" and (rel.player1 == issuerID or rel.player2 == issuerID) then
                atWar = true; break;
            end
        end
        if not atWar then
            setReturn({success=false, message="War Bonds can only be purchased from a nation currently at war."});
            return;
        end
        if GetStoredGold(game, playerID) < amount then
            setReturn({success=false, message="You need " .. tostring(amount) .. " Commerce to buy this War Bond."});
            return;
        end
        if not RemoveGold(game, playerID, amount) then
            setReturn({success=false, message="Unable to deduct the War Bond purchase."});
            return;
        end
        AddGold(game, issuerID, amount);
        local economy = data.globalEconomy or {};
        economy.warBonds = economy.warBonds or {nextHoldingID=1, holdings={}, maturityTurns=5, returnPercent=20};
        local market = economy.warBonds;
        market.holdings = market.holdings or {};
        market.nextHoldingID = market.nextHoldingID or 1;
        local currentTurn = GetCurrentEconomyTurn(data);
        local duration = math.max(1, tonumber(market.maturityTurns) or 5);
        local rate = math.max(0, tonumber(market.returnPercent) or 20);
        table.insert(market.holdings, {
            id=market.nextHoldingID, buyerPlayerID=playerID, issuerPlayerID=issuerID, principal=amount,
            purchasedTurn=currentTurn, maturesTurn=currentTurn+duration, payout=math.floor(amount*(1+rate/100)+0.5), status="active"
        });
        market.nextHoldingID = market.nextHoldingID + 1;
        data.globalEconomy = economy;
        CompactPublicGameDataForSave(data);
        Mod.PublicGameData = data;
        setReturn({success=true, message="War Bond purchased for " .. tostring(amount) .. " Commerce. It matures in " .. tostring(duration) .. " turns for " .. tostring(math.floor(amount*(1+rate/100)+0.5)) .. " Commerce if the issuer can repay."});
        return;
    end

    -- =====================================================
    -- SEND PEACE OFFER
    -- =====================================================

    if payload.type
        == "sendPeaceOffer" then


        local targetPlayerID =
            MakeInteger(
                payload.targetPlayerID
            );


        if targetPlayerID == nil then


            setReturn({
                success = false,
                message =
                    "Invalid nation."
            });


            return;
        end


        if targetPlayerID
            == playerID then


            setReturn({
                success = false,
                message =
                    "You cannot send a peace offer to your own nation."
            });


            return;
        end


        if not PlayerAvailable(
            game,
            targetPlayerID
        ) then


            setReturn({
                success = false,
                message =
                    "That nation is no longer available."
            });


            return;
        end


        local targetNation =
            EnsureNation(
                data,
                game,
                targetPlayerID
            );


        if targetNation.eliminated
            == true then


            setReturn({
                success = false,
                message =
                    "You cannot negotiate peace with an eliminated nation."
            });


            return;
        end


        if targetNation.setupComplete
            ~= true then


            setReturn({
                success = false,
                message =
                    "That nation has not completed National Setup and is not participating in Global Diplomacy."
            });


            return;
        end


        if not IsAtWar(
            data,
            playerID,
            targetPlayerID
        ) then


            setReturn({
                success = false,
                message =
                    "Peace offers can only be sent while your nations are at war."
            });


            return;
        end


        if HasPendingPeaceOffer(
            data,
            playerID,
            targetPlayerID
        ) then


            setReturn({
                success = false,
                message =
                    "A peace offer between these nations is already pending."
            });


            return;
        end


        local diplomacy =
            GetDiplomacyData(
                data
            );


        local currentTurn =
            GetCurrentEconomyTurn(
                data
            );


        local senderName =
            GetPlayerName(
                game,
                playerID
            );


        local targetName =
            GetPlayerName(
                game,
                targetPlayerID
            );


        local offer =
        {

            fromPlayerID =
                playerID,

            toPlayerID =
                targetPlayerID,

            offeredTurn =
                currentTurn,

            active =
                true
        };


        table.insert(
            diplomacy.pendingPeaceOffers,
            offer
        );


        local message =
            senderName ..
            " offered peace to " ..
            targetName ..
            ".";


        AddDiplomacyHistory(
            data,
            "peace_offered",
            playerID,
            targetPlayerID,
            message,
            {
                offeredTurn =
                    currentTurn
            }
        );


        AddWorldEvent(
            data.globalEconomy,
            "peace_offered",
            playerID,
            message,
            {
                otherPlayerID =
                    targetPlayerID
            }
        );


        CompactPublicGameDataForSave(data);
        Mod.PublicGameData =
            data;


        setReturn({

            success =
                true,

            message =
                "Peace offer sent to " ..
                targetName ..
                "."
        });


        return;
    end


    -- =====================================================
    -- ACCEPT PEACE OFFER
    -- =====================================================

    if payload.type
        == "acceptPeaceOffer" then


        local fromPlayerID =
            MakeInteger(
                payload.fromPlayerID
            );


        if fromPlayerID == nil then


            setReturn({
                success = false,
                message =
                    "Invalid peace offer."
            });


            return;
        end


        local diplomacy =
            GetDiplomacyData(
                data
            );


        local offerIndex =
            nil;


        for index, offer
            in ipairs(
                diplomacy.pendingPeaceOffers
            ) do


            if offer.fromPlayerID
                == fromPlayerID

                and offer.toPlayerID
                == playerID then


                offerIndex =
                    index;


                break;
            end
        end


        if offerIndex == nil then


            setReturn({
                success = false,
                message =
                    "This peace offer no longer exists."
            });


            return;
        end


        if not IsAtWar(
            data,
            fromPlayerID,
            playerID
        ) then


            table.remove(
                diplomacy.pendingPeaceOffers,
                offerIndex
            );


            CompactPublicGameDataForSave(data);
            Mod.PublicGameData =
                data;


            setReturn({
                success = false,
                message =
                    "Your nations are no longer at war."
            });


            return;
        end


        local fromName =
            GetPlayerName(
                game,
                fromPlayerID
            );


        local receiverName =
            GetPlayerName(
                game,
                playerID
            );


        EnterPeace(
            data,
            game,
            fromPlayerID,
            playerID
        );


        local acceptedMessage =
            receiverName ..
            " accepted the peace offer from " ..
            fromName ..
            ".";


        AddDiplomacyHistory(
            data,
            "peace_offer_accepted",
            fromPlayerID,
            playerID,
            acceptedMessage,
            nil
        );


        AddWorldEvent(
            data.globalEconomy,
            "peace_offer_accepted",
            playerID,
            acceptedMessage,
            {
                otherPlayerID =
                    fromPlayerID
            }
        );


        CompactPublicGameDataForSave(data);
        Mod.PublicGameData =
            data;


        local cooldown =
            GetSetting(
                "PeaceCooldownTurns",
                DEFAULT_PEACE_COOLDOWN_TURNS
            );


        setReturn({

            success =
                true,

            peaceActive =
                true,

            cooldownTurns =
                cooldown,

            message =
                "Peace established with " ..
                fromName ..
                "."
        });


        return;
    end


    -- =====================================================
    -- REJECT PEACE OFFER
    -- =====================================================

    if payload.type
        == "rejectPeaceOffer" then


        local fromPlayerID =
            MakeInteger(
                payload.fromPlayerID
            );


        if fromPlayerID == nil then


            setReturn({
                success = false,
                message =
                    "Invalid peace offer."
            });


            return;
        end


        local diplomacy =
            GetDiplomacyData(
                data
            );


        local offerIndex =
            nil;


        for index, offer
            in ipairs(
                diplomacy.pendingPeaceOffers
            ) do


            if offer.fromPlayerID
                == fromPlayerID

                and offer.toPlayerID
                == playerID then


                offerIndex =
                    index;


                break;
            end
        end


        if offerIndex == nil then


            setReturn({
                success = false,
                message =
                    "This peace offer no longer exists."
            });


            return;
        end


        table.remove(
            diplomacy.pendingPeaceOffers,
            offerIndex
        );


        local fromName =
            GetPlayerName(
                game,
                fromPlayerID
            );


        local receiverName =
            GetPlayerName(
                game,
                playerID
            );


        local message =
            receiverName ..
            " rejected the peace offer from " ..
            fromName ..
            ".";


        AddDiplomacyHistory(
            data,
            "peace_offer_rejected",
            fromPlayerID,
            playerID,
            message,
            nil
        );


        AddWorldEvent(
            data.globalEconomy,
            "peace_offer_rejected",
            playerID,
            message,
            {
                otherPlayerID =
                    fromPlayerID
            }
        );


        CompactPublicGameDataForSave(data);
        Mod.PublicGameData =
            data;


        setReturn({

            success =
                true,

            message =
                "Peace offer rejected."
        });


        return;
    end
    -- =====================================================
    -- SEND NON-AGGRESSION PACT OFFER
    -- =====================================================

    if payload.type
        == "sendNAPOffer" then


        local targetPlayerID =
            MakeInteger(
                payload.targetPlayerID
            );


        local duration =
            MakeInteger(
                payload.duration
            );


        if targetPlayerID == nil then


            setReturn({
                success = false,
                message =
                    "Invalid nation."
            });


            return;
        end


        if targetPlayerID
            == playerID then


            setReturn({
                success = false,
                message =
                    "You cannot form a Non-Aggression Pact with your own nation."
            });


            return;
        end


        if not PlayerAvailable(
            game,
            targetPlayerID
        ) then


            setReturn({
                success = false,
                message =
                    "That nation is no longer available."
            });


            return;
        end


        local targetNation =
            EnsureNation(
                data,
                game,
                targetPlayerID
            );


        if targetNation.eliminated
            == true then


            setReturn({
                success = false,
                message =
                    "You cannot form a pact with an eliminated nation."
            });


            return;
        end


        if targetNation.setupComplete
            ~= true then


            setReturn({
                success = false,
                message =
                    "That nation has not completed National Setup and is not participating in Global Diplomacy."
            });


            return;
        end


        if IsAtWar(
            data,
            playerID,
            targetPlayerID
        ) then


            setReturn({
                success = false,
                message =
                    "You cannot form a Non-Aggression Pact while your nations are at war. Establish peace first."
            });


            return;
        end


        if GetActiveNAP(
            data,
            playerID,
            targetPlayerID
        ) ~= nil then


            setReturn({
                success = false,
                message =
                    "A Non-Aggression Pact is already active between these nations."
            });


            return;
        end


        if HasPendingNAPOffer(
            data,
            playerID,
            targetPlayerID
        ) then


            setReturn({
                success = false,
                message =
                    "A Non-Aggression Pact offer between these nations is already pending."
            });


            return;
        end


        if duration == nil then


            duration =
                GetSetting(
                    "DefaultNAPDurationTurns",
                    DEFAULT_NAP_DURATION_TURNS
                );
        end


        if duration
            < MIN_NAP_DURATION_TURNS then


            duration =
                MIN_NAP_DURATION_TURNS;
        end


        if duration
            > MAX_NAP_DURATION_TURNS then


            duration =
                MAX_NAP_DURATION_TURNS;
        end


        local diplomacy =
            GetDiplomacyData(
                data
            );


        local currentTurn =
            GetCurrentEconomyTurn(
                data
            );


        local senderName =
            GetPlayerName(
                game,
                playerID
            );


        local targetName =
            GetPlayerName(
                game,
                targetPlayerID
            );


        local offer =
        {

            fromPlayerID =
                playerID,

            toPlayerID =
                targetPlayerID,

            duration =
                duration,

            offeredTurn =
                currentTurn,

            active =
                true
        };


        table.insert(
            diplomacy.pendingNAPOffers,
            offer
        );


        local message =
            senderName ..
            " offered " ..
            targetName ..
            " a " ..
            tostring(
                duration
            ) ..
            "-turn Non-Aggression Pact.";


        AddDiplomacyHistory(
            data,
            "nap_offered",
            playerID,
            targetPlayerID,
            message,
            {
                duration =
                    duration,

                offeredTurn =
                    currentTurn
            }
        );


        AddWorldEvent(
            data.globalEconomy,
            "nap_offered",
            playerID,
            message,
            {
                otherPlayerID =
                    targetPlayerID,

                duration =
                    duration
            }
        );


        CompactPublicGameDataForSave(data);
        Mod.PublicGameData =
            data;


        setReturn({

            success =
                true,

            duration =
                duration,

            message =
                "Non-Aggression Pact offer sent to " ..
                targetName ..
                " for " ..
                tostring(
                    duration
                ) ..
                " turn(s)."
        });


        return;
    end

-- =========================================================
-- PROPOSE ALLIANCE
-- =========================================================

if payload.type == "proposeAlliance" then

    local targetPlayerID =
        MakeInteger(
            payload.targetPlayerID
        );


    if targetPlayerID == nil then

        setReturn({
            success = false,
            message =
                "Invalid nation."
        });

        return;
    end


    if targetPlayerID == playerID then

        setReturn({
            success = false,
            message =
                "You cannot form an Alliance with your own nation."
        });

        return;
    end


    if not PlayerAvailable(
        game,
        targetPlayerID
    ) then

        setReturn({
            success = false,
            message =
                "That nation is not available."
        });

        return;
    end


    local diplomacy =
        GetDiplomacyData(
            data
        );

local pairKey =
    PairKey(
        playerID,
        targetPlayerID
    );


if IsAtWar(
        data,
        playerID,
        targetPlayerID
    ) then

        setReturn({
            success = false,
            message =
                "You cannot propose an Alliance while at war."
        });

        return;
    end


    if diplomacy.alliances[
        pairKey
    ] ~= nil
        and diplomacy.alliances[
            pairKey
        ].active == true then

        setReturn({
            success = false,
            message =
                "These nations are already allied."
        });

        return;
    end


    for _, offer in ipairs(
        diplomacy.pendingAllianceOffers
    ) do

        if (
            offer.fromPlayerID == playerID
            and offer.toPlayerID == targetPlayerID
        )
        or (
            offer.fromPlayerID == targetPlayerID
            and offer.toPlayerID == playerID
        )
        then

            setReturn({
                success = false,
                message =
                    "An Alliance proposal is already pending between these nations."
            });

            return;
        end

    end


table.insert(
    diplomacy.pendingAllianceOffers,
    {
        fromPlayerID =
            playerID,

        toPlayerID =
            targetPlayerID,

        createdTurn =
            GetCurrentEconomyTurn(
                data
            )
    }
);


    local targetName =
        GetPlayerName(
            game,
            targetPlayerID
        );


AddDiplomacyHistory(
    data,
    "alliance_proposed",
    playerID,
    targetPlayerID,
    GetPlayerName(
        game,
        playerID
    ) ..
    " proposed an Alliance with " ..
    targetName ..
    ".",
    {
        offeredTurn =
            GetCurrentEconomyTurn(
                data
            )
    }
);


    CompactPublicGameDataForSave(data);
    Mod.PublicGameData =
        data;


    setReturn({
        success = true,
        message =
            "Alliance proposal sent to " ..
            targetName ..
            "."
    });


    return;
end

-- =========================================================
-- ACCEPT ALLIANCE OFFER
-- =========================================================

if payload.type == "acceptAllianceOffer" then

    local fromPlayerID =
        MakeInteger(
            payload.fromPlayerID
        );


    if fromPlayerID == nil then

        setReturn({
            success = false,
            message =
                "Invalid nation."
        });

        return;
    end


    if fromPlayerID == playerID then

        setReturn({
            success = false,
            message =
                "Invalid Alliance proposal."
        });

        return;
    end


    if not PlayerAvailable(
        game,
        fromPlayerID
    ) then

        setReturn({
            success = false,
            message =
                "That nation is not available."
        });

        return;
    end


    local diplomacy =
        GetDiplomacyData(
            data
        );


    local offerIndex =
        nil;


    for index, offer in ipairs(
        diplomacy.pendingAllianceOffers
    ) do

        if offer.fromPlayerID == fromPlayerID
            and offer.toPlayerID == playerID then

            offerIndex =
                index;

            break;
        end

    end


    if offerIndex == nil then

        setReturn({
            success = false,
            message =
                "No pending Alliance proposal was found."
        });

        return;
    end


    if IsAtWar(
        data,
        playerID,
        fromPlayerID
    ) then

        table.remove(
            diplomacy.pendingAllianceOffers,
            offerIndex
        );


        CompactPublicGameDataForSave(data);
        Mod.PublicGameData =
            data;


        setReturn({
            success = false,
            message =
                "The Alliance proposal expired because the nations are at war."
        });

        return;
    end


local pairKey =
    PairKey(
        playerID,
        fromPlayerID
    );


    if diplomacy.alliances[
        pairKey
    ] ~= nil
        and diplomacy.alliances[
            pairKey
        ].active == true then

        table.remove(
            diplomacy.pendingAllianceOffers,
            offerIndex
        );


        CompactPublicGameDataForSave(data);
        Mod.PublicGameData =
            data;


        setReturn({
            success = false,
            message =
                "These nations are already allied."
        });

        return;
    end


    table.remove(
        diplomacy.pendingAllianceOffers,
        offerIndex
    );


    diplomacy.alliances[
        pairKey
    ] = {

        player1 =
            fromPlayerID,

        player2 =
            playerID,

startTurn =
    GetCurrentEconomyTurn(
        data
    ),

        active =
            true
    };


    local fromName =
        GetPlayerName(
            game,
            fromPlayerID
        );

    local ourName =
        GetPlayerName(
            game,
            playerID
        );


AddDiplomacyHistory(
    data,
    "alliance_formed",
    fromPlayerID,
    playerID,
    fromName ..
    " and " ..
    ourName ..
    " formed an Alliance.",
    {
        startTurn =
            GetCurrentEconomyTurn(
                data
            )
    }
);


    CompactPublicGameDataForSave(data);
    Mod.PublicGameData =
        data;


    setReturn({
        success = true,
        message =
            "Alliance formed with " ..
            fromName ..
            "."
    });


    return;
end

-- =========================================================
-- REJECT ALLIANCE OFFER
-- =========================================================

if payload.type == "rejectAllianceOffer" then

    local fromPlayerID =
        MakeInteger(
            payload.fromPlayerID
        );


    if fromPlayerID == nil then

        setReturn({
            success = false,
            message =
                "Invalid nation."
        });

        return;
    end


    local diplomacy =
        GetDiplomacyData(
            data
        );


    local offerIndex =
        nil;


    for index, offer in ipairs(
        diplomacy.pendingAllianceOffers
    ) do

        if offer.fromPlayerID == fromPlayerID
            and offer.toPlayerID == playerID then

            offerIndex =
                index;

            break;
        end

    end


    if offerIndex == nil then

        setReturn({
            success = false,
            message =
                "No pending Alliance proposal was found."
        });

        return;
    end


    table.remove(
        diplomacy.pendingAllianceOffers,
        offerIndex
    );


AddDiplomacyHistory(
    data,
    "alliance_rejected",
    fromPlayerID,
    playerID,
    GetPlayerName(
        game,
        playerID
    ) ..
    " rejected the Alliance proposal from " ..
    GetPlayerName(
        game,
        fromPlayerID
    ) ..
    ".",
    nil
);


    CompactPublicGameDataForSave(data);
    Mod.PublicGameData =
        data;


    setReturn({
        success = true,
        message =
            "Alliance proposal rejected."
    });


    return;
end

-- =========================================================
-- END ALLIANCE
-- =========================================================

if payload.type == "endAlliance" then

    local otherPlayerID =
        MakeInteger(
            payload.otherPlayerID
        );


    if otherPlayerID == nil
        or otherPlayerID == playerID then

        setReturn({
            success = false,
            message =
                "Invalid allied nation."
        });

        return;
    end


    local diplomacy =
        GetDiplomacyData(
            data
        );


    local pairKey =
        PairKey(
            playerID,
            otherPlayerID
        );


    local alliance =
        diplomacy.alliances[
            pairKey
        ];


    if alliance == nil
        or alliance.active ~= true then

        setReturn({
            success = false,
            message =
                "There is no active Alliance between these nations."
        });

        return;
    end


    diplomacy.alliances[
        pairKey
    ] =
        nil;


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
                offer.fromPlayerID == playerID
                and offer.toPlayerID == otherPlayerID
            )
            or
            (
                offer.fromPlayerID == otherPlayerID
                and offer.toPlayerID == playerID
            )
        then

            table.remove(
                diplomacy.pendingAllianceOffers,
                i
            );

        end

    end


    local ourName =
        GetPlayerName(
            game,
            playerID
        );

    local otherName =
        GetPlayerName(
            game,
            otherPlayerID
        );


    AddDiplomacyHistory(
        data,
        "alliance_ended",
        playerID,
        otherPlayerID,
        ourName ..
        " ended the Alliance with " ..
        otherName ..
        ".",
        {
            endedTurn =
                GetCurrentEconomyTurn(
                    data
                )
        }
    );


    CompactPublicGameDataForSave(data);
    Mod.PublicGameData =
        data;


    setReturn({
        success = true,
        message =
            "Alliance with " ..
            otherName ..
            " has ended."
    });


    return;
end

-- =========================================================
-- CREATE FACTION
-- =========================================================

if payload.type == "createFaction" then

    local factionName =
        TrimString(
            payload.factionName
        );


    if factionName == "" then

        setReturn({
            success = false,
            message =
                "Enter a Faction name."
        });

        return;
    end


    if string.len(factionName) > 30 then

        setReturn({
            success = false,
            message =
                "Faction names may contain up to 30 characters."
        });

        return;
    end


    local diplomacy =
        GetDiplomacyData(
            data
        );


    if diplomacy.playerFaction[
        playerID
    ] ~= nil then

        setReturn({
            success = false,
            message =
                "Your nation already belongs to a Faction."
        });

        return;
    end


    for _, faction in pairs(
        diplomacy.factions
    ) do

        if string.lower(
            tostring(
                faction.name or ""
            )
        ) == string.lower(
            factionName
        ) then

            setReturn({
                success = false,
                message =
                    "A Faction with that name already exists."
            });

            return;
        end

    end


    local factionID =
        diplomacy.nextFactionID;


    diplomacy.nextFactionID =
        factionID + 1;


    diplomacy.factions[
        factionID
    ] = {

        id =
            factionID,

        name =
            factionName,

        leaderPlayerID =
            playerID,

        members =
            {
                [playerID] = true
            },

        createdTurn =
            GetCurrentEconomyTurn(
                data
            )
    };


    diplomacy.playerFaction[
        playerID
    ] =
        factionID;


    AddDiplomacyHistory(
        data,
        "faction_created",
        playerID,
        nil,
        GetPlayerName(
            game,
            playerID
        ) ..
        " created the Faction \"" ..
        factionName ..
        "\".",
        {
            factionID =
                factionID
        }
    );


    CompactPublicGameDataForSave(data);
    Mod.PublicGameData =
        data;


    setReturn({
        success = true,
        factionID = factionID,
        message =
            "Faction \"" ..
            factionName ..
            "\" created."
    });


    return;
end


-- =========================================================
-- INVITE TO FACTION
-- =========================================================

if payload.type == "inviteToFaction" then

    local targetPlayerID =
        MakeInteger(
            payload.targetPlayerID
        );


    if targetPlayerID == nil
        or targetPlayerID == playerID then

        setReturn({
            success = false,
            message =
                "Invalid nation."
        });

        return;
    end


    if not PlayerAvailable(
        game,
        targetPlayerID
    ) then

        setReturn({
            success = false,
            message =
                "That nation is not available."
        });

        return;
    end


    local diplomacy =
        GetDiplomacyData(
            data
        );


    local factionID =
        diplomacy.playerFaction[
            playerID
        ];


    local faction =
        diplomacy.factions[
            factionID
        ];


    if faction == nil
        or faction.leaderPlayerID
        ~= playerID then

        setReturn({
            success = false,
            message =
                "Only a Faction leader may invite nations."
        });

        return;
    end


    if diplomacy.playerFaction[
        targetPlayerID
    ] ~= nil then

        setReturn({
            success = false,
            message =
                "That nation already belongs to a Faction."
        });

        return;
    end


    if IsAtWar(
        data,
        playerID,
        targetPlayerID
    ) then

        setReturn({
            success = false,
            message =
                "You cannot invite a nation you are currently at war with."
        });

        return;
    end


    for _, invite in ipairs(
        diplomacy.pendingFactionInvites
    ) do

        if invite.factionID == factionID
            and invite.toPlayerID
            == targetPlayerID then

            setReturn({
                success = false,
                message =
                    "That nation already has a pending invitation to this Faction."
            });

            return;
        end

    end


    table.insert(
        diplomacy.pendingFactionInvites,
        {

            factionID =
                factionID,

            fromPlayerID =
                playerID,

            toPlayerID =
                targetPlayerID,

            createdTurn =
                GetCurrentEconomyTurn(
                    data
                )
        }
    );


    AddDiplomacyHistory(
        data,
        "faction_invite_sent",
        playerID,
        targetPlayerID,
        GetPlayerName(
            game,
            playerID
        ) ..
        " invited " ..
        GetPlayerName(
            game,
            targetPlayerID
        ) ..
        " to join \"" ..
        tostring(
            faction.name
        ) ..
        "\".",
        {
            factionID =
                factionID
        }
    );


    CompactPublicGameDataForSave(data);
    Mod.PublicGameData =
        data;


    setReturn({
        success = true,
        message =
            "Faction invitation sent."
    });


    return;
end


-- =========================================================
-- ACCEPT FACTION INVITE
-- =========================================================

if payload.type == "acceptFactionInvite" then

    local factionID =
        MakeInteger(
            payload.factionID
        );


    local diplomacy =
        GetDiplomacyData(
            data
        );


    if diplomacy.playerFaction[
        playerID
    ] ~= nil then

        setReturn({
            success = false,
            message =
                "Your nation already belongs to a Faction."
        });

        return;
    end


    local inviteIndex =
        nil;


    for index, invite in ipairs(
        diplomacy.pendingFactionInvites
    ) do

        if invite.factionID == factionID
            and invite.toPlayerID
            == playerID then

            inviteIndex =
                index;

            break;
        end

    end


    if inviteIndex == nil then

        setReturn({
            success = false,
            message =
                "No pending Faction invitation was found."
        });

        return;
    end


    local faction =
        diplomacy.factions[
            factionID
        ];


    if faction == nil then

        table.remove(
            diplomacy.pendingFactionInvites,
            inviteIndex
        );


        setReturn({
            success = false,
            message =
                "That Faction no longer exists."
        });

        return;
    end


    table.remove(
        diplomacy.pendingFactionInvites,
        inviteIndex
    );


    faction.members =
        faction.members or {};


    faction.members[
        playerID
    ] =
        true;


    diplomacy.playerFaction[
        playerID
    ] =
        factionID;


    AddDiplomacyHistory(
        data,
        "faction_joined",
        playerID,
        faction.leaderPlayerID,
        GetPlayerName(
            game,
            playerID
        ) ..
        " joined the Faction \"" ..
        tostring(
            faction.name
        ) ..
        "\".",
        {
            factionID =
                factionID
        }
    );


    CompactPublicGameDataForSave(data);
    Mod.PublicGameData =
        data;


    setReturn({
        success = true,
        message =
            "You joined \"" ..
            tostring(
                faction.name
            ) ..
            "\"."
    });


    return;
end


-- =========================================================
-- REJECT FACTION INVITE
-- =========================================================

if payload.type == "rejectFactionInvite" then

    local factionID =
        MakeInteger(
            payload.factionID
        );


    local diplomacy =
        GetDiplomacyData(
            data
        );


    for index =
        #diplomacy.pendingFactionInvites,
        1,
        -1 do

        local invite =
            diplomacy.pendingFactionInvites[
                index
            ];


        if invite.factionID == factionID
            and invite.toPlayerID
            == playerID then

            local faction =
                diplomacy.factions[
                    factionID
                ];


            table.remove(
                diplomacy.pendingFactionInvites,
                index
            );


            AddDiplomacyHistory(
                data,
                "faction_invite_rejected",
                playerID,
                invite.fromPlayerID,
                GetPlayerName(
                    game,
                    playerID
                ) ..
                " rejected an invitation to join \"" ..
                tostring(
                    faction ~= nil
                    and faction.name
                    or "Faction"
                ) ..
                "\".",
                {
                    factionID =
                        factionID
                }
            );


            CompactPublicGameDataForSave(data);
            Mod.PublicGameData =
                data;


            setReturn({
                success = true,
                message =
                    "Faction invitation rejected."
            });


            return;

        end

    end


    setReturn({
        success = false,
        message =
            "No pending Faction invitation was found."
    });


    return;
end


-- =========================================================
-- LEAVE FACTION
-- =========================================================

if payload.type == "leaveFaction" then

    local diplomacy =
        GetDiplomacyData(
            data
        );


    local factionID =
        diplomacy.playerFaction[
            playerID
        ];


    local faction =
        diplomacy.factions[
            factionID
        ];


    if faction == nil then

        setReturn({
            success = false,
            message =
                "Your nation does not belong to a Faction."
        });

        return;
    end


    if faction.leaderPlayerID
        == playerID then

        setReturn({
            success = false,
            message =
                "The Faction leader cannot leave while other members remain. Remove the members first."
        });

        return;
    end


    faction.members[
        playerID
    ] =
        nil;


    diplomacy.playerFaction[
        playerID
    ] =
        nil;


    AddDiplomacyHistory(
        data,
        "faction_left",
        playerID,
        faction.leaderPlayerID,
        GetPlayerName(
            game,
            playerID
        ) ..
        " left the Faction \"" ..
        tostring(
            faction.name
        ) ..
        "\".",
        {
            factionID =
                factionID
        }
    );


    CompactPublicGameDataForSave(data);
    Mod.PublicGameData =
        data;


    setReturn({
        success = true,
        message =
            "You left \"" ..
            tostring(
                faction.name
            ) ..
            "\"."
    });


    return;
end

-- =========================================================
-- DISBAND FACTION
-- =========================================================

if payload.type == "disbandFaction" then

    local diplomacy =
        GetDiplomacyData(
            data
        );


    local factionID =
        diplomacy.playerFaction[
            playerID
        ];


    local faction =
        diplomacy.factions[
            factionID
        ];


    if faction == nil then

        setReturn({
            success = false,
            message =
                "Your nation does not belong to a Faction."
        });

        return;
    end


    if faction.leaderPlayerID
        ~= playerID then

        setReturn({
            success = false,
            message =
                "Only the Faction leader may disband the Faction."
        });

        return;
    end


    local factionName =
        tostring(
            faction.name
            or "Faction"
        );


    for memberID, isMember in pairs(
        faction.members
        or {}
    ) do

        if isMember == true then

            diplomacy.playerFaction[
                memberID
            ] =
                nil;

        end

    end


    for i =
        #diplomacy.pendingFactionInvites,
        1,
        -1 do

        local invite =
            diplomacy.pendingFactionInvites[
                i
            ];


        if invite.factionID
            == factionID then

            table.remove(
                diplomacy.pendingFactionInvites,
                i
            );

        end

    end


    diplomacy.factions[
        factionID
    ] =
        nil;


    AddDiplomacyHistory(
        data,
        "faction_disbanded",
        playerID,
        nil,
        GetPlayerName(
            game,
            playerID
        ) ..
        " disbanded the Faction \"" ..
        factionName ..
        "\".",
        {
            factionID =
                factionID
        }
    );


    CompactPublicGameDataForSave(data);
    Mod.PublicGameData =
        data;


    setReturn({
        success = true,
        message =
            "Faction \"" ..
            factionName ..
            "\" has been disbanded."
    });


    return;
end

-- =========================================================
-- REMOVE FACTION MEMBER
-- =========================================================

if payload.type == "removeFactionMember" then

    local targetPlayerID =
        MakeInteger(
            payload.targetPlayerID
        );


    local diplomacy =
        GetDiplomacyData(
            data
        );


    local factionID =
        diplomacy.playerFaction[
            playerID
        ];


    local faction =
        diplomacy.factions[
            factionID
        ];


    if faction == nil
        or faction.leaderPlayerID
        ~= playerID then

        setReturn({
            success = false,
            message =
                "Only the Faction leader may remove members."
        });

        return;
    end


    if targetPlayerID == nil
        or targetPlayerID == playerID
        or faction.members[
            targetPlayerID
        ] ~= true then

        setReturn({
            success = false,
            message =
                "That nation is not a removable Faction member."
        });

        return;
    end


    faction.members[
        targetPlayerID
    ] =
        nil;


    diplomacy.playerFaction[
        targetPlayerID
    ] =
        nil;


    AddDiplomacyHistory(
        data,
        "faction_member_removed",
        playerID,
        targetPlayerID,
        GetPlayerName(
            game,
            playerID
        ) ..
        " removed " ..
        GetPlayerName(
            game,
            targetPlayerID
        ) ..
        " from the Faction \"" ..
        tostring(
            faction.name
        ) ..
        "\".",
        {
            factionID =
                factionID
        }
    );


    CompactPublicGameDataForSave(data);
    Mod.PublicGameData =
        data;


    setReturn({
        success = true,
        message =
            "Faction member removed."
    });


    return;
end

    -- =====================================================
    -- ACCEPT NON-AGGRESSION PACT OFFER
    -- =====================================================

    if payload.type
        == "acceptNAPOffer" then


        local fromPlayerID =
            MakeInteger(
                payload.fromPlayerID
            );


        if fromPlayerID == nil then


            setReturn({
                success = false,
                message =
                    "Invalid Non-Aggression Pact offer."
            });


            return;
        end


        local diplomacy =
            GetDiplomacyData(
                data
            );


        local offerIndex =
            nil;


        local selectedOffer =
            nil;


        for index, offer
            in ipairs(
                diplomacy.pendingNAPOffers
            ) do


            if offer.fromPlayerID
                == fromPlayerID

                and offer.toPlayerID
                == playerID then


                offerIndex =
                    index;


                selectedOffer =
                    offer;


                break;
            end
        end


        if offerIndex == nil
            or selectedOffer == nil then


            setReturn({
                success = false,
                message =
                    "This Non-Aggression Pact offer no longer exists."
            });


            return;
        end


        if IsAtWar(
            data,
            fromPlayerID,
            playerID
        ) then


            table.remove(
                diplomacy.pendingNAPOffers,
                offerIndex
            );


            CompactPublicGameDataForSave(data);
            Mod.PublicGameData =
                data;


            setReturn({
                success = false,
                message =
                    "This pact can no longer be accepted because your nations are at war."
            });


            return;
        end


        local duration =
            MakeInteger(
                selectedOffer.duration
            )
            or DEFAULT_NAP_DURATION_TURNS;


        if duration
            < MIN_NAP_DURATION_TURNS then


            duration =
                MIN_NAP_DURATION_TURNS;
        end


        if duration
            > MAX_NAP_DURATION_TURNS then


            duration =
                MAX_NAP_DURATION_TURNS;
        end


        local currentTurn =
            GetCurrentEconomyTurn(
                data
            );


        local startTurn =
            currentTurn;


        local endTurn =
            currentTurn
            + duration;


        local key =
            PairKey(
                fromPlayerID,
                playerID
            );


        diplomacy.nonAggressionPacts[
            key
        ] =
        {

            player1 =
                fromPlayerID,

            player2 =
                playerID,

            startTurn =
                startTurn,

            endTurn =
                endTurn,

            duration =
                duration,

            active =
                true
        };


        table.remove(
            diplomacy.pendingNAPOffers,
            offerIndex
        );


        local fromName =
            GetPlayerName(
                game,
                fromPlayerID
            );


        local receiverName =
            GetPlayerName(
                game,
                playerID
            );


        local message =
            fromName ..
            " and " ..
            receiverName ..
            " entered a " ..
            tostring(
                duration
            ) ..
            "-turn Non-Aggression Pact.";


        AddDiplomacyHistory(
            data,
            "nap_started",
            fromPlayerID,
            playerID,
            message,
            {
                startTurn =
                    startTurn,

                endTurn =
                    endTurn,

                duration =
                    duration
            }
        );


        AddWorldEvent(
            data.globalEconomy,
            "nap_started",
            playerID,
            message,
            {
                otherPlayerID =
                    fromPlayerID,

                endTurn =
                    endTurn,

                duration =
                    duration
            }
        );


        CompactPublicGameDataForSave(data);
        Mod.PublicGameData =
            data;


        setReturn({

            success =
                true,

            napActive =
                true,

            duration =
                duration,

            endTurn =
                endTurn,

            message =
                "Non-Aggression Pact established with " ..
                fromName ..
                " for " ..
                tostring(
                    duration
                ) ..
                " turn(s)."
        });


        return;
    end


    -- =====================================================
    -- REJECT NON-AGGRESSION PACT OFFER
    -- =====================================================

    if payload.type
        == "rejectNAPOffer" then


        local fromPlayerID =
            MakeInteger(
                payload.fromPlayerID
            );


        if fromPlayerID == nil then


            setReturn({
                success = false,
                message =
                    "Invalid Non-Aggression Pact offer."
            });


            return;
        end


        local diplomacy =
            GetDiplomacyData(
                data
            );


        local offerIndex =
            nil;


        for index, offer
            in ipairs(
                diplomacy.pendingNAPOffers
            ) do


            if offer.fromPlayerID
                == fromPlayerID

                and offer.toPlayerID
                == playerID then


                offerIndex =
                    index;


                break;
            end
        end


        if offerIndex == nil then


            setReturn({
                success = false,
                message =
                    "This Non-Aggression Pact offer no longer exists."
            });


            return;
        end


        table.remove(
            diplomacy.pendingNAPOffers,
            offerIndex
        );


        local fromName =
            GetPlayerName(
                game,
                fromPlayerID
            );


        local receiverName =
            GetPlayerName(
                game,
                playerID
            );


        local message =
            receiverName ..
            " rejected the Non-Aggression Pact offer from " ..
            fromName ..
            ".";


        AddDiplomacyHistory(
            data,
            "nap_rejected",
            fromPlayerID,
            playerID,
            message,
            nil
        );


        AddWorldEvent(
            data.globalEconomy,
            "nap_rejected",
            playerID,
            message,
            {
                otherPlayerID =
                    fromPlayerID
            }
        );


        CompactPublicGameDataForSave(data);
        Mod.PublicGameData =
            data;


        setReturn({

            success =
                true,

            message =
                "Non-Aggression Pact offer rejected."
        });


        return;
    end   
    -- =====================================================
    -- PUBLISH INVESTMENT PROJECT
    -- =====================================================

    if payload.type
        == "publishInvestmentProject" then


        local projectType =
            INVESTMENT_TYPES[
                payload.projectTypeID
            ];


        if projectType == nil then


            setReturn({
                success = false,
                message =
                    "Invalid investment project type."
            });


            return;
        end


        local fundingGoal =
            MakeInteger(
                payload.fundingGoal
            );


        local creatorContribution =
            MakeInteger(
                payload.creatorContribution
            );


        local investorLimit =
            MakeInteger(
                payload.investorLimit
            );


        if fundingGoal == nil
            or creatorContribution == nil
            or investorLimit == nil then


            setReturn({
                success = false,
                message =
                    "Invalid project settings."
            });


            return;
        end


        if fundingGoal < 200 then


            setReturn({
                success = false,
                message =
                    "Funding goal must be at least 200 gold."
            });


            return;
        end


        if fundingGoal
            > projectType.maxGoal then


            setReturn({
                success = false,
                message =
                    projectType.name ..
                    " may not exceed " ..
                    tostring(
                        projectType.maxGoal
                    ) ..
                    " gold."
            });


            return;
        end


        if investorLimit
            < MIN_INVESTORS
            or investorLimit
            > MAX_INVESTORS then


            setReturn({
                success = false,
                message =
                    "Outside investor limit must be between 2 and 6."
            });


            return;
        end


        local creatorMinimum =
            math.ceil(
                fundingGoal
                * (
                    CREATOR_MIN_PERCENT
                    / 100
                )
            );


        if creatorContribution
            < creatorMinimum then


            setReturn({
                success = false,
                message =
                    "You must contribute at least " ..
                    tostring(
                        creatorMinimum
                    ) ..
                    " gold."
            });


            return;
        end


        if creatorContribution
            > fundingGoal then


            setReturn({
                success = false,
                message =
                    "Your contribution cannot exceed the funding goal."
            });


            return;
        end


        local currentGold =
            GetStoredGold(
                game,
                playerID
            );


        if currentGold
            < creatorContribution then


            setReturn({
                success = false,
                message =
                    "You only have " ..
                    tostring(
                        currentGold
                    ) ..
                    " stored gold."
            });


            return;
        end


        if not RemoveGold(
            game,
            playerID,
            creatorContribution
        ) then


            setReturn({
                success = false,
                message =
                    "Could not deduct your project contribution."
            });


            return;
        end


        local projectID =
            data.nextInvestmentProjectID;


        data.nextInvestmentProjectID =
            projectID + 1;


        local project =
        {

            id =
                projectID,

            projectTypeID =
                payload.projectTypeID,

            projectName =
                projectType.name,

            creatorID =
                playerID,

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
                        playerID,

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
                false
        };


        table.insert(
            data.investmentProjects,
            project
        );


        local creatorName =
            GetPlayerName(
                game,
                playerID
            );


        local message =
            creatorName ..
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
            playerID,
            false
        );


        AddTradeHistory(
            data,
            "investment_created",
            message,
            playerID,
            nil,
            false
        );


        ActivateProject(
            game,
            data,
            project
        );


        CompactPublicGameDataForSave(data);
        Mod.PublicGameData =
            data;


        setReturn({

            success =
                true,

            projectID =
                projectID,

            message =
                projectType.name ..
                " was published successfully."
        });


        return;
    end
    -- =====================================================
    -- INVEST IN PROJECT
    -- =====================================================

    if payload.type
        == "investInProject" then


        local projectID =
            MakeInteger(
                payload.projectID
            );


        local amount =
            MakeInteger(
                payload.amount
            );


        if projectID == nil
            or amount == nil
            or amount <= 0 then


            setReturn({
                success = false,
                message =
                    "Invalid investment."
            });


            return;
        end


        local project =
            FindInvestmentProject(
                data,
                projectID
            );


        if project == nil then


            setReturn({
                success = false,
                message =
                    "This investment project no longer exists."
            });


            return;
        end


        if project.status
            ~= "funding" then


            setReturn({
                success = false,
                message =
                    "This project is no longer accepting investments."
            });


            return;
        end


        if project.creatorID
            == playerID then


            setReturn({
                success = false,
                message =
                    "Creators cannot use an outside investment slot on their own project."
            });


            return;
        end


        local remainingFunding =
            project.fundingGoal
            - project.currentFunding;


        if remainingFunding <= 0 then


            ActivateProject(
                game,
                data,
                project
            );


            CompactPublicGameDataForSave(data);
            Mod.PublicGameData =
                data;


            setReturn({
                success = false,
                message =
                    "This project is already fully funded."
            });


            return;
        end


        local investorCap =
            math.floor(
                project.fundingGoal
                * (
                    OUTSIDE_INVESTOR_MAX_PERCENT
                    / 100
                )
            );


        local existing =
            FindInvestorEntry(
                project,
                playerID
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


        if remainingCap <= 0 then


            setReturn({
                success = false,
                message =
                    "You have reached your maximum investment for this project."
            });


            return;
        end


        if existing == nil then


            local outsideCount =
                CountOutsideInvestors(
                    project
                );


            if outsideCount
                >= project.investorLimit then


                setReturn({
                    success = false,
                    message =
                        "This project has reached its outside investor limit."
                });


                return;
            end
        end


        if amount > remainingCap then


            setReturn({
                success = false,
                message =
                    "You may invest at most " ..
                    tostring(
                        remainingCap
                    ) ..
                    " additional gold."
            });


            return;
        end


        if amount > remainingFunding then


            setReturn({
                success = false,
                message =
                    "Only " ..
                    tostring(
                        remainingFunding
                    ) ..
                    " gold remains before full funding."
            });


            return;
        end


        local currentGold =
            GetStoredGold(
                game,
                playerID
            );


        if currentGold < amount then


            setReturn({
                success = false,
                message =
                    "You only have " ..
                    tostring(
                        currentGold
                    ) ..
                    " stored gold."
            });


            return;
        end

local pendingGold =
    0;

local pendingForProject =
    0;

for _, pendingAction
    in pairs(
        data.pendingInvestmentActions
        or {}
    ) do

    if pendingAction.type == "invest"
        and pendingAction.playerID == playerID then

        pendingGold =
            pendingGold
            + (
                pendingAction.amount
                or 0
            );

        if pendingAction.projectID
            == project.id then

            pendingForProject =
                pendingForProject
                + (
                    pendingAction.amount
                    or 0
                );
        end
    end
end

if pendingGold + amount > currentGold then

    setReturn({
        success = false,
        message =
            "You do not have enough uncommitted gold.\n\n" ..
            "Stored Gold: " ..
            tostring(currentGold) ..
            "\nAlready Pending: " ..
            tostring(pendingGold) ..
            "\nNew Investment: " ..
            tostring(amount)
    });

    return;
end

if pendingForProject + amount > remainingCap then

    setReturn({
        success = false,
        message =
            "This would exceed your investment limit for this project."
    });

    return;
end

if pendingForProject + amount > remainingFunding then

    setReturn({
        success = false,
        message =
            "This would exceed the remaining funding needed for this project."
    });

    return;
end

table.insert(
    data.pendingInvestmentActions,
    {
        type = "invest",
        playerID = playerID,
        projectID = project.id,
        amount = amount,
        createdTurn = data.tradeTurn
    }
);

CompactPublicGameDataForSave(data);
Mod.PublicGameData =
    data;

setReturn({
    success = true,
    pending = true,
    message =
        "Investment of " ..
        tostring(amount) ..
        " gold is pending until turn commit."
});

return;

end

-- =====================================================
-- CANCEL PENDING INVESTMENT
-- =====================================================

if payload.type == "cancelPendingInvestment" then

    local projectID =
        MakeInteger(
            payload.projectID
        );

    if projectID == nil then

        setReturn({
            success = false,
            message = "Invalid pending investment."
        });

        return;
    end

    local cancelledAmount = 0;

    for i =
        #data.pendingInvestmentActions,
        1,
        -1 do

        local action =
            data.pendingInvestmentActions[i];

        if action.type == "invest"
            and action.playerID == playerID
            and action.projectID == projectID then

            cancelledAmount =
                cancelledAmount
                + (
                    action.amount
                    or 0
                );

            table.remove(
                data.pendingInvestmentActions,
                i
            );
        end
    end

    if cancelledAmount <= 0 then

        setReturn({
            success = false,
            message =
                "No pending investment was found."
        });

        return;
    end

    CompactPublicGameDataForSave(data);
    Mod.PublicGameData =
        data;

    setReturn({
        success = true,
        message =
            "Cancelled pending investment of " ..
            tostring(cancelledAmount) ..
            " gold."
    });

    return;
end

-- =====================================================
-- BUY STOCK
-- =====================================================

-- ============================================
-- ISSUE NEW SHARES
-- ============================================

if payload.type == "issueShares" then

    local companyID =
        MakeInteger(
            payload.companyID
        );

    local shares =
        MakeInteger(
            payload.shares
        );

    if companyID == nil
        or shares == nil
        or shares <= 0
    then

        setReturn({
            success = false,
            message = "Invalid share issuance."
        });

        return;
    end

    local economy =
        data.globalEconomy;

    local company =
        economy.market.companies[
            companyID
        ];

    if company == nil
        or company.active ~= true
        or company.delisted == true
    then

        setReturn({
            success = false,
            message = "This company is not available."
        });

        return;
    end

    if company.ownerPlayerID ~= playerID
        and company.founderPlayerID ~= playerID
    then

        setReturn({
            success = false,
            message = "Only the flagship company owner can issue new shares."
        });

        return;
    end

    if shares ~= 10
        and shares ~= 25
        and shares ~= 50
    then

        setReturn({
            success = false,
            message = "Invalid issuance amount."
        });

        return;
    end

    local currentTurn =
        economy.currentEconomyTurn
        or data.tradeTurn
        or 1;

    local lastIssueTurn =
    company.lastShareIssueTurn;

    if lastIssueTurn ~= nil
    and currentTurn - lastIssueTurn < 5
then

        setReturn({
            success = false,
            message = "This company must wait before issuing more shares."
        });

        return;
    end

    company.totalShares =
        (
            company.totalShares
            or 0
        )
        + shares;

    company.publicShares =
        (
            company.publicShares
            or 0
        )
        + shares;

    company.sharesAvailable =
        (
            company.sharesAvailable
            or 0
        )
        + shares;

    company.lastShareIssueTurn =
        currentTurn;

    local currentPrice =
        company.currentPrice
        or company.startingPrice
        or 0;

    company.marketCap =
        company.totalShares
        * currentPrice;

    economy.market.news =
        economy.market.news
        or {};

    table.insert(
        economy.market.news,
        {
            turn = currentTurn,
            type = "share_issuance",
            companyID = company.id,
            message =
                tostring(company.name)
                .. " issued "
                .. tostring(shares)
                .. " new public shares."
        }
    );

    CompactPublicGameDataForSave(data);
    Mod.PublicGameData =
        data;
    
    setReturn({
        success = true,
        message =
            tostring(shares)
            .. " new shares were issued."
    });

    return;
end

if payload.type == "buyStock" then

    local companyID =
        MakeInteger(
            payload.companyID
        );

    local shares =
        MakeInteger(
            payload.shares
        );

    if companyID == nil
        or shares == nil
        or shares <= 0 then

        setReturn({
            success = false,
            message = "Invalid stock purchase."
        });

        return;
    end

    local economy =
        data.globalEconomy;

    local company =
        economy.market.companies[
            companyID
        ];

    if company == nil
        or company.active ~= true
        or company.delisted == true then

        setReturn({
            success = false,
            message = "This company is not available for trading."
        });

        return;
    end

    if company.status == "pre_market" then

        setReturn({
            success = false,
            message = "This company is not yet open for public trading."
        });

        return;
    end

    local availableShares =
        company.sharesAvailable
        or 0;

    if shares > availableShares then

        setReturn({
            success = false,
            message =
                "Only " ..
                tostring(availableShares) ..
                " share(s) are currently available."
        });

        return;
    end

    local sharePrice =
        company.currentPrice
        or company.startingPrice
        or 1;

    local totalCost =
        shares
        * sharePrice;

    local currentGold =
        GetStoredGold(
            game,
            playerID
        );

    if currentGold < totalCost then

        setReturn({
            success = false,
            message =
                "You need " ..
                tostring(totalCost) ..
                " gold to buy these shares."
        });

        return;
    end

    if not RemoveGold(
        game,
        playerID,
        totalCost
    ) then

        setReturn({
            success = false,
            message = "Could not complete the stock purchase."
        });

        return;
    end

    local nation =
        EnsureNation(
            data,
            game,
            playerID
        );

    nation.stockHoldings =
        nation.stockHoldings
        or {};

    nation.stockCostBasis =
        nation.stockCostBasis
        or {};

    local oldShares =
        nation.stockHoldings[
            companyID
        ]
        or 0;

    local oldCostBasis =
        nation.stockCostBasis[
            companyID
        ]
        or 0;

    nation.stockHoldings[
        companyID
    ] =
        oldShares
        + shares;

    nation.stockCostBasis[
        companyID
    ] =
        oldCostBasis
        + totalCost;

local primarySharesRemaining =
    company.primarySharesRemaining
    or 0;

local primarySharesSold =
    math.min(
        shares,
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
            * sharePrice
            * founderProceedsPercent
            / 100
        )
        + 0.5
    );

    if founderPlayerID ~= nil
        and founderPlayerID ~= playerID then

AddGold(
    game,
    founderPlayerID,
    founderProceeds
);

    end

end

company.sharesAvailable =
    math.max(
        0,
        availableShares
        - shares
    );
    
    company.buyVolumeThisTurn =
    (
        company.buyVolumeThisTurn
        or 0
    )
    + shares;

nation.stockLastBuyTurn =
    nation.stockLastBuyTurn
    or {};

nation.stockLastBuyTurn[
    companyID
] =
    economy.currentEconomyTurn
    or data.tradeTurn
    or 1;

    table.insert(
        economy.market.transactions,
        {
            turn =
                economy.currentEconomyTurn
                or data.tradeTurn
                or 1,

            type =
                "buy",

            playerID =
                playerID,

            companyID =
                companyID,

            shares =
                shares,

            price =
                sharePrice,

            total =
                totalCost
        }
    );

    CompactPublicGameDataForSave(data);
    Mod.PublicGameData =
        data;

    setReturn({
        success = true,
        message =
            "Purchased " ..
            tostring(shares) ..
            " share(s) of " ..
            tostring(company.name) ..
            " for " ..
            tostring(totalCost) ..
            " gold."
    });

    return;
end

-- =====================================================
-- BUY ETF
-- =====================================================

if payload.type == "buyETF" then

    local shares =
        MakeInteger(
            payload.shares
        );

    if shares == nil
        or shares <= 0 then

        setReturn({
            success = false,
            message = "Invalid ETF purchase."
        });

        return;
    end

    local economy =
        data.globalEconomy;

    if economy == nil
        or economy.market == nil
        or economy.market.etf == nil then

        setReturn({
            success = false,
            message = "ETF market is not available."
        });

        return;
    end

    local etf =
        economy.market.etf;

    if etf.active ~= true then

        setReturn({
            success = false,
            message = "The ETF is not currently active."
        });

        return;
    end

    local availableShares =
        etf.sharesAvailable
        or 0;

    if shares > availableShares then

        setReturn({
            success = false,
            message =
                "Only " ..
                tostring(availableShares) ..
                " ETF share(s) are available."
        });

        return;
    end

    local sharePrice =
        etf.currentPrice
        or etf.startingPrice
        or 100;

    local totalCost =
        math.floor(
            shares
            * sharePrice
            + 0.5
        );

    local currentGold =
        GetStoredGold(
            game,
            playerID
        );

    if currentGold < totalCost then

        setReturn({
            success = false,
            message =
                "You need " ..
                tostring(totalCost) ..
                " Commerce to buy these ETF shares."
        });

        return;
    end

    if not RemoveGold(
        game,
        playerID,
        totalCost
    ) then

        setReturn({
            success = false,
            message = "Could not complete the ETF purchase."
        });

        return;
    end

    local nation =
        EnsureNation(
            data,
            game,
            playerID
        );

    nation.etfShares =
        nation.etfShares
        or 0;

    nation.etfCostBasis =
        nation.etfCostBasis
        or 0;

    nation.etfShares =
        nation.etfShares
        + shares;

    nation.etfCostBasis =
        nation.etfCostBasis
        + totalCost;

etf.sharesAvailable =
    math.max(
        0,
        availableShares
        - shares
    );

    economy.market.transactions =
        economy.market.transactions
        or {};

    table.insert(
        economy.market.transactions,
        {
            turn =
                economy.currentEconomyTurn
                or data.tradeTurn
                or 1,

            type =
                "buy_etf",

            playerID =
                playerID,

            shares =
                shares,

            price =
                sharePrice,

            total =
                totalCost
        }
    );

    CompactPublicGameDataForSave(data);
    Mod.PublicGameData =
        data;

    setReturn({
        success = true,
        message =
            "Purchased " ..
            tostring(shares) ..
            " ETF share(s) for " ..
            tostring(totalCost) ..
            " Commerce."
    });

    return;

end


-- =====================================================
-- SELL ETF
-- =====================================================

if payload.type == "sellETF" then

    local shares =
        MakeInteger(
            payload.shares
        );

    if shares == nil
        or shares <= 0 then

        setReturn({
            success = false,
            message = "Invalid ETF sale."
        });

        return;
    end

    local economy =
        data.globalEconomy;

    if economy == nil
        or economy.market == nil
        or economy.market.etf == nil then

        setReturn({
            success = false,
            message = "ETF market is not available."
        });

        return;
    end

    local etf =
        economy.market.etf;

    local nation =
        EnsureNation(
            data,
            game,
            playerID
        );

    nation.etfShares =
        nation.etfShares
        or 0;

    nation.etfCostBasis =
        nation.etfCostBasis
        or 0;

    nation.realizedETFProfit =
        nation.realizedETFProfit
        or 0;

    if shares > nation.etfShares then

        setReturn({
            success = false,
            message =
                "You only own " ..
                tostring(nation.etfShares) ..
                " ETF share(s)."
        });

        return;
    end

    local sharePrice =
        etf.currentPrice
        or etf.startingPrice
        or 100;

    local totalValue =
        math.floor(
            shares
            * sharePrice
            + 0.5
        );

    local oldShares =
        nation.etfShares;

    local oldCostBasis =
        nation.etfCostBasis;

    local costRemoved =
        0;

    if oldShares > 0 then

        costRemoved =
            oldCostBasis
            * (
                shares
                / oldShares
            );

    end

    nation.etfShares =
        oldShares
        - shares;

    nation.etfCostBasis =
        math.max(
            0,
            oldCostBasis
            - costRemoved
        );

    if nation.etfShares <= 0 then

    nation.etfCostBasis =
        0;

end

    nation.realizedETFProfit =
        nation.realizedETFProfit
        + (
            totalValue
            - costRemoved
        );

    etf.sharesAvailable =
        (
            etf.sharesAvailable
            or 0
        )
        + shares;

    AddGold(
        game,
        playerID,
        totalValue
    );

    economy.market.transactions =
        economy.market.transactions
        or {};

    table.insert(
        economy.market.transactions,
        {
            turn =
                economy.currentEconomyTurn
                or data.tradeTurn
                or 1,

            type =
                "sell_etf",

            playerID =
                playerID,

            shares =
                shares,

            price =
                sharePrice,

            total =
                totalValue
        }
    );

    CompactPublicGameDataForSave(data);
    Mod.PublicGameData =
        data;

    setReturn({
        success = true,
        message =
            "Sold " ..
            tostring(shares) ..
            " ETF share(s) for " ..
            tostring(totalValue) ..
            " Commerce."
    });

    return;

end

-- =====================================================
-- SELL STOCK
-- =====================================================

if payload.type == "sellStock" then

    local companyID =
        MakeInteger(
            payload.companyID
        );

    local shares =
        MakeInteger(
            payload.shares
        );

    if companyID == nil
        or shares == nil
        or shares <= 0 then

        setReturn({
            success = false,
            message = "Invalid stock sale."
        });

        return;
    end

    local economy =
        data.globalEconomy;

    local company =
        economy.market.companies[
            companyID
        ];

    if company == nil
        or company.active ~= true
        or company.delisted == true then

        setReturn({
            success = false,
            message = "This company is not available for trading."
        });

        return;
    end

    local nation =
        EnsureNation(
            data,
            game,
            playerID
        );

    nation.stockHoldings =
        nation.stockHoldings
        or {};

    nation.stockCostBasis =
        nation.stockCostBasis
        or {};

    local ownedShares =
        nation.stockHoldings[
            companyID
        ]
        or 0;

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

    if shares > sellableShares then

        setReturn({
            success = false,
            message =
                "You can currently sell only " ..
                tostring(sellableShares) ..
                " share(s). Founder shares are protected."
        });

        return;
    end

    local sharePrice =
        company.currentPrice
        or company.startingPrice
        or 1;

    local totalValue =
        shares
        * sharePrice;

    local oldCostBasis =
        nation.stockCostBasis[
            companyID
        ]
        or 0;

    local costRemoved =
        0;

if sellableShares > 0 then

    costRemoved =
        math.floor(
            (
                oldCostBasis
                * (
                    shares / sellableShares
                )
            )
            + 0.5
        );

end

local currentTurn =
    economy.currentEconomyTurn
    or data.tradeTurn
    or 1;

local lastBuyTurn =
    (
        nation.stockLastBuyTurn
        and nation.stockLastBuyTurn[
            companyID
        ]
    )
    or -999;

if currentTurn
    - lastBuyTurn
    < 2 then

    setReturn({
        success = false,
        message =
            "You must hold newly purchased shares for at least 2 turns before selling."
    });

    return;
end

    nation.stockHoldings[
        companyID
    ] =
        ownedShares
        - shares;

    nation.stockCostBasis[
        companyID
    ] =
        math.max(
            0,
            oldCostBasis
            - costRemoved
        );

    if nation.stockHoldings[
    companyID
] <= protectedFounderShares then

    nation.stockCostBasis[
        companyID
    ] =
        0;

end

    nation.realizedStockProfit =
        (
            nation.realizedStockProfit
            or 0
        )
        + (
            totalValue
            - costRemoved
        );

    company.sharesAvailable =
        (
            company.sharesAvailable
            or 0
        )
        + shares;
    
    company.sellVolumeThisTurn =
    (
        company.sellVolumeThisTurn
        or 0
    )
    + shares;

    AddGold(
        game,
        playerID,
        totalValue
    );

    table.insert(
        economy.market.transactions,
        {
            turn =
                economy.currentEconomyTurn
                or data.tradeTurn
                or 1,

            type =
                "sell",

            playerID =
                playerID,

            companyID =
                companyID,

            shares =
                shares,

            price =
                sharePrice,

            total =
                totalValue
        }
    );

    CompactPublicGameDataForSave(data);
    Mod.PublicGameData =
        data;

    setReturn({
        success = true,
        message =
            "Sold " ..
            tostring(shares) ..
            " share(s) of " ..
            tostring(company.name) ..
            " for " ..
            tostring(totalValue) ..
            " gold."
    });

    return;
end
    -- =====================================================
    -- PROPOSE TRADE
    -- =====================================================

    if payload.type
        == "proposeTrade" then


        local targetPlayerID =
            MakeInteger(
                payload.targetPlayerID
            );


        if targetPlayerID == nil
            or targetPlayerID
            == playerID then


            setReturn({
                success = false,
                message =
                    "Invalid trade partner."
            });


            return;
        end


        if not PlayerAvailable(
            game,
            playerID
        )
        or not PlayerAvailable(
            game,
            targetPlayerID
        ) then


            setReturn({
                success = false,
                message =
                    "This trade partner is not available."
            });


            return;
        end


        local targetNation =
            EnsureNation(
                data,
                game,
                targetPlayerID
            );


        if targetNation.eliminated
            == true then


            setReturn({
                success = false,
                message =
                    "This trade partner is no longer economically active."
            });


            return;
        end


        if targetNation.setupComplete
            ~= true then


            setReturn({
                success = false,
                message =
                    "This nation must complete National Setup before participating in Trade Agreements."
            });


            return;
        end


        -- =================================================
        -- DIPLOMACY TRADE RULE
        -- =================================================

        if IsAtWar(
            data,
            playerID,
            targetPlayerID
        ) then


            setReturn({
                success = false,
                message =
                    "Trade Agreements cannot be established between nations that are at war."
            });


            return;
        end


        local maxAgreements =
            GetMaxAgreements();


        if CountActiveAgreements(
            data,
            playerID
        ) >= maxAgreements then


            setReturn({
                success = false,
                message =
                    "You already have the host's maximum of " ..
                    tostring(
                        maxAgreements
                    ) ..
                    " active trade agreements."
            });


            return;
        end


        if CountActiveAgreements(
            data,
            targetPlayerID
        ) >= maxAgreements then


            setReturn({
                success = false,
                message =
                    "This nation already has the host's maximum of " ..
                    tostring(
                        maxAgreements
                    ) ..
                    " active trade agreements."
            });


            return;
        end


        if HasActiveAgreement(
            data,
            playerID,
            targetPlayerID
        ) then


            setReturn({
                success = false,
                message =
                    "You already have an active trade agreement with this nation."
            });


            return;
        end


        if HasPendingTrade(
            data,
            playerID,
            targetPlayerID
        ) then


            setReturn({
                success = false,
                message =
                    "A trade proposal already exists between these nations."
            });


            return;
        end


        if IsOnCooldown(
            data,
            playerID,
            targetPlayerID
        ) then


            setReturn({
                success = false,
                message =
                    "You must wait for the trade cooldown to expire."
            });


            return;
        end


        local target =
            GetPlayer(
                game,
                targetPlayerID
            );


        local proposerName =
            GetPlayerName(
                game,
                playerID
            );


        local targetName =
            GetPlayerName(
                game,
                targetPlayerID
            );


        -- =================================================
        -- HUMAN -> AI
        -- =================================================

        if target.IsAI then


            if EvaluateAITrade(
                game,
                data,
                targetPlayerID,
                playerID
            ) then


                table.insert(
                    data.activeAgreements,
                    {

                        player1 =
                            playerID,

                        player2 =
                            targetPlayerID,

                        startedTurn =
                            data.tradeTurn
                    }
                );


                AddTradeHistory(
                    data,
                    "agreement_signed",
                    proposerName ..
                    " and " ..
                    targetName ..
                    " signed a trade agreement.",
                    playerID,
                    targetPlayerID,
                    false
                );


                CompactPublicGameDataForSave(data);
                Mod.PublicGameData =
                    data;


                setReturn({

                    success =
                        true,

                    aiDecision =
                        "accepted",

                    message =
                        targetName ..
                        " accepted the trade agreement."
                });


                return;


            else


                StartCooldown(
                    data,
                    playerID,
                    targetPlayerID
                );


                AddTradeHistory(
                    data,
                    "proposal_rejected",
                    targetName ..
                    " rejected a trade proposal from " ..
                    proposerName ..
                    ".",
                    playerID,
                    targetPlayerID,
                    false
                );


                CompactPublicGameDataForSave(data);
                Mod.PublicGameData =
                    data;


                setReturn({

                    success =
                        false,

                    aiDecision =
                        "rejected",

                    message =
                        targetName ..
                        " rejected the trade agreement."
                });


                return;
            end
        end


        -- =================================================
        -- HUMAN -> HUMAN
        -- =================================================

        table.insert(
            data.pendingProposals,
            {

                fromPlayerID =
                    playerID,

                toPlayerID =
                    targetPlayerID,

                createdTurn =
                    data.tradeTurn
            }
        );


        AddTradeHistory(
            data,
            "proposal_sent",
            proposerName ..
            " sent a trade proposal to " ..
            targetName ..
            ".",
            playerID,
            targetPlayerID,
            false
        );


        CompactPublicGameDataForSave(data);
        Mod.PublicGameData =
            data;


        setReturn({

            success =
                true,

            message =
                "Trade proposal sent successfully."
        });


        return;
    end
    -- =====================================================
    -- ACCEPT TRADE
    -- =====================================================

    if payload.type
        == "acceptTrade" then


        local fromPlayerID =
            MakeInteger(
                payload.fromPlayerID
            );


        if fromPlayerID == nil then


            setReturn({
                success = false,
                message =
                    "Invalid trade proposal."
            });


            return;
        end


        local proposalIndex =
            nil;


        for index, proposal
            in ipairs(
                data.pendingProposals
            ) do


            if proposal.fromPlayerID
                == fromPlayerID

                and proposal.toPlayerID
                == playerID then


                proposalIndex =
                    index;


                break;
            end
        end


        if proposalIndex == nil then


            setReturn({
                success = false,
                message =
                    "This trade proposal no longer exists."
            });


            return;
        end


        -- =================================================
        -- DIPLOMACY TRADE RULE
        -- =================================================

        if IsAtWar(
            data,
            fromPlayerID,
            playerID
        ) then


            table.remove(
                data.pendingProposals,
                proposalIndex
            );


            CompactPublicGameDataForSave(data);
            Mod.PublicGameData =
                data;


            setReturn({
                success = false,
                message =
                    "This trade proposal was canceled because your nations are now at war."
            });


            return;
        end


        local proposerNation =
            EnsureNation(
                data,
                game,
                fromPlayerID
            );


        if proposerNation.eliminated
            == true
            or proposerNation.setupComplete
            ~= true then


            table.remove(
                data.pendingProposals,
                proposalIndex
            );


            CompactPublicGameDataForSave(data);
            Mod.PublicGameData =
                data;


            setReturn({
                success = false,
                message =
                    "The proposing nation is no longer eligible for this Trade Agreement."
            });


            return;
        end


        local maxAgreements =
            GetMaxAgreements();


        local receiverCount =
            CountActiveAgreements(
                data,
                playerID
            );


        local proposerCount =
            CountActiveAgreements(
                data,
                fromPlayerID
            );


        if receiverCount
            >= maxAgreements then


            setReturn({
                success = false,
                message =
                    "You already have the maximum of " ..
                    tostring(
                        maxAgreements
                    ) ..
                    " active trade agreements."
            });


            return;
        end


        if proposerCount
            >= maxAgreements then


            setReturn({
                success = false,
                message =
                    "The proposing nation already has the maximum of " ..
                    tostring(
                        maxAgreements
                    ) ..
                    " active trade agreements."
            });


            return;
        end


        if HasActiveAgreement(
            data,
            fromPlayerID,
            playerID
        ) then


            table.remove(
                data.pendingProposals,
                proposalIndex
            );


            CompactPublicGameDataForSave(data);
            Mod.PublicGameData =
                data;


            setReturn({
                success = false,
                message =
                    "This trade agreement is already active."
            });


            return;
        end


        table.remove(
            data.pendingProposals,
            proposalIndex
        );


        table.insert(
            data.activeAgreements,
            {

                player1 =
                    fromPlayerID,

                player2 =
                    playerID,

                startedTurn =
                    data.tradeTurn
            }
        );


        local fromName =
            GetPlayerName(
                game,
                fromPlayerID
            );


        local receiverName =
            GetPlayerName(
                game,
                playerID
            );


        AddTradeHistory(
            data,
            "agreement_signed",
            receiverName ..
            " accepted a trade proposal from " ..
            fromName ..
            ".",
            fromPlayerID,
            playerID,
            false
        );


        CompactPublicGameDataForSave(data);
        Mod.PublicGameData =
            data;


        setReturn({

            success =
                true,

            message =
                "Trade agreement accepted. You now have " ..
                tostring(
                    receiverCount + 1
                ) ..
                " / " ..
                tostring(
                    maxAgreements
                ) ..
                " active agreements."
        });


        return;
    end
    -- =====================================================
    -- REJECT TRADE
    -- =====================================================

    if payload.type
        == "rejectTrade" then


        local fromPlayerID =
            MakeInteger(
                payload.fromPlayerID
            );


        if fromPlayerID == nil then


            setReturn({
                success = false,
                message =
                    "Invalid trade proposal."
            });


            return;
        end


        local proposalIndex =
            nil;


        for index, proposal
            in ipairs(
                data.pendingProposals
            ) do


            if proposal.fromPlayerID
                == fromPlayerID

                and proposal.toPlayerID
                == playerID then


                proposalIndex =
                    index;


                break;
            end
        end


        if proposalIndex == nil then


            setReturn({
                success = false,
                message =
                    "This proposal no longer exists."
            });


            return;
        end


        table.remove(
            data.pendingProposals,
            proposalIndex
        );


        StartCooldown(
            data,
            fromPlayerID,
            playerID
        );


        local fromName =
            GetPlayerName(
                game,
                fromPlayerID
            );


        local receiverName =
            GetPlayerName(
                game,
                playerID
            );


        AddTradeHistory(
            data,
            "proposal_rejected",
            receiverName ..
            " rejected a trade proposal from " ..
            fromName ..
            ".",
            fromPlayerID,
            playerID,
            false
        );


        CompactPublicGameDataForSave(data);
        Mod.PublicGameData =
            data;


        local cooldown =
            GetCooldownTurns();


        if cooldown > 0 then


            setReturn({

                success =
                    true,

                message =
                    "Trade proposal rejected. A " ..
                    tostring(
                        cooldown
                    ) ..
                    "-turn cooldown is now active."
            });


        else


            setReturn({

                success =
                    true,

                message =
                    "Trade proposal rejected."
            });
        end


        return;
    end


    -- =====================================================
    -- PLAYER WAR EVENT ALERT PREFERENCE
    -- =====================================================

    if payload.type == "setWarEventAlerts" then

        local nation =
            EnsureNation(
                data,
                game,
                playerID
            );

        nation.showWarEventAlerts =
            payload.enabled == true;

        CompactPublicGameDataForSave(data);
        Mod.PublicGameData =
            data;

        setReturn({
            success = true,
            message = nation.showWarEventAlerts
                and "War event pop-up alerts enabled."
                or "War event pop-up alerts hidden. Events remain available in Diplomacy."
        });

        return;
    end


    -- =====================================================
    -- INTERACTIVE WAR EVENT CHOICE
    -- =====================================================

    if payload.type == "resolveWarEvent" then

        if GetSetting("WarEventsEnabled", true) ~= true then
            setReturn({success=false, message="Wartime events are disabled by the host."});
            return;
        end

        local nation =
            EnsureNation(
                data,
                game,
                playerID
            );

        local event =
            nation.pendingWarEvent;

        local eventID =
            MakeInteger(
                payload.eventID
            );

        if event == nil
            or eventID == nil
            or event.id ~= eventID
        then
            setReturn({success=false, message="This wartime event is no longer available."});
            return;
        end

        local choice =
            tostring(
                payload.choice
                or ""
            );

        local commerce =
            math.max(
                1,
                GetCommerceIncome(
                    game,
                    playerID
                )
            );

        local consequence = {
            eventID = event.id,
            warKey = event.warKey,
            otherPlayerID = event.otherPlayerID,
            choice = choice,
            readinessDuration = 2,
            goldDelta = 0,
            unrestDelta = 0,
            readinessModifier = 0,
            message = ""
        };

        if choice == "FULL_MOBILIZATION" then

            local cost =
                math.max(
                    25,
                    math.floor(
                        commerce * 0.08 + 0.5
                    )
                );

            consequence.goldDelta = -cost;
            consequence.readinessModifier = 10;
            consequence.unrestDelta = 2;
            consequence.message =
                "Full Mobilization selected: -"
                .. tostring(cost)
                .. " Commerce next turn, +10 Military Readiness for 2 turns, +2 Unrest.";

        elseif choice == "RATION_SUPPLIES" then

            local cost =
                math.max(
                    10,
                    math.floor(
                        commerce * 0.03 + 0.5
                    )
                );

            consequence.goldDelta = -cost;
            consequence.readinessModifier = 5;
            consequence.unrestDelta = 5;
            consequence.message =
                "Ration Supplies selected: -"
                .. tostring(cost)
                .. " Commerce next turn, +5 Military Readiness for 2 turns, +5 Unrest.";

        elseif choice == "PROTECT_ECONOMY" then

            consequence.goldDelta = 0;
            consequence.readinessModifier = -8;
            consequence.unrestDelta = -2;
            consequence.message =
                "Protect Economy selected: no direct Commerce cost, -8 Military Readiness for 2 turns, -2 Unrest.";

        else
            setReturn({success=false, message="Invalid wartime event choice."});
            return;
        end

        nation.pendingWarEvent = nil;
        nation.pendingWarEventConsequence = consequence;

        CompactPublicGameDataForSave(data);
        Mod.PublicGameData =
            data;

        setReturn({
            success = true,
            message = consequence.message
        });

        return;
    end


    -- =====================================================
    -- UNITED NATIONS RESOLUTION PROPOSAL
    -- =====================================================

    if payload.type == "proposeUNResolution" then

        if unData == nil
            or GetSetting("UnitedNationsEnabled", true) ~= true
        then

            setReturn({
                success = false,
                message = "The United Nations is disabled by the host."
            });

            return;
        end

        local currentTurn =
            data.tradeTurn
            or 0;

        local startTurn =
            math.max(
                1,
                MakeInteger(
                    GetSetting(
                        "UnitedNationsStartTurn",
                        2
                    )
                )
                or 2
            );

        if currentTurn < startTurn then

            setReturn({
                success = false,
                message =
                    "The United Nations becomes active on Turn "
                    .. tostring(startTurn)
                    .. "."
            });

            return;
        end

        local resolutionType =
            tostring(
                payload.resolutionType
                or ""
            );

        local targetPlayerID =
            MakeInteger(
                payload.targetPlayerID
            );

        if UN_RESOLUTION_TYPES[resolutionType] ~= true then

            setReturn({
                success = false,
                message = "Invalid UN resolution type."
            });

            return;
        end

        if targetPlayerID == nil
            or targetPlayerID == playerID
            or not PlayerAvailable(
                game,
                targetPlayerID
            )
        then

            setReturn({
                success = false,
                message = "Select a valid target nation."
            });

            return;
        end

        if resolutionType == "ceasefire"
            and not IsAtWar(
                data,
                playerID,
                targetPlayerID
            )
        then

            setReturn({
                success = false,
                message = "A ceasefire resolution can only target a nation you are currently at war with."
            });

            return;
        end

        local maxActive =
            math.max(
                1,
                math.min(
                    10,
                    MakeInteger(
                        GetSetting(
                            "UNMaximumActiveResolutions",
                            3
                        )
                    )
                    or 3
                )
            );

        if #unData.activeResolutions >= maxActive then

            setReturn({
                success = false,
                message = "The UN already has the maximum number of active resolutions."
            });

            return;
        end

        local cooldown =
            math.max(
                0,
                MakeInteger(
                    GetSetting(
                        "UNProposalCooldownTurns",
                        2
                    )
                )
                or 2
            );

        local lastTurn =
            unData.lastProposalTurnByPlayer[
                playerID
            ];

        if lastTurn ~= nil
            and currentTurn
                - lastTurn
                < cooldown
        then

            setReturn({
                success = false,
                message =
                    "Your UN proposal cooldown has "
                    .. tostring(
                        cooldown
                        - (
                            currentTurn
                            - lastTurn
                        )
                    )
                    .. " turn(s) remaining."
            });

            return;
        end

        local duration =
            math.max(
                1,
                math.min(
                    10,
                    MakeInteger(
                        GetSetting(
                            "UNVoteDurationTurns",
                            2
                        )
                    )
                    or 2
                )
            );

        local id =
            unData.nextResolutionID;

        unData.nextResolutionID =
            id + 1;

        local resolution =
            {
                id = id,
                resolutionType = resolutionType,
                proposerPlayerID = playerID,
                targetPlayerID = targetPlayerID,
                createdTurn = currentTurn,
                voteEndsTurn = currentTurn + duration,
                status = "VOTING",
                votes = {}
            };

        table.insert(
            unData.activeResolutions,
            resolution
        );

        unData.lastProposalTurnByPlayer[
            playerID
        ] =
            currentTurn;

        CompactPublicGameDataForSave(data);
        Mod.PublicGameData =
            data;

        setReturn({
            success = true,
            message =
                "UN "
                .. resolutionType
                .. " resolution #"
                .. tostring(id)
                .. " opened for Security Council voting."
        });

        return;
    end


    -- =====================================================
    -- UNITED NATIONS VOTING
    -- =====================================================

    if payload.type == "voteUNResolution" then

        if unData == nil
            or GetSetting("UnitedNationsEnabled", true) ~= true
        then

            setReturn({
                success = false,
                message = "The United Nations is disabled."
            });

            return;
        end

        if not UNIsCouncilMember(
            unData,
            playerID
        )
        then

            setReturn({
                success = false,
                message = "Only current Security Council members may vote."
            });

            return;
        end

        local resolutionID =
            MakeInteger(
                payload.resolutionID
            );

        local vote =
            string.upper(
                tostring(
                    payload.vote
                    or ""
                )
            );

        if vote ~= "YES"
            and vote ~= "NO"
            and vote ~= "ABSTAIN"
        then

            setReturn({
                success = false,
                message = "Vote must be YES, NO, or ABSTAIN."
            });

            return;
        end

        local resolution =
            nil;

        for _, item
            in ipairs(
                unData.activeResolutions
                or {}
            )
        do

            if item.id == resolutionID then

                resolution =
                    item;

                break;
            end
        end

        if resolution == nil then

            setReturn({
                success = false,
                message = "That UN resolution is no longer active."
            });

            return;
        end

        resolution.votes =
            resolution.votes
            or {};

        resolution.votes[
            tostring(
                playerID
            )
        ] =
            vote;

        CompactPublicGameDataForSave(data);
        Mod.PublicGameData =
            data;

        local vetoText =
            vote == "NO"
            and UNContains(
                unData.permanentMembers,
                playerID
            )
            and " This NO vote will act as a permanent-member veto if it remains when voting closes."
            or "";

        setReturn({
            success = true,
            message =
                "Your UN vote was recorded as "
                .. vote
                .. "."
                .. vetoText
        });

        return;
    end


    -- =====================================================
    -- ARMY RECRUITER DEVELOPMENT
    -- =====================================================

    if payload.type == "buildArmyRecruiter" then
        if GetSetting("ArmyRecruitersEnabled", true) ~= true then
            setReturn({success=false, message="Army Recruiters are disabled by the host."}); return;
        end
        local territoryID = MakeInteger(payload.territoryID);
        local standing = game.ServerGame and game.ServerGame.LatestTurnStanding;
        local terr = territoryID and standing and standing.Territories and standing.Territories[territoryID] or nil;
        if terr == nil or terr.OwnerPlayerID ~= playerID then
            setReturn({success=false, message="Select a territory you currently own."}); return;
        end
        data.globalEconomy.armyRecruiters = data.globalEconomy.armyRecruiters or {enabled=true, territories={}, pendingBuilds={}};
        local recruiters = data.globalEconomy.armyRecruiters;
        recruiters.territories = recruiters.territories or {}; recruiters.pendingBuilds = recruiters.pendingBuilds or {};
        local currentLevel = tonumber(recruiters.territories[territoryID]) or 0;
        local maxLevel = math.max(1, math.floor(tonumber(GetSetting("ArmyRecruiterMaxLevel", 3)) or 3));
        if currentLevel >= maxLevel then setReturn({success=false, message="This Army Recruiter is already at maximum level."}); return; end
        local maxPerPlayer = math.max(1, math.floor(tonumber(GetSetting("ArmyRecruiterMaxPerPlayer", 3)) or 3));
        if currentLevel <= 0 then
            local count = 0;
            for tid, level in pairs(recruiters.territories) do
                local st = standing.Territories[tid];
                if (tonumber(level) or 0) > 0 and st ~= nil and st.OwnerPlayerID == playerID then count = count + 1; end
            end
            if count >= maxPerPlayer then setReturn({success=false, message="You already control the maximum of " .. tostring(maxPerPlayer) .. " Army Recruiter territories."}); return; end
        end
        local newLevel = currentLevel + 1;
        local baseCost = math.max(25, math.floor(tonumber(GetSetting("ArmyRecruiterBaseCost", 250)) or 250));
        local cost = baseCost * newLevel;
        if GetStoredGold(game, playerID) < cost then setReturn({success=false, message="You need " .. tostring(cost) .. " Commerce for Army Recruiter level " .. tostring(newLevel) .. "."}); return; end
        RemoveGold(game, playerID, cost);
        table.insert(recruiters.pendingBuilds, {playerID=playerID, territoryID=territoryID, fromLevel=currentLevel, toLevel=newLevel, cost=cost, paid=true, requestedTurn=data.tradeTurn or 0});
        -- Reserve the level immediately to prevent duplicate purchases before the next turn.
        recruiters.territories[territoryID] = newLevel;
        CompactPublicGameDataForSave(data);
        Mod.PublicGameData = data;
        setReturn({success=true, message="Army Recruiter level " .. tostring(newLevel) .. " scheduled. " .. tostring(cost) .. " Commerce was deducted immediately."});
        return;
    end

    -- =====================================================
    -- RESOURCE FACILITY DEVELOPMENT
    -- =====================================================

    if payload.type == "buildResourceFacility" then

        if resourceData == nil
            or resourceData.enabled ~= true
            or GetSetting("ResourcesEnabled", true) ~= true
        then
            setReturn({success=false, message="Strategic Resources are disabled by the host."});
            return;
        end

        local resourceName = tostring(payload.resource or "");
        local territoryID = MakeInteger(payload.territoryID);
        if RESOURCE_TYPES[resourceName] ~= true or territoryID == nil then
            setReturn({success=false, message="Invalid resource facility request."});
            return;
        end
        if IsAdvancedResource(resourceName)
            and GetSetting("AdvancedResourcesEnabled", true) ~= true
        then
            setReturn({success=false, message="Advanced resources are disabled by the host."});
            return;
        end

        local standing = game.ServerGame and game.ServerGame.LatestTurnStanding;
        local terr = standing and standing.Territories and standing.Territories[territoryID];
        if terr == nil or terr.OwnerPlayerID ~= playerID then
            setReturn({success=false, message="You can only develop a resource facility on a territory you currently own."});
            return;
        end

        local nodes = resourceData.territories[territoryID];
        local currentLevel = nodes and nodes[resourceName] or 0;

        for _, pending in ipairs(resourceData.pendingBuilds or {}) do
            if pending.playerID == playerID and pending.territoryID == territoryID and pending.resource == resourceName then
                setReturn({success=false, message="A " .. resourceName .. " facility build/upgrade is already scheduled on this territory."});
                return;
            end
        end

        local maxLevel = math.max(1, math.floor(tonumber(GetSetting("ResourceFacilityMaxLevel", 3)) or 3));
        if currentLevel >= maxLevel then
            setReturn({success=false, message=resourceName .. " facility is already at maximum level."});
            return;
        end

        local newLevel = currentLevel + 1;
        local baseCost = math.max(1, math.floor(tonumber(GetSetting("ResourceFacilityBaseCost", 100)) or 100));
        local cost = currentLevel <= 0
            and (baseCost * 3)
            or (baseCost * newLevel);
        local nation = EnsureNation(data, game, playerID);
        EnsureNationResourceFields(nation);
        local availableGold = GetStoredGold(game, playerID);
        if availableGold < cost then
            setReturn({success=false, message="You need " .. tostring(cost) .. " Commerce to develop this facility to level " .. tostring(newLevel) .. "."});
            return;
        end

        -- Pay at the moment the player confirms construction.
        RemoveGold(game, playerID, cost);
        table.insert(resourceData.pendingBuilds, {
            playerID = playerID,
            territoryID = territoryID,
            resource = resourceName,
            fromLevel = currentLevel,
            toLevel = newLevel,
            cost = cost,
            paid = true,
            requestedTurn = data.tradeTurn or 0
        });

        CompactPublicGameDataForSave(data);
        Mod.PublicGameData = data;
        local actionText = currentLevel <= 0 and "facility construction" or "facility upgrade";
        setReturn({success=true, message=resourceName .. " " .. actionText .. " scheduled for next turn. " .. tostring(cost) .. " Commerce was deducted immediately."});
        return;
    end


    -- =====================================================
    -- RESOURCE TRADE PROPOSAL
    -- =====================================================

    if payload.type == "proposeResourceTrade" then

        if resourceData == nil
            or resourceData.enabled ~= true
            or GetSetting("ResourceTradingEnabled", true) ~= true
        then
            setReturn({success=false, message="Resource trading is disabled."});
            return;
        end

        local targetPlayerID = MakeInteger(payload.targetPlayerID);
        local resourceName = tostring(payload.resource or "");
        local amount = math.max(1, math.min(10, MakeInteger(payload.amount) or 1));
        local pricePerUnit = math.max(0, math.min(500, MakeInteger(payload.pricePerUnit) or 25));

        if targetPlayerID == nil or targetPlayerID == playerID or not PlayerAvailable(game, targetPlayerID) then
            setReturn({success=false, message="Invalid resource trade partner."});
            return;
        end

        if UNEmbargoActive(data, playerID)
            or UNEmbargoActive(data, targetPlayerID)
        then
            setReturn({success=false, message="A UN embargo currently blocks new resource trade with one of these nations."});
            return;
        end

        if RESOURCE_TYPES[resourceName] ~= true then
            setReturn({success=false, message="Invalid resource type."});
            return;
        end
        if IsAdvancedResource(resourceName)
            and GetSetting("AdvancedResourcesEnabled", true) ~= true
        then
            setReturn({success=false, message="Advanced resources are disabled."});
            return;
        end

        local nation = EnsureNation(data, game, playerID);
        EnsureNationResourceFields(nation);
        local production = nation.resourceProduction[resourceName] or 0;
        if production < amount then
            setReturn({success=false, message="Your current " .. resourceName .. " production is only " .. tostring(production) .. " per turn."});
            return;
        end

        local id = resourceData.nextOfferID;
        resourceData.nextOfferID = id + 1;
        table.insert(resourceData.pendingOffers, {
            id = id,
            fromPlayerID = playerID,
            toPlayerID = targetPlayerID,
            resource = resourceName,
            amount = amount,
            pricePerUnit = pricePerUnit,
            createdTurn = data.tradeTurn or 0
        });
        CompactPublicGameDataForSave(data);
        Mod.PublicGameData = data;
        setReturn({success=true, message="Resource trade offer sent."});
        return;
    end


    if payload.type == "acceptResourceTrade" then
        local offerID = MakeInteger(payload.offerID);
        local index, offer = FindResourceOffer(resourceData or {}, offerID);
        if offer == nil or offer.toPlayerID ~= playerID then
            setReturn({success=false, message="Resource trade offer not found."});
            return;
        end
        table.remove(resourceData.pendingOffers, index);
        offer.acceptedTurn = data.tradeTurn or 0;
        table.insert(resourceData.activeTrades, offer);
        table.insert(resourceData.tradeHistory, {
            turn = data.tradeTurn or 0,
            type = "accepted",
            fromPlayerID = offer.fromPlayerID,
            toPlayerID = offer.toPlayerID,
            resource = offer.resource,
            amount = offer.amount,
            pricePerUnit = offer.pricePerUnit
        });
        TrimArrayKeepNewestForSave(resourceData.tradeHistory, 20);
        CompactPublicGameDataForSave(data);
        Mod.PublicGameData = data;
        setReturn({success=true, message="Resource trade contract activated."});
        return;
    end


    if payload.type == "rejectResourceTrade" then
        local offerID = MakeInteger(payload.offerID);
        local index, offer = FindResourceOffer(resourceData or {}, offerID);
        if offer == nil or offer.toPlayerID ~= playerID then
            setReturn({success=false, message="Resource trade offer not found."});
            return;
        end
        table.remove(resourceData.pendingOffers, index);
        CompactPublicGameDataForSave(data);
        Mod.PublicGameData = data;
        setReturn({success=true, message="Resource trade offer rejected."});
        return;
    end


    if payload.type == "cancelResourceTrade" then
        local tradeIndex = MakeInteger(payload.tradeIndex);
        local trade = tradeIndex and resourceData.activeTrades[tradeIndex] or nil;
        if trade == nil
            or (trade.fromPlayerID ~= playerID and trade.toPlayerID ~= playerID)
        then
            setReturn({success=false, message="Resource trade contract not found."});
            return;
        end
        table.remove(resourceData.activeTrades, tradeIndex);
        CompactPublicGameDataForSave(data);
        Mod.PublicGameData = data;
        setReturn({success=true, message="Resource trade contract canceled."});
        return;
    end


    -- =====================================================
    -- CANCEL TRADE
    -- =====================================================

    if payload.type
        == "cancelTrade" then


        local otherPlayerID =
            MakeInteger(
                payload.otherPlayerID
            );


        if otherPlayerID == nil then


            setReturn({
                success = false,
                message =
                    "Invalid trade partner."
            });


            return;
        end


        local agreementIndex =
            nil;


        for index, agreement
            in ipairs(
                data.activeAgreements
            ) do


            if
                (
                    agreement.player1
                        == playerID

                    and agreement.player2
                        == otherPlayerID
                )
                or
                (
                    agreement.player1
                        == otherPlayerID

                    and agreement.player2
                        == playerID
                )
            then


                agreementIndex =
                    index;


                break;
            end
        end


        if agreementIndex == nil then


            setReturn({
                success = false,
                message =
                    "You do not have an active trade agreement with this nation."
            });


            return;
        end


        table.remove(
            data.activeAgreements,
            agreementIndex
        );


        StartCooldown(
            data,
            playerID,
            otherPlayerID
        );


        local cancelingName =
            GetPlayerName(
                game,
                playerID
            );


        local otherName =
            GetPlayerName(
                game,
                otherPlayerID
            );


        AddTradeHistory(
            data,
            "agreement_canceled",
            cancelingName ..
            " canceled its trade agreement with " ..
            otherName ..
            ".",
            playerID,
            otherPlayerID,
            false
        );


        CompactPublicGameDataForSave(data);
        Mod.PublicGameData =
            data;


        local cooldown =
            GetCooldownTurns();


        if cooldown > 0 then


            setReturn({

                success =
                    true,

                message =
                    "Trade agreement canceled. A " ..
                    tostring(
                        cooldown
                    ) ..
                    "-turn cooldown is now active."
            });


        else


            setReturn({

                success =
                    true,

                message =
                    "Trade agreement canceled."
            });
        end


        return;
    end


    -- =====================================================
    -- UNKNOWN REQUEST
    -- =====================================================

    setReturn({

        success =
            false,

        message =
            "Unknown Global Economy request."
    });
end