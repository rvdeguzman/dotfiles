;;; doom-dark-funeral-theme.el --- Dark Funeral Black Metal Theme -*- lexical-binding: t; no-byte-compile: t; -*-
;;
;; Author: Generated from dark-funeral theme
;; Created: September 9, 2025
;; Version: 1.0.0
;; Keywords: custom themes, faces
;; Homepage: https://github.com/doomemacs/themes
;; Package-Requires: ((emacs "25.1") (cl-lib "0.5") (doom-themes "2.2.1"))
;;
;;; Commentary:
;;
;; Dark Funeral theme inspired by black metal aesthetics
;; Blue/orange color scheme with pure black background
;;
;;; Code:

(require 'doom-themes)

;;
;;; Variables

(defgroup doom-dark-funeral-theme nil
  "Options for the `doom-dark-funeral' theme."
  :group 'doom-themes)

(defcustom doom-dark-funeral-brighter-modeline nil
  "If non-nil, more vivid colors will be used to style the mode-line."
  :group 'doom-dark-funeral-theme
  :type 'boolean)

(defcustom doom-dark-funeral-brighter-comments nil
  "If non-nil, comments will be highlighted in more vivid colors."
  :group 'doom-dark-funeral-theme
  :type 'boolean)

;;
;;; Theme definition

(def-doom-theme doom-dark-funeral
  "A dark theme inspired by Dark Funeral's black metal aesthetics."

  ;; name        default   256       16
  ((bg         '("#000000" nil       nil            ))   ; Pure black background
   (bg-alt     '("#000000" nil       nil            ))   ; Dark blue alternate background
   (base0      '("#000000" "black"   "black"        ))
   (base1      '("#1e1e1e" "#1e1e1e" "brightblack"  ))
   (base2      '("#2e2e2e" "#2e2e2e" "brightblack"  ))
   (base3      '("#262626" "#262626" "brightblack"  ))
   (base4      '("#3f3f3f" "#3f3f3f" "brightblack"  ))
   (base5      '("#525252" "#525252" "brightblack"  ))
   (base6      '("#6c6c6c" "#6c6c6c" "brightblack"  ))
   (base7      '("#979797" "#979797" "brightblack"  ))
   (base8      '("#dfdfdf" "#dfdfdf" "white"        ))
   (fg         '("#c1c1c1" "#c1c1c1" "brightwhite"  ))   ; Main foreground
   (fg-alt     '("#5f8787" "#5f8787" "white"        ))   ; Alt highlight color

   (grey       base4)
   (red        '("#5f8787" "#5f8787" "red"          ))   ; Diagnostic red
   (orange     '("#aaaaaa" "#aaaaaa" "brightred"    ))   ; Numbers
   (green      '("#6e4c4c" "#6e4c4c" "green"        ))   ; Diagnostic green
   (teal       '("#5f8787" "#5f8787" "brightgreen"  ))   ; Alt color
   (yellow     '("#888888" "#888888" "yellow"       ))   ; Functions
   (blue       '("#aaaaaa" "#aaaaaa" "brightblue"   ))   ; Constants
   (dark-blue  '("#999999" "#999999" "blue"         ))   ; Keywords
   (magenta    '("#d0dfee" "#d0dfee" "brightmagenta"))   ; Types (light blue accent)
   (violet     '("#fbcb97" "#fbcb97" "magenta"      ))   ; Strings (warm orange accent)
   (cyan       '("#fbcb97" "#fbcb97" "brightcyan"   ))
   (dark-cyan  '("#505050" "#505050" "cyan"         ))   ; Comments

   ;; face categories -- required for all themes
   (highlight      magenta)
   (vertical-bar   (doom-darken base1 0.1))
   (selection      '("#333333"))                          ; Visual selection
   (builtin        dark-blue)                            ; Keywords
   (comments       (if doom-dark-funeral-brighter-comments dark-cyan base5))
   (doc-comments   (doom-lighten (if doom-dark-funeral-brighter-comments dark-cyan base5) 0.25))
   (constants      blue)                                 ; Constants
   (functions      yellow)                               ; Functions
   (keywords       dark-blue)                            ; Keywords
   (methods        cyan)
   (operators      '("#9b99a3"))                         ; Operators
   (type           magenta)                              ; Types
   (strings        violet)                               ; Strings
   (variables      fg)                                   ; Properties/variables
   (numbers        orange)                               ; Numbers
   (region         selection)
   (error          red)
   (warning        '("#5f8787"))                         ; Diagnostic yellow mapped to alt
   (success        green)
   (vc-modified    orange)
   (vc-added       green)
   (vc-deleted     red)

   ;; custom categories
   (hidden     `(,(car bg) "black" "black"))
   (-modeline-dark doom-dark-funeral-brighter-modeline)
   (-modeline-pad
    (when doom-dark-funeral-brighter-modeline 4))

   (modeline-fg     fg)
   (modeline-fg-alt base5)

   (modeline-bg
    (if -modeline-dark
        (doom-darken blue 0.475)
      `(,(doom-darken (car bg-alt) 0.15) ,@(cdr base0))))
   (modeline-bg-l
    (if -modeline-dark
        (doom-darken blue 0.45)
      `(,(doom-darken (car bg-alt) 0.1) ,@(cdr base0))))
   (modeline-bg-inactive   `(,(doom-darken (car bg-alt) 0.1) ,@(cdr bg-alt)))
   (modeline-bg-inactive-l `(,(car bg-alt) ,@(cdr base1))))

  ;;; Base theme face overrides
  (((line-number &override) :foreground base4)
   ((line-number-current-line &override) :foreground fg)
   ((font-lock-comment-face &override)
    :background (if doom-dark-funeral-brighter-comments (doom-lighten bg 0.05)))
   (mode-line
    :background modeline-bg :foreground modeline-fg
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg)))
   (mode-line-inactive
    :background modeline-bg-inactive :foreground modeline-fg-alt
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-inactive)))
   (mode-line-emphasis
    :foreground (if -modeline-dark base8 highlight))

   ;;; Syntax highlighting
   (font-lock-keyword-face       :foreground keywords)
   (font-lock-type-face          :foreground type)
   (font-lock-builtin-face       :foreground builtin)
   (font-lock-function-name-face :foreground functions)
   (font-lock-variable-name-face :foreground variables)
   (font-lock-string-face        :foreground strings)
   (font-lock-comment-face       :foreground comments)
   (font-lock-constant-face      :foreground constants)
   (font-lock-warning-face       :foreground warning)

   ;;; Doom modeline
   (doom-modeline-bar :background (if -modeline-dark modeline-bg highlight))
   (doom-modeline-buffer-file :inherit 'mode-line-buffer-id :weight 'bold)
   (doom-modeline-buffer-path :inherit 'mode-line-emphasis :weight 'bold)
   (doom-modeline-buffer-project-root :foreground green :weight 'bold)

   ;;; Dashboard (Doom Emacs home screen) - toned down colors
   (doom-dashboard-banner :foreground magenta)           ; ASCII art - muted gray instead of colored
   (doom-dashboard-menu-title :foreground fg)         ; Menu items - normal foreground
   (doom-dashboard-menu-desc :foreground base5)       ; Descriptions - subtle gray
   (doom-dashboard-footer-icon :foreground base5)     ; Footer icons
   (doom-dashboard-loaded :foreground base6)          ; "Loaded X packages" text

   ;;; Cursor - make it more visible
   (cursor :background fg)                             ; Light gray cursor
   )
  ;;; Base theme variable overrides
  ;; ()
  )

;;; doom-dark-funeral-theme.el ends here
