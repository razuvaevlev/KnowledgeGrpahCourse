-- ===========================================================================
--	HUD's "Launch Bar"
--	Copyright (c) 2017-2019 Firaxis Games
--
--	Controls raising full-screen and "choosers" found in upper-left of HUD.
-- ===========================================================================
include( "GameCapabilities" );


-- ===========================================================================
--	MEMBERS
-- ===========================================================================
local m_numOpen					:number = 0;

local m_isAutoUnitCycle			:boolean = false;

local isTechTreeOpen			:boolean = false;
local isCivicsTreeOpen			:boolean = false;
local isGreatPeopleOpen			:boolean = false;
local isGreatWorksOpen			:boolean = false;
local isHistoricMomentsOpen		:boolean = false;
local isReligionOpen			:boolean = false;
local isGovernmentOpen			:boolean = false;
local isGovernorPanelOpen       :boolean = false;

local m_isGreatPeopleUnlocked	:boolean = false;
local m_isGreatWorksUnlocked	:boolean = false;
local m_isReligionUnlocked		:boolean = false;
local m_isGovernmentUnlocked	:boolean = false;

local m_isTechTreeAvailable		:boolean = false;
local m_isCivicsTreeAvailable	:boolean = false;
local m_isGovernmentAvailable	:boolean = false;
local m_isReligionAvailable		:boolean = false;
local m_isGreatPeopleAvailable	:boolean = false;
local m_isGreatWorksAvailable	:boolean = false;

local isDebug					:boolean = false;			-- Set to true to force all hook buttons to show on game start	


-- ===========================================================================
--	Callbacks
-- ===========================================================================

-- ===========================================================================
function OnOpenGovernment()
	local ePlayer		:number = Game.GetLocalPlayer();
	if ePlayer == -1 then
		return; -- Probably autoplay
	end

	local localPlayer:table = Players[ePlayer];
	if localPlayer == nil then
		return;
	end

	local kCulture:table	= localPlayer:GetCulture();
	if ( kCulture:IsInAnarchy() ) then -- Anarchy? No gov't for you.
		if isGovernmentOpen then
			LuaEvents.LaunchBar_CloseGovernmentPanel()
		end
		return;
	end

	if isGovernmentOpen then
		LuaEvents.LaunchBar_CloseGovernmentPanel()
	else
		CloseAllPopups();
		if (kCulture:CivicCompletedThisTurn() and kCulture:CivicUnlocksGovernment(kCulture:GetCivicCompletedThisTurn()) and not kCulture:GovernmentChangeConsidered()) then
			-- Blocking notification that NEW GOVERNMENT is available, make sure player takes a look	
			LuaEvents.LaunchBar_GovernmentOpenGovernments();
		else 
			-- Normal entry to my Government
			LuaEvents.LaunchBar_GovernmentOpenMyGovernment();
		end
	end
end

-- ===========================================================================
function CloseAllPopups()
	LuaEvents.LaunchBar_CloseGreatPeoplePopup();
	LuaEvents.LaunchBar_CloseGreatWorksOverview();
	LuaEvents.LaunchBar_CloseReligionPanel();
	if isGovernmentOpen then
		LuaEvents.LaunchBar_CloseGovernmentPanel();
	end
	LuaEvents.LaunchBar_CloseTechTree();
	LuaEvents.LaunchBar_CloseCivicsTree();
end

-- ===========================================================================
function OnGetPopupsOpen()
	if isGovernmentOpen or isTechTreeOpen or isCivicsTreeOpen or isGreatPeopleOpen or isGreatWorksOpen or isReligionOpen or isHistoricMomentsOpen or isGovernorPanelOpen then
		LuaEvents.TradeRouteChooser_CloseIfPopups();
		m_isAutoUnitCycle = false;
		if UserConfiguration.IsAutoUnitCycle() then
			m_isAutoUnitCycle = true; -- set to true so we know we need to open it after the currently open popup is closed.
		end
	end
end

-- ===========================================================================
function OnOpenTradeRouteDueToAutoCycle()
	--if another popup was open, trade route needs to open after it has been closed (when auto unit cycle is enabled)
	if m_isAutoUnitCycle then
		LuaEvents.TradeRouteChooser_ReOpen();		
	end
end

-- ===========================================================================
function OnOpenGreatPeople()
	if isGreatPeopleOpen then
		LuaEvents.LaunchBar_CloseGreatPeoplePopup();
	else
		CloseAllPopups();
		LuaEvents.LaunchBar_OpenGreatPeoplePopup();	
	end
