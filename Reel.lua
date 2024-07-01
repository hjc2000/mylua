-- 获取线轴已放出的圈数的偏移量
function Reel_ReleasedRotationsOffset()
	return DD(101)
end

-- 设置线轴已放出的圈数的偏移量
function Reel_SetReleasedRotationsOffset(value)
	DD(101, value)
end

-- 线轴已放出的圈数 = 偏移量 + 通过累计脉冲数缓存算出来的圈数
function Reel_n()
	return IntDiv(Encoder_CumulativePulseCache(), Encoder_PulsePerRotation())
		+ Reel_ReleasedRotationsOffset()
end

-- 重置已放出的圈数
function Reel_ResetReleasedRotations()
	-- 设置为 -IntDiv(Encoder_CumulativePulseCache(), Encoder_PulsePerRotation())
	-- 才能使 Reel_n 为 0
	Reel_SetReleasedRotationsOffset(-IntDiv(Encoder_CumulativePulseCache(), Encoder_PulsePerRotation()))
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
