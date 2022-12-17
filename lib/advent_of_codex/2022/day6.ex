defmodule AdventOfCodex2022.Day6 do
  def puzzle1() do
    uniq_in_datastream(4)
  end

  def puzzle2() do
    uniq_in_datastream(14)
  end

  defp uniq_in_datastream(length) do
    AdventOfCodex2022.stream_input(6, 1)
    |> Stream.chunk_every(length, 1, :discard)
    |> Enum.reduce_while(length, fn chunk, acc ->
      case Enum.uniq(chunk) == chunk do
        true -> {:halt, acc}
        _ -> {:cont, acc + 1}
      end
    end)
  end
end
