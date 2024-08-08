Servo_CheckParam()
Servo_Enable()

-- 使能通信转速设置
Servo_SetEI(10, 1)

-- 设置定时任务
local timer1_context = Timer_New(
	10,
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
	Timer_Check(timer1_context)
end
