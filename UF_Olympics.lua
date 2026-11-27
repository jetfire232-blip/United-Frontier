local O = {}
O.sports = {
    {id="track",name="Track & Field"}, {id="swim",name="Swimming"},
    {id="football",name="Football"}, {id="cycling",name="Cycling"},
    {id="rowing",name="Rowing"}, {id="basketball",name="Basketball"}
}
O.medalNames={"Gold","Silver","Bronze"}
O.commerceBoost={10,6,3}
O.recruitBoost={15,10,5}
O.minimum=4
local function whole(value)
    local n=tonumber(value)
    if not n or n~=n or n<0 or n>1000000000 or n~=math.floor(n) then return nil end
    return n
end
function O.isHost(game,pid)
    if pid==nil then return false end
    local settings=game and game.Settings
    if not settings then return false end
    if settings.StartedBy~=nil then return settings.StartedBy==pid end
    -- A local single-player game may not have a creator ID.
    if settings.SinglePlayer~=true then return false end
    local sole
    for id,player in pairs((game.Game or {}).Players or {}) do
        if player.IsAI~=true then
            if sole~=nil then return false end
            sole=id
        end
    end
    return sole==pid
end
function O.turn(data)
    return math.max(1,(tonumber(data.tradeTurn) or 0)+1)
end
function O.phase(games,turn)
    if not games then return "Awaiting host setup" end
    if games.settled then return "Results" end
    if turn<games.opens then return "Scheduled" end
    if turn<=games.closes then return "Training open" end
    if turn<games.results then
        return games.betting and "Betting open" or "Training locked"
    end
    return "Awaiting results"
