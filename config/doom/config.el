;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
 (setq user-full-name "rvdeguzman"
       user-mail-address "rvdeguzman@gmail.com")

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
;; config.el
;; Keep your existing configuration at the top...

;; First, set up the basic org configuration
(setq org-directory "~/school/org/")

;; Set up org-roam configuration in a single place to avoid duplicates
(after! org-roam
  ;; Set the directory where your notes will live
  ;; (setq org-roam-directory (file-truename "~/notes/roam"))
  (setq org-roam-directory (file-truename "~/school/roam"))
  
  ;; Explicitly set the database location
  ;; (setq org-roam-db-location (file-truename "~/notes/roam/org-roam.db"))
  (setq org-roam-db-location (file-truename "~/school/roam/org-roam.db"))

  (setq org-roam-capture-templates
      '(("d" "default" plain
         "%?"
         :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                           "#+title: ${title}\n#+date: %U\n#+filetags: \n\n")
         :unnarrowed t)
        ("r" "reference" plain
         "%?"
         :target (file+head "references/${slug}.org"
                           "#+title: ${title}\n#+date: %U\n#+filetags: :reference:\n\n")
         :unnarrowed t)
        ("l" "lecture" plain
         "%?"
         :target (file+head "${course}/lectures/${slug}.org"
                           "#+title: ${title}\n#+date: %<%Y-%m-%d>\n#+filetags: :lecture:\n\n* Key Points\n\n* Examples\n\n* Questions")
         :unnarrowed t
         :properties (("course" . "${course}")))
        ("c" "concept" plain
         "%?"
         :target (file+head "${course}/concepts/${slug}.org"
                           "#+title: ${title}\n#+filetags: :concept:\n\n* Definition\n\n* Examples\n\n* Related Concepts")
         :unnarrowed t
         :properties (("course" . "${course}")))
        ("n" "new course" plain
         "%?"
         :target (file+head "${title}/index.org"
                           "#+title: ${title}\n#+filetags: :course:\n\n* Course Overview\n- Professor: \n- Schedule: \n- Office Hours: \n\n* Key Topics\n\n* Assignments & Due Dates\n\n* Resources\n\n* Lectures\n\n* Important Concepts")
         :unnarrowed t)))
  ;;  (setq org-roam-capture-templates
;;      '(("d" "default" plain
;;         "%?"
;;         :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
;;                           "#+title: ${title}\n#+date: %U\n#+filetags: \n\n")
;;         :unnarrowed t)
;;        ("r" "reference" plain
;;         "%?"
;;         :target (file+head "references/${slug}.org"
;;                           "#+title: ${title}\n#+date: %U\n#+filetags: :reference:\n\n")
;;         :unnarrowed t)
;;        ("l" "lecture" plain
;;         "%?"
;;         :target (file+head "${course}/lectures/${slug}.org"
;;                           "#+title: ${title}\n#+date: %<%Y-%m-%d>\n#+filetags: :${course}:lecture:\n\n* Key Points\n\n* Examples\n\n* Questions")
;;         :unnarrowed t)
;;        ("c" "concept" plain
;;         "%?"
;;         :target (file+head "${course}/concepts/${slug}.org"
;;                           "#+title: ${title}\n#+filetags: :${course}:concept:\n\n* Definition\n\n* Examples\n\n* Related Concepts")
;;         :unnarrowed t)
;;        ("n" "new course" plain
;;         "%?"
;;         :target (file+head "${course}/index.org"
;;                           "#+title: ${title}\n#+filetags: :${course}:course:\n\n* Course Overview\n- Professor: \n- Schedule: \n- Office Hours: \n\n* Key Topics\n\n* Assignments & Due Dates\n\n* Resources\n\n* Lectures\n\n* Important Concepts")
;;         :unnarrowed t)))
  ;; Set up capture templates for creating new notes
;;  (setq org-roam-capture-templates
;;        '(("d" "default" plain
;;           "%?"
;;           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
;;                             "#+title: ${title}\n#+date: %U\n#+filetags: \n\n")
;;           :unnarrowed t)
;;          ("r" "reference" plain
;;           "%?"
;;           :target (file+head "references/${slug}.org"
;;                             "#+title: ${title}\n#+date: %U\n#+filetags: :reference:\n\n")
;;           :unnarrowed t)))
;;        '(("l" "lecture" plain
;;        "%?"
;;        :if-new (file+head "${course}/lectures/${slug}.org"
;;                                "#+title: ${title}\n#+date: %<%Y-%m-%d>\n#+filetags: :${course}:lecture:\n\n* Key Points\n\n* Examples\n\n* Questions")
;;        :unnarrowed t)
;;        '(("c" "concept" plain
;;        "%?"
;;        :if-new (file+head "${course}/concepts/${slug}.org"
;;                                "#+title: ${title}\n#+filetags: :${course}:concept:\n\n* Definition\n\n* Examples\n\n* Related Concepts")
;;        :unnarrowed t)))

  ;; Configure the display template for better completion
  (setq org-roam-node-display-template
        (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))

  ;; Set up the keybindings using Doom's map! macro
  (map! :leader
        :prefix "n"
        :desc "org-roam-buffer-toggle" "l" #'org-roam-buffer-toggle
        :desc "org-roam-node-find" "f" #'org-roam-node-find
        :desc "org-roam-graph" "g" #'org-roam-graph
        :desc "org-roam-node-insert" "i" #'org-roam-node-insert
        :desc "org-roam-capture" "c" #'org-roam-capture
        :desc "org-roam-dailies-capture-today" "j" #'org-roam-dailies-capture-today))

;; Keep your org-roam-ui configuration
 (use-package! org-roam-ui
   :after org-roam
   :config
   (setq org-roam-ui-sync-theme t
         org-roam-ui-follow t
         org-roam-ui-update-on-save t
         org-roam-ui-open-on-start t))
 
(set-default 'preview-scale-function 1.5)

(setq display-line-numbers 'relative)
(after! org
  (plist-put org-format-latex-options :scale 1.5))
;;(setq org-format-latex-options (plist-put org-format-latex-options :scale 2.0))
