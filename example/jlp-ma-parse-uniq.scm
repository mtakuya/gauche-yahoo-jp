#!/usr/bin/env gosh
(use yahoo-jp)

(define appid "YOUR-APPID")
(define yahoo-obj (make-yahoo-jp appid))
(define res (yahoo:jlp-ma-parse-uniq yahoo-obj 
                                     '((sentence "庭には二羽ニワトリがいる。")
                                       (results "uniq"))))
(for-each (lambda (lst)
            (display (maparse-uniq-reading lst))
            (newline)
            (display (maparse-uniq-count lst))
            (newline))
          res)
