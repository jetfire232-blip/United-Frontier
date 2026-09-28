-- =========================================================
-- GLOBAL ECONOMY & DIPLOMACY
-- HOST CONFIGURATION UI
-- =========================================================

TradeConfigInputs = {};


-- =========================================================
-- HELPERS
-- =========================================================

local function GetNumberSetting(settings, name, defaultValue)

    if settings[name] ~= nil then
        return settings[name];
    end

    return defaultValue;
end


local function GetBoolSetting(settings, name, defaultValue)

    if settings[name] ~= nil then
        return settings[name];
    end

    return defaultValue;
end


local function AddDivider(root)

    UI.CreateLabel(root)
        .SetText(
            "----------------------------------------"
        );
end


local function AddSection(root, title, description)

    AddDivider(root);

    UI.CreateLabel(root)
        .SetText(
            title
        );

    if description ~= nil
        and description ~= "" then

        UI.CreateLabel(root)
            .SetText(
                description
            );
    end
end


local function AddNumberInput(
    root,
    key,
    label,
    value,
    minimum,
    maximum,
    helpText
)

    UI.CreateLabel(root)
        .SetText(
            label
        );

    TradeConfigInputs[key] =
        UI.CreateNumberInputField(root)
            .SetWholeNumbers(true)
            .SetSliderMinValue(minimum)
            .SetSliderMaxValue(maximum)
            .SetValue(
                value
            );

    if helpText ~= nil
        and helpText ~= "" then

        UI.CreateLabel(root)
            .SetText(
                helpText
            );
    end
end


local function AddCheckBox(
    root,
    key,
    label,
    checked
)

    TradeConfigInputs[key] =
        UI.CreateCheckBox(root)
            .SetText(
                label
            )
            .SetIsChecked(
                checked
            );
end


-- =========================================================
-- MAIN CONFIGURATION UI
-- =========================================================

