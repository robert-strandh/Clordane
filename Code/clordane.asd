(cl:in-package #:asdf-user)

(defsystem #:clordane
  :depends-on (#:mcclim
               #:bordeaux-threads
               #:receptacle
               #:sicl-source-tracking
               #:clouseau)
  :serial t
  :components
  ((:file "packages")
   (:file "communication")
   (:file "gui")))
