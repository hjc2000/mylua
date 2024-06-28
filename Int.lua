-- 将浮点转为 32 位整型。会进行截断，使得结果更靠近 0
-- value 大于 2147483647 会返回 2147483647
-- value 小于 -2147483648 会返回 -2147483648
function FloatToInt(value)
	if (value > 2147483647) then
		return 2147483647
	end

	if (value < -2147483648) then
		return -2147483648
	end

	if (value > 0) then
		return math.floor(value)
	end

	return math.ceil(value)
end

-- left / right
-- 结果会被截断，使得结果更靠近 0
function IntDiv(left, right)
	left = FloatToInt(left)
	right = FloatToInt(right)

	if (left > 0 and right > 0) then
		return left // right
	end

	if (left < 0 and right < 0) then
		return left // right
	end

	-- left 和 right 异号
	if (left < 0) then
		left = -left
	end

	if (right < 0) then
		right = -right
	end

	local div = left // right
	return -div
end

-- left % right
function IntMod(left, right)
	local div = IntDiv(left, right)
	return left - right * div
end

function IntDivMod(left, right)
	local ret = {}
	ret.div = IntDiv(left, right)
	ret.mod = IntMod(left, right)
	return ret
end

-- 求 base 的 pow 次幂
-- 只支持整数幂，pow 的小数部分会被丢弃
-- base 会被以浮点数处理
function IntPow(base, pow)
	base = FloatToInt(base)
	pow = FloatToInt(pow)

	local ret = 1
	for i = 0, pow - 1 do
		ret = ret * base
	end

	return FloatToInt(ret)
end
