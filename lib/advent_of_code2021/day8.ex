defmodule AdventOfCode2021.Day8 do
  def puzzle1() do
    AdventOfCode2021.get_input(8)
    |> parse()
    |> Stream.map(fn [_upat, output] ->
      Enum.count(output, &(length(&1) in [2, 3, 4, 7]))
    end)
    |> Enum.sum()
  end

  def puzzle2() do
    AdventOfCode2021.get_input(8)
    |> parse()
    |> Stream.map(fn [pattern, [d1, d2, d3, d4]] ->
      p_to_d = process_patterns(pattern)
      p_to_d[d1] * 1000 + p_to_d[d2] * 100 + p_to_d[d3] * 10 + p_to_d[d4]
    end)
    |> Enum.sum()
  end

  defp parse(input) do
    input
    |> Enum.map(fn line ->
      String.split(line, "|", trim: true)
      |> Enum.map(fn values ->
        String.split(values, " ", trim: true)
        |> Enum.map(fn pattern -> String.split(pattern, "", trim: true) |> Enum.sort() end)
      end)
    end)
  end

  defp process_patterns(patterns) do
    %{2 => [one], 3 => [seven], 4 => [four], 5 => ttf, 6 => zsn, 7 => [eight]} =
      patterns
      |> Enum.reduce(%{}, fn pattern, len_to_pattern ->
        Map.update(len_to_pattern, length(pattern), [pattern], &[pattern | &1])
      end)

    [nine] = Enum.filter(zsn, &digit_in_digit?(&1, four))
    zs = Enum.filter(zsn, &(&1 != nine))
    [zero] = Enum.filter(zs, &digit_in_digit?(&1, one))
    [six] = Enum.filter(zs, &(&1 != zero))

    [three] = Enum.filter(ttf, &digit_in_digit?(&1, one))
    tf = Enum.filter(ttf, &(&1 != three))
    [five] = Enum.filter(tf, &digit_in_digit?(nine, &1))
    [two] = Enum.filter(tf, &(&1 != five))

    %{
      zero => 0,
      one => 1,
      two => 2,
      three => 3,
      four => 4,
      five => 5,
      six => 6,
      seven => 7,
      eight => 8,
      nine => 9
    }
  end

  defp digit_in_digit?(big, small) do
    Enum.all?(small, &(&1 in big))
  end
end
