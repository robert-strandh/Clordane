(cl:in-package #:clordane)

(defclass breakpoint ()
  ((%program-counter :initarg :program-counter :reader program-counter)))

(defclass thread-info ()
  (;; This slot contains a hash table that maps values of the program
   ;; counter to instances of the class BREAKPOINT defined above. 
   (%breakpoints :initform (make-hash-table :test #'eq) :reader breakpoints)))

;;; This hash table contains an entry for each debugged thread.  The
;;; key is the thread itself.  The value is an instance of the
;;; THREAD-INFO class defined above.  A thread will regularly consult
;;; this table.  If its thread is present as a key in the table, it
;;; will do some further interrogation on the THREAD-INFO instance it
;;; finds in there.
(defparameter *thread-table* (make-hash-table :test #'eq))
