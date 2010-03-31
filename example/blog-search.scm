#!/usr/bin/env gosh
(use yahoo-jp)

(define appid "YOUR-APPID")
(define yahoo-obj (make-yahoo-jp appid))
(define res (yahoo:blog-search yahoo-obj '((query "scheme lisp") (results 10))))
(for-each (lambda (lst)
            (display (blog-title lst))
            (newline)
            (display (blog-url lst))
            (newline))
          res)
