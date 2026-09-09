local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local DataService = require(ReplicatedStorage.Packages.DataService).client
local React = require(ReplicatedStorage.Packages.React)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)
local useAbsSize = require(ReplicatedStorage.Source.Core.UI.Hooks.useAbsSize)
local useDataState = require(ReplicatedStorage.Source.Core.UI.Hooks.useDataState)
local useDeviceInput = require(ReplicatedStorage.Source.Core.UI.Hooks.useDeviceInput)
local AutoScaledFrame = require(ReplicatedStorage.Source.Core.UI.Primitives.AutoScaledFrame)
local Button = require(ReplicatedStorage.Source.Core.UI.Primitives.Button)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local InventoryServiceClient = require(ReplicatedStorage.Source.Features.Inventory.InventoryServiceClient)
local InventorySlice = require(ReplicatedStorage.Source.Features.Inventory.InventorySlice)
local InventoryButton = require(ReplicatedStorage.Source.Features.Inventory.UI.Components.InventoryButton)
local ItemButtonStroke = require(ReplicatedStorage.Source.Features.Inventory.UI.Components.ItemButtonStroke)
local ItemIcon = require(ReplicatedStorage.Source.Features.Inventory.UI.Components.ItemIcon)
local useItemDragger = require(ReplicatedStorage.Source.Features.Inventory.UI.Hooks.useItemDragger)
local useSlotSize = require(ReplicatedStorage.Source.Features.Inventory.UI.Hooks.useSlotSize)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local e = React.createElement

local UNUSED_SLOT_SIZE = 75 / 95
local MAX_SLOTS = 9
local NULL = "NULL"

type HotbarSlotProps = {
	index: number,
}

local function useHotBarItemData(index: number)
	local uniqueId = useDataState({ "hotbar", index })
	local itemData, setItemData = React.useState(nil)

	React.useEffect(function()
		if uniqueId == NULL or not uniqueId then
			setItemData(nil)
			return
		end

		local function update()
			local val = DataService:get({ "inventory", uniqueId })
			if type(val) == "table" then
				setItemData(table.clone(val))
			else
				setItemData(val)
			end
		end

		update()
		local conn = DataService:getChangedSignal({ "inventory", uniqueId }):Connect(update)

		return function()
			conn:Destroy()
		end
	end, { uniqueId })

	return itemData
end

local function HotbarSlot(props: HotbarSlotProps)
	local open = ReactCharm.useAtom(InventorySlice.state.backpackOpen)
	local uniqueId: string = useDataState({ "hotbar", props.index })
	local itemData = useHotBarItemData(props.index)
	local inputDevice = useDeviceInput()
	local setDragStart = useItemDragger(uniqueId)
	local isDragging = ReactCharm.useAtom(InventorySlice.state.draggingItemUniqueId) ~= nil
	local hoveredSlot = ReactCharm.useAtom(InventorySlice.state.hoveredSlot)
	local equippedUniqueId = ReactCharm.useAtom(InventorySlice.state.equippedItemUniqueId)
	local equipped = equippedUniqueId == uniqueId

	if not itemData and not open then
		return nil
	end

	return e("Frame", {
		Size = if not itemData then UDim2.fromScale(UNUSED_SLOT_SIZE, UNUSED_SLOT_SIZE) else UDim2.fromScale(1, 1),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		LayoutOrder = props.index,
		BackgroundTransparency = 0.2,
		BackgroundColor3 = if hoveredSlot == props.index
			then Color3.fromRGB(60, 62, 66)
			else Color3.fromRGB(37, 38, 41),
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0.1, 0),
		}),

		ItemIcon = if itemData
			then e(ItemIcon, {
				itemData = itemData,
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
			})
			else nil,

		SlotNum = if inputDevice == Enum.PreferredInput.KeyboardAndMouse
			then e(TextLabel, {
				Text = props.index,
				Size = UDim2.fromScale(0.25, 0.25),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				AnchorPoint = Vector2.new(0, 0),
				Position = UDim2.fromScale(0, 0),
				Stroke = { Color = Color3.fromRGB(20, 20, 20), Thickness = 2 },
				ZIndex = 5,
			})
			else nil,

		Stroke = if itemData then e(ItemButtonStroke, { equipped = equipped, partData = itemData }) else nil,

		Btn = e(Button, {
			hoverScale = 1,
			Size = UDim2.fromScale(1.1, 1.1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			Activated = function()
				if itemData then
					local isEquipped = equippedUniqueId == uniqueId
					if isEquipped then
						InventoryServiceClient:unequipItem()
					else
						InventoryServiceClient:equipItem(uniqueId)
					end
				end
			end,
			OnDown = function()
				if itemData then
					setDragStart(UserInputService:GetMouseLocation())
				end
			end,
			OnEnter = function()
				if isDragging then
					InventorySlice.state.hoveredSlot(props.index)
				end
			end,
			OnLeave = function()
				task.delay(0.1, function() -- weird roblox issue on mobile, idk
					if isDragging and InventorySlice.state.hoveredSlot() == props.index then
						InventorySlice.state.hoveredSlot(nil)
					end
				end)
			end,
		}),
	})
