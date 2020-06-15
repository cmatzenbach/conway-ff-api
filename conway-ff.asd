(asdf:defsystem "conway-ff"
	:description "Simple app for conway's class"
	:version "0.0.1"
	:depends-on ("hunchentoot" "easy-routes" "jonathan")
	:components ((:file "server")
							 (:file "main" :depends-on ("server"))))
