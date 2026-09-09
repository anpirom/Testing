local Abbreviate = require(script.Parent.Abbreviate)
return function(n: number): string
	if n >= 10e6 then
		return "$" .. Abbreviate(n, 5)
	end

	local str = tostring(math.round(n))

	-- Handle sign
	local sign = ""
	if string.sub(str, 1, 1) == "-" then
		sign = "-"
		str = string.sub(str, 2)
	end

	-- Insert commas
	while true do
		local newStr, count = str:gsub("^(%d+)(%d%d%d)", "%1,%2")
		str = newStr
		if count == 0 then
			break
		end
	end

	return sign .. "$" .. str
end
