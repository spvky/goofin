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
    apply_thing_velocity(delta);
    #if DEV_MODE {
        if editor_mode {
            thing_editor_picking(*current_room.things);
        }
    }
}
