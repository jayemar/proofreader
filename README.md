# Proofreader
*Proofreader* is an Emacs package to help recognize common mistakes when writing. It's intended to be used as a buffer-local minor mode that can be enabled and disabled by running `proofreader-mode`.

Proofreader search for and highlights the following features in a document:
1. incorrect spelling (via flyspell)
2. use of the passive voice
3. weasel words (words that sound good with conveying information)
4. duplicate words

Each of these can be enabled or disabled as desired.

## Installation
Place `proofreader.el` in your Emacs load path and add:

```elisp
(require 'proofreader)

## Customization
Proofreader ships with default values that should make it usable out of the box. However,
you can customize highlighting faces and word lists by customizing the group:
```elisp
M-x customize-group RET proofreader RET
```
If using files for custom word lists, each word or phrase should be placed on its own line.

## Customization
### Spelling
Proofreader uses flyspell to highlight misspelled words.  This can be disabled by setting `proofreader-check-spelling` to nil.

### Passive Voice
Proofreader attempts to recognize and highlight phrases that use the passive voice.  This functionality can be disbaled by setting `proofreader-check-for-passive-voice` to nil.

The words lists used to recognize passive voice can be customized by configuring the values of `proofreader-irregular-words` and/or `proofreader-auxiliary-verbs`, or by using word files specified by `proofreader-irregular-words-file` and `proofreader-auxiliary-verbs-file`.

### Weasel Words
The phrase "weasel words" here indicates phrases or words that sound good without conveying information.  Proofreader highlights these weasel words.  This functionality can be disabled by setting `proofreader-check-for-weasel-words` to nil.

The list of recognized weasel words can be customized by configuring the values of `proofreader-weasel-words`, or by using a word file specified by `proofreader-weasel-words-file`.

### Duplicate Words
Proofreader searches for and highlights multiple occurrences of the same word used next to each other.  This functionality can be disabled by setting `proofreader-check-for-double-words` to nil.

