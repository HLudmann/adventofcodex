defmodule AdventOfCodex2021.Day5 do
  def puzzle1() do
    AdventOfCodex2021.get_input(5)
    |> parse()
    |> Stream.filter(fn
      [x, _, x, _] -> true
      [_, y, _, y] -> true
      _ -> false
    end)
    |> Enum.reduce(%{}, fn
      [x, y1, x, y2], acc_map ->
        Enum.reduce(y1..y2, acc_map, fn y, acc ->
          Map.update(acc, y, %{x => 1}, fn y_map -> Map.update(y_map, x, 1, &(&1 + 1)) end)
        end)

      [x1, y, x2, y], acc_map ->
        Map.update(acc_map, y, Enum.into(x1..x2, %{}, &{&1, 1}), fn y_map ->
          Enum.reduce(x1..x2, y_map, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
        end)
    end)
    |> count_overlap()
  end

  def puzzle2() do
    AdventOfCodex2021.get_input(5)
    |> parse()
    |> Enum.reduce(%{}, fn
      [x, y1, x, y2], acc_map ->
        Enum.reduce(y1..y2, acc_map, fn y, acc ->
          Map.update(acc, y, %{x => 1}, fn y_map -> Map.update(y_map, x, 1, &(&1 + 1)) end)
        end)

      [x1, y, x2, y], acc_map ->
        Map.update(acc_map, y, Enum.into(x1..x2, %{}, &{&1, 1}), fn y_map ->
          Enum.reduce(x1..x2, y_map, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
        end)

      [x1, y1, x2, y2], acc_map ->
        Enum.reduce(Enum.zip(x1..x2, y1..y2), acc_map, fn {x, y}, acc ->
          Map.update(acc, y, %{x=>1}, fn y_map -> Map.update(y_map, x, 1, &(&1+1)) end)
        end)
    end)
    |> count_overlap()
  end

  defp parse(input) do
    input
    |> Stream.map(fn line ->
      String.split(line, " -> ", trim: true)
      |> Enum.map(fn xy -> String.split(xy, ",") |> Enum.map(&String.to_integer/1) end)
      |> List.flatten()
    end)
  end

  defp count_overlap(diagram, min \\ 2) do
    diagram
    |> Enum.map(fn {_, l_map} -> Enum.count(l_map, fn {_, cnt} -> min <= cnt end) end)
    |> Enum.sum()
  end
end
