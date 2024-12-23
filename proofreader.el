;;; proofreader.el --- Proof-reading tool for Eamcs -*- coding: utf-8; lexical-binding: t; -*-

;; Copyright (c) 2024 Joe Reinhart <joseph.reinhart@gmail.com>

;; Author: Joe Reinhart
;; URL: https://github.com/jayemar/proofreader
;; Keywords: wp, docs
;; Version: 0.1.0
;; Package-Requires: ((emacs "27.1"))
;; This file is NOT part of GNU Emacs.

;;; License:
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:
;; Proofreader provides tooling to help with proof-reading compositions.
;;
;; Heavily inspired by the blog and code from these articles:
;; https://simonwillison.net/2024/Dec/14/improve-your-writing/#atom-everything
;; https://matt.might.net/articles/shell-scripts-for-passive-voice-weasel-words-duplicates/

;;; Code:

(defun proofreader--read-file-list (file)
  "Read FILE and return phrase list."
  (when (and file (file-exists-p file))
    (with-temp-buffer
      (insert-file-contents file)
      (split-string (buffer-substring (point-min) (point-max)) "\n" t "\s*"))))

(defun proofreader--list-to-or-regex (l)
  "Return a regex string that ORs the items in the list L."
  (string-join (seq-map (lambda (i) (prin1-to-string i t)) l) "\\|"))

