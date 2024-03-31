defmodule Remote.CLI do
  alias Remote.{Projman}

  @option_parser_opts [
    strict: [
      help: :boolean,
      fun: :string,
      bin: :string
    ],
    aliases: [
      h: :help,
      f: :fun,
      b: :bin
    ]
  ]

  def main(argv) do
    args = parse_args(argv)

    # Clustering
    # let's make it a flag for "sync | pull"?
    # TODO: async connect to remote node
    # Cluster.make_self_node()
    # Cluster.connect_to_remote_node()
    # Prompt.display("Connected to remote node.", color: :green)
    # IO.inspect(Node.list(), label: "list")
    # IO.inspect(Node.list(:hidden), label: "hidden")

    # Run the CLI
    run(args)
  end

  defp run(params) do
    case params do
      [help: true] ->
        show_help()

      [fun: command] ->
        Projman.run(command)

      _ ->
        show_help()
        IO.inspect(params)
        # [bin: command] -> Bin.run(command)
    end
  end

  defp parse_args(args) do
    OptionParser.parse(args, @option_parser_opts)
    |> elem(0)
  end

  defp show_help() do
    IO.puts("""
    Commands:
    --bin
    --fun new | list | update | delete
    """)
  end
end
