--#region 通用

-- 毫秒延时
function Delay(milliseconds)
	DELAY(milliseconds)
end

-- 获取伺服参数
function GetServoParam(group, index)
	return SRV_PARA(group, index)
end

-- 设置伺服参数
function SetServoParam(group, index, value)
	SRV_PARA(group, index, value)
end

-- 获取 EI
function GetEI(ei_index)
	return SRV_EI(ei_index)
end

-- 设置 EI
function SetEI(ei_index, value)
	SRV_EI(ei_index, value)
end

-- 让 EI 接收到一个上升沿
function SetEIRisingEdge(ei_index)
	SetEI(ei_index, 0)
	Delay(1)
	SetEI(ei_index, 1)
	Delay(1)
	SetEI(ei_index, 0)
end

-- 重启伺服
function RestartServo()
	SetServoParam(3, 98, 9999)
end

--#region 定时器

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

--#endregion 定时器

-- 获取编码器的累计脉冲数
function GetEncoderCumulativePulse()
	return SRV_MON(10)
end

-- lua 的一切数字都为浮点。这里是将数字减去它的小数部分，只保留整数部分。
function NumberToInteger(num)
	local decimal_part = num % 1
	local integer_part = num - decimal_part
	return integer_part
end

--#region 数学

local PI = 3.1415926535898

function Max(num1, num2)
	if (num1 > num2) then
		return num1
	end

	return num2
end

function Min(num1, num2)
	if (num1 < num2) then
		return num1
	end

	return num2
end

-- 求 base 的 pow 次幂
-- 只支持整数幂，pow 的小数部分会被丢弃
-- base 会被以浮点数处理
function IntegerPow(base, pow)
	local ret = 1
	pow = NumberToInteger(pow)
	for i = 0, pow - 1 do
		ret = ret * base
	end

	return ret
end

--#endregion 数学

-- 设置转速
function SetSpeed(value)
	AXIS_SPEED(value)
end

-- 设置加速时间。单位：毫秒。
function SetAccelerationTime(value)
	AXIS_ACCEL(value)
end

-- 设置减速时间。单位：毫秒。
function SetDecelerationTime(value)
	AXIS_DECEL(value)
end

-- 设置绝对位置。需要启动定位运行才会真正运行，否则只是设置一个立即数。
function SetAbsolutePosition(value)
	AXIS_MOVEABS(value)
end

-- 设置相对位置。需要启动定位运行才会真正运行，否则只是设置一个立即数。
function SetRelativePosition(value)
	AXIS_MOVE(value)
end

--#endregion 通用

--#region 不通用

--#region 编码器累计脉冲数

-- 获取储存在非易失储存器的的编码器累计脉冲数
function Encoder_CumulativePulseCache()
	return DD(100)
end

-- 设置储存在非易失储存器的的编码器累计脉冲数
function SetEncoderCumulativePulseCache(value)
	DD(100, value)
end

function Encoder_CumulativePulseOffsetCache()
	return DD(101) + DD(102) * 2147483648
end

function SetEncoderCumulativePulseOffsetCache(value)
	DD(101, value % 2147483648)
	DD(102, value / 2147483648)
end

-- 总的编码器脉冲数缓存
-- 总的缓存 = 累计缓存 + 偏移量缓存
function Encoder_TotalPulseCache()
	return Encoder_CumulativePulseCache() + Encoder_CumulativePulseOffsetCache()
end

-- 初始化时更新总的编码器脉冲数缓存
function UpdataEncoderTotalPulseCacheInInit()
	local pulse_offset_cache = Encoder_CumulativePulseOffsetCache()
	local cumulative_pulse_cache = Encoder_CumulativePulseCache()
	local cumulative_pulse = GetEncoderCumulativePulse()

	-- 上电后，理论的 cumulative_pulse 应该是 0，但是实际上可能因为振动或其他原因，
	-- cumulative_pulse 并不是 0.

	-- 上电后 cumulative_pulse_cache 的值是掉电前储存的编码器累计脉冲数。理论上此时应该将
	-- cumulative_pulse_cache 的值转移到 pulse_offset_cache 中，然后 cumulative_pulse_cache
	-- 清 0. 但是 cumulative_pulse 实际上可能不为 0，所以需要计算偏移量

	-- 将增量储存到 pulse_offset_cache 中，然后 cumulative_pulse_cache 赋值为 cumulative_pulse
	local delta_cumulative_pulse = cumulative_pulse_cache - cumulative_pulse
	SetEncoderCumulativePulseOffsetCache(pulse_offset_cache + delta_cumulative_pulse)
	SetEncoderCumulativePulseCache(cumulative_pulse)
