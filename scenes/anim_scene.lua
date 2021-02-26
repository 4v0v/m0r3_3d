Anim_scene = Scene:extend('Anim_scene')


function Anim_scene:new()
	Anim_scene.super.new(@)

	@:every(fn() return pressed('escape') end, fn() change_scene_with_transition('menu') end)


	@.camera_3d = {
		fov      = 90,
		position = cpml.vec3(5, 0, 0),
		matrix   = cpml.mat4():identity(),
	}

	@.proj = {}
	@.proj.updateMatrix = function(proj)
		local w, h = love.graphics.getDimensions()
		local isPerspective = proj.matrix == proj.perspective
		proj.ortho = cpml.mat4.from_ortho(-w/100, w/100, h/100, -h/100, -100, 100)
		proj.perspective = cpml.mat4.from_perspective( @.camera_3d.fov , w / h, 0.1, 100.0)
		proj.matrix =  isPerspective and proj.perspective or proj.ortho
	end
	

	@.model = {}
	@.model.pose      = 'walk'
	@.model.file      = "assets/iqm/mrfixit.iqm"
	@.model.materials = {
			["Body.tga"] = "assets/images/Body.jpg",
			["Head.tga"] = "assets/images/Head.jpg",
	}
	@.model.position   = cpml.vec3(0, 0, 0)
	@.model.angles     = cpml.vec3(0, 0, 0)
	@.model.matrix     = cpml.mat4():identity()

	@.model.iqm        = iqm.load(@.model.file)
	@.model.anims      = iqm.load_anims(@.model.file)
	@.model.anim		 = anim9(@.model.anims)

	@.model.tracks     = {} 
	for i, v in ipairs(@.model.anims) do
		@.model.tracks[v.name] = @.model.anim:new_track(v.name)
	end
	
	@.model.textures   = {}
	for mat, image in pairs(@.model.materials) do
		@.model.textures[mat] = love.graphics.newImage(image, { mipmaps = true })
	end

	@.model.anim.animations['idle'].loop = true
	@.model.anim:play(@.model.tracks.idle)
	@.model.anim:update(0) -- init animation


	function @.model:updateMatrix()
		local mat, angles, center = self.matrix, self.angles, self.center
		mat:identity()
		mat:translate(mat, -center)
		mat:rotate(mat, angles.x, cpml.vec3.unit_x)
		mat:rotate(mat, angles.y, cpml.vec3.unit_y)
		mat:rotate(mat, angles.z, cpml.vec3.unit_z)
		mat:translate(mat, center + self.position)
	end
	local bounds = @.model.iqm.bounds.base
	local min    = cpml.vec3(bounds.min)
	local max    = cpml.vec3(bounds.max)
	@.model.center = (min + max) / 2
	@.model:updateMatrix()
	@.camera_3d.position = @.camera_3d.position + (@.model.position + @.model.center)
	@.camera_3d.matrix:look_at(@.camera_3d.matrix, @.camera_3d.position, @.model.position + @.model.center, cpml.vec3.unit_z)
	@.proj:updateMatrix()

	@.shader = love.graphics.newShader("assets/shaders/anim_shader.glsl")
end

function Anim_scene:update(dt)
	Anim_scene.super.update(@, dt)

	@.model.anim:update(dt)
end

function Anim_scene:keypressed(k)
	if k == 'a' then 
		@.model.anim:transition(@.model.tracks.idle)
		-- @.model.anim:update(0) -- init animation
	end
end
function Anim_scene:draw_outside_camera_fg()
	lg.setColor(0.2, 0.5, 0.3)
	lg.rectangle('fill', 0, 0, lg.getWidth(), lg.getHeight())
	lg.setColor(1, 1, 1)
	love.graphics.setShader(@.shader)
	love.graphics.setDepthMode("less", true)
	love.graphics.setMeshCullMode("back")

	@.shader:send("u_proj"  , "column", @.proj.matrix:to_vec4s())
	@.shader:send("u_camera", "column", @.camera_3d.matrix:to_vec4s())
	@.shader:send("u_model" , "column", @.model.matrix:to_vec4s())
	@.shader:send("u_pose"  , "column", unpack(@.model.anim.current_pose))

	for _, buffer in ipairs(@.model.iqm.meshes) do
		local texture = @.model.textures[buffer.material]
		@.model.iqm.mesh:setTexture(texture)
		@.model.iqm.mesh:setDrawRange(buffer.first, buffer.last - buffer.first)
		love.graphics.draw(@.model.iqm.mesh)
	end

	love.graphics.setDepthMode()
	love.graphics.setShader()
end

