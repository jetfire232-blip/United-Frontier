-- Shared conventional military rules. Imported independently by each server hook.
function UFReleaseAIManagerFunding(data,resourceChanges)
    local economy=data.globalEconomy or {};
    for playerID,nation in pairs(economy.nations or {}) do
        local reserved=math.max(0,math.floor(tonumber(nation.aiManagerOneTimeEscrow) or 0));
        if reserved>0 then
            resourceChanges[playerID]=(resourceChanges[playerID] or 0)+reserved;
            nation.aiManagerOneTimeEscrow=0;
            if (Mod.Settings or {}).PlayerAIManagerEnabled==false or nation.aiManagerEnabled~=true
                or (nation.aiManagerCancelTurn and (economy.currentEconomyTurn or data.tradeTurn or 1)>=nation.aiManagerCancelTurn) then
                nation.aiManagerOneTimeBudget=0;
            end
        end
    end
end

local function setting(key,default)
    local value=(Mod.Settings or {})[key]; if value==nil then return default; end; return value;
end

UFConventionalUnitConfig={
    Tank={name="Tank Battalion",tableName="tanks",pending="pendingTanks",enabled="TanksEnabled",costKey="TankBaseCost",cost=300,strengthKey="TankCombatStrength",strength=8,maxKey="TankMaxPerPlayer",max=10,oil=1,iron=1,image="Tank.png",order=3383},
    Drone={tableName="drones",pending="pendingDrones",enabled="DronesEnabled",costKey="DroneBaseCost",cost=150,strengthKey="DroneCombatStrength",strength=2,maxKey="DroneMaxPerPlayer",max=10,oil=1,iron=0,image="Drone.png",order=3382}
};

function UFRetiredAction(payload)
    if payload.resource=="Uranium" then return true; end
    if payload.type=="requestHeadquartersSharing" or payload.type=="respondHeadquartersSharing" then return true; end
    local retired={upgradeAgencyCapability=true,quoteAgencyOperation=true,launchIntelligenceOperation=true,launchFinancialEspionage=true,launchAgencyCyberOperation=true,counterIntelResponse=true,shareIntelReport=true,hqCyberDisrupt=true,hqResourceScan=true,hqMilitaryScan=true,resupplyMissile=true,launchMissile=true,buildHeadquarters=true,upgradeHeadquartersBranch=true};
    if retired[payload.type] then return true; end
    return (payload.type=="buildStrategicMilitary" or payload.type=="repairMilitaryAsset") and payload.kind~="Airbase";
end

local retiredFields={"headquarters","samSites","missileSilos","powerGrids","forwardAirstrips","cyberFacilities","missileInventory","interceptorInventory","pendingStrategicStrikes","pendingAirMissions","airMissionUsedTurn","intelligenceOperationsLevel","cyberOperationsLevel","counterIntelligenceLevel","intelligenceReports","counterIntelAlerts","strategicWarnings","lastAgencyOperationTurn","lastAgencyTargetTurn","lastCyberOperationTurn","hqRecentResults","disruptions","cityDamage"};

