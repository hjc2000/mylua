-- 获取减速比。减速比 = 电机转的圈数 / 线轴转的圈数
-- 这里获取的是分子：电机转的圈数
function Transmission_ReductionRatioNum()
	if (DD(103) <= 0) then
		DD(103, 1)
	end

	return DD(103)
end

-- 获取减速比。减速比 = 电机转的圈数 / 线轴转的圈数
-- 这里获取的是分母：线轴转的圈数
function Transmission_ReductionRatioDen()
	if (DD(104) <= 0) then
		DD(104, 1)
	end

	return DD(104)
end

-- 计算电子齿轮比，并更新伺服参数
function Transmission_UpdataFractionGear()
	local gear_num = Encoder_PulsePerRotation() /
		(Reel_N() * Reel_C1() + Reel_C0() * Reel_n() - Reel_C1() * Reel_n()) *
		Reel_N() *
		Transmission_ReductionRatioNum() *
		Input_X();

	local gear_den = Input_PulseRatio() * Input_Y() * Transmission_ReductionRatioDen();

	-- 浮点的电子齿轮比
	local gear = gear_num / gear_den;

	-- 要将 gear 转化成分数
	-- 分子分母最大值是 IntPow(2, 22) - 1
	-- 计算看 gear 能乘多少比例而不超过最大值
	local rate = (IntPow(2, 22) - 1) / gear

	-- 对浮点型的比例进行截断，转化为整型
	rate = FloatToInt(rate)

	-- gear = gear / 1
	-- 分子分母同时乘 rate
	gear_num = FloatToInt(gear * rate)
	gear_den = rate

	Servo_SetParam(1, 6, gear_num)
	Servo_SetParam(1, 7, gear_den)
end
