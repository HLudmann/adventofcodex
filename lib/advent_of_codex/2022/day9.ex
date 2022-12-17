defmodule AdventOfCodex2022.Day9 do
  defmodule Grid do
    defstruct tail: {0, 0}, head: {0, 0}, visited: MapSet.new([{0, 0}])
  end

  def puzzle1() do
    input_to_steps()
    |> Enum.reduce(%Grid{}, fn step, grid -> grid |> head_move(step) |> tail_move() end)
    |> count_visits()
  end

  def puzzle2() do
    input_to_steps()
    |> Enum.reduce(Enum.map(1..9, fn _ -> %Grid{} end), fn step, [h | t] ->
      h = h |> head_move(step) |> tail_move()

      Enum.reduce(t, [h], fn grid, grids = [h | _] ->
        [%{grid | head: h.tail} |> tail_move() | grids]
      end)
      |> Enum.reverse()
    end)
    |> Enum.at(-1)
    |> count_visits()
  end

  defp input_to_steps do
    AdventOfCodex2022.read_input(9, trim: true)
    |> Enum.map(&Regex.named_captures(~r/^(?<dir>[RULD]) (?<dist>\d+)$/, &1))
    |> Enum.map(fn %{"dir" => dir, "dist" => dist} ->
      for _ <- 1..String.to_integer(dist) do
        case dir do
          "U" -> &up/1
          "D" -> &down/1
          "L" -> &left/1
          "R" -> &right/1
        end
      end
    end)
    |> List.flatten()
  end

  defp up({x, y}), do: {x + 1, y}
  defp down({x, y}), do: {x - 1, y}
  defp left({x, y}), do: {x, y - 1}
  defp right({x, y}), do: {x, y + 1}

  defp right_left_or_none(pos, 0), do: pos

  defp right_left_or_none(pos, diff) do
    case diff < 0 do
      false -> pos |> right()
      true -> pos |> left()
    end
  end

  defp up_down_or_none(pos, 0), do: pos

  defp up_down_or_none(pos, diff) do
    case diff < 0 do
      false -> pos |> up()
      true -> pos |> down()
    end
  end

  defp head_move(grid = %Grid{head: pos}, step) do
    %{grid | head: step.(pos)}
  end

  defp diff(pos1, pos2)
  defp diff({x1, y1}, {x2, y2}), do: {x1 - x2, y1 - y2}

  defp add_visit(grid = %Grid{tail: tail, visited: visited}),
    do: %{grid | visited: visited |> MapSet.put(tail)}

  defp tail_move(grid = %Grid{tail: tail, head: head}) do
    case diff(head, tail) do
      {x, y} when abs(x) < 2 and abs(y) < 2 -> grid
      {2, y} -> %{grid | tail: up(tail) |> right_left_or_none(y)}
      {-2, y} -> %{grid | tail: down(tail) |> right_left_or_none(y)}
      {x, -2} -> %{grid | tail: left(tail) |> up_down_or_none(x)}
      {x, 2} -> %{grid | tail: right(tail) |> up_down_or_none(x)}
    end
    |> add_visit()
  end

  defp count_visits(%Grid{visited: visited}), do: MapSet.size(visited)
end
