-- =========================================================
-- GLOBAL ECONOMY & DIPLOMACY
-- INITIAL GAME / NATION STATE
-- =========================================================


-- =========================================================
-- HELPERS
-- =========================================================

local function GetSetting(name, defaultValue)

    if Mod.Settings ~= nil
        and Mod.Settings[name] ~= nil then

        return Mod.Settings[name];
    end

    return defaultValue;
end


local function IsAIPlayer(player)

    if player == nil then
        return false;
    end

    -- War.app exposes player information differently
    -- depending on player type / state.
    -- For now this field is initialized conservatively.
    -- Smart AI handling will be finalized when we build
    -- the AI Strategy Engine.

    if player.IsAI ~= nil then
        return player.IsAI == true;
    end

    return false;
end


local function CreateResourceState()

    return
        {
            enabled =
                GetSetting(
                    "ResourcesEnabled",
                    true
                ),

            advancedEnabled =
                GetSetting(
                    "AdvancedResourcesEnabled",
                    true
                ),

            randomizedPlacement =
                GetSetting(
                    "RandomizedResourcePlacement",
                    false
                ),

            mapIconsEnabled =
                GetSetting(
                    "ResourceMapIconsEnabled",
                    true
                ),

            territories = {},
            pendingBuilds = {},
            pendingOffers = {},
            activeTrades = {},
            tradeHistory = {},
            nextOfferID = 1
        };
end




local function CreateMilitaryFoundationState()

    return
        {
            version = 1,
            enabled = GetSetting("MilitaryExpansionEnabled", true),

            -- Strategic ownership and sensitive military details are stored outside this public framework where appropriate.
            -- Visible map assets are synchronized from the authoritative military state; private intelligence remains player-specific.
            publicStructures = {},
            pendingPublicEvents = {},
            nextStructureID = 1
        };
end

