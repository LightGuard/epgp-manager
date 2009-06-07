manager = LibStub("AceAddon-3.0"):NewAddon("manager", "AceConsole-3.0", "AceEvent-3.0")
AceGUI = LibStub("AceGUI-3.0")

-- AceGUI 
do
  local mainFrame

  function manager:CreateFrame()
    mainFrame = AceGUI:Create("Frame")
    mainFrame:SetTitle("EPGP Manager")
    mainFrame:SetStatusText("by LightGuard <Knights of Dragons Keep> Galaronk")
    mainFrame:SetCallback("OnClose", function(widget) widget:Hide() end)
    mainFrame:SetLayout("Fill")
    mainFrame:SetWidth(600) 
  end

  -- Event Handlers
  function manager:LOOT_OPENED() 
    -- How many items are there to loot?
    if (mainFrame == nil) then manager:CreateFrame() end

    mainFrame:Show()

    local lootableItemNum = GetNumLootItems()
    local lootTable = {}

    if (lootableItemNum > 0) then
      for i = 1, lootableItemNum do
        local texture, item, quantity, quality, locked = GetLootSlotInfo(i) 
        local link = select(2, GetItemInfo(item)) 

        tinsert(lootTable, {value = i, text = link, icon = texture})

        local lootTree = AceGUI:Create("TreeGroup")
        lootTree:SetCallback("OnGroupSelected", function(tree, event, selected)
          lootTree:ReleaseChildren()
          local texture, item, quantity, quality, locked = GetLootSlotInfo(selected) 
          local link = select(2, GetItemInfo(item)) 
          local actionGroup = AceGUI:Create("InlineGroup")
          local playersGroup = AceGUI:Create("InlineGroup")
          local requestRoll = AceGUI:Create("Button")
          local endRequestRoll = AceGUI:Create("Button")
          local assignSelected = AceGUI:Create("Button")
          local itemIcon = AceGUI:Create("Icon")

          itemIcon:SetImage(texture)
          itemIcon:SetWidth(250)
          itemIcon:SetLabel(link)
          itemIcon:SetCallback("OnEnter", function() 
            if (LootSlotIsItem(selected)) then
              GameTooltip:SetOwner(itemIcon.frame, "ANCHOR_RIGHT")
              GameTooltip:SetLootItem(selected)
              CursorUpdate(self)
            end 
          end)
          itemIcon:SetCallback("OnLeave", function() GameTooltip:Hide() end) 

          requestRoll:SetText("Start Roll Requests")
          assignSelected:SetText("Assign to Selected")
          endRequestRoll:SetText("End Roll Request Accept")

          actionGroup:SetTitle("Loot Actions")
          actionGroup:SetLayout("Flow") 
          actionGroup:AddChild(itemIcon)
          actionGroup:AddChild(requestRoll)
          actionGroup:AddChild(endRequestRoll)
          actionGroup:AddChild(assignSelected)

          playersGroup:SetTitle("Players")
          playersGroup:SetLayout("flow")

          lootTree:AddChild(actionGroup)
          lootTree:AddChild(playersGroup)
        end)
        lootTree:SetTree(lootTable) 
        mainFrame:AddChild(lootTree)
      end
    end 
  end

  function manager:LOOT_CLOSED() 
    mainFrame:ReleaseChildren()
    mainFrame:Hide()
  end
end

function manager:OnInitialize()
  -- Called when the addon is loaded
end

function manager:OnEnable()
  -- Called when the addon is enabled
  self:RegisterEvent("LOOT_OPENED")
  self:RegisterEvent("LOOT_CLOSED")
end

function manager:OnDisable()
  -- Called when the addon is disabled
end 

-- DEBUG
function table_print (tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    local sb = {}
    for key, value in pairs (tt) do
      table.insert(sb, string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true
        table.insert(sb, "{\n");
        table.insert(sb, table_print (value, indent + 2, done))
        table.insert(sb, string.rep (" ", indent)) -- indent it
        table.insert(sb, "}\n");
      elseif "number" == type(key) then
        table.insert(sb, string.format("\"%s\"\n", tostring(value)))
      else
        table.insert(sb, string.format(
        "%s = \"%s\"\n", tostring (key), tostring(value)))
      end
    end
    return table.concat(sb)
  else
    return tt .. "\n"
  end
end

function to_string( tbl )
  if  "nil"       == type( tbl ) then
    return tostring(nil)
  elseif  "table" == type( tbl ) then
    return table_print(tbl)
  elseif  "string" == type( tbl ) then
    return tbl
  else
    tostring(tbl)
  end
end
