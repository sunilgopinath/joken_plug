defmodule JokenPlug.Router do
  use Plug.Router
  import Joken

  plug Joken.Plug, verify: &JokenPlug.Router.verify_function/0
  plug :match
  plug :dispatch

  post "/user" do
    # will only execute here if token is present and valid
  end

  match _ do
    # will only execute here if token is present and valid
  end

  def verify_function() do
    %Joken.Token{}
    |> Joken.with_signer(hs256("secret"))
    |> Joken.with_sub(1234567890)
  end
end
