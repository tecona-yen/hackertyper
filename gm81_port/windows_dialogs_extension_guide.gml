// =============================================================================
// GameMaker 8.1 Extension Reference: GM Windows Dialogs
// =============================================================================
// To use these functions instead of the built-in dialogs:
// 1. In GameMaker 8.1, go to Resources -> Select Extension Packages
// 2. Select 'GM Windows Dialogs' from the right pane and move it to the left pane.
// 3. You can then replace the get_color() / show_menu() calls in obj_settings_step
//    with the enhanced Windows common dialogs below:
// =============================================================================

/*
// --- A. ENHANCED WINDOWS COLOR DIALOG ---
wd_color_dialog_set_color(global.text_color);
if (wd_color_dialog_show())
{
    global.text_color = wd_color_dialog_get_color();
}


// --- B. ENHANCED WINDOWS FONT DIALOG ---
wd_font_dialog_set_name(font_name);
wd_font_dialog_set_size(font_size);
wd_font_dialog_set_color(global.text_color);
if (wd_font_dialog_show())
{
    font_name = wd_font_dialog_get_name();
    font_size = wd_font_dialog_get_size();
    global.text_color = wd_font_dialog_get_color();

    // Recreate the active font resource
    if (global.current_font != -1 && font_exists(global.current_font))
    {
        font_delete(global.current_font);
    }
    global.current_font = font_add(font_name, font_size, false, false, 32, 128);
}


// --- C. ENHANCED WINDOWS FILE DIALOG ---
wd_open_dialog_set_caption('Choose HackerTyper Source Code File');
wd_open_dialog_set_filter('Source Code Files (*.c;*.cpp;*.h;*.txt;*.gml;*.js)|*.c;*.cpp;*.h;*.txt;*.gml;*.js|All Files (*.*)|*.*');
if (wd_open_dialog_show())
{
    var fname, f, crlf;
    crlf = chr(13) + chr(10);
    fname = wd_open_dialog_get_file();
    if (fname != '' && file_exists(fname))
    {
        f = file_text_open_read(fname);
        global.source_code = '';
        while (!file_text_eof(f))
        {
            global.source_code += file_text_read_string(f) + crlf;
            file_text_readln(f);
        }
        file_text_close(f);
        global.source_code = string_replace_all(global.source_code, chr(9), '    ');
        file_name = filename_name(fname);
        window_set_caption('Hacker Typer - GameMaker 8.1 [' + file_name + ']');
    }
}
*/
