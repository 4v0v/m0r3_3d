--[[
 4v0v - MIT license
 based on groverbuger's g3d 
 https://github.com/groverburger/g3d
      __ __        __     
     /\ \\ \      /\ \    
   __\ \ \\ \     \_\ \   
 /'_ `\ \ \\ \_   /'_` \  
/\ \L\ \ \__ ,__\/\ \L\ \ 
\ \____ \/_/\_\_/\ \___,_\
 \/___L\ \ \/_/   \/__,_ /
   /\____/                
   \_/__/                 
--]]

love.graphics.setDepthMode("lequal", true)

G4D_PATH     = ...
local model  = require(G4D_PATH .. "/g4d_model")
local camera = require(G4D_PATH .. "/g4d_camera")
local shader = require(G4D_PATH .. "/g4d_shaderloader")
G4D_PATH     = nil

local G4d = {
	camera    = camera,
	shader    = shader, 
	add_model = model,
	models    = model.models,
}

function G4d:draw(x, y)
	love.graphics.setShader(self.shader)

	for _, model in ipairs(self.models) do 
		model:draw()
	end

	love.graphics.setShader()
end


return G4d