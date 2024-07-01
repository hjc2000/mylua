function Input_PulseRatio()
	-- 指令脉冲比率 1
	return Servo_GetParam(2, 54)
end

-- 收线机收 x 米线会发出 y 个脉冲
-- 这里获取的是其中的 x
function Input_X()
	if (DD(108) <= 0) then
		DD(108, 100)
	end

	return DD(108)
end

-- 收线机收 x 米线会发出 y 个脉冲
-- 这里获取的是其中的 y
function Input_Y()
	if (DD(109) <= 0) then
		DD(109, 100)
	end

	return DD(109)
end
