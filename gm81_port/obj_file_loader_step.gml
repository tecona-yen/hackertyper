// obj_file_loader - Step Event (GameMaker 8.1)
var fname, bfile, bsize, crlf, i, line;

crlf = chr(13) + chr(10);

// =========================================================
// A. Chunked loading tick: read N lines per game step
// =========================================================
if (is_loading)
{
    i = 0;
    while (i < lines_per_step && !file_text_eof(loading_file))
    {
        line = file_text_read_string(loading_file);
        file_text_readln(loading_file);
        loading_buf       += line + crlf;
        loading_bytes_est += string_length(line) + 2;
        i += 1;
    }

    // Update progress estimate (cap at 99 until fully done)
    if (loading_total_est > 0)
    {
        loading_progress = floor((loading_bytes_est / loading_total_est) * 100);
        if (loading_progress > 99) loading_progress = 99;
    }
    else
    {
        loading_progress = 50;
    }

    // Check if we reached end of file
    if (file_text_eof(loading_file))
    {
        file_text_close(loading_file);
        loading_file = -1;

        // Finalise: replace tabs with spaces, then publish
        loading_buf   = string_replace_all(loading_buf, chr(9), '    ');
        global.source_code = loading_buf;
        loading_buf   = '';
        loading_progress = 100;
        is_loading    = false;

        window_set_caption('Hacker Typer - GameMaker 8.1 [' + file_name + ']');

        // Reset typer for fresh file
        with (obj_typer)
        {
            typed_text   = '';
            display_text = '';
            text_index   = 1;
            scroll_y     = 0;
            user_scrolled = false;
        }
    }
    exit; // Skip hotkey handling while loading
}

// =========================================================
// B. Open-file hotkey / footer-button trigger
// =========================================================
if (global.request_open_file || keyboard_check_pressed(vk_f2) || (keyboard_check(vk_control) && keyboard_check_pressed(ord('O'))))
{
    global.request_open_file = false;
    io_clear();

    fname = get_open_filename('Source Code Files (*.c;*.cpp;*.h;*.txt;*.gml;*.js)|*.c;*.cpp;*.h;*.txt;*.gml;*.js|All Files (*.*)|*.*', '');
    if (fname != '' && file_exists(fname))
    {
        // --- Check file size before opening ---
        bfile = file_bin_open(fname, 0);
        bsize = file_bin_size(bfile);
        file_bin_close(bfile);

        if (bsize > max_file_size)
        {
            show_message('File is too large!' + chr(13) + 'Maximum supported file size is 3 MB.' + chr(13) + 'Please choose a smaller source file.');
        }
        else
        {
            // Begin async chunked loading
            if (loading_file != -1) file_text_close(loading_file);
            loading_file      = file_text_open_read(fname);
            loading_buf       = '';
            loading_total_est = bsize;
            loading_bytes_est = 0;
            loading_progress  = 0;
            is_loading        = true;
            file_name         = filename_name(fname);
            window_set_caption('Hacker Typer - GameMaker 8.1 [Loading: ' + file_name + ']');
        }
    }
    io_clear();
}
