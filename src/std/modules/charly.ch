const CONFIG = __internal__method("__charly_config")

export = {
  const LICENSE         = CONFIG("LICENSE")
  const VERSION         = CONFIG("VERSION")
  const COMPILE_COMMIT  = CONFIG("COMPILE_COMMIT")
  const COMPILE_DATE    = CONFIG("COMPILE_DATE")
  const CHARLYDIR       = ENV["CHARLYDIR"]
}
