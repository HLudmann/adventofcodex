defmodule AdventOfCodex2021.Day1 do
  def puzzle1() do
    AdventOfCodex2021.get_input_as_integer(1)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(&is_higher/1)
    |> Enum.sum()
  end

  def puzzle2() do
    AdventOfCodex2021.get_input_as_integer(1)
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.map(&Enum.sum/1)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(&is_higher/1)
    |> Enum.sum()
  end

  defp is_higher(chunk)
  defp is_higher([cur, next | _rem]) when cur < next, do: 1
  defp is_higher(_), do: 0
end
