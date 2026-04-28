current_theme: s32 = xx Get_Rect.Default_Themes.Default;
my_theme: Get_Rect.Overall_Theme; // This gets filled out by calling the Theme_Proc for current_theme.
inspector_window: Get_Rect.Subwindow_Info;

some_string: string;

pos_string_x: string;
pos_string_y: string;

pos_string_2_x: string;
pos_string_2_y: string;

render_editor_ui :: () {
    Simp.set_shader_for_color();

    if editor_selection.mode == {
    case .Entity;
        my_theme.subwindow_theme.title_bar.surface_color = .{1, 0, 0, 1};
    case .Collider;
        my_theme.subwindow_theme.title_bar.surface_color = .{0, 0, 1, 1};
    }

    current_time := to_float64_seconds(current_time_monotonic());
    w, h := Simp.get_render_dimensions(n_window.resource);

    Get_Rect.ui_per_frame_update(n_window.resource, w, h, current_time);

    Get_Rect.add_subwindow(*inspector_subwindow, *my_theme.subwindow_theme);

    Get_Rect.draw_popups();
}

mouse_pos :: () -> Vector2 {
    mouse_x, mouse_y, ok := get_mouse_pointer_position();
    mouse_y = xx n_window.height - mouse_y;
    if ok {
        return .{xx mouse_x, xx mouse_y};
    } else {
        return .{-100, -100};
    }
}

mouse_position_to_world :: () -> Vector2 {
    pos := mouse_pos();
    return pos + camera.target;
}

draw_inspector :: (state: *Get_Rect.Subwindow_State, r: Get_Rect.Rect, data: *void) {
    x := r.x + 20;
    y := r.y + r.h - 60;

    y -= 45;

    if editor_selection.mode == {
    case .Entity;
        inspector_subwindow.title_text = "Inspector | Entities";
        text_extents := Vector2.{150, 35};

        r1 := Get_Rect.get_rect(x, y, text_extents.x, text_extents.y);
        // y -= 45;
        r2 := Get_Rect.get_rect(x + 155, y, text_extents.x, text_extents.y);

        ent_idx := editor_selection.selected_entity_idx;

        action_a, new_text_a := Get_Rect.text_input(r1, pos_string_x, *my_theme.text_input_theme);
        if action_a & .ENTERED modify_float_string(*pos_string_x, new_text_a, *entities[ent_idx].position.x);
        action_b, new_text_b := Get_Rect.text_input(r2, pos_string_y, *my_theme.text_input_theme);
        if action_b & .ENTERED modify_float_string(*pos_string_y, new_text_b, *entities[ent_idx].position.y);
    case .Collider;
        inspector_subwindow.title_text = "Inspector | Collision";
    }

    mouse_pos := mouse_position_to_world();
    pos_label := Get_Rect.get_rect(r.x - 10, r.y - 20, 400, 80);
    mouse_x, mouse_y := float_fmt(mouse_pos.x), float_fmt(mouse_pos.y);
    Get_Rect.label(pos_label, tprint("{%, %}", mouse_x, mouse_y), *my_theme.label_theme);
}

modify_float_string :: (ps: *string, new_value: string, value_ptr: *float32) {
    new_float, ok := parse_float(*new_value);
    assert(ok, "Invalid float parsed when modifying a float string");
    new_string := tprint("%", float_fmt(new_float));
    print("New String: %\n", new_string);
    free(ps.*);
    ps.* = copy_string(new_string);
    print("PString: %\n", ps.*);
    value_ptr.* = new_float;
}
