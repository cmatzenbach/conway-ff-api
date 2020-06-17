(defpackage :server
	(:use cl)
	(:export
   #:start-server
   #:stop-server))

(in-package :server)

;; load dependenciesfor teseting in slime, will be compiled in asdf and shouldn't be re-ran
;; (ql:quickload :hunchentoot)
;; (ql:quickload :hunchentoot-test)
;; (ql:quickload :easy-routes)
;; (ql:quickload :jonathan)

;; create variable to store acceptor
(defvar *acceptor* nil)

;; start server
(defun start-server ()
  (server:stop-server)
  (hunchentoot:start (setf *acceptor*
               (make-instance 'easy-routes:easy-routes-acceptor
                              :port 4246))))

;; function to stop server
(defun stop-server ()
  (when *acceptor*
    (when (hunchentoot:started-p *acceptor*)
          (hunchentoot:stop *acceptor*))))

;; try to set global server settings here
;; (setf (hunchentoot:header-out "Access-Control-Allow-Origin") "*")
;; (setf (hunchentoot:header-out "Access-Control-Allow-Methods") "POST,GET,OPTIONS,DELETE,PUT")
;; (setf (hunchentoot:header-out "Access-Control-Max-Age") 1000)
;; (setf (hunchentoot:header-out "Access-Control-Allow-Headers") "x-requested-with, Content-Encoding, Content-Type, origin, authorization, accept, client-security-token")
;; (setf (hunchentoot:header-out "Content-Type") "application/json")

;; global vars
(defvar *page-views* 0)

;; simple route for testing front-end axios calls
(easy-routes:defroute project ("/matzy" :method :get) (home)
  (setf (hunchentoot:content-type*) "text/plain")
  (format nil "~a" home))

;; route to use jonathan to send JSON data back to FE
(easy-routes:defroute testjson ("/testjson" :method :get
                                            :decorators (@json @allow-origin)) ()
  (jonathan.encode:to-json '(:name "Common Lisp" :born 1984 :impls (SBCL KCL))))

(easy-routes:defroute name ("/foo/:x") (y &get z)
  (format nil "x: ~a y: ~a z: ~a" x y z))

;; first ever route!
(easy-routes:defroute yo ("/yo") (name)
  (setf (hunchentoot:content-type*) "text/plain")
  (format nil "Hey~@[ ~A~]!" name))

;; test getting data from GET vars in url
(easy-routes:defroute getvars ("/getvars") (x &get y z)
  (format nil "x: ~a  y: ~a  z: ~a" x y z))

;; route to store page views
(easy-routes:defroute views ("/store_page_views") ()
  (setf (hunchentoot:content-type*) "text/plain")
  ;; for now, print out that page is viewed, later store in database
  (incf *page-views*)
  (format t "~d" *page-views*))

;; decorators
(defun @json (next)
  (setf (hunchentoot:content-type*) "application/json")
  (funcall next))

;; custom decorator to set Access-Control-Allow-Origin
(defun @allow-origin (next)
  (setf (hunchentoot:header-out :Access-Control-Allow-Origin hunchentoot:*reply*) "*")
  (funcall next))
