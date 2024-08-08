Servo_CheckParam()
Servo_Enable()
Servo_SetSpeed(0)

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

		if (Option_Start()) then
			local e = Option_ExpectedVoltage() - Servo_Vref()
			local speed = PidController_Input(pid_controller_context, e)
			Servo_SetSpeed(speed)
		else
			Servo_SetSpeed(0)
		end
	end
)

Timer_Start(timer1_context, true)

while (true)
do
	Timer_Check(timer1_context)
end
