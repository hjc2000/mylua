--- 获取伺服参数
--- @param group integer 组索引
--- @param index integer 参数子索引
--- @return number 参数值
function Servo_GetParam(group, index)
	return SRV_PARA(group, index)
end

--- 设置伺服参数
--- @param group integer 组索引
--- @param index integer 参数子索引
--- @param value number 参数值
function Servo_SetParam(group, index, value)
	SRV_PARA(group, index, value)
end

--- 配置伺服参数
function Servo_ConfigParam()
	-- 速度控制模式
	Servo_SetParam(1, 1, 1)
	Servo_SetVrefFilterTime(10)

	--#region 硬件 EI 分配
	-- EI1
	Servo_SetParam(3, 1, 0)

	-- EI2
	Servo_SetParam(3, 2, 0)

	-- EI3
	Servo_SetParam(3, 3, 0)

	-- EI4
	Servo_SetParam(3, 4, 0)

	-- EI5
	Servo_SetParam(3, 5, 0)
	--#endregion

	--#region 通信 EI 分配
	-- EI9
	-- EI9 配置为使能
	Servo_SetParam(3, 9, 1)

	-- EI10
	-- EI10 配置为通信转速选择
	Servo_SetParam(3, 10, 18)

	-- EI11
	-- 正转指令
	Servo_SetParam(3, 11, 2)

	-- EI12
	Servo_SetParam(3, 12, 0)

	-- EI13
	Servo_SetParam(3, 13, 0)

	-- EI14
	Servo_SetParam(3, 14, 0)

	-- EI15
	Servo_SetParam(3, 15, 0)

	-- EI16
	Servo_SetParam(3, 16, 0)

	-- EI17
	Servo_SetParam(3, 17, 0)

	-- EI18
	Servo_SetParam(3, 18, 0)

	-- EI19
	Servo_SetParam(3, 19, 0)

	-- EI20
	Servo_SetParam(3, 20, 0)

	-- EI21
	Servo_SetParam(3, 21, 0)

	-- EI22
	Servo_SetParam(3, 22, 0)

	-- EI23
	Servo_SetParam(3, 23, 0)

	-- EI24
	Servo_SetParam(3, 24, 0)
	--#endregion
end

--- 获取 EI
--- @param ei_index integer EI 索引
--- @return integer EI 值。会是 0 或 1。
function Servo_GetEI(ei_index)
	return SRV_EI(ei_index)
end

--- 设置 EI
--- @param ei_index integer EI 索引。
--- @param value integer EI 值。只能是 0 或 1。
function Servo_SetEI(ei_index, value)
	SRV_EI(ei_index, value)
end

--- 让 EI 接收到一个上升沿
--- @param ei_index integer EI 索引
function Servo_TriggerEIRisingEdge(ei_index)
	Servo_SetEI(ei_index, 0)
	Delay(5)
	Servo_SetEI(ei_index, 1)
	Delay(5)
	Servo_SetEI(ei_index, 0)
end

--- 重启伺服
function Servo_Restart()
	Servo_SetParam(3, 98, 9999)
end

--- 设置转速
--- @param value number
function Servo_SetSpeed(value)
	AXIS_SPEED(value)
end

--- 使能
function Servo_Enable()
	Servo_SetEI(9, 1)
end

--- 失能
function Servo_Disable()
	Servo_SetEI(9, 0)
end

--- 模拟输入电压。单位：V
--- @return number
function Servo_Vref()
	return SRV_MON(16) / 100
end

--- 伺服的模拟输入电压端子的滤波时间常数。单位：ms
--- @return number
function Servo_VrefFilterTime()
	return Servo_GetParam(3, 49) / 100
end

--- 设置伺服的模拟输入电压端子的滤波时间常数。单位：ms
--- @param value number
function Servo_SetVrefFilterTime(value)
	Servo_SetParam(3, 49, math.floor(value * 100))
end
