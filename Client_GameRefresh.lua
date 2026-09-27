-- =========================================================
-- GLOBAL ECONOMY
-- CLIENT GAME REFRESH
--
-- Gives each human player one setup reminder per
-- client session until National Setup is completed.
-- =========================================================


NationalSetupReminderShown =
    NationalSetupReminderShown
    or false;

DiplomacyNotificationsShown =
    DiplomacyNotificationsShown
    or {};

function Client_GameRefresh(game)


    if game == nil
        or game.Us == nil then

        return;

    end

-- =========================================================
-- DIPLOMACY NOTIFICATIONS
-- =========================================================

local notificationData =
    Mod.PublicGameData or {};

local notificationEconomy =
    notificationData.globalEconomy
    or {};

local diplomacy =
    notificationEconomy.diplomacy
    or {};

local pendingWarDeclarations =
    diplomacy.pendingWarDeclarations
    or {};

local relationships =
    diplomacy.relationships
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

local pendingFactionInvites =
    diplomacy.pendingFactionInvites
    or {};

local ourID =
    game.Us.ID;

-- =========================================================
-- INTERACTIVE WAR EVENT NOTIFICATION
-- =========================================================

local ourNation =
    (notificationEconomy.nations or {})[
        ourID
    ];

local pendingWarEvent =
    ourNation ~= nil
    and ourNation.pendingWarEvent
    or nil;

if pendingWarEvent ~= nil
    and ourNation.showWarEventAlerts ~= false
then

    local notificationKey =
        "warEvent:" ..
        tostring(
            pendingWarEvent.id
            or 0
        );

    if not DiplomacyNotificationsShown[
        notificationKey
    ] then

        DiplomacyNotificationsShown[
            notificationKey
        ] = true;

        local otherName =
            "another nation";

        if pendingWarEvent.otherPlayerID ~= nil then
            local otherPlayer =
                game.Game.Players[
                    pendingWarEvent.otherPlayerID
                ];
            if otherPlayer ~= nil then
                otherName =
                    otherPlayer.DisplayName(
                        nil,
                        false
                    );
            end
        end

        UI.Alert(
            tostring(
                pendingWarEvent.title
                or "WARTIME DECISION"
            ) ..
            "\n\nYour war with " ..
            tostring(otherName) ..
            " requires a national decision.\n\nOpen Diplomacy and use the Current Wars / War Event section to choose your response."
        );

    end
end


for _, declaration in pairs(
    pendingWarDeclarations
) do

    if declaration.toPlayerID == ourID then

        local notificationKey =
            "warDeclaration:" ..
            tostring(
                declaration.fromPlayerID
            ) ..
            ":" ..
            tostring(
                declaration.declaredTurn
                or 0
            );

        if not DiplomacyNotificationsShown[
            notificationKey
        ] then

            DiplomacyNotificationsShown[
                notificationKey
            ] =
                true;


            local fromName =
                "Player " ..
                tostring(
                    declaration.fromPlayerID
                );

            local fromPlayer =
                game.Game.Players[
                    declaration.fromPlayerID
                ];

            if fromPlayer ~= nil then

                fromName =
                    fromPlayer.DisplayName(
                        nil,
                        false
                    );

            end


            UI.Alert(
                "WAR DECLARATION\n\n" ..
                fromName ..
                " has declared war on your nation.\n\n" ..
                "Hostilities will begin next turn."
            );

        end

    end

end

-- =========================================================
-- ACTIVE WAR NOTIFICATIONS
-- =========================================================

for pairKey, relationship in pairs(
    relationships
) do

    if relationship ~= nil
        and relationship.status == "war" then

        local player1 =
            relationship.player1;

        local player2 =
            relationship.player2;

        local otherPlayerID =
            nil;


        if player1 == ourID then

            otherPlayerID =
                player2;

        elseif player2 == ourID then

            otherPlayerID =
                player1;

        end


        if otherPlayerID ~= nil then

            local notificationKey =
                "warActive:" ..
                tostring(pairKey) ..
                ":" ..
                tostring(
                    relationship.warStartTurn
                    or relationship.startTurn
                    or 0
                );


            if not DiplomacyNotificationsShown[
                notificationKey
            ] then

                DiplomacyNotificationsShown[
                    notificationKey
                ] =
                    true;


                local otherName =
                    "Player " ..
                    tostring(
                        otherPlayerID
                    );

                local otherPlayer =
                    game.Game.Players[
                        otherPlayerID
                    ];


                if otherPlayer ~= nil then

                    otherName =
                        otherPlayer.DisplayName(
                            nil,
                            false
                        );

                end


                UI.Alert(
                    "WAR HAS BEGUN\n\n" ..
                    otherName ..
                    " is now officially at war with your nation.\n\n" ..
                    "Hostilities are now active."
                );

            end

        end

    end

end

-- =========================================================
-- PEACE OFFER NOTIFICATIONS
-- =========================================================

