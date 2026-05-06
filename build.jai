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
    while true {
        message := compiler_wait_for_message();
        if message.kind == {
        case .TYPECHECKED;
            typechecked := cast(*Message_Typechecked)message;
            for decl: typechecked.declarations {
                // struct_info := checked.expression.defined_type;
                // notes := checked.expression.notes;
                // is_thing_data: bool;
                // print("% notes for %\n", notes.count, struct_info.name);
                // // Look in how to for how to check typchecking at the end after notes have been read
                // for n: notes {
                //     print("Note %\n", n);
                //     // if n == "thing_data" {
                //     //     is_thing_data = true;
                //     // }
                // }
                // if is_thing_data {
                //     print("% checked\n", struct_info.name);
                // }
            }

            for s: typechecked.structs {
                for note: s.expression.notes {
                    if equal(note.text, "thing_data") {
                        print("%\n", s.expression.defined_type.name);
                        for member: s.expression.defined_type.members {
                            member_type: Type = (cast(*Type)(*member.type)).*;
                            print("%: %\nNotes: %\n\n", member.name, member_type, member.notes);
                        }
                    }
                }
            }
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

has_note :: (header: *Code_Procedure_Header, note: string) -> bool {
    for header.notes if it.text == note return true;
    return false;
}
