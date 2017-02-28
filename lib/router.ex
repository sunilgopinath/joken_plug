defmodule JokenPlug.Router do
  use Plug.Router
  import Joken

  @skip_auth private: %{joken_skip: true}
  @is_admin private: %{joken_verify: &JokenPlug.Router.is_admin/0}

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

  post "/add_claims", @skip_auth do
    token = %Joken.Token{}
    |> with_sub("elixir")
    |> with_claims(%{role: "admin"})
    |> sign(hs512("elixrdemo"))
    |> get_compact

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, token)
  end

  get "/verify_token" do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Hello Tester")
  end

  get "/admin", @is_admin do
    ["Bearer " <> incoming_token] = get_req_header(conn, "authorization")
    role = incoming_token
    |> token
    |> peek

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Hello " <> Map.get(role, "role"))
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

  def is_admin() do
    %Joken.Token{}
    |> with_json_module(Poison)
    |> with_validation("role", &(&1 == "admin"))
    |> with_signer(hs512("elixrdemo"))
  end

end
