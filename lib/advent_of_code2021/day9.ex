defmodule AdventOfCode2021.Day9 do
  def map() do
    AdventOfCode2021.get_input(9)
    |> parse()
  end

  @spec puzzle1 :: number
  def puzzle1() do
    map =
      AdventOfCode2021.get_input(9)
      |> parse()

    for row <- 0..(map_size(map) - 1),
        col <- 0..(map_size(map[0]) - 1),
        local_min?(map, row, col) do
      map[row][col] + 1
    end
    |> Enum.sum()
  end

  @spec puzzle2 :: number
  def puzzle2() do
    map =
      AdventOfCode2021.get_input(9)
      |> parse()

    [largest, second_largest, third_largest | _] =
      for row <- 0..(map_size(map) - 1),
          col <- 0..(map_size(map[0]) - 1),
          local_min?(map, row, col) do
        Task.async(fn -> bassin(map, row, col) end)
      end
      |> Enum.map(&Task.await/1)
      |> Enum.map(&Enum.count/1)
      |> Enum.sort(:desc)

    largest * second_largest * third_largest
  end

  @spec parse([String.t()]) :: %{integer => %{integer => integer}}
  defp parse(input) do
    input
    |> Enum.with_index()
    |> Enum.into(%{}, fn {line, i} ->
      {i,
       line
       |> String.split("", trim: true)
       |> Enum.with_index()
       |> Enum.into(%{}, fn {height, j} -> {j, String.to_integer(height)} end)}
    end)
  end

  @spec local_min?(%{integer => %{integer => integer}}, integer, integer) :: boolean
  defp local_min?(map, row, col) do
    for l <- -1..1, m <- -1..1, abs(l) != abs(m), map[row + l][col + m] != nil do
      {row + l, col + m}
    end
    |> Enum.map(fn {i, j} -> map[row][col] < map[i][j] end)
    |> Enum.all?()
  end

  @spec bassin(%{integer => %{integer => integer}}, integer, integer) :: [{integer, integer}]
  defp bassin(map, row, col) do
    case map[row][col] do
      9 ->
        []

      height ->
        map = Map.update!(map, row, &Map.put(&1, col, 9))

        ([{row, col}] ++
           (for l <- -1..1,
                m <- -1..1,
                abs(l) != abs(m),
                map[row + l][col + m] != nil,
                height < map[row + l][col + m] do
              bassin(map, row + l, col + m)
            end
            |> List.flatten()))
        |> Enum.uniq()
    end
  end
end
