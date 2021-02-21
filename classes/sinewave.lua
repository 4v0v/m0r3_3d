Sinewave = Class:extend('Sinewave')

function Sinewave:new(value, amplitude, duration)
	@.initial   = value     or 0
	@.amplitude = amplitude or 1
	@.duration  = duration  or 1
	@.timer     = 0
	@.sin       = 0
	@.cos       = 0
	@.playing   = true
end

function Sinewave:update(dt)
	if !@.playing then return end
	
	@.timer += dt
	@.timer %= @.duration

	local percent_of_timer = @.timer / @.duration
	local part_of_radius   = 2*math.pi * percent_of_timer

	@.sin = @.amplitude * math.sin(part_of_radius)
	@.cos = @.amplitude * math.cos(part_of_radius)
end

function Sinewave:stop()
	@.playing = false
end

function Sinewave:play()
	@.playing = true
end

function Sinewave:get() 
	return @.initial + @.sin
end

function Sinewave:get_sin() 
	return @.initial + @.sin
end

function Sinewave:get_cos() 
	return @.initial + @.cos
end

function Sinewave:set(value)
	@.initial = value
end