end

-- 在死循环中更新总的编码器脉冲数缓存
function UpdataEncoderTotalPulseCacheInLoop()
	-- 在这里要通过 cumulative_pulse_cache 检测出 cumulative_pulse 的溢出。
	-- 如果发生溢出，要让 pulse_offset_cache 减去溢出后环绕的值
	-- 例如 8 位有符号整型，127+1 后发生方向为负的环绕，环绕量为 -256，-128-1
	-- 后变成 127，发生方向为正的环绕，环绕量为 256

	-- 将值转移给 pulse_offset_cache 后，cumulative_pulse_cache 就可以继续跟踪 cumulative_pulse

	local pulse_offset_cache = Encoder_CumulativePulseOffsetCache()
	local cumulative_pulse_cache = Encoder_CumulativePulseCache()
	local cumulative_pulse = GetEncoderCumulativePulse()
	local delta_cumulative_pulse = cumulative_pulse - cumulative_pulse_cache

	-- 正转，累计脉冲数上溢后变成负数了，负数减去还是正数的缓存后变成一个很负的数
	if (delta_cumulative_pulse < -2147483648) then
		SetEncoderCumulativePulseOffsetCache(pulse_offset_cache + 2147483648 * 2)
		-- 更新累计脉冲缓存
		SetEncoderCumulativePulseCache(cumulative_pulse)
		return
	end

	-- 反转，发生下溢，溢出到正数那边了，正数减去还是负数的缓存，得到一个特别大的正数
	if (delta_cumulative_pulse > 2147483647) then
		SetEncoderCumulativePulseOffsetCache(pulse_offset_cache - 2147483648 * 2)
		-- 更新累计脉冲缓存
		SetEncoderCumulativePulseCache(cumulative_pulse)
		return
	end
end

--#endregion

--#region 电子齿轮比计算

--#region 电子齿轮比计算接口函数

-- 编码器转一圈发出的脉冲数
function Encoder_PulsePerRotation()
	return IntegerPow(2, 17)
end

-- 获取减速比。减速比 = 电机转的圈数 / 线轴转的圈数
function GetReductionRatio()
	return 100
end

-- 从满卷到空卷的圈数
function Get_N()
	return 100
end

-- 空卷周长。单位：米
function Get_c0()
	return 740 * 1e-3
end

-- 满卷周长。单位：米
function Get_c1()
	return 2533.2248 * 1e-3
end

--#endregion

-- 空卷半径
function Get_r0()
	return Get_c0() / (2 * PI)
end

-- 满卷半径
function Get_r1()
	return Get_c1() / (2 * PI)
end

-- 获取线轴当前放出的圈数
function Get_n()
	local encoder_rotations = Encoder_TotalPulseCache() / Encoder_PulsePerRotation()

	-- 减速比 = 电机转的圈数 / 线轴转的圈数
	-- 线轴转的圈数 = 电机转的圈数 / 减速比
	return encoder_rotations / GetReductionRatio()
end

-- 在当前位置的基础上，线轴再转一圈放出的弧长
function DeltaS()
	-- Δs = 2 * pi * (r1 - n * (r1 - r0) / N)
	return 2 * PI * (Get_r1() - Get_n() * (Get_r1() - Get_r0()) / Get_N())
end

-- 获取收线机收每米线输入多少个脉冲
function GetInputPulseCountPerMetre()
	return 100
end

-- 获取放完这一圈的线，需要收线机输入多少个脉冲
function GetInputPulseCountForDeltaS()
	return DeltaS() * GetInputPulseCountPerMetre()
end

-- 获取放线轴每转一圈，编码器需要转多少圈
function GetEncoderRotationsPerReelRotation()
	-- 减速比 = 电机转的圈数 / 线轴转的圈数
	-- 电机转的圈数 = 减速比 * 线轴转的圈数
	return GetReductionRatio() * 1
end

