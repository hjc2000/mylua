dofile("pid/PidController.lua")
dofile("pid/InertialElement.lua")

local pid_controller_context = PidController_New(1000, 0.5, 0,
	0.5, -- 积分分离阈值
	1.5, -- 积分上限
	-1.5 -- 积分下限
)

local inertial_element_context = InertialElement_New(100, 0.001)

local x = 1
local y = 0
local e = x - y
for i = 0, 2000 do
	y = PidController_Input(pid_controller_context, e)
	y = InertialElement_Input(inertial_element_context, y)
	e = x - y
	print(y)
end
