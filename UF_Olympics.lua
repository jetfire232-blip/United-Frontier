-- War.app loads mod Lua files for their global side effects.
local O = {}
O.sports = {
    {id="track",name="Track & Field"}, {id="swim",name="Swimming"},
    {id="football",name="Football"}, {id="cycling",name="Cycling"},
    {id="rowing",name="Rowing"}, {id="basketball",name="Basketball"}
}
O.presentation={
    track={image="olympics-track.png",venue="THE RUNNING TRACK",finish="PHOTO FINISH",reveal="The finish-line officials confirm the medal order."},
    swim={image="olympics-swim.png",venue="THE AQUATICS CENTER",finish="FINAL TOUCH",reveal="The pool scoreboard confirms the medal order."},
    football={image="olympics-football.png",venue="THE FOOTBALL STADIUM",finish="FINAL WHISTLE",reveal="The final whistle marks the close of competition."},
    cycling={image="olympics-cycling.png",venue="THE VELODROME",finish="FINAL LAP",reveal="The riders cross the line and the podium is confirmed."},
    rowing={image="olympics-rowing.png",venue="THE REGATTA COURSE",finish="FINAL STROKES",reveal="The crews reach the finish and the medals are confirmed."},
    basketball={image="olympics-basketball.png",venue="THE BASKETBALL ARENA",finish="FINAL BUZZER",reveal="The final buzzer sounds and the medal order is confirmed."}
}
O.medalNames={"Gold","Silver","Bronze"}
O.commerceBoost={10,6,3}
O.recruitBoost={15,10,5}
O.minimum=4
O.newTeamWeight=20
function O.teamWeight(event,amount)
    if amount<=0 then return 0 end
    return math.sqrt(amount)+(event.baseTeamWeight or 0)
end
function O.minTeams(event) return event.minTeams or O.minimum end
function O.maxTeams(event) return event.maxTeams or 0 end
function O.occupiedSeats(event)
    local seats=0
    for _ in pairs(event.training) do seats=seats+1 end
    return seats
end
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
function O.betWindow(games)
    if not games.betting then return nil,nil end
    return games.betOpens or games.closes+1,games.betCloses or games.results-1
end
function O.phase(games,turn)
    if not games then return "Awaiting host setup" end
    if games.settled then return "Results" end
    if turn<games.opens then return "Scheduled" end
    if turn<=games.closes then return "Training open" end
    if turn<games.results then
        local first,last=O.betWindow(games)
        if first and turn>=first and turn<=last then return "Betting open" end
        return "Training locked"
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
    local first,last
    if enabled then
        first=payload.betOpens~=nil and payload.betOpens~="" and whole(payload.betOpens) or nil
        last=payload.betCloses~=nil and payload.betCloses~="" and whole(payload.betCloses) or nil
        if (payload.betOpens~=nil and payload.betOpens~="" and not first) or (payload.betCloses~=nil and payload.betCloses~="" and not last) then
            return false,"Betting turns must be whole numbers, or blank for automatic."
        end
        first,last=first or closes+1,last or results-1
        if first<=closes or first>last or last>=results then
            return false,"Betting must start after training closes and finish before results."
        end
    end
    if type(payload.events)~="table" then return false,"Choose at least one event." end
    local events={}
    for _,sport in ipairs(O.sports) do
        local settings=payload.events[sport.id]
        if settings~=nil then
            local purse,minTeams,maxTeams
            if type(settings)=="table" then
                purse,minTeams,maxTeams=whole(settings.purse),whole(settings.minTeams),whole(settings.maxTeams)
            else
                purse,minTeams,maxTeams=whole(settings),O.minimum,0
            end
            if not purse or purse>10000 then return false,sport.name..": set the base prize from 0 to 10,000 Commerce." end
            if not minTeams or minTeams<2 or not maxTeams or (maxTeams~=0 and maxTeams<minTeams) then
                return false,sport.name..": use a minimum of at least 2 and a maximum of 0 (unlimited) or at least the minimum."
            end
            local possible=0
            for _,player in pairs((game.Game or {}).Players or {}) do
                if player.IsAI~=true and not player.Surrendered then possible=possible+1 end
            end
            if minTeams>possible and possible>1 then
                return false,sport.name..": the minimum exceeds the number of active human nations ("..possible..")."
            end
            events[#events+1]={id=sport.id,name=sport.name,purse=purse,minTeams=minTeams,maxTeams=maxTeams,
                baseTeamWeight=O.newTeamWeight,training={},bets={}}
        end
    end
    if #events==0 then return false,"Choose at least one event." end
    economy.olympics={opens=opens,closes=closes,results=results,betting=enabled,betOpens=first,betCloses=last,events=events,boosts={}}
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
            local weight=O.teamWeight(event,amount)
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
function O.prizes(pot,teams)
    if teams==2 then
        local first=math.floor(pot*0.6); return {first,pot-first}
    end
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
        local cap=O.maxTeams(event)
        if cap>0 and not event.training[pid] and O.occupiedSeats(event)>=cap then
            return false,"All team spots for this event are taken."
        end
        if O.pot(event,amount)>1000000000 then return false,"This purse exceeds the game's supported Commerce range." end
        if not debit(amount) then return false,"Your balance changed; try again." end
        event.training[pid]=(event.training[pid] or 0)+amount
        return true,"Added "..amount.." Commerce to your training."
    end
    if payload.type~="olympicsBet" or phase~="Betting open" then return false,"Betting is closed." end
    if event.training[pid] then return false,"You cannot bet on an event you entered." end
    local entrants=O.entries(game,economy,event)
    if #entrants<O.minTeams(event) then return false,"Not enough eligible teams to open betting." end
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
function O.betTotals(event,pick,eligible)
    local total,backed=0,0
    for _,bet in pairs(event.bets) do
        if not eligible or eligible[bet.pick] then
            total=total+bet.amount
            if bet.pick==pick then backed=backed+bet.amount end
        end
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
        if #entries<O.minTeams(event) then
            event.cancelled=true
            for pid,amount in pairs(event.training) do credit(pid,amount) end
            settleBets(event,nil,credit)
        else
            local pot=event.purse
            for pid,amount in pairs(event.training) do
                if event.eligibleAtClose[pid] then pot=pot+amount else credit(pid,amount) end
            end
            local prizes=O.prizes(pot,#entries)
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
UF_Olympics = O
