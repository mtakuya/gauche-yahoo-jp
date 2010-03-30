;;;
;;; yahoo-jp.scm - Yahoo! Japan Developer Newtwork API Module (v0.0.1)
;;;
;;; Copyright (c) 2010 Takuya Mannami <mtakuya@users.sourceforge.jp>
;;;
;;; Redistribution and use in source and binary forms, with or without
;;; modification, are permitted provided that the following conditions
;;; are met:
;;;
;;; 1. Redistributions of source code must retain the above copyright
;;; notice, this list of conditions and the following disclaimer.
;;;
;;; 2. Redistributions in binary form must reproduce the above copyright
;;; notice, this list of conditions and the following disclaimer in the
;;; documentation and/or other materials provided with the distribution.
;;;
;;; 3. Neither the name of the authors nor the names of its contributors
;;; may be used to endorse or promote products derived from this
;;; software without specific prior written permission.
;;;
;;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;;; "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;;; LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;;; A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
;;; OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;;; SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
;;; TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
;;; PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
;;; LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
;;; NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;;; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;;;
 
(define-module yahoo-jp
  (use rfc.uri)
  (use rfc.http)
  (use sxml.ssax)
  (use sxml.sxpath)
  (use util.match)
  (export 
   web-title web-summary web-url web-clickurl web-modificationdata web-mimetype web-cacheurl web-cachesize
   image-title image-summary image-url image-clickurl image-refererurl image-filesize image-height image-width
   image-thumnailurl image-thumnailheight image-thumnailwidth
   video-title video-summary video-url video-clickurl video-refererurl video-filesize video-fileformat
   video-height video-width video-duration video-streaming video-channels video-thumbnailurl
   video-thumbnailheight video-thumbnailwidth
   assist-result
   blog-id blog-rssurl blog-title blog-description blog-url blog-creator blog-mobilelink blog-datetime
   blog-sitetitle blog-siteurl
   topics-datetime topics-createtime topics-newsupdatetime topics-relatedinfoupdatetime topics-headlineupdatetime
   topics-title topics-keyword topics-topicname topics-english topics-overview topics-overview topics-category
   topics-categorysub topics-url topics-pickupcategory topics-pickuporder topics-pvindex topics-editnum
   topics-newsnum topics-newsurl topics-relatedinformation
   heading-title heading-topicname heading-english heading-startdate heading-enddate heading-topicpickuptimes
   heading-pvtotal heading-url heading-topicbacknumberurl heading-midashibacknumberurl
   topicslog-topicname topicslog-english topicslog-createdate topicslog-url topicslog-category
   topicslog-subcategory topicslog-keyword topicslog-totaltitlenum topicslog-totaltitletime 
   topicslog-totaltitlepvindex topicslog-publicationinfo 
   maparse-ma-surface maparse-ma-reading maparse-ma-pos maparse-ma-baseform 
   maparse-uniq-count maparse-uniq-reading maparse-uniq-baseform maparse-uniq-pos
   kousei-startpos kousei-length kousei-surface kousei-shitekiword kousei-shitekinfo 
   da-parse-surface da-parse-reading da-parse-baseform da-parse-pos da-parse-feature 
   extract-keyphrase extract-score
   <yahoo-jp> make-yahoo-jp
   yahoo:web-search yahoo:image-search yahoo:video-search yahoo:assist-search yahoo:blog-search
   yahoo:news-topics yahoo:news-heading yahoo:news-topicslog 
   yahoo:jlp-ma-parse-uniq yahoo:jlp-ma-parse-ma
   yahoo:jlp-conversion yahoo:jlp-conversion-hiragana yahoo:jlp-conversion-katakana
   yahoo:jlp-conversion-half-katakana yahoo:jlp-conversion-alphanumeric yahoo:jlp-conversion-half-alphanumeric
   yahoo:jlp-furigana-hiragana yahoo:jlp-furigana-roma yahoo:jlp-kousei
   yahoo:jlp-da-parse yahoo:jlp-extract)
 )
(select-module yahoo-jp)


;;-----------------------------------------------------------------
;; api path
;; 