local function CreateDefaultNationState(
    playerID,
    player,
    startAtWar
)

    local nation = {};

    nation.playerID =
        playerID;

    nation.initialized =
        true;

    nation.eliminated =
        false;

    nation.isAI =
        IsAIPlayer(player);


    -- =====================================================
    -- TURN 1 NATIONAL SETUP
    -- =====================================================

    nation.setupComplete =
        false;

    nation.ideology =
        nil;

    nation.economicStrategy =
        nil;

    nation.taxPolicy =
        "Standard";

    nation.taxPolicyLastChangedTurn =
        0;


    -- =====================================================
    -- ECONOMIC HISTORY
    -- =====================================================

    nation.commerceHistory =
        {};

    nation.storedGoldHistory =
        {};

    nation.economicRankHistory =
        {};

    nation.economicPowerScore =
        0;

    nation.currentEconomicRank =
        nil;


    -- =====================================================
    -- DIPLOMACY
    -- =====================================================

    nation.defaultRelationship =
        startAtWar
        and "war"
        or "peace";

    nation.relationships =
        {};

    nation.pendingWarDeclarations =
        {};

    nation.pendingPeaceOffers =
        {};

    nation.nonAggressionPacts =
        {};

    nation.lastPeaceTurn =
        {};


    -- =====================================================
    -- TRADE
    -- =====================================================

    nation.tradeIncomeThisTurn =
        0;

    nation.totalTradeIncome =
        0;


    -- =====================================================
    -- INVESTMENTS
    -- =====================================================

    nation.totalProjectInvested =
        0;

    nation.totalProjectReturned =
        0;

    nation.projectProfitLoss =
        0;


    -- =====================================================
    -- PUBLIC COMPANIES
    -- =====================================================

    nation.companies =
        {};

    nation.companySlotsUnlocked =
        1;

    nation.flagshipCompanyCreated =
        false;


    -- =====================================================
    -- STOCK PORTFOLIO
    -- =====================================================

    nation.stockHoldings =
        {};

    nation.stockCostBasis =
        {};

    nation.realizedStockProfit =
        0;

    nation.dividendsReceived =
        0;


    -- =====================================================
    -- ETF
    -- =====================================================

    nation.etfShares =
        0;

    nation.etfCostBasis =
        0;

    nation.etfDividendsReceived =
        0;

    nation.etfRebalanceBonusesReceived =
        0;

    nation.etfBonusThisTurn =
        0;


    -- =====================================================
    -- BONDS
    -- =====================================================

    nation.bondsOwned =
        {};

    nation.bondsIssued =
        {};

    nation.creditRating =
        "BBB";

    nation.creditScore =
        50;


    -- =====================================================
    -- UNITED NATIONS
    -- =====================================================

    nation.publicEnemyLevel =
        0;

    nation.sanctions =
        {};

    nation.unEligible =
        true;

    nation.unLeadershipRole =
        nil;

    nation.lastUNProposalTurn =
        nil;


    -- =====================================================
    -- AI STRATEGY
    -- =====================================================

    nation.aiProfile =
        nil;

    nation.aiDynamicReservePercent =
        GetSetting(
            "AIBaseReservePercent",
            40
        );

    nation.aiLastStrategicReviewTurn =
        0;


    -- =====================================================
    -- PLAYER AI MANAGER
    -- =====================================================

    nation.aiManagerEnabled =
        false;

    nation.aiManagerBudget =
        100;

    nation.aiManagerBudgetRemaining =
        0;

    nation.aiManagerCancelTurn =
        nil;

    nation.aiManagerLastProcessedTurn =
        0;

    nation.aiManagerTurnBudget =
        0;

    nation.aiManagerSpentThisTurn =
        0;

    nation.aiManagerMarketSpentThisTurn =
        0;

    nation.aiManagerInvestmentSpentThisTurn =
        0;

    nation.aiManagerMilitarySpentThisTurn =
        0;

    nation.aiManagerCommerceBefore =
        0;

    nation.aiManagerCommerceAfter =
        0;


    -- =====================================================
    -- STRATEGIC RESOURCES
    -- =====================================================

    nation.resourceProfile =
        nil;

    nation.resourceSlot =
        nil;

    nation.resourceProduction =
        {};

    nation.resourceEffective =
        {};

    nation.resourceShortages =
        {};

    nation.resourceRequirements =
        {};

    nation.resourceRequirementsInitialized =
        false;

    nation.resourcePenaltyPercent =
        0;

    nation.resourceMilitaryReadiness =
        100;

    nation.resourceUnrest =
        0;

    nation.resourceBuildReservedGold =
        0;

    nation.armyRecruiterCount = 0;
    nation.armyRecruiterLevels = 0;
    nation.armyRecruiterArmiesGeneratedThisTurn = 0;




    -- =====================================================
    -- UNITED FRONTIER MILITARY FOUNDATION
    -- =====================================================

    nation.military =
        {
            doctrine = "Peace",
            headquartersStatus = "Not Constructed",
            headquartersLevel = 0,
            headquartersTerritoryID = nil,
            headquartersBranches =
                {
                    Intelligence = 0,
                    Security = 0,
                    CyberWarfare = 0,
                    JointCommand = 0
                },

            airbaseCount = 0,
            forwardAirstripCount = 0,
            samSiteCount = 0,
            missileSiloCount = 0,
            powerGridCount = 0,
            airWingCount = 0,
            specialForcesCount = 0,

            damagedStructureCount = 0,
            disabledStructureCount = 0,

            -- These are summaries only. Hidden structure locations and
            -- intelligence discoveries are deliberately NOT placed here.
            sharedIntelligenceEnabled = false,
            jointStrategicWarningEnabled = false
        };


    -- =====================================================
    -- NOTIFICATIONS / TURN REPORT
    -- =====================================================

    nation.personalEventQueue =
        {};

    nation.lastTurnReportSeen =
        0;

    -- =====================================================
    -- WAR EVENT / PLAYER NOTIFICATION PREFERENCES
    -- =====================================================

    nation.showWarEventAlerts = true;
    nation.pendingWarEvent = nil;
    nation.lastWarEventTurn = 0;
    nation.warEventReadinessModifier = 0;
    nation.warEventReadinessUntilTurn = 0;
    nation.pendingWarEventGoldDelta = 0;
    nation.pendingWarEventUnrestDelta = 0;


    return nation;
