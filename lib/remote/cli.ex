defmodule Remote.CLI do
  @option_parser_opts [
    aliases: [l: :lines, w: :words, c: :chars],
    switches: [chars: :boolean, words: :boolean, lines: :boolean]
  ]

  def main(argv) do
    argv
    |> dbg()
    |> parse_args
    |> IO.inspect()
  end

  defp parse_args(args) do
    OptionParser.parse(args, @option_parser_opts)
  end
end
