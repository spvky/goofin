process_input :: () {
    for event: events_this_frame {
        if event.type == .QUIT {
            n_window.close = true;
            break;
        }


        #if DEV_MODE {
            Get_Rect.getrect_handle_event(event);
        }

        // keyboard events
        if !getrect_captured_keyboard {
            if event.key_code == {
            case .ESCAPE;
                if event.key_pressed {
                    n_window.close = true;
                }
            case .ARROW_UP;
                if event.key_pressed {
                    held_actions |= .CAM_UP;
                } else {
                    held_actions &= ~.CAM_UP;
                }
            case .ARROW_DOWN;
                if event.key_pressed {
                    held_actions |= .CAM_DOWN;
                } else {
                    held_actions &= ~.CAM_DOWN;
                }
            case .ARROW_LEFT;
                if event.key_pressed {
                    held_actions |= .CAM_LEFT;
                } else {
                    held_actions &= ~.CAM_LEFT;
                }
            case .ARROW_RIGHT;
                if event.key_pressed {
                    held_actions |= .CAM_RIGHT;
                } else {
                    held_actions &= ~.CAM_RIGHT;
                }
            case;
            }
        }

        // mouse events
        if !getrect_captured_mouse {
            if event.key_code == {
            case .MOUSE_BUTTON_LEFT;
                if event.key_pressed {
                    held_actions |= .EDITOR_SELECT;
                } else {
                    held_actions &= ~.EDITOR_SELECT;
                }
            case;
            }
        }
    }
}

Input_Action :: enum_flags u32 {
    CAM_UP;
    CAM_DOWN;
    CAM_LEFT;
    CAM_RIGHT;
    MOVE_RIGHT;
    MOVE_LEFT;
    MOVE_UP;
    MOVE_DOWN;
    JUMP;
    EDITOR_SELECT;
}

held_actions: Input_Action;

is_action_pressed :: (action: Input_Action) -> bool {
    return (held_actions & action) == action;
}
