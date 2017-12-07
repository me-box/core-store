open Lwt;
open Cohttp_lwt_unix;

module Constants = {
  let arbiter_endpoint = "https://arbiter:8080/store/secret";
  let arbiter_token_file = "/run/secrets/ARBITER_TOKEN";
  let curve_key_file = "/run/secrets/ZMQ_SECRET_KEY";
  let token_key_file = "/tmp/TOKEN_KEY";
  let zest_binary = "/app/zest/server.exe";
  let identity = Sys.getenv "DATABOX_LOCAL_NAME";
  let store_dir = "/database";
};

let get_arbiter_token () => {
  Fpath.v Constants.arbiter_token_file |> 
    Bos.OS.File.read |> 
      Rresult.R.get_ok |> 
        B64.encode;
};


let get_macaroon_secret arbiter_token => {
  let key = [("X-Api-Key", arbiter_token)];
  let headers = Cohttp.Header.of_list key;
  Client.get ::headers (Uri.of_string Constants.arbiter_endpoint) >>=
    fun (_, body) => body |> Cohttp_lwt_body.to_string
};

let write_macaroon_secret secret => {
  Bos.OS.File.write (Fpath.v Constants.token_key_file) secret;
};

let exec cmd => {
  Lwt_process.exec cmd >>=
    fun _ => Lwt.return_unit;
};

let make_cmd () => {
  open Constants;
  let _ = Lwt_io.printf "Starting %s --secret-key-file %s --token-key-file %s --identity %s --store-dir %s\n" zest_binary curve_key_file token_key_file identity store_dir;
  (zest_binary, [|zest_binary, "--secret-key-file", curve_key_file, "--token-key-file", token_key_file, "--identity", identity, "--store-dir", store_dir|]);
};

let bootstrap () => {
  get_arbiter_token () |>
    get_macaroon_secret >>=
      fun key => write_macaroon_secret key |>
        fun _ => make_cmd () |> exec;
};

let report_error e => {
  let msg = Printexc.to_string e;
  let stack = Printexc.get_backtrace ();
  let _ = Lwt_log_core.error_f "Opps: %s%s" msg stack;
};

let _ = try {Lwt_main.run {bootstrap ()}} {
  | e => report_error e;
};