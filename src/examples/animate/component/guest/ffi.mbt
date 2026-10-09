///|
#doc(hidden)
pub fn wasmExportStart() -> Int {
  @async-core.with_waitableset(async fn() {
    @async-core.with_task_group(async fn(background_group) {
      start(background_group)
      start_task_return()
    })
  })
}

///|
fn wasmExportAsyncStartTaskReturn() = "[export]$root" "[task-return]start"

///|
fn start_task_return() -> Unit {
  wasmExportAsyncStartTaskReturn()
  @async-core.task_returned()
}

///|
#doc(hidden)
pub fn wasmExportAsyncStart(event_raw : Int, waitable : Int, code : Int) -> Int {
  @async-core.cb(event_raw, waitable, code)
}
