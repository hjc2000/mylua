--#region Option

--- PID 的比例系数
--- @return number
function Option_PID_KP()
	return DD(100)
end

--- PID 的积分系数
--- @return number
function Option_PID_KI()
	return DD(101)
end

--- PID 的微分系数
--- @return number
function Option_PID_KD()
	return DD(102)
end

--- 积分分离阈值。在偏差量的绝对值大于此值时不进行积分累加，偏差量绝对值小于此值后
--- 才开始进行积分累加。
--- @return number
function Option_IntegralSeparationThreshold()
	return DD(103)
end

--- 积分环节的正向饱和值。
--- @return number
function Option_IntegralPositiveSaturation()
	return DD(104)
end

--- 积分环节的负向饱和值。
--- @return number
function Option_IntegralNegativeSaturation()
	return DD(105)
end

--- 期望的电压。
--- 触摸屏使用整型进行设置，单位为 0.01V. 脚本中获取到值后除以 100，转换为 V。
--- @return number
function Option_ExpectedVoltage()
	return DD(106) / 100
end

--#region 是否启动

--- 是否上电后自动运行
--- @return boolean
local function Option_AutoStart()
	return DD(107) ~= 0
end

-- 如果希望上电自动运行，将 DD0 设置为 1.
if (Option_AutoStart()) then
	DD(0, 1)
end

--- 启动运行
--- @return boolean 为true表示启动运行，否则不能运行，不能让电机转动。
function Option_Start()
	return DD(0) ~= 0
end

--#endregion

--- 最大转速
--- @return integer
function Option_MaxSpeed()
	local max = DD(108)
	if (max < Option_MinSpeed()) then
		max = Option_MinSpeed()
	end

	return max
end

--- 最小转速
--- @return integer
function Option_MinSpeed()
	return DD(109)
end

--#endregion


--#region PidController

--- 新建一个PID控制器。
--- @param kp number 比例
--- @param ki number 积分
--- @param kd number 微分
--- @param integral_separation_threshold number 积分分离阈值
--- @param integral_positive_saturation number 积分正饱和
--- @param integral_negative_saturation number 积分负饱和
--- @return table PID控制器上下文。
function PidController_New(kp, ki, kd,
						   integral_separation_threshold,
						   integral_positive_saturation,
						   integral_negative_saturation)
	local context = {}
	context.kp = kp
	context.ki = ki
	context.kd = kd
	context.integral_separation_threshold = integral_separation_threshold
	context.integral_positive_saturation = integral_positive_saturation
	context.integral_negative_saturation = integral_negative_saturation

	context.x0 = 0
	context.x1 = 0
	context.x2 = 0

	context.p = 0
	context.i = 0
	context.d = 0

	return context
end

--- 向PID控制器输入一个值并得到输出。
--- @param context table PID控制器上下文。
--- @param x number 输入值
--- @return number PID输出
function PidController_Input(context, x)
	context.x2 = context.x1
	context.x1 = context.x0
	context.x0 = x

	context.p = context.p + context.kp * (context.x0 - context.x1)

	if (math.abs(x) <= context.integral_separation_threshold) then
		-- 偏差减小，投入积分
		context.i = context.i + context.ki * context.x0

		-- 积分饱和
		if (context.i > context.integral_positive_saturation) then
			context.i = context.integral_positive_saturation
		elseif (context.i < context.integral_negative_saturation) then
			context.i = context.integral_negative_saturation
		end
	end

	context.d = context.d + context.kd * (context.x0 - 2 * context.x1 + context.x2)

	return context.p + context.i + context.d
end

--- 更改 PID 控制器的参数
--- @param context table 上下文
--- @param kp number 比例
--- @param ki number 积分
--- @param kd number 微分
--- @param integral_separation_threshold number 积分分离阈值
--- @param integral_positive_saturation number 积分正饱和
--- @param integral_negative_saturation number 积分负饱和
function PidController_ChangeParameters(context,
										kp, ki, kd,
										integral_separation_threshold,
										integral_positive_saturation,
										integral_negative_saturation)
	context.kp = kp
	context.ki = ki
	context.kd = kd
	context.integral_separation_threshold = integral_separation_threshold
	context.integral_positive_saturation = integral_positive_saturation
	context.integral_negative_saturation = integral_negative_saturation
