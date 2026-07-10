;;; cli.el -*- lexical-binding: t; -*-

;; Keep Doom's generated env file focused on executable lookup state.
;; Doom loads this before `doom env` and `doom sync`, so future syncs won't
;; persist globally exported API keys/tokens from the shell environment.
(setq doom-env-deny '("."))
(setq doom-env-allow
      '("^PATH$"
        "^MANPATH$"
        "^INFOPATH$"
        "^LIBRARY_PATH$"
        "^SHELL$"
        "^BUN_INSTALL$"
        "^PNPM_HOME$"
        "^NVM_DIR$"
        "^NVM_BIN$"
        "^NVM_INC$"
        "^JAVA_HOME$"
        "^SDKMAN_DIR$"
        "^SDKMAN_CANDIDATES_DIR$"
        "^MAINICHI_DIR$"))
