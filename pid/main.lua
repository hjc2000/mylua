if (DD == nil) then
	dofile("pid/PidController.lua")
end

local pid_controller_context = PidController_New(0.5, 0.05, 0, 110, -110)

local x = 100
local y = 0
local e = x - y
for i = 0, 200 do
	y = PidController_Input(pid_controller_context, e, true)
	e = x - y
	print(y)
end
