;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq doom-theme 'kanagawa-dragon)
(setq doom-font (font-spec :family "IosevkaTerm Nerd Font Mono" :size 14))
(setq display-line-numbers-type 'relative)

;; Org paths (set these before org loads)
(setq org-directory "~/org"
      org-roam-directory (file-truename "~/org/roam"))

;; Optional: org-roam only handles .org in v2; no need to set this.
;; (setq org-roam-file-extensions '("org"))

;; Display template: title + tags (avoid ${type:15})
(setq org-roam-node-display-template
      (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))

(setq org-roam-capture-templates
      '(("m" "main" plain "%?"
         :if-new (file+head "main/${slug}.org" "#+title: ${title}\n")
         :immediate-finish t :unnarrowed t)
        ("r" "reference" plain "%?"
         :if-new (file+head "reference/${title}.org" "#+title: ${title}\n")
         :immediate-finish t :unnarrowed t)
        ("a" "article" plain "%?"
         :if-new (file+head "articles/${title}.org"
                            "#+title: ${title}\n#+filetags: :article:\n")
         :immediate-finish t :unnarrowed t)
        ("d" "default" plain "%?"
         :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
         :unnarrowed t)))

;; org-roam
(use-package! org-roam
  :custom
  (org-roam-directory (file-truename "~/org/roam"))
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n g" . org-roam-graph)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture)
         ("C-c n j" . org-roam-dailies-capture-today))
  :config
  (setq org-roam-node-display-template
        (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
  (org-roam-db-autosync-mode)
  (require 'org-roam-protocol))

;; org-roam-ui (ensure `websocket` & `org-roam-ui` are in packages.el)
(use-package! org-roam-ui
  :after org-roam
  :hook (org-roam-db-autosync-mode . org-roam-ui-mode)  ;; works in v2
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t))

;; vterm (usually provided by :term vterm in Doom; keep only if you need it)
(use-package! vterm
  :commands vterm)
