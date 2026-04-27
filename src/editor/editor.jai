inspector_subwindow := Get_Rect.Subwindow_Info.{
                                                rect = #run Get_Rect.get_rect(600, 200, 400, 600),
                                                draw = draw_inspector,
                                                title_text = "Inspector"};

Editor_Selection :: struct {
    mode: Editor_Selection_Mode;
    selected_collider_idx: u32;
    selected_entity_idx: u32;
}

Editor_Selection_Mode :: enum {
    Entity :: 0;
    Collider :: 1;
}

editor_selection: Editor_Selection;

editor_init :: () {
    load_editor_assets();
    Get_Rect.ui_init();
    some_string = copy_string("Cool guy");
    a := formatFloat(entities[0].position.x, 2, 2, zero_removal = .NO);
    pos_string_x = sprint("%", float_fmt(entities[0].position.x));
    pos_string_y = sprint("%", float_fmt(entities[0].position.y));
    pos_string_2_x = sprint("%", entities[1].position.x);
    pos_string_2_y = sprint("%", entities[1].position.y);

    proc := Get_Rect.default_theme_procs[current_theme];
    my_theme = proc();
    Get_Rect.set_default_theme(my_theme);
    my_theme.text_input_theme.font = editor_assets.font;
    my_theme.label_theme.font = editor_assets.font;
    my_theme.label_theme.alignment = .Left;
    my_theme.button_theme.font = editor_assets.font;
}

update_editor_selection :: () {
}

float_fmt :: (v: float32) -> FormatFloat #expand {
    return formatFloat(v, 2, 2, zero_removal = .NO);
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
