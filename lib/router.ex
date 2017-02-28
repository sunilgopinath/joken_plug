defmodule JokenPlug.Router do
  use Plug.Router
  import Joken

  @skip_auth private: %{joken_skip: true}

  @is_not_subject private: %{joken_verify: &JokenPlug.Router.is_not_subject/0}

  plug :match
  plug Joken.Plug, verify: &JokenPlug.Router.verify/0
  plug :dispatch

  post "/login", @skip_auth do

    compact = token()
    |> with_sub(1234567890)
    |> sign(hs256("secret"))
    |> get_compact

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, compact)
  end

  get "/verify_token" do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Hello Tester")
  end

  post "/custom_function_failure", @is_not_subject do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "I am subject 1234567890")
  end

  match _, @skip_auth do
    conn
    |> send_resp(404, "Not found")
  end

  def verify() do
    now = current_time()
    %Joken.Token{}
    |> with_json_module(Poison)
    |> with_signer(hs256("secret"))
    |> with_validation("exp", &(&1 > now))
    |> with_validation("iat", &(&1 <= now))
    |> with_sub(1234567890)
  end

  def is_not_subject() do
    %Joken.Token{}
    |> Joken.with_validation("sub", &(&1 != 1234567890))
    |> Joken.with_signer(hs256("secret"))
  end

end
