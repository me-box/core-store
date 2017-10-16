open Lwt;
open Cohttp_lwt_unix;

module Constants = {
  let arbiter_endpoint = "https://arbiter:8080/store/secret";
  let arbiter_token_file = "/run/secrets/ARBITER_TOKEN";
  let store_key_file = "/run/secrets/ZMQ_SECRET_KEY";
  let zest_binary = "/app/zest/server.exe";
  let identity = Sys.getenv "DATABOX_LOCAL_NAME";
  let store_dir = "/database";
};

let token_from_file () => {
  Fpath.v Constants.arbiter_token_file |> 
    Bos.OS.File.read |> 
      Rresult.R.get_ok |> 
        B64.encode;
};

let key_from_file () => {
  Fpath.v Constants.store_key_file |> 
    Bos.OS.File.read |> 
      Rresult.R.get_ok
};

let get_macaroon_secret arbiter_token => {
  let key = [("X-Api-Key", arbiter_token)];
  let headers = Cohttp.Header.of_list key;
  Client.get ::headers (Uri.of_string Constants.arbiter_endpoint) >>=
    fun (_, body) => body |> Cohttp_lwt_body.to_string
};

let exec cmd => {
  Lwt_process.exec cmd >>=
    fun _ => Lwt.return_unit;
};

let make_cmd macaroon_key curve_key => {
  open Constants;
  let _ = Lwt_io.printf "Starting %s --secret-key %s --token-key %s --identity %s --store-dir %s\n" zest_binary curve_key macaroon_key identity store_dir;
  (zest_binary, [|zest_binary, "--secret-key", curve_key, "--token-key", macaroon_key, "--identity", identity, "--store-dir", store_dir, "--enable-logging"|]);
};

let bootstrap with::token and::key => {
  get_macaroon_secret token >>=
    fun secret =>
      exec (make_cmd secret key);
};

let report_error e => {
  let msg = Printexc.to_string e;
  let stack = Printexc.get_backtrace ();
  let _ = Lwt_log_core.error_f "Opps: %s%s" msg stack;
};

let _ = try {Lwt_main.run {bootstrap with::(token_from_file ()) and::(key_from_file ())}} {
  | e => report_error e;
};