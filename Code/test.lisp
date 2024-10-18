(cl:in-package #:common-lisp-user)

(defun bla ()
  (flet ((make-source (lines li1 ci1 li2 ci2)
           (cons (make-instance 'sicl-source-tracking:source-position
                   :lines lines :line-index li1 :character-index ci1)
                 (make-instance 'sicl-source-tracking:source-position
                   :lines lines :line-index li2 :character-index ci2)))
         (action (n)
           (format *trace-output* "~s~%" n)))
    (action 1)
    (clordane::wait)
    (clordane:potential-breakpoint
     (make-source #("first line" "second line" "third line") 1 3 1 7))
    (action 2)
    (clordane::wait)
    (action 3)
    (clordane:potential-breakpoint
     (make-source #("xfirst line" "xsecond line" "xthird line") 0 2 1 10))
    (action 4)
    (clordane::wait)
    (action 5)
    (clordane:potential-breakpoint
     (make-source #("yfirst line" "ysecond line" "ythird line") 0 2 1 10))
    (action 6)))