end


local function CreateGlobalState()

    local data = {};

    data.version =
        4;

    data.initialized =
        true;

    data.currentEconomyTurn =
        1;

    data.openingPeriodTurns =
        GetSetting(
            "OpeningPeriodTurns",
            1
        );


    -- =====================================================
    -- PLAYER / NATION STATE
    -- =====================================================

    data.nations =
        {};


    -- =====================================================
    -- DIPLOMACY
    -- =====================================================

    data.diplomacy =
        {
            relationships = {},
            warHistory = {},
            peaceHistory = {},
            nonAggressionPacts = {},
            warStats = {},
            warEventHistory = {},
            nextWarEventID = 1
        };


    -- =====================================================
    -- TRADE
    -- =====================================================

    -- Existing trade systems currently use their own
    -- PublicGameData fields.
    -- We do NOT delete or replace them here.
    -- They will be migrated later.


    -- =====================================================
    -- INVESTMENTS
    -- =====================================================

    -- Existing investment systems also remain untouched
    -- for now and will be migrated during their rebuild.


    -- =====================================================
    -- STOCK MARKET
    -- =====================================================

    data.market =
        {
            companies = {},
            transactions = {},
            priceHistory = {},
            nextCompanyID = 1
        };


    -- =====================================================
    -- ETF
    -- =====================================================

    data.etf =
        {
            enabled =
                GetSetting(
                    "ETFEnabled",
                    true
                ),

            size =
                GetSetting(
                    "ETFSize",
                    5
                ),

            price =
                100,

            holdings =
                {},

            members =
                {},

            membershipHistory =
                {},

            priceHistory =
                {}
        };


    -- =====================================================
    -- BONDS
    -- =====================================================

    data.bondMarket =
        {
            bonds = {},
            transactions = {},
            nextBondID = 1
        };

    data.warBonds =
        {
            nextHoldingID = 1,
            holdings = {},
            maturityTurns = 5,
            returnPercent = 20
        };


    -- =====================================================
    -- TAXATION
    -- =====================================================

    data.taxation =
        {
            enabled =
                GetSetting(
                    "TaxationEnabled",
                    true
                )
        };


    -- =====================================================
    -- STRATEGIC RESOURCES
    -- =====================================================

    data.resources =
        CreateResourceState();


    -- =====================================================
    -- MILITARY FOUNDATION
    -- =====================================================

    data.military =
        CreateMilitaryFoundationState();


    -- =====================================================
    -- UNITED NATIONS
    -- =====================================================

    data.unitedNations =
        {
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

            chairPlayerID = nil,
            viceChairPlayerID = nil,

            publicEnemies = {},
            sanctions = {},
            embargoes = {},
            condemnations = {}
        };

    -- =====================================================
    -- WORLD NEWS / EVENT SYSTEM
    -- =====================================================

    data.worldEvents =
        {};

    data.pendingWorldReportEvents =
        {};

    data.turnReports =
        {};


    -- =====================================================
    -- ECONOMIC RANKINGS
    -- =====================================================

    data.economicRankings =
        {};


    -- =====================================================
    -- TRANSACTION LEDGER
    -- =====================================================

    data.transactionLedger =
        {};


    return data;
end


-- =========================================================
-- STRATEGIC RESOURCE DEFINITIONS
-- =========================================================

local RESOURCE_ORDER = {
    "Oil",
    "Gas",
    "Uranium",
    "Iron",
    "Food",
    "Rare Earths",
    "Coal",
    "Copper",
    "Lithium"
};

