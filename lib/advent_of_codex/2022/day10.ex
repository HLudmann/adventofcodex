defmodule AdventOfCodex2022.Day10 do
  def puzzle1() do
    input_to_cycle_funcs()
    |> Enum.reduce(%{x: 1, cycles: [1]}, fn func, %{x: x, cycles: c} ->
      %{x: func.(x), cycles: c ++ [func.(x)]}
    end)
    |> Map.get(:cycles)
    |> Enum.drop(19)
    |> Enum.take(201)
    |> Enum.take_every(40)
    |> Enum.with_index()
    |> Enum.map(fn {v, i} -> v * (20 + i * 40) end)
    |> Enum.sum()
  end

  def puzzle2() do
    input_to_cycle_funcs()
    |> Enum.reduce(%{x: 1, crt: ""}, fn func, %{x: x, crt: c} ->
      case abs(rem(String.length(c), 40) - x) do
        d when d < 2 -> %{x: func.(x), crt: c <> "#"}
        _ -> %{x: func.(x), crt: c <> "."}
      end
    end)
    |> Map.get(:crt)
    |> String.to_charlist()
    |> Enum.chunk_every(40)
  end

  defp input_to_cycle_funcs() do
    AdventOfCodex2022.read_input(10, trim: true)
    |> Enum.reduce([], fn
      "noop", funcs -> funcs ++ [& &1]
      "addx " <> v, funcs -> funcs ++ [& &1, &(&1 + String.to_integer(v))]
    end)
  end
end