end

-- ===========================================================================
function OnOpenGreatWorks()
	if isGreatWorksOpen then
		LuaEvents.LaunchBar_CloseGreatWorksOverview();
	else
		CloseAllPopups();
		LuaEvents.LaunchBar_OpenGreatWorksOverview();	
	end
end

-- ===========================================================================
function OnOpenReligion()
	if isReligionOpen then
		LuaEvents.LaunchBar_CloseReligionPanel();
		LuaEvents.LaunchBar_ClosePantheonChooser();
	else
		-- If we're able to but have yet to found a pantheon then open the pantheon chooser instead
		local pLocalPlayerReligion:table = Players[Game.GetLocalPlayer()]:GetReligion();
		if pLocalPlayerReligion and pLocalPlayerReligion:GetPantheon() < 0 and pLocalPlayerReligion:CanCreatePantheon() then
			LuaEvents.LaunchBar_OpenPantheonChooser();
		else
			CloseAllPopups();
			LuaEvents.LaunchBar_OpenReligionPanel();
		end	
	end
end

-- ===========================================================================
function OnOpenResearch()
	if isTechTreeOpen then
		LuaEvents.LaunchBar_CloseTechTree();
	else
		CloseAllPopups();
		LuaEvents.LaunchBar_RaiseTechTree();	
	end
end

-- ===========================================================================
function OnOpenCulture()
	if isCivicsTreeOpen then
		LuaEvents.LaunchBar_CloseCivicsTree();
	else
		CloseAllPopups();
		LuaEvents.LaunchBar_RaiseCivicsTree();	
	end
end

-- ===========================================================================
function OnOpenGovernors()
	if isGovernorPanelOpen then
		LuaEvents.GovernorPanel_Close();
	else
		CloseAllPopups();
		LuaEvents.GovernorPanel_Open();
	end
end

-- ===========================================================================
function SetCivicsTreeOpen()
	isCivicsTreeOpen = true;
	OnOpen();
end

-- ===========================================================================
function SetTechTreeOpen()
	isTechTreeOpen = true;
	OnOpen();
end

-- ===========================================================================
function SetGreatPeopleOpen()
	isGreatPeopleOpen = true;
	OnOpen();
end

-- ===========================================================================
function SetGreatWorksOpen()
	isGreatWorksOpen = true;
	OnOpen();
end

-- ===========================================================================
function SetReligionOpen()
	isReligionOpen = true;
	OnOpen();
end

-- ===========================================================================
function SetGovernmentOpen()
	isGovernmentOpen = true;
	OnOpen();
end

-- ===========================================================================
function SetGovernorPanelOpen()
	isGovernorPanelOpen = true;
	OnOpen();
end

-- ===========================================================================
function SetHistoricMomentsOpened()
	isHistoricMomentsOpen = true;
	OnOpen();
end

-- ===========================================================================
function SetCivicsTreeClosed()
	isCivicsTreeOpen = false;
	OnClose();
end

-- ===========================================================================
function SetTechTreeClosed()
	isTechTreeOpen = false;
	OnClose();
end

-- ===========================================================================
function SetGreatPeopleClosed()
	isGreatPeopleOpen = false;
	OnClose();
end

-- ===========================================================================
function SetGreatWorksClosed()
	isGreatWorksOpen = false;
	OnClose();
end

-- ===========================================================================
function SetReligionClosed()
	isReligionOpen = false;
	OnClose();
end

-- ===========================================================================
function SetGovernmentClosed()
	isGovernmentOpen = false;
	OnClose();
end

-- ===========================================================================
function SetGovernorPanelClosed()
	isGovernorPanelOpen = false;
	OnClose();
end

-- ===========================================================================
function SetHistoricMomentsClosed()
	isHistoricMomentsOpen = false;
	OnClose();
end

-- ===========================================================================
--	Lua Event
--	Tutorial system is requesting any screen openned, to be closed.
-- ===========================================================================
function OnTutorialCloseAll()
	CloseAllPopups();
end


-- ===========================================================================
--	Game Engine Event
-- ===========================================================================
function OnInterfaceModeChanged(eOldMode:number, eNewMode:number)
	if eNewMode == InterfaceModeTypes.VIEW_MODAL_LENS then
		ContextPtr:SetHide(true);
	end
	if eNewMode == InterfaceModeTypes.CINEMATIC then
		CloseAllPopups();	--	TODO: Remove this and instead change Popup behavior via new parameter. (TTP 43933)
	end

	if eOldMode == InterfaceModeTypes.VIEW_MODAL_LENS then
		ContextPtr:SetHide(false);
	end
