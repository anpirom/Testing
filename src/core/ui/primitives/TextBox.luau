local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local UITypes = require(ReplicatedStorage.Source.Core.UI.UITypes)
local e = React.createElement

export type TextBoxProps = UITypes.GenericUIProps & {
	Text: string?,
	ClearTextOnFocus: boolean?,
	TextEditable: boolean?,
	PlaceholderText: string?,
	PlaceholderColor3: Color3?,
	TextSize: number?,
	TextColor3: Color3?,
	TextScaled: boolean?,
	TextWrapped: boolean?,
	TextXAlignment: Enum.TextXAlignment?,
	children: React.ReactNode?,
	NumbersOnly: boolean?,
	LettersOnly: boolean?,
	LettersAndNumbersOnly: boolean?,
	MaxCharacters: number?,
	CapsLock: boolean?,
	FocusLost: ((textbox: TextBox, enterPressed: boolean) -> ())?,
}

local DEFAULTS = {
	Text = "",
	Font = Enum.Font.BuilderSansExtraBold,
	ClearTextOnFocus = false,
	TextEditable = true,
	PlaceholderText = "",
	PlaceholderColor3 = Color3.fromRGB(194, 194, 194),
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextScaled = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
}

local CUSTOM_PROPS =
	{ "children", "NumbersOnly", "LettersOnly", "LettersAndNumbersOnly", "MaxCharacters", "CapsLock", "FocusLost" }

return React.forwardRef(function(props: TextBoxProps, ref)
	local textboxRef = React.useRef(nil :: TextBox?)

	local safeProps = Sift.Dictionary.removeKeys(props, unpack(CUSTOM_PROPS))
	for i, v in DEFAULTS do
		if safeProps[i] == nil then
			safeProps[i] = v
		end
	end

	safeProps.ref = React.useCallback(function(instance)
		textboxRef.current = instance
		if ref then
			if typeof(ref) == "function" then
				ref(instance)
			else
				ref.current = instance
			end
		end
	end, { ref })

	safeProps[React.Change.Text] = React.useCallback(function(textbox: TextBox)
		local newText = textbox.Text
		if props.MaxCharacters and newText:len() > props.MaxCharacters then
			newText = newText:sub(1, props.MaxCharacters)
		end

		if props.CapsLock then
			newText = newText:upper()
		end

		if props.NumbersOnly then
			newText = newText:gsub("[^%d]", "")
		elseif props.LettersOnly then
			newText = newText:gsub("[^%a]", "")
		elseif props.LettersAndNumbersOnly then
			newText = newText:gsub("[^%w]", "")
		end

		if newText ~= textbox.Text then
			textbox.Text = newText
		end
	end, { props })

	safeProps[React.Event.FocusLost] = props.FocusLost

	return e("TextBox", safeProps, props.children)
end)
