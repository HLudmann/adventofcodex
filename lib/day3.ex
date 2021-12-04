defmodule AdventOfCode2021.Day3 do
  def puzzle1() do
    [first | _] = input = AdventOfCode2021.get_input(3)
    diag_size = length(input)
    acc = List.duplicate(0, String.length(first))

    input
    |> Enum.map(fn elem ->
      String.split(elem, "", trim: true) |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.reduce(acc, fn elem, acc ->
      for {x, y} <- Enum.zip(elem, acc), do: x + y
    end)
    |> Enum.reduce(["", ""], fn elem, [gamma, epsilon] ->
      cond do
        elem <= diag_size / 2 -> [gamma <> "0", epsilon <> "1"]
        true -> [gamma <> "1", epsilon <> "0"]
      end
    end)
    |> Enum.map(fn e -> Integer.parse(e, 2) |> elem(0) end)
    |> Enum.product()
  end

  def puzzle2() do
    input = AdventOfCode2021.get_input(3) |> Enum.map(&String.split(&1, "", trim: true))

    (most_frequent_filter(input) |> Integer.parse(2) |> elem(0)) *
      (least_frequent_filter(input) |> Integer.parse(2) |> elem(0))
  end

  defp most_frequent_filter([[] | _]), do: ""
  defp most_frequent_filter([elem]), do: Enum.join(elem)

  defp most_frequent_filter(input) do
    most_freq =
      cond do
        Enum.count(input, fn [h | _] -> h == "1" end) >= length(input) / 2 -> "1"
        true -> "0"
      end

    most_freq <>
      (input
       |> Enum.filter(fn [h | _] -> h == most_freq end)
       |> Enum.map(fn [_ | tail] -> tail end)
       |> most_frequent_filter())
  end


  defp least_frequent_filter([[] | _]), do: ""
  defp least_frequent_filter([elem]), do: Enum.join(elem)

  defp least_frequent_filter(input) do
    least_freq =
      cond do
        Enum.count(input, fn [h | _] -> h == "0" end) <= length(input) / 2 -> "0"
        true -> "1"
      end

    least_freq <>
      (input
       |> Enum.filter(fn [h | _] -> h == least_freq end)
       |> Enum.map(fn [_ | tail] -> tail end)
       |> least_frequent_filter())
  end
end