end
function O.publish(game,economy,turn,pid,payload)
    if not O.isHost(game,pid) then return false,"Only the game host can set up the Olympics." end
    if game.Settings.CommerceGame==false then return false,"The Olympics require a Commerce game." end
    if economy.olympics then return false,"The Olympic schedule is already locked." end
    if turn~=1 then return false,"The host can set up the Olympics on Turn 1." end
    local opens,closes,results=whole(payload.opens),whole(payload.closes),whole(payload.results)
    if not opens or not closes or not results or opens<1 or closes<opens or results<=closes or results>1000 then
        return false,"Choose valid turns: opening ≤ last training turn < results turn."
    end
    local enabled=payload.betting==true
    if enabled and results<closes+2 then return false,"Leave at least one full turn for betting after training closes." end
    if type(payload.events)~="table" then return false,"Choose at least one event." end
    local events={}
    for _,sport in ipairs(O.sports) do
        local purse=payload.events[sport.id]
        if purse~=nil then
            purse=whole(purse)
            if not purse or purse>10000 then return false,"Set each base purse from 0 to 10,000 Commerce." end
            events[#events+1]={id=sport.id,name=sport.name,purse=purse,training={},bets={}}
        end
    end
    if #events==0 then return false,"Choose at least one event." end
    economy.olympics={opens=opens,closes=closes,results=results,betting=enabled,events=events,boosts={}}
    return true,"Olympic schedule published and locked."
end
function O.eligible(game,economy,pid)
    local player=((game.Game or {}).Players or {})[pid]
    local nation=(economy.nations or {})[pid]
    return player and not player.Surrendered and nation and not nation.eliminated
end
function O.entries(game,economy,event)
    local entries={}
    local sum=0
    for pid,amount in pairs(event.training) do
        if O.eligible(game,economy,pid) then
            local weight=math.sqrt(amount)
            entries[#entries+1]={pid=pid,amount=amount,weight=weight}
            sum=sum+weight
        end
    end
    table.sort(entries,function(a,b)
        if a.amount~=b.amount then return a.amount>b.amount end
        return a.pid<b.pid
    end)
    return entries,sum
end
function O.pot(event,extra)
    local total=event.purse+(extra or 0)
    for _,amount in pairs(event.training) do total=total+amount end
    return total
end
function O.prizes(pot)
    local gold=math.floor(pot/2)
    local silver=math.floor(pot*3/10)
    return {gold,silver,pot-gold-silver}
end
function O.commit(game,economy,turn,pid,payload,balance,debit)
    local games=economy.olympics
    if not games or games.settled then return false,"There are no open Olympics." end
    if not O.eligible(game,economy,pid) then return false,"Only active nations can participate." end
    local event
    for _,e in ipairs(games.events) do if e.id==payload.event then event=e; break end end
    if not event then return false,"Choose a scheduled event." end
    local amount=whole(payload.amount)
    if not amount or amount<1 or amount>balance then return false,"Enter a positive whole amount you can afford." end
    local phase=O.phase(games,turn)
    if payload.type=="olympicsTrain" then
        if phase~="Training open" then return false,"Training is closed." end
        if O.pot(event,amount)>1000000000 then return false,"This purse exceeds the game's supported Commerce range." end
        if not debit(amount) then return false,"Your balance changed; try again." end
        event.training[pid]=(event.training[pid] or 0)+amount
        return true,"Added "..amount.." Commerce to your training."
    end
    if payload.type~="olympicsBet" or phase~="Betting open" then return false,"Betting is closed." end
    if event.training[pid] then return false,"You cannot bet on an event you entered." end
    local entrants=O.entries(game,economy,event)
    if #entrants<O.minimum then return false,"At least four eligible teams are needed to open betting." end
    local pick=whole(payload.pick)
    if not pick or not event.training[pick] or not O.eligible(game,economy,pick) then
        return false,"Choose an active entrant to win gold."
    end
    local existing=event.bets[pid]
    if existing and existing.pick~=pick then return false,"You can only back one team per event." end
    local total=amount
    for _,bet in pairs(event.bets) do total=total+bet.amount end
    if total>1000000000 then return false,"This betting pool exceeds the game's supported Commerce range." end
    if not debit(amount) then return false,"Your balance changed; try again." end
    event.bets[pid]={pick=pick,amount=(existing and existing.amount or 0)+amount}
    return true,"Placed "..amount.." Commerce on gold."
end
function O.betTotals(event,pick)
    local total,backed=0,0
    for _,bet in pairs(event.bets) do
        total=total+bet.amount
        if bet.pick==pick then backed=backed+bet.amount end
    end
    return total,backed
end
local function draw(entries,random)
    local sum=0
    for _,entry in ipairs(entries) do sum=sum+entry.weight end
    local roll=random()*sum
    for index,entry in ipairs(entries) do
        roll=roll-entry.weight
        if roll<0 or index==#entries then return table.remove(entries,index) end
    end
end
local function settleBets(event,winner,credit)
    local _,backed=O.betTotals(event,winner)
    event.betPayouts={}
    -- Void stakes on nations that are out at settlement; payable pool contains valid picks only.
    local pool=0
    for _,bet in pairs(event.bets) do
        if event.eligibleAtClose[bet.pick] then pool=pool+bet.amount end
    end
    if not winner or backed==0 then
        event.betRefunded=true
        for pid,bet in pairs(event.bets) do event.betPayouts[pid]=bet.amount; credit(pid,bet.amount) end
        return
    end
    local paid,winners=0,{}
    for pid,bet in pairs(event.bets) do
        if not event.eligibleAtClose[bet.pick] then
            event.betPayouts[pid]=bet.amount
            credit(pid,bet.amount)
        elseif bet.pick==winner then
            local exact=pool*(bet.amount/backed)
            local amount=math.floor(exact)
            paid=paid+amount
            winners[#winners+1]={pid=pid,amount=amount,remainder=exact-amount}
        end
    end
    table.sort(winners,function(a,b)
        if a.remainder~=b.remainder then return a.remainder>b.remainder end
        return a.pid<b.pid
    end)
    local remainder=pool-paid
    for index,win in ipairs(winners) do
        local amount=win.amount+(index<=remainder and 1 or 0)
        event.betPayouts[win.pid]=amount
        credit(win.pid,amount)
    end
end
function O.resolve(game,economy,turn,credit,random)
    local games=economy.olympics
    if not games or games.settled or turn<games.results then return end
    for _,event in ipairs(games.events) do
        local entries=O.entries(game,economy,event)
        event.eligibleAtClose={}
        for _,entry in ipairs(entries) do event.eligibleAtClose[entry.pid]=true end
        if #entries<O.minimum then
            event.cancelled=true
            for pid,amount in pairs(event.training) do credit(pid,amount) end
            settleBets(event,nil,credit)
        else
            local pot=event.purse
            for pid,amount in pairs(event.training) do
                if event.eligibleAtClose[pid] then pot=pot+amount else credit(pid,amount) end
            end
            local prizes=O.prizes(pot)
            event.medals={}
            for rank,amount in ipairs(prizes) do
                local entry=draw(entries,random or math.random)
                credit(entry.pid,amount)
                event.medals[rank]={pid=entry.pid,prize=amount}
                local boost=games.boosts[entry.pid]
                if boost==nil or rank<boost.rank then
                    games.boosts[entry.pid]={rank=rank,first=turn+1,last=turn+2}
                end
            end
            settleBets(event,event.medals[1].pid,credit)
        end
    end
    games.settled=true
    games.settledTurn=turn
end
function O.boost(economy,turn,pid)
    local games=economy and economy.olympics
    local boost=games and games.boosts[pid]
    if not boost or turn<boost.first or turn>boost.last then return 0,0 end
    return O.commerceBoost[boost.rank],O.recruitBoost[boost.rank]
end
return O
