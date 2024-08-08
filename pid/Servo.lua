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
	-- 速度控制模式
	if (Servo_GetParam(1, 1) ~= 1) then
		Servo_SetParam(1, 1, 1)
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
	-- EI9
	-- EI9 配置为使能
	if (Servo_GetParam(3, 9) ~= 1) then
		Servo_SetParam(3, 9, 1)
	end

	-- EI10
	-- EI10 配置为通信转速选择
	if (Servo_GetParam(3, 10) ~= 18) then
		Servo_SetParam(3, 10, 18)
	end

	-- EI11
	if (Servo_GetParam(3, 11) ~= 0) then
		Servo_SetParam(3, 11, 0)
	end

	-- EI12
	if (Servo_GetParam(3, 12) ~= 0) then
		Servo_SetParam(3, 12, 0)
	end

	-- EI13
	if (Servo_GetParam(3, 13) ~= 0) then
		Servo_SetParam(3, 13, 0)
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
	Delay(5)
	Servo_SetEI(ei_index, 1)
	Delay(5)
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
function Servo_SetAccelerationTime(value)
	AXIS_ACCEL(value)
end

-- 设置减速时间。单位：毫秒。
function Servo_SetDecelerationTime(value)
	AXIS_DECEL(value)
end

--- 使能
function Servo_Enable()
	Servo_SetEI(9, 1)
end

--- 失能
function Servo_Disable()
	Servo_SetEI(9, 0)
end

--- 模拟输入电压
--- @return number
function Sservo_Vref()
	return SRV_MON(16)
end
