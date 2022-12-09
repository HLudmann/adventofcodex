defmodule AdventOfCode2022.Day8 do
  def puzzle1() do
    {grid, size} = input_to_grid_n_size()

    for i <- 1..size, j <- 1..size do
      is_visible(grid, size, i, j)
    end
    |> Enum.filter(& &1)
    |> Enum.count()
  end

  def puzzle2() do
    {grid, size} = input_to_grid_n_size()

    for i <- 1..size, j <- 1..size do
      [
        view_dist_up(grid, i, j),
        view_dist_right(grid, i, j, size),
        view_dist_down(grid, i, j, size),
        view_dist_left(grid, i, j)
      ]
    end
    |> Enum.map(&Enum.product/1)
    |> Enum.max()
  end

  defp input_to_grid_n_size() do
    input =
      AdventOfCode2022.read_input(8, trim: true)
      |> Enum.map(fn line ->
        line |> String.split("", trim: true) |> Enum.map(&String.to_integer/1)
      end)

    size = length(input)

    grid =
      for i <- 1..size, j <- 1..size, into: %{} do
        {{i, j}, input |> Enum.at(i - 1) |> Enum.at(j - 1)}
      end

    {grid, size}
  end

  defp is_visible(grid, size, i, j)
  defp is_visible(_, _, 1, _), do: true
  defp is_visible(_, _, _, 1), do: true
  defp is_visible(_, size, size, _), do: true
  defp is_visible(_, size, _, size), do: true

  defp is_visible(grid, size, i, j) do
    is_higher(Enum.map(1..(i - 1), &grid[{&1, j}]), grid[{i, j}]) ||
      is_higher(Enum.map((i + 1)..size, &grid[{&1, j}]), grid[{i, j}]) ||
      is_higher(Enum.map(1..(j - 1), &grid[{i, &1}]), grid[{i, j}]) ||
      is_higher(Enum.map((j + 1)..size, &grid[{i, &1}]), grid[{i, j}])
  end

  defp is_higher(list, value), do: Enum.max(list) < value

  defp view_dist_up(grid, i, j)
  defp view_dist_up(_, 1, _), do: 0

  defp view_dist_up(grid, i, j) do
    view_dist(grid[{i, j}], (i - 1)..1, &grid[{&1, j}])
  end

  defp view_dist_left(grid, i, j)
  defp view_dist_left(_, _, 1), do: 0

  defp view_dist_left(grid, i, j) do
    view_dist(grid[{i, j}], (j - 1)..1, &grid[{i, &1}])
  end

  defp view_dist_down(grid, i, j, size)
  defp view_dist_down(_, size, _, size), do: 0

  defp view_dist_down(grid, i, j, size) do
    view_dist(grid[{i, j}], (i + 1)..size, &grid[{&1, j}])
  end

  defp view_dist_right(grid, i, j, size)
  defp view_dist_right(_, _, size, size), do: 0

  defp view_dist_right(grid, i, j, size) do
    view_dist(grid[{i, j}], (j + 1)..size, &grid[{i, &1}])
  end

  defp view_dist(tree, range, value_fn) do
    Enum.reduce_while(range, 0, fn x, acc ->
      case value_fn.(x) < tree do
        true -> {:cont, acc + 1}
        false -> {:halt, acc + 1}
      end
    end)
  end
end
