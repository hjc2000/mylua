-- 编码器转一圈发出的脉冲数
function Encoder_PulsePerRotation()
	return IntPow(2, 17)
end

-- 获取储存在非易失储存器的的编码器累计脉冲数缓存
function Encoder_CumulativePulseCache()
	return DD(100)
end

-- 设置储存在非易失储存器的的编码器位置缓存
-- 会同时检查是否溢出，溢出了会增加或减少当前已经转的圈数的偏移量
function Encoder_UpdateCumulativePulseCache()
	-- 读取编码器的累计脉冲数。这个数被伺服使用 int 计数，正向溢出后会从最大正数变成最小负数。
	local pulse = SRV_MON(10)

	if (pulse < (-2147483648 // 2) and Encoder_CumulativePulseCache() > (2147483647 // 2)) then
		-- 发生正向溢出
		local n = Reel_ReleasedRotationsOffset()
		local encoder_n = IntPow(2, 32 - 17)

		-- 减速比 = 电机转的圈数 / 线轴转的圈数
		-- 线轴转的圈数 = 电机转的圈数 / 减速比
		local reel_n = encoder_n / Transmission_ReductionRatio_Machine() * Transmission_ReductionRatio_Reel()
		reel_n = FloatToInt(reel_n)
		Reel_SetReleasedRotationsOffset(n + reel_n)
	end

	if (Encoder_CumulativePulseCache() < (-2147483648 // 2) and pulse > (2147483647 // 2)) then
		-- 发生负向溢出
		local n = Reel_ReleasedRotationsOffset()
		local encoder_n = IntPow(2, 32 - 17)

		-- 减速比 = 电机转的圈数 / 线轴转的圈数
		-- 线轴转的圈数 = 电机转的圈数 / 减速比
		local reel_n = encoder_n / Transmission_ReductionRatio_Machine() * Transmission_ReductionRatio_Reel()
		reel_n = FloatToInt(reel_n)
		Reel_SetReleasedRotationsOffset(n - reel_n)
	end

	DD(100, pulse)
end
