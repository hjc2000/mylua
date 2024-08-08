dofile("pid/PidController.lua")

local pid_controller_context = PidController_New(0.9, 0.05, 0,
	50,
	110,
	-110)

local x = 100
local y = 0
local e = x - y
for i = 0, 200 do
	y = PidController_Input(pid_controller_context, e)
	e = x - y
	print(y)
end