end


-- ===========================================================================
--	Refresh Data and View
-- ===========================================================================
function RealizeHookVisibility()
	m_isTechTreeAvailable = isDebug or HasCapability("CAPABILITY_TECH_TREE");
	Controls.ScienceButton:SetShow(m_isTechTreeAvailable);
	Controls.ScienceBolt:SetShow(m_isTechTreeAvailable);

	m_isCivicsTreeAvailable = isDebug or HasCapability("CAPABILITY_CIVICS_TREE");
	Controls.CultureButton:SetShow(m_isCivicsTreeAvailable);
	Controls.CultureBolt:SetShow(m_isCivicsTreeAvailable);

	m_isGreatPeopleAvailable = isDebug or (m_isGreatPeopleUnlocked and HasCapability("CAPABILITY_GREAT_PEOPLE_VIEW") and not IsLocalPlayerObserving());
	Controls.GreatPeopleButton:SetShow(m_isGreatPeopleAvailable);
	Controls.GreatPeopleBolt:SetShow(m_isGreatPeopleAvailable);

	m_isReligionAvailable = isDebug or (m_isReligionUnlocked and HasCapability("CAPABILITY_RELIGION_VIEW") and not IsLocalPlayerObserving());
	Controls.ReligionButton:SetShow(m_isReligionAvailable);
	Controls.ReligionBolt:SetShow(m_isReligionAvailable);

	m_isGreatWorksAvailable = isDebug or (m_isGreatWorksUnlocked and HasCapability("CAPABILITY_GREAT_WORKS_VIEW") and not IsLocalPlayerObserving());
	Controls.GreatWorksButton:SetShow(m_isGreatWorksAvailable);
	Controls.GreatWorksBolt:SetShow(m_isGreatWorksAvailable);

	m_isGovernmentAvailable = isDebug or (m_isGovernmentUnlocked and HasCapability("CAPABILITY_GOVERNMENTS_VIEW") and not IsLocalPlayerObserving());
	Controls.GovernmentButton:SetShow(m_isGovernmentAvailable);
	Controls.GovernmentBolt:SetShow(m_isGovernmentAvailable);

	RealizeBacking();
end

-- ===========================================================================
function OnFaithChanged()
	if (m_isReligionUnlocked) then
		return;
	end
	m_isReligionUnlocked = true;
	RealizeHookVisibility();
end

-- ===========================================================================
function RefreshReligion()
	local ePlayer:number = Game.GetLocalPlayer();
	if ePlayer == -1 then
		-- Likely auto playing.
		return;
	end
	if m_isReligionUnlocked then
		return;
	end
	local localPlayer			:table = Players[ePlayer];
	local playerReligion		:table = localPlayer:GetReligion();
	local hasFaithYield			:boolean = playerReligion:GetFaithYield() > 0;
	local hasFaithBalance		:boolean = playerReligion:GetFaithBalance() > 0;
	if (hasFaithYield or hasFaithBalance) then
		m_isReligionUnlocked = true;
	end
	RealizeHookVisibility();
end

-- ===========================================================================
function OnGreatWorkCreated()
	if (m_isGreatWorksUnlocked) then
		return;
	end
	m_isGreatWorksUnlocked = true;
	RealizeHookVisibility();
end

-- ===========================================================================
function OnDiplomacyDealEnacted()
	if (not m_isGreatWorksUnlocked) then
		RefreshGreatWorks();
	end
end

-- ===========================================================================
--	Capturing a city can also net us pretty great works
function OnCityCaptured()
	if (not m_isGreatWorksUnlocked) then
		RefreshGreatWorks();
	end
end

-- ===========================================================================
function RefreshGreatWorks()
	local ePlayer:number = Game.GetLocalPlayer();
	if ePlayer == -1 then
		-- Likely auto playing.
		return;
	end
	if m_isGreatWorksUnlocked then
		return;
	end
	
	local localPlayer	:table = Players[ePlayer];  
	local pCities		:table = localPlayer:GetCities();
	for i, pCity in pCities:Members() do
		if pCity ~= nil and pCity:GetOwner() == ePlayer then
			
			local pCityBldgs:table = pCity:GetBuildings();
			for buildingInfo in GameInfo.Buildings() do
				local buildingIndex:number = buildingInfo.Index;
				if(pCityBldgs:HasBuilding(buildingIndex)) then
					local numSlots:number = pCityBldgs:GetNumGreatWorkSlots(buildingIndex);
					if (numSlots ~= nil and numSlots > 0) then
						for slotIndex=0, numSlots - 1 do
							local greatWorkIndex:number = pCityBldgs:GetGreatWorkInSlot(buildingIndex, slotIndex);
							if (greatWorkIndex ~= -1) then
								m_isGreatWorksUnlocked = true;
								break;
							end
						end
					end
				end
			end

			if m_isGreatWorksUnlocked then
				break;
			end
		end
	end
	RealizeHookVisibility();
