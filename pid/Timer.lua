--- 毫秒延时
--- @param milliseconds integer
function Delay(milliseconds)
	DELAY(milliseconds)
end

--- 构造一个新的定时器。会自动分配空闲的定时器。
--- 如果没有空闲的定时器，会返回 nil，否则返回定时器上下文
--- 需要用 Timer_Start 函数启动定时器。
--- @param interval_in_milliseconds integer 定时周期。单位：ms
---
--- @param auto_reset boolean 每次定时时间到后，触发回调后是否自动重置定时时间到标识。
--- 重置后要下一次定时时间到 Timer_Check 才会再次触发回调。
--- 如果不自动重置，则必须手动重置，否则即使定时时间没到，Timer_Check 也会触发回调。
---
--- @param callback_func function 回调函数。
--- @return table 定时器上下文。
function Timer_New(interval_in_milliseconds, auto_reset, callback_func)
	-- 数组，索引为 n 的位置为 true 表示定时器 ID 是 n 的定时器正在被使用
	G_timer_usage_states = {}

	local timer_context = {}

	for i = 0, 29 do
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

--- 释放定时器。
--- 会先调用 Timer_Stop
--- @param timer_context table 定时器上下文。
function Timer_Free(timer_context)
	Timer_Stop(timer_context)
	G_timer_usage_states[timer_context.timer_id] = false
end

--- 启动定时器。
--- @param timer_context table 定时器上下文。
--- @param callback_immediately boolean 为 true 则会立刻执行一次回调，不用等到定时时间到。
function Timer_Start(timer_context, callback_immediately)
	if (timer_context.callback_func ~= nil and callback_immediately) then
		timer_context.callback_func()
	end

	TIM_START(timer_context.timer_id, timer_context.interval_in_milliseconds)
end

--- 停止定时器
--- @param timer_context table 定时器上下文。
function Timer_Stop(timer_context)
	TIM_STOP(timer_context.timer_id)
end

--- 检查定时时间是否到了，到了会触发回调。需要在循环中被反复调用。
--- @param timer_context table 定时器上下文。
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

--- 重置定时器的定时时间到标识。
--- @param timer_context table 定时器上下文。
function Timer_Reset(timer_context)
	TIM_RESET(timer_context.timer_id)
end
