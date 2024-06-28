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
