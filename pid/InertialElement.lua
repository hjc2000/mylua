--- 创建一个惯性环节
--- @param T number 惯性时间常数
--- @param sample_interval number 采样周期
--- @return table 上下文
function InertialElement_New(T, sample_interval)
	local context = {}
	context.T = T
	context.sample_interval = sample_interval
	context.y = 0
	return context
end

--- 输入一个值并获取输出。
--- @param context table 上下文
--- @param x number 输入值
--- @return number 输出值
function InertialElement_Input(context, x)
	context.y = (context.T / (context.T + context.sample_interval)) * context.y +
		(context.sample_interval / (context.T + context.sample_interval)) * x

	return context.y
end