;search
(define *host-search*        "search.yahooapis.jp")
(define *path-web-search*    "/WebSearchService/V1/webSearch")
(define *path-image-search*  "/ImageSearchService/V1/imageSearch")
(define *path-video-search*  "/VideoSearchService/V1/videoSearch")
(define *path-assist-search* "/AssistSearchService/V1/webunitSearch")
(define *path-blog-search*   "/BlogSearchService/V1/blogSearch")

;news
(define *host-news*           "news.yahooapis.jp")
(define *path-news-topics*    "/NewsWebService/V2/topics")
(define *path-news-heading*   "/NewsWebService/V1/heading")
(define *path-news-topicslog* "/NewsWebService/V1/topicsLog")

;jlp
(define *host-jlp*            "jlp.yahooapis.jp") 
(define *path-jlp-ma-parse*   "/MAService/V1/parse")
(define *path-jlp-conversion* "/JIMService/V1/conversion")
(define *path-jlp-furigana*   "/FuriganaService/V1/furigana")
(define *path-jlp-kousei*     "/KouseiService/V1/kousei")
(define *path-jlp-da-parse*   "/DAService/V1/parse")
(define *path-jlp-extract*    "/KeyphraseService/V1/extract")

;;

;;-----------------------------------------------------------------
;; sxml path
;; 

