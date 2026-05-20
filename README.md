# Antigravity IDE Window Borders Patcher

A zero-dependency Perl script to restore native OS window borders (Server-Side Decorations) in the Google Antigravity IDE (v2.0.0+).

## The Problem
In recent updates of the Antigravity IDE (which is based on Electron/VS Code), the developers hardcoded `titleBarStyle: 'hidden'` inside the Electron window configuration (`app.asar`). This setting completely ignores your internal IDE configuration (`"window.titleBarStyle": "native"`) and forces a frameless window layout. On many Linux desktop environments (such as MATE/Marco, XFCE, and some Wayland setups), this causes the application to run completely without window borders, shadows, or OS-native decorations.

## The Solution
This lightweight Perl script performs a safe, in-place binary patch of the `app.asar` file. It replaces the hardcoded `titleBarStyle: 'hidden'` with `titleBarStyle:'default'` (preserving the exact byte length of the file to prevent breaking the ASAR archive offsets). 

This instantly restores the standard window frame and lets your OS window manager draw the native borders and shadows you love.

## How to Use

1. Download the patcher script:
   ```bash
   curl -O https://raw.githubusercontent.com/orikuttner/antigravity-window-borders-patcher/main/patch_antigravity.pl
   chmod +x patch_antigravity.pl
   
2. Find the app.asar file in the `resources` directory.

3. Patch it using
	```bash
	perl <path_to_app.asar>

	

