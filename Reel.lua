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
