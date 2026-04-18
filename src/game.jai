main :: () {
    init_window();
    #if DEV_MODE {
        editor_init();
    }
    init_textures();
    make_entity(.{100, 100});
    while !window.close {
        now := seconds_since_init();
        delta: float64 = now - last_time;
        current_dt = cast(float)delta;

        if current_dt > DT_MAX current_dt = DT_MAX;

        last_time = now;
        simulate(current_dt);
        // timestep(#code simulate(tickrate()));
        render();
    }
}

current_dt: float = 0.016667;
last_time: float64;
DT_MAX: float: 0.15;
Simp :: #import "Simp";
Input :: #import "Input";
Texture :: Simp.Texture;

#import "Basic";
#import "Math";
#import "File";
#import "Random";
#import "Input";
#import "Window_Creation";
// #import "Time"(TICK_RATE = 1.0 / 60.0);

#load "window.jai";
#load "render.jai";
#load "camera.jai";
#load "entities.jai";
#load "simulate.jai";
#load "input.jai";
#load "player.jai";
#load "preload_test.jai";

#if DEV_MODE {
    #load "editor/editor.jai";
}