-- One custom map icon per resource territory.
-- The icon family identifies the dominant resource, while the badge baked into
-- the image shows the combined facility/deposit level.  We always place exactly
-- one custom structure so territories never get clogged by repeated icons.
local RESOURCE_ICON_SAFE_NAMES = {
    Oil = "Oil",
    Gas = "Gas",
    Uranium = "Uranium",
    Iron = "Iron",
    Food = "Food",
    ["Rare Earths"] = "RareEarths",
    Coal = "Coal",
    Copper = "Copper",
    Lithium = "Lithium"
};

local function ResourceIconStructure(resourceName, facilityLevel)
    local safe = RESOURCE_ICON_SAFE_NAMES[resourceName] or "Oil";
    local maxLevel = math.max(1, math.min(5, math.floor(tonumber(Mod.Settings.ResourceFacilityMaxLevel) or 3)));
    local level = math.max(1, math.min(maxLevel, math.floor(tonumber(facilityLevel) or 1)));
    return WL.StructureType.Custom("Resource" .. safe .. tostring(level));
end

local function GetPrimaryResource(nodes)
    local bestName = nil;
    local bestLevel = -1;
    for _, resourceName in ipairs(RESOURCE_ORDER) do
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
    for _, resourceName in ipairs(RESOURCE_ORDER) do
        total = total + math.max(0, tonumber((nodes or {})[resourceName]) or 0);
    end
    return total;
end

local PUBLIC_RESOURCE_ICONS = {}; -- Resources are player-specific intelligence and are never globally exposed as standing structures.

local function ResourceTerritoryBordersAnotherPlayer(Game, Standing, territoryID)
    local terr = Standing and Standing.Territories and Standing.Territories[territoryID] or nil;
    local owner = terr and terr.OwnerPlayerID or nil;
    if owner == nil or owner == WL.PlayerID.Neutral or owner == WL.PlayerID.Fogged then return false; end
    local details = Game and Game.Map and Game.Map.Territories and Game.Map.Territories[territoryID] or nil;
    if details == nil then return false; end
    for connectedID, _ in pairs(details.ConnectedTo or {}) do
        local neighbor = Standing.Territories[connectedID];
        local other = neighbor and neighbor.OwnerPlayerID or nil;
        if other ~= nil and other ~= owner and other ~= WL.PlayerID.Neutral and other ~= WL.PlayerID.Fogged then
            return true;
        end
    end
    return false;
end

local function ShouldShowResourceIcon(Game, Standing, territoryID, resourceName)
    -- War.app standing structures are shared with every viewer.  United Frontier keeps
    -- resource locations private and exposes permitted locations through
    -- Mod.PlayerGameData + client map highlighting instead of global structures.
    return false;
end

