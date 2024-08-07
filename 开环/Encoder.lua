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
	local current_cumulative_pulse = Encoder_CumulativePulse()

	-- 初始化时是上电后重新执行的时候，此时编码器的累计脉冲数归 0，但也有可能因为外力，偏离 0
	-- 一点点。

	-- 将编码器累计脉冲数缓存减去当前累计脉冲数，得到偏差
	local delta_pulse = Encoder_CumulativePulseCache() - current_cumulative_pulse

	-- 偏差量对应编码器转了多少圈
	local delta_encoder_n = IntDiv(delta_pulse, Encoder_PulsePerRotation())

	-- 将 delta_encoder_n 加到当前的编码器圈数偏移量中，因为随后要让累计脉冲数缓存去跟踪当前
	-- 累计脉冲数
	local current_encoder_n_offset = Encoder_n_Offset()
	Encoder_Set_n_Offset(current_encoder_n_offset + delta_encoder_n);

	-- 将累计脉冲数缓存设置为当前的值
	Encoder_SetCumulativePulseCache(current_cumulative_pulse)
end

-- 更新储存在非易失储存器的的编码器累计脉冲数缓存
-- 会同时检查是否溢出，溢出了会增加或减少当前已经转的圈数的偏移量
function Encoder_UpdateCumulativePulseCache()
	-- 读取编码器的累计脉冲数。这个数被伺服使用 int 计数，正向溢出后会从最大正数变成最小负数。
	local current_cumulative_pulse = Encoder_CumulativePulse()

	if (current_cumulative_pulse < (-2147483648 // 2) and Encoder_CumulativePulseCache() > (2147483647 // 2)) then
		-- 发生正向溢出
		local current_encoder_n_offset = Encoder_n_Offset()
		Encoder_Set_n_Offset(current_encoder_n_offset + IntPow(2, 32 - 17))
	end

	if (Encoder_CumulativePulseCache() < (-2147483648 // 2) and current_cumulative_pulse > (2147483647 // 2)) then
		-- 发生负向溢出
		local current_encoder_n_offset = Encoder_n_Offset()
		Encoder_Set_n_Offset(current_encoder_n_offset - IntPow(2, 32 - 17))
	end

	-- 将累计脉冲数缓存设置为当前的值
	Encoder_SetCumulativePulseCache(current_cumulative_pulse)
end

-- 编码器转的圈数的偏移量
function Encoder_n_Offset()
	return DD(101)
end

-- 设置编码器转的圈数的偏移量
function Encoder_Set_n_Offset(value)
	DD(101, value)
end

-- 编码器转过的圈数 = 累计脉冲数计算出来的圈数 + Encoder_n_Offset()
function Encoder_n()
	return IntDiv(Encoder_CumulativePulseCache(), Encoder_PulsePerRotation()) +
		Encoder_n_Offset()
end

-- 重置编码器转过的圈数
function Encoder_Reset()
	-- 将编码器累计脉冲数缓存设置为当前的累计脉冲数
	Encoder_SetCumulativePulseCache(Encoder_CumulativePulse())

	-- 因为要将圈数归 0，但是无法将当前编码器累计脉冲数归 0，所以只能从偏移量入手。
	Encoder_Set_n_Offset(-IntDiv(Encoder_CumulativePulseCache(), Encoder_PulsePerRotation()))
end
