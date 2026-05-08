EXECUTABLE_BASE_NAME := "negative-zero";
#run {
    set_build_options_dc(.{do_output = false});
    #import "Compiler";
    #import "Basic";
    #import "String";
    #import "Math";
    Autorun :: #import "Autorun";
    // Parse args
    args := get_build_options().compile_time_command_line;
    dev := array_find(args, "-dev");
    run := array_find(args, "-run");
    // Create Workspace
    w := compiler_create_workspace("Target workspace");
    // Set build options (just output name for now)
    options := get_build_options(w);
    copy_commonly_propagated_fields(get_build_options(), *options);
    executable_name: string;
    if dev {
        executable_name = tprint("%-dev", EXECUTABLE_BASE_NAME);
    } else {
        executable_name = EXECUTABLE_BASE_NAME;
    }

    options.output_executable_name = executable_name;
    set_build_options(options, w);

    // Start compiler intercept loop
    compiler_begin_intercept(w);
    add_build_file("src/game.jai", w);
    add_build_string(tprint("DEV_MODE :: %;", dev), w);

    character_data_fields: [..]Editor_Codegen_Field;
    collision_data_fields: [..]Editor_Codegen_Field;

    finished_type_checking_pre_codegen: bool;

    while true {
        message := compiler_wait_for_message();
        if message.kind == {
        case .TYPECHECKED;
            typechecked := cast(*Message_Typechecked)message;

            for s: typechecked.structs {
                struct_name := s.expression.defined_type.name;
                for note: s.expression.notes {
                    if equal(note.text, "thing_data") {
                        is_char_data := equal(struct_name, "Character_Data");
                        is_col_data := equal(struct_name, "Collision_Data");
                        print("%\n", struct_name);
                        for member: s.expression.defined_type.members {
                            member_type: Type = (cast(*Type)(*member.type)).*;
                            field := Editor_Codegen_Field.{member_name = member.name, member_type = member_type};

                            for field_note: member.notes {
                                if equal(field_note, "editor_display") {
                                    if is_char_data {
                                        array_add(*character_data_fields, field);
                                        print("Added % to character_fields\n", field);
                                    } else
                                    if is_col_data {
                                        array_add(*collision_data_fields, field);
                                        print("Added % to collision_fields\n", field);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        case .FILE;
            file := cast(*Message_File)message;
            /* If we have already gained our type information for editor displayable structs, add editor.jai to the build
							and insert our generated procedures for editor fields */
            if ends_with(file.fully_pathed_filename, "editor.jai") && dev && finished_type_checking_pre_codegen {
                placeholder_build_string := editor_codegen(character_data_fields, collision_data_fields);
                // add_build_string(placeholder_build_string, w, file);
                // print("Generated Code to Insert\n%\n", placeholder_build_string);
            }
        case .PHASE;
            phase := cast(*Message_Phase)message;
            // If we have finished typechecking for the first time, insert our dev files
            if phase.phase == .TYPECHECKED_ALL_WE_CAN && !finished_type_checking_pre_codegen {
                if dev {
                    // Run editor codegen
                    add_build_file("src/dev/editor.jai", w);
                }
                finished_type_checking_pre_codegen = true;
            }
        case .COMPLETE;
            mc := cast(*Message_Complete)message;
            if mc.error_code != .NONE {
                exit(1);
            }
            break;
        }
    }
    compiler_end_intercept(w);
    print("\n");
    if run Autorun.run_build_result_of_workspace(w);
}

// Editor Codegen
Editor_Codegen_Field :: struct {
    member_name: string;
    member_type: Type;
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
	`y_pos += `label_extents.y + 5;
	%1_x_rect := Get_Rect.get_rect(`text_left_margin, `y_pos, `text_extents.x, `text_extents.y);
	%1_y_rect := Get_Rect.get_rect(`text_left_margin + `text_extents.x + 5, `y_pos, `text_extents.x, `text_extents.y);
	`y_pos += `text_extents.y + 5;


  Get_Rect.label(%1_label_rect, "%1", *my_theme.label_theme);

	{
		x_str := float_str(`entity.%1.x);
		action_x, new_text_x, state_x := Get_Rect.text_input(r1, x_str, *my_theme.text_input_theme);
		if action_x & .ENTERED {
				if modify_float_from_string(*`entity.%1.x, new_text_x) {
						new_x_str := tprint("%", formatFloat(`entity.%1.x, 2, 0, zero_removal = .NO));
				}
		}
		if !state_x.active {
				Get_Rect.reset(state_x);
		}
	}

	}


  {
		y_str := float_str(`entity.%1.y);
		action_y, new_text_y, state_y := Get_Rect.text_input(r2, y_str, *my_theme.text_input_theme);
		if action_y & .ENTERED {
				if modify_float_from_string(*`entity.%1.y, new_text_y) {
						new_y_str := tprint("%", formatFloat(`entity.%1.y, 2, 0, zero_removal = .NO));
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
        if field.member_type == {
        case Vector2;
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
    print(final_string);
    return final_string;
}
