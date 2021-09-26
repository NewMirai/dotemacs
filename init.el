(setq inhibit-startup-message t)

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(setq split-width-threshold 0) ;Default split is right window
(menu-bar-mode -1)            ; Disable the menu bar

(column-number-mode)

(defun my_starters_hook ()
  "Hooks to trigger at startup."
  (toggle-frame-fullscreen))

(add-hook 'after-init-hook 'my_starters_hook)

(defun display-line-numbers-custom-hook ()
  "Hook to enable relative line numbers in some modes."
  (display-line-numbers-mode 'relative))

(add-hook (or 'prog-mode-hook 'text-mode-hook) 'display-line-numbers-custom-hook)

(setq make-backup-files nil) ; remove backup files
;; Set up the visible bell
(setq visible-bell t)

(set-face-attribute 'default nil :font "Fira Code" :height 140)

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024))

(setq lsp-keymap-prefix "C-c l")

;; Only for text
(add-hook 'text-mode-hook #'abbrev-mode)

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
 (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
   (package-install 'use-package))

(require 'use-package)

;; Install quelpa
(use-package quelpa
  :ensure t)

(use-package vterm
    :ensure t)

(use-package all-the-icons
  :ensure t)

(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package doom-themes
  :ensure t
  :config
  (load-theme 'doom-solarized-dark-high-contrast t)
  (doom-themes-org-config))

(use-package webjump
  :custom
  (webjump-sites '(("Github" . "https://github.com/NewMirai")
      ("Web search[Startpage]" .
       [simple-query "www.startpage.com" "https://www.startpage.com/do/search?q=" ""])
      ("Youtube search" .
       [simple-query "www.youtube.com" "https://www.youtube.com/results?search_query=" ""])
      ("StackOverflow" .
       [simple-query "www.stackoverflow.com" "https:://www.stackoverflow.com/search?q=" ""])))
  :bind ("C-c j" . webjump))

(use-package pdf-tools-install
  :ensure pdf-tools
  :if (display-graphic-p)
  :mode "\\.pdf\\'"
  :commands (pdf-loader-install)
  :custom
  (TeX-view-program-selection '((output-pdf "pdf-tools")))
  (TeX-view-program-list '(("pdf-tools" "TeX-pdf-tools-sync-view")))
  :hook
  (pdf-view-mode . (lambda () (display-line-numbers-mode -1)))
  :config
  (pdf-loader-install))

;; Org mode latest version
(use-package org
  :ensure t)

;; org-babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '(( emacs-lisp . t)
   (python . t)))

(require 'org-tempo)
(add-to-list 'org-structure-template-alist '("sh" . "src shell"))
(add-to-list 'org-structure-template-alist '("ditaa" . "src ditaa"))
(add-to-list 'org-structure-template-alist '("py" . "src python"))
(add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))

(setq org-confirm-babel-evaluate nil)

;; org-bullet
(use-package org-bullets
  :ensure t
  :hook (org-mode . org-bullets-mode))

;; org-git
(use-package orgit
  :after magit
  :ensure t)

(use-package orgit-forge
  :after forge
  :ensure t)

(use-package ox-hugo
  :ensure t
  :after ox)

;; Activate dita
(org-babel-do-load-languages
 'org-babel-load-languages
 '((ditaa . t))) ; this line activates ditaa

(use-package which-key
   :ensure t
   :init (which-key-mode)
   :diminish which-key-mode
   :config
   (setq which-key-idle-delay 1))

(use-package selectrum
  :ensure t
  :config
  (selectrum-mode +1)
  (setq selectrum-refine-candidates-function #'orderless-filter)
  (setq orderless-skip-highlighting (lambda () selectrum-is-active))
  (setq selectrum-highlight-candidates-function #'orderless-highlight-matches))

;; Enable richer annotations using the Marginalia package
(use-package marginalia
  :ensure t
  :bind (("M-A" . marginalia-cycle)
	 :map minibuffer-local-map
	 ("M-A" . marginalia-cycle))
  :init
  (marginalia-mode))

(marginalia-mode)

(use-package orderless
  :ensure t
  :custom (completion-styles '(orderless)))

;; Configuration for Consult
(use-package consult
  :ensure t
  :bind ("C-s" . consult-line))

(use-package embark
  :ensure t
  :bind
  (("C-S-a" . embark-act)
   ("C-h B" . embark-bindings))
  :init
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  (add-to-list 'display-buffer-alist
	       '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
		 nil
		 (window-parameters (mode-line-format . none)))))

(use-package embark-consult
  :ensure t
  :after (embark consult)
  :demand t ; only necessary if you have the hook below
  ;; if you want to have consult previews as you move around an
  ;; auto-updating embark collect buffer
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package projectile
   :ensure t
   :diminish projectile-mode
   :config (projectile-mode)
   ;; Python setup projects
   (projectile-register-project-type 'kedro '("pyproject.toml" "notebooks" "logs" "conf" "src" "setup.cfg" "docs")
			     :project-file "pyproject.toml"
			     :compile "kedro build-docs"
			     :install "kedro install --build-reqs"
			     :test "kedro test -vvv"
			     :run "kedro run"
			     :test-prefix "test_"
			     :package "kedro package")
   :custom ((projectile-completion-system 'default))
   :bind-keymap
   ("C-c p" . projectile-command-map))

;; Git setup
(use-package magit
  :ensure t)

(use-package forge
  :after magit
  :ensure t)

(use-package orgit
  :after magit
  :ensure t)

(use-package orgit-forge
  :after forge
  :ensure t)

;; LSP mode
(use-package lsp-mode
  :ensure t
  :custom
  (lsp-headerline-breadcrumb-enable nil)
  (lsp-signature-auto-activate nil)
  (lsp-signature-render-documentation nil)
  (lsp-enable-file-watchers nil)
  (lsp-log-io nil)
  (lsp-rust-analyzer-cargo-watch-command "clippy")
  (lsp-rust-analyzer-server-display-inlay-hints t) 
  :hook (python-mode . lsp)
	 (c-mode . lsp)
	 (c++-mode . lsp)
	 (ess-r-mode . lsp)
	 (inferior-ess-r-mode . lsp)
	 (objc-mode . lsp)
	 (cuda-mode . lsp)
	 (go-mode . lsp)
	 (latex-mode . lsp)
	 (lsp-enable-which-key-integration . lsp)
  :commands lsp)

;; LSP UI
(use-package lsp-ui
  :ensure t
  :custom
  (lsp-ui-sideline-show-hover nil)
  (lsp-ui-doc nil))  

;; dap-mode
(use-package dap-mode
  :ensure t
  :config
  (dap-mode 1)
  (dap-ui-mode 1)
  (dap-tooltip-mode 1)
  (tooltip-mode 1)
  (dap-ui-controls-mode 1)
  ;; dap-cpp-c-rust
  (require 'dap-lldb)
  (require 'dap-gdb-lldb)
  (dap-register-debug-template
   "Rust::LLDB Run Configuration"
   (list :type "lldb"
	 :request "launch"
	 :name "LLDB::Run"
	 :gdbpath "rust-lldb"
	 :target nil
	 :cwd nil))
  (dap-register-debug-template
   "Rust::GDB Run Configuration"
   (list :type "gdb"
	 :request "launch"
	 :name "GDB::Run"
	 :gdbpath "home/alangel/.cargo/bin/rust-gdb"
	 :target nil
	 :cwd nil))
  ;; dap-python
  (require 'dap-python)
  (setq dap-python-debugger 'debugpy)
  ;; dap-go
  (require 'dap-go))

(use-package company
  :ensure t
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :ensure t
  :hook (company-mode . company-box-mode))

;; flycheck
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

;; Python setup
(use-package python
  :ensure t
  :custom
  (python-shell-interpreter "python")
  (python-shell-interpreter-args "-i")
  (python-indent-offset 4))

(use-package pyenv-mode
  :ensure t)
(pyenv-mode)

(require 'pyenv-mode)

(defun projectile-pyenv-mode-set ()
  "Set pyenv version matching project name."
  (let ((project (projectile-project-name)))
    (if (member project (pyenv-mode-versions))
	(pyenv-mode-set project)
      (pyenv-mode-unset))))

(add-hook 'projectile-after-switch-project-hook 'projectile-pyenv-mode-set)

(use-package lsp-pyright
 :ensure t
 :custom
 (setq lsp-pyright-auto-import-completions t)
 (setq lsp-pyright-diagnostic-mode "workspace")
 (setq lsp-pyright-typechecking-mode "basic")
 :hook (python-mode . (lambda ()
			   (require 'lsp-pyright)
			   (lsp))))

(use-package ess
  :ensure t
  :custom
  (ess-history-file nil)
  (ess-style 'Rstudio)
  (ess-source-directory (lambda()
			  (concat ess-directory "src/")))
  :config
  (require 'ess-r-mode)
  (define-key ess-r-mode-map "C-c C-=" 'ess-cycle-assign)
  (define-key inferior-ess-r-mode-map "C-c C-=" 'ess-cycle-assign))

(use-package ccls
  :ensure t
  :after lsp
  :custom (setq ccls-executable "ccls")
  :hook ((c-mode c++-mode objc-mode cuda-mode) .
	 (lambda () (require 'ccls) (lsp))))

(use-package rustic
  :ensure t
  :config
  ;; comment to disable rustfmt on save
  (setq rustic-format-on-save t))

(use-package go-mode
  :ensure t)

(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

(provide 'gopls-config)

(use-package julia-mode
  :ensure t)

(use-package julia-repl
  :ensure t
  :after julia-mode
  :hook
  (julia-mode . julia-repl-mode)
  :config
  (julia-repl-set-terminal-backend 'vterm)
  (setq vterm-kill-buffer-on-exit nil))

;; Vim keys
(use-package evil
  :ensure t ;; install the evil package if not installed
  :init ;; tweak evil's configuration before loading it
  (setq evil-search-module 'evil-search)
  (setq evil-ex-complete-emacs-commands nil)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-below t)
  (setq evil-shift-round nil)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  :config ;; tweak evil after loading it
  (evil-mode)

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init)))

(defun evil-collection-vterm-escape-stay ()
"Go back to normal state but don't move
cursor backwards. Moving cursor backwards is the default vim behavior but it is
not appropriate in some cases like terminals."
(setq-local evil-move-cursor-back nil))

(add-hook 'vterm-mode-hook #'evil-collection-vterm-escape-stay)

(use-package yasnippet
 :ensure t
 :hook ((text-mode
	 prog-mode
	 conf-mode
	 snippet-mode) . yas-minor-mode-on)
 :init
 (setq yas-snippet-dir "~/.emacs.d/snippets"))

(use-package yasnippet-snippets
  :ensure t)

(use-package tex :defer t :ensure auctex :config (setq TeX-auto-save t))

(use-package exec-path-from-shell
  :ensure t)

(global-set-key (kbd "C-c c") 'shell-command)

(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))

(use-package yaml-mode
  :ensure t)

(add-hook 'yaml-mode-hook
	  '(lambda ()
	     (define-key yaml-mode-map "\C-m" 'newline-and-indent)))