-- Slot profiles are deliberately broad 2026 strategic-production strengths,
-- not literal extraction tonnage.  They are used to decide how many deposits
-- are seeded for a nation when the host chooses realistic placement.
local RESOURCE_SLOT_PROFILES = {
    {name="United States", Oil=5, Gas=5, Uranium=3, Iron=3, Food=5, ["Rare Earths"]=2, Coal=4, Copper=3, Lithium=2},
    {name="China", Oil=2, Gas=2, Uranium=2, Iron=5, Food=5, ["Rare Earths"]=5, Coal=5, Copper=5, Lithium=4},
    {name="Russia", Oil=5, Gas=5, Uranium=4, Iron=4, Food=3, ["Rare Earths"]=3, Coal=4, Copper=3, Lithium=2},
    {name="India", Oil=2, Gas=1, Uranium=2, Iron=4, Food=5, ["Rare Earths"]=2, Coal=4, Copper=3, Lithium=2},
    {name="Germany", Oil=1, Gas=1, Uranium=0, Iron=2, Food=3, ["Rare Earths"]=1, Coal=1, Copper=1, Lithium=0},
    {name="Japan", Oil=0, Gas=0, Uranium=0, Iron=1, Food=2, ["Rare Earths"]=1, Coal=0, Copper=1, Lithium=0},
    {name="Britain", Oil=2, Gas=2, Uranium=1, Iron=1, Food=3, ["Rare Earths"]=1, Coal=1, Copper=1, Lithium=0},
    {name="France", Oil=1, Gas=0, Uranium=2, Iron=1, Food=4, ["Rare Earths"]=1, Coal=0, Copper=1, Lithium=1},
    {name="Brazil", Oil=4, Gas=2, Uranium=2, Iron=5, Food=5, ["Rare Earths"]=3, Coal=1, Copper=3, Lithium=3},
    {name="Saudi Arabia", Oil=5, Gas=4, Uranium=0, Iron=1, Food=1, ["Rare Earths"]=1, Coal=0, Copper=2, Lithium=0},
    {name="Turkey", Oil=1, Gas=1, Uranium=1, Iron=3, Food=4, ["Rare Earths"]=2, Coal=3, Copper=3, Lithium=1},
    {name="Italy", Oil=1, Gas=1, Uranium=0, Iron=1, Food=4, ["Rare Earths"]=0, Coal=0, Copper=1, Lithium=0},
    {name="Poland", Oil=1, Gas=1, Uranium=0, Iron=2, Food=4, ["Rare Earths"]=1, Coal=4, Copper=2, Lithium=0},
    {name="Iran", Oil=5, Gas=5, Uranium=2, Iron=3, Food=3, ["Rare Earths"]=2, Coal=2, Copper=4, Lithium=1},
    {name="Israel", Oil=0, Gas=3, Uranium=1, Iron=0, Food=2, ["Rare Earths"]=0, Coal=0, Copper=1, Lithium=0},
    {name="Australia", Oil=2, Gas=5, Uranium=5, Iron=5, Food=5, ["Rare Earths"]=5, Coal=5, Copper=4, Lithium=5},
    {name="Indonesia", Oil=3, Gas=3, Uranium=0, Iron=2, Food=5, ["Rare Earths"]=2, Coal=5, Copper=4, Lithium=1},
    {name="Spain", Oil=0, Gas=0, Uranium=1, Iron=2, Food=4, ["Rare Earths"]=1, Coal=1, Copper=2, Lithium=2},
    {name="Pakistan", Oil=1, Gas=2, Uranium=2, Iron=2, Food=4, ["Rare Earths"]=1, Coal=3, Copper=2, Lithium=1},
    {name="Ukraine", Oil=1, Gas=2, Uranium=3, Iron=4, Food=5, ["Rare Earths"]=2, Coal=4, Copper=2, Lithium=1},
    {name="South Africa", Oil=0, Gas=1, Uranium=3, Iron=4, Food=3, ["Rare Earths"]=4, Coal=5, Copper=3, Lithium=2},
    {name="Vietnam", Oil=2, Gas=2, Uranium=0, Iron=2, Food=5, ["Rare Earths"]=3, Coal=4, Copper=2, Lithium=1},
    {name="Argentina", Oil=3, Gas=4, Uranium=2, Iron=2, Food=5, ["Rare Earths"]=2, Coal=1, Copper=3, Lithium=5},
    {name="Norway", Oil=5, Gas=5, Uranium=0, Iron=1, Food=2, ["Rare Earths"]=1, Coal=1, Copper=2, Lithium=0},
    {name="Algeria", Oil=4, Gas=5, Uranium=1, Iron=3, Food=2, ["Rare Earths"]=2, Coal=1, Copper=2, Lithium=0},
    {name="Colombia", Oil=3, Gas=2, Uranium=0, Iron=1, Food=5, ["Rare Earths"]=1, Coal=4, Copper=2, Lithium=0},
    {name="Chile", Oil=0, Gas=1, Uranium=0, Iron=3, Food=3, ["Rare Earths"]=2, Coal=1, Copper=5, Lithium=5},
    {name="Kazakhstan", Oil=5, Gas=4, Uranium=5, Iron=4, Food=3, ["Rare Earths"]=3, Coal=4, Copper=4, Lithium=1},
    {name="Nigeria", Oil=5, Gas=5, Uranium=0, Iron=2, Food=4, ["Rare Earths"]=1, Coal=2, Copper=1, Lithium=0},
    {name="Iraq", Oil=5, Gas=3, Uranium=0, Iron=1, Food=2, ["Rare Earths"]=0, Coal=0, Copper=1, Lithium=0},
    {name="Peru", Oil=1, Gas=2, Uranium=1, Iron=3, Food=4, ["Rare Earths"]=2, Coal=1, Copper=5, Lithium=2},
    {name="Venezuela", Oil=5, Gas=4, Uranium=1, Iron=3, Food=2, ["Rare Earths"]=1, Coal=3, Copper=2, Lithium=0},
    {name="Libya", Oil=5, Gas=4, Uranium=0, Iron=1, Food=1, ["Rare Earths"]=0, Coal=0, Copper=1, Lithium=0},
    {name="Ethiopia", Oil=0, Gas=1, Uranium=0, Iron=1, Food=4, ["Rare Earths"]=1, Coal=1, Copper=2, Lithium=0},
    {name="Myanmar", Oil=2, Gas=3, Uranium=1, Iron=2, Food=5, ["Rare Earths"]=4, Coal=2, Copper=3, Lithium=1},
    {name="DR Congo", Oil=1, Gas=1, Uranium=2, Iron=3, Food=3, ["Rare Earths"]=5, Coal=1, Copper=5, Lithium=4},
    {name="Mozambique", Oil=0, Gas=5, Uranium=1, Iron=2, Food=3, ["Rare Earths"]=2, Coal=4, Copper=1, Lithium=1},
    {name="Taiwan", Oil=0, Gas=0, Uranium=0, Iron=1, Food=2, ["Rare Earths"]=2, Coal=0, Copper=2, Lithium=0}
};

