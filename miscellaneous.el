;;; miscellaneous.el --- random crap that belongs somewhere else -*- lexical-binding: t -*-

;;; Some convenience functions that don't belong here but I don' have a better place to put them.

(defun misc--princ (OBJECT &optional PRINT-CHAR-FUNCTION)
  "`princ' but does not print the colon of a keyword"
  (princ (if (keywordp OBJECT)
             (substring (symbol-name OBJECT) 1)
           OBJECT)
         PRINT-CHAR-FUNCTION))

(defun misc--mkstr (&rest ARGS)
  "Create a string from arbitrary arguments."
  (with-output-to-string
    (mapc #'misc--princ ARGS)))

(defun misc--symb (&rest ARGS)
  "Create a new interned symbol."
  (intern (apply #'misc--mkstr ARGS)))

(defun misc--pad (W S)
  "Integer -> String -> String
Pad string S with spaces to width W. A negative width means add the padding on the right.

Example: (misc--pad 5 \"Hi!\") => \"  Hi!\""
  (declare (pure t) (side-effect-free t))
  (format (concat "%" (number-to-string W) "s") S))

;;; Key maps

(defun misc--def-keys (MAP &rest BINDINGS)
  "Create new key bindings in MAP.
Each binding should be a string that can be passed to `kbd' followed by an interactive procedure."
  (declare (indent defun))
  (seq-doseq (b (seq-partition BINDINGS 2))
    (define-key MAP (kbd (seq-elt b 0))
      (seq-elt b 1))))


(provide 'miscellaneous)
