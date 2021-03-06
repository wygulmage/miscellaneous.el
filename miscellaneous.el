;;; miscellaneous.el --- random crap that belongs somewhere else -*- lexical-binding: t -*-

;;; Some convenience functions that don't belong here but I don't have a better place to put them.
(eval-when-compile
  (require 'cl-macs))
(require 'seq) ; `seq-doseq', `seq-partition'

;;; Strings and Symbols:

(defun misc--princ (OBJECT &optional PRINT-CHAR-FUNCTION)
  "`princ' but does not print the colon of a keyword"
  (princ (if (keywordp OBJECT)
             (substring (symbol-name OBJECT) 1)
           OBJECT)
         PRINT-CHAR-FUNCTION))

(defun misc--mkstr (&rest ARGS)
  "Create a string from arbitrary arguments."
  (declare (pure t) (side-effect-free t))
  (with-output-to-string
    (mapc #'misc--princ ARGS)))

(defun misc--symb (&rest ARGS)
  "Create a new interned symbol."
  (intern (apply #'misc--mkstr ARGS)))

(defun misc--pad (W S)
  "Integer -> String -> String
Pad string S with spaces to width W. A negative width means add the padding on the right.\n
Example: (misc--pad 5 \"Hi!\") => \"  Hi!\""
  (declare (pure t) (side-effect-free t))
  (format (concat "%" (number-to-string W) "s") S))


;;; Lists:

(defun misc--alternate (LIST1 LIST2)
  "Create a list that alternates the elements of LIST1 and LIST2."
  (declare (pure t) (side-effect-free t))
  (cl-loop
   for e1 in LIST1 and e2 in LIST2
   append (list e1 e2)))


(defun misc/folder (FUNCTION IDENTITY)
  ":: (a -> b -> b) -> b ->
     (Maybe (a . b) -> b)"
  (lambda (maybe)
    (pcase maybe
      (`(,a . ,b) (funcall FUNCTION a b))
      ('() IDENTITY))))

;; This takes advantage of the fact that (a . [a]) :: [a].
;; One possible process:
;; 1. Pass seed0 to the unfolder.
;; 2. The unfolder produces a Maybe (value1, seed1).
;; 3. Pass the Maybe (value1, seed1) to the folder.
;; 4. The folder produces a

;; (defun misc/fold-rec (LIST FOLDER)
;;   ":: [a] -> (Maybe (a . s) -> s) -> s"
;;   (funcall FOLDER
;;    (pcase LIST
;;      (`(,x . ,xx)
;;       `(,x . ,(misc/fold-rec xx FOLDER))))))

;; (defun misc/unfold-rec (SEED UNFOLDER)
;;   ":: s -> (s -> Maybe (a . s)) -> [a]"
;;   (pcase (funcall UNFOLDER SEED)
;;     (`(,x . ,state)
;;      `(,x . ,(misc/unfold-rec state UNFOLDER)))))

(defun misc/refold (SEED UNFOLDER FOLDER)
  ":: s -> (s -> Maybe (a . s)) -> (Maybe (a . b) -> b) -> b
This is a left-fold."
  (funcall FOLDER
           (pcase (funcall UNFOLDER SEED)
             (`(,x . ,state)
              `(,x . ,(misc/refold state UNFOLDER FOLDER)))
             ('() ()))))

;; ;; Canonical:
;; (defun misc/fold-rec (FOLDER LIST)
;;   ":: (Maybe (a . b) -> b) -> [a] -> b"
;;   (funcall FOLDER
;;    (pcase LIST
;;      (`(,x . ,xx)
;;       `(,x . ,(misc/fold-rec FOLDER xx))))))

;; (defun misc/unfold-rec (UNFOLDER SEED)
;;   ":: (b -> Maybe (a . b)) -> b -> [a]"
;;   (pcase (funcall UNFOLDER SEED)
;;     (`(,x . ,new-seed)
;;      `(,x . ,(misc/unfold-rec UNFOLDER new-seed)))))


(defun misc/refold-left (FOLDER UNFOLDER SEED)
  "Hatch a snake, feed it its own tail, and return what's left.
:: (Maybe (a . b) -> b) -> (s -> Maybe (a . s)) -> s -> b
This is a left fold."
  (let ((result (funcall FOLDER ()))
        (maybe  (funcall UNFOLDER SEED)))
    (while maybe
      (setq result (funcall FOLDER   (cons (car maybe) result))
            maybe  (funcall UNFOLDER (cdr maybe))))
    result))

(defun misc/unfold (UNFOLDER SEED)
  (misc/refold #'identity UNFOLDER SEED))

(defun misc/fold (FUNCTION IDENTITY LIST)
  "bog standard left-fold function"
  (misc/refold (misc/folder FUNCTION IDENTITY) #'identity LIST))

(defun misc//fix (f) (lambda (x) (funcall (funcall f (misc//fix f)) x)))

;; (defalias 'misc/left #'car)
;; (defalias 'misc/right #'cdr)
;; (defalias 'misc/branch? #'consp)
;; (defalias 'misc/leaf? #'vectorp)
;; (defun misc/treefold (FOLDER LIST)
;;   ":: (Either a (b, b) -> b) -> Tree a -> b")

;;; Numbers:

(defun misc--digits (N)
  "Number -> Integer
The number of decimal digits of N, including any period as a digit.\n
Example: (misc--digits 10.7) => 4"
  (declare (pure t) (side-effect-free t))
  (length (number-to-string N)))

;;; Key maps:

(defun misc--def-keys (MAP &rest BINDINGS)
  "Create new key bindings in MAP.
Each binding should be a string that can be passed to `kbd' followed by an interactive procedure."
  (declare (indent defun))
  (seq-doseq (b (seq-partition BINDINGS 2))
    (define-key MAP (kbd (elt b 0))
      (elt b 1))))


(provide 'miscellaneous)
