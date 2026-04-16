main :: () {
    init_window();
    init_textures();
    make_entity(.{100, 100});
    while !window.close {
        now := seconds_since_init();
        delta := now - time.last_time;
        time.current_delta = cast(float)delta;
        time.last_time = now;
        if time.current_delta > time.max_delta {
            time.current_delta = time.max_delta;
            print("Big timestep encountered, clamping to %\n", time.max_delta);
        }
        simulate(time.current_delta);
        render();
    }
}

time: Time;

Simp :: #import "Simp";
Input :: #import "Input";
Texture :: Simp.Texture;

#import "Basic";
#import "Math";
#import "File";
#import "Random";
#import "Window_Creation";

#load "window.jai";
#load "render.jai";
#load "entities.jai";
#load "simulate.jai";
#load "preload_test.jai";

Time :: struct {
    tick_rate: float = 1.0 / 100.0;
    last_time: float64;
    current_delta: float32 = 0.016667;
    max_delta: float32 = 0.15;
}

timestep_loop :: (body: Code) {
    // t1 := f32(rl.GetTime())
    // 		elapsed := math.min(t1 - time.t, 0.25)
    // 
    // 		time.t = t1
    // 		time.simulation_time += elapsed
    // 		for time.simulation_time >= TICK_RATE {
    // 			// Physics stuff
    #insert body;
    // 			time.simulation_time -= TICK_RATE
    // 		}
}