end

local function Hotbar()
	local ref = React.useRef(nil :: Frame?)
	local slotSize = useSlotSize()
	local absSize = useAbsSize(ref)
	local numSlots = math.min(MAX_SLOTS, absSize.X // slotSize)
	local slots = React.useMemo(function()
		local result = {}
		for i = 1, numSlots do
			result[i] = e(HotbarSlot, { index = i })
		end
		return result
	end, { numSlots })

	return e("Frame", {
		Size = UDim2.new(1, 0, 0, slotSize),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 1),
		BackgroundTransparency = 1,
		ref = ref,
		LayoutOrder = 3,
	}, {
		Layout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 5),
		}),
	}, slots)
end

local function InventoryButtons()
	local inventory = useDataState("inventory")
	local buttons = {}
	for uniqueId, itemData in inventory do
		buttons[uniqueId] = e(InventoryButton, { itemData = itemData, uniqueId = uniqueId })
	end

	return buttons
end

local function Tab(props)
	return e(Button, {
		hoverScale = 1,
		Size = UDim2.fromScale(1, 1),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		BackgroundColor3 = Color3.fromRGB(37, 38, 41),
		BackgroundTransparency = 0.2,
		LayoutOrder = props.layout,
		Activated = function()
			InventorySlice.state.tab(props.tab)
		end,
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),

		txt = if props.tab == "all"
			then e(TextLabel, {
				Text = "ALL",
				Size = UDim2.fromScale(0.55, 0.55),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				TextColor3 = Color3.fromRGB(229, 232, 238),
				BackgroundTransparency = 1,
				DropShadow = { Color = Color3.fromRGB(17, 17, 17), Transparency = 0.8 },
			})
			else nil,

		Image = e("ImageLabel", {
			Image = props.icon,
			Size = UDim2.fromScale(0.75, 0.75),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			ZIndex = 2,
		}),

		Bg = e("ImageLabel", {
			Image = props.icon,
			Size = UDim2.fromScale(0.75, 0.75),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.55),
			BackgroundTransparency = 1,
			ImageColor3 = Color3.fromRGB(17, 17, 17),
			ImageTransparency = 0.8,
		}),
	})
end

local function Tabs()
	return e("Frame", {
		Size = UDim2.new(0, 66, 1, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(0, -6, 0.5, 0),
		BackgroundTransparency = 1,
	}, {
		Layout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6),
		}),

		AllTab = e(Tab, { tab = "all", layout = 1, icon = "" }),
		TowersTab = e(Tab, { tab = "towers", layout = 2, icon = Towers.getTowerInfo("crossbow").image }),
		CratesTab = e(Tab, { tab = "crates", layout = 3, icon = Towers.getTowerInfo("crossbow").crateImage }),
		FavTab = e(Tab, { tab = "favorites", layout = 4, icon = ImageIds.heart }),
	})
end

local function SearchBox()
	local ref = React.useRef(nil :: TextBox?)
	React.useEffect(function()
		if not ref.current then
			return
		end

		local conn = ref.current:GetPropertyChangedSignal("Text"):Connect(function()
			local txt = ref.current.Text
			if txt == "" then
				txt = nil
			end
			InventorySlice.state.searchQuery(txt)
		end)

		return function()
			conn:Disconnect()
		end
	end, { ref })

	return e("TextBox", {
		ref = ref,
		Size = UDim2.fromOffset(200, 42),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(0.9, 0, 0, 8),
		BackgroundColor3 = Color3.fromRGB(217, 219, 227),
		BackgroundTransparency = 0.8,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		PlaceholderText = "Search",
		Text = "",
		TextScaled = true,
		Font = Enum.Font.BuilderSansExtraBold,
		ClipsDescendants = true,
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),

		Padding = e("UIPadding", {
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 3),
			PaddingBottom = UDim.new(0, 3),
		}),
	})
