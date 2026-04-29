Entity :: struct {
    using position: Vector2;
    velocity: Vector2;
    map: *Texture;
}

entities: [..]Entity;

make_entity :: (position: Vector2) {
    print("New Entity\n");
    array_add(*entities, Entity.{position = position, velocity = .{0, 0}, map = *bug_tex});
}

render_entities :: () {
    for e, i: entities {
        pos := cam_relative_position(e.position);
        render_sprite_centered(e.map, pos, .{100, 100}, .{1, 1, 1, 1});
        #if DEV_MODE {
            if editor_selection.mode == .Entity {
                color := Vector4.{1, 1, 1, 1};
                if i == xx editor_selection.selected_entity_idx {
                    color = Vector4.{1, 0, 0, 0};
                }
                render_square(pos, .{10, 10}, color);
            }
        }
    }
}

#if DEV_MODE {
    set_entity_inspector_fields :: (entity: *Entity) {
        x := formatFloat(entity.position.x, 2, 2, zero_removal = .NO);
        y := formatFloat(entity.position.y, 2, 2, zero_removal = .NO);
        pos_string_x = sprint("%", x);
        pos_string_y = sprint("%", y);
    }

    entity_picking :: () {
        if editor_selection.mode == .Entity {
            pos := mouse_position_to_world();
            data := *editor_selection.entity_data;
            if is_action_pressed(.EDITOR_SELECT) {
                for entity, i: entities {
                    if distance(pos, entity.position) < 30 && !data.held_entity {
                        data.held_entity = true;
                        data.held_entity_idx = xx i;
                        editor_selection.selected_entity_idx = xx i;
                        break;
                    }
                }
            } else {
                data.held_entity = false;
                set_entity_inspector_fields(*entities[data.held_entity_idx]);
            }
            if data.held_entity {
                entity := *entities[data.held_entity_idx];
                entity.position = pos;
                set_entity_inspector_fields(entity);
            }
        }
    }
}
