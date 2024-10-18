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
    (let* ((source (source frame))
           (start (car source))
           (lines (sicl-source-tracking:lines start))
           (line-number (sicl-source-tracking:line-index start))
           (column-number (sicl-source-tracking:character-index start)))
      (loop for i from 0 below line-number
            for line = (aref lines i)
            do (format pane "~a~%" line))
      (format pane "~a" (subseq (aref lines line-number) 0 column-number))
      (multiple-value-bind (x y) (clim:stream-cursor-position pane)
        (clim:draw-rectangle* pane
                              x y (+ x 5) (+ y 10)
                              :filled t :ink clim:+red+))
      (format pane "~a~%" (subseq (aref lines line-number) column-number))
      (loop for i from (1+ line-number) below (length lines)
            for line = (aref lines i)
            do (format pane "~a~%" line)))))

(defclass info ()
  ((%queue :initarg :queue :reader queue)
   (%frame :initarg :frame :reader frame)))

(defvar *info*)

(defun clordane (form)
  (let* ((frame (clim:make-application-frame 'clordane))
         (info (make-instance 'info
                 :queue (queue frame)
                 :frame frame))
         ;; When a form is evaluated from Clordane, we make sure that
         ;; the special variable *INFO* is bound to an instance of the
         ;; class INFO.  That way, application code has access to the
         ;; queue used for communication between it and Clordane, and
         ;; to the Clordane application frame so that commands can be
         ;; injected into it.
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

;;; This command is executed by the application injecting it into the
;;; command queue of Clordane, using CLIM:EXECUTE-FRAME-COMMAND.
(define-clordane-command (com-breakpoint :name t) ()
  nil)

;;; This function is called by the application in the application
;;; thread.  We simplify the demo by assuming that there is always a
;;; breakpoint, because we don't yet have the mechanisms to manage
;;; breakpoints.
(defun potential-breakpoint (source-position)
  (check-type source-position
              (cons sicl-source-tracking:source-position
                    sicl-source-tracking:source-position))
  ;; It is possible that the application is run directly, rather than
  ;; from Clordane.  In that case, we do nothing.
  (when (boundp '*info*)
    (setf (source (frame *info*)) source-position)
    (clim:execute-frame-command (frame *info*) '(com-breakpoint))))

;;; This function is called by the application in the application
;;; thread.
(defun wait ()
  ;; It is possible that the application is run directly, rather than
  ;; from Clordane.  In that case, we do nothing.
  (when (boundp '*info*)
    (receptacle:queue-pop-wait (queue *info*))))