end

--#endregion


--#region Servo

--- 获取伺服参数
--- @param group integer 组索引
--- @param index integer 参数子索引
--- @return number 参数值
function Servo_GetParam(group, index)
	return SRV_PARA(group, index)
end

--- 设置伺服参数
--- @param group integer 组索引
--- @param index integer 参数子索引
--- @param value number 参数值
function Servo_SetParam(group, index, value)
	SRV_PARA(group, index, value)
end

--- 检查参数。参数不对会设置参数
function Servo_CheckParam()
	-- 速度控制模式
	if (Servo_GetParam(1, 1) ~= 1) then
		Servo_SetParam(1, 1, 1)
	end

	Servo_SetVrefFilterTime(10)

	--#region 硬件 EI 分配
	-- EI1
	if (Servo_GetParam(3, 1) ~= 0) then
		Servo_SetParam(3, 1, 0)
	end
	-- EI2
	if (Servo_GetParam(3, 2) ~= 0) then
		Servo_SetParam(3, 2, 0)
	end
	-- EI3
	if (Servo_GetParam(3, 3) ~= 0) then
		Servo_SetParam(3, 3, 0)
	end
	-- EI4
	if (Servo_GetParam(3, 4) ~= 0) then
		Servo_SetParam(3, 4, 0)
	end
	-- EI5
	if (Servo_GetParam(3, 5) ~= 0) then
		Servo_SetParam(3, 5, 0)
	end
	--#endregion

	--#region 通信 EI 分配
	-- EI9
	-- EI9 配置为使能
	if (Servo_GetParam(3, 9) ~= 1) then
		Servo_SetParam(3, 9, 1)
	end

	-- EI10
	-- EI10 配置为通信转速选择
	if (Servo_GetParam(3, 10) ~= 18) then
		Servo_SetParam(3, 10, 18)
	end

	-- EI11
	if (Servo_GetParam(3, 11) ~= 0) then
		Servo_SetParam(3, 11, 0)
	end

	-- EI12
	if (Servo_GetParam(3, 12) ~= 0) then
		Servo_SetParam(3, 12, 0)
	end

	-- EI13
	if (Servo_GetParam(3, 13) ~= 0) then
		Servo_SetParam(3, 13, 0)
	end

	-- EI14
	if (Servo_GetParam(3, 14) ~= 0) then
		Servo_SetParam(3, 14, 0)
	end

	-- EI15
	if (Servo_GetParam(3, 15) ~= 0) then
		Servo_SetParam(3, 15, 0)
	end

	-- EI16
	if (Servo_GetParam(3, 16) ~= 0) then
		Servo_SetParam(3, 16, 0)
	end

	-- EI17
	if (Servo_GetParam(3, 17) ~= 0) then
		Servo_SetParam(3, 17, 0)
	end

	-- EI18
	if (Servo_GetParam(3, 18) ~= 0) then
		Servo_SetParam(3, 18, 0)
	end

	-- EI19
	if (Servo_GetParam(3, 19) ~= 0) then
		Servo_SetParam(3, 19, 0)
	end

	-- EI20
	if (Servo_GetParam(3, 20) ~= 0) then
		Servo_SetParam(3, 20, 0)
	end

	-- EI21
	if (Servo_GetParam(3, 21) ~= 0) then
		Servo_SetParam(3, 21, 0)
	end

	-- EI22
	if (Servo_GetParam(3, 22) ~= 0) then
		Servo_SetParam(3, 22, 0)
	end

	-- EI23
	if (Servo_GetParam(3, 23) ~= 0) then
		Servo_SetParam(3, 23, 0)
	end

	-- EI24
	if (Servo_GetParam(3, 24) ~= 0) then
		Servo_SetParam(3, 24, 0)
	end
	--#endregion
end

