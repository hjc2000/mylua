--- 新建一个PID控制器。
--- @param kp number
--- @param ki number
--- @param kd number
--- @param integral_positive_saturation number 积分正饱和
--- @param integral_negative_saturation number 积分负饱和
--- @return table PID控制器上下文。
function PidController_New(kp, ki, kd,
						   integral_positive_saturation,
						   integral_negative_saturation)
	local context = {}
	context.kp = kp
	context.ki = ki
	context.kd = kd
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
--- @param use_integral boolean 是否使用积分环节
--- @return number PID输出
function PidController_Input(context, x, use_integral)
	context.x2 = context.x1
	context.x1 = context.x0
	context.x0 = x

	context.p = context.p + context.kp * (context.x0 - context.x1)

	if (use_integral) then
		context.i = context.i + context.ki * context.x0

		-- 积分饱和
		if (context.i > context.integral_positive_saturation) then
			context.i = context.integral_positive_saturation
		elseif (context.i < context.integral_negative_saturation) then
			context.i = context.integral_negative_saturation
		end
	else
		context.i = 0
	end

	context.d = context.d + context.kd * (context.x0 - 2 * context.x1 + context.x2)

	return context.p + context.i + context.d
end
