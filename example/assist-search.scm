#!/usr/bin/env gosh
(use yahoo-jp)

(define appid "YOUR-APPID")
(define yahoo-obj (make-yahoo-jp appid))
(define res 
  (yahoo:assist-search yahoo-obj 
                      '((query "yahoo")
                        (results 10)))) 
                        
(for-each (lambda (lst)
            (display (assist-result lst))
            (newline))
          res)