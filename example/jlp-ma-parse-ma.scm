#!/usr/bin/env gosh
(use yahoo-jp)

(define APPID "YOUR-APPID")
(define yahoo-obj (make-yahoo-jp APPID))
(define res (yahoo:jlp-ma-parse-ma yahoo-obj 
                                     '((sentence "庭には二羽鶏がいる。")
                                       (results "ma"))))

(map (lambda (lst)
       (display (append (maparse-ma-reading lst)
                        (maparse-ma-surface lst)
                        (maparse-ma-pos lst)))
       (newline))
res)
