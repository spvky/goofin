MAX_THINGS_PER_ROOM :: 128;

Thing :: struct {
    using position: Vector2;
    kind: Thing_Kind;
    using collision_data: Collision_Data;
    #overlay (collision_data) using character_data: Character_Data;
}

Thing_Room_Manager :: struct {
    things: [MAX_THINGS_PER_ROOM]Thing;
    used: [MAX_THINGS_PER_ROOM]bool;
    next_free: int = 0;
}

debug_room_things: Thing_Room_Manager;

for_expansion :: (tm: *Thing_Room_Manager, body: Code, flags: For_Flags) #expand {
    for ok, i: tm.used {
        if !ok continue;
        `it_index := i;
        `it := *tm.things[i];
        #insert body;
    }
}

add_thing :: (tm: *Thing_Room_Manager, thing: Thing) {
    for i: 0..tm.next_free - 1 {
        if !tm.used[i] {
            tm.used[i] = true;
            tm.things[i] = thing;
            return;
        }
    }
    tm.used[tm.next_free] = true;
    tm.things[tm.next_free] = thing;
    tm.next_free += 1;
}

clear_thing_at_index :: (tm: *Thing_Room_Manager, i: int) {
    tm.things[i] = .{};
    tm.used[i] = false;
}

get_thing_ptr :: (tm: *Thing_Room_Manager, i: int) -> *Thing {
    return *tm.things[i];
}

Thing_Kind :: enum {
    NIL :: 0;
    CHARACTER :: 1;
    COLLISION :: 2;
}

Character_Data :: struct @thing_data {
    velocity: Vector2; @editor_display
    size := Vector2.{100, 100}; @editor_display
    map: *Texture;
}

// Because of the nature of putting arrays through my codegen proc these will be handled manually until that becomes annoying, leaving the editor display tags here to remind myself
Collision_Data :: struct @thing_data {
    collision_shape: Collision_Shape;
    is_sensor := false;
    verts: void;
    polygon_verts: [4]Vector2; @editor_display
    #overlay (polygon_verts) aabb_extents: [2]Vector2; @editor_display
    #overlay (polygon_verts) triangle_verts: [3]Vector2; @editor_display
}

Collision_Shape :: enum {
    TRIANGLE;
    POLYGON;
    AABB;
}

Character_Kind :: enum {
    BUG :: 0;
}

make_collision_aabb :: (position: Vector2, min: Vector2, max: Vector2) -> Thing {
    thing: Thing;
    thing.position = position;
    thing.kind = .COLLISION;
    thing.collision_shape = .AABB;
    thing.aabb_extents = .[min, max];
    return thing;
}

make_collision_aabb_simple :: (position: Vector2) -> Thing {
    points: [2]Vector2;
    points[0] = .{-50, -50};
    points[1] = .{50, 50};
    return make_collision_aabb(position, points[0], points[1]);
}

make_collision_tri :: (position: Vector2, points: [3]Vector2) -> Thing {
    thing: Thing;
    thing.position = position;
    thing.kind = .COLLISION;
    thing.collision_shape = .TRIANGLE;
    thing.triangle_verts = points;
    return thing;
}

make_collision_right_tri :: (position: Vector2) -> Thing {
    points: [3]Vector2;
    points[0] = .{-50, 50};
    points[1] = .{-50, -50};
    points[2] = .{50, -50};
    return make_collision_tri(position, points);
}

make_collision_poly :: (position: Vector2, points: [4]Vector2) -> Thing {
    thing: Thing;
    thing.position = position;
    thing.kind = .COLLISION;
    thing.collision_shape = .POLYGON;
    thing.polygon_verts = points;
    return thing;
}

make_collision_poly_square :: (position: Vector2) -> Thing {
    points: [4]Vector2;
    points[0] = .{-50, -50};
    points[1] = .{-50, 50};
    points[2] = .{50, 50};
    points[3] = .{50, -50};
    return make_collision_poly(position, points);
}

get_collision_vertex_collection :: (thing: *Thing) -> []Vector2 {
    collection: []Vector2;
    if thing.collision_shape == {
    case .AABB;
        collection = thing.aabb_extents;
    case .TRIANGLE;
        collection = thing.triangle_verts;
    case .POLYGON;
        collection = thing.polygon_verts;
    }
    return collection;
}

