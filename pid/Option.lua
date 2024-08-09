--- PID 的比例系数
--- @return number
function Option_PID_KP()
	return DD(100)
end

--- PID 的积分系数
--- @return number
function Option_PID_KI()
	return DD(101)
end

--- PID 的微分系数
--- @return number
function Option_PID_KD()
	return DD(102)
end

--- 积分分离阈值。单位：0.01V
--- 在偏差量的绝对值大于此值时不进行积分累加，偏差量绝对值小于此值后
--- 才开始进行积分累加。
--- @return number
function Option_IntegralSeparationThreshold()
	return DD(103) / 100
end

--- 积分环节的正向饱和值。
--- @return number
function Option_IntegralPositiveSaturation()
	return DD(104)
end

--- 积分环节的负向饱和值。
--- @return number
function Option_IntegralNegativeSaturation()
	return DD(105)
end

--- 期望的电压。单位：0.01V
--- 触摸屏使用整型进行设置，单位为 0.01V. 脚本中获取到值后除以 100，转换为 V。
--- @return number
function Option_ExpectedVoltage()
	return DD(106) / 100
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
