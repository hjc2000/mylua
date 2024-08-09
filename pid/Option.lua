--- PID 的比例系数
--- @return number
function Option_PID_KP()
	return DF(100)
end

--- PID 的积分系数
--- @return number
function Option_PID_KI()
	return DF(101)
end

--- PID 的微分系数
--- @return number
function Option_PID_KD()
	return DF(102)
end

--- 积分分离阈值。单位：V
--- 在偏差量的绝对值大于此值时不进行积分累加，偏差量绝对值小于此值后
--- 才开始进行积分累加。
--- @return number
function Option_IntegralSeparationThreshold()
	return DF(103)
end

--- 积分环节的正向饱和值。
--- @return number
function Option_IntegralPositiveSaturation()
	return DF(104)
end

--- 积分环节的负向饱和值。
--- @return number
function Option_IntegralNegativeSaturation()
	return DF(105)
end

--- 期望的电压。单位：V
--- @return number
function Option_ExpectedVoltage()
	return DF(106)
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

--- 对偏差量取相反数。
--- @return boolean 为true表示需要将偏差量取相反数，为false则不用。
function Option_TakeTheOppositeOfError()
	return DD(110) ~= 0
end
