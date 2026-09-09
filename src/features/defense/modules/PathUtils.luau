export type Path = {
	length: number,
	nodes: { CFrame },
}

local PathUtils = {}

local EPS = 1e-8

function PathUtils.calcpath(pathFolder: Model & any): Path
	local nonLerpedNodes = {}
	local iNode = 1

	while true do
		local nodePart = pathFolder:FindFirstChild(tostring(iNode))
		if not nodePart then
			break
		end

		nodePart.Transparency = 1
		table.insert(nonLerpedNodes, nodePart.Position)
		iNode += 1
	end

	-- Sample positions every 1 stud along the polyline
	local lerpedPositions = { nonLerpedNodes[1] }
	local totalLength = 0
	local cursorPos = nonLerpedNodes[1]
	local carry = 0

	for i = 2, #nonLerpedNodes do
		local goal = nonLerpedNodes[i]
		local segment = goal - cursorPos
		local segmentLen = segment.Magnitude

		if segmentLen <= EPS then
			cursorPos = goal
			continue
		end

		local dir = segment / segmentLen
		totalLength += segmentLen

		local remainingOnSegment = segmentLen

		while remainingOnSegment + carry >= 1 do
			local need = 1 - carry
			cursorPos = cursorPos + dir * need
			table.insert(lerpedPositions, cursorPos)
			remainingOnSegment -= need
			carry = 0
		end

		carry += remainingOnSegment
		cursorPos = goal
	end

	-- Ensure final endpoint is included
	local lastOriginal = nonLerpedNodes[#nonLerpedNodes]
	local lastSample = lerpedPositions[#lerpedPositions]
	if (lastOriginal - lastSample).Magnitude > 1e-4 then
		table.insert(lerpedPositions, lastOriginal)
	end

	-- Convert sampled positions -> oriented CFrames (facing next sample)
	local cframes = table.create(#lerpedPositions)

	for i = 1, #lerpedPositions - 1 do
		local p0 = lerpedPositions[i]
		local p1 = lerpedPositions[i + 1]
		local delta = p1 - p0

		-- Yaw-only facing (prevents pitching/rolling)
		local flat = Vector3.new(delta.X, 0, delta.Z)

		if flat.Magnitude <= EPS then
			-- Degenerate: fall back to a neutral rotation at this point
			cframes[i] = CFrame.new(p0)
		else
			cframes[i] = CFrame.lookAt(p0, p0 + flat, Vector3.yAxis)
		end

		-- If you *want* pitch for elevation changes, replace the above with:
		-- cframes[i] = CFrame.lookAt(p0, p1, Vector3.yAxis)
	end

	-- Last node: keep the last segment's facing if possible
	local lastIndex = #lerpedPositions
	if lastIndex == 1 then
		cframes[1] = CFrame.new(lerpedPositions[1])
	else
		local lastPos = lerpedPositions[lastIndex]
		local prevPos = lerpedPositions[lastIndex - 1]
		local delta = lastPos - prevPos
		local flat = Vector3.new(delta.X, 0, delta.Z)

		if flat.Magnitude > EPS then
			cframes[lastIndex] = CFrame.lookAt(lastPos, lastPos + flat, Vector3.yAxis)
		else
			local prevCf = cframes[lastIndex - 1]
			-- Same rotation as previous, updated position
			cframes[lastIndex] = CFrame.fromMatrix(lastPos, prevCf.RightVector, prevCf.UpVector, prevCf.BackVector)
		end
	end

	return {
		length = totalLength,
		nodes = cframes,
	}
end

function PathUtils.calcPaths(defenseModel: Model & any): { Path }
	local paths = {}

	for _, floorFolder in defenseModel.Floors:GetChildren() do
		local pathFolder = floorFolder.Path
		local path = PathUtils.calcpath(pathFolder)
		paths[tonumber(floorFolder.Name)] = path
	end

	return paths
end

function PathUtils.getCFrameFromDist(path: Path, dist: number): CFrame
	if path == nil then
		return CFrame.new()
	end

	-- Clamp to [0, path.length] to avoid out-of-range
	if dist <= 0 then
		return path.nodes[1]
	end
	if dist >= path.length then
		return path.nodes[#path.nodes]
	end

	local baseIndex = math.floor(dist) + 1
	local currentCf = path.nodes[baseIndex]
	local nextCf = path.nodes[baseIndex + 1]
	if not nextCf then
		return currentCf
	end

	local alpha = dist - math.floor(dist)
	return currentCf:Lerp(nextCf, alpha)
end

function PathUtils.getPosFromDist(path: Path, dist: number): Vector3
	return PathUtils.getCFrameFromDist(path, dist).Position
end

return PathUtils
