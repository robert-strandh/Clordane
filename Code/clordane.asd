(cl:in-package #:asdf-user)

(defsystem #:clordane
  :depends-on (#:mcclim
               #:sicl-minimal-extrinsic-environment)
  :serial t
  :components
  ((:file "packages")
   (:file "gui")))

  
