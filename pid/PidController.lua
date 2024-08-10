--- 新建一个PID控制器。
--- @param kp number 比例
--- @param ki number 积分
--- @param kd number 微分
--- @param integral_separation_threshold number 积分分离阈值
--- @param output_max number 输出限幅。最大值。
--- @param output_min number 输出限幅。最小值。
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

	context.y  = context.y + context.kp * (context.x0 - context.x1)

	if (math.abs(x) <= context.integral_separation_threshold) then
		-- 偏差减小，投入积分
		context.y = context.y + context.ki * context.x0
	end

	context.y = context.y + context.kd * (context.x0 - 2 * context.x1 + context.x2)

	-- 输出限幅
	if (context.y > context.output_max) then
		context.y = context.output_max
	elseif (context.y < context.output_min) then
		context.y = context.output_min
	end

	return context.y
end

--- 更改 PID 控制器的参数
--- @param context table 上下文
--- @param kp number 比例
--- @param ki number 积分
--- @param kd number 微分
--- @param integral_separation_threshold number 积分分离阈值
--- @param output_max number 输出限幅。最大值。
--- @param output_min number 输出限幅。最小值。
function PidController_ChangeParameters(context,
										kp, ki, kd,
										integral_separation_threshold,
										output_max,
										output_min)
	context.kp = kp
	context.ki = ki
	context.kd = kd
	context.integral_separation_threshold = integral_separation_threshold
	context.output_max = output_max
	context.output_min = output_min
end
