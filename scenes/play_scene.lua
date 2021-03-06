Play_scene = Scene:extend('Play_scene')

function Play_scene:new()
	Play_scene.super.new(@)

	@.map    = g4d.add_model("assets/obj/map.obj", "assets/images/tileset.png"):scale(1, -1, -1)
	@.moon   = g4d.add_model('assets/obj/sphere.obj', 'assets/images/moon.png'):move(5, -10, 0):scale(2)
	@.cube1  = g4d.add_model('assets/obj/cube.obj'):move(-2, 0, 24):set_color(0, 1, 1)
	@.cube2  = g4d.add_model('assets/obj/cube.obj'):move(-6, 0, 24):set_color(1, 0, 1)
	@.cube3  = g4d.add_model('assets/obj/cube.obj'):move(-10, 0, 24):set_color(1, 1, 0)
	@.cube4  = g4d.add_model('assets/obj/cube.obj'):move(-2, 0, 16):set_color(1, 0, 0)
	@.cube5  = g4d.add_model('assets/obj/cube.obj'):move(-6, 0, 16):set_color(0, 1, 0)
	@.cube6  = g4d.add_model('assets/obj/cube.obj'):move(-5, 5, 5):set_color(0, 0, 1)
	@.light2 = g4d.add_model('assets/obj/sphere.obj'):move(-5, 5, 5):set_color(.3, .3, .3)


	@.mrfixit = g4d.add_model('assets/iqm/mrfixit.iqm', {
		["Body.tga"] = "assets/images/Body.jpg",
		["Head.tga"] = "assets/images/Head.jpg",
	}):move(-10, 2, 0):rotate(math.pi/2, 0, 0)
	@.mrfixit.anim.animations['idle'].loop = true
	@.mrfixit.anim:play(@.mrfixit.tracks.idle)
	@.mrfixit.anim:update(0) -- init animation


	@.dude = g4d.add_model('assets/iqm/human.iqm', {
		["TextureClothedLightSkin2"] = "assets/images/TextureClothedLightSkin2.png",
	}):move(-10, 0, 5):rotate(math.pi/2, 0, 0)
	@.dude.anim.animations['Idle'].loop = true
	@.dude.anim:play(@.dude.tracks.Idle)
	@.dude.anim:update(0) -- init animation


	@.ending = g4d.add_model('assets/iqm/ending.iqm', {["Material.001"] = "assets/images/ending.png"}):move(-30, 0, 0):rotate(math.pi/2, 0, 0)
	@.ending.anim.animations['cutscene'].loop = true
	@.ending.anim:play(@.ending.tracks.cutscene)
	@.ending.anim:update(0) -- init animation

	print(@.cube1.aabb.min)
	print(@.cube1.aabb.max)


	print(@.dude.aabb.min)
	print(@.dude.aabb.max)


	@.sinewave  = Sinewave(0, 10, 3)
	@.cube_dist = Lerp(10)

	@:every(fn() return @.moon:collide_with_aabb(@.cube1) end, fn() print('collision') end )
	@:every(fn() return @.ending:collide_with_aabb(@.cube1) end, fn() print('dude collision') end )
	@:every(fn() return pressed('escape') end, fn() change_scene_with_transition('menu') end)
end

function Play_scene:update(dt)
	Play_scene.super.update(@, dt)
	g4d:update(dt)

	@.sinewave:update(dt)
	@.cube_dist:update(dt)

	if down('q')      then g4d.camera:update(dt, 'left')   end
	if down('d')      then g4d.camera:update(dt, 'right')  end
	if down('lshift') then g4d.camera:update(dt, 'up')     end
	if down('lctrl')  then g4d.camera:update(dt, 'down')   end
	if down('z')      then g4d.camera:update(dt, 'toward') end
	if down('s')      then g4d.camera:update(dt, 'back')   end

	@.cube1:move(
		g4d.camera.x + (g4d.camera.tx - g4d.camera.x) * @.cube_dist:get(), 
		g4d.camera.y + (g4d.camera.ty - g4d.camera.y) * @.cube_dist:get(), 
		g4d.camera.z + (g4d.camera.tz - g4d.camera.z) * @.cube_dist:get()
	)
	@.light2:move(_, 5 + @.sinewave:get_cos())
	@.moon:rotate(@.moon.rx + dt)
	@.cube2:rotate(_, @.cube2.ry + dt)
	@.cube3:rotate(_, _, @.cube3.rz + dt)
	@.cube4:rotate(@.cube4.rx + dt)
	@.cube5:rotate(_, @.cube5.ry + dt)
	@.cube6:rotate(_, _, @.cube6.rz + dt)
end


function Play_scene:draw_outside_camera_fg()
	g4d:draw()
end

function Play_scene:enter()
	lm.setRelativeMode(true)
end

function Play_scene:exit()
	lm.setRelativeMode(false)
end

function Play_scene:mousemoved(x, y, dx, dy)
	g4d.camera:mousemoved(dx,dy)
end

function Play_scene:wheelmoved(x, y)
	@.cube_dist:lerp(@.cube_dist:get() + y * 2)
end
