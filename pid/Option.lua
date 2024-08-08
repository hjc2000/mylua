--- PID 的比例系数
--- @return number
function Option_PID_KP()
	return DD(0)
end

--- PID 的积分系数
--- @return number
function Option_PID_KI()
	return DD(1)
end

--- PID 的微分系数
--- @return number
function Option_PID_KD()
	return DD(2)
end

--- 积分分离阈值。在偏差量的绝对值大于此值时不进行积分累加，偏差量绝对值小于此值后
--- 才开始进行积分累加。
--- @return number
function Option_IntegralSeparationThreshold()
	return DD(3)
end

--- 积分环节的正向饱和值。
--- @return number
function Option_IntegralPositiveSaturation()
	return DD(4)
end

--- 积分环节的负向饱和值。
--- @return number
function Option_IntegralNegativeSaturation()
	return DD(5)
end
