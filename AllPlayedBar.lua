-- AllPlayedBar.lua
-- Barre de temps de jeu redimensionnable

AllPlayedBar = {}

-- Variables pour la barre
local barFrame = nil
local barText = nil
local isBarVisible = false
local updateTimer = nil
local sessionStartTime = nil

-- Configuration par défaut de la barre
local defaultBarConfig = {
    width = 300,
    height = 60,
    x = 100,
    y = -100,
    visible = false,
    updateInterval = 1, -- Mise à jour toutes les secondes
    displayMode = 1, -- 1 = Session + Perso + Global, 2 = Session seule, 3 = Perso seul, 4 = Global seul
    fontSize = 11,
    backgroundColor = {0, 0, 0, 0.8},
    textColor = {1, 1, 1, 1},
    borderColor = {0.5, 0.5, 0.5, 1}
}

-- Fonction pour sauvegarder la configuration de la barre
local function SaveBarConfig()
    if not AllPlayedDB or not barFrame then
        return
    end
    
    AllPlayedDB.barConfig = AllPlayedDB.barConfig or {}
    AllPlayedDB.barConfig.width = barFrame:GetWidth()
    AllPlayedDB.barConfig.height = barFrame:GetHeight()
    AllPlayedDB.barConfig.x = barFrame:GetLeft()
    AllPlayedDB.barConfig.y = barFrame:GetTop()
    AllPlayedDB.barConfig.visible = isBarVisible
end

-- Fonction pour charger la configuration de la barre
local function LoadBarConfig()
    if not AllPlayedDB then
        return defaultBarConfig
    end
    
    AllPlayedDB.barConfig = AllPlayedDB.barConfig or {}
    
    -- Fusionner avec les valeurs par défaut
    for key, value in pairs(defaultBarConfig) do
        if AllPlayedDB.barConfig[key] == nil then
            AllPlayedDB.barConfig[key] = value
        end
    end
    
    return AllPlayedDB.barConfig
end

-- Fonction pour calculer le temps global
local function GetGlobalPlaytime()
    if AllPlayed and AllPlayed.GetGlobalPlaytime then
        return AllPlayed.GetGlobalPlaytime()
    end
    return 0
end

-- Fonction pour obtenir le temps du personnage actuel
local function GetCurrentCharPlaytime()
    if AllPlayed and AllPlayed.GetCurrentCharPlaytime then
        return AllPlayed.GetCurrentCharPlaytime()
    end
    return 0
end

-- Fonction pour obtenir le temps de session actuelle
local function GetSessionPlaytime()
    if not sessionStartTime then
        return 0
    end
    return time() - sessionStartTime
end

-- Fonction pour réinitialiser le timer de session
local function ResetSessionTimer()
    sessionStartTime = time()
end

-- Exposer la variable pour l'accès externe
function AllPlayedBar.GetSessionStartTime()
    return sessionStartTime
end

-- Fonction pour formater le temps
local function FormatTime(totalSeconds)
    if AllPlayed and AllPlayed.FormatTime then
        return AllPlayed.FormatTime(totalSeconds)
    end
    
    -- Fallback si AllPlayed n'est pas encore chargé
    if not totalSeconds or totalSeconds == 0 then
        return "0h 0m 0s"
    end
    
    local hours = math.floor(totalSeconds / 3600)
    local minutes = math.floor((totalSeconds % 3600) / 60)
    local seconds = totalSeconds % 60
    
    return string.format("%dh %dm %ds", hours, minutes, seconds)
end

-- Fonction pour mettre à jour le texte de la barre
local function UpdateBarText()
    if not barText or not isBarVisible then
        return
    end
    
    local config = AllPlayedDB.barConfig
    local sessionTime = GetSessionPlaytime()
    local charTime = GetCurrentCharPlaytime()
    local globalTime = GetGlobalPlaytime()
    
    local displayText = ""
    
    if config.displayMode == 1 then
        -- Mode complet : Session + Perso + Global
        displayText = string.format("Session: %s\nPerso: %s\nGlobal: %s",
            FormatTime(sessionTime),
            FormatTime(charTime),
            FormatTime(globalTime))
    elseif config.displayMode == 2 then
        -- Session seule
        displayText = "Session: " .. FormatTime(sessionTime)
    elseif config.displayMode == 3 then
        -- Personnage seul
        displayText = UnitName("player") .. ": " .. FormatTime(charTime)
    elseif config.displayMode == 4 then
        -- Global seul
        displayText = "Global: " .. FormatTime(globalTime)
    end
    
    barText:SetText(displayText)
