// Editor Codegen
Editor_Codegen_Field :: struct {
    member_name: string;
    member_type_name: string;
}

PLACEHOLDER_INSERTION_STRING :: #string END
draw_character_data_fields :: () #expand {
	%1
}

draw_collision_data_fields :: () #expand {
	%2
}
END

VECTOR2_INPUT_STRING :: #string END
	%1_label_rect := Get_Rect.get_rect(`label_left_margin, `y_pos, `label_extents.x, `label_extents.y);
	// shift y_pos when we finish defining rects for a row
	`y_pos -= (`label_extents.y + 5);
	%1_x_rect := Get_Rect.get_rect(`text_left_margin, `y_pos, `text_extents.x, `text_extents.y);
	%1_y_rect := Get_Rect.get_rect(`text_left_margin + `text_extents.x + 5, `y_pos, `text_extents.x, `text_extents.y);
	`y_pos -= (`text_extents.y + 10);


  Get_Rect.label(%1_label_rect, "%1", *my_theme.label_theme);

	{
		x_str := float_str(`entity.%1.x);
		action_x, new_text_x, state_x := Get_Rect.text_input(%1_x_rect, x_str, *my_theme.text_input_theme);
		if action_x & .ENTERED {
				// if modify_float_from_string(*`entity.%1.x, new_text_x) {
				// 		new_x_str := float_str(`entity.%1.x);
				// }
		}
		if !state_x.active {
				Get_Rect.reset(state_x);
		}
	}

  {
		y_str := float_str(`entity.%1.y);
		action_y, new_text_y, state_y := Get_Rect.text_input(%1_y_rect, y_str, *my_theme.text_input_theme);
		if action_y & .ENTERED {
				if modify_float_from_string(*`entity.%1.y, new_text_y) {
						new_y_str := float_str(`entity.%1.y);
				}
		}
		if !state_y.active {
				Get_Rect.reset(state_y);
		}
  }
END

editor_codegen :: (char_fields: []Editor_Codegen_Field, col_fields: []Editor_Codegen_Field) -> string {
    // Build character data proc
    char_data_builder: String_Builder;

    print_to_builder(*char_data_builder, VECTOR2_INPUT_STRING, "position");

    for field: char_fields {
        if equal(field.member_type_name, "Vector2") {
            print_to_builder(*char_data_builder, VECTOR2_INPUT_STRING, field.member_name);
        }
    }

    char_data_string := builder_to_string(*char_data_builder);
    // //////////////////////////

    // Build collision data proc
    col_data_builder: String_Builder;
    print_to_builder(*col_data_builder, VECTOR2_INPUT_STRING, "position");
    for field: col_fields {
    }

    col_data_string := builder_to_string(*col_data_builder);
    // //////////////////////////

    final_string := tprint(PLACEHOLDER_INSERTION_STRING, char_data_string, col_data_string);
    return final_string;
}
