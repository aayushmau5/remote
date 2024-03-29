defmodule Remote.Projman do
  @moduledoc """
  Projman - A project manager written in elixir.
  """
  # what if we use sqlite?
  # or clustered elixir(store in postgres?)
  @entries_storage_path Path.join([System.user_home!(), ".config", "projman-config.json"])

  def run(command) do
    case command do
      "new" -> create_new_project_entry()
      "list" -> list_all_entries()
      "update" -> update_entry()
      "delete" -> delete_entry()
      _ -> show_help()
    end
  end

  def create_new_project_entry() do
    startup()
    # List all the files
    # or
  end

  def list_all_entries() do
    startup()

    json_entries = read_entries_store()
    IO.inspect(json_entries)
  end

  def update_entry() do
    startup()
  end

  def delete_entry() do
    startup()
  end

  defp show_help() do
    IO.puts("""
    Projman:

    opts:
    \tnew
    \tlist
    \tupdate
    \tdelete
    """)
  end

  defp startup() do
    # Run the necessary step before a command
    check_or_create_entries_store()
  end

  # TODO: think about storing the data to postgres(through remote node)

  defp check_or_create_entries_store() do
    # TODO: think about the structure of storage
    if not File.exists?(@entries_storage_path), do: File.write!(@entries_storage_path, "{}")
  end

  defp write_to_entries_store(data), do: File.write!(@entries_storage_path, Jason.encode!(data))
  defp read_entries_store(), do: File.read!(@entries_storage_path) |> Jason.decode!()
  defp reset_entries_store(), do: File.write!(@entries_storage_path, "{}")

  #   def add_project(project_path, project_name, editor_command) do
  #     Config.check_config()
  #     project_config_key = create_project_key(project_name, editor_command)

  #     config_data = Config.get_config()

  #     if record_exists?(config_data, project_config_key) do
  #       IO.ANSI.format([:red, "The project entry already exists"]) |> IO.puts()
  #     else
  #       project_config_data = %{
  #         project_path: project_path,
  #         project_name: project_name,
  #         editor_command: editor_command
  #       }

  #       config_data = update_config(config_data, project_config_key, project_config_data)
  #       Config.write_config(config_data)

  #       IO.ANSI.format([:green, "Project entry added"]) |> IO.puts()
  #     end
  #   end

  #   def list_projects() do
  #     Config.get_config()
  #     |> Enum.map(fn {k, v} ->
  #       Map.put(v, "id", k)
  #     end)
  #   end

  #   def open_project(project) do
  #     project_path = project["project_path"]
  #     editor_command = project["editor_command"]
  #     # TODO: perhaps use System.find_executable() first
  #     # TODO: how to execute cli based editor
  #     # System.shell("#{editor_command} #{project_path}")
  #     System.cmd(editor_command, [project_path], stderr_to_stdout: true)
  #   end

  #   def update_project(key, project_data) do
  #     Config.get_config() |> Map.put(key, project_data) |> Config.write_config()
  #   end

  #   def delete_project(project) do
  #     Config.get_config() |> Map.delete(project["id"]) |> Config.write_config()
  #   end

  #   defp create_project_key(project_name, editor_command) do
  #     project_name = String.downcase(project_name) |> String.replace(~r/\s/, "-")
  #     editor_command = String.downcase(editor_command)
  #     "#{project_name}-#{editor_command}"
  #   end

  #   defp record_exists?(config, key) do
  #     case Map.fetch(config, key) do
  #       {:ok, _} -> true
  #       :error -> false
  #     end
  #   end

  #   defp update_config(config, key, value) do
  #     Map.put(config, key, value)
  #   end
  # end

  # defmodule Config do
  #   @config_file_path Path.join([System.user_home!(), ".config", "projman-config.json"])

  #   def check_config() do
  #     if not File.exists?(@config_file_path), do: File.write!(@config_file_path, "{}")
  #   end

  #   def write_config(data), do: File.write!(@config_file_path, Jason.encode!(data))
  #   def get_config(), do: File.read!(@config_file_path) |> Jason.decode!()
  #   def reset_config(), do: File.write!(@config_file_path, "{}")
  # end

  # defmodule Shell do
  #   def run() do
  #     IO.puts("""
  #     l - List all projects
  #     n - Create a new entry
  #     d - Delete an entry
  #     m - Modify an entry
  #     r - Reset the config
  #     q - Quit
  #     """)

  #     # IO.getn() doesn't work for some reason
  #     IO.gets("> ") |> String.trim() |> handle_command()
  #   end

  #   def handle_command("l") do
  #     projects = list_projects()

  #     {_, projects_list_string} = list_projects_with_number(projects)
  #     IO.puts(projects_list_string)

  #     selected_project_index =
  #       IO.gets("Select the project number > ") |> String.trim() |> String.to_integer()

  #     selected_project = Enum.at(projects, selected_project_index - 1)

  #     IO.ANSI.format([:yellow, "Opening project"]) |> IO.puts()

  #     open_project(selected_project)
  #   end

  #   def handle_command("n") do
  #     IO.ANSI.format([:blue_background, "Create a new project entry"]) |> IO.puts()

  #     # TODO: perhaps sanitize project name?
  #     # TODO: add relative paths
  #     project_path =
  #       IO.gets(
  #         "What will be the path to the project?(Just press enter for current working directory path)\n> "
  #       )
  #       |> get_value_without_newline(File.cwd!())

  #     project_name =
  #       IO.gets(
  #         "What will be the name of the project?(Just press enter for selected directory)\n> "
  #       )
  #       |> get_value_without_newline(Path.basename(project_path))

  #     IO.puts("""
  #     Which editor do you want to open the project in?(Default: VSCode)
  #     - VSCode(type: code)
  #     - Vim(type: vim)
  #     - Neovim(type: nvim)
  #     - Atom(type: atom)
  #     - Add your own? Type the command
  #     """)

  #     # TODO: validate editor_command input
  #     editor_command =
  #       IO.gets("> ")
  #       |> get_value_without_newline("code")

  #     add_project(project_path, project_name, editor_command)
  #   end

  #   def handle_command("d") do
  #     projects = list_projects()

  #     {_, projects_list} = list_projects_with_number(projects)
  #     IO.puts(projects_list)

  #     selected_project_index =
  #       IO.gets("Select the project number which you want to delete > ")
  #       |> String.trim()
  #       |> String.to_integer()

  #     selected_project = Enum.at(projects, selected_project_index - 1)

  #     IO.ANSI.format([:red, "Deleting project"]) |> IO.puts()
  #     delete_project(selected_project)
  #   end

  #   def handle_command("m") do
  #     projects = Projman.list_projects()

  #     {_, projects_list} = list_projects_with_number(projects)
  #     IO.puts(projects_list)

  #     selected_project_index =
  #       IO.gets("Select the project number which you want to update > ")
  #       |> String.trim()
  #       |> String.to_integer()

  #     selected_project = Enum.at(projects, selected_project_index - 1)

  #     project_path =
  #       IO.gets(
  #         "What will be the path to the project?(Current Value: #{selected_project["project_path"]})\n> "
  #       )
  #       |> get_value_without_newline(selected_project["project_path"])

  #     project_name =
  #       IO.gets(
  #         "What will be the name of the project?(Current Value: #{selected_project["project_name"]})\n> "
  #       )
  #       |> get_value_without_newline(selected_project["project_name"])

  #     IO.puts("""
  #     Which editor do you want to open the project in?(Current Value: #{selected_project["editor_command"]})
  #     - VSCode(type: code)
  #     - Vim(type: vim)
  #     - Neovim(type: nvim)
  #     - Atom(type: atom)
  #     - Add your own? Type the command
  #     """)

  #     # TODO: validate editor_command input
  #     editor_command =
  #       IO.gets("> ")
  #       |> get_value_without_newline(selected_project["editor_command"])

  #     update_project(
  #       selected_project["id"],
  #       %{
  #         project_path: project_path,
  #         project_name: project_name,
  #         editor_command: editor_command
  #       }
  #     )
  #   end

  #   def handle_command("r") do
  #     IO.ANSI.format([:red, "Removing project entries"]) |> IO.puts()
  #     Config.reset_config()
  #   end

  #   def handle_command("q") do
  #     IO.ANSI.format([:green, "Goodbye"]) |> IO.puts()
  #   end

  #   def handle_command(_) do
  #     IO.ANSI.format([:red, "Invalid command. Please try again."]) |> IO.puts()
  #     run()
  #   end

  #   defp get_value_without_newline(input, default) do
  #     input = String.trim(input)

  #     if String.length(input) > 0 do
  #       input
  #     else
  #       default
  #     end
  #   end

  #   defp list_projects_with_number(projects) do
  #     Enum.reduce(projects, {1, ""}, fn project, {project_index, output_string} ->
  #       project_output =
  #         "#{project_index}. #{project["project_name"]} - #{project["project_path"]} - #{project["editor_command"]}\n"

  #       {project_index + 1, output_string <> project_output}
  #     end)
  #   end
end
