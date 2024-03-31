defmodule Remote.Projman do
  @moduledoc """
  Projman - A project manager written in elixir.
  """

  import Prompt

  defstruct [:path, :name, :command, :editor]

  # TODO: infer project name from path basename
  # TODO: input "." -> cwd in project path
  # TODO: do something when there's no entry
  # or clustered elixir(store in postgres?). if i use have, think about having a local cache for offline support.
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
    name = get_project_name()
    path = get_project_path()
    editor = get_editor()
    command = get_editor_command(editor)

    project = %__MODULE__{name: name, path: path, command: command, editor: editor}

    if entry_exists?(project) do
      display("The project entry already exists.", color: :red)
    else
      save_entry(project)
      display("The project entry added.", color: :green)
    end
  end

  def list_all_entries() do
    startup()

    entries = get_entries()

    choice_entries =
      entries
      |> Enum.with_index()
      |> Enum.map(fn {entry, index} ->
        {"#{entry.name}\t#{entry.editor}\t#{entry.path}", index}
      end)

    selected_index = select("Open project:", choice_entries)
    project = Enum.at(entries, selected_index)

    # TODO: perhaps use System.find_executable() first
    # System.shell("#{editor_command} #{project_path}")
    # TODO: how to execute cli based editor
    System.cmd(project.command, [project.path], stderr_to_stdout: true)

    display("Opening project: #{project.name}", color: :light_blue)
  end

  def update_entry() do
    startup()

    entries = get_entries()

    choice_entries =
      entries
      |> Enum.with_index()
      |> Enum.map(fn {entry, index} ->
        {"#{entry.name}\t#{entry.editor}\t#{entry.path}", index}
      end)

    selected_index = select("Update project:", choice_entries)
    project = Enum.at(entries, selected_index)

    name = get_project_name(default_answer: project.name)
    path = get_project_path(default_answer: project.path)
    display("(Default editor: #{project.editor})", color: :light_blue)
    editor = get_editor()
    command = get_editor_command(editor)

    List.update_at(entries, selected_index, fn _ ->
      %__MODULE__{name: name, path: path, editor: editor, command: command}
    end)
    |> save_entries()

    display("Project entry updated.", color: :green)
  end

  def delete_entry() do
    startup()

    entries = get_entries()

    choice_entries =
      entries
      |> Enum.with_index()
      |> Enum.map(fn {entry, index} ->
        {"#{entry.name}\t#{entry.editor}\t#{entry.path}", index}
      end)

    selected_index = select("Delete project:", choice_entries)

    List.delete_at(entries, selected_index)
    |> save_entries()

    display("Project entry deleted.", color: :red)
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

  defp get_project_name(opts \\ []) do
    default_answer = Keyword.get(opts, :default_answer, "")
    min_length = if String.length(default_answer) == 0, do: 1, else: 0

    case text("Project Name",
           color: :light_blue,
           min: min_length,
           max: 128,
           trim: true,
           default_answer: default_answer
         ) do
      :error_min ->
        display("Invalid project name.", color: :red)
        get_project_name(opts)

      :error_max ->
        display("Project name too long.", color: :red)
        get_project_name(opts)

      "" ->
        default_answer

      val ->
        val
    end
  end

  defp get_project_path(opts \\ []) do
    default_answer = Keyword.get(opts, :default_answer, "")
    current_path = if String.length(default_answer) == 0, do: File.cwd!(), else: default_answer

    case text("Project Path",
           color: :light_blue,
           max: 128,
           trim: true,
           default_answer: current_path
         ) do
      :error_min ->
        display("Invalid project path.", color: :red)
        get_project_path(opts)

      :error_max ->
        display("Project path too long.", color: :red)
        get_project_path(opts)

      "" ->
        current_path

      val ->
        # TODO: use fixed path instead
        # Path.expand(path)
        val
    end
  end

  defp get_editor() do
    select("Editor", ["VSCode", "Zed", "Neovim"], color: :light_blue)
  end

  defp get_editor_command(editor) do
    case editor do
      "VSCode" -> "code"
      "Zed" -> "zed"
      "Neovim" -> "nvim"
    end
  end

  # TODO: think about storing the data to postgres(through remote node)

  defp startup() do
    # Run the necessary step before a command
    check_or_create_entries_store()
  end

  defp check_or_create_entries_store() do
    if not File.exists?(@entries_storage_path), do: reset_entries_store()
  end

  defp entry_exists?(%__MODULE__{} = entry) do
    entry =
      get_entries()
      |> Enum.find(fn project -> project == entry end)

    if entry == nil, do: false, else: true
  end

  defp save_entries(entries) do
    entries =
      Enum.map(entries, fn entry -> [entry.name, entry.editor, entry.command, entry.path] end)

    write_to_entries_store(entries)
  end

  defp save_entry(%__MODULE__{} = entry) do
    # we are storing the data as [[name, editor, command, path]]
    project_info = [entry.name, entry.editor, entry.command, entry.path]
    entries = read_entries_store()
    updated_entries = [project_info | entries]
    write_to_entries_store(updated_entries)
  end

  defp get_entries() do
    read_entries_store()
    |> Enum.map(fn [name, editor, command, path] ->
      %__MODULE__{name: name, path: path, editor: editor, command: command}
    end)
  end

  defp write_to_entries_store(entries),
    do: File.write!(@entries_storage_path, Jason.encode!(entries))

  defp read_entries_store(), do: File.read!(@entries_storage_path) |> Jason.decode!()
  defp reset_entries_store(), do: File.write!(@entries_storage_path, "[]")

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
end