function Client_PresentConfigureUI(rootParent)

    local root =
        UI.CreateVerticalLayoutGroup(
            rootParent
        );

    local settings =
        Mod.Settings or {};


    -- =====================================================
    -- CURRENT / EXISTING TRADE SETTINGS
    -- =====================================================

    local maxTradeAgreements =
        GetNumberSetting(
            settings,
            "MaxTradeAgreements",
            3
        );

    local tradeBonusPercent =
        GetNumberSetting(
            settings,
            "TradeBonusPercent",
            10
        );

    local tradeCooldownTurns =
        GetNumberSetting(
            settings,
            "TradeCooldownTurns",
            3
        );

    local aiProposalChance =
        GetNumberSetting(
            settings,
            "AIProposalChance",
            35
        );

    local aiMinimumAgreementTurns =
        GetNumberSetting(
            settings,
            "AIMinimumAgreementTurns",
            3
        );

    local aiReplacementPercent =
        GetNumberSetting(
            settings,
            "AIReplacementPercent",
            50
        );

    local economicDeclineTurns =
        GetNumberSetting(
            settings,
            "EconomicDeclineTurns",
            3
        );


    -- =====================================================
    -- CURRENT / EXISTING AI INVESTMENT SETTINGS
    -- =====================================================

    local aiInvestmentsEnabled =
        GetBoolSetting(
            settings,
            "AIInvestmentsEnabled",
            true
        );

    local aiProjectsEnabled =
        GetBoolSetting(
            settings,
            "AIProjectsEnabled",
            true
        );

    local aiProjectChance =
        GetNumberSetting(
            settings,
            "AIProjectChance",
            15
        );

    local aiInvestChance =
        GetNumberSetting(
            settings,
            "AIInvestChance",
            30
        );

    local aiInvestmentReservePercent =
        GetNumberSetting(
            settings,
            "AIInvestmentReservePercent",
            40
        );


    -- =====================================================
    -- GENERAL SETTINGS
    -- =====================================================

    local openingPeriodTurns =
        GetNumberSetting(
            settings,
            "OpeningPeriodTurns",
            1
        );

    local turnReportsEnabled =
        GetBoolSetting(
            settings,
            "TurnReportsEnabled",
            true
        );

    local worldNewsEnabled =
        GetBoolSetting(
            settings,
            "WorldNewsEnabled",
            true
        );


    -- =====================================================
    -- DIPLOMACY SETTINGS
    -- =====================================================

    local requireWarDeclaration =
        GetBoolSetting(
            settings,
            "RequireWarDeclaration",
            true
        );

    local playersStartAtWar =
        GetBoolSetting(
            settings,
            "PlayersStartAtWar",
            false
        );

    local warDeclarationDelay =
        GetNumberSetting(
            settings,
            "WarDeclarationDelay",
            1
        );

    local peaceCooldownTurns =
        GetNumberSetting(
            settings,
            "PeaceCooldownTurns",
            3
        );

    local warEventsEnabled =
        GetBoolSetting(
            settings,
            "WarEventsEnabled",
            true
        );

    local warEventFrequencyTurns =
        GetNumberSetting(
            settings,
            "WarEventFrequencyTurns",
            3
        );

    local nonAggressionPactsEnabled =
        GetBoolSetting(
            settings,
            "NonAggressionPactsEnabled",
            true
        );

    local giftWarRestrictionEnabled =
        GetBoolSetting(
            settings,
            "GiftWarRestrictionEnabled",
            true
        );

    local aiCanDeclareWarOnHumans =
        GetBoolSetting(
            settings,
            "AICanDeclareWarOnHumans",
            true
        );

    local aiCanDeclareWarOnAI =
        GetBoolSetting(
            settings,
            "AICanDeclareWarOnAI",
            true
        );


    -- =====================================================
    -- INVESTMENT SETTINGS
    -- =====================================================

    local investmentFundingWindow =
        GetNumberSetting(
            settings,
            "InvestmentFundingWindow",
            3
        );

    local internationalInvestorBonusEnabled =
        GetBoolSetting(
            settings,
            "InternationalInvestorBonusEnabled",
            true
        );

    local investorSuccessBonusPercent =
        GetNumberSetting(
            settings,
            "InvestorSuccessBonusPercent",
            3
        );

    local maxInvestorSuccessBonusPercent =
        GetNumberSetting(
            settings,
            "MaxInvestorSuccessBonusPercent",
            10
        );


    -- =====================================================
    -- STOCK MARKET SETTINGS
    -- =====================================================

    local stockMarketEnabled =
        GetBoolSetting(
            settings,
            "StockMarketEnabled",
            true
        );

    local maxCompaniesPerNation =
        GetNumberSetting(
            settings,
            "MaxCompaniesPerNation",
            3
        );

    local founderSharePercent =
        GetNumberSetting(
            settings,
            "FounderSharePercent",
            20
        );

    local dividendsEnabled =
        GetBoolSetting(
            settings,
            "DividendsEnabled",
            true
        );

    local dividendFrequencyTurns =
        GetNumberSetting(
            settings,
            "DividendFrequencyTurns",
            3
        );

    local stockVolatilityPercent =
        GetNumberSetting(
            settings,
            "StockVolatilityPercent",
            10
        );


    -- =====================================================
    -- ETF SETTINGS
    -- =====================================================

    local etfEnabled =
        GetBoolSetting(
            settings,
            "ETFEnabled",
            true
        );

    local etfSize =
        GetNumberSetting(
            settings,
            "ETFSize",
            5
        );

    local etfMembershipBonusPercent =
        GetNumberSetting(
            settings,
            "ETFMembershipBonusPercent",
            3
        );

    local etfLoyaltyBonusEnabled =
        GetBoolSetting(
            settings,
            "ETFLoyaltyBonusEnabled",
            true
        );


    -- =====================================================
    -- BOND SETTINGS
    -- =====================================================

    local bondsEnabled =
        GetBoolSetting(
            settings,
            "BondsEnabled",
            true
        );

    local minimumBondDuration =
        GetNumberSetting(
            settings,
            "MinimumBondDuration",
            2
        );

    local maximumBondDuration =
        GetNumberSetting(
            settings,
            "MaximumBondDuration",
            10
        );


    -- =====================================================
    -- TAXATION SETTINGS
    -- =====================================================

    local taxationEnabled =
        GetBoolSetting(
            settings,
            "TaxationEnabled",
            true
        );

    local taxChangeCooldownTurns =
        GetNumberSetting(
            settings,
            "TaxChangeCooldownTurns",
            2
        );


    -- =====================================================
    -- UNITED NATIONS SETTINGS
    -- =====================================================

    local unitedNationsEnabled =
        GetBoolSetting(
            settings,
            "UnitedNationsEnabled",
            true
        );

    local unitedNationsStartTurn =
        GetNumberSetting(
            settings,
            "UnitedNationsStartTurn",
            2
        );

    local unVoteDurationTurns =
        GetNumberSetting(
            settings,
            "UNVoteDurationTurns",
            2
        );

    local unPassRequirementPercent =
        GetNumberSetting(
            settings,
            "UNPassRequirementPercent",
            60
        );

    local unProposalCooldownTurns =
        GetNumberSetting(
            settings,
            "UNProposalCooldownTurns",
            2
        );

    local unMaximumActiveResolutions =
        GetNumberSetting(
            settings,
            "UNMaximumActiveResolutions",
            3
        );

    local unSanctionMinTurns = GetNumberSetting(settings, "UNSanctionMinTurns", 2);
    local unSanctionMaxTurns = GetNumberSetting(settings, "UNSanctionMaxTurns", 6);
    local unCeasefireMinTurns = GetNumberSetting(settings, "UNCeasefireMinTurns", 2);
    local unCeasefireMaxTurns = GetNumberSetting(settings, "UNCeasefireMaxTurns", 6);

    local aiCanProposeUNResolutions =
        GetBoolSetting(
            settings,
            "AICanProposeUNResolutions",
            true
        );

    local publicEnemyEnabled =
        GetBoolSetting(
            settings,
            "PublicEnemyEnabled",
            true
        );

    local unLeadershipEnabled =
        GetBoolSetting(
            settings,
            "UNLeadershipEnabled",
            true
        );

    local unPermanentSeatCount =
        GetNumberSetting(
            settings,
            "UNPermanentSeatCount",
            5
        );

    local unRotatingSeatCount =
        GetNumberSetting(
            settings,
            "UNRotatingSeatCount",
            10
        );

    local unReplacementMode =
        GetNumberSetting(
            settings,
            "UNReplacementMode",
            1
        );

    local unPermanentSeatSlot1 = GetNumberSetting(settings, "UNPermanentSeatSlot1", 0);
    local unPermanentSeatSlot2 = GetNumberSetting(settings, "UNPermanentSeatSlot2", 0);
    local unPermanentSeatSlot3 = GetNumberSetting(settings, "UNPermanentSeatSlot3", 0);
    local unPermanentSeatSlot4 = GetNumberSetting(settings, "UNPermanentSeatSlot4", 0);
    local unPermanentSeatSlot5 = GetNumberSetting(settings, "UNPermanentSeatSlot5", 0);


    -- =====================================================
    -- RESOURCE SYSTEM SETTINGS
    -- =====================================================

    local resourcesEnabled =
        GetBoolSetting(
            settings,
            "ResourcesEnabled",
            true
        );

    local randomizedResourcePlacement =
        GetBoolSetting(
            settings,
            "RandomizedResourcePlacement",
            false
        );

    local advancedResourcesEnabled =
        GetBoolSetting(
            settings,
            "AdvancedResourcesEnabled",
            true
        );

    local resourceTradingEnabled =
        GetBoolSetting(
            settings,
            "ResourceTradingEnabled",
            true
        );

    local resourceFacilityBaseCost =
        GetNumberSetting(
            settings,
            "ResourceFacilityBaseCost",
            100
        );

    local resourceFacilityMaxLevel =
        GetNumberSetting(
            settings,
            "ResourceFacilityMaxLevel",
            3
        );

    local resourceShortagePenaltyPercent =
        GetNumberSetting(
            settings,
            "ResourceShortagePenaltyPercent",
            3
        );

    local resourceUnrestEnabled =
        GetBoolSetting(
            settings,
            "ResourceUnrestEnabled",
            true
        );

    local resourceMapIconsEnabled =
        GetBoolSetting(
            settings,
            "ResourceMapIconsEnabled",
            true
        );

    local armyRecruitersEnabled = GetBoolSetting(settings, "ArmyRecruitersEnabled", true);
    local armyRecruiterBaseCost = GetNumberSetting(settings, "ArmyRecruiterBaseCost", 250);
    local armyRecruiterMaxPerPlayer = GetNumberSetting(settings, "ArmyRecruiterMaxPerPlayer", 3);
    local armyRecruiterArmiesPerTurn = GetNumberSetting(settings, "ArmyRecruiterArmiesPerTurn", 4);
    local armyRecruiterMaxLevel = GetNumberSetting(settings, "ArmyRecruiterMaxLevel", 3);


    -- =====================================================
    -- UNITED FRONTIER MILITARY FOUNDATION
    -- =====================================================

    local militaryExpansionEnabled = GetBoolSetting(settings, "MilitaryExpansionEnabled", true);
    local hiddenMilitaryInfrastructureEnabled = GetBoolSetting(settings, "HiddenMilitaryInfrastructureEnabled", true);

    local headquartersEnabled = GetBoolSetting(settings, "HeadquartersEnabled", true);
    local headquartersBaseCost = GetNumberSetting(settings, "HeadquartersBaseCost", 500);
    local headquartersMaxBranchLevel = GetNumberSetting(settings, "HeadquartersMaxBranchLevel", 5);

    local airbasesEnabled = GetBoolSetting(settings, "AirbasesEnabled", true);
    local airbaseBaseCost = GetNumberSetting(settings, "AirbaseBaseCost", 350);
    local airbaseMaxLevel = GetNumberSetting(settings, "AirbaseMaxLevel", 3);

    local forwardAirstripsEnabled = GetBoolSetting(settings, "ForwardAirstripsEnabled", true);
    local forwardAirstripBaseCost = GetNumberSetting(settings, "ForwardAirstripBaseCost", 175);

    local samSitesEnabled = GetBoolSetting(settings, "SAMSitesEnabled", true);
    local samSiteBaseCost = GetNumberSetting(settings, "SAMSiteBaseCost", 300);
    local samSiteMaxLevel = GetNumberSetting(settings, "SAMSiteMaxLevel", 3);

    local missileSilosEnabled = GetBoolSetting(settings, "MissileSilosEnabled", true);
    local missileSiloBaseCost = GetNumberSetting(settings, "MissileSiloBaseCost", 500);
    local missileSiloMaxLevel = GetNumberSetting(settings, "MissileSiloMaxLevel", 3);

    local powerGridEnabled = GetBoolSetting(settings, "PowerGridEnabled", true);
    local powerGridBaseCost = GetNumberSetting(settings, "PowerGridBaseCost", 300);

    local airWingsEnabled = GetBoolSetting(settings, "AirWingsEnabled", true);
    local airWingBaseCost = GetNumberSetting(settings, "AirWingBaseCost", 200);
    local aircraftPerAirWing = GetNumberSetting(settings, "AircraftPerAirWing", 25);
    local airWingMaxPerPlayer = GetNumberSetting(settings, "AirWingMaxPerPlayer", 10);

    local specialForcesEnabled = GetBoolSetting(settings, "SpecialForcesEnabled", true);
    local specialForcesBaseCost = GetNumberSetting(settings, "SpecialForcesBaseCost", 180);
    local specialForcesMaxPerPlayer = GetNumberSetting(settings, "SpecialForcesMaxPerPlayer", 4);

    local uraniumDistributionMode = GetNumberSetting(settings, "UraniumDistributionMode", 1);
    local uraniumFacilityCostMultiplier = GetNumberSetting(settings, "UraniumFacilityCostMultiplier", 200);
    local startingUraniumStockpile = GetNumberSetting(settings, "StartingUraniumStockpile", 0);


    -- =====================================================
    -- SMART AI SETTINGS
    -- =====================================================

    local smartEconomicAIEnabled =
        GetBoolSetting(
            settings,
            "SmartEconomicAIEnabled",
            true
        );

    local aiBaseReservePercent =
        GetNumberSetting(
            settings,
            "AIBaseReservePercent",
            40
        );

    local aiEconomicAggressiveness =
        GetNumberSetting(
            settings,
            "AIEconomicAggressiveness",
            50
        );

    local aiWarAggressiveness =
        GetNumberSetting(
            settings,
            "AIWarAggressiveness",
            35
        );

    local aiStockParticipationEnabled =
        GetBoolSetting(
            settings,
            "AIStockParticipationEnabled",
            true
        );

    local aiETFParticipationEnabled =
        GetBoolSetting(
            settings,
            "AIETFParticipationEnabled",
            true
        );

    local aiBondParticipationEnabled =
        GetBoolSetting(
            settings,
            "AIBondParticipationEnabled",
            true
        );

    local aiTaxManagementEnabled =
        GetBoolSetting(
            settings,
            "AITaxManagementEnabled",
            true
        );

    local playerAIManagerEnabled =
        GetBoolSetting(
            settings,
            "PlayerAIManagerEnabled",
            true
        );


    -- =====================================================
    -- TITLE
    -- =====================================================

    UI.CreateLabel(root)
        .SetText(
            "GLOBAL ECONOMY & DIPLOMACY SETTINGS"
        );

    UI.CreateLabel(root)
        .SetText(
            "Configure diplomacy, trade, investments, markets, taxation, the United Nations, and AI economic behavior."
        );


    -- =====================================================
    -- GENERAL
    -- =====================================================

    AddSection(
        root,
        "GENERAL",
        "Controls the opening period and automatic economic reports."
    );

    AddNumberInput(
        root,
        "OpeningPeriodTurns",
        "Opening Period Before Full Global Economy Activates (turns)",
        openingPeriodTurns,
        0,
        3,
        "Default: 1. Players can establish their nation before all international systems become fully active."
    );

    AddCheckBox(
        root,
        "TurnReportsEnabled",
        "Show consolidated player reports at the beginning of each new turn",
        turnReportsEnabled
    );

    AddCheckBox(
        root,
        "WorldNewsEnabled",
        "Generate Global Economy world-news headlines",
        worldNewsEnabled
    );


    -- =====================================================
    -- DIPLOMACY
    -- =====================================================

    AddSection(
        root,
        "DIPLOMACY",
        "Controls formal Peace and War relationships between nations."
    );

    AddCheckBox(
        root,
        "RequireWarDeclaration",
        "Require an official declaration of war before nations may attack each other",
        requireWarDeclaration
    );

    AddCheckBox(
        root,
        "PlayersStartAtWar",
        "Start all nations at WAR instead of PEACE",
        playersStartAtWar
    );

    AddNumberInput(
        root,
        "WarDeclarationDelay",
        "War Declaration Delay (turns)",
        warDeclarationDelay,
        0,
        3,
        "Default: 1. A declaration can be announced before combat becomes legal."
    );

    AddNumberInput(
        root,
        "PeaceCooldownTurns",
        "Cooldown After Peace Before War Can Be Declared Again",
        peaceCooldownTurns,
        0,
        10,
        "Prevents repeated peace-war-peace abuse."
    );

    AddCheckBox(
        root,
        "WarEventsEnabled",
        "Enable interactive wartime national events",
        warEventsEnabled
    );

    AddNumberInput(
        root,
        "WarEventFrequencyTurns",
        "Turns Between Wartime Decision Events",
        warEventFrequencyTurns,
        1,
        10,
        "Default: 3. Human players receive strategic choices; AI nations resolve a balanced response automatically."
    );

    AddCheckBox(
        root,
        "NonAggressionPactsEnabled",
        "Enable Non-Aggression Pacts",
        nonAggressionPactsEnabled
    );

    AddCheckBox(
        root,
        "GiftWarRestrictionEnabled",
        "Block wartime Gift Card transfers that bypass official war declarations",
        giftWarRestrictionEnabled
    );

    AddCheckBox(
        root,
        "AICanDeclareWarOnHumans",
        "Allow AI nations to officially declare war on human nations",
        aiCanDeclareWarOnHumans
    );

    AddCheckBox(
        root,
        "AICanDeclareWarOnAI",
        "Allow AI nations to officially declare war on other AI nations",
        aiCanDeclareWarOnAI
    );


    -- =====================================================
    -- TRADE AGREEMENTS
    -- =====================================================

    AddSection(
        root,
        "TRADE AGREEMENTS",
        "Trade provides stable recurring Commerce-based income."
    );

    AddNumberInput(
        root,
        "MaxTradeAgreements",
        "Maximum Active Trade Agreements Per Nation",
        maxTradeAgreements,
        1,
        20,
        "Large games can raise this value. Recommended defaults may later scale automatically with game size."
    );

    AddNumberInput(
        root,
        "TradeBonusPercent",
        "Trade Income Bonus (%)",
        tradeBonusPercent,
        1,
        50,
        "Each nation receives a percentage of its trade partner's Commerce income."
    );

    AddNumberInput(
        root,
        "TradeCooldownTurns",
        "Cooldown After Rejection or Cancellation (turns)",
        tradeCooldownTurns,
        0,
        10,
        ""
    );

    AddNumberInput(
        root,
        "AIProposalChance",
        "Legacy AI Trade Proposal Activity (%)",
        aiProposalChance,
        0,
        100,
        "This setting is preserved while the new Smart AI system is being introduced."
    );

    AddNumberInput(
        root,
        "AIMinimumAgreementTurns",
        "Minimum AI Agreement Duration Before Replacement",
        aiMinimumAgreementTurns,
        0,
        15,
        ""
    );

    AddNumberInput(
        root,
        "AIReplacementPercent",
        "Required Economic Improvement Before AI Replaces Partner (%)",
        aiReplacementPercent,
        10,
        200,
        "Example: 50 means a replacement partner generally needs to be about 50% more attractive."
    );

    AddNumberInput(
        root,
        "EconomicDeclineTurns",
        "Consecutive Declining Income Turns Before AI Becomes Concerned",
        economicDeclineTurns,
        2,
        10,
        "The AI should respond to sustained economic weakness rather than one bad turn."
    );


    -- =====================================================
    -- INVESTMENTS
    -- =====================================================

    AddSection(
        root,
        "INVESTMENTS",
        "Projects provide larger potential returns but lock capital and can fail."
    );

    AddNumberInput(
        root,
        "InvestmentFundingWindow",
        "Project Funding Window (turns)",
        investmentFundingWindow,
        1,
        10,
        "Projects that fail to reach their funding goal before this deadline expire and refund committed principal."
    );

    AddCheckBox(
        root,
        "InternationalInvestorBonusEnabled",
        "Enable an international participation bonus for projects with multiple nations",
        internationalInvestorBonusEnabled
    );

    AddNumberInput(
        root,
        "InvestorSuccessBonusPercent",
        "Success Chance Bonus Per Additional Participating Nation (%)",
        investorSuccessBonusPercent,
        0,
        10,
        "Rewards multinational projects without guaranteeing success."
    );

    AddNumberInput(
        root,
        "MaxInvestorSuccessBonusPercent",
        "Maximum International Participation Success Bonus (%)",
        maxInvestorSuccessBonusPercent,
        0,
        25,
        ""
    );

    AddCheckBox(
        root,
        "AIInvestmentsEnabled",
        "Allow AI nations to invest in projects",
        aiInvestmentsEnabled
    );

    AddCheckBox(
        root,
        "AIProjectsEnabled",
        "Allow AI nations to create investment projects",
        aiProjectsEnabled
    );

    AddNumberInput(
        root,
        "AIProjectChance",
        "Legacy AI Project Creation Activity (%)",
        aiProjectChance,
        0,
        100,
        "Preserved for compatibility while project decisions are moved into Smart AI."
    );

    AddNumberInput(
        root,
        "AIInvestChance",
        "Legacy AI Investment Activity (%)",
        aiInvestChance,
        0,
        100,
        "Preserved for compatibility while investment decisions are moved into Smart AI."
    );

    AddNumberInput(
        root,
        "AIInvestmentReservePercent",
        "Legacy AI Investment Gold Reserve (%)",
        aiInvestmentReservePercent,
        10,
        90,
        "Existing investment code currently uses this value."
    );

    UI.CreateLabel(root)
        .SetText(
            "The seven existing investment categories remain available. Their risk, return, duration, and failure-recovery values will be rebalanced during the investment-engine update."
        );


    -- =====================================================
    -- MARKETS
    -- =====================================================

    AddSection(
        root,
        "MARKETS - STOCKS",
        "Players and AI can create flagship public companies and participate in the global stock market."
    );

    AddCheckBox(
        root,
        "StockMarketEnabled",
        "Enable the Stock Market",
        stockMarketEnabled
    );

    AddNumberInput(
        root,
        "MaxCompaniesPerNation",
        "Maximum Public Companies Per Nation",
        maxCompaniesPerNation,
        1,
        5,
        "Nations begin with access to one flagship company. Additional companies must be unlocked through economic progress."
    );

    AddNumberInput(
        root,
        "FounderSharePercent",
        "Founder Starting Ownership (%)",
        founderSharePercent,
        5,
        50,
        "Founder shares give nations an incentive to strengthen their own economy and company."
    );

    AddNumberInput(
        root,
        "StockVolatilityPercent",
        "Base Stock Market Volatility (%)",
        stockVolatilityPercent,
        1,
        30,
        "Higher values create larger normal stock-price movements."
    );

    AddCheckBox(
        root,
        "DividendsEnabled",
        "Enable stock dividends",
        dividendsEnabled
    );

    AddNumberInput(
        root,
        "DividendFrequencyTurns",
        "Dividend Payment Frequency (turns)",
        dividendFrequencyTurns,
        1,
        10,
        "Growth, Balanced, and Dividend companies will use different dividend behavior."
    );


    -- =====================================================
    -- ETF
    -- =====================================================

    AddSection(
        root,
        "MARKETS - ETF",
        "The global ETF automatically tracks the strongest eligible public companies."
    );

    AddCheckBox(
        root,
        "ETFEnabled",
        "Enable the Global ETF",
        etfEnabled
    );

    AddNumberInput(
        root,
        "ETFSize",
        "Number of Companies in the Global ETF",
        etfSize,
        3,
        10,
        "Default: Top 5. The ETF automatically rebalances when company rankings change."
    );

    AddNumberInput(
        root,
        "ETFMembershipBonusPercent",
        "ETF Membership Market Confidence Bonus (%)",
        etfMembershipBonusPercent,
        0,
        5,
        "Provides a small competitive reward for qualifying without making leading companies unstoppable."
    );

    AddCheckBox(
        root,
        "ETFLoyaltyBonusEnabled",
        "Enable additional prestige for companies that remain in the ETF for consecutive turns",
        etfLoyaltyBonusEnabled
    );


    -- =====================================================
    -- BONDS
    -- =====================================================

    AddSection(
        root,
        "MARKETS - BONDS",
        "Bonds provide more predictable returns but expose investors to credit and default risk."
    );

    AddCheckBox(
        root,
        "BondsEnabled",
        "Enable nation-issued bonds",
        bondsEnabled
    );

    AddNumberInput(
        root,
        "MinimumBondDuration",
        "Minimum Bond Maturity (turns)",
        minimumBondDuration,
        1,
        10,
        ""
    );

    AddNumberInput(
        root,
        "MaximumBondDuration",
        "Maximum Bond Maturity (turns)",
        maximumBondDuration,
        2,
        20,
        "Lower-rated nations may need to offer higher yields to attract investors."
    );


    -- =====================================================
    -- TAXATION
    -- =====================================================

    AddSection(
        root,
        "TAXATION",
        "Taxation converts domestic city-based economic development into government revenue while creating a growth tradeoff."
    );

    AddCheckBox(
        root,
        "TaxationEnabled",
        "Enable domestic taxation",
        taxationEnabled
    );

    AddNumberInput(
        root,
        "TaxChangeCooldownTurns",
        "Tax Policy Change Cooldown (turns)",
        taxChangeCooldownTurns,
        0,
        10,
        "Prevents players from repeatedly changing tax policy to exploit turn timing."
    );

    UI.CreateLabel(root)
        .SetText(
            "Planned policies: Low, Standard, High, and Emergency taxation. Higher taxation provides greater immediate revenue but creates stronger economic and market penalties."
        );


    -- =====================================================
    -- UNITED NATIONS
    -- =====================================================

    AddSection(
        root,
        "UNITED NATIONS",
        "The UN manages international resolutions, sanctions, aid, Public Enemy status, and leadership."
    );

    AddCheckBox(
        root,
        "UnitedNationsEnabled",
        "Enable the United Nations",
        unitedNationsEnabled
    );

    AddNumberInput(
        root,
        "UnitedNationsStartTurn",
        "Turn the United Nations Becomes Active",
        unitedNationsStartTurn,
        1,
        10,
        ""
    );

    AddNumberInput(
        root,
        "UNVoteDurationTurns",
        "UN Voting Duration (turns)",
        unVoteDurationTurns,
        1,
        10,
        ""
    );

    AddNumberInput(
        root,
        "UNPassRequirementPercent",
        "UN Resolution YES Vote Requirement (%)",
        unPassRequirementPercent,
        50,
        100,
        "Default: 60%. Only eligible, non-eliminated nations count toward voting."
    );

    AddNumberInput(
        root,
        "UNProposalCooldownTurns",
        "UN Proposal Cooldown (turns)",
        unProposalCooldownTurns,
        0,
        10,
        ""
    );

    AddNumberInput(
        root,
        "UNMaximumActiveResolutions",
        "Maximum Simultaneous Active UN Resolutions",
        unMaximumActiveResolutions,
        1,
        10,
        ""
    );

    AddNumberInput(root, "UNSanctionMinTurns", "Sanctions Minimum Duration (turns)", unSanctionMinTurns, 1, 20, "Players may choose a sanction duration, but not below this value.");
    AddNumberInput(root, "UNSanctionMaxTurns", "Sanctions Maximum Duration (turns)", unSanctionMaxTurns, 1, 20, "Hard cap so sanctions cannot be made excessive.");
    AddNumberInput(root, "UNCeasefireMinTurns", "Ceasefire Minimum Duration (turns)", unCeasefireMinTurns, 1, 20, "Passed ceasefires block a new war declaration for at least this many turns.");
    AddNumberInput(root, "UNCeasefireMaxTurns", "Ceasefire Maximum Duration (turns)", unCeasefireMaxTurns, 1, 20, "Hard cap on proposer-selected UN ceasefires.");

    AddCheckBox(
        root,
        "AICanProposeUNResolutions",
        "Allow AI nations to propose UN resolutions",
        aiCanProposeUNResolutions
    );

    AddCheckBox(
        root,
        "PublicEnemyEnabled",
        "Enable Public Enemy designation and consequences",
        publicEnemyEnabled
    );

    AddCheckBox(
        root,
        "UNLeadershipEnabled",
        "Enable UN Chair, Vice Chair, elections, and leadership succession",
        unLeadershipEnabled
    );

    AddNumberInput(
        root,
        "UNPermanentSeatCount",
        "Permanent Security Council Seats",
        unPermanentSeatCount,
        1,
        10,
        "Default: 5. Permanent members can veto Security Council resolutions by voting NO."
    );

    AddNumberInput(
        root,
        "UNRotatingSeatCount",
        "Rotating Security Council Seats",
        unRotatingSeatCount,
        0,
        50,
        "Default: 10. Rotating members vote but do not have veto power."
    );

    AddNumberInput(
        root,
        "UNReplacementMode",
        "Permanent Seat Replacement Mode (1-3)",
        unReplacementMode,
        1,
        3,
        "1 = next-highest eligible power, 2 = Security Council replacement vote, 3 = configured slot priority / then next-highest."
    );

    UI.CreateLabel(root)
        .SetText(
            "OPTIONAL PERMANENT SEAT SLOT OVERRIDES\nEnter a player slot number for a permanent seat, or 0 to let the mod auto-select that seat. Slots are based on the sorted active player list used by the scenario."
        );

    AddNumberInput(root, "UNPermanentSeatSlot1", "Permanent Seat 1 Slot (0 = Auto)", unPermanentSeatSlot1, 0, 400, "");
    AddNumberInput(root, "UNPermanentSeatSlot2", "Permanent Seat 2 Slot (0 = Auto)", unPermanentSeatSlot2, 0, 400, "");
    AddNumberInput(root, "UNPermanentSeatSlot3", "Permanent Seat 3 Slot (0 = Auto)", unPermanentSeatSlot3, 0, 400, "");
    AddNumberInput(root, "UNPermanentSeatSlot4", "Permanent Seat 4 Slot (0 = Auto)", unPermanentSeatSlot4, 0, 400, "");
    AddNumberInput(root, "UNPermanentSeatSlot5", "Permanent Seat 5 Slot (0 = Auto)", unPermanentSeatSlot5, 0, 400, "");

    UI.CreateLabel(root)
        .SetText(
            "Initial V3 UN resolutions: Sanctions, Embargo, Aid, Condemnation, and Ceasefire. Only Security Council members vote. Permanent members have veto power."
        );


    AddSection(root, "ARMY RECRUITERS");

    AddCheckBox(root, "ArmyRecruitersEnabled", "Enable Army Recruiters", armyRecruitersEnabled);
    AddNumberInput(root, "ArmyRecruiterBaseCost", "Army Recruiter Base Cost (Commerce)", armyRecruiterBaseCost, 25, 2000, "Commerce is deducted immediately when a recruiter is built or upgraded.");
    AddNumberInput(root, "ArmyRecruiterMaxPerPlayer", "Maximum Recruiter Territories per Player", armyRecruiterMaxPerPlayer, 1, 10, "Captured recruiters can put a nation above this limit, but it cannot build another until below the limit.");
    AddNumberInput(root, "ArmyRecruiterArmiesPerTurn", "Base Armies per Recruiter Level / Turn", armyRecruiterArmiesPerTurn, 1, 25, "Actual output is multiplied by Military Readiness.");
    AddNumberInput(root, "ArmyRecruiterMaxLevel", "Maximum Recruiter Level", armyRecruiterMaxLevel, 1, 5, "Upgrades increase army output and strategic resource maintenance demand.");


    AddSection(root, "MILITARY & STRATEGIC SYSTEMS", "Core host controls for United Frontier military infrastructure, visible map assets, Air Wings, Special Forces, Headquarters intelligence, and strategic readiness.");

    AddCheckBox(root, "MilitaryExpansionEnabled", "Enable United Frontier Military Systems", militaryExpansionEnabled);
    AddCheckBox(root, "HiddenMilitaryInfrastructureEnabled", "Protect Military Asset Details Behind Intelligence", hiddenMilitaryInfrastructureEnabled);

    AddCheckBox(root, "HeadquartersEnabled", "Enable Headquarters", headquartersEnabled);
    AddNumberInput(root, "HeadquartersBaseCost", "Headquarters Base Cost (Commerce)", headquartersBaseCost, 50, 5000, "One national HQ. Intelligence, Security, Cyber Warfare, and Joint Command live inside it.");
    AddNumberInput(root, "HeadquartersMaxBranchLevel", "Maximum HQ Branch Level", math.min(5, headquartersMaxBranchLevel), 1, 5, "Applies to Intelligence, Security, Cyber Warfare, and Joint Command. United Frontier currently supports five meaningful levels per branch.");

    AddCheckBox(root, "AirbasesEnabled", "Enable Airbases", airbasesEnabled);
    AddNumberInput(root, "AirbaseBaseCost", "Airbase Base Cost (Commerce)", airbaseBaseCost, 25, 5000, "One icon per territory. Upgrading changes the same structure rather than adding another icon.");
    AddNumberInput(root, "AirbaseMaxLevel", "Airbase Maximum Level", airbaseMaxLevel, 1, 5, "Recommended default: 3 visual levels.");

    AddCheckBox(root, "ForwardAirstripsEnabled", "Enable Forward Airstrips", forwardAirstripsEnabled);
    AddNumberInput(root, "ForwardAirstripBaseCost", "Forward Airstrip Cost (Commerce)", forwardAirstripBaseCost, 25, 3000, "Cheaper limited-capacity airfield intended for forward areas.");

    AddCheckBox(root, "SAMSitesEnabled", "Enable SAM Sites", samSitesEnabled);
    AddNumberInput(root, "SAMSiteBaseCost", "SAM Site Base Cost (Commerce)", samSiteBaseCost, 25, 5000, "Air and strategic-defense system.");
    AddNumberInput(root, "SAMSiteMaxLevel", "SAM Site Maximum Level", samSiteMaxLevel, 1, 5, "Higher SAM levels prepare stronger air/strategic defense; detailed interception effects are documented in How It Works.");

    AddCheckBox(root, "MissileSilosEnabled", "Enable Missile Silos", missileSilosEnabled);
    AddNumberInput(root, "MissileSiloBaseCost", "Missile Silo Base Cost (Commerce)", missileSiloBaseCost, 50, 10000, "Missile Silos are visible strategic assets designed for limited missile inventory, reloads, and strategic strike orders.");
    AddNumberInput(root, "MissileSiloMaxLevel", "Missile Silo Maximum Level", missileSiloMaxLevel, 1, 5, "Recommended default: 3 visual levels.");

    AddCheckBox(root, "PowerGridEnabled", "Enable Power Grid", powerGridEnabled);
    AddNumberInput(root, "PowerGridBaseCost", "Power Grid Cost (Commerce)", powerGridBaseCost, 25, 5000, "Power Grid structures are intended to remain publicly visible.");

    AddCheckBox(root, "AirWingsEnabled", "Enable Air Wings", airWingsEnabled);
    AddNumberInput(root, "AirWingBaseCost", "Air Wing Cost (Commerce)", airWingBaseCost, 25, 5000, "Air Wings are visible custom military units. Purchasing requires capacity at an owned Airbase.");
    AddNumberInput(root, "AircraftPerAirWing", "Aircraft Represented per Air Wing", aircraftPerAirWing, 1, 500, "Display scale only; example: one small Air Wing icon can represent 25 aircraft.");
    AddNumberInput(root, "AirWingMaxPerPlayer", "Maximum Air Wings per Player", airWingMaxPerPlayer, 1, 100, "Host-configurable national limit.");

    AddCheckBox(root, "SpecialForcesEnabled", "Enable Special Forces Infantry", specialForcesEnabled);
    AddNumberInput(root, "SpecialForcesBaseCost", "Special Forces Cost (Commerce)", specialForcesBaseCost, 25, 5000, "Elite unit for reconnaissance, raids, sabotage, and strategic missions.");
    AddNumberInput(root, "SpecialForcesMaxPerPlayer", "Maximum Special Forces Units per Player", specialForcesMaxPerPlayer, 1, 25, "Keeps Special Forces elite rather than replacing normal armies.");

    AddSection(root, "URANIUM STRATEGY", "Uranium is intentionally rarer and more expensive than ordinary resources. Players do not automatically receive Uranium based on Commerce or income.");
    AddNumberInput(root, "UraniumDistributionMode", "Uranium Distribution (0=None, 1=Very Rare, 2=Rare, 3=Moderate, 4=Common, 5=Manual)", uraniumDistributionMode, 0, 5, "Distribution logic will be applied during the resource-generation upgrade phase.");
    AddNumberInput(root, "UraniumFacilityCostMultiplier", "Uranium Facility Cost (% of normal resource facility)", uraniumFacilityCostMultiplier, 100, 500, "Default 200% makes Uranium the most expensive resource facility.");
    AddNumberInput(root, "StartingUraniumStockpile", "Starting Uranium Stockpile", startingUraniumStockpile, 0, 1000, "Default 0. Uranium is not automatically granted based on national income.");

    -- =====================================================
    -- SMART AI
    -- =====================================================

    AddSection(
        root,
        "SMART AI",
        "AI nations should make connected military, economic, diplomatic, and financial decisions instead of acting through isolated random choices."
    );

    AddCheckBox(
        root,
        "SmartEconomicAIEnabled",
        "Enable Smart Economic & Diplomatic AI",
        smartEconomicAIEnabled
    );

    AddNumberInput(
        root,
        "AIBaseReservePercent",
        "AI Base Treasury Reserve (%)",
        aiBaseReservePercent,
        10,
        90,
        "This becomes a baseline rather than a hard reserve. AI will dynamically raise or lower reserves based on war, threats, obligations, and opportunities."
    );

    AddNumberInput(
        root,
        "AIEconomicAggressiveness",
        "AI Economic Aggressiveness",
        aiEconomicAggressiveness,
        0,
        100,
        "Higher values make AI more willing to pursue economic growth and financial opportunities when financially safe."
    );

    AddNumberInput(
        root,
        "AIWarAggressiveness",
        "AI War Aggressiveness",
        aiWarAggressiveness,
        0,
        100,
        "This affects willingness to consider war. AI should still evaluate military strength, economic cost, current wars, trade relationships, and UN consequences."
    );

    AddCheckBox(
        root,
        "AIStockParticipationEnabled",
        "Allow Smart AI to buy and sell individual stocks",
        aiStockParticipationEnabled
    );

    AddCheckBox(
        root,
        "AIETFParticipationEnabled",
        "Allow Smart AI to invest in the ETF",
        aiETFParticipationEnabled
    );

    AddCheckBox(
        root,
        "AIBondParticipationEnabled",
        "Allow Smart AI to issue and purchase bonds",
        aiBondParticipationEnabled
    );

    AddCheckBox(
        root,
        "AITaxManagementEnabled",
        "Allow Smart AI to dynamically manage taxation",
        aiTaxManagementEnabled
    );


    AddSection(
        root,
        "STRATEGIC RESOURCES",
        "Territory resources produce each turn, can be traded between nations, and influence Commerce / military mobilization. Realistic mode assigns resource strengths from the nation slot profile; randomized mode keeps the same strengths but randomizes which owned territories receive them."
    );

    AddCheckBox(
        root,
        "ResourcesEnabled",
        "Enable Strategic Resources",
        resourcesEnabled
    );

    AddCheckBox(
        root,
        "RandomizedResourcePlacement",
        "Randomize resource territory placement",
        randomizedResourcePlacement
    );

    AddCheckBox(
        root,
        "AdvancedResourcesEnabled",
        "Enable advanced resources (Coal, Copper, Lithium)",
        advancedResourcesEnabled
    );

    AddCheckBox(
        root,
        "ResourceTradingEnabled",
        "Allow direct recurring resource trade contracts",
        resourceTradingEnabled
    );

    AddNumberInput(
        root,
        "ResourceFacilityBaseCost",
        "Base Resource Facility Cost (gold)",
        resourceFacilityBaseCost,
        25,
        1000,
        "Developing an existing resource deposit costs this amount multiplied by the new facility level."
    );

    AddNumberInput(
        root,
        "ResourceFacilityMaxLevel",
        "Maximum Facility Level",
        resourceFacilityMaxLevel,
        1,
        5,
        "Hard cap for each resource facility. The map icon changes with the facility level instead of adding another icon."
    );

    AddNumberInput(
        root,
        "ResourceShortagePenaltyPercent",
        "Shortage Penalty per Essential Resource (%)",
        resourceShortagePenaltyPercent,
        0,
        10,
        "Oil, Food, Iron and Gas shortages reduce usable Commerce and therefore military spending power. Total resource penalty is capped for performance and balance."
    );

    AddCheckBox(
        root,
        "ResourceUnrestEnabled",
        "Allow sustained shortages to create national unrest",
        resourceUnrestEnabled
    );

    AddCheckBox(
        root,
        "ResourceMapIconsEnabled",
        "Enable Resource Location Intelligence",
        resourceMapIconsEnabled
    );

    UI.CreateLabel(root)
        .SetText(
            "Resource deposits are not exposed as global map structures. Players learn locations through ownership, direct borders, faction/shared intelligence, or Headquarters Intelligence. The Resources tab provides private filters and Show-on-Map highlighting."
        );


    AddSection(
        root,
        "PLAYER AI MANAGER",
        "Optional automation for human players. It reserves a player-set Commerce budget each turn and can allocate it across Markets, Investments, Strategic Resources, Recruiters, and military development. Diplomacy, ideology, taxation, and direct combat orders remain player-controlled."
    );

    AddCheckBox(
        root,
        "PlayerAIManagerEnabled",
        "Allow human players to enable the AI Manager",
        playerAIManagerEnabled
    );


    -- =====================================================
    -- PLAYER START / IDEOLOGY INFORMATION
    -- =====================================================

    AddSection(
        root,
        "TURN 1 NATIONAL SETUP",
        "Each active nation will complete a National Setup at the beginning of the game."
    );

    UI.CreateLabel(root)
        .SetText(
            "Planned Turn 1 choices:\n\n" ..
            "- Ideology\n" ..
            "- Economic Strategy\n" ..
            "- Starting Tax Policy\n" ..
            "- Flagship Company Name\n" ..
            "- Company Strategy: Growth / Balanced / Dividend\n" ..
            "- Diplomacy Rules Confirmation\n\n" ..
            "Players are not forced to buy stocks, invest, issue bonds, sign trade agreements, or declare war during Turn 1."
        );


    -- =====================================================
    -- ELIMINATION RULE
    -- =====================================================

    AddSection(
        root,
        "ELIMINATION",
        "Eliminated human and AI nations are automatically removed from the economic and diplomatic systems."
    );

    UI.CreateLabel(root)
        .SetText(
            "Eliminated nations cannot trade, invest, create companies, buy stocks or ETFs, issue or buy bonds, vote in the UN, or use diplomacy. Existing positions will be settled according to each system's elimination rules."
        );


    -- =====================================================
    -- SUMMARY
    -- =====================================================

    AddSection(
        root,
        "DEFAULT GLOBAL ECONOMY",
        "Recommended starting configuration."
    );

    UI.CreateLabel(root)
        .SetText(
            "Opening Period: 1 turn\n" ..
            "War Declaration Required: Yes\n" ..
            "War Declaration Delay: 1 turn\n" ..
            "Maximum Trade Agreements: 3\n" ..
            "Trade Income Bonus: 10%\n" ..
            "Investment Funding Window: 3 turns\n" ..
            "International Investor Bonus: Enabled\n" ..
            "Stock Market: Enabled\n" ..
            "Maximum Companies Per Nation: 3\n" ..
            "Founder Ownership: 20%\n" ..
            "Dividends: Enabled / every 3 turns\n" ..
            "Global ETF: Top 5\n" ..
            "ETF Membership Bonus: 3%\n" ..
            "Bonds: Enabled\n" ..
            "Taxation: Enabled\n" ..
            "United Nations: Enabled\n" ..
            "UN Passage Requirement: 60%\n" ..
            "Public Enemy System: Enabled\n" ..
            "Smart AI: Enabled\n" ..
            "AI Base Reserve: 40%"
        );

    AddDivider(root);

    UI.CreateLabel(root)
        .SetText(
            "This configuration screen establishes the Version 1 foundation. Individual economic formulas and project balance values will be finalized as each server system is rebuilt."
        );

end