# Blood Upon the Snow: The Aftermath

A story-driven Godot action game where you play as **Thorgestr**, a Viking warrior uncovering betrayal inside Reykjanesta after a raid.

## Play

- Itch.io (Web build): **`https://emberlul.itch.io/blood-upon-the-snow-the-aftermath`**
- Local (Godot): open this project in **Godot 4.4** and run `project.godot`.

## What This Game Is About

After returning from battle, Thorgestr speaks with his father, receives orders from Commander Bjorn, survives an ambush, escapes prison, uncovers treason, and fights for the future of Reykjanesta.

The game blends:
- narrative dialogue scenes
- an archery survival challenge
- a lockpicking minigame
- a 3-stage duel sequence

## What This Project Contains

- `scenes/`: all game scenes (menu, world, hall, archery, jail, betrayal, duels, win/lose screens)
- `scripts/`: gameplay/state scripts (dialogue flow, combat, minigames, scene transitions, global state)
- `assets/`: sprites, backgrounds, UI art, SFX, fonts
- `web/`: exported web build files (`index.html`, `.pck`, `.wasm`, etc.)
- `export_presets.cfg`: Godot export settings (Web preset included)

## How to Play

### 1. Overworld / Dialogue
- **Left Click**: move Thorgestr (point-and-click movement)
- **E**: interact with NPCs/objects
- **Space/Enter** (`ui_accept`): advance dialogue text

### 2. Archery Minigame
- **WASD**: move
- **Mouse**: aim
- **Left Click**: shoot
- Goal: reach **50 kills** before dying to continue the story

### 3. Lockpicking Minigame
- **Mouse movement**: angle the lockpick
- **Hold Space** (`ui_accept`): turn the lock cylinder
- **Esc** (`ui_cancel`): exit lockpicking
- Complete all 5 lock levels to escape

### 4. Duel Rounds
- Click the red hit marker when it appears
- Successful click damages the enemy; missed timing damages you
- Win 3 rounds to reach the ending

## Run Locally

### Option A: Godot Editor (recommended)
1. Install Godot **4.4**.
2. Import this folder as a project.
3. Run the main scene (`menu.tscn`) from the editor.

### Option B: Run Exported Web Build
1. Serve the `web/` folder with a local server (do not open `index.html` directly from file path).
2. Example:
   - `cd web`
   - `python -m http.server 8000`
3. Open `http://localhost:8000`.

## Credits

Built in Godot with custom game logic, dialogue scripting, and minigame flow created for **Blood Upon the Snow: The Aftermath**.
