defmodule AdventOfCode2021.Day6 do
  def puzzle1() do
    AdventOfCode2021.get_input(6)
    |> parse()
    |> ff_n_days(80)
    |> count_fish_in_map()
  end

  def puzzle2() do
    AdventOfCode2021.get_input(6)
    |> parse()
    |> ff_n_days(256)
    |> count_fish_in_map()
  end

  defp parse(input) do
    input
    |> hd()
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce(Enum.into(0..8, %{}, &{&1, 0}), &Map.update(&2, &1, 1, fn old -> old + 1 end))
  end

  defp ff_n_days(fish_map, span) do
    Enum.reduce(1..span, fish_map, fn _day, cur_map ->
      Enum.reduce(cur_map, %{}, fn
        {0, cnt}, new_map -> new_map |> Map.update(6, cnt, &(&1 + cnt)) |> Map.put(8, cnt)
        {days_rem, cnt}, new_map -> Map.update(new_map, days_rem - 1, cnt, &(&1 + cnt))
      end)
    end)
  end

  defp count_fish_in_map(fish_map) do
    fish_map |> Enum.map(fn {_day, cnt} -> cnt end) |> Enum.sum()
  end
end