make_character :: (position := Vector2.{0, 0}, velocity := Vector2.{0, 0}, character_kind: Character_Kind = .BUG) -> Thing {
    thing: Thing;
    thing.position = position;
    thing.kind = .CHARACTER;
    map: *Texture;
    if character_kind == {
    case .BUG;
        map = *bug_tex;
    }
    thing.character_data = Character_Data.{
                                           velocity = velocity,
                                           map = map};
    return thing;
}

render_single_thing :: (thing: *Thing) {
    pos := cam_relative_position(thing.position);
    if thing.kind == {
    case .CHARACTER;
        render_sprite_centered(thing.map, pos, thing.size, .{1, 1, 1, 1});
    case .COLLISION;
        Simp.set_shader_for_color();
        if thing.collision_shape == {
        case .AABB;
            p0 := pos + .{thing.aabb_extents[0].x, thing.aabb_extents[0].y};
            p1 := pos + .{thing.aabb_extents[0].x, thing.aabb_extents[1].y};
            p2 := pos + .{thing.aabb_extents[1].x, thing.aabb_extents[1].y};
            p3 := pos + .{thing.aabb_extents[1].x, thing.aabb_extents[0].y};
            Simp.immediate_quad(p0, p1, p2, p3, .{0, 0, 0.7, 1});
        case .TRIANGLE;
            p0 := pos + thing.triangle_verts[0];
            p1 := pos + thing.triangle_verts[1];
            p2 := pos + thing.triangle_verts[2];
            Simp.immediate_quad(p0, p0, p1, p2, .{0, 0.7, 0, 1});
        case .POLYGON;
            p0 := pos + thing.polygon_verts[0];
            p1 := pos + thing.polygon_verts[1];
            p2 := pos + thing.polygon_verts[2];
            p3 := pos + thing.polygon_verts[3];
            Simp.immediate_quad(p0, p1, p2, p3, .{0.7, 0, 0, 1});
        }
    }
}

render_things_in_room :: (tm: Thing_Room_Manager) {
    for thing, i: tm {
        pos := cam_relative_position(thing.position);
        render_single_thing(thing);
        #if DEV_MODE {
            selected_entity := i == xx editor_selection.selected_entity_idx;
            if selected_entity {
                render_square(pos, .{10, 10}, .{1, 0, 0, 1});
                if editor_selection.locked {
                    if thing.kind == .COLLISION {
                        verts := get_collision_vertex_collection(thing);
                        for v: verts {
                            render_square(pos + v, .{10, 10}, .{1, 1, 1, 1});
                        }
                    }
                }
            } else if !selected_entity && !editor_selection.locked {
                render_square(pos, .{10, 10}, .{1, 1, 1, 1});
            }
        }
    }
}

apply_thing_velocity :: (delta: float32) {
    for *t: debug_room_things {
        if t.kind == .CHARACTER {
            t.position += t.velocity * delta;
        }
    }
}

#if DEV_MODE {
    thing_editor_picking :: (tm: *Thing_Room_Manager) {
        pos := mouse_position_to_world();
        data := *editor_selection.entity_data;
        if is_action_pressed(.EDITOR_SELECT) {
            if editor_selection.locked {
                thing := get_thing_ptr(tm, editor_selection.selected_entity_idx);
                verts := get_collision_vertex_collection(thing);
                for v, i: verts {
                    adjusted_v := thing.position + v;
                    if distance(pos, adjusted_v) < 30 {
                        data.held_entity_component_idx = xx i;
                        data.held_component = true;
                        break;
                    }
                }
            } else {
                for thing, i: tm {
                    if distance(pos, thing.position) < 30 && !data.held_entity {
                        data.held_entity = true;
                        data.held_entity_idx = xx i;
                        editor_selection.selected_entity_idx = xx i;
                        break;
                    }
                }
            }
        } else {
            data.held_entity = false;
            data.held_component = false;
        }
        if data.held_entity {
            thing := get_thing_ptr(tm, data.held_entity_idx);
            thing.position = pos;
        }
        if data.held_component {
            thing := get_thing_ptr(tm, data.held_entity_idx);
            comp_ptr := *thing.polygon_verts[data.held_entity_component_idx];
            comp_ptr.* = pos - thing.position;
        }
    }
}
