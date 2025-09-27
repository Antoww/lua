-- AllPlayed Addon
-- Tracks playtime across all characters

AllPlayed = {}
AllPlayed.frame = CreateFrame("Frame")

-- Variables par défaut
AllPlayedDB = AllPlayedDB or {}

-- Fonction pour formater le temps en heures, minutes et secondes
local function FormatTime(totalSeconds)
    if not totalSeconds or totalSeconds == 0 then
        return "0h 0m 0s"
    end
    
    local hours = math.floor(totalSeconds / 3600)
    local minutes = math.floor((totalSeconds % 3600) / 60)
    local seconds = totalSeconds % 60
    
    return string.format("%dh %dm %ds", hours, minutes, seconds)
end

-- Fonction pour obtenir l'identifiant unique du personnage
local function GetCharacterKey()
    local playerName = UnitName("player")
    local realmName = GetRealmName()
    return playerName .. "-" .. realmName
end

-- Fonction pour obtenir le temps de jeu actuel
local function GetCurrentPlaytime()
    RequestTimePlayed()
    -- Le temps sera récupéré via l'événement TIME_PLAYED_MSG
end

-- Fonction pour sauvegarder le temps de jeu
local function SavePlaytime(totalTime, levelTime)
    local charKey = GetCharacterKey()
    local playerClass = UnitClass("player")
    local playerLevel = UnitLevel("player")
    
    -- Initialiser les données du serveur si nécessaire
    local realmName = GetRealmName()
    if not AllPlayedDB[realmName] then
        AllPlayedDB[realmName] = {}
    end
    
    -- Sauvegarder les informations du personnage
    AllPlayedDB[realmName][charKey] = {
        name = UnitName("player"),
        class = playerClass,
        level = playerLevel,
        totalTime = totalTime,
        levelTime = levelTime,
        lastUpdate = time()
    }
    
    -- Mettre à jour la barre si elle existe
    if AllPlayedBar and AllPlayedBar.OnPlaytimeUpdated then
        AllPlayedBar.OnPlaytimeUpdated()
    end
    
    print("|cff00ff00[AllPlayed]|r Temps de jeu sauvegardé pour " .. UnitName("player"))
end

-- Fonctions exposées pour AllPlayedBar
function AllPlayed.GetGlobalPlaytime()
    local realmName = GetRealmName()
    if not AllPlayedDB[realmName] then
        return 0
    end
    
    local total = 0
    for _, char in pairs(AllPlayedDB[realmName]) do
        total = total + (char.totalTime or 0)
    end
    return total
end

function AllPlayed.GetCurrentCharPlaytime()
    local charKey = GetCharacterKey()
    local realmName = GetRealmName()
    
    if AllPlayedDB[realmName] and AllPlayedDB[realmName][charKey] then
        return AllPlayedDB[realmName][charKey].totalTime or 0
    end
    return 0
end

function AllPlayed.FormatTime(totalSeconds)
    return FormatTime(totalSeconds)
end

-- Fonction pour afficher les statistiques
local function ShowPlaytimeStats()
    local realmName = GetRealmName()
    local currentCharKey = GetCharacterKey()
    
    print("|cff00ff00=== AllPlayed - Statistiques ===|r")
    
    if not AllPlayedDB[realmName] then
        print("|cffff0000Aucune donnée trouvée pour ce serveur.|r")
        return
    end
    
    local totalGlobalTime = 0
    local charCount = 0
    
    -- Afficher les stats du personnage actuel en premier
    if AllPlayedDB[realmName][currentCharKey] then
        local char = AllPlayedDB[realmName][currentCharKey]
        print(string.format("|cff00ffff[ACTUEL] %s|r |cff%s(%s %d)|r - %s", 
            char.name, 
            RAID_CLASS_COLORS[char.class] and RAID_CLASS_COLORS[char.class].colorStr or "ffffff",
            char.class, 
            char.level, 
            FormatTime(char.totalTime)))
        totalGlobalTime = totalGlobalTime + char.totalTime
        charCount = charCount + 1
    end
    
    print("|cffcccccc--- Autres personnages ---")
    
    -- Afficher les autres personnages
    for charKey, char in pairs(AllPlayedDB[realmName]) do
        if charKey ~= currentCharKey then
            print(string.format("%s |cff%s(%s %d)|r - %s", 
                char.name, 
                RAID_CLASS_COLORS[char.class] and RAID_CLASS_COLORS[char.class].colorStr or "ffffff",
                char.class, 
                char.level, 
                FormatTime(char.totalTime)))
            totalGlobalTime = totalGlobalTime + char.totalTime
            charCount = charCount + 1
        end
    end
    
    print("|cffcccccc--- Résumé ---")
    print(string.format("|cffffff00Total sur %d personnage(s): %s|r", charCount, FormatTime(totalGlobalTime)))
