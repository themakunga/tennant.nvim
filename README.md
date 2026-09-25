# tennant.nvim

> **Text-to-Speech for Neovim** — lee en voz alta palabras, líneas, bloques y notificaciones usando el motor TTS nativo de tu sistema operativo.
>
> **Text-to-Speech for Neovim** — reads aloud words, lines, blocks and notifications using your OS's native TTS engine.

---

## Español

### ¿Qué es?

`tennant.nvim` es un plugin de Neovim que convierte texto en voz usando el motor TTS nativo de cada sistema operativo: `say` en macOS, PowerShell en Windows y `spd-say` / `espeak-ng` / `espeak` / `festival` en Linux. No requiere dependencias externas de Lua ni APIs de pago.

### Requisitos

| Plataforma | Requisito |
|------------|-----------|
| **macOS** | `say` (incluido en el sistema) |
| **Linux** | `spd-say`, `espeak-ng`, `espeak` o `festival` (cualquiera) |
| **Windows** | PowerShell + .NET Framework (incluido en Windows) |
| **Neovim** | >= 0.12 |
| **Treesitter** | Opcional — mejora la lectura de bloques por tipo |

### Instalación

#### lazy.nvim (recomendado)

```lua
{
  'themakunga/tennant.nvim',
  event = 'VeryLazy',
  opts = {
    -- prefix = '<leader>tv', -- prefijo por defecto
  },
}
```

#### packer.nvim

```lua
use {
  'themakunga/tennant.nvim',
  config = function()
    require('tennant').setup()
  end,
}
```

#### vim-plug

```vim
Plug 'themakunga/tennant.nvim'
```

Luego en tu config:

```lua
require('tennant').setup()
```

#### vim packages (`:h packages`)

```bash
mkdir -p ~/.local/share/nvim/site/pack/plugins/start
git clone https://github.com/themakunga/tennant.nvim \
  ~/.local/share/nvim/site/pack/plugins/start/tennant.nvim
```

Agrega en tu `init.lua`:

```lua
require('tennant').setup()
```

#### rocks.nvim

```lua
-- en tu rocks.toml
[plugins]
"tennant.nvim" = "scm"
```

O en tu config:

```lua
require('rocks').install('tennant.nvim')
```

### Configuración

```lua
require('tennant').setup({
  prefix = '<leader>tv',
  language = 'es', -- 'es' (default) or 'en'
})
```

`language` cambia los avisos, las etiquetas leídas y las descripciones de comandos y atajos. El contenido del archivo y las notificaciones externas se leen sin traducir. La voz y pronunciación dependen de la configuración del motor TTS del sistema; selecciona una voz inglesa en ese motor para leer inglés.

### Atajos de teclado

Con el prefijo por defecto `<leader>tv`:

| Atajo | Acción |
|-------|--------|
| `<leader>tvw` | Leer la palabra bajo el cursor |
| `<leader>tvl` | Leer la línea actual |
| `<leader>tvl` (modo visual) | Leer el texto seleccionado (`v`, `V` o `Ctrl-v`) |
| `<leader>tvb` | Leer el bloque completo más cercano (usa Treesitter si está disponible) |
| `<leader>tvp` | Subir y leer el bloque contenedor |
| `<leader>tvn` | Leer las notificaciones |
| `<leader>tvs` | Detener la lectura |

### Comandos

| Comando | Descripción |
|---------|-------------|
| `:TennantWord` | Lee la palabra bajo el cursor |
| `:[rango]TennantLine` | Lee la línea actual o el rango indicado (por ejemplo, `:2,5TennantLine`) |
| `:TennantBlock` | Lee el bloque completo más cercano |
| `:TennantParent` | Sube y lee el bloque contenedor |
| `:TennantNotify` | Lee las notificaciones |
| `:TennantStop` | Detiene la lectura en curso |

`<leader>tvb` inicia la lectura desde el bloque más cercano al cursor. Cada `<leader>tvp` sube un nivel hasta leer el archivo; después anuncia «No existen más niveles de anidación». Mover el cursor o editar el texto reinicia el recorrido desde la posición actual. Sin un parser de Treesitter, se lee la línea actual.

### Lectura de notificaciones

`<leader>tvn` o `:TennantNotify` abre una ventana temporal, anuncia el total de notificaciones capturadas durante la sesión y lee la primera, en orden de llegada. Presiona `n` para leer la siguiente y `x` para cancelar, detener la voz y cerrar la ventana. `Esc`, `:TennantStop` y `<leader>tvs` también cancelan. Al terminar, se anuncia que no hay más notificaciones; `x` cierra la ventana. Tus atajos habituales se conservan fuera de ella. Las notificaciones nuevas se incluyen al iniciar otro recorrido; el historial se conserva hasta cerrar Neovim.

