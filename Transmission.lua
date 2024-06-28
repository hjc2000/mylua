-- 获取减速比。减速比 = 电机转的圈数 / 线轴转的圈数
-- 这里获取的是分子：电机转的圈数
function Transmission_ReductionRatio_Machine()
	if (DD(103) <= 0) then
		DD(103, 1)
	end

	return DD(103)
end

-- 获取减速比。减速比 = 电机转的圈数 / 线轴转的圈数
-- 这里获取的是分母：线轴转的圈数
function Transmission_ReductionRatio_Reel()
	if (DD(104) <= 0) then
		DD(104, 1)
	end

	return DD(104)
end

-- 收线机收 x 米线会输入 y 个脉冲
-- 这里获取的是其中的 x
function Transmission_InputPulse_X()
	if (DF(108) <= 0) then
		DF(108, 100)
	end

	return DF(108)
end

-- 收线机收 x 米线会输入 y 个脉冲
-- 这里获取的是其中的 y
function Transmission_InputPulse_Y()
	if (DD(109) <= 0) then
		DD(109, 100)
	end

	return DD(109)
end

-- 放完这一圈的线，收线机需要发多少个脉冲给伺服
function Transmission_InputPulsePerDeltaS()
	return FloatToInt(Reel_DeltaS() * Transmission_InputPulse_Y() / Transmission_InputPulse_X)
end

-- 获取电子齿轮比。
function Transmission_Gear()
	-- 电子齿轮比 = 编码器脉冲个数 / 输入脉冲个数
	local gear = Transmission_ReductionRatio_Machine() /
		Transmission_ReductionRatio_Reel() *
		Encoder_PulsePerRotation() /
		Transmission_InputPulsePerDeltaS()

	return gear
end

-- 将浮点的电子齿轮比转为分数
function Transmission_FractionGear()
	local gear = Transmission_Gear()
	local gain = (IntPow(2, 22) - 1) / gear
	local fraction = {}
	fraction[0] = gear * gain;
	fraction[1] = gain;
	return fraction
end

-- 计算电子齿轮比，并更新伺服参数
Transmission_UpdataFractionGear = function()
	local fraction_gear = Transmission_FractionGear()
	Servo_SetParam(1, 6, fraction_gear[0])
	Servo_SetParam(1, 7, fraction_gear[1])
end
