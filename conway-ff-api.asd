(asdf:defsystem "conway-ff-api"
	:description "Simple app for conway's class"
	:version "0.0.1"
	:depends-on ("hunchentoot" "easy-routes" "jonathan" "mito" "cl-pass")
	:components ((:file "packages")
							 (:file "db" :depends-on ("packages"))
							 (:file "server" :depends-on ("packages"))
							 (:file "main" :depends-on ("server"))))