end

-- ===========================================================================
function RefreshGreatPeople()
	local ePlayer:number = Game.GetLocalPlayer();
	if ePlayer == -1 then
		-- Likely auto playing.
		return;
	end
	if m_isGreatPeopleUnlocked then
		return;
	end

	-- Show button if we have any great people in the game
	for greatPerson in GameInfo.GreatPersonIndividuals() do
		m_isGreatPeopleUnlocked = true;
		break;
	end
	RealizeHookVisibility();
end

-- ===========================================================================
function ShowFreePolicyFlag( isFree:boolean )
	Controls.PoliciesAvailableIndicator:SetShow( isFree );
	Controls.PoliciesAvailableIndicator:SetToolTipString( isFree and Locale.Lookup("LOC_HUD_GOVT_FREE_CHANGES") or nil );
end

-- ===========================================================================
--	Game Event
-- ===========================================================================
function OnCivicCompleted(player:number, civic:number, isCanceled:boolean)
	local ePlayer:number = Game.GetLocalPlayer();
	if ePlayer == -1 then
		return;
	end
	if(not m_isGovernmentUnlocked) then
		local playerCulture:table = Players[ePlayer]:GetCulture();
		if (playerCulture:GetNumPoliciesUnlocked() > 0) then
			m_isGovernmentUnlocked = true;
		end
	end
	RealizeHookVisibility();
end

-- ===========================================================================
function RefreshGovernment()
	local playerID:number = Game.GetLocalPlayer();
	if playerID == -1 then return; end

	local kCulture:table = Players[playerID]:GetCulture();
	if ( kCulture:GetNumPoliciesUnlocked() <= 0 ) then
		Controls.GovernmentButton:SetToolTipString(Locale.Lookup("LOC_GOVERNMENT_DOESNT_UNLOCK"));
		Controls.GovernmentButton:GetTextControl():SetColor(UI.GetColorValueFromHexLiteral(0xFF666666));
	else
		m_isGovernmentUnlocked = true;
		Controls.GovernmentButton:SetHide(false);
		Controls.GovernmentBolt:SetHide(false);
		if ( kCulture:IsInAnarchy() ) then
			local iAnarchyTurns = kCulture:GetAnarchyEndTurn() - Game.GetCurrentGameTurn();
			Controls.GovernmentButton:SetDisabled(true);
			Controls.GovernmentIcon:SetColorByName("Civ6Red");
			Controls.GovernmentButton:SetToolTipString("[COLOR_RED]".. Locale.Lookup("LOC_GOVERNMENT_ANARCHY_TURNS", iAnarchyTurns) .. "[ENDCOLOR]");
			ShowFreePolicyFlag( false );
		else
			Controls.GovernmentButton:SetDisabled(false);
			Controls.GovernmentIcon:SetColorByName("White");
			Controls.GovernmentButton:SetToolTipString(Locale.Lookup("LOC_GOVERNMENT_MANAGE_GOVERNMENT_AND_POLICIES"));
			ShowFreePolicyFlag( kCulture:GetCostToUnlockPolicies() == 0 and kCulture:PolicyChangeMade() == false);
		end
	end
	RealizeHookVisibility();
end

-- ===========================================================================
--	Update the background and size of the launchbar itself.
-- ===========================================================================
function RealizeBacking()
	Controls.ButtonStack:CalculateSize();
	local stackWidth:number = Controls.ButtonStack:GetSizeX();

	Controls.LaunchBacking:SetSizeX(stackWidth+116);
	Controls.LaunchBackingTile:SetSizeX(stackWidth-20);
	Controls.LaunchBarDropShadow:SetSizeX(stackWidth);

	-- If the stack is less than a pip (at this writing 7) then there is nothing in it... hide the launchbar
	if stackWidth < 10 then
		stackWidth = 0;
		ContextPtr:SetHide(true);
	else
		if ContextPtr:IsHidden() then
			ContextPtr:SetHide(false);
		end
	end
	
	-- Signal to other contexts (e.g., DiploRibbon)  when size has changed.
	LuaEvents.LaunchBar_Resize( stackWidth );
