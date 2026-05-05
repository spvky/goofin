MAX_THINGS_PER_ROOM :: 128;

Thing :: struct {
    using position: Vector2;
    kind: Thing_Kind;
    collision_data: Collision_Data;
    #overlay (collision_data) character_data: Character_Data;
}

Thing_Room_Manager :: struct {
    things: [MAX_THINGS_PER_ROOM]Thing;
    used: [MAX_SHAPES_PER_ROOM]bool;
    next_free: int = 0;
}

debug_room_things: Thing_Room_Manager;

for_expansion :: (tm: Thing_Room_Manager, body: Code, flags: For_Flags) #expand {
    for ok, i: tm.used {
        if !ok continue;
        `it_index := i;
        `it := tm.things[i];
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

Character_Data :: struct {
    velocity: Vector2;
    size := Vector2.{100, 100};
    map: *Texture;
}

Collision_Data :: struct {
    kind: Collision_Shape_Kind;
    is_sensor := false;
    polygon_verts: [4]Vector2;
    #overlay (polygon_verts) aabb_extents: [2]Vector2;
    #overlay (polygon_verts) triangle_verts: [3]Vector2;
}

Character_Kind :: enum {
    BUG :: 0;
}

make_collision_aabb :: (position: Vector2, min: Vector2, max: Vector2) -> Thing {
    thing: Thing;
    thing.position = position;
    thing.kind = .COLLISION;
    thing.collision_data = .{kind = .AABB, aabb_extents = .[min, max]};
    return thing;
}

make_collision_tri :: (position: Vector2, points: [3]Vector2) -> Thing {
    thing: Thing;
    thing.position = position;
    thing.kind = .COLLISION;
    thing.collision_data = .{kind = .TRIANGLE, triangle_verts = points};
    return thing;
}

make_collision_poly :: (position: Vector2, points: [4]Vector2) -> Thing {
    thing: Thing;
    thing.position = position;
    thing.kind = .COLLISION;
    thing.collision_data = .{kind = .POLYGON, polygon_verts = points};
    return thing;
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
        data := thing.character_data;
        render_sprite_centered(data.map, pos, data.size, .{1, 1, 1, 1});
    case .COLLISION;
        data := thing.collision_data;
        if data.kind == {
        case .AABB;
            p0 := pos + .{data.aabb_extents[0].x, data.aabb_extents[0].y};
            p1 := pos + .{data.aabb_extents[0].x, data.aabb_extents[1].y};
            p2 := pos + .{data.aabb_extents[1].x, data.aabb_extents[1].y};
            p3 := pos + .{data.aabb_extents[1].x, data.aabb_extents[0].y};
            Simp.immediate_quad(p0, p1, p2, p3, .{0, 0, 0.7, 1});
        case .TRIANGLE;
            p0 := pos + data.triangle_verts[0];
            p1 := pos + data.triangle_verts[1];
            p2 := pos + data.triangle_verts[2];
            Simp.immediate_quad(p0, p0, p1, p2, .{0, 0.7, 0, 1});
        case .POLYGON;
            p0 := pos + data.polygon_verts[0];
            p1 := pos + data.polygon_verts[1];
            p2 := pos + data.polygon_verts[2];
            p3 := pos + data.polygon_verts[3];
            Simp.immediate_quad(p0, p1, p2, p3, .{0.7, 0, 0, 1});
        }
    }
}

render_things_in_room :: (tm: Thing_Room_Manager) {
    // print("Things Next Free: %\n", tm.next_free);
    // print("3rd Thing: %\n", tm.things[2]);
    // print("Things Used: %\n", tm.used);
    for thing, i: tm {
        if tm.used[i] {
            // print("Thing: %\n", thing);
        }
        render_single_thing(*thing);
    }
}
