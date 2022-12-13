defmodule AdventOfCode2022.Day13 do
  def puzzle1() do
    input_to_lists()
    |>Enum.chunk_every(2)
    |> Enum.map(fn [left, right] -> pair_valid?(left, right) end)
    |> Enum.with_index()
    # starts at 1
    |> (&for({valid?, index} <- &1, valid? == :ok, do: index + 1)).()
    |> Enum.sum()
  end

  @div1 [[2]]
  @div2 [[6]]
  def puzzle2() do
    (input_to_lists() ++ [@div1, @div2])
    |> Enum.sort(&pair_valid?(&1, &2) == :ok)
    |> Enum.with_index()
    |> (&for {val, index} <- &1, val in [@div1, @div2], do: index+1).()
    |> Enum.product()
  end

  defp input_to_lists() do
    AdventOfCode2022.read_input(13, trim: true)
    |> Enum.map(&(Code.eval_string(&1) |> elem(0)))
  end

  defp pair_valid?(left, right)
  defp pair_valid?(same, same), do: :cont
  defp pair_valid?(l, r) when is_integer(l) and is_integer(r), do: (l < r && :ok) || :ko
  defp pair_valid?([], []), do: :cont
  defp pair_valid?([], _), do: :ok
  defp pair_valid?(_, []), do: :ko
  defp pair_valid?(l, r) when is_list(l) and is_integer(r), do: pair_valid?(l, [r])
  defp pair_valid?(l, r) when is_integer(l) and is_list(r), do: pair_valid?([l], r)

  defp pair_valid?([lh | lt], [rh | rt]) do
    case pair_valid?(lh, rh) do
      :cont -> pair_valid?(lt, rt)
      res -> res
    end
  end
end
