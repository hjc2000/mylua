-- 线轴转的圈数
function Reel_n()
	-- 减速比 = 编码器转的圈数 / 线轴转的圈数
	-- 线轴转的圈数 = 编码器转的圈数 / 减速比
	local n = Encoder_n() / Transmission_ReductionRatioNum() * Transmission_ReductionRatioDen()
	return FloatToInt(n)
end

-- 空卷周长。单位：mm
function Reel_C0()
	if (DD(105) <= 0) then
		DD(105, 1)
	end

	return DD(105)
end

-- 满卷周长。单位：mm
function Reel_C1()
	if (DD(106) <= Reel_C0()) then
		DD(106, Reel_C0())
	end

	return DD(106)
end

-- 从满卷到空卷的圈数
function Reel_N()
	if (DD(107) <= 0) then
		DD(107, 100)
	end

	return DD(107)
end
