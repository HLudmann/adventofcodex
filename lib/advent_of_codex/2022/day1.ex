defmodule AdventOfCodex2022.Day1 do
  def puzzle1() do
    sum_cal_by_elf()
    |> Enum.max()
  end

  def puzzle2() do
    sum_cal_by_elf()
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.sum()
  end

  defp sum_cal_by_elf() do
    AdventOfCodex2022.read_input(1)
    |> Enum.reduce([0], fn
      "", acc -> [0 | acc]
      str_int, [h | t] -> [h + String.to_integer(str_int) | t]
    end)
  end
end
