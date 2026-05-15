// File to contain operations related to saving/loading rooms

// Save room in the rooms folder, with it's name serving as the filename
save_room_to_file :: (room: *Room) {
    path := tprint("assets/rooms/%.room", room.name);
    file, ok := file_open(path, true);
    assert(ok, "Failed to open % for writing!\n", path);
    defer file_close(*file);

    things_size := size_of(Thing_Room_Manager);

    written := file_write(*file, *room.things, things_size);
    assert(written, "Failed to write to %!\n", path);
}

// Read room from file
read_room_from_file :: (room: *Room, path: string) {
    file, ok := file_open(path);
    assert(ok, "Failed to open % for reading!\n", path);
    defer file_close(*file);

    dir, name, extension := path_decomp(path);
    room.name = copy_string(name);
    file_read(file, *room.things, size_of(Thing_Room_Manager));
    link_room_textures(room);
}

make_new_room :: () {
    current_room = Room.{};
}

link_room_textures :: (room: *Room) {
    for thing: room.things {
        if thing.kind == .CHARACTER {
            thing.map = *bug_tex;
        }
    }
}

room_list :: () -> []string {
    return File_Util.file_list("assets/rooms",, temp);
}
