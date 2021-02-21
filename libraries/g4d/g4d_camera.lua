local Matrices = require(G4D_PATH .. '/g4d_matrices')
local cos, sin, max, min, abs, atan2, sqrt = math.cos, math.sin, math.max, math.min, math.abs, math.atan2, math.sqrt

local function sign(x) 
	if x < 0 then return -1 else return 1 end 
end

local function not_zero_cos(x)
	return sign(math.cos(x)) * math.max(math.abs(math.cos(x)), .001)
end

local function unpack_params(p1, p2, p3) 
	if type(p1) == 'table' then return p1[1], p1[2], p1[3] else return p1, p2, p3 end
end

local Camera = {}

function Camera:new()
	local cam = setmetatable({}, {__index = Camera})

	cam.aspect_ratio = love.graphics.getWidth()/love.graphics.getHeight()
	cam.shader       = require(G4D_PATH .. "/g4d_shaderloader")
	cam.fov          = math.pi/3
	cam.near_clip    = .01
	cam.far_clip     = 1000
	cam.down         = {0, -1, 0} -- 1: flip camera
	cam.sensitivity  = .003
	cam.speed        = 10
	cam.x            = 0
	cam.y            = 0
	cam.z            = 0
	cam.tx           = 0
	cam.ty           = 0
	cam.tz           = 1
	cam.yaw          = 0
	cam.pitch        = 0

	cam:update_projection_matrix('projection')
	cam:update_view_matrix()

	return cam
end

function Camera:update(dt, dir)
	local speed = self.speed * dt
	local dx    = 0
	local dy    = 0
	local dir_t = 0

		-- move camera's absolute position
	if     dir == 'right_abs' then self.x = self.x + speed
	elseif dir == 'left_abs'  then self.x = self.x - speed
	elseif dir == 'forth_abs' then self.z = self.z + speed
	elseif dir == 'back_abs'  then self.z = self.z - speed
	elseif dir == 'up'        then self.y = self.y + speed
	elseif dir == 'down'      then self.y = self.y - speed
		-- move camera relative to target
	elseif dir == 'left'      then dx    = -1
	elseif dir == 'right'     then dx    =  1
	elseif dir == 'forth'     then dy    = -1
	elseif dir == 'back'      then dy    =  1
		-- move camera toward / away from its target		
	elseif dir == 'away_from' then dir_t = -1
	elseif dir == 'toward'    then dir_t =  1 end

	if dx ~= 0 or dy ~= 0 then
		local angle = atan2(dy, dx)
		local dir_x = cos(self.yaw + angle)           
		local dir_z = sin(self.yaw + angle + math.pi) 

		self.x = self.x + speed * dir_x
		self.z = self.z + speed * dir_z
	end

	if dir_t ~= 0 then 
		local sign = 0 
		if     math.cos(self.pitch) > 0 then sign =  1
		elseif math.cos(self.pitch) < 0 then sign = -1 end

		local cos_pitch = not_zero_cos(self.pitch)
		local tx = sin(self.yaw) * cos_pitch
		local ty = sin(self.pitch)
		local tz = cos(self.yaw) * cos_pitch

		self.x = self.x + tx * speed * dir_t
		self.y = self.y + ty * speed * dir_t
		self.z = self.z + tz * speed * dir_t
	end
	
	self:look_in_dir()
end

function Camera:mousemoved(dx, dy)
	local dir   = self.yaw + dx * self.sensitivity
	local pitch = max(min(self.pitch + dy * self.sensitivity, math.pi/2), -math.pi/2)
	self:look_in_dir(dir, pitch)
end

function Camera:position()
	return {self.x, self.y, self.z}
end

function Camera:move(x, y, z)
	local x, y, z = unpack_params(x, y, z)
	self.x, self.y, self.z = x or self.x, y or self.y, z or self.z

	self:update_view_matrix()
end

function Camera:look_at(tx, ty, tz)
	local tx, ty, tz = unpack_params(tx, ty, tz)
	self.tx, self.ty, self.tz = tx or self.tx, ty or self.ty, tz or self.tz
	if self.tx == 0 then self.tx = .001 end

	local dx = self.tx - self.x
	local dy = self.ty - self.y
	local dz = self.tz - self.z

	self.yaw   = -atan2(dz, dx) + math.pi/2
	self.pitch = -atan2(dy, sqrt(dx^2 + dz^2))

	self:update_view_matrix()
end

function Camera:look_in_dir(yaw, pitch)
	self.yaw   = yaw   or self.yaw
	self.pitch = pitch or self.pitch

	local cos_pitch = not_zero_cos(self.pitch)
	self.tx = self.x + sin(self.yaw) * cos_pitch
	self.ty = self.y + sin(self.pitch)
	self.tz = self.z + cos(self.yaw) * cos_pitch

	self:update_view_matrix()
end

function Camera:update_view_matrix(dt)
	self.shader:send('camera.view_matrix', Matrices:get_view_matrix({self.x, self.y, self.z}, {self.tx, self.ty, self.tz}, self.down))

	if self.shader:hasUniform('camera.position') then 
		self.shader:send('camera.position', {self.x, self.y, self.z, 1})
	end
end

function Camera:update_projection_matrix(type)
	local matrix
	if     type == 'projection'   then
		matrix = Matrices:get_projection_matrix(self.fov, self.near_clip, self.far_clip, self.aspect_ratio)
	elseif type == 'orthographic' then
		matrix = Matrices:get_orthographic_matrix(self.fov, size or 5, self.near_clip, self.far_clip, self.aspect_ratio)
	end

	self.shader:send('camera.projection_matrix', matrix)
end

return Camera:new()
