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

-- 收线机收 x 米线会发出 y 个脉冲
-- 这里获取的是其中的 x
function Transmission_InputPulse_X()
	if (DF(108) <= 0) then
		DF(108, 100)
	end

	return DF(108)
end

-- 收线机收 x 米线会发出 y 个脉冲
-- 这里获取的是其中的 y
function Transmission_InputPulse_Y()
	if (DD(109) <= 0) then
		DD(109, 100)
	end

	return DD(109)
end

-- 计算电子齿轮比，并更新伺服参数
Transmission_UpdataFractionGear = function()
	local fraction_gear = Transmission_FractionGear()
	Servo_SetParam(1, 6, fraction_gear[0])
	Servo_SetParam(1, 7, fraction_gear[1])
end
