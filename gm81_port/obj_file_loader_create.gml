// obj_file_loader - Create Event (GameMaker 8.1)
var fname, bfile, bsize, q, crlf;

q    = chr(34);
crlf = chr(13) + chr(10);

file_name = 'Default Kernel (kernel.c)';
global.request_open_file = false;

// --- Chunked loading state ---
is_loading         = false;   // true while reading in progress
loading_file       = -1;      // text file handle
loading_progress   = 0;       // 0..100 percent
loading_buf        = '';      // accumulator for the current load
lines_per_step     = 60;      // lines read per game step
max_file_size      = 3145728; // 3 MB hard limit (3 * 1024 * 1024)
loading_total_est  = 0;       // estimated total byte count for progress bar
loading_bytes_est  = 0;       // estimated bytes read so far

// Default embedded Linux Kernel source code if user cancels dialog
global.source_code = '/*' + crlf
    + ' * Linux Kernel HackerTyper Core Engine' + crlf
    + ' * Architecture: x86_64 / Subsystem Kernel Matrix' + crlf
    + ' */' + crlf + crlf
    + '#include <linux/module.h>' + crlf
    + '#include <linux/kernel.h>' + crlf
    + '#include <linux/init.h>' + crlf + crlf
    + 'static int __init hackertyper_init(void)' + crlf
    + '{' + crlf
    + '    printk(KERN_INFO ' + q + '[SYS_INIT] Mounting cyberdeck matrix...\n' + q + ');' + crlf
    + '    task->flags |= PF_SUPERPRIV; /* Elevate permissions */' + crlf
    + '    printk(KERN_INFO ' + q + '[AUTH_GRANT] Security token: 0x7FFE4012\n' + q + ');' + crlf
    + '    return 0;' + crlf
    + '}' + crlf + crlf
    + 'static void __exit hackertyper_exit(void)' + crlf
    + '{' + crlf
    + '    printk(KERN_ALERT ' + q + '[SYSTEM] Typer offline.\n' + q + ');' + crlf
    + '}' + crlf + crlf
    + 'module_init(hackertyper_init);' + crlf
    + 'module_exit(hackertyper_exit);' + crlf
    + 'MODULE_LICENSE(' + q + 'GPL' + q + ');' + crlf;

global.source_loaded = true;

// Prompt user to select their source code file on startup
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
else
{
    // Update caption with default file
    window_set_caption('Hacker Typer - GameMaker 8.1 [' + file_name + ']');
}
