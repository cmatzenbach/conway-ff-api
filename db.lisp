(defpackage :db
	(:use cl)
	(:export
	 :connect-db
	 :disconnect-db
	 :add-user
   :modify-user))

(in-package :db)

;;;; Helper functions

(defun connect-db ()
  "Connect to the database"
  (mito:connect-toplevel :mysql
                         :database-name "fantasy_football"
                         :host "ff-fitness1-instance-1.cabjcsqo5uku.us-east-2.rds.amazonaws.com"
                         :port 3306
                         :username "matzy"
                         :password "Paintitred1"))

(defun disconnect-db ()
  (mito:disconnect-toplevel))


;;;; Database tables setup

;; users table (using mito macro)
(mito:deftable users ()
  ((username :col-type (:varchar 128))
   (password :col-type (:varchar 255))
   (team-name :col-type (:varchar 255)))
  (:conc-name my-))

;; TODO returning false right now, despite table appearing in mysql
(defun check-users-table ()
  (mito:ensure-table-exists 'users))


;;;; migration functions

;; create USERS table
(defun create-users-table ()
  (mapc #'mito:execute-sql (mito:table-definition 'users)))


;;;; CRUD Operations
(defun add-user (user pass team)
  (mito:create-dao 'users :username user :password (cl-pass:hash pass) :team-name team))

;; (defun modify-user (&key (user nil user-supplied-p) (pass nil pass-supplied-p) (team nil team-supplied-p))
;;   (values
;;     ((not user-supplied-p) (mito:create-dao 'users :username user))
;;     ((not pass-supplied-p) (mito:create-dao 'users :password (cl-pass:hash pass)))
;;     ((not team-supplied-p) (mito:create-dao 'users :team-name team))))

