acid_biter_speed_modifier = 1.3
acid_biter_health_modifier = 0.25
acid_biter_tint1 = {
    r = 0,
    g = 1,
    b = 0,
    a = 1
}
acid_biter_tint2 = {
    r = 0.25,
    g = 1,
    b = 0.25,
    a = 1
}
acid_biter_suffix = "-acid"

local function acid_biter_dying_trigger_effect(radius, damage, evolution_size)
    return {{
        type = "play-sound",
        sound = {{
            filename = "__base__/sound/creatures/projectile-acid-burn-1.ogg",
            volume = 0.65
        }, {
            filename = "__base__/sound/creatures/projectile-acid-burn-2.ogg",
            volume = 0.65
        }, {
            filename = "__base__/sound/creatures/projectile-acid-burn-long-1.ogg",
            volume = 0.6
        }, {
            filename = "__base__/sound/creatures/projectile-acid-burn-long-2.ogg",
            volume = 0.6
        }}
    }, {
        type = "create-fire",
        entity_name = "acid-splash-fire-worm-" .. evolution_size,
        tile_collision_mask = {"water-tile"},
        show_in_tooltip = true
    }, {
        type = "create-entity",
        entity_name = "water-splash",
        tile_collision_mask = {"ground-tile"}
    }, {
        type = "nested-result",
        action = {
            type = "area",
            radius = radius,
            force = "enemy",
            ignore_collision_condition = true,
            action_delivery = {
                type = "instant",
                target_effects = {{
                    type = "create-sticker",
                    sticker = "acid-sticker-" .. evolution_size
                }, {
                    type = "damage",
                    damage = {
                        amount = damage,
                        type = "acid"
                    }
                }}
            }
        }
    }}
end

-- Set the tint for all layers of an animation that are a mask and not a shadow
local function apply_tint(animation, tint1, tint2)
    for i, layer in ipairs(animation.layers) do
        add_tint = false
        if layer.flags then
            for _, flag in ipairs(layer.flags) do
                if flag == "mask" then
                    add_tint = true
                    break
                end
            end
        end
        add_tint = add_tint and not draw_as_shadow

        if add_tint then
            tint = tint1
            if i > 0 then
                tint = tint2
            end
            layer.tint = tint
            layer.hr_version.tint = tint
        end
    end
end

acid_biter_by_evolution_size = {} -- evolution size => entity prototype

evolution_sizes = {"small", "medium", "big", "behemoth"}
base_biter_suffix = "-biter"

acid_biter_attributes = {
    ["small"] = {
        death_splash_radius = 2.5,
        death_damage = damage_modifier_spitter_small,
        attack_range = 1
    },
    ["medium"] = {
        death_splash_radius = 3,
        death_damage = damage_modifier_spitter_medium,
        attack_range = 2
    },
    ["big"] = {
        death_splash_radius = 4.5,
        death_damage = damage_modifier_spitter_big,
        attack_range = 3
    },
    ["behemoth"] = {
        death_splash_radius = 6,
        death_damage = damage_modifier_spitter_behemoth,
        attack_range = 4
    }
}

spitter_by_evolution_size = {}
for _, evolution_size in ipairs(evolution_sizes) do
    local base_spitter_name = evolution_size .. "-spitter"
    local spiter = table.deepcopy(data.raw["unit"][base_spitter_name])
    spitter_by_evolution_size[evolution_size] = spiter
end

-- Copy base biters
for _, evolution_size in ipairs(evolution_sizes) do
    local base_biter_name = evolution_size .. base_biter_suffix
    local biter = table.deepcopy(data.raw["unit"][base_biter_name])
    acid_biter_by_evolution_size[evolution_size] = biter
end

-- Modify the base biters into acid biters
for evolution_size, acid_biter in pairs(acid_biter_by_evolution_size) do
    local acid_biter_attribute = acid_biter_attributes[evolution_size]

    acid_biter.name = acid_biter.name .. acid_biter_suffix
    acid_biter.movement_speed = acid_biter.movement_speed * acid_biter_speed_modifier
    acid_biter.max_health = acid_biter.max_health * acid_biter_health_modifier

    -- FIXME: this only works because no base biters have acid resistance
    local acid_resistance = {
        type = "acid",
        decrease = 0,
        percent = 100
    }
    table.insert(acid_biter.resistances, acid_resistance)

    -- Tint the biter
    apply_tint(acid_biter.run_animation, acid_biter_tint1, acid_biter_tint2)

    acid_biter.dying_trigger_effect = acid_biter_dying_trigger_effect(acid_biter_attribute.death_splash_radius,
        acid_biter_attribute.death_damage, evolution_size)

    local acid_attack_parameters = spitter_by_evolution_size[evolution_size].attack_parameters
    acid_attack_parameters.range = acid_biter_attribute.attack_range
    acid_attack_parameters.cooldown = acid_biter.attack_parameters.cooldown
    acid_attack_parameters.animation = acid_biter.attack_parameters.animation
    apply_tint(acid_attack_parameters.animation, acid_biter_tint1, acid_biter_tint2)

    acid_biter.attack_parameters = acid_attack_parameters
end

log("add acid biters?")
log(serpent.block(evolution_sizes))
log(serpent.block(acid_biter_by_evolution_size))

-- Add acid biters
for _, acid_biter in pairs(acid_biter_by_evolution_size) do
    log("adding biter")
    data:extend({acid_biter})
end

-- Add the acid biter spawner
local acid_biter_spawner = table.deepcopy(data.raw["unit-spawner"]["biter-spawner"])
acid_biter_spawner.name = acid_biter_spawner.name .. acid_biter_suffix
acid_biter_spawner.result_units = {{"small-biter-acid", {{0.0, 0.3}, {0.6, 0.0}}},
                                   {"medium-biter-acid", {{0.2, 0.0}, {0.6, 0.3}, {0.7, 0.1}}},
                                   {"big-biter-acid", {{0.5, 0.0}, {1.0, 0.4}}},
                                   {"behemoth-biter-acid", {{0.9, 0.0}, {1.0, 0.3}}}}
for _, animation in ipairs(acid_biter_spawner.animations) do
    apply_tint(animation, acid_biter_tint1, acid_biter_tint2)
end

data:extend({acid_biter_spawner})
