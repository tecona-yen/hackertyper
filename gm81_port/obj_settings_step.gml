// obj_settings - Step Event (GameMaker 8.1)
var menu_choice, new_col, new_spd, new_sz, font_choice, need_font_update, action_trigger;

need_font_update = false;
action_trigger = -1;

// 1. Process mouse click on footer buttons
if (clicked_button != -1)
{
    action_trigger = clicked_button;
    clicked_button = -1;
}

// 2. Process keyboard shortcuts
if (keyboard_check_pressed(vk_f2) || (keyboard_check(vk_control) && keyboard_check_pressed(ord('O'))))
{
    action_trigger = 0; // Open File
}
else if (keyboard_check_pressed(vk_f3))
{
    action_trigger = 1; // Toggle AutoType
}
else if (keyboard_check_pressed(vk_f4) || (keyboard_check(vk_control) && keyboard_check_pressed(ord('S'))))
{
    action_trigger = 2; // Settings Menu
}
else if (keyboard_check_pressed(vk_f5))
{
    action_trigger = 3; // Color Cycle
}
else if (keyboard_check_pressed(vk_add) || keyboard_check_pressed(187))
{
    if (global.type_speed < 20) global.type_speed += 1;
}
else if (keyboard_check_pressed(vk_subtract) || keyboard_check_pressed(189))
{
    if (global.type_speed > 1) global.type_speed -= 1;
}
else if (keyboard_check_pressed(vk_f11) || (keyboard_check(vk_alt) && keyboard_check_pressed(vk_enter)))
{
    window_set_fullscreen(!window_get_fullscreen());
}

// 3. Execute actions
if (action_trigger == 0) // Open File
{
    global.request_open_file = true;
    io_clear();
}
else if (action_trigger == 1) // Toggle AutoType
{
    global.autotype_active = !global.autotype_active;
    io_clear();
}
else if (action_trigger == 2) // Settings Menu
{
    io_clear();
    menu_choice = show_menu('1. Change Text Color|2. Change Background Color|3. Cycle Color Presets (Green/Amber/Cyan/Red/Purple/White)|4. Set Typing Speed|5. Choose Font Family|6. Set Font Size|7. Toggle AutoType Mode|8. Reset to Defaults', -1);

    if (menu_choice == 0) // Custom Text Color
    {
        new_col = get_color(global.text_color);
        if (new_col != -1) global.text_color = new_col;
    }
    else if (menu_choice == 1) // Custom Background Color
    {
        new_col = get_color(global.bg_color);
        if (new_col != -1)
        {
            global.bg_color = new_col;
            background_color = new_col;
            background_showcolor = true;
        }
    }
    else if (menu_choice == 2) // Cycle Presets
    {
        current_preset = (current_preset + 1) mod preset_count;
        global.text_color = preset_colors[current_preset];
    }
    else if (menu_choice == 3) // Typing Speed
    {
        new_spd = get_integer('Enter typing speed (1 - 20 chars per keystroke):', global.type_speed);
        if (new_spd >= 1 && new_spd <= 20)
        {
            global.type_speed = new_spd;
        }
    }
    else if (menu_choice == 4) // Font Family
    {
        font_choice = show_menu('Courier New|Consolas|Lucida Console|Fixedsys|System', -1);
        if (font_choice == 0) { font_name = 'Courier New'; need_font_update = true; }
        else if (font_choice == 1) { font_name = 'Consolas'; need_font_update = true; }
        else if (font_choice == 2) { font_name = 'Lucida Console'; need_font_update = true; }
        else if (font_choice == 3) { font_name = 'Fixedsys'; need_font_update = true; }
        else if (font_choice == 4) { font_name = 'System'; need_font_update = true; }
    }
    else if (menu_choice == 5) // Font Size
    {
        new_sz = get_integer('Enter font size in points (8 - 32):', font_size);
        if (new_sz >= 8 && new_sz <= 32)
        {
            font_size = new_sz;
            need_font_update = true;
        }
    }
    else if (menu_choice == 6) // Toggle AutoType
    {
        global.autotype_active = !global.autotype_active;
    }
    else if (menu_choice == 7) // Reset to Defaults
    {
        global.type_speed = 3;
        global.autotype_active = false;
        global.text_color = make_color_rgb(0, 255, 0);
        global.bg_color = c_black;
        background_color = c_black;
        font_name = 'Courier New';
        font_size = 12;
        current_preset = 0;
        need_font_update = true;
    }
    io_clear();
}
else if (action_trigger == 3) // Direct Cycle Colors
{
    current_preset = (current_preset + 1) mod preset_count;
    global.text_color = preset_colors[current_preset];
    io_clear();
}
else if (action_trigger == 4) // Speed dialog
{
    io_clear();
    new_spd = get_integer('Enter typing speed (1 - 20 chars per keystroke):', global.type_speed);
    if (new_spd >= 1 && new_spd <= 20)
    {
        global.type_speed = new_spd;
    }
    io_clear();
}
else if (action_trigger == 5) // Font dialog
{
    io_clear();
    font_choice = show_menu('Courier New|Consolas|Lucida Console|Fixedsys|System', -1);
    if (font_choice == 0) { font_name = 'Courier New'; need_font_update = true; }
    else if (font_choice == 1) { font_name = 'Consolas'; need_font_update = true; }
    else if (font_choice == 2) { font_name = 'Lucida Console'; need_font_update = true; }
    else if (font_choice == 3) { font_name = 'Fixedsys'; need_font_update = true; }
    else if (font_choice == 4) { font_name = 'System'; need_font_update = true; }
    io_clear();
}
else if (action_trigger == 6) // Clear screen
{
    with (obj_typer)
    {
        typed_text = '';
        display_text = '';
        text_index = 1;
        scroll_y = 0;
        user_scrolled = false;
    }
    io_clear();
}
else if (action_trigger == 7) // Fullscreen toggle
{
    window_set_fullscreen(!window_get_fullscreen());
    io_clear();
}
else if (action_trigger == 8) // Not used
{
    show_info();
    io_clear();
}
else if (action_trigger == 9) // Help
{
    show_info();
    io_clear();
}



// Recreate font resource if font family or size changed
if (need_font_update)
{
    if (global.current_font != -1 && font_exists(global.current_font))
    {
        font_delete(global.current_font);
    }
    global.current_font = font_add(font_name, font_size, false, false, 32, 128);
}