(defcustom proofreader-check-spelling t
  "If true, highlight misspelled words found in buffer."
  :group 'proofreader
  :type 'boolean)

(defcustom proofreader-check-for-weasel-words t
  "If true, highlight weasel words found in buffer."
  :group 'proofreader
  :type 'boolean)

(defcustom proofreader-check-for-passive-voice t
  "If true, highlight passages that use the passive voice in buffer."
  :group 'proofreader
  :type 'boolean)

(defcustom proofreader-check-for-double-words t
  "If true, highlight duplicated words found in buffer."
  :group 'proofreader
  :type 'boolean)

(defcustom proofreader-weasel-word-face 'highlight
  "Face to use to indicate weasel words."
  :group 'proofreader
  :type 'face)

(defcustom proofreader-passive-voice-face 'idle-highlight
  "Face to use to indicate uses of the passive voice."
  :group 'proofreader
  :type 'face)

(defcustom proofreader-double-word-face 'isearch-fail
  "Face to use to indicate double words."
  :group 'proofreader
  :type 'face)


;;
;; Weasel Words
;;

(defcustom proofreader-weasel-words
  '(clearly
    completely
    exceedingly
    excellent
    extremely
    fairly
    few
    huge
    interestingly
    largely
    many
    mostly
    quite
    relatively
    remarkably
    several
    significantly
    substantially
    surprisingly
    tiny
    various
    vast
    very
    "are a number"
    "is a number")
  "List words or phrases that sound good without conveying information."
  :group 'proofreader
  :type '(repeat string))

(defun proofreader-weasel-regex ()
  "Return the regex string used to recognize weasel words."
  (proofreader--list-to-or-regex proofreader-weasel-words))

(defun proofreader-highlight-weasel-words ()
  "Highlight weasel words found in buffer."
  (interactive)
  (highlight-regexp (proofreader-weasel-regex) proofreader-weasel-word-face))


;;
;; Passive voice
;;

(defcustom proofreader-irregular-words
  '(awoken
    been
    born
    beat
    become
    begun
    bent
    beset
    bet
    bid
    bidden
    bound
    bitten
    bled
    blown
    broken
    bred
    brought
    broadcast
    built
    burnt
    burst
    bought
    cast
    caught
    chosen
    clung
    come
    cost
    crept
    cut
    dealt
    dug
    dived
    done
    drawn
    dreamt
    driven
    drunk
    eaten
    fallen
    fed
    felt
    fought
    found
    fit
    fled
    flung
    flown
    forbidden
    forgotten
    foregone
    forgiven
    forsaken
    frozen
    gotten
    given
    gone
    ground
    grown
    hung
    heard
    hidden
    hit
    held
    hurt
    kept
    knelt
    knit
    known
    laid
    led
    leapt
    learnt
    left
    lent
    let
    lain
    lighted
    lost
    made
    meant
    met
    misspelt
    mistaken
    mown
    overcome
    overdone
    overtaken
    overthrown
    paid
    pled
    proven
    put
    quit
    read
    rid
    ridden
    rung
    risen
    run
    sawn
    said
    seen
    sought
    sold
    sent
    set
    sewn
    shaken
    shaven
    shorn
    shed
    shone
    shod
    shot
    shown
    shrunk
    shut
    sung
    sunk
    sat
    slept
    slain
    slid
    slung
    slit
    smitten
    sown
    spoken
    sped
    spent
    spilt
    spun
    spit
    split
    spread
    sprung
    stood
    stolen
    stuck
    stung
    stunk
    stridden
    struck
    strung
    striven
    sworn
    swept
    swollen
    swum
    swung
    taken
    taught
    torn
    told
    thought
    thrived
    thrown
    thrust
    trodden
    understood
    upheld
    upset
    woken
    worn
    woven
    wed
    wept
    wound
    won
    withheld
    withstood
    wrung
    written)
  "List of words to help recognize the passive voice."
  :group 'proofreader
  :type '(repeat string))

(defcustom proofreader-auxiliary-verbs
  '(am
    are
    is
    was
    were
    be
    being
    been
    have
    has
    had
    do
    does
    did
    shall
    will
    should
    would
    may
    might
    must
    can
    could
    seems
    appears)
  "Prefix words to use before the irregulars to recognize passive voice."
  :group 'proofreader
  :type '(repeat string))

(defun proofreader-passive-voice-regex ()
  "Return the regex string used to recognize use of the passive voice."
  (let ((p1 (proofreader--list-to-or-regex proofreader-auxiliary-verbs))
        (p2 (proofreader--list-to-or-regex proofreader-irregular-words)))
    (format "\\b\\(%s\\)\\b[[:space:]]*\\(\\w+ed\\|\\(?:%s\\)\\)\\b" p1 p2)))

(defun proofreader-highlight-passive-voice ()
  "Highlight phrases using the passive voice."
  (interactive)
  (highlight-regexp
   (proofreader-passive-voice-regex) proofreader-passive-voice-face))


;;
;; Double words
;;

(defun proofreader-highlight-repeated-words ()
  "Highlight instances where the same word appears twice in succession."
  (interactive)
  (highlight-regexp
   "\\(\\<\\w+\\>\\)\\s-*\n?\\s-*\\1\\>" proofreader-double-word-face))


;;
;; Final Configuration
;;

(defcustom proofreader-weasel-words-file nil
  "Location of file with values to override `proofreader-weasel-words'."
  :group 'proofreader
  :type 'file
  :initialize #'custom-initialize-reset
  :set (lambda (symbol value)
         (set-default symbol value)
         (when-let ((words (proofreader--read-file-list value)))
           (customize-set-value 'proofreader-weasel-words words))))

(defcustom proofreader-irregular-words-file nil
  "Location of file with values to override `proofreader-irregular-words'."
  :group 'proofreader
  :type 'file
  :initialize #'custom-initialize-reset
  :set (lambda (symbol value)
         (set-default symbol value)
         (when-let ((words (proofreader--read-file-list value)))
           (customize-set-value 'proofreader-irregular-words words))))

(defcustom proofreader-auxiliary-verbs-file nil
  "Location of file with values to override `proofreader-auxiliary-verbs'."
  :group 'proofreader
  :type 'file
  :initialize #'custom-initialize-reset
  :set (lambda (symbol value)
         (set-default symbol value)
         (when-let ((words (proofreader--read-file-list value)))
           (customize-set-value 'proofreader-auxiliary-verbs words))))

(defun proofreader-enable ()
  "Enable active proofreading of text in buffer."
  (interactive)
  (when proofreader-check-spelling
    (flyspell-buffer))
  (when proofreader-check-for-weasel-words
    (proofreader-highlight-weasel-words))
  (when proofreader-check-for-passive-voice
    (proofreader-highlight-passive-voice))
  (when proofreader-check-for-double-words
    (proofreader-highlight-repeated-words)))

(defun proofreader-disable ()
  "Disable active proofreader features."
  (interactive)
  (flyspell-mode-off)
  (unhighlight-regexp t))

;; Defined here so that it can be used by `proofreader--hook' before the
;; the call to `define-minor-mode' that would define the varirable.
(defvar proofreader-mode)

(defun proofreader--hook ()
  "Toggle proofreader mode from current state."
  (if proofreader-mode
      (proofreader-enable)
    (proofreader-disable)))

;;;###autoload
(define-minor-mode proofreader-mode
  "Toggle minor mode `proofreader-mode' on and off."
  :init-value nil
  ;; :lighter " pf"
  :after-hook (proofreader--hook)
  :keymap (make-sparse-keymap))

(provide 'proofreader)
;;; proofreader.el ends here
