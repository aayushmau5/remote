defmodule Remote.Cluster do
  def make_self_node() do
    {:ok, _} = Node.start(:remote, :shortnames)

    cookie = System.get_env("REMOTE_COOKIE") |> String.to_atom()
    Node.set_cookie(node(), cookie)
  end

  def connect_to_remote_node() do
    # TODO: add nil check, and throw(or switch to local copy?) if remote connection failed
    remote_node = System.get_env("REMOTE_REMOTE_NODE") |> String.to_atom()
    IO.inspect(remote_node)
    IO.inspect(node())
    IO.inspect(Node.get_cookie())
    IO.inspect(Node.connect(remote_node))
  end
end