--- 获取 EI
--- @param ei_index integer EI 索引
--- @return integer EI 值。会是 0 或 1。
function Servo_GetEI(ei_index)
	return SRV_EI(ei_index)
end

--- 设置 EI
--- @param ei_index integer EI 索引。
--- @param value integer EI 值。只能是 0 或 1。
function Servo_SetEI(ei_index, value)
	SRV_EI(ei_index, value)
end

--- 让 EI 接收到一个上升沿
--- @param ei_index integer EI 索引
function Servo_TriggerEIRisingEdge(ei_index)
	Servo_SetEI(ei_index, 0)
	Delay(5)
	Servo_SetEI(ei_index, 1)
	Delay(5)
	Servo_SetEI(ei_index, 0)
end

--- 重启伺服
function Servo_Restart()
	Servo_SetParam(3, 98, 9999)
end

--- 设置转速
--- @param value number
function Servo_SetSpeed(value)
	AXIS_SPEED(value)
end

--- 使能
function Servo_Enable()
	Servo_SetEI(9, 1)
end

--- 失能
function Servo_Disable()
	Servo_SetEI(9, 0)
end

--- 模拟输入电压。单位：V
--- @return number
function Servo_Vref()
	return SRV_MON(16) / 100
end

--- 伺服的模拟输入电压端子的滤波时间常数。单位：ms
--- @return number
function Servo_VrefFilterTime()
	return Servo_GetParam(3, 49) / 100
end

--- 设置伺服的模拟输入电压端子的滤波时间常数。单位：ms
--- @param value number
function Servo_SetVrefFilterTime(value)
	Servo_SetParam(3, 49, math.floor(value * 100))
end

--#endregion


--#region Timer

-- 毫秒延时
function Delay(milliseconds)
	DELAY(milliseconds)
end

-- 构造一个新的定时器。会自动分配空闲的定时器。
-- 如果没有空闲的定时器，会返回 nil，否则返回定时器上下文
-- 需要用 Timer_Start 函数启动定时器。
function Timer_New(interval_in_milliseconds, auto_reset, callback_func)
	-- 数组，索引为 n 的位置为 true 表示定时器 ID 是 n 的定时器正在被使用
	G_timer_usage_states = {}

	local timer_context = {}

	for i = 0, 30 do
		if G_timer_usage_states[i] ~= true then
			G_timer_usage_states[i] = true
			timer_context.timer_id = i
			timer_context.interval_in_milliseconds = interval_in_milliseconds
			timer_context.auto_reset = auto_reset
			timer_context.callback_func = callback_func
			return timer_context
		end
	end

	-- 定时器已被耗尽
	return nil
end

-- 释放定时器。
-- 如果定时器还未停止，会先调用 Timer_Stop
function Timer_Free(timer_context)
	Timer_Stop(timer_context)
	G_timer_usage_states[timer_context.timer_id] = false
end

-- 启动定时器。
-- callback_immediately 为 true 则会立刻执行一次回调，不用等到定时时间到。
function Timer_Start(timer_context, callback_immediately)
	if (timer_context.callback_func ~= nil and callback_immediately) then
		timer_context.callback_func()
	end

	TIM_START(timer_context.timer_id, timer_context.interval_in_milliseconds)
end

function Timer_Stop(timer_context)
	TIM_STOP(timer_context.timer_id)
end

-- 检查定时时间是否到了，到了会触发回调。需要在循环中被反复调用。
function Timer_Check(timer_context)
	if (TIM_CHECK(timer_context.timer_id) == 1) then
		if (timer_context.callback_func ~= nil) then
			timer_context.callback_func()
		end

		if (timer_context.auto_reset) then
			Timer_Reset(timer_context)
		end
	end
end

function Timer_Reset(timer_context)
	TIM_RESET(timer_context.timer_id)
end

--#endregion


--#region main

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

			-- 转速限幅
			if (speed < Option_MinSpeed()) then
				speed = Option_MinSpeed()
			elseif (speed > Option_MaxSpeed()) then
				speed = Option_MaxSpeed()
			end

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

--#endregion
