defmodule JokenPlug.RouterTest do
  use ExUnit.Case
  use Plug.Test

  alias JokenPlug.Router

  @opts Router.init([])

  test "returns unauthorized" do
    conn = conn(:get, "/", "")
           |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 401
  end

  test "returns unauthorized with invalid token" do
    conn = conn(:get, "/", "")
           |> put_req_header("authorization", "invalid-jwt")
           |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 401
  end

end