end

-- ===========================================================================
function UpdateTechMeter( localPlayer:table )
	if ( localPlayer ~= nil and Controls.ScienceHookWithMeter:IsVisible() ) then
		local playerTechs		:table	= localPlayer:GetTechs();
		local currentTechID		:number = playerTechs:GetResearchingTech();

		if(currentTechID >= 0) then
			local progress			:number = playerTechs:GetResearchProgress(currentTechID);
			local cost				:number	= playerTechs:GetResearchCost(currentTechID);
	
			Controls.ScienceMeter:SetPercent(progress/cost);
		else
			Controls.ScienceMeter:SetPercent(0);
		end

		local techInfo:table = GameInfo.Technologies[currentTechID];
		if (techInfo ~= nil) then
			local textureString = "ICON_" .. techInfo.TechnologyType;
			local textureOffsetX, textureOffsetY, textureSheet = IconManager:FindIconAtlas(textureString,38);
			if textureSheet ~= nil then
				Controls.ResearchIcon:SetTexture(textureOffsetX, textureOffsetY, textureSheet);
			end
		end
	else
		Controls.ResearchIcon:SetTexture(0, 0, "LaunchBar_Hook_TechTree");
	end
end

-- ===========================================================================
function UpdateCivicMeter( localPlayer:table)
	if ( localPlayer ~= nil and Controls.CultureHookWithMeter:IsVisible() ) then
		local pPlayerCulture	:table	= localPlayer:GetCulture();
		local currentCivicID    :number = pPlayerCulture:GetProgressingCivic();

		if(currentCivicID >= 0) then
			local civicProgress	:number = pPlayerCulture:GetCulturalProgress(currentCivicID);
			local civicCost		:number	= pPlayerCulture:GetCultureCost(currentCivicID);	
			Controls.CultureMeter:SetPercent(civicProgress/civicCost);
		else
			Controls.CultureMeter:SetPercent(0);
		end

		local CivicInfo:table = GameInfo.Civics[currentCivicID];
		if (CivicInfo ~= nil) then
			local civictextureString = "ICON_" .. CivicInfo.CivicType;
			local civictextureOffsetX, civictextureOffsetY, civictextureSheet = IconManager:FindIconAtlas(civictextureString,38);
			if civictextureSheet ~= nil then
				Controls.CultureIcon:SetTexture(civictextureOffsetX, civictextureOffsetY, civictextureSheet);
			end
		end
	else
		Controls.CultureIcon:SetTexture(0, 0, "LaunchBar_Hook_CivicsTree");
	end
end

-- ===========================================================================
--	Main Refresh
-- ===========================================================================
function RefreshView()
	local localPlayerID :number = Game.GetLocalPlayer();
	if localPlayerID  == -1 then
		return;
	end
	local localPlayer = Players[localPlayerID];
	if (localPlayer == nil) then
		return;
	end

	UpdateTechMeter(localPlayer);
	UpdateCivicMeter(localPlayer);

	RefreshGovernment();
	RefreshGreatWorks();
	RefreshGreatPeople();
	RefreshReligion();

	if BASE_RefreshView == nil then		-- No MODs/Expansions defining this function so its safe to call Realize now.
		RealizeBacking();
	end
end

-- ===========================================================================
--	EVENT
function OnLocalPlayerTurnBegin()
	RefreshView();
end

-- ===========================================================================
--	EVENT
function OnVisualStateRestored()
	RefreshView();
end

-- ===========================================================================
--	EVENT
function OnCivicChanged()
	RefreshView();
end

-- ===========================================================================
--	EVENT
function OnCivicsUnlocked()
	local ePlayer:number = Game.GetLocalPlayer();
	if ePlayer == -1 then
		return;
	end

	-- Check to see if we now have policies to slot.
	-- We do this for scenarios that unlock civics by script.  
	-- Script granted civics do not trigger a CivicCompleted event.
	if(not m_isGovernmentUnlocked) then
		local playerCulture:table = Players[ePlayer]:GetCulture();
		if (playerCulture:GetNumPoliciesUnlocked() > 0) then
			m_isGovernmentUnlocked = true;
			RealizeHookVisibility();
		end
	end
end

-- ===========================================================================
--	EVENT
function OnResearchChanged()
	RefreshView();
end

-- ===========================================================================
--	EVENT
function OnGovernmentRefresh()
	RefreshGovernment();
