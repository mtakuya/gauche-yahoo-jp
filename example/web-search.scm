#!/usr/bin/env gosh
(use yahoo-jp)

(define appid "YOUR-APPID")
(define yahoo-obj (make-yahoo-jp appid))
(define res (yahoo:web-search yahoo-obj '((query "yahoo"))))
(for-each (lambda (lst)
            (display (web-title lst))
            (newline)
            (display (web-summary lst))
            (newline)
            (display (web-url lst))
            (newline))
          res)