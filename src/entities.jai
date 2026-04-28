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
