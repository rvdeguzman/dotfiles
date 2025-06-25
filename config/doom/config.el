;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-gruvbox)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.


(setq display-line-numbers-type 'relative)

(use-package! pulse
  :config
  (setq pulse-flag t)
  (setq pulse-delay 0.04)

  (defun my/pulse-yank ()
    "Pulse the yanked region."
    (when (and pulse-flag (use-region-p))
      (pulse-momentary-highlight-region (point) (mark t))))

  (advice-add 'yank :after #'my/pulse-yank)
  (advice-add 'yank-pop :after #'my/pulse-yank))

(use-package! org-download
  :after org
  :config
  (add-hook 'dired-mode-hook 'org-download-enable))

(after! org
  (setq org-format-latex-options
        (plist-put org-format-latex-options :scale 1.6))
  (setq org-preview-latex-default-process 'dvisvgm))

(after! org-modern
  (setq org-modern-star nil
        org-modern-list nil
        org-modern-checkbox nil
        org-modern-priority nil
        org-modern-horizontal-rule nil
        org-modern-internal-target nil
        org-modern-radio-target nil
        org-modern-replace-stars nil
        org-modern-fold-stars nil

        org-modern-table t
        org-modern-table-vertical 3
        org-modern-table-horizontal 0.1
        org-modern-timestamp t
        org-modern-todo t
        org-modern-tag t
        org-modern-keyword t
        org-modern-block-name t
        org-modern-block-fringe t
        org-modern-progress 12
        org-modern-footnote nil

        org-modern-label-border 'auto
        org-modern-hide-stars 'leading))


(setq confirm-kill-emacs nil)

