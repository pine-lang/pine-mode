;;; pine-mode.el --- Evaluate pine expressions in emacs -*- lexical-binding: t -*-

;; Author: Ahmad Nazir Raja <ahmadnazir@gmail.com>
;; Version: 0.0.1
;; Package-Requires: ((s "1.10.0"))
;; URL: https://github.com/ahmadnazir/pine-mode

;;; Commentary:
;;
;; This mode helps you evaluate pine expressions. Some examples are:
;;
;; users * | customers *
;;
;; customers name=Acme* | users *
;;
;; For more details, see https://github.com/ahmadnazir/pine

(require 's)
(require 'sql)
(require 'request)
(require 'cl-lib)

;;; Code:

(defcustom pine-mode--pine-service-endpoint "http://localhost:33333/api/v1/build-with-params"
  "Endpoint for the pine service")

(defun pine-mode--get-string (start end)
  "Get the raw query with variables.
Argument START Point where the query starts.
Argument END Point where the query ends."
  (interactive "r")
  (buffer-substring-no-properties start end))

(defun pine-mode--string-at-point()
  "Build the query to be executed at point"
  (let ((start (save-excursion
                 (move-beginning-of-line nil)
                 (point)))
        (end (save-excursion
               (move-end-of-line nil)
               (point))))
    (pine-mode--get-string start end)))

(defun pine-mode--pine-build-at-point (callback)
  "Build a query for the pine expression at point."
  (interactive)
  (let ((expression (s-trim (pine-mode--string-at-point))))
    (request pine-mode--pine-service-endpoint
      :type "POST"
      :data (json-encode `(("expression" . ,expression)))
      :headers '(("Content-Type" . "application/json"))
      :parser 'buffer-string
      :success (cl-function
                (lambda (&key data &allow-other-keys)
                  (when data
                    (funcall callback data)
                    (message "%s" data)))))))

(defun pine-mode--eval-at-point()
  "Evaluate a pine expression at point"
  (interactive)
  (pine-mode--pine-build-at-point 'sql-send-string)
  )

(defun pine-mode--copy-at-point()
  "Copy the result of building a Pine expression at point."
  (interactive)
  (pine-mode--pine-build-at-point 'kill-new))


;; Minor Mode
(defvar pine-mode-map (make-sparse-keymap)
  "Pine-mode keymap.")

;; (define-key pine-mode-map
;;   (kbd "C-c C-c") 'pine-mode--eval-at-point)

;;;###autoload
(define-minor-mode pine-mode
  "Pine mode" nil " Pine" pine-mode-map
  (progn ()
         (message "pine mode activated")
         ))

(provide 'pine-mode)

;;; pine-mode.el ends here
