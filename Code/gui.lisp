(cl:in-package #:clordane)

(clim:define-application-frame clordane ()
  ((%environment :initform nil :accessor environment)
   (%source :initform nil :accessor source))
  (:panes (error-message :application :scroll-bars nil)
          (backtrace :application :scroll-bars nil)
          (interaction :interactor :scroll-bars nil)
          (buttons  :application :scroll-bars nil)
          (source :application :scroll-bars nil
                  :display-function 'display-source)
          (repl  :application :scroll-bars nil))
  (:layouts (default
             (clim:horizontally (:height 1000 :width 1400)
               (1/2 (clim:vertically ()
                      (1/10 error-message)
                      (7/10 (clim:scrolling (:scroll-bars t) backtrace))
                      (1/10 (clim:scrolling (:scroll-bars t) interaction))
                      (1/10 buttons)))
               (1/2 (clim:vertically ()
                      (8/10 (clim:scrolling (:scroll-bars t) source))
                      (2/10 (clim:scrolling (:scroll-bars t) repl))))))))

(defun display-source (frame pane)
  (let ((source (source frame)))
    (if (null source)
        (format pane "No source available")
        (loop for line across source
              do (format pane "~a~%" line)))))
(defun clordane ()
  (clim:run-frame-top-level (clim:make-application-frame 'clordane)))

(define-clordane-command (com-quit :name t) ()
  (clim:frame-exit clim:*application-frame*))

(define-clordane-command (com-load-environment :name t)
    ((environment clim:form))
  (setf (environment clim:*application-frame*)
        (eval environment)))

(define-clordane-command (com-find-function :name t)
    ((function-name clim:form))
  (let ((environment (environment clim:*application-frame*)))
    (if (null environment)
        (format *standard-input* "No environment loaded")
        (let* ((function (sicl-genv:fdefinition function-name environment))
               (source-information
                 (sicl-minimal-extrinsic-environment::source-information function))
               (positions
                 (sicl-minimal-extrinsic-environment:positions source-information)))
          (if (null positions)
              (format *standard-input* "No source information available")
              (setf (source clim:*application-frame*)
                    (sicl-source-tracking:lines (caar positions))))))))