end

-- ===========================================================================
function OnOpen()
	m_isAutoUnitCycle = false;
	m_numOpen = m_numOpen+1;
	local screenX, screenY:number = UIManager:GetScreenSizeVal();
	if screenY <= 850 then
		Controls.LaunchContainer:SetOffsetY(-35);
	end
	LuaEvents.TradeRouteChooser_CloseIfPopups();
	LuaEvents.LaunchBar_CloseChoosers();
end

-- ===========================================================================
function OnClose()
	m_numOpen = m_numOpen-1;
	if(m_numOpen < 0 )then
		m_numOpen = 0;
	end
	if m_numOpen == 0 then
		Controls.LaunchContainer:SetOffsetY(-5);
	end
	OnOpenTradeRouteDueToAutoCycle(); --open if this popup blocked traderoute from opening
end

-- ===========================================================================
function OnToggleResearchPanel(hideResearch)
	Controls.ScienceHookWithMeter:SetHide(not hideResearch);
	UpdateTechMeter(Players[Game.GetLocalPlayer()]);
end

-- ===========================================================================
function OnToggleCivicPanel(hideResearch)
	Controls.CultureHookWithMeter:SetHide(not hideResearch);
	UpdateCivicMeter(Players[Game.GetLocalPlayer()]);
end

-- ===========================================================================
-- Reset the hooks when the player changes for hotseat.
function OnLocalPlayerChanged()	
	m_isGreatPeopleUnlocked	= false;
	m_isGreatWorksUnlocked	= false;
	m_isReligionUnlocked	= false;	
	m_isGovernmentUnlocked	= false;
	RefreshGovernment();
	RefreshGreatPeople();
	RefreshGreatWorks();
	RefreshReligion();
end

-- ===========================================================================
--	Input Hotkey Event (Extended in XP1 to hook extra panels)
-- ===========================================================================
function OnInputActionTriggered( actionId )
	if ( m_isTechTreeAvailable ) then
		if ( actionId == Input.GetActionId("ToggleTechTree") ) then
			OnOpenResearch();
		end
	end

	if ( m_isCivicsTreeAvailable ) then
		if ( actionId == Input.GetActionId("ToggleCivicsTree") ) then
			OnOpenCulture();
		end
	end

	if ( m_isGovernmentAvailable ) then
		if ( actionId == Input.GetActionId("ToggleGovernment") ) then
			OnOpenGovernment();
		end
	end

	if ( m_isReligionAvailable ) then
		if ( actionId == Input.GetActionId("ToggleReligion") ) then
			OnOpenReligion();
		end
	end
	
	if ( m_isGreatPeopleAvailable ) then
		if ( actionId == Input.GetActionId("ToggleGreatPeople") and UI.QueryGlobalParameterInt("DISABLE_GREAT_PEOPLE_HOTKEY") ~= 1 ) then
			OnOpenGreatPeople();
		end
	end

	if ( m_isGreatWorksAvailable ) then
		if ( actionId == Input.GetActionId("ToggleGreatWorks") and UI.QueryGlobalParameterInt("DISABLE_GREAT_WORKS_HOTKEY") ~= 1 ) then
			OnOpenGreatWorks();
		end
	end	
end

function IsLocalPlayerObserving()
	local localPlayerID : number = Game.GetLocalPlayer();
	if(localPlayerID == PlayerTypes.NONE)then return false; end
	local pPlayer : table = PlayerConfigurations[Game.GetLocalPlayer()]
	return not pPlayer:IsAlive();
end

function OnStartObserverMode()
	RefreshView();
end

-- ===========================================================================
function PlayMouseoverSound()
	UI.PlaySound("Main_Menu_Mouse_Over");
end