end

-- Fonction pour créer la barre
local function CreatePlaytimeBar()
    if barFrame then
        return barFrame
    end
    
    print("|cff00ff00[AllPlayed]|r Création de la barre de temps...")
    
    local config = LoadBarConfig()
    
    -- Créer la frame principale
    barFrame = CreateFrame("Frame", "AllPlayedBarFrame", UIParent, "BackdropTemplate")
    barFrame:SetSize(config.width, config.height)
    barFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", config.x or 100, config.y or -100)
    
    -- Configuration du backdrop (arrière-plan et bordure)
    barFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 8,
        insets = {left = 2, right = 2, top = 2, bottom = 2}
    })
    
    barFrame:SetBackdropColor(unpack(config.backgroundColor))
    barFrame:SetBackdropBorderColor(unpack(config.borderColor))
    
    -- Rendre la frame déplaçable
    barFrame:SetMovable(true)
    barFrame:EnableMouse(true)
    barFrame:RegisterForDrag("LeftButton")
    barFrame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    barFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SaveBarConfig()
    end)
    
    -- Rendre la frame redimensionnable
    barFrame:SetResizable(true)
    barFrame:SetMinResize(100, 20)
    barFrame:SetMaxResize(500, 100)
    
    -- Créer la poignée de redimensionnement
    local resizeButton = CreateFrame("Button", nil, barFrame)
    resizeButton:SetSize(16, 16)
    resizeButton:SetPoint("BOTTOMRIGHT", -1, 1)
    resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    
    resizeButton:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            barFrame:StartSizing("BOTTOMRIGHT")
        end
    end)
    
    resizeButton:SetScript("OnMouseUp", function(self, button)
        barFrame:StopMovingOrSizing()
        SaveBarConfig()
        -- Ajuster la taille du texte si nécessaire
        barText:SetWidth(barFrame:GetWidth() - 10)
    end)
    
    -- Créer le texte
    barText = barFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    barText:SetPoint("CENTER")
    barText:SetTextColor(unpack(config.textColor))
    barText:SetFont("Fonts\\FRIZQT__.TTF", config.fontSize, "OUTLINE")
    barText:SetWidth(config.width - 10)
    barText:SetWordWrap(true)
    barText:SetJustifyH("CENTER")
    barText:SetJustifyV("MIDDLE")
    
    -- Menu clic droit
    barFrame:SetScript("OnMouseUp", function(self, button)
        if button == "RightButton" then
            AllPlayedBar.ShowContextMenu()
        end
    end)
    
    -- Tooltip
    barFrame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:SetText("AllPlayed Bar", 1, 1, 1)
        GameTooltip:AddLine("Session: " .. FormatTime(GetSessionPlaytime()), 0.5, 1, 0.5)
        GameTooltip:AddLine("Personnage: " .. FormatTime(GetCurrentCharPlaytime()), 0.5, 0.5, 1)
        GameTooltip:AddLine("Global: " .. FormatTime(GetGlobalPlaytime()), 1, 1, 0.5)
        GameTooltip:AddLine(" ", 1, 1, 1)
        GameTooltip:AddLine("Clic gauche + glisser: Déplacer", 0.7, 0.7, 0.7)
        GameTooltip:AddLine("Clic droit: Menu d'affichage", 0.7, 0.7, 0.7)
        GameTooltip:AddLine("Coin bas-droit: Redimensionner", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    
    barFrame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    print("|cff00ff00[AllPlayed]|r Barre créée avec succès!")
    
    return barFrame
end

-- Menu contextuel
function AllPlayedBar.ShowContextMenu()
    local config = AllPlayedDB.barConfig
    local menu = {
        {
            text = "AllPlayed Bar - Mode d'affichage",
            isTitle = true,
            notCheckable = true
        },
        {
            text = "Session + Perso + Global",
            func = function()
                config.displayMode = 1
                UpdateBarText()
                print("|cff00ff00[AllPlayed]|r Mode: Complet")
            end,
            checked = (config.displayMode == 1),
            keepShownOnClick = false
        },
        {
            text = "Session uniquement",
            func = function()
                config.displayMode = 2
                UpdateBarText()
                print("|cff00ff00[AllPlayed]|r Mode: Session")
            end,
            checked = (config.displayMode == 2),
            keepShownOnClick = false
        },
        {
            text = "Personnage uniquement",
            func = function()
                config.displayMode = 3
                UpdateBarText()
                print("|cff00ff00[AllPlayed]|r Mode: Personnage")
            end,
            checked = (config.displayMode == 3),
            keepShownOnClick = false
        },
        {
            text = "Global uniquement",
            func = function()
                config.displayMode = 4
                UpdateBarText()
                print("|cff00ff00[AllPlayed]|r Mode: Global")
            end,
            checked = (config.displayMode == 4),
            keepShownOnClick = false
        },
        {
            text = " ",
            notCheckable = true,
            hasArrow = false,
            disabled = true
        },
        {
            text = "Réinitialiser session",
            func = function()
                ResetSessionTimer()
                print("|cff00ff00[AllPlayed]|r Compteur de session réinitialisé")
            end,
            notCheckable = true
        },
        {
            text = "Masquer la barre",
            func = function()
                AllPlayedBar.HideBar()
            end,
            notCheckable = true
        },
        {
            text = "Réinitialiser position",
            func = function()
                barFrame:ClearAllPoints()
                barFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 100, -100)
                barFrame:SetSize(300, 60)
                SaveBarConfig()
            end,
            notCheckable = true
        }
    }
    
    EasyMenu(menu, CreateFrame("Frame", "AllPlayedBarContextMenu", UIParent, "UIDropDownMenuTemplate"), "cursor", 0, 0, "MENU")