local function GetResourceProfile(slot)
    return RESOURCE_SLOT_PROFILES[slot] or {
        name = "Generic Slot " .. tostring(slot),
        Oil = 1, Gas = 1, Uranium = 1, Iron = 2, Food = 3,
        ["Rare Earths"] = 1, Coal = 1, Copper = 1, Lithium = 1
    };
end

local function IsResourceCustomStructure(structureType)
    for _, safe in pairs(RESOURCE_ICON_SAFE_NAMES) do
        for level = 1, 5 do
            if structureType == WL.StructureType.Custom("Resource" .. safe .. tostring(level)) then
                return true;
            end
        end
    end
    return false;
end

local function RefreshStartingResourceIcon(Game, standing, resources, territoryID)
    local terr = standing.Territories[territoryID];
    local nodes = resources.territories[territoryID];
    if terr == nil or nodes == nil then return; end

    -- Build a fresh plain Lua structure table instead of assigning nil into
    -- War.app's typed Int32 structure dictionary.  Assigning nil to that
    -- dictionary can throw "Int32 cannot be nil" during Server_StartGame.
    local structures = {};
    for structureType, count in pairs(terr.Structures or {}) do
        if structureType ~= WL.StructureType.ResourceCache
            and not IsResourceCustomStructure(structureType)
        then
            structures[structureType] = count;
        end
    end

    local primary = GetPrimaryResource(nodes);
    local primaryLevel = math.max(0, tonumber((nodes or {})[primary]) or 0);
    if primaryLevel > 0 and ShouldShowResourceIcon(Game, standing, territoryID, primary) then
        structures[ResourceIconStructure(primary, primaryLevel)] = 1;
    end

    terr.Structures = structures;
end

local function ShuffleTerritories(list)
    for i = #list, 2, -1 do
        local j = math.random(i);
        list[i], list[j] = list[j], list[i];
    end
end

