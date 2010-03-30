#!/usr/bin/env gosh
(use yahoo-jp)

(define appid "YOUR-APPID")
(define yahoo-obj (make-yahoo-jp appid))
(define res 
  (yahoo:video-search yahoo-obj 
                      '((query "yahoo") 
                        (results 5)
                        (format "flash"))))
                        
(for-each (lambda (lst)
            (display (video-title lst))
            (newline)
            (display (video-summary lst))
            (newline)
            (display (video-url lst))
            (newline)
            (display (video-fileformat lst))
            (newline)
            (display (video-height lst))
            (newline)
            (display (video-width lst))
            (newline))
          res)