;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; theme
(setq doom-theme 'doom-gruvbox)
(set-frame-parameter nil 'alpha '(95 . 95))
(add-to-list 'default-frame-alist '(alpha . (95 . 95)))

(setq-default tab-width 4)

(let ((local-bin (expand-file-name "~/.local/bin")))
  (when (file-directory-p local-bin)
    (add-to-list 'exec-path local-bin)
    (unless (member local-bin (parse-colon-path (or (getenv "PATH") "")))
      (setenv "PATH" (concat local-bin path-separator (or (getenv "PATH") ""))))))

(setq doom-font (font-spec :family "Iosevka Nerd Font Mono" :size 16))
(setq display-line-numbers-type 'relative)

;; Use Emacs for simple reading-oriented sites. Keep heavy JS sites external.
(setq browse-url-browser-function #'eww-browse-url)
(setq browse-url-handlers
      '(("https?://news\\.ycombinator\\.com" . eww-browse-url)
        ("https?://\\(www\\.\\)?reddit\\.com" . eww-browse-url)
        ("https?://old\\.reddit\\.com" . eww-browse-url)))

(after! eww
  (setq shr-width 100
        shr-use-colors nil
        shr-use-fonts nil
        eww-search-prefix "https://duckduckgo.com/html/?q="))

(defun my/open-hacker-news ()
  "Open Hacker News in EWW."
  (interactive)
  (eww "https://news.ycombinator.com"))

(defun my/open-reddit ()
  "Open old Reddit in EWW for a simpler, more reliable UI."
  (interactive)
  (eww "https://old.reddit.com"))

(after! neotree
  (setq neo-window-position 'right))

(after! corfu
  (setq corfu-auto-delay 0))

(setq org-directory "~/org")

;; org-roam capture templates
(setq org-roam-capture-templates
      '(("p" "Project" plain
         "* Elevator Pitch\n%?\n\n* Type\nSoftware / App / SaaS / Idea\n\n* Status\nActive / Paused / Completed / Idea\n\n* Tech Stack\n\n* Timesheet\n| Date | Hours | Notes |\n|------|-------|-------|\n\n* Next Steps\n\n* Notes\n"
         :if-new (file+head "projects/${title}.org"
                            "#+title: ${title}\n#+filetags: :project:\n")
         :immediate-finish t :unnarrowed t)
        ("c" "Class" plain
         "* Overview\n\n\
- Instructor :: \n\
- Semester :: \n\
- Schedule :: \n\
- Location :: \n\
\n\
* Syllabus\n\n\
\n\
* Important Dates\n\n\
\n\
* Assignments\n\n\
\n\
* Exams\n\n\
\n\
* Resources\n\n\
\n\
* Lecture Index\n"
         :if-new (file+head "classes/%<%Y>/${slug}.org"
                            "#+title: ${title}\n#+filetags: :class:\n")
         :immediate-finish t :unnarrowed t)
        ("l" "Lecture" plain
         "* %<%Y-%m-%d> — ${title}\n\n\
** Key Topics\n\
- \n\n\
** Notes\n\n\n\
** Questions\n\
- \n\n\
"
         :if-new (file+head "lectures/%<%Y-%m-%d>-${slug}.org"
                            "#+title: ${title}\n#+filetags: :lecture:\n")
         :immediate-finish t :unnarrowed t)
        ("o" "Concept" plain
         "* Notes\n%?\n\n* Summary\n\n\n* Definition\n\n* Key Points\n- \n\n* Related\n"
         :if-new (file+head "concepts/${slug}.org"
                            "#+title: ${title}\n#+filetags: :concept:\n")
         :immediate-finish t :unnarrowed t)
        ("r" "Reference" plain "%?"
         :if-new (file+head "reference/${title}.org"
                            "#+title: ${title}\n")
         :immediate-finish t :unnarrowed t)))

(defun my/open-daily-note ()
  "Open today's daily journal, creating it from template if new."
  (interactive)
  (let* ((dir (expand-file-name "journal/" org-directory))
         (file (expand-file-name (format-time-string "%Y-%m-%d.org") dir)))
    (unless (file-exists-p dir)
      (make-directory dir t))
    (find-file file)
    (when (= (buffer-size) 0)
      (insert (format-time-string
               "#+title: %Y-%m-%d\n#+filetags: :daily:\n\n* Timesheet\n| Task | Hours | Notes |\n|------|-------|-------|\n|      |       |       |\n\n* Notes\n")))))

;; org-roam
(use-package! org-roam
  :custom
  (org-roam-directory (file-truename "~/org/roam"))
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n g" . org-roam-graph)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture))
  :config
  (setq org-roam-node-display-template
        (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
  (org-roam-db-autosync-mode)
  (require 'org-roam-protocol))

(use-package! org-roam-ui
  :after org-roam
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t))

(after! org
  ;; agenda — targeted directories only
  (setq org-agenda-files
        (append (list (expand-file-name "habits.org" org-directory)
                      (expand-file-name "inbox.org" org-directory)
                      (expand-file-name "calendar.org" org-directory)
                      (expand-file-name "reminders.org" org-directory)
                      (expand-file-name "journal/" org-directory)
                      (expand-file-name "roam/projects/" org-directory))
                (directory-files-recursively
                 (expand-file-name "roam/classes/" org-directory)
                 "\\.org$")))

  ;; org-habit
  (add-to-list 'org-modules 'org-habit t)
  (setq org-habit-graph-column 60)

  ;; inline images
  ;; (setq org-startup-with-inline-images t)
  (add-hook 'org-mode-hook #'org-display-inline-images)

  ;; latex preview
  ;; (setq org-startup-with-latex-preview t)
  (setq org-preview-latex-default-process 'dvisvgm)
  (setq org-format-latex-options
        (plist-put org-format-latex-options :background "Transparent")))

(use-package! org-download
  :after org
  :config
  (kill-local-variable 'org-download-image-dir)
  (kill-local-variable 'org-download-heading-lvl)
  (setq-default org-download-image-dir "./.images")
  (setq-default org-download-heading-lvl nil)
  (setq org-download-method 'directory
        org-download-timestamp "_%Y%m%d_%H%M%S"
        org-download-link-format "[[file:.images/%s]]\n"
        org-download-annotate-function (lambda (_link) "")
        org-download-screenshot-method (if (eq system-type 'darwin)
                                           "screencapture -i %s"
                                         "grimblast save area %s"))
  (defun my/org-download-clipboard (&optional basename)
    "Paste clipboard image without creating a properties drawer or extra newlines."
    (interactive)
    (let ((org-download-link-format "[[file:.images/%s]]")
          (org-download-heading-lvl nil)
          (org-download-image-dir "./.images"))
      (cl-letf (((symbol-function 'org-id-get-create) #'ignore))
        (org-download-clipboard basename))))
  (map! :map org-mode-map "C-c i v" #'my/org-download-clipboard))

(use-package! kitty-graphics
  :if (and (not (display-graphic-p))
           (or (getenv "KITTY_PID")
               (getenv "WEZTERM_EXECUTABLE")
               (getenv "GHOSTTY_BIN_DIR")))
  :config
  (kitty-graphics-mode 1))

(add-load-path! "leetcode.el")

(use-package! leetcode
  :load-path "leetcode.el"
  :commands (leetcode)
  :init
  (setq leetcode-prefer-language "python3"
        leetcode-save-solutions t
        leetcode-directory (expand-file-name "~/leetcode/")
        leetcode-cache-file (expand-file-name ".local/cache/leetcode-problems.cache" doom-user-dir))
  :config
  (defun rv/leetcode-renew-session ()
    "Renew LeetCode session from browser cookies."
    (interactive)
    (aio-wait-for (leetcode--ensure-login t))
    (message "LeetCode session renewed from browser cookies."))

  (map! :leader
        :desc "Open LeetCode"
        "o l" #'leetcode
        :desc "Renew LeetCode session"
        "o L" #'rv/leetcode-renew-session))

(defun org-roam-capture-here ()
  "new org roam node in pwd"
  (interactive)
  (let ((org-roam-directory default-directory))
    (org-roam-capture)))

(map! :leader
      :desc "org-roam capture here"
      "n h" #'org-roam-capture-here)

(map! :leader
      :desc "Open daily note"
      "n d" #'my/open-daily-note)
(map! "C-c n d" #'my/open-daily-note)

(map! :n "C-h" #'evil-window-left
      :n "C-j" #'evil-window-down
      :n "C-k" #'evil-window-up
      :n "C-l" #'evil-window-right)

(after! org
  (map! :map org-mode-map
        :n "C-j" #'evil-window-down))

(map! :leader
      :prefix "w"
      "h" #'evil-window-split
      "v" #'evil-window-vsplit)

(map! :leader
      (:prefix ("o" . "open")
       :desc "Hacker News" "h" #'my/open-hacker-news
       :desc "Reddit" "r" #'my/open-reddit))

;; gptel — LLM integration
(load! "secrets.el" doom-user-dir t)

;; Neovim muscle-memory migration
;;
;; These bindings preserve the parts of the ~/.config/nvim workflow that have
;; clean Doom equivalents: project search, recent files, sidebar, symbol search,
;; and flash-style jumps.
(map! :n "C-q" #'save-buffers-kill-terminal
      :n "gO" #'consult-imenu
      :n "gW" #'consult-imenu-multi
      :n "gr" #'+lookup/references
      :n "gi" #'+lookup/implementations
      :n "[d" #'flycheck-previous-error
      :n "]d" #'flycheck-next-error
      :leader
      :desc "Project search" "," #'+default/search-project
      :desc "Recent project files" "." #'projectile-recentf
      :desc "Search current buffer" "/" #'+default/search-buffer
      :desc "Project sidebar" "e" #'+neotree/open
      :desc "Close window" "w d" #'delete-window
      :desc "Search help docs" "s h" #'info-apropos
      :desc "Search keybindings" "s k" #'helpful-key
      :desc "Document symbols" "s s" #'consult-imenu
      :desc "Syntax/tree symbols" "s t" #'consult-imenu
      :desc "Search symbol at point in project" "s w" #'+default/search-project-for-symbol-at-point
      :desc "Search project by grep" "s g" #'+default/search-project
      :desc "Search diagnostics" "s d" #'+default/diagnostics
      :desc "Resume minibuffer search" "s r" #'vertico-repeat
      :desc "Search commands" "s c" #'execute-extended-command
      :desc "Open Doom config" "s n" #'doom/find-file-in-private-config
      :desc "Workspace symbols" "w s" #'consult-imenu-multi)

(use-package! flash
  :commands (flash-jump flash-treesitter flash-evil-jump)
  :init
  (setq flash-multi-window t
        flash-char-jump-labels t)
  :config
  (require 'flash-isearch)
  (flash-isearch-mode 1)
  (require 'flash-evil)
  (evil-global-set-key 'normal (kbd "f") #'flash-evil-jump)
  (evil-global-set-key 'visual (kbd "f") #'flash-evil-jump)
  (evil-global-set-key 'motion (kbd "f") #'flash-evil-jump)
  (evil-global-set-key 'operator (kbd "f") #'flash-evil-jump))

(after! leetcode
  ;; leetcode.el installs its own evil local maps, which override global flash
  ;; bindings in the problem list/detail buffers.
  (define-key leetcode--problems-mode-map (kbd "f") #'flash-evil-jump)
  (define-key leetcode--problem-detail-mode-map (kbd "f") #'flash-evil-jump))


(map! :g "C-1" #'+workspace/switch-to-0
      :g "C-2" #'+workspace/switch-to-1
      :g "C-3" #'+workspace/switch-to-2
      :g "C-4" #'+workspace/switch-to-3
      :g "C-5" #'+workspace/switch-to-4
      :g "C-6" #'+workspace/switch-to-5
      :g "C-7" #'+workspace/switch-to-6
      :g "C-8" #'+workspace/switch-to-7
      :g "C-9" #'+workspace/switch-to-8
      :g "C-0" #'+workspace/switch-to-final)
