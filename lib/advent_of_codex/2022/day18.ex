defmodule AdventOfCodex2022.Day18 do
  def puzzle1() do
    cubes = input_to_cubes()

    cubes
    |> Map.keys()
    |> Enum.map(fn [x, y, z] ->
      [[x, y, z + 1], [x, y, z - 1], [x, y + 1, z], [x, y - 1, z], [x + 1, y, z], [x - 1, y, z]]
      |> Enum.count(&(cubes[&1] == nil))
    end)
    |> Enum.sum()
  end

  def puzzle2() do
    cubes_n_steam = input_to_cubes() |> find_bubbles()

    cubes_n_steam
    |> Enum.map(fn
      {_, -1} ->
        0

      {_, 0} ->
        0

      {[x, y, z], _} ->
        [[x, y, z + 1], [x, y, z - 1], [x, y + 1, z], [x, y - 1, z], [x + 1, y, z], [x - 1, y, z]]
        |> Enum.count(&(Map.get(cubes_n_steam, &1, 0) == 0))
    end)
    |> Enum.sum()
  end

  defp input_to_cubes() do
    AdventOfCodex2022.read_input(18, trim: true)
    |> Enum.into(%{}, fn line ->
      {line |> String.split(",", trim: true) |> Enum.map(&String.to_integer/1), 1}
    end)
  end

  defp get_min_max_at(enum, index),
    do:
      enum
      |> Enum.min_max_by(&Enum.at(&1, index))
      |> (fn {mn, mx} -> Enum.at(mn, index)..Enum.at(mx, index) end).()

  defp find_bubbles(cubes) do
    x_rg = cubes |> Map.keys() |> get_min_max_at(0)
    y_rg = cubes |> Map.keys() |> get_min_max_at(1)
    z_rg = cubes |> Map.keys() |> get_min_max_at(2)

    neighbours = fn [x, y, z] ->
      [[x, y, z + 1], [x, y, z - 1], [x, y + 1, z], [x, y - 1, z], [x + 1, y, z], [x - 1, y, z]]
      |> Enum.filter(&(cubes[&1] != 1))
    end

    dist = h = fn _, _ -> 1 end

    goal = fn p = [x, y, z] ->
      cubes[p] in [-1, 0] or x not in x_rg or y not in y_rg or z not in z_rg
    end

    for(x <- x_rg, y <- y_rg, z <- z_rg, cubes[[x, y, z]] == nil, do: [x, y, z])
    |> Enum.reduce(cubes, fn pos, cbs ->
      case cbs[pos] == nil do
        false ->
          cbs

        true ->
          case Astar.astar({neighbours, dist, h}, pos, goal) |> Enum.reverse() do
            [] ->
              Map.put(cbs, pos, -1)

            path = [last | _] ->
              val = Map.get(cubes, last, 0)
              Enum.reduce([pos | path], cbs, &Map.put_new(&2, &1, val))
          end
      end
    end)
  end
end
