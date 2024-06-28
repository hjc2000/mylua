--#region Int

-- 将浮点转为 32 位整型。会进行截断，使得结果更靠近 0
-- value 大于 2147483647 会返回 2147483647
-- value 小于 -2147483648 会返回 -2147483648
function FloatToInt(value)
	if (value > 2147483647) then
		return 2147483647
	end

	if (value < -2147483648) then
		return -2147483648
	end

	if (value > 0) then
		return math.floor(value)
	end

	return math.ceil(value)
end

-- left / right
-- 结果会被截断，使得结果更靠近 0
function IntDiv(left, right)
	left = FloatToInt(left)
	right = FloatToInt(right)

	if (left > 0 and right > 0) then
		return left // right
	end

	if (left < 0 and right < 0) then
		return left // right
	end

	-- left 和 right 异号
	if (left < 0) then
		left = -left
	end

	if (right < 0) then
		right = -right
	end

	local div = left // right
	return -div
end

-- left % right
function IntMod(left, right)
	local div = IntDiv(left, right)
	return left - right * div
end

function IntDivMod(left, right)
	local ret = {}
	ret.div = IntDiv(left, right)
	ret.mod = IntMod(left, right)
	return ret
end

--endregion

-- 毫秒延时
function Delay(milliseconds)
	DELAY(milliseconds)
end

--region Servo
Servo = {}

--获取伺服参数
Servo.GetParam = function(group, index)
	return SRV_PARA(group, index)
end

-- 设置伺服参数
Servo.SetParam = function(group, index, value)
	SRV_PARA(group, index, value)
end

-- 检查参数。参数不对会设置参数
Servo.CheckParam = function()
	-- 定位运行模式
	if (Servo.GetParam(1, 1) ~= 7) then
		Servo.SetParam(1, 1, 7)
	end

	-- 速度控制时加减速有效
	if (Servo.GetParam(1, 36) ~= 1) then
		Servo.SetParam(1, 36, 1)
	end

	-- 内部定位数据无效
	if (Servo.GetParam(2, 40) ~= 0) then
		Servo.SetParam(2, 40, 0)
	end

	--#region 硬件 EI 分配
	-- EI1
	if (Servo.GetParam(3, 1) ~= 0) then
		Servo.SetParam(3, 1, 0)
	end
	-- EI2
	if (Servo.GetParam(3, 2) ~= 0) then
		Servo.SetParam(3, 2, 0)
	end
	-- EI3
	if (Servo.GetParam(3, 3) ~= 0) then
		Servo.SetParam(3, 3, 0)
	end
	-- EI4
	if (Servo.GetParam(3, 4) ~= 0) then
		Servo.SetParam(3, 4, 0)
	end
	-- EI5
	if (Servo.GetParam(3, 5) ~= 0) then
		Servo.SetParam(3, 5, 0)
	end
	--#endregion

	--#region 通信 EI 分配
	-- EI9 配置为使能
	if (Servo.GetParam(3, 9) ~= 1) then
		Servo.SetParam(3, 9, 1)
	end
	-- EI10 配置为位置预置功能
	if (Servo.GetParam(3, 10) ~= 16) then
		Servo.SetParam(3, 10, 16)
	end
	-- EI11 配置为指令脉冲比率 1，为 ON 时进入脉冲模式
	-- 为 OFF 时可以被正转信号和反转信号控制进行点动。
	if (Servo.GetParam(3, 11) ~= 27) then
		Servo.SetParam(3, 11, 27)
	end
	-- EI12 配置为正转
	if (Servo.GetParam(3, 12) ~= 2) then
		Servo.SetParam(3, 12, 2)
	end
	-- EI13 配置为反转
	if (Servo.GetParam(3, 13) ~= 3) then
		Servo.SetParam(3, 13, 3)
	end
	-- EI14
	if (Servo.GetParam(3, 14) ~= 0) then
		Servo.SetParam(3, 14, 0)
	end
	-- EI15
	if (Servo.GetParam(3, 15) ~= 0) then
		Servo.SetParam(3, 15, 0)
	end
	-- EI16
	if (Servo.GetParam(3, 16) ~= 0) then
		Servo.SetParam(3, 16, 0)
	end
	-- EI17
	if (Servo.GetParam(3, 17) ~= 0) then
		Servo.SetParam(3, 17, 0)
	end
	-- EI18
	if (Servo.GetParam(3, 18) ~= 0) then
		Servo.SetParam(3, 18, 0)
	end
	-- EI19
	if (Servo.GetParam(3, 19) ~= 0) then
		Servo.SetParam(3, 19, 0)
	end
	-- EI20
	if (Servo.GetParam(3, 20) ~= 0) then
		Servo.SetParam(3, 20, 0)
	end
	-- EI21
	if (Servo.GetParam(3, 21) ~= 0) then
		Servo.SetParam(3, 21, 0)
	end
	-- EI22
	if (Servo.GetParam(3, 22) ~= 0) then
		Servo.SetParam(3, 22, 0)
	end
	-- EI23
	if (Servo.GetParam(3, 23) ~= 0) then
		Servo.SetParam(3, 23, 0)
	end
	-- EI24
	if (Servo.GetParam(3, 24) ~= 0) then
		Servo.SetParam(3, 24, 0)
	end
	--#endregion