end

-- Gestionnaire d'événements
local function OnEvent(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "AllPlayed" then
            print("|cff00ff00[AllPlayed]|r Addon chargé. Utilisez /aplayed pour voir vos statistiques.")
            print("|cff00ff00[AllPlayed]|r Utilisez /aplayed bar pour afficher/masquer la barre de temps.")
            
            -- Initialiser la barre
            if AllPlayedBar and AllPlayedBar.Initialize then
                AllPlayedBar.Initialize()
            end
            
            -- Demander le temps de jeu à la connexion
            C_Timer.After(2, GetCurrentPlaytime)
        end
    elseif event == "TIME_PLAYED_MSG" then
        local totalTime, levelTime = ...
        SavePlaytime(totalTime, levelTime)
    end
end

-- Enregistrement des événements
AllPlayed.frame:RegisterEvent("ADDON_LOADED")
AllPlayed.frame:RegisterEvent("TIME_PLAYED_MSG")
AllPlayed.frame:SetScript("OnEvent", OnEvent)

-- Commande slash
SLASH_ALLPLAYED1 = "/aplayed"
SlashCmdList["ALLPLAYED"] = function(msg)
    msg = string.lower(string.trim(msg or ""))
    
    if msg == "" then
        ShowPlaytimeStats()
    elseif msg == "help" or msg == "aide" then
        print("|cff00ff00[AllPlayed] Commandes disponibles:|r")
        print("|cffffff00/aplayed|r - Affiche les statistiques de temps de jeu")
        print("|cffffff00/aplayed bar|r - Affiche/masque la barre de temps")
        print("|cffffff00/aplayed bar show|r - Affiche la barre de temps")
        print("|cffffff00/aplayed bar hide|r - Masque la barre de temps")
        print("|cffffff00/aplayed session|r - Affiche le temps de session actuelle")
        print("|cffffff00/aplayed update|r - Met à jour le temps de jeu du personnage actuel")
        print("|cffffff00/aplayed help|r - Affiche cette aide")
        print("|cffcccccc--- Barre de temps ---")
        print("|cffffff00Clic droit sur la barre|r - Menu des modes d'affichage")
        print("|cffffff004 modes|r: Complet, Session, Personnage, Global")
    elseif msg == "update" then
        print("|cff00ff00[AllPlayed]|r Mise à jour du temps de jeu...")
        GetCurrentPlaytime()
    elseif msg == "bar" then
        if AllPlayedBar and AllPlayedBar.ToggleBar then
            AllPlayedBar.ToggleBar()
        else
            print("|cffff0000[AllPlayed] Erreur: Module barre non disponible.|r")
        end
    elseif msg == "bar show" then
        if AllPlayedBar and AllPlayedBar.ShowBar then
            AllPlayedBar.ShowBar()
        else
            print("|cffff0000[AllPlayed] Erreur: Module barre non disponible.|r")
        end
    elseif msg == "bar hide" then
        if AllPlayedBar and AllPlayedBar.HideBar then
            AllPlayedBar.HideBar()
        else
            print("|cffff0000[AllPlayed] Erreur: Module barre non disponible.|r")
        end
    elseif msg == "session" then
        if AllPlayedBar and AllPlayedBar.GetSessionStartTime then
            local startTime = AllPlayedBar.GetSessionStartTime()
            local sessionTime = startTime and (time() - startTime) or 0
            print("|cff00ff00[AllPlayed]|r Temps de session: " .. FormatTime(sessionTime))
        else
            print("|cffff0000[AllPlayed] Erreur: Module session non disponible.|r")
        end
    else
        print("|cffff0000[AllPlayed] Commande inconnue. Tapez /aplayed help pour l'aide.|r")
    end
end

print("|cff00ff00AllPlayed addon initialisé|r")
