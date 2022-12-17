defmodule AdventOfCodex2021.Day4 do
  def puzzle1() do
    {num_list, parsed_tables} =
      AdventOfCodex2021.get_input(4)
      |> parse_input()

    num_list
    |> Enum.reduce_while(parsed_tables, fn num, tables ->
      updated = Enum.map(tables, &check_num(num, &1))

      rem_sum =
        Enum.reduce_while(updated, -1, fn table, _ ->
          case has_won?(table) do
            false -> {:cont, -1}
            true -> {:halt, sum_remaining(table)}
          end
        end)

      case rem_sum do
        -1 -> {:cont, updated}
        sum -> {:halt, sum * num}
      end
    end)
  end

  def puzzle2() do
    {num_list, parsed_tables} =
      AdventOfCodex2021.get_input(4)
      |> parse_input()

    num_list
    |> Enum.reduce_while(parsed_tables, fn num, tables ->
      case Enum.map(tables, &check_num(num, &1)) do
        [last] ->
          case has_won?(last) do
            true -> {:halt, sum_remaining(last) * num}
            false -> {:cont, [last]}
          end

        updated ->
          {:cont, updated |> Enum.filter(&(not has_won?(&1)))}
      end
    end)
  end

  defp parse_input(input) do
    [num_chain | tables] = input

    numbers = num_chain |> String.split(",", trim: true) |> Enum.map(&String.to_integer/1)

    formated_tables =
      tables
      |> Stream.chunk_every(5, 5, :discard)
      |> Stream.map(fn raw_table ->
        raw_table
        |> Enum.map(fn raw_line ->
          raw_line
          |> String.split(" ", trim: true)
          |> Enum.map(&String.to_integer/1)
        end)
      end)
      |> Enum.to_list()

    {numbers, formated_tables}
  end

  defp check_num(num, table) do
    Enum.map(table, fn row ->
      Enum.map(row, fn
        ^num -> -1
        e -> e
      end)
    end)
  end

  defp has_won?(table)

  defp has_won?([[-1, -1, -1, -1, -1] | _]), do: true
  defp has_won?([[-1 | _], [-1 | _], [-1 | _], [-1 | _], [-1 | _]]), do: true

  defp has_won?([[_ | _] | _] = table),
    do: has_won?(tl(table)) or has_won?(Enum.map(table, &tl/1))

  defp has_won?(_), do: false

  defp sum_remaining(table) do
    Enum.map(table, fn row ->
      row |> Enum.filter(&(&1 != -1)) |> Enum.sum()
    end)
    |> Enum.sum()
  end
end
