(defpackage :server
	(:use cl)
	(:export
   :start-server
   :stop-server))

(defpackage :db
	(:export *connection*))
