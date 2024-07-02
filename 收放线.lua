--#region Int

-- 检查浮点数是否超过了 int 的表示范围
function FloatOutsideIntRange(value)
	if (value > 2147483647) then
		return true
	end

	if (value < -2147483648) then
		return true
	end
end

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

	-- 同号
	if (left > 0 and right > 0) then
		return left // right
	end

	-- 同号
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

-- 求 base 的 pow 次幂
-- 只支持整数幂，pow 的小数部分会被丢弃
-- base 会被以浮点数处理
function IntPow(base, pow)
	base = FloatToInt(base)
	pow = FloatToInt(pow)

	local ret = 1
	for i = 0, pow - 1 do
		ret = ret * base
	end

	return FloatToInt(ret)
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

--#region Servo

--获取伺服参数
function Servo_GetParam(group, index)
	return SRV_PARA(group, index)
end

-- 设置伺服参数
function Servo_SetParam(group, index, value)
	SRV_PARA(group, index, value)
end

-- 检查参数。参数不对会设置参数
function Servo_CheckParam()
	-- 定位运行模式
	if (Servo_GetParam(1, 1) ~= 7) then
		Servo_SetParam(1, 1, 7)
	end

	-- 速度控制时加减速有效
	if (Servo_GetParam(1, 36) ~= 1) then
		Servo_SetParam(1, 36, 1)
	end

	-- 内部定位数据无效
	if (Servo_GetParam(2, 40) ~= 0) then
		Servo_SetParam(2, 40, 0)
	end

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
	-- EI9 配置为使能
	if (Servo_GetParam(3, 9) ~= 1) then
		Servo_SetParam(3, 9, 1)
	end
	-- EI10 配置为位置预置功能
	if (Servo_GetParam(3, 10) ~= 16) then
		Servo_SetParam(3, 10, 16)
	end
	-- EI11 配置为指令脉冲比率 1，为 ON 时进入脉冲模式
	-- 为 OFF 时可以被正转信号和反转信号控制进行点动。
	if (Servo_GetParam(3, 11) ~= 27) then
		Servo_SetParam(3, 11, 27)
	end
	-- EI12 配置为正转
	if (Servo_GetParam(3, 12) ~= 2) then
		Servo_SetParam(3, 12, 2)
	end
	-- EI13 配置为反转
	if (Servo_GetParam(3, 13) ~= 3) then
		Servo_SetParam(3, 13, 3)
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

-- 获取 EI
function Servo_GetEI(ei_index)
	return SRV_EI(ei_index)
end

-- 设置 EI
function Servo_SetEI(ei_index, value)
	SRV_EI(ei_index, value)
end

-- 让 EI 接收到一个上升沿
function Servo_TriggerEIRisingEdge(ei_index)
	Servo_SetEI(ei_index, 0)
	Delay(1)
	Servo_SetEI(ei_index, 1)
	Delay(1)
	Servo_SetEI(ei_index, 0)
end

-- 重启伺服
function Servo_Restart()
	Servo_SetParam(3, 98, 9999)
end

-- 设置转速
function Servo_SetSpeed(value)
	AXIS_SPEED(value)
end

-- 设置加速时间。单位：毫秒。
Servo_SetAccelerationTime = function(value)
	AXIS_ACCEL(value)
end

-- 设置减速时间。单位：毫秒。
Servo_SetDecelerationTime = function(value)
	AXIS_DECEL(value)
end

-- 设置绝对位置。需要启动定位运行才会真正运行，否则只是设置一个立即数。
Servo_SetAbsolutePosition = function(value)
	AXIS_MOVEABS(value)
end

-- 设置相对位置。需要启动定位运行才会真正运行，否则只是设置一个立即数。
Servo_SetRelativePosition = function(value)
	AXIS_MOVE(value)
end

-- 使能
function Servo_Enable()
	Servo_SetEI(9, 1)
end

-- 失能
function Servo_Disable()
	Servo_SetEI(9, 0)
end

--#endregion

--#region Input

-- 指令脉冲比率 1
function Input_PulseRatio()
	return Servo_GetParam(2, 54)
end

-- 收线机收 x 米线会发出 y 个脉冲
-- 这里获取的是其中的 x
function Input_X()
	if (DD(108) <= 0) then
		DD(108, 100)
	end

	return DD(108)
end

-- 收线机收 x 米线会发出 y 个脉冲
-- 这里获取的是其中的 y
function Input_Y()
	if (DD(109) <= 0) then
		DD(109, 100)
	end

	return DD(109)
end

--#endregion

--#region Encoder

-- 编码器转一圈发出的脉冲数
function Encoder_PulsePerRotation()
	return IntPow(2, 17)
end

-- 编码器累计脉冲数
function Encoder_CumulativePulse()
	return SRV_MON(10)
end

-- 获取编码器累计脉冲数缓存
function Encoder_CumulativePulseCache()
	return DD(100)
end

-- 设置编码器累计脉冲数缓存
function Encoder_SetCumulativePulseCache(value)
	DD(100, value)
