dofile("pid/PidController.lua")
dofile("pid/InertialElement.lua")

local pid_controller_context = PidController_New(1000, 100, 0,
	10, -- 积分分离阈值
	1,
	0
)

local inertial_element_context = InertialElement_New(1, 0.01)

local x = 1
local e = x
for i = 0, 1000 do
	local y = PidController_Input(pid_controller_context, e)
	y = InertialElement_Input(inertial_element_context, y)
	e = x - y

	if (i % 10 == 0) then
		print(y)
	end
end