-- ===========================================================================
function Unsubscribe()

	Events.AnarchyBegins.Remove( OnGovernmentRefresh );
	Events.AnarchyEnds.Remove( OnGovernmentRefresh );
	Events.CityOccupationChanged.Remove( OnCityCaptured );		-- HACK: Detect GreatWorks acquired via city capture, by hooking this event
	Events.CivicCompleted.Remove( OnCivicCompleted );			-- To capture when we complete Code of Laws
	Events.CivicChanged.Remove( OnCivicChanged );
	Events.CivicsUnlocked.Remove( OnCivicsUnlocked );
	Events.DiplomacyDealEnacted.Remove( OnDiplomacyDealEnacted );
	Events.FaithChanged.Remove( OnFaithChanged );
	Events.GovernmentChanged.Remove( OnGovernmentRefresh );
	Events.GovernmentPolicyChanged.Remove( OnGovernmentRefresh );
	Events.GovernmentPolicyObsoleted.Remove( OnGovernmentRefresh );
	Events.GreatWorkCreated.Remove( OnGreatWorkCreated );
	Events.InputActionTriggered.Remove( OnInputActionTriggered );
	Events.InterfaceModeChanged.Remove( OnInterfaceModeChanged );
	Events.LocalPlayerChanged.Remove( OnLocalPlayerChanged );
	Events.LocalPlayerTurnBegin.Remove( OnLocalPlayerTurnBegin );
	Events.ResearchChanged.Remove(OnResearchChanged);
	Events.TreasuryChanged.Remove( OnGovernmentRefresh );
	Events.VisualStateRestored.Remove( OnVisualStateRestored );

	LuaEvents.CivicsTree_CloseCivicsTree.Remove( SetCivicsTreeClosed );
	LuaEvents.CivicsTree_OpenCivicsTree.Remove( SetCivicsTreeOpen );	
	LuaEvents.EndGameMenu_StartObserverMode.Remove( OnStartObserverMode );
	LuaEvents.Government_CloseGovernment.Remove( SetGovernmentClosed );
	LuaEvents.Government_OpenGovernment.Remove( SetGovernmentOpen );
	LuaEvents.GovernorPanel_Closed.Remove( SetGovernorPanelClosed );
	LuaEvents.GovernorPanel_Opened.Remove( SetGovernorPanelOpen );	
	LuaEvents.GreatPeople_CloseGreatPeople.Remove( SetGreatPeopleClosed );
	LuaEvents.GreatPeople_OpenGreatPeople.Remove( SetGreatPeopleOpen );
	LuaEvents.GreatWorks_CloseGreatWorks.Remove( SetGreatWorksClosed );
	LuaEvents.GreatWorks_OpenGreatWorks.Remove( SetGreatWorksOpen );
	LuaEvents.HistoricMoments_Closed.Remove( SetHistoricMomentsClosed );
	LuaEvents.HistoricMoments_Opened.Remove( SetHistoricMomentsOpened );
	LuaEvents.LaunchBar_CheckPopupsOpen.Remove( OnGetPopupsOpen );
	LuaEvents.Religion_CloseReligion.Remove( SetReligionClosed );
	LuaEvents.Religion_OpenReligion.Remove( SetReligionOpen );	
	LuaEvents.PantheonChooser_CloseReligion.Remove( SetReligionClosed );
	LuaEvents.PantheonChooser_OpenReligion.Remove( SetReligionOpen );	
	LuaEvents.TechTree_CloseTechTree.Remove(SetTechTreeClosed);
	LuaEvents.TechTree_OpenTechTree.Remove( SetTechTreeOpen );
	LuaEvents.Tutorial_CloseAllLaunchBarScreens.Remove( OnTutorialCloseAll );

	if HasCapability("CAPABILITY_TECH_TREE") then
		LuaEvents.WorldTracker_ToggleResearchPanel.Remove( OnToggleResearchPanel );
	end
	if HasCapability("CAPABILITY_CIVICS_TREE") then
		LuaEvents.WorldTracker_ToggleCivicPanel.Remove( OnToggleCivicPanel );
	end
end