end

-- 初始化阶段更新编码器累计脉冲数缓存
function Encoder_UpdateCumulativePulseCacheInInit()
	-- 读取编码器的累计脉冲数。这个数被伺服使用 int 计数，正向溢出后会从最大正数变成最小负数。
	local current_cumulative_pulse = Encoder_CumulativePulse()

	-- 初始化时是上电后重新执行的时候，此时编码器的累计脉冲数归 0，但也有可能因为外力，偏离 0
	-- 一点点。

	-- 将编码器累计脉冲数缓存减去当前累计脉冲数，得到偏差
	local delta_pulse = Encoder_CumulativePulseCache() - current_cumulative_pulse

	-- 偏差量对应编码器转了多少圈
	local delta_encoder_n = IntDiv(delta_pulse, Encoder_PulsePerRotation())

	-- 将 delta_encoder_n 加到当前的编码器圈数偏移量中，因为随后要让累计脉冲数缓存去跟踪当前
	-- 累计脉冲数
	local current_encoder_n_offset = Encoder_n_Offset()
	Encoder_Set_n_Offset(current_encoder_n_offset + delta_encoder_n);

	-- 将累计脉冲数缓存设置为当前的值
	Encoder_SetCumulativePulseCache(current_cumulative_pulse)
end

-- 更新储存在非易失储存器的的编码器累计脉冲数缓存
-- 会同时检查是否溢出，溢出了会增加或减少当前已经转的圈数的偏移量
function Encoder_UpdateCumulativePulseCache()
	-- 读取编码器的累计脉冲数。这个数被伺服使用 int 计数，正向溢出后会从最大正数变成最小负数。
	local current_cumulative_pulse = Encoder_CumulativePulse()

	if (current_cumulative_pulse < (-2147483648 // 2) and Encoder_CumulativePulseCache() > (2147483647 // 2)) then
		-- 发生正向溢出
		local current_encoder_n_offset = Encoder_n_Offset()
		Encoder_Set_n_Offset(current_encoder_n_offset + IntPow(2, 32 - 17))
	end

	if (Encoder_CumulativePulseCache() < (-2147483648 // 2) and current_cumulative_pulse > (2147483647 // 2)) then
		-- 发生负向溢出
		local current_encoder_n_offset = Encoder_n_Offset()
		Encoder_Set_n_Offset(current_encoder_n_offset - IntPow(2, 32 - 17))
	end

	-- 将累计脉冲数缓存设置为当前的值
	Encoder_SetCumulativePulseCache(current_cumulative_pulse)
end

-- 编码器转的圈数的偏移量
function Encoder_n_Offset()
	return DD(101)
end

-- 设置编码器转的圈数的偏移量
function Encoder_Set_n_Offset(value)
	DD(101, value)
end

-- 编码器转过的圈数 = 累计脉冲数计算出来的圈数 + Encoder_n_Offset()
function Encoder_n()
	return IntDiv(Encoder_CumulativePulseCache(), Encoder_PulsePerRotation()) +
		Encoder_n_Offset()
end

-- 重置编码器转过的圈数
function Encoder_Reset()
	-- 将编码器累计脉冲数缓存设置为当前的累计脉冲数
	Encoder_SetCumulativePulseCache(Encoder_CumulativePulse())

	-- 因为要将圈数归 0，但是无法将当前编码器累计脉冲数归 0，所以只能从偏移量入手。
	Encoder_Set_n_Offset(-IntDiv(Encoder_CumulativePulseCache(), Encoder_PulsePerRotation()))
end

--#endregion

--#region Reel

-- 线轴转的圈数
function Reel_n()
	-- 减速比 = 编码器转的圈数 / 线轴转的圈数
	-- 线轴转的圈数 = 编码器转的圈数 / 减速比
	local n = Encoder_n() / Transmission_ReductionRatioNum() * Transmission_ReductionRatioDen()
	return FloatToInt(n)
end

-- 空卷周长。单位：mm
function Reel_C0()
	if (DD(105) <= 0) then
		DD(105, 1)
	end

	return DD(105)
end

-- 满卷周长。单位：mm
function Reel_C1()
	if (DD(106) <= Reel_C0()) then
		DD(106, Reel_C0())
	end

	return DD(106)
end

-- 从满卷到空卷的圈数
function Reel_N()
	if (DD(107) <= 0) then
		DD(107, 100)
	end

	return DD(107)
end

--#endregion

--#region Transmission

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

--#endregion

--#region 主程序

Servo_CheckParam()
Servo_Enable()

-- 初始化后默认进入脉冲模式
Servo_SetEI(11, 1)
Encoder_UpdateCumulativePulseCacheInInit()

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
		-- 检测到触摸屏将 M1 置 1，重置已放出的圈数，并将 M1 置 0.
		Encoder_Reset()
		M(1, 0)
	end

	Timer_Check(timer1_context)

	-- 将线轴已经转的圈数放到 D1 中供触摸屏读取
	DD(1, Reel_n())
end

--#endregion
