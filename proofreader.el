;;; proofreader --- Proof-reading tool for Eamcs -*- coding: utf-8; lexical-binding: t; -*-

;; Copyright (c) 2024 Joe Reinhart <joseph.reinhart@gmail.com>

;; Author: Joe Reinhart
;; URL: https://github.com/jayemar/proofreader
;; Keywords: proofreader, writing
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

;;;###autoload
(define-minor-mode proofreader-mode
  "Toggle minor mode `proofreader-mode' on and off."
  :init-value nil
  :lighter " pf")

(defun proofreader--list-to-or-regex (l)
  "Return a regex string that ORs the items in the list L."
  (string-join (seq-map (lambda (i) (prin1-to-string i t)) l) "\\|"))

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
  "List words or phrases that sound good without conveying information"
  :group 'proofreader
  :type '(repeat string))

(defvar proofreader-weasel-regex
  (proofreader--list-to-or-regex proofreader-weasel-words)
  "Regex string to use use when searching for weasel words")

(defun proofreader-highlight-weasel-words ()
  "Highlight weasel words found in buffer."
  (interactive)
  (highlight-regexp proofreader-weasel-regex 'highlight))


;;
;; Passive voice
;;

(defcustom proofreader-irregulars
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

(defcustom proofreader-morningstars
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


;; egrep -n -i --color \
;;  "\\b(am|are|were|being|is|been|was|be)\
;; \\b[ ]*(\w+ed|($irregulars))\\b" $*

(defvar proofreader-passive-voice-regex
  (let ((p1 (proofreader--list-to-or-regex proofreader-morningstars))
        (p2 (proofreader--list-to-or-regex proofreader-irregulars)))
    (format "\\b\\(%s\\)\\b[[:space:]]*\\(\\w+ed\\|\\(?:%s\\)\\)\\b" p1 p2)))

(defun proofreader-highlight-passive-voice ()
  "Highlight phrases using the passive voice."
  (interactive)
  (highlight-regexp proofreader-passive-voice-regex 'idle-highlight))


;;
;; Double words
;;

(defun proofreader-highlight-repeated-words ()
  "Highlight instances where the same word appears twice in succession."
  (interactive)
  (highlight-regexp "\\(\\<\\w+\\>\\)\\s-*\n?\\s-*\\1\\>" 'isearch-fail))


;;
;; Final Configuration
;;

(defun proofreader-start ()
  "Begin active proofreading of text in buffer."
  (interactive)
  (proofreader-highlight-weasel-words)
  (proofreader-highlight-passive-voice)
  (proofreader-highlight-repeated-words))

(defun proofreader-quit ()
  "Stop active proofreader features."
  (interactive)
  ;; (unhighlight-regexp proofreader-weasel-regex)
  (unhighlight-regexp t))

(defalias 'proofreader-stop 'proofreader-quit)

(provide 'proofreader)
;;; proofreader.el ends here