function UFConventionalMigration(game,pd,pgd,data,deferSave)
    pd=pd or Mod.PrivateGameData or {};
    pd.strategicMilitary=pd.strategicMilitary or {byPlayer={}};
    local military=pd.strategicMilitary; military.byPlayer=military.byPlayer or {};
    military.pendingCovertOps=nil; military.nextCovertOpID=nil;
    pgd=pgd or Mod.PlayerGameData or {};
    for playerID,state in pairs(military.byPlayer) do
        for _,field in ipairs(retiredFields) do state[field]=nil; end
        state.airbases=state.airbases or {};
        state.airWings=state.airWings or {}; state.specialForces=state.specialForces or {};
        state.tanks=state.tanks or {}; state.drones=state.drones or {};
        state.pendingTanks=state.pendingTanks or {}; state.pendingDrones=state.pendingDrones or {};
        if state.conventionalVersion~=15 then
            -- Old covert discoveries have no reliable provenance. Rebuild known
            -- locations through current ownership/borders/accepted sharing.
            state.discoveredMilitary={}; state.discoveredResourceTerritories={};
            state.assetCondition={}; state.conventionalVersion=15;
            pgd[playerID]=pgd[playerID] or {}; pgd[playerID].strategicIntel={knownResources={},knownMilitary={}};
        end
        pgd[playerID]=pgd[playerID] or {}; pgd[playerID].ownMilitary=state;
        pgd[playerID].strategicIntel=pgd[playerID].strategicIntel or {};
        pgd[playerID].strategicIntel.knownResources={};
    end
    data=data or Mod.PublicGameData or {};
    for _,nation in pairs((data.globalEconomy or {}).nations or {}) do
        if nation.military then
            for _,field in ipairs({"headquartersStatus","headquartersLevel","headquartersTerritoryID","headquartersBranches","samSiteCount","missileSiloCount","powerGridCount","forwardAirstripCount","jointStrategicWarningEnabled"}) do nation.military[field]=nil; end
        end
        nation.aiLastMissileOrder=nil;
        for _,field in ipairs({"resourceStockpile","resourceProduction","resourceEffective","resourceRequirements","resourceShortages","resourceStockpileChange"}) do if type(nation[field])=="table" then nation[field].Uranium=nil;end end
    end
    local diplomacy=(data.globalEconomy or {}).diplomacy or {};
    for _,alliance in pairs(diplomacy.alliances or {}) do alliance.jointStrategicWarning=nil;alliance.sharedIntelligence=nil;end
    diplomacy.pendingHeadquartersShareRequests={};
    local resources=(data.globalEconomy or {}).resources;
    if resources then
        for _,nodes in pairs(resources.territories or {}) do nodes.Uranium=nil;end
        for _,field in ipairs({"pendingBuilds","pendingOffers","activeTrades"})do
            local list=resources[field] or {};
            for i=#list,1,-1 do
                local item=list[i];
                if item.resource=="Uranium" then
                    if field=="pendingBuilds" and item.paid==true and (tonumber(item.cost) or 0)>0 then
                        local server=game.ServerGame;
                        if server and server.SetPlayerResource and server.LatestTurnStanding and server.LatestTurnStanding.NumResources then
                            local current=server.LatestTurnStanding.NumResources(item.playerID,WL.ResourceType.Gold);
                            server.SetPlayerResource(item.playerID,WL.ResourceType.Gold,current+item.cost);
                        end
                        local nation=((data.globalEconomy or {}).nations or {})[item.playerID];
                        if nation then nation.resourceBuildReservedGold=math.max(0,(tonumber(nation.resourceBuildReservedGold) or 0)-(tonumber(item.cost) or 0));end
                    end
                    table.remove(list,i);
                end
            end
        end
    end
    UFPublishResourceCatalog(game,data);
    if deferSave~=true then
        Mod.PrivateGameData=pd; Mod.PlayerGameData=pgd; Mod.PublicGameData=data;
    end
    return pd,pgd,data;
end

function UFPublishResourceCatalog(game,data)
    local resources=(data.globalEconomy or {}).resources;if not resources then return;end
    resources.owners=resources.owners or {};
    local standing=game.ServerGame and game.ServerGame.LatestTurnStanding;if not standing then return;end
    for tid,nodes in pairs(resources.territories or {}) do
        nodes.Uranium=nil;local id=tonumber(tid) or tid;local terr=standing.Territories[id];
        if terr then resources.owners[tid]=terr.OwnerPlayerID;resources.owners[id]=terr.OwnerPlayerID;end
    end
end

-- Bound resource queues so repeated requests cannot grow a save indefinitely.
function UFResourceOfferAllowed(resources,playerID,targetID,resource,kind)
    local pending=resources.pendingOffers or {};local count=0;
    if #pending>=400 then return false,"The resource offer queue is full. Resolve existing offers first.";end
    for _,offer in ipairs(pending)do
        if offer.fromPlayerID==playerID then count=count+1;end
        if offer.fromPlayerID==playerID and offer.toPlayerID==targetID and offer.resource==resource and tostring(offer.kind or "offer")==kind then
            return false,"You already have a pending offer/request for this resource and partner.";
        end
    end
    if count>=20 then return false,"Resolve your pending resource offers before sending more (maximum 20).";end
    return true;
