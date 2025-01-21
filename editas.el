;; -*- lexical-binding: t; -*-

(defvar-local editas-base-file nil)

(defvar-local editas-name-regex '("\\.html" ".md")
  "Conversion between base file name and fake file name.
List itemes are used as parameters in replace-regexp-in-string.
")

(defvar-local editas-from-function "pandoc -f html -t markdown_strict"
  "Command to convert from the source file to the editing buffer")

(defcustom editas-to-function "pandoc -f markdown_strict -t html -o"
  "Command to convert from the editing buffer to the source file")

(defun editas (file)
  (interactive "fFind file:")
  (let* ((base-file (expand-file-name file))
         (temp-file
          (apply 'replace-regexp-in-string
                 (append editas-name-regex (list base-file))))
         (buffer
          (get-buffer-create (file-name-nondirectory temp-file))))
    (switch-to-buffer buffer)
    (let ((buffer-file-name temp-file))
      (normal-mode))
    (setq editas-base-file base-file)
    (add-hook 'write-contents-functions 'editas-save nil t)
    (if (functionp editas-from-function)
        (funcall editas-from-function)
      (let ((command
             (cond
              ((stringp editas-from-function)
               (split-string editas-from-function))
              ((listp editas-from-function)
               editas-from-function))))
        (make-process
         :name "EditasLoad"
         :buffer buffer
         :command (append command (list base-file))
         :sentinel #'ignore)))))

(defun editas-save ()
  (let ((buffer (current-buffer)))
    (if (functionp editas-to-function)
        (funcall editas-to-function)
      (let ((command
             (cond
              ((stringp editas-to-function)
               (split-string editas-to-function))
              ((listp editas-to-function)
               editas-to-function))))
        (make-process
         :name "EditasWrite"
         :connection-type 'pipe
         :command (append command (list editas-base-file))
         :sentinel #'ignore)
        (process-send-region "EditasWrite" (point-min) (point-max))
        (process-send-eof "EditasWrite")
        (message (format "Wrote %s" editas-base-file))))))