local function InitializeStrategicResources(Game, Standing, economy)
    if economy.resources == nil or economy.resources.enabled ~= true then
        return;
    end

    local activePlayerIDs = {};
    for playerID, nation in pairs(economy.nations or {}) do
        if nation.eliminated ~= true then
            table.insert(activePlayerIDs, playerID);
        end
    end
    table.sort(activePlayerIDs);

    local territoriesByOwner = {};
    for territoryID, terr in pairs(Standing.Territories or {}) do
        local owner = terr.OwnerPlayerID;
        if owner ~= nil and owner ~= WL.PlayerID.Neutral then
            territoriesByOwner[owner] = territoriesByOwner[owner] or {};
            table.insert(territoriesByOwner[owner], territoryID);
        end
    end

    for slot, playerID in ipairs(activePlayerIDs) do
        local nation = economy.nations[playerID];
        local profile = GetResourceProfile(slot);
        nation.resourceSlot = slot;
        nation.resourceProfile = profile.name;

        local owned = territoriesByOwner[playerID] or {};
        table.sort(owned);
        if economy.resources.randomizedPlacement == true then
            ShuffleTerritories(owned);
        end

        if #owned > 0 then
            local cursor = 1;
            for _, resourceName in ipairs(RESOURCE_ORDER) do
                if economy.resources.advancedEnabled == true
                    or resourceName == "Oil"
                    or resourceName == "Gas"
                    or resourceName == "Uranium"
                    or resourceName == "Iron"
                    or resourceName == "Food"
                    or resourceName == "Rare Earths"
                then
                    local strength = tonumber(profile[resourceName]) or 0;
                    local deposits = math.max(0, math.min(3, math.ceil(strength / 2)));
                    for n = 1, deposits do
                        local territoryID = owned[cursor];
                        cursor = cursor + 1;
                        if cursor > #owned then cursor = 1; end
                        economy.resources.territories[territoryID] =
                            economy.resources.territories[territoryID] or {};
                        local current = economy.resources.territories[territoryID][resourceName] or 0;
                        local level = math.max(current, strength >= 4 and 2 or 1);
                        economy.resources.territories[territoryID][resourceName] = level;
                        -- Map icon is refreshed once after all resources are seeded
                        -- so a multi-resource territory still receives only one icon.
                    end
                end
            end
        end
    end

    if economy.resources.mapIconsEnabled ~= false then
        for territoryID, _ in pairs(economy.resources.territories or {}) do
            RefreshStartingResourceIcon(Game, Standing, economy.resources, territoryID);
        end
    end
end


-- =========================================================
-- SERVER START GAME
-- =========================================================

