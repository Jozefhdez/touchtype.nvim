# touchtype.nvim

**touchtype.nvim** is a beautiful and minimal touch typing game for Neovim, designed to help you practice typing directly in your editor with a modern, visually appealing interface.

---

## ✨ Features

- 🎨 **Beautiful UI**: Clean, centered floating windows with modern styling and emojis
- 📝 **Real-time feedback**: Instant character-by-character highlighting
  - ✅ Green for correct characters  
  - ❌ Red for incorrect characters
- 📊 **Comprehensive stats**: 
  - Words per minute (WPM)
  - Accuracy percentage
  - Error count
  - Time elapsed
  - Characters typed
- 🎯 **Live metrics**: Real-time WPM and error tracking during gameplay
- ⌨️ **Keyboard-driven**: Fully accessible without mouse
- 🔄 **Quick restart**: Easy replay functionality

---

## Installation

Use your favorite plugin manager. Example with [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "jozefhdez/touchtype.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        require("touchtype").setup()
    end,
}
```

---

## 🚀 Usage

In Neovim, run:

```
:T
```

or call the Lua function:

```lua
:lua require("touchtype.game").start()
```

### 🎮 How to play:
1. A beautiful centered floating window will appear with words to type
2. Type the words exactly as shown - you'll see real-time feedback with colors
3. Watch your live WPM and error count in the status bar
4. When finished, view your detailed results
5. Press `R` to play again or `q` to quit

### ⌨️ Controls:
- **Typing**: Just start typing the displayed words
- **Restart**: `:R` - Quick restart for another round
- **Quit**: `:q` - Close the results window
- **Backspace**: Fix mistakes as you type

---

## 🛠️ Roadmap

- [ ] 🎨 Custom color themes and UI customization
- [ ] 📈 Progress tracking and statistics history  
- [ ] 📖 Custom word lists and difficulty levels
- [ ] ⏰ Configurable session length and game modes
- [ ] 🏆 Achievement system and personal records
- [ ] 📊 Visual progress graphs (monkeytype-style)

---

## Contributing

Pull requests and suggestions are welcome!

---

## License

MIT
