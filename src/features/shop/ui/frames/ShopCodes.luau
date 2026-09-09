local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local TextBox = require(ReplicatedStorage.Source.Core.UI.Primitives.TextBox)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local StudButton = require(ReplicatedStorage.Source.Features.App.UI.Components.StudButton)
local CodeServiceClient = require(ReplicatedStorage.Source.Features.Codes.CodeServiceClient)
local ShopContentFrame = require(ReplicatedStorage.Source.Features.Shop.UI.Components.ShopContentFrame)
local ShopFrame = require(ReplicatedStorage.Source.Features.Shop.UI.Components.ShopFrame)
local e = React.createElement

return function()
	local ref = React.useRef(nil :: TextBox?)
	local resultText, setResultText = React.useBinding("")
	local resultTextColor3, setResultTextColor3 = React.useBinding(Color3.fromRGB(255, 255, 255))

	local redeem = React.useCallback(function()
		if not ref.current then
			return
		end

		local code = ref.current.Text
		if code == "" then
			return
		end

		local success, message = CodeServiceClient:redeem(code)
		if success then
			setResultTextColor3(Color3.fromRGB(92, 255, 92))
		else
			setResultTextColor3(Color3.fromRGB(255, 64, 64))
		end
		setResultText(message)
		task.wait(3)
		if resultText:getValue() == message then
			setResultText("")
		end
	end, { ref })

	return e(ShopContentFrame, {
		Text = "Codes",
		LayoutOrder = 50,
	}, {
		e(ShopFrame.Blue, {
			Size = UDim2.fromOffset(768, 160),
		}, {
			e(TextLabel, {
				Text = "Follow socials for codes!",
				Size = UDim2.fromOffset(500, 42),
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromScale(0.5, 0.05),
				Stroke = { Thickness = 3, Color = Color3.fromRGB(16, 16, 20) },
			}),

			e(TextLabel, {
				Text = resultText,
				Size = UDim2.fromOffset(200, 30),
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromScale(0.5, 0.35),
				TextColor3 = resultTextColor3,
				Stroke = { Thickness = 2, Color = Color3.fromRGB(16, 16, 20) },
			}),

			e(StudButton.Green, {
				Text = "Redeem",
				Position = UDim2.fromScale(0.86, 0.725),
				Size = UDim2.fromOffset(175, 60),
				AnchorPoint = Vector2.new(0.5, 0.5),
				hoverScale = 1.05,
				Activated = redeem,
			}),

			e(ShopFrame.Grey, {
				Size = UDim2.fromScale(0.7, 0.35),
				Position = UDim2.fromScale(0.03, 0.9),
				AnchorPoint = Vector2.new(0, 1),
			}, {
				e(TextBox, {
					ref = ref,
					FocusLost = function(_, enterPressed)
						if enterPressed then
							redeem()
						end
					end,
					Size = UDim2.fromScale(0.97, 0.875),
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					PlaceholderText = "Enter Code Here",
					ClearTextOnFocus = true,
					TextSize = 20,
					TextStrokeTransparency = 0,
					PlaceholderColor3 = Color3.fromRGB(216, 216, 219),
					TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
				}),
			}),
		}),
	})
end