end

-- 获取 EI
Servo.GetEI = function(ei_index)
	return SRV_EI(ei_index)
end

-- 设置 EI
Servo.SetEI = function(ei_index, value)
	SRV_EI(ei_index, value)
end

-- 让 EI 接收到一个上升沿
Servo.TriggerEIRisingEdge = function(ei_index)
	Servo.SetEI(ei_index, 0)
	Delay(1)
	Servo.SetEI(ei_index, 1)
	Delay(1)
	Servo.SetEI(ei_index, 0)
end

-- 重启伺服
Servo.Restart = function()
	Servo.SetParam(3, 98, 9999)
end

-- 设置转速
Servo.SetSpeed = function(value)
	AXIS_SPEED(value)
end

-- 设置加速时间。单位：毫秒。
Servo.SetAccelerationTime = function(value)
	AXIS_ACCEL(value)
end

-- 设置减速时间。单位：毫秒。
Servo.SetDecelerationTime = function(value)
	AXIS_DECEL(value)
end

-- 设置绝对位置。需要启动定位运行才会真正运行，否则只是设置一个立即数。
Servo.SetAbsolutePosition = function(value)
	AXIS_MOVEABS(value)
end

-- 设置相对位置。需要启动定位运行才会真正运行，否则只是设置一个立即数。
Servo.SetRelativePosition = function(value)
	AXIS_MOVE(value)
end

-- 使能
Servo.Enable = function()
	Servo.SetEI(9, 1)
end

-- 失能
Servo.Disable = function()
	Servo.SetEI(9, 0)
end

--#endregion

--#region Timer
Timer = {}

-- 构造一个新的定时器。会自动分配空闲的定时器。
-- 如果没有空闲的定时器，会返回 nil，否则返回定时器上下文
-- 需要用 Timer_Start 函数启动定时器。
Timer.New = function(interval_in_milliseconds, auto_reset, callback_func)
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
Timer.Free = function(timer_context)
	Timer.Stop(timer_context)
	G_timer_usage_states[timer_context.timer_id] = false
end

-- 启动定时器。
-- callback_immediately 为 true 则会立刻执行一次回调，不用等到定时时间到。
Timer.Start = function(timer_context, callback_immediately)
	if (timer_context.callback_func ~= nil and callback_immediately) then
		timer_context.callback_func()
	end

	TIM_START(timer_context.timer_id, timer_context.interval_in_milliseconds)
end

Timer.Stop = function(timer_context)
	TIM_STOP(timer_context.timer_id)
end

-- 检查定时时间是否到了，到了会触发回调。需要在循环中被反复调用。
Timer.Check = function(timer_context)
	if (TIM_CHECK(timer_context.timer_id) == 1) then
		if (timer_context.callback_func ~= nil) then
			timer_context.callback_func()
		end

		if (timer_context.auto_reset) then
			Timer.Reset(timer_context)
		end
	end
end

