#!/usr/bin/env gosh
(use yahoo-jp)

(define appid "YOUR-APPID")
(define yahoo-obj (make-yahoo-jp appid))
(define res (yahoo:news-heading yahoo-obj '((category "computer")
                                            (startdate "201003010000")
                                            (results "5"))))
(for-each (lambda (lst)
            (display (heading-title lst)) (newline)
            (display (heading-url lst)) (newline))
              res)