### Bloques reconocidos por Treesitter

Cuando Treesitter está disponible, `:TennantBlock` identifica y anuncia el tipo de bloque:
`función`, `método`, `función flecha`, `variable`, `constante`, `clase`, `bloque if`, `bucle for`, `bucle while`, `bloque try`, `retorno`, `importación`, `exportación`.

---

## English

### What is it?

`tennant.nvim` is a Neovim plugin that converts text to speech using each operating system's native TTS engine: `say` on macOS, PowerShell on Windows, and `spd-say` / `espeak-ng` / `espeak` / `festival` on Linux. No external Lua dependencies or paid APIs required.

### Requirements

| Platform | Requirement |
|----------|-------------|
| **macOS** | `say` (built-in) |
| **Linux** | `spd-say`, `espeak-ng`, `espeak` or `festival` (any one) |
| **Windows** | PowerShell + .NET Framework (built-in) |
| **Neovim** | >= 0.12 |
| **Treesitter** | Optional — improves block reading by type |

### Installation

#### lazy.nvim (recommended)

```lua
{
  'themakunga/tennant.nvim',
  event = 'VeryLazy',
  opts = {
    -- prefix = '<leader>tv', -- default prefix
  },
}
```

#### packer.nvim

```lua
use {
  'themakunga/tennant.nvim',
  config = function()
    require('tennant').setup()
  end,
}
```

#### vim-plug

```vim
Plug 'themakunga/tennant.nvim'
```

Then in your config:

```lua
require('tennant').setup()
```

#### vim packages (`:h packages`)

```bash
mkdir -p ~/.local/share/nvim/site/pack/plugins/start
git clone https://github.com/themakunga/tennant.nvim \
  ~/.local/share/nvim/site/pack/plugins/start/tennant.nvim
```

Add to your `init.lua`:

```lua
require('tennant').setup()
```

#### rocks.nvim

```lua
-- in your rocks.toml
[plugins]
"tennant.nvim" = "scm"
```

Or in your config:

```lua
require('rocks').install('tennant.nvim')
```

### Configuration

```lua
require('tennant').setup({
  prefix = '<leader>tv',
  language = 'en', -- 'es' (default) or 'en'
})
```

Set `language = 'en'` for English announcements, spoken labels, and command/keymap descriptions. Spanish (`'es'`) remains the default. File contents and external notifications are read without translation. Voice and pronunciation follow your system TTS configuration; select an English voice in that engine for English speech.

### Keymaps

With the default prefix `<leader>tv`:

| Key | Action |
|-----|--------|
| `<leader>tvw` | Read word under cursor |
| `<leader>tvl` | Read current line |
| `<leader>tvl` (Visual mode) | Read selected text (`v`, `V`, or `Ctrl-v`) |
| `<leader>tvb` | Read the full nearest block (uses Treesitter if available) |
| `<leader>tvp` | Move up and read the enclosing block |
| `<leader>tvn` | Read notifications |
| `<leader>tvs` | Stop speaking |

### Commands

| Command | Description |
|---------|-------------|
| `:TennantWord` | Read word under cursor |
| `:[range]TennantLine` | Read current line or the given range (for example, `:2,5TennantLine`) |
| `:TennantBlock` | Read the full nearest block |
| `:TennantParent` | Move up and read the enclosing block |
| `:TennantNotify` | Read notifications |
| `:TennantStop` | Stop current speech |

`<leader>tvb` starts at the nearest block to the cursor. Each `<leader>tvp` moves up one level through the whole file, then announces “No more nesting levels” when configured in English. Moving the cursor or editing text restarts traversal from the current position. Without a Treesitter parser, reading falls back to the current line.

### Reading notifications

`<leader>tvn` or `:TennantNotify` opens a temporary window, announces the number of notifications captured during the session, and reads the first in arrival order. Press `n` for the next notification or `x` to cancel, stop speech, and close the window. `Esc`, `:TennantStop`, and `<leader>tvs` also cancel. The last notification announces the end; `x` closes the window. Your usual mappings remain intact outside it. New arrivals are included when starting another traversal; history is retained until Neovim exits.

### Treesitter block types

When Treesitter is available, `:TennantBlock` identifies and announces the block type:
`function`, `method`, `arrow function`, `variable`, `constant`, `class`, `if block`, `for loop`, `while loop`, `try block`, `return`, `import`, `export`.

---

## License

MIT
