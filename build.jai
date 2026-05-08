EXECUTABLE_BASE_NAME := "negative-zero";
#run {
    set_build_options_dc(.{do_output = false});
    #import "Compiler";
    #import "Basic";
    #import "String";
    #import "Math";
    #load "codegen.jai";
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
    add_build_string(tprint("editor_mode := %;", dev), w);

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
                            field := Editor_Codegen_Field.{member_name = member.name, member_type_name = tprint("%", member_type)};

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
                print(placeholder_build_string);
                add_build_string(placeholder_build_string, w, file);
            }
        case .PHASE;
            phase := cast(*Message_Phase)message;
            // If we have finished typechecking for the first time, insert our dev files
            if phase.phase == .TYPECHECKED_ALL_WE_CAN && !finished_type_checking_pre_codegen {
                if dev {
                    // add editor source file
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
