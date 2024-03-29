defmodule Remote.Cluster do
  def connect(remote_node) do
    node_name = node()

    if node_name == :nonode@nohost do
      raise("instance not a node")
    end

    cookie = Node.get_cookie()

    if cookie == :nocookie do
      raise("COOKIE not set for the node")
    end

    Node.connect(remote_node)
  end
end
