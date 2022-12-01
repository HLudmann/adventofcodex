defmodule AdventOfCode2021.Day7 do
  def puzzle1() do
    crabs = AdventOfCode2021.get_input(7) |> parse() |> Enum.sort()
    Enum.at(crabs, div(length(crabs), 2)) |> distance(crabs)
  end

  def puzzle2() do
    crabs = AdventOfCode2021.get_input(7) |> parse()
    average = (Enum.sum(crabs) / length(crabs)) |> round
    dist_to_avg = distincrease(average, crabs)

    Enum.reduce_while(1..average, dist_to_avg, fn num, cur_best ->
      candidat = min(distincrease(average-num, crabs), distincrease(average+num, crabs))
      case candidat <= cur_best do
        true -> {:cont, candidat}
        false -> {:halt, cur_best}
      end
    end)
  end

  defp parse(input) do
    input |> hd |> String.split(",", trim: true) |> Enum.map(&String.to_integer/1)
  end

  defp distance(point, crabs) do
    Stream.map(crabs, &abs(&1 - point)) |> Enum.sum()
  end

  defp distincrease(point, crabs) do
    Stream.map(crabs, fn crab ->
      n = abs(crab - point)
      # using round just to transform into integer
      round(n * (n + 1) / 2)
    end)
    |> Enum.sum()
  end
end
