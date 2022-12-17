defmodule AdventOfCodex2022.Day7 do
  def puzzle1() do
    %{tree: tree, dirs: dirs} = get_tree_and_dirs_from_input()

    Enum.map(dirs, &get_in(tree, &1 ++ [:size]))
    |> Enum.filter(&(&1 <= 100_000))
    |> Enum.sum()
  end

  @disk_size 70_000_000
  @size_needed 30_000_000
  def puzzle2() do
    %{tree: tree, dirs: dirs} = get_tree_and_dirs_from_input()
    to_empty = tree["/"][:size] + @size_needed - @disk_size


    Enum.map(dirs, &get_in(tree, &1 ++ [:size]))
    |> Enum.filter(&(&1 >= to_empty))
    |> Enum.min()
  end

  defp get_tree_and_dirs_from_input() do
    AdventOfCodex2022.read_input(7, trim: true)
    |> Enum.reduce(%{tree: %{}, dirs: [], pwd: []}, fn
      "$ ls", arbo ->
        arbo

      "$ cd ..", arbo ->
        update_dir_size(arbo)

      "$ cd " <> dir, %{tree: tree, dirs: dirs, pwd: pwd} ->
        new_pwd = pwd ++ [dir]
        %{tree: tree |> put_in(new_pwd, %{size: 0}), dirs: dirs ++ [new_pwd], pwd: new_pwd}

      "dir " <> _, acc ->
        acc

      line, arbo = %{tree: tree, pwd: pwd} ->
        [size, name] = String.split(line, " ", trim: true)
        size = String.to_integer(size)

        new_tree = tree |> put_in(pwd ++ [name], size) |> update_in(pwd ++ [:size], &(&1 + size))
        %{arbo | tree: new_tree}
    end)
    |> propagate_last_sizes()
  end

  defp update_dir_size(arbo = %{tree: tree, pwd: pwd}) do
    new_pwd = pwd |> Enum.take(length(pwd) - 1)
    new_tree = tree |> update_in(new_pwd ++ [:size], &(&1 + get_in(tree, pwd ++ [:size])))
    %{arbo | tree: new_tree, pwd: new_pwd}
  end

  defp propagate_last_sizes(arbo = %{pwd: ["/"]}), do: arbo
  defp propagate_last_sizes(arbo), do: arbo |> update_dir_size() |> propagate_last_sizes()
end
