defmodule AdventOfCodex2021.Day6 do
  def puzzle1() do
    AdventOfCodex2021.get_input(6)
    |> parse()
    |> ff_n_days(80)
    |> count_fish_in_map()
  end

  def puzzle2() do
    AdventOfCodex2021.get_input(6)
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
    Enum.reduce(1..span, fish_map, fn _day,
                                      %{
                                        0 => val0,
                                        1 => val1,
                                        2 => val2,
                                        3 => val3,
                                        4 => val4,
                                        5 => val5,
                                        6 => val6,
                                        7 => val7,
                                        8 => val8
                                      } ->
      %{
        0 => val1,
        1 => val2,
        2 => val3,
        3 => val4,
        4 => val5,
        5 => val6,
        6 => val0 + val7,
        7 => val8,
        8 => val0
      }
    end)
  end

  defp count_fish_in_map(fish_map) do
    fish_map |> Enum.map(fn {_day, cnt} -> cnt end) |> Enum.sum()
  end
end