end

-- Fonction pour afficher la barre
function AllPlayedBar.ShowBar()
    if not barFrame then
        CreatePlaytimeBar()
    end
    
    barFrame:Show()
    isBarVisible = true
    
    -- S'assurer que barConfig existe
    local config = LoadBarConfig()
    if AllPlayedDB and AllPlayedDB.barConfig then
        AllPlayedDB.barConfig.visible = true
    end
    
    -- Démarrer le timer de mise à jour
    if updateTimer then
        updateTimer:Cancel()
    end
    
    updateTimer = C_Timer.NewTicker(config.updateInterval, UpdateBarText)
    
    -- Forcer une mise à jour immédiate
    C_Timer.After(0.1, UpdateBarText)
    
    print("|cff00ff00[AllPlayed]|r Barre de temps affichée")
end

-- Fonction pour masquer la barre
function AllPlayedBar.HideBar()
    if barFrame then
        barFrame:Hide()
    end
    
    isBarVisible = false
    
    if AllPlayedDB and AllPlayedDB.barConfig then
        AllPlayedDB.barConfig.visible = false
    end
    
    if updateTimer then
        updateTimer:Cancel()
        updateTimer = nil
    end
    
    print("|cff00ff00[AllPlayed]|r Barre de temps masquée")
end

-- Fonction pour basculer l'affichage de la barre
function AllPlayedBar.ToggleBar()
    if isBarVisible then
        AllPlayedBar.HideBar()
    else
        AllPlayedBar.ShowBar()
    end
end

-- Fonction de test pour forcer l'affichage de la barre
function AllPlayedBar.ForceShow()
    print("|cff00ff00[AllPlayed]|r Force l'affichage de la barre...")
    
    if not barFrame then
        print("|cff00ff00[AllPlayed]|r Création forcée de la barre...")
        CreatePlaytimeBar()
    end
    
    if barFrame then
        barFrame:Show()
        isBarVisible = true
        barText:SetText("Test: Barre visible!")
        print("|cff00ff00[AllPlayed]|r Barre forcée à l'affichage!")
    else
        print("|cffff0000[AllPlayed]|r ERREUR: Impossible de créer la barre!")
    end
end

-- Fonction d'initialisation
function AllPlayedBar.Initialize()
    -- Initialiser le timer de session
    ResetSessionTimer()
    
    -- Attendre que AllPlayedDB soit disponible avant de charger la config
    C_Timer.After(0.5, function()
        local config = LoadBarConfig()
        
        if config.visible then
            -- Délai pour s'assurer que l'interface est prête
            C_Timer.After(1, function()
                AllPlayedBar.ShowBar()
            end)
        end
    end)
end

-- Fonction appelée quand les données de temps sont mises à jour
function AllPlayedBar.OnPlaytimeUpdated()
    if isBarVisible then
        UpdateBarText()
    end
end
