ACTION_OPTIONS: [2]string: .[
                             "Collision",
                             "Entity"];

inspector_subwindow := Get_Rect.Subwindow_Info.{
                                                rect = #run Get_Rect.get_rect(cast(float32)n_window.width - 610, cast(float32)n_window.height - 810, 600, 800),
                                                draw = draw_inspector_panel,
                                                title_text = "Inspector"};

actions_subwindow := Get_Rect.Subwindow_Info.{
                                              rect = #run Get_Rect.get_rect(0, cast(float32)n_window.height - 400, 200, 250),
                                              draw = draw_actions_panel,
                                              title_text = "Actions"};

save_subwindow := Get_Rect.Subwindow_Info.{
                                           rect = #run Get_Rect.get_rect(0, 0, 340, 250),
                                           draw = draw_save_panel,
                                           title_text = "Save Room"};

load_subwindow := Get_Rect.Subwindow_Info.{
                                           rect = #run Get_Rect.get_rect(0, cast(float32)n_window.height - 300, 340, 250),
                                           draw = draw_load_panel,
                                           title_text = "Load Room"};

draw_inspector_panel :: (state: *Get_Rect.Subwindow_State, r: Get_Rect.Rect, data: *void) {
    locked_rect := Get_Rect.get_rect(r.x + r.w - 200, r.y + r.h - 60, 200, 50);
    pressed := Get_Rect.base_checkbox(locked_rect, "Locked", editor_state.locked, *my_theme.checkbox_theme);
    editor_state.locked ^= pressed;

    ent_idx := editor_state.selected_entity_idx;
    entity := get_thing_ptr(*current_room.things, ent_idx);

    label_left_margin := r.x - 5;
    text_left_margin := r.x + 30;
    y_pos := r.y + r.h - 60;

    label_extents := Vector2.{600, 35};
    text_extents := Vector2.{150, 35};
    field_index: s64;

    if entity.kind == {
    case .CHARACTER;
        draw_character_data_fields();
    case .COLLISION;
        col_shape := entity.collision_shape;
        draw_collision_data_fields(col_shape);
    }

    mouse_pos := mouse_position_to_world();
    pos_label := Get_Rect.get_rect(r.x - 10, r.y - 20, 400, 80);
    mouse_x, mouse_y := float_fmt(mouse_pos.x), float_fmt(mouse_pos.y);
    Get_Rect.label(pos_label, tprint("{%, %}", mouse_x, mouse_y), *my_theme.label_theme);
}

draw_actions_panel :: (state: *Get_Rect.Subwindow_State, r: Get_Rect.Rect, data: *void) {
    dropdown_rect := Get_Rect.get_rect(r.x, r.y + r.h - 50, 200, 50);
    rect1 := Get_Rect.get_rect(r.x, r.y + r.h - 105, 200, 50);
    rect2 := Get_Rect.get_rect(r.x, r.y + r.h - 160, 200, 50);
    rect3 := Get_Rect.get_rect(r.x, r.y + r.h - 215, 200, 50);

    Get_Rect.dropdown(dropdown_rect, ACTION_OPTIONS, *editor_state.current_action_set);
    if editor_state.current_action_set == {
    case 0;
        _, _, aabb_released := Get_Rect.button(rect1, "AABB");
        _, _, tri_released := Get_Rect.button(rect2, "Tri");
        _, _, poly_released := Get_Rect.button(rect3, "Polygon");
        if aabb_released {
            editor_state.action_state = .MAKE_AABB;
        }
        if tri_released {
            editor_state.action_state = .MAKE_TRI;
        }
        if poly_released {
            editor_state.action_state = .MAKE_POLY;
        }

    case 1;
        _, _, entity_released := Get_Rect.button(rect1, "Entity");
        if entity_released {
            editor_state.action_state = .MAKE_ENTITY;
        }
    }
}

draw_save_panel :: (state: *Get_Rect.Subwindow_State, r: Get_Rect.Rect, data: *void) {
    text_extents := Vector2.{300, 50};
    room_name_rect := Get_Rect.get_rect(r.x + 20, r.y + r.h - 80, text_extents.x, text_extents.y);
    room_name_action, new_room_name, room_name_state := Get_Rect.text_input(room_name_rect, current_room.name, *my_theme.text_input_theme);
    if room_name_action & .ENTERED modify_string(*current_room.name, new_room_name);

    save_button_rect := Get_Rect.get_rect(r.x + 20, r.y + r.h - 150, 145, 50);
    _, _, save_released := Get_Rect.button(save_button_rect, "Save");
    if save_released {
        save_room_to_file(*current_room);
        editor_state.room_dirty = false;
    }

    new_button_rect := Get_Rect.get_rect(r.x + 170, r.y + r.h - 150, 145, 50);
    _, _, new_released := Get_Rect.button(new_button_rect, "New");
    if new_released {
        make_new_room();
        editor_state.room_dirty = false;
    }
}

draw_load_panel :: (state: *Get_Rect.Subwindow_State, r: Get_Rect.Rect, data: *void) {
    button_extents := Vector2.{200, 60};
    room_files_rect := Get_Rect.get_rect(r.x + 20, r.y + 20, r.w - 40, r.h - 40);

    scroll_region, inside := Get_Rect.begin_scrollable_region(room_files_rect, *my_theme.scrollable_region_theme);
    s := inside;
    s.y = s.y + s.h - button_extents.y;
    s.h = button_extents.y;
    s.y += editor_state.load_window_scroll_value;

    room_files := room_list();

    for room_files {
        _, _, _, filename := path_decomp(it);
        pressed := Get_Rect.button(s, filename, identifier = it_index);
        if pressed {
            read_room_from_file(*current_room, tprint("assets/rooms/%", filename));
        }
        s.y -= 60;
    }
    Get_Rect.end_scrollable_region(scroll_region, s.x + s.w, s.y, *editor_state.load_window_scroll_value);
}
