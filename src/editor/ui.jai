current_theme: s32 = xx Get_Rect.Default_Themes.Default;
my_theme: Get_Rect.Overall_Theme; // This gets filled out by calling the Theme_Proc for current_theme.
inspector_window: Get_Rect.Subwindow_Info;

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

    getrect_captured_mouse, getrect_captured_keyboard = Get_Rect.ui_per_frame_update(n_window.resource, w, h, current_time);

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
        data := *editor_selection.entity_data;
        inspector_subwindow.title_text = "Inspector | Entities";
        text_extents := Vector2.{150, 35};

        r1 := Get_Rect.get_rect(x, y, text_extents.x, text_extents.y);
        // y -= 45;
        r2 := Get_Rect.get_rect(x + 155, y, text_extents.x, text_extents.y);

        ent_idx := editor_selection.selected_entity_idx;
        entity := *entities[ent_idx];

        // a scope to prevent copy/paste errors
        {
            x_str := tprint("%", formatFloat(entity.position.x, 2, 2, zero_removal = .NO));
            action_x, new_text_x, state_x := Get_Rect.text_input(r1, x_str, *my_theme.text_input_theme);
            if action_x & .ENTERED {
                if modify_float_from_string(*entity.position.x, new_text_x) {
                    new_x_str := tprint("%", formatFloat(entity.position.x, 2, 2, zero_removal = .NO));
                }
            }
            if !state_x.active {
                Get_Rect.reset(state_x);
            }
        }

        // a scope to prevent copy/paste errors (e.g. using "x_str" by accident)
        {
            y_str := tprint("%", formatFloat(entity.position.y, 2, 2, zero_removal = .NO));
            action_y, new_text_y, state_y := Get_Rect.text_input(r2, y_str, *my_theme.text_input_theme);
            if action_y & .ENTERED {
                if modify_float_from_string(*entity.position.y, new_text_y) {
                    new_y_str := tprint("%", formatFloat(entity.position.y, 2, 2, zero_removal = .NO));
                }
            }
            if !state_y.active {
                Get_Rect.reset(state_y);
            }
        }
    case .Collider;
        inspector_subwindow.title_text = "Inspector | Collision";
    }

    mouse_pos := mouse_position_to_world();
    pos_label := Get_Rect.get_rect(r.x - 10, r.y - 20, 400, 80);
    mouse_x, mouse_y := float_fmt(mouse_pos.x), float_fmt(mouse_pos.y);
    Get_Rect.label(pos_label, tprint("{%, %}", mouse_x, mouse_y), *my_theme.label_theme);
}

modify_float_from_string :: (value_ptr: *float32, float_str: string) -> success: bool {
    new_value, ok := parse_float(*float_str);
    if ok {
        value_ptr.* = new_value;
    } else {
        assert(false, "Unable to parse float from string '%'", float_str);
    }
    return ok;
}