Timer.Reset = function(timer_context)
	TIM_RESET(timer_context.timer_id)
end

--#endregion

--#region Encoder
Encoder = {}

-- 编码器转一圈发出的脉冲数
Encoder.PulsePerRotation = function()
	return Base.Pow(2, 17)
end

-- 编码器的位置
Encoder.Position = function()
	-- 读取编码器的累计脉冲数。这个数被伺服使用 int 计数，正向溢出后会从最大正数变成最小负数。
	return SRV_MON(10)
end

-- 获取储存在非易失储存器的的编码器位置缓存
Encoder.PositionCache = function()
	return DD(100)
end

-- 设置储存在非易失储存器的的编码器位置缓存
Encoder.SetPositionCache = function(value)
	DD(100, value)
end

-- 获取储存在非易矢储存器的编码器位置偏移量缓存
Encoder.PositionOffsetCache = function()
	return (DD(102) << 32) | DD(101)
end

-- 设置储存在非易矢储存器的编码器位置偏移量缓存
Encoder.SetPositionOffsetCache = function(value)
	DD(101, value & 0xffffffff)
	DD(102, value >> 32)
end

-- 编码器绝对位置缓存。
Encoder.AbsolutePositionCache = function()
	return Encoder.PositionCache() + Encoder.PositionOffsetCache()
end

-- 实时的编码器绝对位置
Encoder.RealTimeAbsolutePosition = function()
	return Encoder.Position() + Encoder.PositionOffsetCache()
end

-- 初始化时更新编码器绝对位置缓存。
Encoder.UpdateAbsolutePositionCacheInInit = function()
	local pulse_offset_cache = Encoder.PositionOffsetCache()
	local cumulative_pulse_cache = Encoder.PositionCache()
	local cumulative_pulse = Encoder.Position()

	-- 上电后，理论的 cumulative_pulse 应该是 0，但是实际上可能因为振动或其他原因，
	-- cumulative_pulse 并不是 0.

	-- 上电后 cumulative_pulse_cache 的值是掉电前储存的编码器累计脉冲数。理论上此时应该将
	-- cumulative_pulse_cache 的值转移到 pulse_offset_cache 中，然后 cumulative_pulse_cache
	-- 清 0. 但是 cumulative_pulse 实际上可能不为 0，所以需要计算偏移量

	-- 将增量储存到 pulse_offset_cache 中，然后 cumulative_pulse_cache 赋值为 cumulative_pulse
	local delta_cumulative_pulse = cumulative_pulse_cache - cumulative_pulse
	Encoder.SetPositionOffsetCache(pulse_offset_cache + delta_cumulative_pulse)
	Encoder.SetPositionCache(cumulative_pulse)
end

-- 在死循环中更新编码器绝对位置缓存。
Encoder.UpdataAbsolutePositionCacheInLoop = function()
	-- 在这里要通过 cumulative_pulse_cache 检测出 cumulative_pulse 的溢出。
	-- 如果发生溢出，要让 pulse_offset_cache 减去溢出后环绕的值
	-- 例如 8 位有符号整型，127+1 后发生方向为负的环绕，环绕量为 -256，-128-1
	-- 后变成 127，发生方向为正的环绕，环绕量为 256

	-- 将值转移给 pulse_offset_cache 后，cumulative_pulse_cache 就可以继续跟踪 cumulative_pulse

	local pulse_offset_cache = Encoder.PositionOffsetCache()
	local cumulative_pulse_cache = Encoder.PositionCache()
	local cumulative_pulse = Encoder.Position()
	local delta_cumulative_pulse = cumulative_pulse - cumulative_pulse_cache

	-- 正转，累计脉冲数上溢后变成负数了，负数减去还是正数的缓存后变成一个很负的数
	if (delta_cumulative_pulse < -2147483648) then
		Encoder.SetPositionOffsetCache(pulse_offset_cache + 2147483648 * 2)
		-- 更新累计脉冲缓存
		Encoder.SetPositionCache(cumulative_pulse)
		return
	end

	-- 反转，发生下溢，溢出到正数那边了，正数减去还是负数的缓存，得到一个特别大的正数
	if (delta_cumulative_pulse > 2147483647) then
		Encoder.SetPositionOffsetCache(pulse_offset_cache - 2147483648 * 2)
		-- 更新累计脉冲缓存
		Encoder.SetPositionCache(cumulative_pulse)
		return
	end

	-- 更新累计脉冲缓存
	Encoder.SetPositionCache(cumulative_pulse)
