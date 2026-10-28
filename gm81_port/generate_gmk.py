import struct
import zlib
import os

def build_hackertyper_gmk(output_path):
    # Load GML files
    base_dir = os.path.dirname(output_path)
    def read_gml(fname):
        with open(os.path.join(base_dir, fname), 'r', encoding='utf-8') as f:
            return f.read().replace('\r\n', '\n').replace('\n', '\r\n')

    loader_create   = read_gml('obj_file_loader_create.gml')
    loader_step     = read_gml('obj_file_loader_step.gml')
    loader_draw     = read_gml('obj_file_loader_draw.gml')

    typer_create    = read_gml('obj_typer_create.gml')
    typer_step      = read_gml('obj_typer_step.gml')
    typer_draw      = read_gml('obj_typer_draw.gml')

    cursor_create   = read_gml('obj_cursor_create.gml')
    cursor_step     = read_gml('obj_cursor_step.gml')
    cursor_draw     = read_gml('obj_cursor_draw.gml')

    settings_create = read_gml('obj_settings_create.gml')
    settings_step   = read_gml('obj_settings_step.gml')
    settings_draw   = read_gml('obj_settings_draw.gml')

    room_code       = read_gml('room_creation_code.gml')

    # Load base template for Settings and GameInfo
    template_path = r'G:\Gamemaker\resources\github-exmples\GMK8_Examples\While - copia.gmk'
    with open(template_path, 'rb') as f:
        tbuf = f.read()

    tpos = 0
    def tr_dword():
        nonlocal tpos
        v, = struct.unpack_from('<I', tbuf, tpos)
        tpos += 4
        return v
    def tr_chunk():
        nonlocal tpos
        l = tr_dword()
        raw = tbuf[tpos:tpos+l]
        tpos += l
        return zlib.decompress(raw)

    for _ in range(7): tr_dword()
    tr_dword() # settings ver
    settings_chunk = tr_chunk()
    
    # We will construct the new GMK
    out = bytearray()
    def w_dword(v):
        out.extend(struct.pack('<I', v & 0xFFFFFFFF))
    def w_int(v):
        out.extend(struct.pack('<i', v))
    def w_bool(v):
        w_dword(1 if v else 0)
    def w_str(s):
        b = s.encode('latin-1') if isinstance(s, str) else s
        w_dword(len(b))
        out.extend(b)
    def w_chunk(decompressed_bytes):
        comp = zlib.compress(decompressed_bytes, 9)
        w_dword(len(comp))
        out.extend(comp)
    def w_double(v):
        out.extend(struct.pack('<d', float(v)))

    # 1. Header
    w_dword(1234321) # magic
    w_dword(800)     # GMK version 800 (natively opened by GM8.1)
    w_dword(760327277) # Game ID
    for g in [714050681, 1276437126, 2045325995, 3044608987]:
        w_dword(g)

    # 2. Settings
    w_dword(800)
    w_chunk(settings_chunk)

    # 3. Triggers
    w_dword(800)
    w_dword(0) # count 0
    w_double(0) # timestamp

    # 4. Constants
    w_dword(800)
    w_dword(0) # count 0
    w_double(0) # timestamp

    # 5. Sounds, Sprites, Backgrounds, Paths, Scripts, Fonts, Timelines (all 0 count)
    for _ in range(7):
        w_dword(800)
        w_dword(0)

    # Helper to serialize an action with GML code
    def serialize_action(code_str):
        a = bytearray()
        def aw_dword(v): a.extend(struct.pack('<I', v & 0xFFFFFFFF))
        def aw_int(v): a.extend(struct.pack('<i', v))
        def aw_bool(v): aw_dword(1 if v else 0)
        def aw_str(s):
            b = s.encode('latin-1') if isinstance(s, str) else s
            aw_dword(len(b))
            a.extend(b)

        aw_dword(440) # version
        aw_dword(1)   # libId (Main/Standard)
        aw_dword(603) # actId (Execute a piece of code)
        aw_dword(7)   # kind (Code)
        aw_bool(False) # mayBeRelative
        aw_bool(False) # question
        aw_bool(False) # appliesToSomething
        aw_dword(2)   # actType (Code)
        aw_str("")    # fnName
        aw_str("")    # fnCode
        aw_dword(1)   # argumentsUsed
        aw_dword(8)   # argumentCount
        for k in range(8):
            aw_dword(1 if k == 0 else 0) # argumentKind (1=string for arg 0)
        aw_int(-1)    # appliesToObject (self = -1)
        aw_bool(False) # isRelative
        aw_dword(8)   # valCount
        aw_str(code_str) # arg 0: GML code!
        for _ in range(7):
            aw_str("0")
        aw_bool(False) # not
        return a

    # Helper to serialize an object
    def serialize_object(name, events_dict):
        # events_dict: { event_type: [(event_kind, code_str), ...] }
        # event_type: 0=create, 3=step, 8=draw
        o = bytearray()
        def ow_dword(v): o.extend(struct.pack('<I', v & 0xFFFFFFFF))
        def ow_int(v): o.extend(struct.pack('<i', v))
        def ow_bool(v): ow_dword(1 if v else 0)
        def ow_str(s):
            b = s.encode('latin-1') if isinstance(s, str) else s
            ow_dword(len(b))
            o.extend(b)

        ow_bool(True) # exists
        ow_str(name)
        ow_dword(0); ow_dword(0) # timestamp
        ow_dword(430) # version
        ow_int(-1)    # spriteIndex (-1 = none)
        ow_bool(False) # solid
        ow_bool(True)  # visible
        ow_int(0)     # depth
        ow_bool(False) # persistent
        ow_int(-1)    # parentIndex
        ow_int(-1)    # maskIndex
        
        ev_count = 11
        ow_dword(ev_count) # evCount - 1 (so 11 means 12 events 0..11)
        for ev in range(ev_count + 1):
            if ev in events_dict:
                for ev_kind, code_str in events_dict[ev]:
                    ow_int(ev_kind)
                    ow_dword(400) # version
                    ow_dword(1)   # action count
                    o.extend(serialize_action(code_str))
            ow_int(-1) # end of sub-events for this event
        return o

    # 6. Objects: 4 objects
    w_dword(800)
    w_dword(4) # 4 objects
    
    # Object 0: obj_file_loader
    loader_obj = serialize_object("obj_file_loader", {
        0: [(0, loader_create)],
        3: [(0, loader_step)],
        8: [(0, loader_draw)]
    })
    w_chunk(loader_obj)

    # Object 1: obj_typer
    typer_obj = serialize_object("obj_typer", {
        0: [(0, typer_create)],
        3: [(0, typer_step)],
        8: [(0, typer_draw)]
    })
    w_chunk(typer_obj)

    # Object 2: obj_cursor
    cursor_obj = serialize_object("obj_cursor", {
        0: [(0, cursor_create)],
        3: [(0, cursor_step)],
        8: [(0, cursor_draw)]
    })
    w_chunk(cursor_obj)

    # Object 3: obj_settings
    settings_obj = serialize_object("obj_settings", {
        0: [(0, settings_create)],
        3: [(0, settings_step)],
        8: [(0, settings_draw)]
    })
    w_chunk(settings_obj)

    # Helper to serialize room
    def serialize_room():
        r = bytearray()
        def rw_dword(v): r.extend(struct.pack('<I', v & 0xFFFFFFFF))
        def rw_int(v): r.extend(struct.pack('<i', v))
        def rw_bool(v): rw_dword(1 if v else 0)
        def rw_str(s):
            b = s.encode('latin-1') if isinstance(s, str) else s
            rw_dword(len(b))
            r.extend(b)

        rw_bool(True) # exists
        rw_str("room0")
        rw_dword(0); rw_dword(0) # timestamp
        rw_dword(541) # version
        rw_str("Hacker Typer") # caption
        rw_dword(1280) # width
        rw_dword(768)  # height
        rw_dword(16)   # snapY
        rw_dword(16)   # snapX
        rw_bool(False) # isoGrid
        rw_dword(30)   # speed
        rw_bool(False) # persistent
        rw_dword(0)    # bgColor = 0 (c_black)
        rw_bool(True)  # bgColorDraw = true
        rw_str(room_code) # creationCode

        rw_dword(8)   # background count = 8
        for _ in range(8):
            rw_bool(False) # visible
            rw_bool(False) # foreground
            rw_int(-1)     # bgIndex
            rw_dword(0); rw_dword(0) # x, y
            rw_bool(True); rw_bool(True) # tileH, tileV
            rw_dword(0); rw_dword(0) # vSpeed, hSpeed
            rw_bool(False) # stretch

        rw_bool(False) # enableViews
        rw_dword(8)    # view count = 8
        for _ in range(8):
            rw_bool(False) # visible
            rw_dword(0); rw_dword(0); rw_dword(1280); rw_dword(768) # viewX, viewY, viewW, viewH
            rw_dword(0); rw_dword(0); rw_dword(1280); rw_dword(768) # portX, portY, portW, portH
            rw_dword(32); rw_dword(32) # hBorder, vBorder
            rw_int(-1); rw_int(-1)     # hSpd, vSpd
            rw_int(-1)                 # objFollow

        # Instances: 4 instances (obj_file_loader, obj_typer, obj_cursor, obj_settings)
        rw_dword(4)
        inst_defs = [
            (0, 0, 0, 100001), # obj_file_loader
            (0, 0, 1, 100002), # obj_typer
            (0, 0, 2, 100003), # obj_cursor
            (0, 0, 3, 100004), # obj_settings
        ]
        for ix, iy, iobj, iid in inst_defs:
            rw_int(ix); rw_int(iy); rw_int(iobj); rw_int(iid)
            rw_str("") # instance creation code
            rw_bool(False) # locked

        rw_dword(0) # tileCount = 0

        rw_bool(False) # rememberRoomEditorInfo
        rw_dword(1280); rw_dword(768) # editorWidth, editorHeight
        rw_bool(True)  # showGrid
        rw_bool(True)  # showObjects
        rw_bool(True)  # showTiles
        rw_bool(True)  # showBackgrounds
        rw_bool(True)  # showForegrounds
        rw_bool(True)  # showViews
        rw_bool(True)  # deleteUnderlyingObjects
        rw_bool(True)  # deleteUnderlyingTiles
        rw_dword(0)    # tab
        rw_dword(0); rw_dword(0) # xPosScroll, yPosScroll
        return r

    # 7. Rooms
    w_dword(800)
    w_dword(1) # 1 room
    w_chunk(serialize_room())

    # 8. lastInstance & lastTile
    w_dword(100005) # lastInstance
    w_dword(10000000) # lastTile

    # 9. Includes (0 count)
    w_dword(800)
    w_dword(0)

    # 10. Packages (0 count)
    w_dword(700)
    w_dword(0)

    # 11. Game Information
    gi = bytearray()
    gi.extend(struct.pack('<I', 800)) # version
    gi.extend(struct.pack('<I', 0xFFFFFF)) # bgColor (white)
    gi.extend(struct.pack('<I', 0)) # mimic
    def gi_str(s):
        b = s.encode('latin-1')
        gi.extend(struct.pack('<I', len(b)))
        gi.extend(b)
    gi_str("Game Information")
    gi.extend(struct.pack('<I', 0)) # left
    gi.extend(struct.pack('<I', 0)) # top
    gi.extend(struct.pack('<I', 600)) # width
    gi.extend(struct.pack('<I', 400)) # height
    gi.extend(struct.pack('<I', 0)) # showBorder
    gi.extend(struct.pack('<I', 0)) # allowResize
    gi.extend(struct.pack('<I', 0)) # stayOnTop
    gi.extend(struct.pack('<I', 0)) # pauseGame
    gi.extend(struct.pack('<d', 0.0)) # lastChanged
    gi_str("HackerTyper for GameMaker 8.1") # text
    w_dword(800)
    w_chunk(gi)

    # 12. libCreationCode
    w_dword(500)
    w_dword(8)
    for _ in range(8):
        w_str("")

    # 13. roomExecutionOrder
    w_dword(700)
    w_dword(1)
    w_dword(0) # room 0

    # 14. Resource Tree
    tree = [
        ("Sprites", 1, 2, 0, []),
        ("Sounds", 1, 3, 0, []),
        ("Backgrounds", 1, 6, 0, []),
        ("Paths", 1, 8, 0, []),
        ("Scripts", 1, 7, 0, []),
        ("Fonts", 1, 9, 0, []),
        ("Time Lines", 1, 12, 0, []),
        ("Objects", 1, 1, 0, [
            ("obj_file_loader", 3, 1, 0, []),
            ("obj_typer", 3, 1, 1, []),
            ("obj_cursor", 3, 1, 2, []),
            ("obj_settings", 3, 1, 3, [])
        ]),
        ("Rooms", 1, 4, 0, [
            ("room0", 3, 4, 0, [])
        ]),
        ("Game Information", 3, 10, 0, []),
        ("Global Game Settings", 3, 11, 0, []),
        ("Extension Packages", 3, 13, 0, [])
    ]

    def write_tree_node(node):
        name, status, group, idx, children = node
        w_dword(status)
        w_dword(group)
        w_int(idx)
        w_str(name)
        w_dword(len(children))
        for ch in children:
            write_tree_node(ch)

    for root_node in tree:
        write_tree_node(root_node)

    with open(output_path, 'wb') as f:
        f.write(out)
    print(f"Successfully generated GMK: {output_path} ({len(out)} bytes)")

if __name__ == '__main__':
    build_hackertyper_gmk(r'g:\Gamemaker\hackertyper\gm81_port\hackertyper.gmk')
