local core = {
	_VERSION = "1.1.4"
}

local info_type = {
	GIVEN = 0,
	TAKEN = 1
}

-- https://sampwiki.blast.hk/wiki/BodyParts
local body_parts = {
    TORSO = 3,
    GROIN = 4,
    LEFT_ARM = 5,
    RIGHT_ARM = 6,
    LEFT_LEG = 7,
    RIGHT_LEG = 8,
    HEAD = 9
}

function core.vector2d(x, y)
    local base = {x = x, y = y}
    base.raw_mult = function(self, vec)
        return self.x * vec.x, self.y * vec.y
    end

    return base
end

function core.init(screen_size, dmg_font, nickname_font, configs, info_velocity)
    print("Initializing core...")
    core.screen_size = screen_size
    core.dmg_font = dmg_font
    core.nickname_font = nickname_font
	core.configs = configs
    core.info_velocity = info_velocity
end

local function set_alpha(argb, new_alpha)
    new_alpha = bit.band(new_alpha, 0xFF)
    local rgb = bit.band(argb, 0x00FFFFFF)
	local new_argb = bit.bor(bit.lshift(new_alpha, 24), rgb)
	if new_argb < 0 then
        new_argb = new_argb + 2^32
    end

    return new_argb
end

local function PlayerCombo(player_id, count, timestamp)
	return {
		player_id = player_id,
		count = count,
		timestamp = timestamp,
		increase_count = function(self, amount)
			self.count = self.count + amount
		end,
		has_ended = function(self)
			return os.clock() - self.timestamp >= core.configs.info_duration
		end
	}
end

local function DamageInfo(kind)
	return {
		kind = kind,
		is_valid = function(self)
			return self.timestamp ~= nil and self.timestamp > 0
		end,
		has_ended = function(self)
			return self.elapsed_time >= core.configs.info_duration
		end,
		update = function(self)
			if not self:is_valid() then return end
			self.elapsed_time = os.clock() - self.timestamp
			if self:has_ended() then return end

			local relative_life_time = self.elapsed_time / core.configs.info_duration
			self.current_alpha = math.max(math.ceil((1 - relative_life_time) * 255), 0)

			self.relative_x, self.relative_y = self.initial_dmg_pos.x, self.initial_dmg_pos.y
			self.relative_y = self.relative_y - (self.elapsed_time * core.info_velocity.y)
		end
	}
end

local function GivenDamageInfo()
	local base = DamageInfo(info_type.GIVEN)

	base.render = function(self)
		if not self:is_valid() or self:has_ended() then return end

		local nick_text = string.format("%s[%s]", self.nick, self.player_id)
		local new_nick_color = set_alpha(self.nick_color, self.current_alpha)
		local new_given_dmg_color = set_alpha(self.dmg_color, self.current_alpha)
		local new_combo_color = set_alpha(core.configs.combo_color, self.current_alpha)
		local nick_x, nick_y = core.screen_size:find_abs_positions(self.initial_nick_pos.x, self.initial_nick_pos.y)
		local posx, posy = core.screen_size:find_abs_positions(self.relative_x, self.relative_y)
		if not self.is_paused then
			local combo_text = string.format("(x%d)", self.combo_count)
			local dmg_text = string.format("%0.1f", self.damage)
			local displacement = core.configs.dmg_font_size * (#dmg_text + 0.5)
			renderFontDrawText(core.dmg_font, combo_text, posx + displacement, posy, new_combo_color)
			renderFontDrawText(core.dmg_font, dmg_text, posx, posy, new_given_dmg_color)
		else
			local new_afk_color = set_alpha(core.configs.afk_color, self.current_alpha)
			renderFontDrawText(core.dmg_font, "AFK", posx, posy, new_afk_color)
		end
		renderFontDrawText(core.nickname_font, nick_text, nick_x, nick_y, new_nick_color)
	end

	return base
end

local function TakenDamageInfo()
	local base = DamageInfo(info_type.TAKEN)

	base.render = function(self)
		if not self:is_valid() or self:has_ended() then return end

		local nick_text = string.format("%s[%s]", self.nick, self.player_id)
		local new_nick_color = set_alpha(self.nick_color, self.current_alpha)
		local new_taken_dmg_color = set_alpha(self.dmg_color, self.current_alpha)
		local nick_x, nick_y = core.screen_size:find_abs_positions(self.initial_nick_pos.x, self.initial_nick_pos.y)
		local posx, posy = core.screen_size:find_abs_positions(self.relative_x, self.relative_y)
		local dmg_text = string.format("%0.1f", self.damage)

		renderFontDrawText(core.dmg_font, dmg_text, posx, posy, new_taken_dmg_color)
		renderFontDrawText(core.nickname_font, nick_text, nick_x, nick_y, new_nick_color)
	end

	return base
end

local function ObjectPool(max_size, ctor)
	assert(max_size ~= nil and max_size > 0, "Invalid pool size")
	assert(ctor ~= nil, "Invalid ctor")
	return {
		max_size = max_size,
		index = 0,
		infos = {},

		init = function(self)
			for i = 1, self.max_size do
				table.insert(self.infos, ctor())
			end
		end,

		get = function(self)
			self.index = math.fmod(self.index, self.max_size) + 1
			print("Taking from pool with index " .. self.index)
			return self.infos[self.index]
		end
	}
end

local player_combos = {
	combos = {},
	find_by_id = function(self, id)
		assert(id ~= nil, "Null id to player combos.")
		return self.combos[tostring(id)]
	end,
	insert = function(self, id)
		assert(id ~= nil, "Null id to player combos.")
		local combo = self.combos[tostring(id)]
		local timestamp = os.clock()
		if combo == nil then
			self.combos[tostring(id)] = PlayerCombo(id, 1, timestamp)
		else
			combo:increase_count(1)
			combo.timestamp = timestamp
		end
	end,
	update = function(self)
		for k,v in pairs(self.combos) do
			if v:has_ended() then
				v.count = 0
			end
		end
	end
}

core.body_parts = body_parts
core.info_type = info_type
core.set_alpha = set_alpha
core.DamageInfo = DamageInfo
core.PlayerCombo = PlayerCombo
core.GivenDamageInfo = GivenDamageInfo
core.TakenDamageInfo = TakenDamageInfo
core.ObjectPool = ObjectPool
core.player_combos = player_combos

return core