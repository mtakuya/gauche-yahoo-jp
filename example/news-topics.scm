#!/usr/bin/env gosh
(use yahoo-jp)

(define appid "YOUR-APPID")
(define yahoo-obj (make-yahoo-jp appid))
(define res (yahoo:news-topics yahoo-obj '((query "yahoo"))))

(for-each (lambda (lst)
                (display (topics-overview lst))
                (newline)
                (display (topics-url lst))
                (newline))
          res)
