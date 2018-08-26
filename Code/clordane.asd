(cl:in-package #:asdf-user)

(defsystem #:clordane
  :depends-on (#:mcclim)
  :serial t
  :components
  ((:file "packages")))

  
