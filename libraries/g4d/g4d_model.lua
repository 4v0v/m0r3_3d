local Vectors  = require(G4D_PATH .. "/g4d_vectors")
local Matrices = require(G4D_PATH .. "/g4d_matrices")
local Collisions  = require(G4D_PATH .. "/g4d_collisions")
local load_obj = require(G4D_PATH .. "/g4d_objloader")

local Model = {}

Model.vertex_format = {
	{"VertexPosition", "float", 3},
	{"VertexTexCoord", "float", 2},
	{"VertexNormal"  , "float", 4},
}

Model.shader = require(G4D_PATH .. "/g4d_shaderloader") 

Model.models = {}

for key,value in pairs(Collisions) do
	Model[key] = value
end

function Model:new(file, texture, pos, rot, sca, color)
	local model = setmetatable({}, {__index = Model})

	if type(file) == "table" then
		model.vertices = file
		model.mesh     = love.graphics.newMesh(Model.vertex_format, model.vertices, "triangles")

	elseif type(file) == 'string' then
		local extension = file:sub(-4,-1) 

		if extension == ".obj" then
			model.vertices    = model:generate_normals_inside_vertices(load_obj(file))
			model.mesh        = love.graphics.newMesh(Model.vertex_format, model.vertices, "triangles")
			model.is_animated = false

		elseif extension == ".iqm" or extension == ".exm" then
			model.iqm         = iqm.load(file)
			model.vertices    = model.iqm.triangles
			model.mesh        = model.iqm.mesh
			model.anims       = iqm.load_anims(file)
			model.anim        = anim9(model.anims)

			model.is_animated = true
			
			model.tracks      = {}
			for i, v in ipairs(model.anims) do
				model.tracks[v.name] = model.anim:new_track(v.name)
			end

			model.anim:update(0)
		end
	end

	if type(texture)  == "string" then 
		model.textures = {love.graphics.newImage(texture)}
		model.mesh:setTexture(model.textures[1])

	elseif type(texture) == 'table' then
		model.textures   = {}
		for mat, image in pairs(texture) do
			model.textures[mat] = love.graphics.newImage(image, { mipmaps = true })
		end
	end

	model.x      = pos and pos[1] or 0
	model.y      = pos and pos[2] or 0
	model.z      = pos and pos[3] or 0
	model.rx     = rot and rot[1] or 0
	model.ry     = rot and rot[2] or 0
	model.rz     = rot and rot[3] or 0
	model.sx     = sca and sca[1] or 1
	model.sy     = sca and sca[2] or 1
	model.sz     = sca and sca[3] or 1
	model.matrix = {}

	if not color then color = {} end
	model.color    = {color[1] or 1, color[2] or 1, color[3] or 1, color[4] or 1}
	model.aabb     = model:generate_aabb(model.vertices)

	table.insert(Model.models, model)

	return model
end

function Model:update(dt)
	if self.is_animated then
		self.anim:update(dt)
	end
end

function Model:draw()
	self:update_matrix()
	self.shader:send("model.color", self.color)
	self.shader:send("model.is_animated", self.is_animated)

	-- TODO: check if multiple textures etc...
	if self.is_animated then
		self.shader:send("model.pose"  , "column", unpack(self.anim.current_pose))

		for _, buffer in ipairs(self.iqm.meshes) do
			local texture = self.textures[buffer.material]
			self.iqm.mesh:setTexture(texture)
			self.iqm.mesh:setDrawRange(buffer.first, buffer.last - buffer.first)
			love.graphics.draw(self.iqm.mesh)
		end
	else
		love.graphics.draw(self.mesh)
	end
end

function Model:generate_normals_inside_vertices(vertices, is_flipped)
	local flip = is_flipped and -1 or 1

	for i=1, #vertices, 3 do
		local v1 = vertices[i]
		local v2 = vertices[i+1]
		local v3 = vertices[i+2]

		local vec1   = {v2[1]-v1[1], v2[2]-v1[2], v2[3]-v1[3]}
		local vec2   = {v3[1]-v2[1], v3[2]-v2[2], v3[3]-v2[3]}
		local normal = Vectors:normalize(Vectors:cross_product(vec1,vec2))

		v1[6] = normal[1] * flip
		v1[7] = normal[2] * flip
		v1[8] = normal[3] * flip

		v2[6] = normal[1] * flip
		v2[7] = normal[2] * flip
		v2[8] = normal[3] * flip

		v3[6] = normal[1] * flip
		v3[7] = normal[2] * flip
		v3[8] = normal[3] * flip
	end

	return vertices
end

function Model:transform(x, y, z, rx, ry, rz, sx, sy, sz)
	self.x  = x  or self.x 
	self.y  = y  or self.y 
	self.z  = z  or self.z 
	self.rx = rx or self.rx
	self.ry = ry or self.ry
	self.rz = rz or self.rz
	self.sx = sx or self.sx
	self.sy = sy or self.sy
	self.sz = sz or self.sz
end

function Model:update_matrix()
	local matrix = Matrices:get_transformation_matrix(
		self.x,  self.y,  self.z, 
		self.rx, self.ry, self.rz, 
		self.sx, self.sy, self.sz
	)
	self.shader:send("model.matrix", matrix)
end

function Model:move(x, y, z)
	if type(x) == 'table' then
		self:transform(x[1], x[2], x[3])
	else
		self:transform(x, y, z)
	end
	return self
end

function Model:rotate(rx, ry, rz)
	if type(rx) == 'table' then
		self:transform(_, _, _, rx[1], rx[2], rx[3])
	else
		self:transform(_, _, _, rx, ry, rz)
	end
	return self
end

function Model:scale(sx, sy, sz)
	if type(sx) == 'table' then
		self:transform(_, _, _, _, _, _, sx[1], sx[2], sx[3])
	else
		self:transform(_, _, _, _, _, _, sx, sy or sx, sz or sx) 
	end
	return self
end

function Model:set_color(...) 
	local color = {...}

	self.color[1] = color[1] or 1
	self.color[2] = color[2] or 1
	self.color[3] = color[3] or 1
	self.color[4] = color[4] or 1

	return self
end

function Model:position() 
	return {self.x, self.y, self.z} 
end

function Model:rotation() 
	return {self.rx, self.ry, self.rz} 
end

function Model:get_scale() 
	return {self.sx, self.sy, self.sz} 
end

return setmetatable(Model, {__call = Model.new})
