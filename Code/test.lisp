(cl:in-package #:common-lisp-user)

;;; This is a mock-up application.  When there is a potential
;;; breakpoint, it calls CLORDANE:POTENTIAL-BREAKPOINT with the source
;;; information of that breakpoint.  It then waits by calling
;;; CLORDANE:WAIT.  In a better version of Clordane and this protocol,
;;; we imagine the use of a special variable, say CLORDANE:*FILTER*,
;;; which contains a small-ish (maybe 1000 entries) bitvector.  The
;;; application starts by consulting this bitvector with the address
;;; of the instruction about to be executed, modulo the size.  If the
;;; value is 0, there is definitely not a breakpoint there, so no need
;;; to call POTENTIAL-BREAKPOINT or WAIT.

;;; To execute the demo, make sure this file has been loaded, and then
;;; start Clordane with (CLORDANE:CLORDANE '(BLA)).  At a breakpoint,
;;; issue the Continue command.

(defun bla ()
  (flet ((make-source (lines li1 ci1 li2 ci2)
           (cons (make-instance 'sicl-source-tracking:source-position
                   :lines lines :line-index li1 :character-index ci1)
                 (make-instance 'sicl-source-tracking:source-position
                   :lines lines :line-index li2 :character-index ci2)))
         (action (n)
           (format *trace-output* "~s~%" n)))
    (action 1)
    (clordane:wait)
    (clordane:potential-breakpoint
     (make-source #("first line" "second line" "third line") 1 3 1 7))
    (action 2)
    (clordane:wait)
    (action 3)
    (clordane:potential-breakpoint
     (make-source #("xfirst line" "xsecond line" "xthird line") 0 2 1 10))
    (action 4)
    (clordane:wait)
    (action 5)
    (clordane:potential-breakpoint
     (make-source #("yfirst line" "ysecond line" "ythird line") 0 2 1 10))
    (action 6)))
