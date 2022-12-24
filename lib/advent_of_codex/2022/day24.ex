defmodule AdventOfCodex2022.Day24 do
  def puzzle1() do
    input_to_grid()
    |> find_shortest_path(:north_exit, :south_exit)
    |> elem(1)
  end

  def puzzle2() do
    input_to_grid()
    |> find_shortest_path(:north_exit, :south_exit)
    |> tap(fn {_, minute} -> IO.puts("1 way in #{minute}") end)
    |> (fn {grid, minute} -> find_shortest_path(grid, :south_exit, :north_exit, minute) end).()
    |> tap(fn {_, minute} -> IO.puts("2 ways in #{minute}") end)
    |> (fn {grid, minute} -> find_shortest_path(grid, :north_exit, :south_exit, minute) end).()
    |> tap(fn {_, minute} -> IO.puts("3 ways in #{minute}") end)
    |> elem(1)
  end

  defp input_to_grid() do
    AdventOfCodex2022.read_input(24, trim: true)
    |> Enum.drop(1)
    |> Enum.drop(-1)
    |> Enum.map(fn line ->
      line
      |> String.split("", trim: true)
      |> Enum.drop(1)
      |> Enum.drop(-1)
      |> Enum.with_index()
    end)
    |> Enum.with_index()
    |> (&(for row <- &1,
              col <- elem(row, 0),
              i = elem(row, 1),
              j = elem(col, 1),
              val = elem(col, 0),
              into: %{} do
            {{i, j}, val}
          end)).()
    |> (fn map ->
          max_row = map |> Map.keys() |> Enum.max_by(&elem(&1, 0)) |> elem(0)
          max_col = map |> Map.keys() |> Enum.max_by(&elem(&1, 1)) |> elem(1)

          %{
            map: map,
            maxes: {max_row, max_col},
            north_exit: {-1, 0},
            south_exit: {max_row + 1, max_col}
          }
        end).()
    |> Map.update!(
      :map,
      &(Map.filter(&1, fn {_, val} -> val != "." end)
        |> Map.new(fn {k, v} -> {k, to_charlist(v)} end))
    )
  end

  defp find_shortest_path(grid, start, goal, minute \\ 1)

  defp find_shortest_path(grid, start, goal, minute) when is_atom(start) and is_atom(goal) do
    grid = grid |> Map.put(:elfs, [grid[start]])
    find_shortest_path(grid, start, grid[goal], minute)
  end

  defp find_shortest_path(_, _, _, 1_000), do: :ko

  defp find_shortest_path(grid, _, goal = {gx, gy}, minute) do
    if rem(minute, 100) == 0, do: IO.inspect(length(grid.elfs), label: minute)

    case Enum.any?(for {x, y} <- grid.elfs, do: abs(x - gx) + abs(y - gy) <= 1) do
      true ->
        {grid, minute}

      false ->
        grid
        |> blizards_move()
        |> elfs_move()
        |> find_shortest_path(nil, goal, minute + 1)
    end
  end

  defp blizards_move(grid = %{map: map, maxes: {max_row, max_col}}) do
    map
    |> Enum.reduce(%{}, fn {pos, dirs}, new_map ->
      Enum.reduce(dirs, new_map, fn dir, nmap ->
        new_pos =
          case {dir, pos} do
            {?<, {x, 0}} -> {x, max_col}
            {?<, {x, y}} -> {x, y - 1}
            {?>, {x, ^max_col}} -> {x, 0}
            {?>, {x, y}} -> {x, y + 1}
            {?v, {^max_row, y}} -> {0, y}
            {?v, {x, y}} -> {x + 1, y}
            {?^, {0, y}} -> {max_row, y}
            {?^, {x, y}} -> {x - 1, y}
          end

        Map.update(nmap, new_pos, [dir], &[dir | &1])
      end)
    end)
    |> (&%{grid | map: &1}).()
  end

  defp in_grid?(%{maxes: {max_row, max_col}}, {x, y}) do
    (x == -1 and y == 0) or (x == max_row + 1 and y == max_col) or
      (x in 0..max_row and y in 0..max_col)
  end

  defp elfs_move(grid = %{map: map, elfs: elfs}) do
    %{
      grid
      | elfs:
          Enum.reduce(elfs, [], fn
            {x, y}, new_elfs ->
              new_elfs ++
                for {dx, dy} <- [{0, 0}, {0, -1}, {0, 1}, {-1, 0}, {1, 0}],
                    x_ = x + dx,
                    y_ = y + dy,
                    in_grid?(grid, {x_, y_}),
                    map[{x_, y_}] == nil,
                    do: {x_, y_}
          end)
          |> Enum.uniq()
    }
  end
end
