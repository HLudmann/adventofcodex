defmodule AdventOfCodex2022.Day25 do
  def puzzle1() do
    input_to_numb5()
    |> Enum.sum()
    |> dec_to_b5()
  end

  def puzzle2() do
    "Done!"
  end

  defp input_to_numb5() do
    AdventOfCodex2022.read_input(25, trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split("", trim: true)
      |> Enum.map(fn
        "-" -> -1
        "=" -> -2
        n -> String.to_integer(n)
      end)
      |> Enum.reverse()
      |> Enum.with_index()
      |> Enum.reduce(0, fn {val, exp}, sum -> sum + val * 5 ** exp end)

      # |> Map.new(fn {v, i} -> {i, v} end)
    end)
  end

  defp dec_to_b5(num) do
    dec_to_b5("", num, 0)
  end

  defp dec_to_b5(b5, 0, 0), do: b5
  defp dec_to_b5(b5, 0, 1), do: "1"<> b5

  defp dec_to_b5(b5, rest, ret) do
    IO.inspect(b5, label: rest)
    case rem(rest, 5) + ret do
      val when val <= 2 -> {val, 0}
      val -> {val - 5, 1}
    end
    |> (fn {val, ret} ->
          case val do
            -2 -> {"=" <> b5, ret}
            -1 -> {"-" <> b5, ret}
            v -> {"#{v}" <> b5, ret}
          end
        end).()
    |> (fn {b5, ret} -> dec_to_b5(b5, div(rest, 5), ret) end).()
  end
end
