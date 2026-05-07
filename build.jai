EXECUTABLE_BASE_NAME := "negative-zero";
#run {
    set_build_options_dc(.{do_output = false});
    #import "Compiler";
    #import "Basic";
    #import "String";
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

            // End struct parsing
        case .PHASE;
            phase := cast(*Message_Phase)message;
            if phase.phase == .TYPECHECKED_ALL_WE_CAN {
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

EDITOR_DISPLAY_INSERTION_STRING :: #string END
	inspector_display_%1_data :: () {
	}
END

editor_codegen :: (thing_type: string, fields: []Editor_Codegen_Field) {
}
