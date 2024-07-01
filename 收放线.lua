Servo_CheckParam()
Servo_Enable()

-- 初始化后默认进入脉冲模式
Servo_SetEI(11, 1)

-- 设置定时任务
local timer1_context = Timer_New(
	10 * 1000,
	true,
	function()
		-- 将更新缓存的操作放到定时器中，不要太频繁地写 flash
		Encoder_UpdateCumulativePulseCache()
		Transmission_UpdataFractionGear()
	end
)
Timer_Start(timer1_context, true)

while (true)
do
	if (M(1) == 1) then
		-- 检测到触摸屏将 M1 置 1，重置编码器位置，并将 M1 置 0.
		Encoder_ResetPosition()
		M(1, 0)
	end

	Timer_Check(timer1_context)

	-- 将线轴已经转的圈数放到 D1 中供触摸屏读取
	DD(1, Reel_n())
end