end

function UFResourceContractAllowed(resources,offer)
    local trades=resources.activeTrades or {};if #trades>=512 then return false,"The resource contract limit has been reached. End an existing contract first.";end
    local seller=offer.kind=="request" and offer.toPlayerID or offer.fromPlayerID;
    local buyer=offer.kind=="request" and offer.fromPlayerID or offer.toPlayerID;
    local sellerCount,buyerCount=0,0;
    for _,trade in ipairs(trades)do
        if trade.fromPlayerID==seller or trade.toPlayerID==seller then sellerCount=sellerCount+1;end
        if trade.fromPlayerID==buyer or trade.toPlayerID==buyer then buyerCount=buyerCount+1;end
        if trade.fromPlayerID==seller and trade.toPlayerID==buyer and trade.resource==offer.resource then return false,"An active contract already supplies this resource between these nations. Cancel it before replacing it.";end
    end
    if sellerCount>=64 or buyerCount>=64 then return false,"A nation has reached its limit of 64 active resource contracts.";end
    return true;
end

local function liveCount(game,playerID,name)
    local total=0;
    for _,terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
        for _,unit in ipairs((terr.NumArmies or {}).SpecialUnits or {}) do
            if unit.proxyType=="CustomSpecialUnit" and unit.Name==name and unit.OwnerID==playerID then total=total+1; end
        end
    end
    return total;
end

function UFQueueConventionalUnit(game,data,playerID,state,kind,territoryID,canSpend,spend)
    local cfg=UFConventionalUnitConfig[kind];
    if cfg==nil or setting("MilitaryExpansionEnabled",true)~=true or setting(cfg.enabled,true)~=true then return false,"This unit is disabled by the host."; end
    local standing=game.ServerGame and game.ServerGame.LatestTurnStanding;
    local terr=standing and standing.Territories and standing.Territories[territoryID];
    if terr==nil or terr.OwnerPlayerID~=playerID then return false,"Select a territory you currently own."; end
    if kind=="Drone" then
        local base=setting("AirbasesEnabled",true)==true and (tonumber((state.airbases or {})[territoryID] or (state.airbases or {})[tostring(territoryID)]) or 0)>0;
        if not base then return false,"Deploy Drones at an owned Airport."; end
    end
    local total=liveCount(game,playerID,cfg.name or kind);
    state[cfg.pending]=state[cfg.pending] or {};
    for _,count in pairs(state[cfg.pending]) do total=total+(tonumber(count) or 0); end
    local max=math.max(1,math.min(100,math.floor(tonumber(setting(cfg.maxKey,cfg.max)) or cfg.max)));
    if total>=max then return false,"Your national limit is "..tostring(max).." "..kind.." units."; end
    local cost=math.max(25,math.min(5000,math.floor(tonumber(setting(cfg.costKey,cfg.cost)) or cfg.cost)));
    if not canSpend(cost) then return false,"You need "..tostring(cost).." Commerce."; end
    local nation=((data.globalEconomy or {}).nations or {})[playerID];
    if nation==nil then return false,"Complete National Setup first."; end
    nation.resourceStockpile=nation.resourceStockpile or {}; local stock=nation.resourceStockpile;
    if (tonumber(stock.Oil) or 0)<cfg.oil or (tonumber(stock.Iron) or 0)<cfg.iron then return false,kind.." requires "..tostring(cfg.oil).." Oil"..(cfg.iron>0 and (" + "..tostring(cfg.iron).." Iron") or "").." in your stockpile."; end
    spend(cost); stock.Oil=(tonumber(stock.Oil) or 0)-cfg.oil;
    if cfg.iron>0 then stock.Iron=(tonumber(stock.Iron) or 0)-cfg.iron; end
    state[cfg.pending][territoryID]=(tonumber(state[cfg.pending][territoryID]) or 0)+1;
    local strength=math.max(1,math.min(50,math.floor(tonumber(setting(cfg.strengthKey,cfg.strength)) or cfg.strength)));
    return true,kind.." ordered: "..tostring(cost).." Commerce + "..tostring(cfg.oil).." Oil"..(cfg.iron>0 and (" + "..tostring(cfg.iron).." Iron") or "").." paid. Combat strength "..tostring(strength)..". Appears when the turn advances.";