-- 获取放线轴每转一圈，编码器产生多少个脉冲
function GetEncoderPulseCountPerReelRatation()
	return GetEncoderRotationsPerReelRotation() * Encoder_PulsePerRotation()
end

-- 获取电子齿轮比。电子齿轮比 = 编码器脉冲个数 / 输入脉冲个数
function GetGear()
	local gear = GetEncoderPulseCountPerReelRatation() / GetInputPulseCountForDeltaS()
	if (gear == 0) then
		gear = 1
	end

	return gear
end

-- 将浮点的电子齿轮比转为分数
function GetFractionGear()
	local gear = GetGear()
	local gain = NumberToInteger(IntegerPow(2, 22) / gear)
	local fraction = {}
	fraction[0] = NumberToInteger(gear * gain);
	fraction[1] = NumberToInteger(gain);
	return fraction
end

-- 计算电子齿轮比，并更新伺服参数
function UpdataFractionGear()
	local fraction_gear = GetFractionGear()
	SetServoParam(1, 6, fraction_gear[0])
	SetServoParam(1, 7, fraction_gear[1])
end

--#endregion

-- 检查参数。参数不对会设置参数后重启伺服。
function CheckParam()
	local should_restart = false

	-- 定位运行模式
	if (GetServoParam(1, 1) ~= 7) then
		SetServoParam(1, 1, 7)
		should_restart = true
	end

	-- 速度控制时加减速有效无效
	if (GetServoParam(1, 36) ~= 1) then
		SetServoParam(1, 36, 1)
		should_restart = true
	end

	-- 内部定位数据无效
	if (GetServoParam(2, 40) ~= 0) then
		SetServoParam(2, 40, 0)
		should_restart = true
	end

	-- 模式 7 时，准备一个 EI，设置为 36 号选项，此 EI 为 ON 时，进入速度控制模式。
	-- 这里准备 EI1。
	-- 此时可以接受正转，反转的点动。
	if (GetServoParam(3, 1) ~= 36) then
		SetServoParam(3, 1, 36)
		should_restart = true
	end
	-- EI2 设置为正转
	if (GetServoParam(3, 2) ~= 2) then
		SetServoParam(3, 2, 2)
		should_restart = true
	end
	-- EI3 设置为反转
	if (GetServoParam(3, 3) ~= 3) then
		SetServoParam(3, 3, 3)
		should_restart = true
	end

	-- EI9 配置为使能
	if (GetServoParam(3, 9) ~= 1) then
		SetServoParam(3, 9, 1)
		should_restart = true
	end

	-- EI10 配置为定位数据启动
	if (GetServoParam(3, 10) ~= 4) then
		SetServoParam(3, 10, 4)
		should_restart = true
	end

	-- EI11 设置为位置预置功能
	if (GetServoParam(3, 11) ~= 16) then
		SetServoParam(3, 11, 16)
		should_restart = true
	end

	-- EI12 设置为立即值变更指令
	if (GetServoParam(3, 12) ~= 23) then
		SetServoParam(3, 12, 23)
		should_restart = true
	end

	-- EI13 设置为临时停止
	if (GetServoParam(3, 13) ~= 31) then
		SetServoParam(3, 13, 31)
		should_restart = true
	end

	-- EI14 设置为定位取消
	if (GetServoParam(3, 14) ~= 32) then
		SetServoParam(3, 14, 32)
		should_restart = true
	end

	-- 重启
	if (should_restart) then
		RestartServo()
	end
end

function EnableServo()
	SetEI(9, 1)
end

function DisableServo()
	SetEI(9, 0)
end

--#endregion 不通用


--#region 主程序
CheckParam()
EnableServo()
Delay(1000)
SetEI(10, 0)
SetEI(13, 0)
SetEI(14, 0)
SetSpeed(200)
SetAccelerationTime(1000)
SetDecelerationTime(1000)

-- 位置预置
SetEIRisingEdge(11)

UpdataEncoderTotalPulseCacheInInit()

-- 设置定时任务并立刻执行一次
local timer1_context = Timer_New(
	10 * 1000,
	true,
	function()
		UpdataFractionGear()
		SetRelativePosition(10 * 1000)
		SetEIRisingEdge(10)
	end
)
Timer_Start(timer1_context, true)

while (true)
do
	UpdataEncoderTotalPulseCacheInLoop()
	Timer_Check(timer1_context)
end
--#endregion 主程序
