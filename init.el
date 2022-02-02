;; Remove some stuff from UI & Startup
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 10)
(menu-bar-mode -1)
(setq visible-bell t)
(setq inhibit-startup-message -1)

;;##############################################
;;  special function  
;;##############################################
(defun keyboard-escape-buffer-magic ()
  "Exit the current \"mode\" (in a generalized sense of the word).
This command can exit an interactive command such as `query-replace',
can clear out a prefix argument or a region,
can get out of the minibuffer or other recursive edit,
cancel the use of the current buffer (for special-purpose buffers)."
  (interactive)
  (cond ((eq last-command 'mode-exited) nil)
	((region-active-p)
	 (deactivate-mark))
	((> (minibuffer-depth) 0)
	 (abort-recursive-edit))
	(current-prefix-arg
	 nil)
	((> (recursion-depth) 0)
	 (exit-recursive-edit))
	(buffer-quit-function
	 (funcall buffer-quit-function))
	((string-match "^ \\*" (buffer-name (current-buffer)))
	 (bury-buffer))))


;; init.el find function
(defun open-init-file ()
  "Open the init file."
  (interactive)
  (find-file user-init-file))
(defun open-org-dir ()
  "Open the org directory in dired."
  (interactive)
  (dired "~/.emacs.d/org/"))


;;custom shorcut
(global-set-key (kbd "<escape>") 'keyboard-escape-buffer-magic)
(define-prefix-command 'open-short)
(global-set-key (kbd "C-o") 'open-short)
(global-set-key (kbd "C-o d") 'open-org-dir)
(global-set-key (kbd "C-o f") 'open-init-file)

;; setup MELPA
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("org" . "https://orgmode.elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package on non-linux platforms
(unless (package-installed-p 'use-package)
 (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)


;; setup helm
;;(use-package helm)


;;change font & theme
(use-package all-the-icons
  :if (display-graphic-p))

(set-face-attribute 'default nil :font "FiraCode NF" :height 120)

(use-package nord-theme)
(load-theme 'nord t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("37768a79b479684b0756dec7c0fc7652082910c37d8863c35b702db3f16000f8" default))
 '(package-selected-packages
   '(lsp-jedi lsp-python-ms pippel visual-fill-column org-bullets org-mode lsp-mode helm which-key rainbow-delimiters doom-modeline use-package nord-theme ivy command-log-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

;; Some useful editor config
(column-number-mode)
(global-display-line-numbers-mode t)
(dolist (mode '(org-mode-hook
		term-mode-hook
		eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

;; Developpement

(use-package pippel)
(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l")
  :config
  (lsp-enable-which-key-integration t))

(use-package lsp-jedi
  :ensure t
  :config
  (with-eval-after-load "lsp-mode"
    (add-to-list 'lsp-disabled-clients 'pyls)
    (add-to-list 'lsp-enabled-clients 'jedi)))

;; org setup

(defun dw/org-mode-setup ()
  (org-indent-mode)
  (auto-fill-mode 0)
  (visual-line-mode 1)
  (setq evil-auto-indent nil))

(use-package org
  :hook (org-mode . dw/org-mode-setup)
  :config
  (setq org-ellipsis " "
	org-hide-emphasis-markers t))
(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("\u200b")))

(defun efs/org-mode-visual-fill ()
  (setq visual-fill-column-width 100
	visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . efs/org-mode-visual-fill))
