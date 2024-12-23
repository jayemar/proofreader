# Proofreader
`Proofreader` is an Emacs package to help recognize common mistakes when writing.

`Proofreader` is a buffer-local minor mode that can be enabled and disabled by running `proofreader-mode`.

This package ships with default values that should be adequate for many use cases.  However, customization is available to select which 

You can customize highlighting faces and word lists through:
```elisp
M-x customize-group RET proofreader RET
```

Word lists will be ingested and incorporated into a regular expression that *ORs* each value.  Each word of phrase should be placed on a new line.

## What is Checked?
### Spelling
`Proofreader` uses `flyspell` to highlight misspelled words.  This can be disabled by setting `proofreader-check-spelling` to `nil`.

### Passive Voice
`Proofreader` attempts to recognize and highlight phrases that use the passive voice.  This functionality can be disbaled by setting `proofreader-check-for-passive-voice` to `nil`.

### Weasel Words
`Proofreader` highlights so-called "weasel words".  This functionality can be disbaled by setting `proofreader-check-for-weasel-words` to `nil`.

### Duplicate Words
`Proofreader` searches for and highlights multiple occurrances of the same word used next to each other.  This functionality can be disabled by setting `proofreader-check-for-double-words` to `nil`.

## Installation
Place `proofreader.el` in your Emacs load path and add:

```elisp
(require 'proofreader)
```

## License

GPL-3.0
