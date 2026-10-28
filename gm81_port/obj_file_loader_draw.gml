// obj_file_loader - Draw Event (GameMaker 8.1)
// Renders the hacker-themed loading overlay while reading a file chunk by chunk.

var bx, by, bw, bh, bar_x, bar_y, bar_w, bar_h, fill_w, pct_str, title_str;

if (!is_loading) exit;

// ---- Layout ----
bw = 480;
bh = 120;
bx = (room_width  - bw) / 2;
by = (room_height - bh) / 2;

// ---- Dark translucent background ----
draw_set_alpha(0.88);
draw_set_color(make_color_rgb(0, 8, 0));
draw_rectangle(bx, by, bx + bw, by + bh, false);
draw_set_alpha(1);

// ---- Bright green border ----
draw_set_color(make_color_rgb(0, 255, 0));
draw_rectangle(bx, by, bx + bw, by + bh, true);

// ---- Title text ----
draw_set_font(-1);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_color(make_color_rgb(0, 255, 0));
title_str = '[ LOADING SOURCE FILE: ' + file_name + ' ]';
draw_text(bx + bw / 2, by + 14, title_str);

// ---- Progress bar background (dark grey track) ----
bar_x = bx + 24;
bar_y = by + 50;
bar_w = bw - 48;
bar_h = 20;
draw_set_color(make_color_rgb(0, 30, 0));
draw_rectangle(bar_x, bar_y, bar_x + bar_w, bar_y + bar_h, false);

// ---- Progress bar fill (bright green) ----
fill_w = floor((bar_w * loading_progress) / 100);
if (fill_w > 0)
{
    draw_set_color(make_color_rgb(0, 220, 0));
    draw_rectangle(bar_x, bar_y, bar_x + fill_w, bar_y + bar_h, false);
}

// ---- Progress bar border ----
draw_set_color(make_color_rgb(0, 255, 0));
draw_rectangle(bar_x, bar_y, bar_x + bar_w, bar_y + bar_h, true);

// ---- Percentage text centred on bar ----
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(make_color_rgb(0, 0, 0));
pct_str = string(loading_progress) + '%';
draw_text(bar_x + bar_w / 2, bar_y + bar_h / 2, pct_str);

// ---- Footer hint ----
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_color(make_color_rgb(0, 140, 0));
draw_text(bx + bw / 2, by + bh - 22, 'Reading file - please wait...');

// Reset alignment
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
