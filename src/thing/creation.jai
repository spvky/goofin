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
    points[0] = .{-50, 50};
    points[1] = .{-50, -50};
    points[2] = .{50, -50};
    points[3] = .{50, 50};
    return make_collision_poly(position, points);
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
