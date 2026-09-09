local MAX_SEARCHES = 100

return function(page: DataStorePages): () -> (number?, number?)
	local i = 0
	local data = page:GetCurrentPage()
	return function(): (number?, number?)
		i += 1

		if i > MAX_SEARCHES then
			return
		end

		local value = data[i]

		if not value then
			if page.IsFinished then
				return
			end

			local success, err = pcall(function()
				page:AdvanceToNextPageAsync()
			end)

			if not success then
				warn("Failed to get next page of leaderboard data:\n", err)
				return
			end

			data = page:GetCurrentPage()
		end

		return value.key, value.value
	end
end