end

local function TitleText()
	local tab = ReactCharm.useAtom(InventorySlice.state.tab)
	return e(TextLabel, {
		Text = if tab == "towers"
			then "Towers"
			elseif tab == "crates" then "Crates"
			elseif tab == "favorites" then "Favorites"
			else "Backpack",
		Size = UDim2.fromOffset(250, 36),
		Position = UDim2.new(0, 15, 0.02, 0),
		TextColor3 = Color3.fromRGB(229, 232, 238),
		Stroke = {},
		TextXAlignment = Enum.TextXAlignment.Left,
		Prefix = if tab ~= "all"
			then {
				Image = if tab == "towers"
					then Towers.getTowerInfo("crossbow").image
					elseif tab == "crates" then Towers.getTowerInfo("crossbow").crateImage
					else ImageIds.heart,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
			}
			else nil,
	})
end

local function InventoryFrame(props)
	local scrollable = ReactCharm.useAtom(InventorySlice.state.inventoryScrollable)

	return e(AutoScaledFrame, {
		Visible = props.open,
		Size = UDim2.fromOffset(700, 300),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(37, 38, 41),
		BackgroundTransparency = 0.2,
		LayoutOrder = 2,
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		Tabs = e(Tabs),
		SearchBox = e(SearchBox),
		TitleText = e(TitleText),

		ScrollingFrame = e("ScrollingFrame", {
			Size = UDim2.fromScale(0.98, 0.8),
			Position = UDim2.fromScale(0.5, 0.98),
			AnchorPoint = Vector2.new(0.5, 1),
			BorderSizePixel = 0,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ScrollBarThickness = 0,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			Interactable = scrollable,
			Active = scrollable,
		}, {
			Layout = e("UIGridLayout", {
				CellSize = UDim2.fromOffset(80, 80),
				CellPadding = UDim2.fromOffset(5, 5),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			Padding = e("UIPadding", {
				PaddingTop = UDim.new(0, 5),
				PaddingBottom = UDim.new(0, 5),
				PaddingLeft = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 5),
			}),

			InventoryButtons = e(InventoryButtons),
		}),

		X = e(Button, {
			hoverScale = 1,
			Size = UDim2.fromOffset(60, 60),
			Position = UDim2.fromScale(1, 0),
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			Activated = function()
				InventorySlice.state.backpackOpen(false)
			end,
		}, {
			Text = e(TextLabel, {
				Text = "X",
				Size = UDim2.fromScale(0.8, 0.8),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
				Stroke = {},
			}),
		}),
	})
end

return function()
	local open = ReactCharm.useAtom(InventorySlice.state.backpackOpen)

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		Size = UDim2.new(0.6, 0, 0, 200),
		Position = UDim2.new(0.5, 0, 1, -6),
		BackgroundTransparency = 1,
	}, {
		Layout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6),
		}),

		Hotbar = e(Hotbar),

		Inventory = e(InventoryFrame, { open = open }),

		OpenButton = e(
			AutoScaledFrame,
			{
				Visible = not open,
				Size = UDim2.fromOffset(150, 40),
				Position = UDim2.fromScale(0.5, 0.375),
				LayoutOrder = 1,
				AnchorPoint = Vector2.new(0.5, 0.5),
			},
			e(Button, {
				hoverScale = 1.1,
				Size = UDim2.fromScale(1, 1),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 0.5,
				BackgroundColor3 = Color3.fromRGB(20, 20, 20),
				Activated = function()
					InventorySlice.state.backpackOpen(true)
				end,
			}, {
				Stroke = e("UIStroke", {

					Color = Color3.fromRGB(0, 0, 0),
					Thickness = 2,
				}),

				Text = e(TextLabel, {
					Text = "Open Backpack",
					Size = UDim2.fromScale(0.9, 0.6),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Stroke = {},
				}),
			})
		),
	})
end
