(in-package :server)

;; create variable to store acceptor
(defvar *acceptor* nil)

;; start server
(defun start-server ()
  (stop-server)
  (hunchentoot:start (setf *acceptor*
               (make-instance 'easy-routes:easy-routes-acceptor
                              :port 5000))))

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

;; FINALLY got this to work with easy-routes, still same undefined func error as route below
(easy-routes:defroute myusername ("/myusername" :method :get
                                                :decorators (@db @html)) ()
  (let* ((res (dbi:prepare db:*connection* "SELECT * FROM Users WHERE username = ?"))
         (res (dbi:execute res "cmatzenbach")))
    (loop :for row = (dbi:fetch res)
          :while row
          :do (format t "~A~%" row))))

(easy-routes:defroute testlogin ("/testlogin") ()
  (dbi:with-connection (db:*connection*)
    (let* ((query (dbi:prepare conn "SELECT * FROM Users"))
           (query (dbi:execute query)))
      (loop for row = (dbi:fetch query)
            while row
            do (format t "~A~%" row)))))

;; works with hunchentoot easy-handler style syntax
(easy-routes:defroute myuser ("/myuser") ()
  (dbi:fetch-all (dbi:execute (dbi:prepare db:*connection* "SELECT * FROM Users WHERE username = ?") "cmatzenbach")))

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

(defun @db (next)
  (db:*connection*
    (funcall next)))

(defun @html (next)
  (setf (hunchentoot:content-type*) "text/html")
  (funcall next))
