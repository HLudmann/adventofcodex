defmodule AdventOfCode2022.Day14 do
  def puzzle1() do
    starting_grid = input_to_grid()
    lowest = find_max_depth(starting_grid)

    loop_while(starting_grid, fn grid ->
      case drop_sand(grid, lowest) do
        {_, y} when y > lowest -> {:halt, grid}
        pos -> {:cont, grid |> Map.put(pos, :sand)}
      end
    end)
    |> Enum.count(fn {_, e} -> e == :sand end)
  end

  def puzzle2() do
    starting_grid = input_to_grid()
    lowest = find_max_depth(starting_grid)

    loop_while(starting_grid, fn grid ->
      case drop_sand(grid, lowest) do
        {500, 0} = pos -> {:halt, grid |> Map.put(pos, :sand)}
        pos -> {:cont, grid |> Map.put(pos, :sand)}
      end
    end)
    |> Enum.count(fn {_, e} -> e == :sand end)
  end

  defp input_to_grid() do
    AdventOfCode2022.read_input(14, trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(" -> ", trim: true)
      |> Enum.map(fn str_pos ->
        str_pos |> String.split(",", trim: true) |> Enum.map(&String.to_integer/1)
      end)
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.reduce(%{}, fn pos_pair, grid ->
        case pos_pair do
          [[x1, y], [x2, y]] -> Enum.into(x1..x2, %{}, &{{&1, y}, :rock})
          [[x, y1], [x, y2]] -> Enum.into(y1..y2, %{}, &{{x, &1}, :rock})
        end
        |> Map.merge(grid)
      end)
    end)
    |> Enum.reduce(%{}, &Map.merge(&1, &2))
  end

  defp find_max_depth(grid) do
    grid |> Enum.map(&(elem(&1, 0) |> elem(1))) |> Enum.max()
  end

  defp loop_while(acc, fun) do
    Stream.cycle([1])
    |> Enum.reduce_while(acc, fn _, a -> fun.(a) end)
  end

  defp drop_sand(grid, lowest) do
    loop_while({500, 0}, fn {x, y} ->
      cond do
        y > lowest -> {:halt, {x, y}}
        grid[{x, y + 1}] == nil -> {:cont, {x, y + 1}}
        grid[{x - 1, y + 1}] == nil -> {:cont, {x - 1, y + 1}}
        grid[{x + 1, y + 1}] == nil -> {:cont, {x + 1, y + 1}}
        true -> {:halt, {x, y}}
      end
    end)
  end
end