end

function UFBuildConventionalUnit(ownerID,kind)
    local cfg=UFConventionalUnitConfig[kind]; local b=WL.CustomSpecialUnitBuilder.Create(ownerID);
    local strength=math.max(1,math.min(50,math.floor(tonumber(setting(cfg.strengthKey,cfg.strength)) or cfg.strength)));
    b.Name=cfg.name or kind; b.IncludeABeforeName=true; b.ImageFilename=cfg.image;
    b.AttackPower=strength; b.DefensePower=strength; b.DamageToKill=strength; b.DamageAbsorbedWhenAttacked=strength; b.CombatOrder=cfg.order;
    b.CanBeGiftedWithGiftCard=false; b.CanBeTransferredToTeammate=false;
    b.CanBeAirliftedToSelf=true; b.CanBeAirliftedToTeammate=false; b.IsVisibleToAllPlayers=false;
    return b.Build();
end

function UFRefreshConventionalUnits(game,addNewOrder)
    local standing=game.ServerGame and game.ServerGame.LatestTurnStanding; if not standing then return; end
    local pd=UF_ADVANCE_TURN_PRIVATE_DATA_CACHE or Mod.PrivateGameData or {}; local byPlayer=(pd.strategicMilitary or {}).byPlayer or {}; local pgd=UF_ADVANCE_TURN_PLAYER_DATA_CACHE or Mod.PlayerGameData or {};
    local add={};
    -- Count both unit types for every owner in a single standing scan.
    local actualByOwner={};
    local kindByName={};
    for kind,cfg in pairs(UFConventionalUnitConfig) do kindByName[cfg.name or kind]=kind;end
    for tid,terr in pairs(standing.Territories) do
        for _,unit in ipairs((terr.NumArmies or {}).SpecialUnits or {}) do
            local kind=unit.proxyType=="CustomSpecialUnit" and kindByName[unit.Name];
            if kind and byPlayer[unit.OwnerID] then
                local owner=unit.OwnerID;
                actualByOwner[owner]=actualByOwner[owner] or {};
                actualByOwner[owner][kind]=actualByOwner[owner][kind] or {};
                local counts=actualByOwner[owner][kind];counts[tid]=(counts[tid] or 0)+1;
            end
        end
    end
    for playerID,state in pairs(byPlayer) do
        for kind,cfg in pairs(UFConventionalUnitConfig) do
            local actual=(actualByOwner[playerID] or {})[kind] or {};
            for tid,count in pairs(state[cfg.pending] or {}) do
                tid=tonumber(tid) or tid; local terr=standing.Territories[tid];
                if terr and terr.OwnerPlayerID==playerID then
                    add[tid]=add[tid] or {};
                    for _=1,math.max(0,math.floor(tonumber(count) or 0)) do table.insert(add[tid],UFBuildConventionalUnit(playerID,kind)); actual[tid]=(actual[tid] or 0)+1; end
                end
            end
            state[cfg.tableName]=actual; state[cfg.pending]={};
        end
        pgd[playerID]=pgd[playerID] or {}; pgd[playerID].ownMilitary=state;
    end
    local mods={}; for tid,units in pairs(add) do local tm=WL.TerritoryModification.Create(tid); tm.AddSpecialUnits=units; table.insert(mods,tm); end
    if #mods>0 then addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral,"United Frontier Tanks and Drones deployed",{},mods,nil,nil)); end
    if UF_ADVANCE_TURN_PRIVATE_DATA_CACHE==nil then Mod.PrivateGameData=pd; end
    if UF_ADVANCE_TURN_PLAYER_DATA_CACHE==nil then Mod.PlayerGameData=pgd; end
end