function Server_StartGame(
    Game,
    Standing
)

    local existing =
        Mod.PublicGameData or {};


    -- =====================================================
    -- DO NOT DESTROY EXISTING V1 STATE
    -- =====================================================

    local data =
        existing;


    -- If this is a brand-new game using the new system,
    -- create the Version 2 foundation.

    if data.globalEconomy == nil then

        data.globalEconomy =
            CreateGlobalState();

    end


    local economy =
        data.globalEconomy;


    -- Support both brand-new games and games created from
    -- an older V3 data shape that did not yet contain resources.
    if economy.resources == nil then
        economy.resources =
            CreateResourceState();
    end

    economy.resources.mapIconsEnabled =
        GetSetting(
            "ResourceMapIconsEnabled",
            economy.resources.mapIconsEnabled ~= false
        );

    if economy.unitedNations == nil then
        economy.unitedNations =
            data.unitedNations or {
                enabled = GetSetting("UnitedNationsEnabled", true),
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
    end
    data.unitedNations = economy.unitedNations;


    -- =====================================================
    -- INITIALIZE EVERY PLAYER / NATION
    -- =====================================================

    local startAtWar =
        GetSetting(
            "PlayersStartAtWar",
            false
        );


    if Game ~= nil
        and Game.Game ~= nil
        and Game.Game.Players ~= nil then

        for playerID, player in pairs(
            Game.Game.Players
        ) do

            if economy.nations[playerID] == nil then

                economy.nations[playerID] =
                    CreateDefaultNationState(
                        playerID,
                        player,
                        startAtWar
                    );

            end

        end

    elseif Game ~= nil
        and Game.Players ~= nil then

        -- Fallback for environments where Players is
        -- exposed directly on the Game object.

        for playerID, player in pairs(
            Game.Players
        ) do

            if economy.nations[playerID] == nil then

                economy.nations[playerID] =
                    CreateDefaultNationState(
                        playerID,
                        player,
                        startAtWar
                    );

            end

        end

    end


    -- =====================================================
    -- INITIALIZE RELATIONSHIPS
    -- =====================================================

    local playerIDs =
        {};

    for playerID, nation in pairs(
        economy.nations
    ) do

        table.insert(
            playerIDs,
            playerID
        );
    end


    for i = 1, #playerIDs do

        local playerA =
            playerIDs[i];

        if economy.diplomacy.relationships[playerA]
            == nil then

            economy.diplomacy.relationships[playerA] =
                {};

        end


        for j = i + 1, #playerIDs do

            local playerB =
                playerIDs[j];


            if economy.diplomacy.relationships[playerB]
                == nil then

                economy.diplomacy.relationships[playerB] =
                    {};

            end


            local startingStatus =
                startAtWar
                and "war"
                or "peace";


            if economy.diplomacy
                .relationships[playerA][playerB]
                == nil then

                economy.diplomacy
                    .relationships[playerA][playerB] =
                        {
                            status =
                                startingStatus,

                            sinceTurn =
                                1,

                            warEffectiveTurn =
                                startAtWar
                                and 1
                                or nil
                        };

            end


            if economy.diplomacy
                .relationships[playerB][playerA]
                == nil then

                economy.diplomacy
                    .relationships[playerB][playerA] =
                        {
                            status =
                                startingStatus,

                            sinceTurn =
                                1,

                            warEffectiveTurn =
                                startAtWar
                                and 1
                                or nil
                        };

            end

        end

    end


    -- =====================================================
    -- INITIALIZE STRATEGIC RESOURCES
    -- =====================================================

    InitializeStrategicResources(
        Game,
        Standing,
        economy
    );


    -- =====================================================
    -- INITIAL WORLD EVENT
    -- =====================================================

    table.insert(
        economy.worldEvents,
        {
            turn =
                1,

            type =
                "global_economy_initialized",

            headline =
                "Global Economy & Diplomacy system initialized."
        }
    );


    -- =====================================================
    -- SAVE BACK TO PUBLIC GAME DATA
    -- =====================================================

    data.globalEconomy =
        economy;

    economy.armyRecruiters = economy.armyRecruiters or {enabled = true, territories = {}, pendingBuilds = {}};

    Mod.PublicGameData =
        data;

    -- =====================================================
    -- UNITED FRONTIER PRIVATE STRATEGIC STATE
    -- =====================================================
    local privateData = Mod.PrivateGameData or {};
    privateData.strategicMilitary = privateData.strategicMilitary or {byPlayer = {}};
    privateData.strategicMilitary.byPlayer = privateData.strategicMilitary.byPlayer or {};

    local playerData = Mod.PlayerGameData or {};
    for playerID, _ in pairs(economy.nations or {}) do
        privateData.strategicMilitary.byPlayer[playerID] =
            privateData.strategicMilitary.byPlayer[playerID]
            or {
                headquarters = nil,
                airbases = {},
                forwardAirstrips = {},
                samSites = {},
                missileSilos = {},
                powerGrids = {},
                airWings = {},
                specialForces = {},
                pendingAirWings = {},
                pendingSpecialForces = {},
                discoveredResourceTerritories = {},
                discoveredMilitary = {},
                lastResourceIntelScanTurn = nil,
                lastMilitaryIntelScanTurn = nil
            };
        playerData[playerID] = playerData[playerID] or {};
        playerData[playerID].strategicIntel = playerData[playerID].strategicIntel or {knownResources = {}, knownMilitary = {}};
        playerData[playerID].ownMilitary = privateData.strategicMilitary.byPlayer[playerID];
    end
    Mod.PrivateGameData = privateData;
    Mod.PlayerGameData = playerData;

    print(
        "Global Economy initialization complete."
    );

end