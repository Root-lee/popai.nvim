# VHS Tape - popai.nvim Demo
# https://github.com/charmbracelet/vhs

# Output settings
Output assets/demo.gif
Set TypingSpeed 50ms
Set PlaybackSpeed 0.7

# Terminal settings - 1080p
Set FontFamily "Monaco"
Set FontSize 22
Set Width 1920
Set Height 1080
Set Padding 20
Set Margin 20
Set MarginFill "#1e1e2e"
Set BorderRadius 12

# Window chrome
Set WindowBar Colorful
Set WindowBarSize 40

# Theme - Catppuccin Mocha style
Set Theme "Catppuccin Mocha"

# ============================================================
# Demo Script
# ============================================================

# Prepare: copy demo_content.txt to /tmp
Hide
Type "cp ~/.config/nvim/popai.nvim/demo_content.txt /tmp/demo_popai.py"
Enter
Sleep 300ms
Show

# Open demo file
Type "nvim /tmp/demo_popai.py"
Enter
Sleep 1s

# ============================================================
# Demo 1: Translate to Chinese
# ============================================================
# Line 5: print('Hello, World!')

Type ":5"
Enter
Sleep 300ms

Type "f'"
Sleep 300ms
Type "vi'"
Sleep 500ms

Type ":Popai translate_ch"
Enter
Sleep 5s

Type "q"
Sleep 800ms

# ============================================================
# Demo 2: Translate to English
# ============================================================
# Line 8: msg = '今天天气真好'

Type ":8"
Enter
Sleep 300ms

Type "f'"
Sleep 300ms
Type "vi'"
Sleep 500ms

Type ":Popai translate_en"
Enter
Sleep 5s

Type "q"
Sleep 800ms

# ============================================================
# Demo 3: Explain Regex
# ============================================================
# Line 11: pattern = r'\d{3}-\d{4}'

Type ":11"
Enter
Sleep 300ms

Type "f'"
Sleep 300ms
Type "vi'"
Sleep 500ms

Type ":Popai regex_explain"
Enter
Sleep 5s

Type "q"
Sleep 800ms

# ============================================================
# Demo 4: Explain Cron Expression
# ============================================================
# Line 14: cron = '30 3 * * *'

Type ":14"
Enter
Sleep 300ms

Type "f'"
Sleep 200ms
Type "vi'"
Sleep 500ms

Type ":Popai cron_explain"
Enter
Sleep 4s

Type "q"
Sleep 800ms

# ============================================================
# Demo 5: Explain Shell Command
# ============================================================
# Line 17: cmd = "ls -la | grep .py"

Type ":17"
Enter
Sleep 300ms

Type 'f"'
Sleep 200ms
Type 'vi"'
Sleep 500ms

Type ":Popai shell_explain"
Enter
Sleep 5s

Type "q"
Sleep 800ms

# ============================================================
# Demo 6: Emoji
# ============================================================
# Line 20: mood = 'I love coding'

Type ":20"
Enter
Sleep 300ms

Type "f'"
Sleep 200ms
Type "vi'"
Sleep 500ms

Type ":Popai emoji"
Enter
Sleep 4s

Type "q"
Sleep 800ms

# ============================================================
# End Demo
# ============================================================

Type ":q!"
Enter
Sleep 500ms
