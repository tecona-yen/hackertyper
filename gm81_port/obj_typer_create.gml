// obj_typer - Create Event (GameMaker 8.1)
text_index = 1;              // 1-based index in GML strings
typed_text = '';             // Raw revealed text
display_text = '';           // Display text with escaped '#' -> chr(92)+'#'

// Global configuration variables
global.type_speed = 3;       // Characters per keystroke (default 3, range 1-20)
global.autotype_active = false; // AutoType mode toggle
global.text_color = c_lime;  // Classic HackerTyper terminal green (#00FF00)
global.bg_color = c_black;   // Pitch black background

// Font and Layout
global.current_font = -1;    // -1 = Default Arial; replaced by obj_settings with Courier New/Consolas
line_sep = 18;               // Updated dynamically based on font height
margin_x = 24;               // Horizontal margin
margin_y = 24;               // Top margin

// Scrolling state
scroll_y = 0;                // Vertical scroll offset in pixels
user_scrolled = false;       // True when user scrolls manually with mouse wheel

// Keyboard repeat timers
key_hold_timer = 0;
key_repeat_delay = 12;
key_repeat_rate = 2;

// AutoType timer (frames between automatic typing)
autotype_timer = 0;
autotype_rate = 2;           // Every 2 frames (~15-30 keystrokes/sec)
