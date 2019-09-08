(cl:in-package #:clordane)

(clim:define-application-frame clordane ()
  ((%queue :initform (receptacle:make-blocking-queue)
           :reader queue)
   (%source :initform nil :accessor source))
  (:panes (backtrace :application :scroll-bars nil)
          (source :application :scroll-bars nil :display-function 'display-source)
          (repl :application :scroll-bars nil)
          (interactor :interactor :scroll-bars nil))
  (:layouts (default (clim:horizontally (:width 1200 :height 900)
                       (clim:vertically ()
                         (4/5 (clim:scrolling () backtrace))
                         (1/5 (clim:scrolling () interactor)))
                       (clim:vertically ()
                         (4/5 (clim:scrolling () source))
                         (1/5 (clim:scrolling () repl)))))))

(defun display-source (frame pane)
  (unless (null (source frame))
    (let* ((from (car (source frame)))
           (to (cdr (source frame)))
           (lines (sicl-source-tracking:lines from))
           (from-line (sicl-source-tracking:line-index from))
           (from-column (sicl-source-tracking:character-index from))
           (to-line (sicl-source-tracking:line-index to))
           (to-column (sicl-source-tracking:character-index to)))
      (unless (null (source frame))
        (loop for i from 0 below from-line
              for line = (aref lines i)
              do (format pane "~a~%" line))
        (format pane "~a" (subseq (aref lines from-line) 0 from-column))
        (clim:with-drawing-options (pane :ink clim:+red+)
          (if (= from-line to-line)
              (format pane "~a"
                      (subseq (aref lines from-line) from-column to-column))
              (progn (format pane "~a~%"
                             (subseq (aref lines from-line) from-column))
                     (loop for i from (1+ from-line) below to-line
                           for line = (aref lines i)
                           do (format pane "~a~%" line))
                     (format pane "~a" (subseq (aref lines to-line) 0 to-column)))))
        (format pane "~a~%" (subseq (aref lines to-line) to-column))
        (loop for i from (1+ to-line) below (length lines)
              for line = (aref lines i)
              do (format pane "~a~%" line))))))

(defclass info ()
  ((%queue :initarg :queue :reader queue)
   (%frame :initarg :frame :reader frame)))

(defvar *info*)

(defun clordane (form)
  (let* ((frame (clim:make-application-frame 'clordane))
         (info (make-instance 'info
                 :queue (queue frame)
                 :frame frame))
         (expression
           `(lambda () (let ((*info* ,info)) ,form)))
         (function (compile nil expression))
         (application-thread (bt:make-thread function)))
    (declare (ignore application-thread))
    (clim:run-frame-top-level frame)))

(define-clordane-command (com-quit :name t) ()
  (clim:frame-exit clim:*application-frame*))

(define-clordane-command (com-continue :name t) ()
  (receptacle:queue-push (queue clim:*application-frame*) t))

(define-clordane-command (com-nop :name t) ()
  nil)

(defun show (source-position)
  (when (boundp '*info*)
    (let* ((expression
             `(lambda ()
                (setf (source ,(frame *info*)) ',source-position)))
           (function (compile nil expression)))
      (clim:execute-frame-command (frame *info*) `(funcall ,function)))))

(defun wait ()
  (when (boundp '*info*)
    (receptacle:queue-pop-wait (queue *info*))))
