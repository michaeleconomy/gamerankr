SuckerPunch.exception_handler = -> (ex, klass, args) { Raven.capture_exception(ex) }