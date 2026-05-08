Editor_Selection :: struct {
    selected_collider_idx: u32;
    selected_entity_idx: u32;
    entity_data: Editor_Entity_Data;
    locked: bool;
    #overlay (entity_data) collider_data: Editor_Entity_Data;
}

Editor_Entity_Data :: struct {
    held_entity := false;
    held_entity_idx: u32;
}

editor_selection: Editor_Selection;
inspector_subwindow := Get_Rect.Subwindow_Info.{
                                                rect = #run Get_Rect.get_rect(cast(float32)n_window.width - 610, cast(float32)n_window.height - 810, 600, 800),
                                                draw = draw_inspector,
                                                title_text = "Inspector"};

editor_init :: () {
    load_editor_assets();
    Get_Rect.ui_init();

    proc := Get_Rect.default_theme_procs[current_theme];
    my_theme = proc();
    Get_Rect.set_default_theme(my_theme);

    input_theme := *my_theme.text_input_theme;
    input_theme.font = editor_assets.font;
    input_theme.alignment = .Left;
    input_theme.alignment_pad_ems = 0.3;
    input_theme.text_baseline_vertical_position = 0.1;

    label_theme := *my_theme.label_theme;
    label_theme.font = editor_assets.font;
    label_theme.alignment = .Left;

    button_theme := *my_theme.button_theme;
    button_theme.font = editor_assets.font;

    checkbox_theme := *my_theme.checkbox_theme;
    checkbox_theme.font = editor_assets.font;
}

float_fmt :: (v: float32) -> FormatFloat #expand {
    return formatFloat(v, 2, 1, zero_removal = .NO);
}

render_editor_grid :: () {
    for i: 0..20 {
        fi := cast(float32)i;
        h_start := Vector2.{0, fi * 100};
        h_end := Vector2.{1920, fi * 100};
        v_start := Vector2.{fi * 100, 0};
        v_end := Vector2.{fi * 100, 1080};

        h_start = cam_relative_position(h_start);
        h_end = cam_relative_position(h_end);
        v_start = cam_relative_position(v_start);
        v_end = cam_relative_position(v_end);
        render_line(h_start, h_end);
        render_line(v_start, v_end);
    }
}

current_theme: s32 = xx Get_Rect.Default_Themes.Default;
my_theme: Get_Rect.Overall_Theme; // This gets filled out by calling the Theme_Proc for current_theme.
inspector_window: Get_Rect.Subwindow_Info;

render_editor_ui :: () {
    Simp.set_shader_for_color();

    my_theme.subwindow_theme.title_bar.surface_color = .{1, 0, 0, 1};

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

/* 
	These macros will be written at compile time to enable automatically display
	struct members in the inpsector window If they are noted with @editor_display
*/
#placeholder draw_character_data_fields;
#placeholder draw_collision_data_fields;

draw_inspector :: (state: *Get_Rect.Subwindow_State, r: Get_Rect.Rect, data: *void) {
    locked_rect := Get_Rect.get_rect(r.x + r.w - 200, r.y + r.h - 60, 200, 50);
    pressed := Get_Rect.base_checkbox(locked_rect, "Locked", editor_selection.locked, *my_theme.checkbox_theme);
    editor_selection.locked ^= pressed;

    ent_idx := editor_selection.selected_entity_idx;
    entity := get_thing_ptr(*debug_room_things, ent_idx);

    label_left_margin := r.x - 5;
    text_left_margin := r.x + 30;
    y_pos := r.y + r.h - 60;

    label_extents := Vector2.{600, 35};
    text_extents := Vector2.{150, 35};

    draw_character_data_fields();

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

// Formats a float and returns the resultant string, using the temporary allocator
float_str :: (f: float32) -> string {
    return tprint("%", formatFloat(f, 2, 0, zero_removal = .NO));
}

Editor_Assets :: struct {
    font: *Simp.Dynamic_Font;
}

editor_assets: Editor_Assets;

load_editor_assets :: () {
    editor_assets.font = Simp.get_font_at_size("assets/fonts", "dungeon-mode.ttf", 24);
    assert(editor_assets.font != null);
}

#import "String";
