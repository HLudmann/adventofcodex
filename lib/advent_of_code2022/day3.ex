defmodule AdventOfCode2022.Day3 do
  def puzzle1() do
    AdventOfCode2022.read_input(3, trim: true)
    |> Enum.map(fn line ->
      [left, right] =
        String.split(line, "", trim: true) |> Enum.chunk_every((String.length(line) / 2) |> round)

      get_commons(left, right) |> Enum.at(0) |> get_priority()
    end)
    |> Enum.sum()
  end

  def puzzle2() do
    AdventOfCode2022.read_input(3, trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
    |> Enum.chunk_every(3, 3, :discard)
    |> Enum.map(fn [s1, s2, s3] ->
      s1
      |> get_commons(s2)
      |> get_commons(s3)
      |> Enum.at(0)
      |> get_priority()
    end)
    |> Enum.sum()
  end

  defp get_commons(left, right) do
    MapSet.intersection(MapSet.new(left), MapSet.new(right)) |> MapSet.to_list()
  end

  defp get_priority(item) do
    case item |> to_charlist() do
      [val] when 97 <= val -> val - 97 + 1
      [val] -> val - 65 + 27
    end
  end
end
