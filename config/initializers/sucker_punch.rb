SuckerPunch.exception_handler = -> (ex, klass, args) do
  Rails.logger.error "suckerpunch exception caught: #{ex} \n#{ex.backtrace.join("\n")}"
  Raven.capture_exception(ex)
end