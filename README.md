# Editas

Edit a file in Emacs as if it were a different format, with the power of Pandoc.  

Uses two functions and a regex replacement which can be set.  

The functions `editas-from-function` and `editas-to-function` can be either a list, a string, or a lisp function.

Example:
```elisp
(defun foobar-editas (file)
	(interactive "fOpen Foobar File:")
	(let ((editas-from-function (expand-file-name "from.sh" user-init-dir))
				editas-name-regex '("\\.html" ".md"))
		(editas file)
		(setq-local editas-to-function (expand-file-name "to.sh" user-init-dir))))

```
