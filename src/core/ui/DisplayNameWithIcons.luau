return function(player: Player): string
	local displayNamePrefix = ""
	if player.HasVerifiedBadge then
		displayNamePrefix = utf8.char(0xe000) .. " "
	end
	if player.MembershipType == Enum.MembershipType.Premium then
		displayNamePrefix ..= utf8.char(0xe001) .. " "
	end

	return displayNamePrefix .. player.DisplayName
end
