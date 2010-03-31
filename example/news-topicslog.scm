#!/usr/bin/env gosh
(use yahoo-jp)

(define appid "YOUR-APPID")
(define yahoo-obj (make-yahoo-jp appid))
(define res (yahoo:news-topicslog yahoo-obj
                                  '((category "computer")
                                    (startdate "20100301")
                                    (results "5"))))
(for-each (lambda (lst)
                (display (topicslog-topicname lst)) 
                (newline)
                (display (topicslog-url lst))
                (newline))
          res)
