defmodule AdventOfCodex2022.Day12 do
  def puzzle1() do
    grid = input_to_grid()
    start = find_S(grid)
    exit = find_E(grid)
    grid = grid |> Map.put(exit, ?z) |> Map.put(start, ?a)

    weihgted_dist = fn _, node -> grid[node] - ?a + 1 end
    unweihgted_dist = fn {r1, c1}, {r2, c2} -> abs(r2 - r1) + abs(c2 - c1) end

    Astar.astar({&get_neighbours(grid, &1), weihgted_dist, unweihgted_dist}, start, exit)
    |> Enum.count()
  end

  def puzzle2() do
    grid = input_to_grid()

    exit = find_E(grid)
    grid = grid |> Map.put(exit, ?z) |> Map.put(find_S(grid), ?a)

    weihgted_dist = fn _, node -> grid[node] - ?a + 1 end
    unweihgted_dist = fn {r1, c1}, {r2, c2} -> abs(r2 - r1) + abs(c2 - c1) end

    grid
    |> Map.keys()
    |> Enum.filter(&(grid[&1] == ?a))
    |> Enum.map(fn start ->
      Astar.astar({&get_neighbours(grid, &1), weihgted_dist, unweihgted_dist}, start, exit)
      |> Enum.count()
    end)
    |> Enum.filter(&(&1 != 0))
    |> Enum.min()
  end

  defp input_to_grid() do
    AdventOfCodex2022.read_input(12, trim: true)
    |> Enum.map(&to_charlist/1)
    |> (fn input ->
          ilen = length(input)
          jlen = input |> Enum.at(0) |> length()

          for i <- 0..(ilen - 1), j <- 0..(jlen - 1), into: %{} do
            {{i, j}, input |> Enum.at(i) |> Enum.at(j)}
          end
        end).()
  end

  defp find_E(grid), do: find_val(grid, ?E)
  defp find_S(grid), do: find_val(grid, ?S)

  defp find_val(grid, val) do
    grid
    |> Enum.reduce_while(nil, fn
      {pos, ^val}, _ -> {:halt, pos}
      _, _ -> {:cont, nil}
    end)
  end

  def get_neighbours(grid, pos = {i, j}) do
    for nei <- [{i - 1, j}, {i + 1, j}, {i, j - 1}, {i, j + 1}],
        grid[nei] != nil,
        nei != pos,
        grid[nei] - grid[pos] <= 1 do
      nei
    end
  end
end
