// obj_typer - Step Event (GameMaker 8.1)
var code_len, should_type, chunk, k, is_setting_key;

// Block all typing while the file loader is still reading chunks
if (obj_file_loader.is_loading) exit;

code_len = string_length(global.source_code);
if (code_len == 0) exit;

// 1. Reset typing on ESC
if (keyboard_check_pressed(vk_escape))
{
    typed_text = '';
    display_text = '';
    text_index = 1;
    scroll_y = 0;
    user_scrolled = false;
    exit;
}

// 2. Typing Keystrokes Detection & AutoType
should_type = false;

// A. AutoType mode: automatically feeds source code over time
if (global.autotype_active)
{
    autotype_timer += 1;
    if (autotype_timer >= autotype_rate)
    {
        autotype_timer = 0;
        should_type = true;
    }
}

// B. Manual keystroke check (STRICTLY filter out settings, shortcuts, and navigation keys)
// Do not type if mouse is clicking inside the bottom footer toolbar
if (mouse_y < room_height - 36)
{
    k = keyboard_lastkey;
    is_setting_key = false;

    // Filter out all Function keys (F1 - F12)
    if (k >= vk_f1 && k <= vk_f12) is_setting_key = true;

    // Filter out modifier keys
    if (k == vk_escape || k == vk_control || k == vk_alt || k == vk_shift) is_setting_key = true;

    // Filter out speed control keys: '+' (187, vk_add) and '-' (189, vk_subtract)
    if (k == vk_add || k == vk_subtract || k == 187 || k == 189) is_setting_key = true;

    // Filter out arrow navigation & editing keys
    if (k == vk_left || k == vk_right || k == vk_up || k == vk_down) is_setting_key = true;
    if (k == vk_pageup || k == vk_pagedown || k == vk_home || k == vk_end || k == vk_insert || k == vk_delete) is_setting_key = true;

    // Filter out chorded shortcuts (Ctrl+O, Ctrl+S, Alt+Enter, etc.)
    if (keyboard_check(vk_control) || keyboard_check(vk_alt)) is_setting_key = true;

    if (!is_setting_key)
    {
        if (keyboard_check_pressed(vk_anykey))
        {
            should_type = true;
            key_hold_timer = 0;
            keyboard_lastkey = 0; // Clear handled key to prevent re-triggering
        }
        else if (keyboard_check(vk_anykey))
        {
            key_hold_timer += 1;
            if (key_hold_timer >= key_repeat_delay)
            {
                if ((key_hold_timer mod key_repeat_rate) == 0)
                {
                    should_type = true;
                }
            }
        }
        else
        {
            key_hold_timer = 0;
        }
    }
    else
    {
        key_hold_timer = 0;
    }
}

if (should_type)
{
    // Copy the next chunk of characters based on current typing speed
    chunk = string_copy(global.source_code, text_index, global.type_speed);
    typed_text += chunk;
    text_index += global.type_speed;

    // Loop back to start if reaching end of source code
    if (text_index > code_len)
    {
        text_index = 1;
    }

    // Escape '#' so C preprocessor commands (#include, #define) render correctly in GM8.1
    display_text = string_replace_all(typed_text, '#', chr(92) + '#');

    // Memory / performance buffer pruning: keep the most recent ~3,500 characters
    if (string_length(typed_text) > 6000)
    {
        var cut_pos;
        cut_pos = string_pos(chr(10), string_copy(typed_text, 2500, 500));
        if (cut_pos > 0)
        {
            typed_text = string_delete(typed_text, 1, 2500 + cut_pos);
            display_text = string_replace_all(typed_text, '#', chr(92) + '#');
        }
    }

    // Typing immediately snaps view to bottom
    user_scrolled = false;
}

// 3. Mouse Wheel Scrolling
if (mouse_wheel_up())
{
    scroll_y += (line_sep * 2);
    if (scroll_y > 0) scroll_y = 0;
    user_scrolled = true;
}
if (mouse_wheel_down())
{
    scroll_y -= (line_sep * 2);
    user_scrolled = true;
}
