--- 新建一个PID控制器。
--- @param kp number
--- @param ki number
--- @param kd number
--- @param integral_separation_threshold number
--- @param output_max number
--- @param output_min number
--- @return table PID控制器上下文。
function PidController_New(kp, ki, kd,
						   integral_separation_threshold,
						   output_max,
						   output_min)
	local context = {}
	context.kp = kp
	context.ki = ki
	context.kd = kd
	context.integral_separation_threshold = integral_separation_threshold
	context.output_max = output_max
	context.output_min = output_min

	context.x0 = 0
	context.x1 = 0
	context.x2 = 0
	context.y = 0

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

	local p = context.kp * (context.x0 - context.x1)

	local i = 0
	if (math.abs(context.y) >= context.integral_separation_threshold) then
		-- 积分分离
		i = context.ki * context.x0
	end

	local d = context.kd * (context.x0 - 2 * context.x1 + context.x2)

	context.y = p + i + d + context.y

	-- 限幅并输出
	local output = context.y

	if (output > context.output_max) then
		output = context.output_max
	elseif (output < context.output_min) then
		output = context.output_min
	end

	return output
end
