// obj_settings - Draw Event (GameMaker 8.1)
// Consolidated, compact, web-style bottom footer with clickable and hover-underlined buttons
var bar_y, bar_h, btn_count, btn_label, i, btn_x, btn_y, btn_w, btn_h;
var is_hover, any_hover, txt_col;

bar_h = 32;
bar_y = room_height - bar_h;
btn_y = bar_y + 8;

// 1. Draw sleek dark footer background bar and top border line
draw_set_color(make_color_rgb(6, 14, 6));
draw_rectangle(0, bar_y, room_width, room_height, false);

draw_set_color(make_color_rgb(0, 65, 0));
draw_line(0, bar_y, room_width, bar_y);

// 2. Define clickable footer buttons
btn_count = 7;
btn_label[0] = 'Open File';

if (global.autotype_active)
{
    btn_label[1] = 'AutoType: ON';
}
else
{
    btn_label[1] = 'AutoType: OFF';
}

btn_label[2] = 'Settings';
btn_label[3] = 'Color: ' + preset_names[current_preset];
btn_label[4] = 'Speed: ' + string(global.type_speed);
btn_label[5] = font_name + ' ' + string(font_size) + 'pt';
btn_label[6] = 'Clear';

// 3. Render buttons with mouse hover underline and click detection
draw_set_font(-1);
draw_set_valign(fa_top);
draw_set_halign(fa_left);

btn_x = 16;
any_hover = false;

for (i = 0; i < btn_count; i += 1)
{
    btn_w = string_width(btn_label[i]);
    btn_h = string_height(btn_label[i]);

    // Check mouse hover
    if (mouse_x >= btn_x - 3 && mouse_x <= btn_x + btn_w + 3 && mouse_y >= btn_y - 2 && mouse_y <= btn_y + btn_h + 4)
    {
        is_hover = true;
        any_hover = true;
    }
    else
    {
        is_hover = false;
    }

    if (is_hover)
    {
        // Highlight color on hover
        draw_set_color(c_lime);
        draw_text(btn_x, btn_y, btn_label[i]);

        // Draw web hyperlink underline (matching HackerTyper CSS a:hover)
        draw_line(btn_x, btn_y + btn_h + 1, btn_x + btn_w, btn_y + btn_h + 1);

        // Click detection
        if (mouse_check_button_pressed(mb_left))
        {
            clicked_button = i;
        }
    }
    else
    {
        // Normal state color
        if (i == 1 && global.autotype_active)
        {
            draw_set_color(make_color_rgb(255, 170, 0)); // Amber warning when AutoType is ON
        }
        else
        {
            draw_set_color(make_color_rgb(0, 180, 0));
        }
        draw_text(btn_x, btn_y, btn_label[i]);
    }

    btn_x += btn_w + 20; // 20px spacing between footer items
}

// Update mouse cursor to web link hand when hovering clickable buttons
if (any_hover)
{
    window_set_cursor(cr_handpoint);
}
else
{
    window_set_cursor(cr_default);
}

// 4. Draw right-side file indicator & system state
draw_set_halign(fa_right);
draw_set_font(-1);

if (instance_exists(obj_file_loader))
{
    draw_set_color(make_color_rgb(0, 140, 0));
    draw_text(room_width - 110, btn_y, '[' + obj_file_loader.file_name + ']');
}

// Blinking status badge on far right
if (global.autotype_active)
{
    draw_set_color(make_color_rgb(255, 170, 0));
    draw_text(room_width - 16, btn_y, '[AUTO]');
}
else if (global.cursor_visible)
{
    draw_set_color(c_lime);
    draw_text(room_width - 16, btn_y, '[ONLINE]');
}
else
{
    draw_set_color(make_color_rgb(0, 70, 0));
    draw_text(room_width - 16, btn_y, '[ . . . ]');
}
