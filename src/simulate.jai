simulate :: (delta: float32) {
    process_input();
    cam_delta: Vector2;
    if is_action_pressed(.CAM_UP) {
        cam_delta.y += 1;
    }
    if is_action_pressed(.CAM_DOWN) {
        cam_delta.y -= 1;
    }
    if is_action_pressed(.CAM_LEFT) {
        cam_delta.x -= 1;
    }
    if is_action_pressed(.CAM_RIGHT) {
        cam_delta.x += 1;
    }
    camera.target += cam_delta * delta * 100;
    for *t: debug_room_things {
        if t.kind == .CHARACTER {
            td := t.character_data;
            t.position += td.velocity * delta;
        }
    }
    #if DEV_MODE {
        thing_editor_picking(*debug_room_things);
    }
}
