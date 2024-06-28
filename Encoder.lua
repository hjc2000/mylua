-- 编码器转一圈发出的脉冲数
function Encoder_PulsePerRotation()
	return IntPow(2, 17)
end

-- 获取储存在非易失储存器的的编码器累计脉冲数缓存
function Encoder_CumulativePulseCache()
	return DD(100)
end

-- 设置储存在非易失储存器的的编码器位置缓存
function Encoder_UpdateCumulativePulseCache()
	-- 读取编码器的累计脉冲数。这个数被伺服使用 int 计数，正向溢出后会从最大正数变成最小负数。
	local pulse = SRV_MON(10)
	DD(100, pulse)
end
