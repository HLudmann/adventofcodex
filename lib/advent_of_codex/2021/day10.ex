defmodule AdventOfCodex2021.Day10 do
  @pairs %{")" => "(", "]" => "[", "}" => "{", ">" => "<"}
  @err_cost %{")" => 3, "]" => 57, "}" => 1197, ">" => 25_137}
  @completion_points %{"(" => 1, "[" => 2, "{" => 3, "<" => 4}

  @spec puzzle1 :: number
  def puzzle1() do
    AdventOfCodex2021.get_input(10)
    |> parse()
    |> Enum.map(&valid_line?/1)
    |> Enum.filter(&(elem(&1, 0) == :ko))
    |> Enum.group_by(fn {_, err} -> @err_cost[err] end, fn _ -> 1 end)
    |> Enum.map(fn {val, times} -> val * Enum.count(times) end)
    |> Enum.sum()
  end

  @spec puzzle2 :: number
  def puzzle2() do
    points_list = AdventOfCodex2021.get_input(10)
      |> parse()
      |> Enum.map(&valid_line?/1)
      |> Enum.filter(&(elem(&1, 0) == :ok))
      |> Enum.map(&count_points(elem(&1, 1)))
      |> Enum.sort()

    Enum.at(points_list, div(length(points_list), 2))
  end

  @spec parse([String.t]) :: [[String.t]]
  defp parse(input) do
    input
    |> Enum.map(&String.split(&1, "", trim: true))
  end

  @spec valid_line?([String.t()]) :: {:ok, [String.t()]} | {:ko, String.t()}
  defp valid_line?(line) do
    {rem, err} =
      Enum.reduce_while(line, {[], nil}, fn
        sep, {stack, _} when sep in ["(", "[", "{", "<"] ->
          {:cont, {[sep | stack], nil}}

        sep, {[top | bot] = stack, _} ->
          cond do
            @pairs[sep] == top -> {:cont, {bot, nil}}
            true -> {:halt, {stack, sep}}
          end
      end)

    case err do
      nil -> {:ok, rem}
      _ -> {:ko, err}
    end
  end

  @spec count_points([String.t]) :: integer
  defp count_points(rem_sep) do
    Enum.reduce(rem_sep, 0, fn sep, score -> 5*score + @completion_points[sep] end)
  end
end
