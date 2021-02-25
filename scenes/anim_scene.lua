Anim_scene = Scene:extend('Anim_scene')


function Anim_scene:new()
	Anim_scene.super.new(@)

	@:every(fn() return pressed('escape') end, fn() change_scene_with_transition('menu') end)



	@.model =
	{
		file  = "assets/iqm/mrfixit.iqm",
		materials =
		{
			-- [material] = image
			["Body.tga"] = "assets/images/Body.jpg",
			["Head.tga"] = "assets/images/Head.jpg",
		},
		anim_pose = "idle",
		
		-- On load
		--textures = newImage!(materials)
		--iqm = iqm.load(model.file),
		--anim = anim9(iqm.load_anims(model.file)),
		--anim_track = model.anim:new_track(model.anim_pose),
		--center = cmpl.vec3(),
		
		-- Position (offset) of the model
		position = cpml.vec3(0, 0, 0),
		-- Angles of the model
		angles = cpml.vec3(0, 0, 0),
		matrix = cpml.mat4():identity(),
	}
	
	@.model.updateMatrix = function(self)
		local mat, angles, center = self.matrix, self.angles, self.center
		mat:identity()
		mat:translate(mat, -center)
		mat:rotate(mat, angles.x, cpml.vec3.unit_x)
		mat:rotate(mat, angles.y, cpml.vec3.unit_y)
		mat:rotate(mat, angles.z, cpml.vec3.unit_z)
		mat:translate(mat, center + self.position)
	end
	
	@.camera_3d = {
		fov = 90,
		-- Distance relative to model's center
		position = cpml.vec3(6, 0, 0),
		matrix = cpml.mat4():identity(),
	}

	
	@.proj = {}
	@.proj.updateMatrix = function(proj)
		local w, h = love.graphics.getDimensions()
		local isPerspective = proj.matrix == proj.perspective
		proj.ortho = cpml.mat4.from_ortho(-w/100, w/100, h/100, -h/100, -100, 100)
		proj.perspective = cpml.mat4.from_perspective( @.camera_3d.fov , w / h, 0.1, 100.0)
		proj.matrix =  isPerspective and proj.perspective or proj.ortho
	end
	
	@.lightv = cpml.vec3(1, 1, 1)
	@.lightv = @.lightv:normalize()


	@.model.iqm = iqm.load(@.model.file)
	@.model.textures = {}
	for mat, image in pairs(@.model.materials) do
		@.model.textures[mat] = love.graphics.newImage(image, { mipmaps = true })
	end

	-- Calculate the center of the model based on bounds
	-- This helps rotating it about its center (by dragging mouse)
	local bounds = @.model.iqm.bounds.base
	local min = cpml.vec3(bounds.min)
	local max = cpml.vec3(bounds.max)
	@.model.center = (min + max) / 2

	@.model:updateMatrix()

	@.model.anim = anim9(iqm.load_anims(@.model.file))
	@.model.anim.animations[@.model.anim_pose].loop = true
	
	@.model.anim_track = @.model.anim:new_track(@.model.anim_pose)
	@.model.anim:play(@.model.anim_track)
	@.model.anim:update(0) -- init animation

	@.camera_3d.position = @.camera_3d.position + (@.model.position + @.model.center)
	@.camera_3d.matrix:look_at(@.camera_3d.matrix, @.camera_3d.position, @.model.position + @.model.center, cpml.vec3.unit_z)

	@.proj:updateMatrix()

	@.shader = love.graphics.newShader("assets/shaders/anim_shader.glsl")
	-- connect with the gui
	-- gui.createGUI(model, @.proj)

end

function Anim_scene:update(dt)
	Anim_scene.super.update(@, dt)

	@.model.anim:update(dt)
end

function Anim_scene:draw_outside_camera_fg()
	love.graphics.setShader(@.shader)
	@.shader:send("u_pose", "column", unpack(@.model.anim.current_pose))
	@.shader:send("u_model", "column", @.model.matrix:to_vec4s())
	@.shader:send("u_camera", "column", @.camera_3d.matrix:to_vec4s())
	@.shader:send("u_light", {@.lightv:unpack()})
	@.shader:send("u_proj", "column", @.proj.matrix:to_vec4s())
	love.graphics.setDepthMode("less", true)
	love.graphics.setMeshCullMode("back")
	for _, buffer in ipairs(@.model.iqm.meshes) do
		local texture = @.model.textures[buffer.material]
		@.model.iqm.mesh:setTexture(texture)
		@.model.iqm.mesh:setDrawRange(buffer.first, buffer.last - buffer.first)
		love.graphics.draw(@.model.iqm.mesh)
	end
	love.graphics.setDepthMode()
	love.graphics.setShader()
	-- gui.draw()
end

