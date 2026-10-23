-- Shared conventional military rules. Imported independently by each server hook.
local function setting(key,default)
    local value=(Mod.Settings or {})[key]; if value==nil then return default; end; return value;
end

UFConventionalUnitConfig={
    Tank={name="Tank Battalion",tableName="tanks",pending="pendingTanks",enabled="TanksEnabled",costKey="TankBaseCost",cost=300,strengthKey="TankCombatStrength",strength=8,maxKey="TankMaxPerPlayer",max=10,oil=1,iron=1,image="Tank.png",order=3383},
    Drone={tableName="drones",pending="pendingDrones",enabled="DronesEnabled",costKey="DroneBaseCost",cost=150,strengthKey="DroneCombatStrength",strength=2,maxKey="DroneMaxPerPlayer",max=10,oil=1,iron=0,image="Drone.png",order=3382}
};

function UFRetiredAction(payload)
    if (payload.type=="requestHeadquartersSharing" or payload.type=="respondHeadquartersSharing") and payload.shareType~="SharedIntelligence" then return true; end
    local retired={upgradeAgencyCapability=true,quoteAgencyOperation=true,launchIntelligenceOperation=true,launchFinancialEspionage=true,launchAgencyCyberOperation=true,counterIntelResponse=true,shareIntelReport=true,hqCyberDisrupt=true,hqResourceScan=true,hqMilitaryScan=true,resupplyMissile=true,launchMissile=true,buildHeadquarters=true,upgradeHeadquartersBranch=true};
    if retired[payload.type] then return true; end
    return (payload.type=="buildStrategicMilitary" or payload.type=="repairMilitaryAsset") and payload.kind~="Airbase" and payload.kind~="ForwardAirstrip";
end

local retiredFields={"headquarters","samSites","missileSilos","powerGrids","cyberFacilities","missileInventory","interceptorInventory","pendingStrategicStrikes","pendingAirMissions","airMissionUsedTurn","intelligenceOperationsLevel","cyberOperationsLevel","counterIntelligenceLevel","intelligenceReports","counterIntelAlerts","strategicWarnings","lastAgencyOperationTurn","lastAgencyTargetTurn","lastCyberOperationTurn","hqRecentResults","disruptions","cityDamage"};

function UFConventionalMigration(game)
    local pd=Mod.PrivateGameData or {};
    pd.strategicMilitary=pd.strategicMilitary or {byPlayer={}};
    local military=pd.strategicMilitary; military.byPlayer=military.byPlayer or {};
    military.pendingCovertOps=nil; military.nextCovertOpID=nil;
    local pgd=Mod.PlayerGameData or {};
    for playerID,state in pairs(military.byPlayer) do
        for _,field in ipairs(retiredFields) do state[field]=nil; end
        state.airbases=state.airbases or {}; state.forwardAirstrips=state.forwardAirstrips or {};
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
    end
    Mod.PrivateGameData=pd; Mod.PlayerGameData=pgd;
    local data=Mod.PublicGameData or {};
    for _,nation in pairs((data.globalEconomy or {}).nations or {}) do
        if nation.military then
            for _,field in ipairs({"headquartersStatus","headquartersLevel","headquartersTerritoryID","headquartersBranches","samSiteCount","missileSiloCount","powerGridCount","jointStrategicWarningEnabled"}) do nation.military[field]=nil; end
        end
        nation.aiLastMissileOrder=nil;
    end
    local diplomacy=(data.globalEconomy or {}).diplomacy or {};
    for _,alliance in pairs(diplomacy.alliances or {}) do alliance.jointStrategicWarning=nil; end
    local requests=diplomacy.pendingHeadquartersShareRequests or {};
    for i=#requests,1,-1 do if requests[i].shareType~="SharedIntelligence" then table.remove(requests,i); end end
    Mod.PublicGameData=data;
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
        local strip=setting("ForwardAirstripsEnabled",true)==true and (tonumber((state.forwardAirstrips or {})[territoryID] or (state.forwardAirstrips or {})[tostring(territoryID)]) or 0)>0;
        if not base and not strip then return false,"Deploy Drones at an owned Airbase or Forward Airstrip."; end
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
    local pd=Mod.PrivateGameData or {}; local byPlayer=(pd.strategicMilitary or {}).byPlayer or {}; local pgd=Mod.PlayerGameData or {};
    local add={};
    for playerID,state in pairs(byPlayer) do
        for kind,cfg in pairs(UFConventionalUnitConfig) do
            local actual={};
            for tid,terr in pairs(standing.Territories) do
                for _,unit in ipairs((terr.NumArmies or {}).SpecialUnits or {}) do
                    if unit.proxyType=="CustomSpecialUnit" and unit.Name==(cfg.name or kind) and unit.OwnerID==playerID then actual[tid]=(actual[tid] or 0)+1; end
                end
            end
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
    Mod.PrivateGameData=pd; Mod.PlayerGameData=pgd;
end
