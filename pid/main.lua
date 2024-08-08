Servo_CheckParam()
Servo_Enable()

-- 使能通信转速设置
Servo_SetEI(10, 1)

-- 设置定时任务
local timer1_context = Timer_New(
	10,
	true,
	function()

	end
)
Timer_Start(timer1_context, true)

while (true)
do
	Timer_Check(timer1_context)
end
