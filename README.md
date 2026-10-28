# HackerTyper - GameMaker 8.1 Port

A full recreation of [HackerTyper.net](https://hackertyper.net/#) use as a **win32 executable**.
Created for [Gamemaker 8.1.141](https://archive.org/details/gm8-and-ds)
To work on or compile this project, you will need to download it from the archive.org link above, when using gamemaker 8.1, type any string into the regsitration box to complete licencing and setup to use the pro version.

---

## 🌟 What's New & Fixed
1. **Consolidated Bottom Toolbar**: The top toolbar has been removed. All controls, status tags, and buttons now live exclusively in a sleek, compact bottom footer (`room_height - 34`). Typing code starts at the top and never overlaps the interface.
2. **Web-Style Hover Underline & Clickable Links**: Hovering over footer buttons changes the cursor to the pointing hand (`cr_handpoint`) and displays a smooth underline (matching CSS `a:hover { text-decoration: underline; }`). Clicking buttons triggers actions directly.
3. **Key-Leak Prevention**: Control and shortcut keys (`+`, `-`, `=`, `_`, `F1`–`F12`, `ESC`, `Ctrl`, `Alt`, `Shift`, arrow keys, and mouse clicks in the footer) are strictly filtered out so they no longer accidentally type characters into the code buffer.
4. **1280x768 Scalable Resolution**: The default resolution is now **1280x768**, resizable by the user (`window_set_sizeable(true)`), with `F11` or `Alt+Enter` for instant fullscreen.
5. **Themed Cyber Dialogs**: All built-in dialogs (`get_integer`, `get_string`, `show_message`) are customized to the hacker theme using GML 8.1 `message_*` functions (black backgrounds, green Courier text, centered).
6. **AutoType Mode (`F3`)**: Press `F2` or click `[AutoType: ON]` to have code stream automatically down the terminal.

---
## 🌟 Issues & Fixes

### ✅ Large File Loading (Fixed)
- Files **larger than 10 MB** are now **rejected immediately** with a friendly dialog instead of hanging.
- Files **≤ 3 MB** are loaded **chunk-by-chunk** (60 lines per game step) using `file_bin_open`/`file_bin_size` for the size check, then `file_text_open_read` with incremental reads across frames.
- A hacker-themed **loading bar overlay** is shown while reading, displaying filename and live progress percentage.
- Typing is **blocked** during loading so no spurious characters enter the buffer.

### ⚠️ Compiling Note
When compiling in the GameMaker 8.1 IDE, run `gm8x_fix.exe` on the resulting `.exe` to prevent the access violation on startup and remove DirectPlay dependencies.  
→ [https://github.com/skyfloogle/gm8x_fix](https://github.com/skyfloogle/gm8x_fix)
---

## 🎮 Interactive Controls

| Control | Action |
|---|---|
| **Any Typing Key** | Types code chunk from loaded file |
| **Mouse Wheel** | Scrolls up and down through the terminal |
| **Mouse Hover on Footer** | Highlights button, draws underline, shows hand pointer |
| **Left Click on Footer** | Executes the clicked function |
| **`F1`** or **`Ctrl+O`** | Show the help window |
| **`F2`** or **`Ctrl+O`** | Opens Windows file picker for source files |
| **`F3`** | Toggles **AutoType** (automatic code streaming) |
| **`F4`** or **`Ctrl+S`** | Opens the **Settings Menu** |
| **`F5`** | Cycles color presets (Green, Amber, Cyan, Red, Purple, White) |
| **`F9`** | Take a screenshot of the game|
| **`+` / `-`** | Adjusts typing speed (1–20 characters per keystroke) |
| **`F11`** or **`Alt+Enter`** | Toggles fullscreen |
| **`ESC`** | Clears the terminal and restarts typing |

---
## 📁 Project Structure (`hackertyper\`)
- `hackertyper.gm81`: Fully completed, polished gamemaker project (Open in gamemaker 8.1).
- `kernel.c`: Authentic Linux kernel module C source code to load and type. 
- You can also use `worm.c` - the decompiled morris worm source code
[https://github.com/skyfloogle/gm8x_fix](https://github.com/skyfloogle/gm8x_fix) Use this to fix the executeable after compiling in gamemaker 8.1
- `hackertyper.ico` : Icon file for the executable
- `loading_image.png` and `loading_prgress_bar.png` : Loading cover image
- `infomation.rtf`: Infomation for the game help screen

### 📁 Javascript Code (`hackertyper\hackertyper.net_source_code`)
- contains the downloaded js source code and html from hackertyper.net, used to help create the GML port


### 📁 Project Scripts (`hackertyper\gm81_port\`)
- `hackertyper_base.gmk`: Ready-to-open GameMaker project (1280x768, 4 objects, room setup).
- `generate_gmk.py`: Python generator that compiles the `.gmk` project from the scripts.
- `obj_settings_create.gml` / `step.gml` / `draw.gml`: Consolidated bottom footer, hover underlines, clickable buttons, font/color management.
- `obj_typer_create.gml` / `step.gml` / `draw.gml`: Typing engine, key filtering, `#` escaping, auto-scrolling, font metrics.
- `obj_file_loader_create.gml` / `step.gml` / `draw.gml`: Source file loading, tab cleaning (`chr(9)` -> 4 spaces), fallback kernel.
- `obj_cursor_create.gml` / `step.gml` / `draw.gml`: 500ms cursor blink timing.
- `room_creation_code.gml`: Room setup (1280x768, sizeable window, black background).
- `windows_dialogs_extension_guide.gml`: Guide and code for the `GM Windows Dialogs` extension package (`wd_`).

---

## 🎨 Themed Dialogs vs. Windows Dialogs Extension

### 1. Built-in Themed Dialogs (Active by Default)
Configured in [`obj_settings_create.gml`](file:///g:/Gamemaker/hackertyper/gm81_port/obj_settings_create.gml) using GML 8.1 manual functions:
```gml
message_caption(1, 'HackerTyper Terminal');
message_position(-1, -1);
message_size(480, -1);
message_text_font('Courier New', 11, make_color_rgb(0, 255, 0), 1);
message_input_font('Courier New', 11, make_color_rgb(0, 255, 0), 0);
message_button_font('Courier New', 10, c_black, 1);
message_input_color(make_color_rgb(10, 24, 10));
message_mouse_color(make_color_rgb(0, 255, 0));
```

### 2. GM Windows Dialogs Extension (`wd_`)
To use native Windows common dialogs instead, these are not used currently:
1. In GameMaker 8.1, go to **Resources > Select Extension Packages**. This package is built into gamemaker 8.1
2. Select **GM Windows Dialogs** and add it to the project.
3. Replace the dialog calls in `obj_settings_step.gml` using the examples in [`windows_dialogs_extension_guide.gml`](file:///g:/Gamemaker/hackertyper/gm81_port/windows_dialogs_extension_guide.gml).
