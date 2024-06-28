-- 获取线轴已放出的圈数的偏移量
function Reel_ReleasedRotationsOffset()
	return DD(101)
end

-- 设置线轴已放出的圈数的偏移量
function Reel_SetReleasedRotationsOffset(value)
	DD(101, value)
end

-- 线轴已放出的圈数 = 偏移量 + 通过累计脉冲数缓存算出来的圈数
function Reel_ReleasedRotations()
	return IntDiv(Encoder_CumulativePulseCache(), Encoder_PulsePerRotation())
		+ Reel_ReleasedRotationsOffset()
end

-- 空卷周长。单位：mm
function Reel_C0()
	if (DF(105) <= 0) then
		DF(105, 1)
	end

	return DF(105)
end

-- 满卷周长。单位：mm
function Reel_C1()
	if (DF(106) <= Reel_C0()) then
		DF(106, Reel_C0())
	end

	return DF(106)
end

-- 从满卷到空卷的圈数
function Reel_N()
	if (DD(107) <= 0) then
		DD(107, 100)
	end

	return DD(107)
end

-- 空卷半径
function Reel_R0()
	return Reel_C0() / (2 * math.pi)
end

-- 满卷半径
function Reel_R1()
	return Reel_C1() / (2 * math.pi)
end

-- 在当前位置的基础上，线轴再转一圈放出的弧长。单位：mm
function Reel_DeltaS()
	-- Δs = 2 * pi * r
	-- r = R1 - D * n
	-- D = (r1 - r0) / N
	local d = (Reel_R1() - Reel_R0()) / Reel_N()
	local r = Reel_R1() - Reel_ReleasedRotations() * d
	return 2 * math.pi * r
end