;search
(define *sxml-path-web-search*    '(urn:yahoo:jp:srch:ResultSet urn:yahoo:jp:srch:Result))
(define *sxml-path-image-search*  '(urn:yahoo:jp:srchmi:ResultSet urn:yahoo:jp:srchmi:Result))
(define *sxml-path-video-search*  '(urn:yahoo:jp:srchmv:ResultSet urn:yahoo:jp:srchmv:Result))
(define *sxml-path-assist-search* '(urn:yahoo:jp:srchunit:ResultSet urn:yahoo:jp:srchunit:Result))
(define *sxml-path-blog-search*   '(urn:yahoo:jp:blogsearch:article:ResultSet urn:yahoo:jp:blogsearch:article:Result))

;news
(define *sxml-path-news-topics*    '(urn:yahoo:jp:news:ResultSet urn:yahoo:jp:news:Result))
(define *sxml-path-news-heading*   '(urn:yahoo:jp:news:ResultSet urn:yahoo:jp:news:Result))
(define *sxml-path-news-topicslog* '(urn:yahoo:jp:news:ResultSet urn:yahoo:jp:news:Result))

;jlp
;map-parse
;ma-uniq is undef
(define *sxml-path-jlp-ma-parse-uniq*
  '(urn:yahoo:jp:jlp:ResultSet urn:yahoo:jp:jlp:uniq_result urn:yahoo:jp:jlp:word_list urn:yahoo:jp:jlp:word))
(define *sxml-path-jlp-ma-parse-ma*  
  '(urn:yahoo:jp:jlp:ResultSet urn:yahoo:jp:jlp:ma_result urn:yahoo:jp:jlp:word_list urn:yahoo:jp:jlp:word))

;conversion
(define *sxml-path-jlp-conversion*
  '(urn:yahoo:jp:jlp:JIMService:ResultSet urn:yahoo:jp:jlp:JIMService:Result urn:yahoo:jp:jlp:JIMService:SegmentList urn:yahoo:jp:jlp:JIMService:Segment urn:yahoo:jp:jlp:JIMService:CandidateList))

;hiragana
(define *sxml-path-jlp-conversion-hiragana* 
  '(urn:yahoo:jp:jlp:JIMService:ResultSet urn:yahoo:jp:jlp:JIMService:Result urn:yahoo:jp:jlp:JIMService:SegmentList urn:yahoo:jp:jlp:JIMService:Segment urn:yahoo:jp:jlp:JIMService:Hiragana))

;katakana
(define *sxml-path-jlp-conversion-katakana*
  '(urn:yahoo:jp:jlp:JIMService:ResultSet urn:yahoo:jp:jlp:JIMService:Result urn:yahoo:jp:jlp:JIMService:SegmentList urn:yahoo:jp:jlp:JIMService:Segment urn:yahoo:jp:jlp:JIMService:Katakana))

(define *sxml-path-jlp-conversion-half-katakana* 
  '(urn:yahoo:jp:jlp:JIMService:ResultSet urn:yahoo:jp:jlp:JIMService:Result urn:yahoo:jp:jlp:JIMService:SegmentList urn:yahoo:jp:jlp:JIMService:Segment urn:yahoo:jp:jlp:JIMService:HalfKatakana))

(define *sxml-path-jlp-conversion-alphanumeric*
  '(urn:yahoo:jp:jlp:JIMService:ResultSet urn:yahoo:jp:jlp:JIMService:Result urn:yahoo:jp:jlp:JIMService:SegmentList urn:yahoo:jp:jlp:JIMService:Segment urn:yahoo:jp:jlp:JIMService:Alphanumeric))

(define *sxml-path-jlp-conversion-half-alphanumeric*
  '(urn:yahoo:jp:jlp:JIMService:ResultSet urn:yahoo:jp:jlp:JIMService:Result urn:yahoo:jp:jlp:JIMService:SegmentList urn:yahoo:jp:jlp:JIMService:Segment urn:yahoo:jp:jlp:JIMService:HalfAlphanumeric))

;furigana
;hiragana
(define *sxml-path-jlp-furigana-hiragana*
  '(urn:yahoo:jp:jlp:FuriganaService:ResultSet urn:yahoo:jp:jlp:FuriganaService:Result urn:yahoo:jp:jlp:FuriganaService:WordList urn:yahoo:jp:jlp:FuriganaService:Word urn:yahoo:jp:jlp:FuriganaService:Furigana))

;roma
(define *sxml-path-jlp-furigana-roma*
  '(urn:yahoo:jp:jlp:FuriganaService:ResultSet urn:yahoo:jp:jlp:FuriganaService:Result urn:yahoo:jp:jlp:FuriganaService:WordList urn:yahoo:jp:jlp:FuriganaService:Word urn:yahoo:jp:jlp:FuriganaService:Roman))

;kousei
(define *sxml-path-jlp-kousei*
  '(urn:yahoo:jp:jlp:KouseiService:ResultSet urn:yahoo:jp:jlp:KouseiService:Result))

;da-parse
(define *sxml-path-jlp-da-parse*
   '(urn:yahoo:jp:jlp:DAService:ResultSet urn:yahoo:jp:jlp:DAService:Result urn:yahoo:jp:jlp:DAService:ChunkList urn:yahoo:jp:jlp:DAService:Chunk urn:yahoo:jp:jlp:DAService:MorphemList urn:yahoo:jp:jlp:DAService:Morphem))

;extract
(define *sxml-path-jlp-extract*
  '(urn:yahoo:jp:jlp:KeyphraseService:ResultSet urn:yahoo:jp:jlp:KeyphraseService:Result))
;;

;;-----------------------------------------------------------------
;; list proc
;; 

;search
;web search
(define (web-title lst)            (list-ref lst 0))
(define (web-summary lst)          (list-ref lst 1))
(define (web-url lst)              (list-ref lst 2))
(define (web-clickurl lst)         (list-ref lst 3))
(define (web-modificationdata lst) (list-ref lst 4))
(define (web-mimetype lst)         (list-ref lst 5))
(define (web-cacheurl lst)         (list-ref lst 6))
(define (web-cachesize lst)        (list-ref lst 7))

;image search
(define (image-title lst)          (list-ref lst 0))
(define (image-summary lst)        (list-ref lst 1))
(define (image-url lst)            (list-ref lst 2))
(define (image-clickurl lst)       (list-ref lst 3))
(define (image-refererurl lst)     (list-ref lst 4))
(define (image-filesize lst)       (list-ref lst 5))
(define (image-height lst)         (list-ref lst 6))
(define (image-width lst)          (list-ref lst 7))
(define (image-thumnailurl lst)    (list-ref lst 8))
(define (image-thumnailheight lst) (list-ref lst 9))
(define (image-thumnailwidth lst)  (list-ref lst 10))

;video search
(define (video-title lst)           (list-ref lst 0))
(define (video-summary lst)         (list-ref lst 1))
(define (video-url lst)             (list-ref lst 2))
(define (video-clickurl lst)        (list-ref lst 3))
(define (video-refererurl lst)      (list-ref lst 4))
(define (video-filesize lst)        (list-ref lst 5))
(define (video-fileformat lst)      (list-ref lst 6))
(define (video-height lst)          (list-ref lst 7))
(define (video-width lst)           (list-ref lst 8))
(define (video-duration lst)        (list-ref lst 9))
(define (video-streaming lst)       (list-ref lst 10))
(define (video-channels lst)        (list-ref lst 11))
(define (video-thumbnailurl lst)    (list-ref lst 12))
(define (video-thumbnailheight lst) (list-ref lst 13))
(define (video-thumbnailwidth lst)  (list-ref lst 14))

;assist search
(define (assist-result lst) lst)

;blog search
(define (blog-id lst)          (list-ref lst 0))
(define (blog-rssurl lst)      (list-ref lst 1))
(define (blog-title lst)       (list-ref lst 2))
(define (blog-description lst) (list-ref lst 3))
(define (blog-url lst)         (list-ref lst 4))
(define (blog-creator lst)     (list-ref lst 5))
(define (blog-mobilelink lst)  (list-ref lst 6))
(define (blog-datetime lst)    (list-ref lst 7))
(define (blog-sitetitle lst)   (list-ref lst 8))
(define (blog-siteurl lst)     (list-ref lst 9))

;news 
;topics
(define (topics-datetime lst)              (list-ref lst 0))
(define (topics-createtime lst)            (list-ref lst 1))
(define (topics-newsupdatetime lst)        (list-ref lst 2))
(define (topics-relatedinfoupdatetime lst) (list-ref lst 3))
(define (topics-headlineupdatetime lst)    (list-ref lst 4))
(define (topics-title lst)                 (list-ref lst 5))
(define (topics-keyword lst)               (list-ref lst 6))
(define (topics-topicname lst)             (list-ref lst 7))
(define (topics-english lst)               (list-ref lst 8))
(define (topics-overview lst)              (list-ref lst 9))
(define (topics-category lst)              (list-ref lst 10))
(define (topics-categorysub lst)           (list-ref lst 11))
(define (topics-url lst)                   (list-ref lst 12))
(define (topics-pickupcategory lst)        (list-ref lst 13))
(define (topics-pickuporder lst)           (list-ref lst 14))
(define (topics-pvindex lst)               (list-ref lst 15))
(define (topics-editnum lst)               (list-ref lst 16))
(define (topics-newsnum lst)               (list-ref lst 17))
(define (topics-newsurl lst)               (list-ref lst 18))
(define (topics-relatedinformation lst)    (list-ref lst 19))

;heading
(define (heading-title lst)                (list-ref lst 0))
(define (heading-topicname lst)            (list-ref lst 1))
(define (heading-english lst)              (list-ref lst 2))
(define (heading-startdate lst)            (list-ref lst 3))
(define (heading-enddate lst)              (list-ref lst 4))
(define (heading-topicpickuptimes lst)     (list-ref lst 5))
(define (heading-pvtotal lst)              (list-ref lst 6))
(define (heading-url lst)                  (list-ref lst 7))
(define (heading-topicbacknumberurl lst)   (list-ref lst 8))
(define (heading-midashibacknumberurl lst) (list-ref lst 9))

;topicslog
(define (topicslog-topicname lst)         (list-ref lst 0))
(define (topicslog-english lst)           (list-ref lst 1))
(define (topicslog-createdate lst)        (list-ref lst 2))
(define (topicslog-url lst)               (list-ref lst 3))
(define (topicslog-category lst)          (list-ref lst 4))
(define (topicslog-subcategory lst)       (list-ref lst 5))
(define (topicslog-keyword lst)           (list-ref lst 6))
(define (topicslog-totaltitlenum lst)     (list-ref lst 7))
(define (topicslog-totaltitletime lst)    (list-ref lst 8))
(define (topicslog-totaltitlepvindex lst) (list-ref lst 9))
(define (topicslog-publicationinfo lst)   (list-ref lst 10))

;;jlp
;ma-parse
;ma-parse-ma
(define (maparse-ma-surface lst)  (list-ref lst 0))
(define (maparse-ma-reading lst)  (list-ref lst 1))
(define (maparse-ma-pos lst)      (list-ref lst 2))
(define (maparse-ma-baseform lst) (list-ref lst 3))

;ma-parse-uniq
(define (maparse-uniq-count lst)    (list-ref lst 0))
(define (maparse-uniq-reading lst)  (list-ref lst 1))
(define (maparse-uniq-baseform lst) (list-ref lst 2))
(define (maparse-uniq-pos lst)      (list-ref lst 3))

;kousei
(define (kousei-startpos lst)    (list-ref lst 0))
(define (kousei-length lst)      (list-ref lst 1))
(define (kousei-surface lst)     (list-ref lst 2))
(define (kousei-shitekiword lst) (list-ref lst 3))
(define (kousei-shitekinfo lst)  (list-ref lst 4))

;da-parse
(define (da-parse-surface lst)  (list-ref lst 0))
(define (da-parse-reading lst)  (list-ref lst 1))
(define (da-parse-baseform lst) (list-ref lst 2))
(define (da-parse-pos lst)      (list-ref lst 3))
(define (da-parse-feature lst)  (list-ref lst 4))

;extract
(define (extract-keyphrase lst) (list-ref lst 0))
(define (extract-score lst)     (list-ref lst 1))
;;

;;-----------------------------------------------------------------
;; util
;; 

(define (xml-get obj host path query-alist)
  (receive (status head body)
           (http-get host
                     (http-compose-query path (cons `(appid ,(ref obj 'appid)) query-alist)))
           (if (equal? status "200")
               body
               (error #`"http-get status ,|status|"))))

(define (xml-parse xml path-list)
  (let* ((in (open-input-string xml)) (out (ssax:xml->sxml in '())))
    ((sxpath path-list) out)))

(define (make-results-alist obj host path query-alist sxml-path  pat)
  (let1 sxml 
   (xml-parse (xml-get obj host path query-alist) sxml-path)
   (map (lambda (lst1)
          (map (lambda (lst2) (pat lst2)) (cdr lst1))) sxml)))

;;

;;-----------------------------------------------------------------
;; pattern
;; 

;search
(define (pat-web-search lst)
  (match lst
         (('urn:yahoo:jp:srch:Cache (s1 s2 ...) (s3 s4 ...)) s2 s4)
         ((s1 s2 ...) s2) ))

(define (pat-image-search lst)
  (match lst
         (('urn:yahoo:jp:srchmi:Thumbnail (s1 s2 ...) (s3 s4 ...) (s5 s6 ...)) s2 s4 s6)
         ((s1 s2 ...) s2) ))

(define (pat-video-search lst)
  (match lst
         (('urn:yahoo:jp:srchmv:Thumbnail (s1 s2 ...) (s3 s4 ...) (s5 s6 ...)) s2 s4 s6)
         ((s1 s2 ...) s2) ))

(define (pat-assist-search lst)  lst) ;pass

(define (pat-blog-search lst)
  (match lst
         (('urn:yahoo:jp:blogsearch:article:Site (s1 s2 ...) (s3 s4 ...)) s2 s4)
         ((s1 s2 ...) s2) ))

;news
(define (pat-news-topics lst)
  (match lst
         (('urn:yahoo:jp:news:Keyword ('urn:yahoo:jp:news:Word s1 ...) ...) s1)
         (('urn:yahoo:jp:news:SubCategory ('urn:yahoo:jp:news:Sub s1 ...) ...) s1)
         ((s1 s2 ...) s2) ))

(define (pat-news-heading lst)
  (match lst
         ((s1 s2 ...) s2) ))

(define (pat-news-topicslog lst)
  (match lst
         (('urn:yahoo:jp:news:Keyword ('urn:yahoo:jp:news:Word s1 ...) ...) s1)
         (('urn:yahoo:jp:news:SubCategory ('urn:yahoo:jp:news:Sub s1 ...) ...) s1)
         ((s1 s2 ...) s2) ))

;jlp
;ma-parse
(define (pat-jlp-ma-parse-uniq lst) ;only uniq
  (match lst
         (('urn:yahoo:jp:jlp:surface s1 ...) s1)
         (('urn:yahoo:jp:jlp:reading s2 ...) s2)
         (('urn:yahoo:jp:jlp:pos s3 ...) s3)
         (('urn:yahoo:jp:jlp:baseform s4 ...) s4)
         (('urn:yahoo:jp:jlp:count s5 ...) s5)
))

(define (pat-jlp-ma-parse-ma lst) ;only ma
  (match lst
         (('urn:yahoo:jp:jlp:surface s1 ...) s1)
         (('urn:yahoo:jp:jlp:reading s2 ...) s2)
         (('urn:yahoo:jp:jlp:pos s3 ...) s3)
         (('urn:yahoo:jp:jlp:baseform s4 ...) s4)
))

;conversion
;default
(define (pat-jlp-conversion lst)
  (match lst
         (('urn:yahoo:jp:jlp:JIMService:Candidate s1 ...) s1)
))

;hiragana
(define (pat-jlp-conversion-hiragana lst) lst) ;pass

;katakana
(define (pat-jlp-conversion-katakana lst) lst) ;pass

;harl_katakana
(define (pat-jlp-conversion-half-katakana lst) lst) ;pass

;alphanumeric
(define (pat-jlp-conversion-alphanumeric lst) lst) ;pass

;half_alphanumeric
(define (pat-jlp-conversion-half-alphanumeric lst) lst) ;pass

;furigana
;hiragana
(define (pat-jlp-furigana-hiragana lst) lst) ;pass

;roma
(define (pat-jlp-furigana-roma lst) lst) ;pass

;kousei
(define (pat-jlp-kousei lst)
  (match lst
         (('urn:yahoo:jp:jlp:KouseiService:StartPos s1 ...) s1)
         (('urn:yahoo:jp:jlp:KouseiService:Length s2 ...) s2)
         (('urn:yahoo:jp:jlp:KouseiService:Surface s3 ...) s3)
         (('urn:yahoo:jp:jlp:KouseiService:ShitekiWord s4 ...) s4)
         (('urn:yahoo:jp:jlp:KouseiService:ShitekiInfo s5 ...) s5)
))

;da-parse
(define (pat-jlp-da-parse lst)
  (match lst
         (('urn:yahoo:jp:jlp:DAService:Surface s1 ...) s1)
         (('urn:yahoo:jp:jlp:DAService:Reading s2 ...) s2)
         (('urn:yahoo:jp:jlp:DAService:Baseform s3 ...) s3)
         (('urn:yahoo:jp:jlp:DAService:POS s4 ...) s4)
         (('urn:yahoo:jp:jlp:DAService:Feature s5 ...) s5)       
))

;extract
(define (pat-jlp-extract lst)
  (match lst
         (('urn:yahoo:jp:jlp:KeyphraseService:Keyphrase s1 ...) s1)
         (('urn:yahoo:jp:jlp:KeyphraseService:Score s2 ...) s2)     
))
;;

;;-----------------------------------------------------------------
;; class
;; 

(define-class <yahoo-jp> () ((appid :init-keyword :appid)))
(define (make-yahoo-jp appid) (make <yahoo-jp> :appid appid))

;;

;;-----------------------------------------------------------------
;; method
;; 

;search
(define-method yahoo:web-search ((obj <yahoo-jp>) query-alist)
  (make-results-alist obj
   *host-search* *path-web-search* query-alist *sxml-path-web-search* pat-web-search))

(define-method yahoo:image-search ((obj <yahoo-jp>) query-alist)
  (make-results-alist obj 
   *host-search* *path-image-search* query-alist *sxml-path-image-search* pat-image-search))

(define-method yahoo:video-search ((obj <yahoo-jp>) query-alist)
  (make-results-alist obj 
   *host-search* *path-video-search* query-alist *sxml-path-video-search* pat-video-search))

(define-method yahoo:assist-search ((obj <yahoo-jp>) query-alist)
  (make-results-alist obj
   *host-search* *path-assist-search* query-alist *sxml-path-assist-search* pat-assist-search))

(define-method yahoo:blog-search ((obj <yahoo-jp>) query-alist)
  (make-results-alist obj
   *host-search* *path-blog-search* query-alist *sxml-path-blog-search* pat-blog-search))

;news
(define-method yahoo:news-topics ((obj <yahoo-jp>) query-alist)
  (make-results-alist obj
   *host-news* *path-news-topics* query-alist *sxml-path-news-topics* pat-news-topics))

(define-method yahoo:news-heading ((obj <yahoo-jp>) query-alist)
  (make-results-alist obj
   *host-news* *path-news-heading* query-alist *sxml-path-news-heading* pat-news-heading))

(define-method yahoo:news-topicslog ((obj <yahoo-jp>) query-alist)
  (make-results-alist obj
   *host-news* *path-news-topicslog* query-alist *sxml-path-news-topicslog* pat-news-topicslog))

;jlp
;ma-parse
(define-method yahoo:jlp-ma-parse-uniq ((obj <yahoo-jp>) query-alist) ;only uniq
  (make-results-alist obj
   *host-jlp* *path-jlp-ma-parse* query-alist *sxml-path-jlp-ma-parse-uniq* pat-jlp-ma-parse-uniq))

(define-method yahoo:jlp-ma-parse-ma ((obj <yahoo-jp>) query-alist) ;only ma
  (make-results-alist obj
   *host-jlp* *path-jlp-ma-parse* query-alist *sxml-path-jlp-ma-parse-ma* pat-jlp-ma-parse-ma))

;conversion
;default
(define-method yahoo:jlp-conversion ((obj <yahoo-jp>) query-alist)
  (make-results-alist obj
   *host-jlp* *path-jlp-conversion* query-alist *sxml-path-jlp-conversion* pat-jlp-conversion))

;hiragana
(define-method yahoo:jlp-conversion-hiragana ((obj <yahoo-jp>) query-alist)
  (make-results-alist obj
   *host-jlp* *path-jlp-conversion* query-alist *sxml-path-jlp-conversion-hiragana* pat-jlp-conversion-hiragana))

;katakana
(define-method yahoo:jlp-conversion-katakana ((obj <yahoo-jp>) query-alist)
  (make-results-alist obj
   *host-jlp* *path-jlp-conversion* query-alist *sxml-path-jlp-conversion-katakana* pat-jlp-conversion-katakana))

;harf-katakana
(define-method yahoo:jlp-conversion-half-katakana ((obj <yahoo-jp>) query-alist)
  (make-results-alist obj
   *host-jlp* *path-jlp-conversion* query-alist *sxml-path-jlp-conversion-half-katakana* pat-jlp-conversion-half-katakana))

;alphanumeric
(define-method yahoo:jlp-conversion-alphanumeric ((obj <yahoo-jp>) query-alist)
  (make-results-alist obj
   *host-jlp* *path-jlp-conversion* query-alist *sxml-path-jlp-conversion-alphanumeric* pat-jlp-conversion-alphanumeric))

;half-alphanumeric
(define-method yahoo:jlp-conversion-half-alphanumeric ((obj <yahoo-jp>) query-alist)
  (make-results-alist obj
   *host-jlp* *path-jlp-conversion* query-alist *sxml-path-jlp-conversion-half-alphanumeric* pat-jlp-conversion-half-alphanumeric))

;furigana
;hiragana
(define-method yahoo:jlp-furigana-hiragana ((obj <yahoo-jp>) query-alist)
  (make-results-alist obj
   *host-jlp* *path-jlp-furigana* query-alist *sxml-path-jlp-furigana-hiragana* pat-jlp-furigana-hiragana))

;roma
(define-method yahoo:jlp-furigana-roma ((obj <yahoo-jp>) query-alist)
  (make-results-alist obj
   *host-jlp* *path-jlp-furigana* query-alist *sxml-path-jlp-furigana-roma* pat-jlp-furigana-roma))

;kousei
(define-method yahoo:jlp-kousei ((obj <yahoo-jp>) query-alist)
  (make-results-alist obj
   *host-jlp* *path-jlp-kousei* query-alist *sxml-path-jlp-kousei* pat-jlp-kousei))

;da-parse
(define-method yahoo:jlp-da-parse ((obj <yahoo-jp>) query-alist)
  (make-results-alist obj
   *host-jlp* *path-jlp-da-parse* query-alist *sxml-path-jlp-da-parse* pat-jlp-da-parse))

;extract
(define-method yahoo:jlp-extract ((obj <yahoo-jp>) query-alist)
  (make-results-alist obj
   *host-jlp* *path-jlp-extract* query-alist *sxml-path-jlp-extract* pat-jlp-extract))

(provide "yahoo-jp") ;0.8.x
