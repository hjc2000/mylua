--#region Transmission
-- 传动
Transmission = {}

-- 获取减速比。减速比 = 电机转的圈数 / 线轴转的圈数
Transmission.ReductionRatio = function()
	if (DD(103) <= 0) then
		DD(103, 1)
	end

	if (DD(104) <= 0) then
		DD(104, 1)
	end

	return DD(103) / DD(104)
end

-- 获取收线机收每米线输入多少个脉冲
Transmission.InputPulsePerMetre = function()
	if (DD(108) <= 0) then
		DD(108, 100)
	end

	return DD(108)
end

-- 获取放完这一圈的线，需要收线机输入多少个脉冲
Transmission.InputPulsePerDeltaS = function()
	return Reel_DeltaS() * Transmission.InputPulsePerMetre()
end

-- 获取放线轴每转一圈，编码器需要转多少圈
Transmission.EncoderRotationsPerReelRotation = function()
	-- 减速比 = 电机转的圈数 / 线轴转的圈数
	-- 电机转的圈数 = 减速比 * 线轴转的圈数
	return Transmission.ReductionRatio() * 1
end

-- 获取放线轴每转一圈，编码器产生多少个脉冲
Transmission.EncoderPulsePerReelRatation = function()
	return Transmission.EncoderRotationsPerReelRotation() * Encoder_PulsePerRotation()
end

-- 获取电子齿轮比。电子齿轮比 = 编码器脉冲个数 / 输入脉冲个数
Transmission.Gear = function()
	local gear = Transmission.EncoderPulsePerReelRatation() / Transmission.InputPulsePerDeltaS()
	return gear
end

-- 将浮点的电子齿轮比转为分数
Transmission.FractionGear = function()
	local gear = Transmission.Gear()
	local gain = (Pow(2, 22) - 1) / gear
	local fraction = {}
	fraction[0] = gear * gain;
	fraction[1] = gain;
	return fraction
end

-- 计算电子齿轮比，并更新伺服参数
Transmission.UpdataFractionGear = function()
	local fraction_gear = Transmission.FractionGear()
	Servo.SetParam(1, 6, fraction_gear[0])
	Servo.SetParam(1, 7, fraction_gear[1])
end

--#endregion

--#region 主程序
Servo.CheckParam()
Servo.Enable()
Encoder.UpdateAbsolutePositionCacheInInit()

-- 初始化后默认进入脉冲模式
Servo.SetEI(11, 1)

-- 设置定时任务
local timer1_context = Timer.New(
	10 * 1000,
	true,
	function()
		-- 将更新缓存的操作放到定时器中，不要太频繁地写 flash
		Encoder.UpdataAbsolutePositionCacheInLoop()
		Transmission.UpdataFractionGear()
	end
)
Timer.Start(timer1_context, true)

while (true)
do
	if (M(1) == 1) then
		-- 检测到触摸屏将 M1 置 1，重置编码器位置，并将 M1 置 0.
		Encoder.ResetPosition()
		M(1, 0)
	end

	Timer.Check(timer1_context)

	-- 将线轴已经转的圈数放到 D1 中供触摸屏读取
	DD(1, Reel_ReleasedRotations())
end
--#endregion 主程序