end

-- 重置编码器的累计脉冲数，连同累计脉冲缓存和累计脉冲偏移量缓存一起清 0.
Encoder.ResetPosition = function()
	-- 位置预置
	Servo.TriggerEIRisingEdge(10)

	-- 清除缓存
	DD(100, 0)
	DD(101, 0)
	DD(102, 0)
end
--#endregion

--#region Base
Base = {}

-- 求 base 的 pow 次幂
-- 只支持整数幂，pow 的小数部分会被丢弃
-- base 会被以浮点数处理
Base.Pow = function(base, pow)
	local ret = 1
	for i = 0, pow - 1 do
		ret = ret * base
	end

	return ret
end
--#endregion

--#region Reel
-- 线轴
Reel = {}

-- 空卷周长。单位：米
Reel.C0 = function()
	if (DF(105) <= 0) then
		DF(105, 1)
	end

	return DF(105)
end

-- 满卷周长。单位：米
Reel.C1 = function()
	if (DF(106) <= Reel.C0()) then
		DF(106, Reel.C0())
	end

	return DF(106)
end

-- 从满卷到空卷的圈数
Reel.N = function()
	if (DD(107) <= 0) then
		DD(107, 100)
	end

	return DD(107)
end

-- 空卷半径
Reel.R0 = function()
	return Reel.C0() / (2 * math.pi)
end

-- 满卷半径
Reel.R1 = function()
	return Reel.C1() / (2 * math.pi)
end

-- 获取线轴当前已经放出的圈数
Reel.n = function()
	local encoder_rotations = Encoder.AbsolutePositionCache() / Encoder.PulsePerRotation()

	-- 减速比 = 电机转的圈数 / 线轴转的圈数
	-- 线轴转的圈数 = 电机转的圈数 / 减速比
	return encoder_rotations / Transmission.ReductionRatio()
end

Reel.RealTime_n = function()
	local encoder_rotations = Encoder.RealTimeAbsolutePosition() / Encoder.PulsePerRotation()

	-- 减速比 = 电机转的圈数 / 线轴转的圈数
	-- 线轴转的圈数 = 电机转的圈数 / 减速比
	return encoder_rotations / Transmission.ReductionRatio()
end

-- 在当前位置的基础上，线轴再转一圈放出的弧长
Reel.DeltaS = function()
	-- Δs = 2 * pi * (r1 - n * (r1 - r0) / N)
	return 2 * math.pi * (Reel.R1() - Reel.n() * (Reel.R1() - Reel.R0()) / Reel.N())
end

--#endregion

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
	return Reel.DeltaS() * Transmission.InputPulsePerMetre()
end

-- 获取放线轴每转一圈，编码器需要转多少圈
Transmission.EncoderRotationsPerReelRotation = function()
	-- 减速比 = 电机转的圈数 / 线轴转的圈数
	-- 电机转的圈数 = 减速比 * 线轴转的圈数
	return Transmission.ReductionRatio() * 1
end

-- 获取放线轴每转一圈，编码器产生多少个脉冲
Transmission.EncoderPulsePerReelRatation = function()
	return Transmission.EncoderRotationsPerReelRotation() * Encoder.PulsePerRotation()
end

-- 获取电子齿轮比。电子齿轮比 = 编码器脉冲个数 / 输入脉冲个数
Transmission.Gear = function()
	local gear = Transmission.EncoderPulsePerReelRatation() / Transmission.InputPulsePerDeltaS()
	return gear
end

-- 将浮点的电子齿轮比转为分数
Transmission.FractionGear = function()
	local gear = Transmission.Gear()
	local gain = (Base.Pow(2, 22) - 1) / gear
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
	DD(1, Reel.RealTime_n())
end
--#endregion 主程序
