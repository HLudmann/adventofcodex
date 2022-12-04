defmodule AdventOfCode2022.Day4 do
  def puzzle1() do
    input_to_range_pairs()
    |> Enum.map(fn {range1, range2} ->
      set1 = MapSet.new(range1)
      set2 = MapSet.new(range2)

      case MapSet.intersection(set1, set2) do
        ^set1 -> 1
        ^set2 -> 1
        _ -> 0
      end
    end)
    |> Enum.sum()
  end

  def puzzle2() do
    input_to_range_pairs()
    |> Enum.map(fn {r1, r2} -> Range.disjoint?(r1, r2) && 0 || 1 end)
    |> Enum.sum()
  end

  defp input_to_range_pairs() do
    AdventOfCode2022.read_input(4, trim: true)
    |> Enum.map(fn line ->
      %{"r1b" => r1b, "r1e" => r1e, "r2b" => r2b, "r2e" => r2e} =
        Regex.named_captures(~r/^(?<r1b>\d+)-(?<r1e>\d+),(?<r2b>\d+)-(?<r2e>\d+)$/, line)
        |> Enum.map(fn {k, v} -> {k, String.to_integer(v)} end)
        |> Enum.into(%{})

      {r1b..r1e, r2b..r2e}
    end)
  end
end
