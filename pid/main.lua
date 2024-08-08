Servo_CheckParam()
Servo_Enable()

-- 使能通信转速设置
Servo_SetEI(10, 1)

-- 初始化 PID 控制器
local pid_controller_context = PidController_New(
	Option_PID_KP(),
	Option_PID_KI(),
	Option_PID_KD(),
	Option_IntegralSeparationThreshold(),
	Option_IntegralPositiveSaturation(),
	Option_IntegralNegativeSaturation()
)

-- 设置定时任务
local timer1_context = Timer_New(
	10,
	true,
	function()
		-- 更新 PID 系数
		PidController_ChangeParameters(
			pid_controller_context,
			Option_PID_KP(),
			Option_PID_KI(),
			Option_PID_KD(),
			Option_IntegralSeparationThreshold(),
			Option_IntegralPositiveSaturation(),
			Option_IntegralNegativeSaturation()
		)

		local e = Option_ExpectedVoltage() - Servo_Vref()
		local speed = PidController_Input(pid_controller_context, e)
		Servo_SetSpeed(speed)
	end
)

Timer_Start(timer1_context, true)

while (true)
do
	Timer_Check(timer1_context)
end
