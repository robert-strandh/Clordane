(defun bla ()
  (format *trace-output* "1~%")
  (clordane::wait)
  (clordane::show (cons (make-instance 'sicl-source-tracking:source-position
                          :lines #("first line" "second line" "third line")
                          :line-index 1
                          :character-index 3)
                        (make-instance 'sicl-source-tracking:source-position
                          :lines #("first line" "second line" "third line")
                          :line-index 1
                          :character-index 7)))
  (format *trace-output* "2~%")
  (clordane::wait)
  (format *trace-output* "3~%")
  (clordane::show (cons (make-instance 'sicl-source-tracking:source-position
                          :lines #("another first line"
                                   "another second line"
                                   "another third line")
                          :line-index 0
                          :character-index 3)
                        (make-instance 'sicl-source-tracking:source-position
                          :lines #("another first line"
                                   "another second line"
                                   "another third line")
                          :line-index 1
                          :character-index 15)))
  (format *trace-output* "4~%")
  (clordane::wait)
  (format *trace-output* "5~%")
  (clordane::show (cons (make-instance 'sicl-source-tracking:source-position
                          :lines #("one more first line"
                                   "one more second line"
                                   "one more third line")
                          :line-index 1
                          :character-index 3)
                        (make-instance 'sicl-source-tracking:source-position
                          :lines #("one more first line"
                                   "one more second line"
                                   "one more third line")
                          :line-index 2
                          :character-index 10)))
  (format *trace-output* "6~%"))
