local Vectors = {}

function Vectors:add(v1,v2,v3, v4,v5,v6)
	return v1+v4, v2+v5, v3+v6
end

function Vectors:subtract(v1,v2,v3, v4,v5,v6)
	return v1-v4, v2-v5, v3-v6
end

function Vectors:scalar_multiply(scalar, v1,v2,v3)
	return v1*scalar, v2*scalar, v3*scalar
end

function Vectors:magnitude(x,y,z)
	return math.sqrt(x^2 + y^2 + z^2)
end

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

function Vectors:fast_normalize(x,y,z)
	local mag = math.sqrt(x^2 + y^2 + z^2)
	return x/mag, y/mag, z/mag
end

function Vectors:fast_dot_product(a1,a2,a3, b1,b2,b3)
	return a1*b1 + a2*b2 + a3*b3
end

function Vectors:fast_cross_product(a1,a2,a3, b1,b2,b3)
	return a2*b3 - a3*b2, a3*b1 - a1*b3, a1*b2 - a2*b1
end


return Vectors
