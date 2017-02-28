defmodule JokenPlug.RouterTest do
  use ExUnit.Case
  use Plug.Test

  alias JokenPlug.Router

  @opts Router.init([])

  test "generates token properly" do
    conn = conn(:post, "/login") |> Router.call([])
    assert conn.status == 200

    token = conn.resp_body

    conn = conn(:get, "/verify_token")
    |> put_req_header("authorization", "Bearer " <> token)
    |> Router.call([])

    assert conn.status == 200
    assert conn.resp_body == "Hello Tester"
  end

  test "forbids invalid token" do
    conn = conn(:post, "/login") |> Router.call([])
    assert conn.status == 200

    token = "invalid"

    conn = conn(:get, "/verify_token")
    |> put_req_header("authorization", "Bearer " <> token)
    |> Router.call([])

    assert conn.state == :sent
    assert conn.status == 401

  end

  test "returns unauthorized with invalid token" do
    conn = conn(:get, "/", "")
           |> put_req_header("authorization", "invalid-jwt")
           |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
  end

end
