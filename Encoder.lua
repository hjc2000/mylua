-- 编码器转一圈发出的脉冲数
function Encoder_PulsePerRotation()
	return IntPow(2, 17)
end

-- 编码器累计脉冲数
function Encoder_CumulativePulse()
	return SRV_MON(10)
end

-- 获取编码器累计脉冲数缓存
function Encoder_CumulativePulseCache()
	return DD(100)
end

-- 设置编码器累计脉冲数缓存
function Encoder_SetCumulativePulseCache(value)
	DD(100, value)
end

-- 初始化阶段更新编码器累计脉冲数缓存
function Encoder_UpdateCumulativePulseCacheInInit()
	-- 读取编码器的累计脉冲数。这个数被伺服使用 int 计数，正向溢出后会从最大正数变成最小负数。
	local pulse = Encoder_CumulativePulse()

	local delta_pulse = Encoder_CumulativePulseCache() - pulse
	local delta_encoder_n = IntDiv(delta_pulse, Encoder_PulsePerRotation())

	-- 减速比 = 电机转的圈数 / 线轴转的圈数
	-- 线轴转的圈数 = 电机转的圈数 / 减速比
	local delta_reel_n = delta_encoder_n / Transmission_ReductionRatio_Machine() * Transmission_ReductionRatio_Reel()
	delta_reel_n = FloatToInt(delta_reel_n)

	local reel_n_offset = Reel_ReleasedRotationsOffset()
	Reel_SetReleasedRotationsOffset(reel_n_offset + delta_reel_n)

	-- 将累计脉冲数缓存设置为当前的值
	Encoder_SetCumulativePulseCache(pulse)
end

-- 设置储存在非易失储存器的的编码器累计脉冲数缓存
-- 会同时检查是否溢出，溢出了会增加或减少当前已经转的圈数的偏移量
function Encoder_UpdateCumulativePulseCache()
	-- 读取编码器的累计脉冲数。这个数被伺服使用 int 计数，正向溢出后会从最大正数变成最小负数。
	local pulse = Encoder_CumulativePulse()

	if (pulse < (-2147483648 // 2) and Encoder_CumulativePulseCache() > (2147483647 // 2)) then
		-- 发生正向溢出
		local reel_n_offset = Reel_ReleasedRotationsOffset()
		local delta_encoder_n = IntPow(2, 32 - 17)

		-- 减速比 = 电机转的圈数 / 线轴转的圈数
		-- 线轴转的圈数 = 电机转的圈数 / 减速比
		local delta_reel_n = delta_encoder_n / Transmission_ReductionRatio_Machine() * Transmission_ReductionRatio_Reel()
		delta_reel_n = FloatToInt(delta_reel_n)
		Reel_SetReleasedRotationsOffset(reel_n_offset + delta_reel_n)
	end

	if (Encoder_CumulativePulseCache() < (-2147483648 // 2) and pulse > (2147483647 // 2)) then
		-- 发生负向溢出
		local reel_n_offset = Reel_ReleasedRotationsOffset()
		local delta_encoder_n = IntPow(2, 32 - 17)

		-- 减速比 = 电机转的圈数 / 线轴转的圈数
		-- 线轴转的圈数 = 电机转的圈数 / 减速比
		local delta_reel_n = delta_encoder_n / Transmission_ReductionRatio_Machine() * Transmission_ReductionRatio_Reel()
		delta_reel_n = FloatToInt(delta_reel_n)
		Reel_SetReleasedRotationsOffset(reel_n_offset - delta_reel_n)
	end

	Encoder_SetCumulativePulseCache(pulse)
end
