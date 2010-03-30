#!/usr/bin/env gosh
(use yahoo-jp)

(define appid "YOUR-APPID")
(define yahoo-obj (make-yahoo-jp appid))
(define res 
  (yahoo:image-search yahoo-obj 
                      '((query "yahoo") 
                        (results 50)
                        (start 10)
                        (format "jpeg")
                        (coloration "color")
                        (site "www.yahoo.com")
                        (site "uk.yahoo.com"))))
(for-each (lambda (lst)
            (display (image-title lst))
            (newline)
            (display (image-summary lst))
            (newline)
            (display (image-url lst))
            (newline))
          res)