# touchtype.nvim

**touchtype.nvim** is a minimal touch typing game for Neovim, designed to help you practice typing directly in your editor.  
This is the first iteration, focusing on simplicity and core functionality.

---

## Features

- Opens a floating window with a random set of words.
- User types their input in a dedicated line.
- Real-time highlighting:  
  - Correct characters are shown in green.  
  - Incorrect characters are shown in red.
- Results window at the end showing:
  - Mistakes (uncorrected errors)
  - Time elapsed
  - Words per minute (WPM)
- Fully keyboard-driven, no mouse required.

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

## Usage

In Neovim, run:

```
:T
```

or call the Lua function:

```lua
:lua require("touchtype.game").start()
```

- A floating window will appear with words to type.
- Type the words in the input line (second line).
- When you finish typing (matching the length of the target), the results window will appear.
- If you want to restart use `:R`
- Use `:q` to close the results window.

---

## Contributing

Pull requests and suggestions are welcome!

---

## License

MIT
