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

;; of course this  works but the loop example from the README doesn't
;; (easy-routes:defroute testgetdata ("/testgetdata" :method :get) ()
;;   (dbi:with-connection (conn :mysql :database-name "fantasy_football" :host "conway-ff1.cctpeqxowyn7.us-east-2.rds.amazonaws.com" :port 3306 :username "matzy" :password "Paintitred1")
;;     (let* ((query (dbi:prepare conn "SELECT * FROM Users"))
;;            (query (dbi:execute query)))
;;       (format nil "~a" (dbi:fetch query)))))
;; (loop for row = (dbi:fetch query)
;;       while row
;;       do (format nil "~A~%" row))


;; FINALLY got it to work - does not look like it's opening extra connections either
;; (easy-routes:defroute myusername ("/myusername" :method :get) ()
;;   (let* ((query (dbi:prepare db:*connection* "SELECT * FROM Users WHERE username = ?"))
;;          (results (dbi:execute query "cmatzenbach")))
;;     (format nil "~a" (dbi:fetch results))))
;; (loop for row = (dbi:fetch query)
;;       while row
;;       do (format nil "~a~%" row))

;; second hack at it, from SO
;; ;; https://stackoverflow.com/questions/31745456/cl-dbi-query-mysql-from-sbcl-with-error-illegal-utf-8-character-starting-at-p
;; (easy-routes:defroute myuser2 ("/testusertwo") ()
;;   (setf query (dbi:prepare db:*connection*
;;                            "SELECT * FROM Users"))
;;   (setf result (dbi:execute query))
;;   (loop for row = (dbi:fetch result)
;;         while row
;;         do (format t "~A~%" row)))

;; probably ideal query response, but persistent connection required, so prob need funcs above
;; also hangs for awhile - all in one go query relying on persistent connection
;; (easy-routes:defroute createuser ("/createuser" :method :post) (&post user pass team)
;;   (setf (hunchentoot:content-type*) "text/plain")
;;   (dbi:do-sql db:*connection*
;;     "INSERT INTO Users (username, password, team_name) VALUES (?, ?, ?)"
;;     (list user pass team))
;;   ;; (dbi:do-sql db:*connection*
;;   ;;   "INSERT INTO Users (username, password, team_name) VALUES (?, ?, ?)"
;;   ;;   (list 0))
;;   (format nil " user: ~a | pass: ~a | team-two: ~a" user pass team))

;; format nil doesn't go to stdout, but rather prints to page (output stream?)
(easy-routes:defroute printpath ("/print") (x y)
  (format nil "~a   ~a" x y))

(easy-routes:defroute name ("/foo/:x") (y &get z)
  (format nil "x: ~a y: ~a z: ~a" x y z))

;; first ever route!
(easy-routes:defroute yo ("/yo") (name)
  (setf (hunchentoot:content-type*) "text/plain")
  (format nil "Hey~@[ ~A~]!" name))

;; test getting data from GET vars in url
(easy-routes:defroute getvars ("/getvars") (x &get y z)
  (format nil "x: ~a  y: ~a  z: ~a" x y z))

;; (easy-routes:defroute printconn ("/printconn") ()
;;   (format nil "x: ~a" db:*connection*))

;; route to store page views
(easy-routes:defroute views ("/store_page_views") ()
  (setf (hunchentoot:content-type*) "text/plain")
  ;; for now, print out that page is viewed, later store in database
  (incf *page-views*)
  ;; TODO doesn't print to page for some reason
  (format nil "~d" *page-views*))

;; decorators
(defun @json (next)
  (setf (hunchentoot:content-type*) "application/json")
  (funcall next))

;; custom decorator to set Access-Control-Allow-Origin
(defun @allow-origin (next)
  (setf (hunchentoot:header-out :Access-Control-Allow-Origin hunchentoot:*reply*) "*")
  (funcall next))

;; TODO Figure out how to build this decorator with cl-di - example is for postmodern
;; (defun @db (next)
;;   (db:*connection*
;;     (funcall next)))

(defun @html (next)
  (setf (hunchentoot:content-type*) "text/html")
  (funcall next))
