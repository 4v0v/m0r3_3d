local Vectors = {}

function Vectors:normalize(vec)
	local dist = math.sqrt(vec[1]^2 + vec[2]^2 + vec[3]^2)
	return { vec[1]/dist, vec[2]/dist, vec[3]/dist }
end

function Vectors:dot_product(a, b)
	return a[1]*b[1] + a[2]*b[2] + a[3]*b[3]
end

function Vectors:cross_product(a, b)
	return { a[2]*b[3] - a[3]*b[2], a[3]*b[1] - a[1]*b[3], a[1]*b[2] - a[2]*b[1] }
end

return Vectors
