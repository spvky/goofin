MAX_THINGS_PER_ROOM :: 128;

Thing_Room_Manager :: struct {
    things: [MAX_THINGS_PER_ROOM]Thing;
    used: [MAX_THINGS_PER_ROOM]bool;
    next_free: int = 0;
}

for_expansion :: (tm: *Thing_Room_Manager, body: Code, flags: For_Flags) #expand {
    for ok, i: tm.used {
        if !ok continue;
        `it_index := i;
        `it := *tm.things[i];
        #insert body;
    }
}

add_thing :: (tm: *Thing_Room_Manager, thing: Thing) {
    for i: 0..tm.next_free - 1 {
        if !tm.used[i] {
            tm.used[i] = true;
            tm.things[i] = thing;
            return;
        }
    }
    tm.used[tm.next_free] = true;
    tm.things[tm.next_free] = thing;
    tm.next_free += 1;
}

clear_thing_at_index :: (tm: *Thing_Room_Manager, i: int) {
    tm.things[i] = .{};
    tm.used[i] = false;
}

get_thing_ptr :: (tm: *Thing_Room_Manager, i: int) -> *Thing {
    return *tm.things[i];
}
