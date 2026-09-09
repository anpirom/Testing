local Suffixes = require(script.Parent.Suffixes)
local DEFAULT_SHOWN_DIGITS = 3

return function(n: number, numShownDigits: number?)
	local prefix = ""
	numShownDigits = numShownDigits or DEFAULT_SHOWN_DIGITS

	if n < 0 then
		n = math.abs(n)
		prefix = "-"
	end

	--string formatted integer
	local int = ("%.0f"):format(n)
	local numDigits = #int

	if numDigits <= 3 then
		return prefix .. int
	end

	local suffix: string? = Suffixes[math.ceil(numDigits / 3)]
	local decimalPosition = (numDigits - 1) % 3 + 1

	if not suffix then
		suffix = "e" .. math.ceil((numDigits - 3) / 3) * 3
	end

	-- construct the abbreviated number
	local abbreviatedNumber = string.sub(int, 1, decimalPosition)
	if decimalPosition < numShownDigits then
		abbreviatedNumber ..= "." .. string.sub(int, decimalPosition + 1, numShownDigits)
	end

	return prefix .. abbreviatedNumber .. suffix
end
