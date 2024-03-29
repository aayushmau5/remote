defmodule Remote.CLI do
  alias Remote.{Projman, Bin}

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
    argv
    |> parse_args
    |> run()
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
