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
(defun open-org-todo ()
  "Open my daily todolist."
  (interactive)
  (find-file "~/.emacs.d/org/todo.org"))


;;custom shorcut
(global-set-key (kbd "<escape>") 'keyboard-escape-buffer-magic) ; Use escape instead of C-g
(define-prefix-command 'open-short) ; Generate a command for prefix 
(global-set-key (kbd "C-o") 'open-short) ; Assign C-o as prefix 
(global-set-key (kbd "C-o d") 'open-org-dir) ; Open my org file dir
(global-set-key (kbd "C-o f") 'open-init-file) ; Open my init.el
(global-set-key (kbd "C-o t") 'open-org-todo) ; Open my todolist

(define-prefix-command 'move-short) ; Generate a command for prefix 
(global-set-key (kbd "C-<") 'move-short) ; Assign C-< as prefix 
(global-set-key (kbd "C-< <up>") 'windmove-up); move up
(global-set-key (kbd "C-< <down>") 'windmove-down); move down
(global-set-key (kbd "C-< <left>") 'windmove-left); move left
(global-set-key (kbd "C-< <right>") 'windmove-right); move right


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

(use-package doom-themes
  :ensure t
  :config
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-vibrant t))
  
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

(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-l")
  :hook ((python-mode . lsp))
  :config
  (lsp-enable-which-key-integration t))
(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode))
(use-package python-mode
  :ensure t
  :hook (python-mode . lsp-deferred))

(use-package lsp-pyright
  :ensure t
  :hook (python-mode . (lambda ()
                          (require 'lsp-pyright)
                          (lsp-deferred))))  ; or lsp-deferred
(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
	      ("<tab>" . company-complete-selection))
  :custom
  (company-minimum-prefix-lenght 1)
  (company-idle-delay 0.0))
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
	org-hide-emphasis-markers t)
  (setq org-agenda-files '("~/.emacs.d/org/todo.org"))
  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  (setq org-todo-keywords
	'((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
	  (sequence "BACKLOG(b)" "READY(r)" "REVIEW(v)" "HOLD(h)" "|" "COMPLETED(c)" "CANCELED(k)"))))

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (python . t)))
(setq org-confirm-babel-evaluate nil)

(require 'org-tempo)
(add-to-list 'org-structure-template-alist '("sh" . "src shell"))
(add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
(add-to-list 'org-structure-template-alist '("py" . "src python"))

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
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(lsp-ui company doom-themes which-key visual-fill-column use-package rainbow-delimiters pippel org-bullets nord-theme lsp-jedi doom-modeline))
 '(python-shell-interpreter "python3")
 '(vc-follow-symlinks t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
