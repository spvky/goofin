tri: Collision_Shape;
poly: Collision_Shape;
aabb: Collision_Shape;

getrect_captured_mouse: bool;
getrect_captured_keyboard: bool;

main :: () {
    init_window();
    init_textures();
    read_room_from_file(*current_room, "assets/rooms/Second.room");
    for room_list() {
        _, _, _, filename := path_decomp(it);
        print("%\n", filename);
    }
    // current_room.name = copy_string("First");
    // bug1 := make_character(.{100, 100});
    // bug2 := make_character(.{300, 250}, .{10, 0});
    // bug3 := make_character(.{600, 250});
    // add_thing(*current_room.things, bug1);
    // add_thing(*current_room.things, bug2);
    // add_thing(*current_room.things, bug3);
    #if DEV_MODE {
        editor_init();
    }
    print("Thing Size: %\n", size_of(Thing));
    while !n_window.close {
        update_window_events();
        now := seconds_since_init();
        delta: float64 = now - last_time;
        current_dt = cast(float)delta;

        if current_dt > DT_MAX current_dt = DT_MAX;

        last_time = now;
        simulate(current_dt);
        // timestep(#code simulate(tickrate()));
        render();
        reset_temporary_storage();
    }
}

current_dt: float = 0.016667;
last_time: float64;
DT_MAX: float: 0.15;
Simp :: #import "Simp";
Input :: #import "Input";
Texture :: Simp.Texture;
Get_Rect :: #import "GetRect";
File_Util :: #import "File_Utilities";

#import "Basic";
#import "Math";
#import "File";
#import "Random";
#import "Input";
#import "String";
#import "Window_Creation";
// #import "Time"(TICK_RATE = 1.0 / 60.0);

#load "window.jai";
#load "render.jai";
#load "camera.jai";
#load "thing/core.jai";
#load "room/core.jai";
#load "simulate.jai";
#load "input.jai";
#load "player.jai";
#load "preload_test.jai";
