function Input_PulseRatio()
	return 1
end

-- 收线机收 x 米线会发出 y 个脉冲
-- 这里获取的是其中的 x
function Input_X()
	if (DF(108) <= 0) then
		DF(108, 100)
	end

	return DF(108)
end

-- 收线机收 x 米线会发出 y 个脉冲
-- 这里获取的是其中的 y
function Input_Y()
	if (DD(109) <= 0) then
		DD(109, 100)
	end

	return DD(109)
end
