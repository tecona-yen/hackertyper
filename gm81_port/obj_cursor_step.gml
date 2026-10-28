// obj_cursor - Step Event (GameMaker 8.1)
blink_timer += 1;
if (blink_timer >= blink_interval)
{
    blink_timer = 0;
    global.cursor_visible = !global.cursor_visible;
}
