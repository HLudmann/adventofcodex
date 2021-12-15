defmodule AdventOfCode2021.Day15 do
  def puzzle1() do
    {grid, size} = get_parsed_input()

    # to_visit = Map.keys(grid)
    # distances = to_visit |> Enum.into(%{}, &{&1, :inf}) |> Map.put({0, 0}, 0)

    # %{grid: grid, distances: distances, goal: {size - 1, size - 1}, to_visit: to_visit}
    # |> dijkstra()

    # NOTE: Dijkstra take ~10s, A* ~60ms
    astar(grid, size)
  end

  def puzzle2() do
    {grid, size} = get_parsed_input()
    grid = expend_grid(grid, size)

    # NOTE: Dijkstra take a loooong time : ~6000s
    # to_visit = Map.keys(grid)

    # distances = to_visit |> Enum.into(%{}, &{&1, :inf}) |> Map.put({0, 0}, 0)

    # %{
    #   grid: grid,
    #   distances: distances,
    #   goal: {5 * size - 1, 5 * size - 1},
    #   to_visit: to_visit
    # }
    # |> dijkstra()

    # NOTE: A* takes ~2s
    astar(grid, 5 * size)
  end

  def get_parsed_input do
    input = AdventOfCode2021.get_input(15)

    {input
     |> Enum.with_index()
     |> Enum.reduce(%{}, fn {line, row}, grid ->
       line
       |> String.to_charlist()
       |> Enum.with_index()
       |> Enum.into(%{}, fn {char, col} -> {{row, col}, char - ?0} end)
       |> Map.merge(grid)
     end), length(input)}
  end

  def astar(grid, size) do
    start = {0, 0}
    goal = {size - 1, size - 1}

    neighbours = fn {row, col} ->
      Enum.filter(
        [{row - 1, col}, {row + 1, col}, {row, col - 1}, {row, col + 1}],
        &(grid[&1] != nil)
      )
    end

    weihgted_dist = fn _, node -> grid[node] end
    unweihgted_dist = fn {r1, c1}, {r2, c2} -> abs(r2 - r1) + abs(c2 - c1) end

    Astar.astar({neighbours, weihgted_dist, unweihgted_dist}, start, goal)
    |> Enum.map(&grid[&1])
    |> Enum.sum()
  end

  def expend_grid(grid, size) do
    new_nodes =
      for row <- 0..(size * 5 - 1), col <- 0..(size * 5 - 1), grid[{row, col}] == nil do
        {row, col}
      end

    Enum.reduce(new_nodes, grid, fn {row, col} = node, g ->
      level_rise = div(row, size) + div(col, size)
      init_node = {rem(row, size), rem(col, size)}

      node_value =
        case grid[init_node] + level_rise do
          val when val < 10 -> val
          val -> val - 9
        end

      Map.put(g, node, node_value)
    end)
  end

  def get_min(%{distances: dists, to_visit: to_visit}) do
    Enum.min(to_visit, fn n1, n2 -> dists[n1] <= dists[n2] end)
  end

  def dijkstra(%{grid: grid, distances: dists, goal: e_pt, to_visit: to_visit} = board) do
    cond do
      e_pt not in to_visit ->
        dists[e_pt]

      true ->
        {row, col} = node = get_min(board)
        node_dist = dists[node]

        neighbours =
          Enum.filter(
            [{row - 1, col}, {row + 1, col}, {row, col - 1}, {row, col + 1}],
            &(grid[&1] != nil)
          )

        board
        |> Map.update!(:distances, fn distances ->
          Enum.reduce(neighbours, distances, fn neigh, dists ->
            case {node_dist + grid[neigh], dists[neigh]} do
              {new, old} when old <= new -> dists
              {new, _} -> Map.put(dists, neigh, new)
            end
          end)
        end)
        |> Map.update!(:to_visit, &List.delete(&1, node))
        |> dijkstra()
    end
  end
end