-- ===========================================================================
function Subscribe()
	Events.AnarchyBegins.Add( OnGovernmentRefresh );
	Events.AnarchyEnds.Add( OnGovernmentRefresh );
	Events.CityOccupationChanged.Add( OnCityCaptured );		-- HACK: Detect GreatWorks acquired via city capture, by hooking this event
	Events.CivicCompleted.Add( OnCivicCompleted );			-- To capture when we complete Code of Laws
	Events.CivicChanged.Add( OnCivicChanged );
	Events.CivicsUnlocked.Add( OnCivicsUnlocked );
	Events.DiplomacyDealEnacted.Add( OnDiplomacyDealEnacted );
	Events.FaithChanged.Add( OnFaithChanged );
	Events.GovernmentChanged.Add( OnGovernmentRefresh );
	Events.GovernmentPolicyChanged.Add( OnGovernmentRefresh );
	Events.GovernmentPolicyObsoleted.Add( OnGovernmentRefresh );
	Events.GreatWorkCreated.Add( OnGreatWorkCreated );
	Events.InputActionTriggered.Add( OnInputActionTriggered );
	Events.InterfaceModeChanged.Add( OnInterfaceModeChanged );
	Events.LocalPlayerChanged.Add( OnLocalPlayerChanged );
	Events.LocalPlayerTurnBegin.Add( OnLocalPlayerTurnBegin );
	Events.ResearchChanged.Add(OnResearchChanged);
	Events.TreasuryChanged.Add( OnGovernmentRefresh );
	Events.VisualStateRestored.Add( OnVisualStateRestored );

	LuaEvents.CivicsTree_CloseCivicsTree.Add( SetCivicsTreeClosed );
	LuaEvents.CivicsTree_OpenCivicsTree.Add( SetCivicsTreeOpen );	
	LuaEvents.EndGameMenu_StartObserverMode.Add( OnStartObserverMode );
	LuaEvents.Government_CloseGovernment.Add( SetGovernmentClosed );
	LuaEvents.Government_OpenGovernment.Add( SetGovernmentOpen );
	LuaEvents.GovernorPanel_Closed.Add( SetGovernorPanelClosed );
	LuaEvents.GovernorPanel_Opened.Add( SetGovernorPanelOpen );	
	LuaEvents.GreatPeople_CloseGreatPeople.Add( SetGreatPeopleClosed );
	LuaEvents.GreatPeople_OpenGreatPeople.Add( SetGreatPeopleOpen );
	LuaEvents.GreatWorks_CloseGreatWorks.Add( SetGreatWorksClosed );
	LuaEvents.GreatWorks_OpenGreatWorks.Add( SetGreatWorksOpen );
	LuaEvents.HistoricMoments_Closed.Add( SetHistoricMomentsClosed );
	LuaEvents.HistoricMoments_Opened.Add( SetHistoricMomentsOpened );
	LuaEvents.LaunchBar_CheckPopupsOpen.Add( OnGetPopupsOpen );
	LuaEvents.Religion_CloseReligion.Add( SetReligionClosed );
	LuaEvents.Religion_OpenReligion.Add( SetReligionOpen );	
	LuaEvents.PantheonChooser_CloseReligion.Add( SetReligionClosed );
	LuaEvents.PantheonChooser_OpenReligion.Add( SetReligionOpen );	
	LuaEvents.TechTree_CloseTechTree.Add(SetTechTreeClosed);
	LuaEvents.TechTree_OpenTechTree.Add( SetTechTreeOpen );
	LuaEvents.Tutorial_CloseAllLaunchBarScreens.Add( OnTutorialCloseAll );

	if HasCapability("CAPABILITY_TECH_TREE") then
		LuaEvents.WorldTracker_ToggleResearchPanel.Add( OnToggleResearchPanel );
	end
	if HasCapability("CAPABILITY_CIVICS_TREE") then
		LuaEvents.WorldTracker_ToggleCivicPanel.Add( OnToggleCivicPanel );
	end
end

-- ===========================================================================
function LateInitialize()
	Subscribe();
	RefreshView();
end

-- ===========================================================================
--	Called after all contexts (this and replacement contexts) are loaded.
-- ===========================================================================
function OnInit( isReload:boolean )
	LateInitialize();
end

-- ===========================================================================
function Initialize()

	ContextPtr:SetInitHandler( OnInit );

	Controls.CultureButton:RegisterCallback(Mouse.eLClick, OnOpenCulture);
	Controls.CultureButton:RegisterCallback( Mouse.eMouseEnter, PlayMouseoverSound);
	Controls.GovernmentButton:RegisterCallback( Mouse.eLClick, OnOpenGovernment );
	Controls.GovernmentButton:RegisterCallback( Mouse.eMouseEnter, PlayMouseoverSound);
	Controls.GreatPeopleButton:RegisterCallback( Mouse.eLClick, OnOpenGreatPeople );
	Controls.GreatPeopleButton:RegisterCallback( Mouse.eMouseEnter, PlayMouseoverSound);
	Controls.GreatWorksButton:RegisterCallback( Mouse.eLClick, OnOpenGreatWorks );
	Controls.GreatWorksButton:RegisterCallback( Mouse.eMouseEnter, PlayMouseoverSound);
	Controls.ReligionButton:RegisterCallback( Mouse.eLClick, OnOpenReligion );
	Controls.ReligionButton:RegisterCallback( Mouse.eMouseEnter, PlayMouseoverSound);
	Controls.ScienceButton:RegisterCallback(Mouse.eLClick, OnOpenResearch);
	Controls.ScienceButton:RegisterCallback( Mouse.eMouseEnter, PlayMouseoverSound);
end
Initialize();
