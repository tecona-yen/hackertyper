// obj_settings - Create Event (GameMaker 8.1)
font_name = 'Courier New';
font_size = 12;

// Create the initial crisp monospaced font
global.current_font = font_add(font_name, font_size, false, false, 32, 128);

// Preset Hacker Colors (matching HackerTyper.net web color options)
preset_names[0] = 'Hacker Green';
preset_colors[0] = make_color_rgb(0, 255, 0);

preset_names[1] = 'Cyber Amber';
preset_colors[1] = make_color_rgb(255, 170, 0);

preset_names[2] = 'Matrix Cyan';
preset_colors[2] = make_color_rgb(0, 240, 255);

preset_names[3] = 'Alert Red';
preset_colors[3] = make_color_rgb(255, 50, 50);

preset_names[4] = 'Neon Purple';
preset_colors[4] = make_color_rgb(175, 40, 255);

preset_names[5] = 'Terminal White';
preset_colors[5] = c_white;

preset_count = 6;
current_preset = 0;

// Apply room background color
background_color = global.bg_color;
background_showcolor = true;

// Configure hacker terminal theme for all built-in dialogs (from GML manual p. 40-41)
message_caption(1, 'HackerTyper Terminal');
message_position(-1, -1); // Centered on screen
message_size(480, -1);    // 480px width, automatic height
message_text_font('Courier New', 11, make_color_rgb(0, 255, 0), 1); // Green bold
message_input_font('Courier New', 11, make_color_rgb(0, 255, 0), 0);
message_button_font('Courier New', 10, c_black, 1);
message_input_color(make_color_rgb(10, 24, 10)); // Deep dark green input box
message_mouse_color(make_color_rgb(0, 255, 0));  // Green hover on dialog buttons

// Clickable footer button state
clicked_button = -1;
footer_h = 34; // Height of bottom toolbar in pixels