for _, offer in pairs(
    pendingPeaceOffers
) do

    if offer.toPlayerID == ourID then

        local notificationKey =
            "peaceOffer:" ..
            tostring(
                offer.fromPlayerID
            ) ..
            ":" ..
            tostring(
                offer.createdTurn
                or offer.turn
                or 0
            );


        if not DiplomacyNotificationsShown[
            notificationKey
        ] then

            DiplomacyNotificationsShown[
                notificationKey
            ] =
                true;


            local fromName =
                "Player " ..
                tostring(
                    offer.fromPlayerID
                );

            local fromPlayer =
                game.Game.Players[
                    offer.fromPlayerID
                ];


            if fromPlayer ~= nil then

                fromName =
                    fromPlayer.DisplayName(
                        nil,
                        false
                    );

            end


            UI.Alert(
                "PEACE OFFER RECEIVED\n\n" ..
                fromName ..
                " has offered peace.\n\n" ..
                "Open Diplomacy to accept or reject the offer."
            );

        end

    end

end

-- =========================================================
-- NON-AGGRESSION PACT OFFER NOTIFICATIONS
-- =========================================================

for _, offer in pairs(
    pendingNAPOffers
) do

    if offer.toPlayerID == ourID then

        local notificationKey =
            "napOffer:" ..
            tostring(
                offer.fromPlayerID
            ) ..
            ":" ..
            tostring(
                offer.createdTurn
                or offer.turn
                or 0
            );


        if not DiplomacyNotificationsShown[
            notificationKey
        ] then

            DiplomacyNotificationsShown[
                notificationKey
            ] =
                true;


            local fromName =
                "Player " ..
                tostring(
                    offer.fromPlayerID
                );

            local fromPlayer =
                game.Game.Players[
                    offer.fromPlayerID
                ];


            if fromPlayer ~= nil then

                fromName =
                    fromPlayer.DisplayName(
                        nil,
                        false
                    );

            end


            UI.Alert(
                "NON-AGGRESSION PACT OFFER\n\n" ..
                fromName ..
                " has proposed a Non-Aggression Pact.\n\n" ..
                "Open Diplomacy to accept or reject the offer."
            );

        end

    end

end


-- =========================================================
-- ALLIANCE OFFER NOTIFICATIONS
-- =========================================================

for _, offer in pairs(
    pendingAllianceOffers
) do

    if offer.toPlayerID == ourID then

        local notificationKey =
            "allianceOffer:" ..
            tostring(
                offer.fromPlayerID
            ) ..
            ":" ..
            tostring(
                offer.createdTurn
                or 0
            );

        if not DiplomacyNotificationsShown[
            notificationKey
        ] then

            DiplomacyNotificationsShown[
                notificationKey
            ] =
                true;

            local fromName =
                "Player " ..
                tostring(
                    offer.fromPlayerID
                );

            local fromPlayer =
                game.Game.Players[
                    offer.fromPlayerID
                ];

            if fromPlayer ~= nil then

                fromName =
                    fromPlayer.DisplayName(
                        nil,
                        false
                    );

            end

            UI.Alert(
                "ALLIANCE PROPOSAL RECEIVED\n\n" ..
                fromName ..
                " has proposed an Alliance with your nation.\n\n" ..
                "Open Diplomacy to accept or reject the proposal."
            );

        end

    end

end

-- =========================================================
-- FACTION INVITATION NOTIFICATION
-- =========================================================

for _, invite in pairs(
    pendingFactionInvites
) do

    if invite.toPlayerID == ourID then

        local notificationKey =
            "factionInvite:" ..
            tostring(
                invite.factionID
            ) ..
            ":" ..
            tostring(
                invite.fromPlayerID
            ) ..
            ":" ..
            tostring(
                invite.createdTurn
                or "?"
            );


        if not DiplomacyNotificationsShown[
            notificationKey
        ] then

            DiplomacyNotificationsShown[
                notificationKey
            ] =
                true;


            local factions =
                diplomacy.factions
                or {};


            local faction =
                factions[
                    invite.factionID
                ];


            local factionName =
                faction ~= nil
                and faction.name
                or "Unknown Faction";


local fromName =
    "Unknown Nation";

local fromPlayer =
    game.Game.Players[
        invite.fromPlayerID
    ];

if fromPlayer ~= nil then

    fromName =
        fromPlayer.DisplayName(
            nil,
            false
        );

end 

            UI.Alert(
                "FACTION INVITATION RECEIVED\n\n" ..
                fromName ..
                " has invited your nation to join \"" ..
                tostring(
                    factionName
                ) ..
                "\".\n\nOpen Diplomacy to accept or reject the invitation."
            );

        end

    end

end

if NationalSetupReminderShown then

    return;

end

    local data =
        Mod.PublicGameData or {};


    local economy =
        data.globalEconomy;


    -- Wait until the server has initialized Global Affairs data.

    if economy == nil
        or economy.initialized ~= true then

        return;

    end


    local nations =
        economy.nations or {};


    local nation =
        nations[
            game.Us.ID
        ];


    -- Do not bother an eliminated nation.

    if nation ~= nil
        and nation.eliminated == true then

        NationalSetupReminderShown =
            true;

        return;

    end


    -- Nothing to remind once setup is complete.

    if nation ~= nil
        and nation.setupComplete == true then

        NationalSetupReminderShown =
            true;

        return;

    end


    NationalSetupReminderShown =
        true;


    UI.Alert(
        "National Setup is required. Open the Global Economy mod menu to choose your ideology, economic strategy, starting tax policy, flagship company, and company strategy."
    );

end