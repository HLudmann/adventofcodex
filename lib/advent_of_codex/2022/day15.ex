defmodule AdventOfCodex2022.Day15 do
  @y 2_000_000

  def puzzle1() do
    grid = input_to_sensors_n_beacons()

    non_beac_on_y =
      find_non_beacon_pts(grid, @y)
      |> Enum.map(&Range.size/1)
      |> Enum.sum()

    beacs_on_y =
      grid
      |> Enum.count(fn
        {{_, @y}, :beac} -> true
        _ -> false
      end)

    non_beac_on_y - beacs_on_y
  end

  def puzzle2() do
    grid = input_to_sensors_n_beacons()

    Stream.cycle([1])
    |> Enum.reduce_while({0, 2 * @y}, fn
      _, pt = {_, 0} ->
        {:halt, pt}

      _, {_, y} ->
        case find_non_beacon_pts(grid, y) do
          [_..e1, _..e2] -> {:halt, {min(e1, e2) + 1, y}}
          _ -> {:cont, {0, y - 1}}
        end
    end)
    |> (fn {x, y} -> x * 2 * @y + y end).()
  end

  defp input_to_sensors_n_beacons() do
    AdventOfCodex2022.read_input(15, trim: true)
    |> Enum.map(fn line ->
      ~r/^Sensor at x=(?<sx>-?\d+), y=(?<sy>-?\d+): closest beacon is at x=(?<bx>-?\d+), y=(?<by>-?\d+)$/
      |> Regex.named_captures(line)
      |> Enum.into(%{}, fn {k, v} -> {k, v |> String.to_integer()} end)
    end)
    |> Enum.reduce(%{}, fn %{"sx" => sx, "sy" => sy, "bx" => bx, "by" => by}, grid ->
      grid |> Map.put({bx, by}, :beac) |> Map.put({sx, sy}, {bx, by})
    end)
  end

  defp dist({x1, y1}, {x2, y2}), do: abs(x1 - x2) + abs(y1 - y2)

  defp touching_range?(b1..e1, b2..e2),
    do: (b1 <= b2 and b2 <= e1 + 1) or (b2 <= b1 and b1 <= e2 + 1)

  defp merge_ranges(b1..e1, b2..e2), do: min(b1, b2)..max(e1, e2)

  defp reduce_ranges(ranges) do
    new =
      ranges
      |> Enum.sort(fn b1..e1, b2..e2 -> b1 <= b2 and e1 <= e2 end)
      |> Enum.reduce([], fn
        range, [] ->
          [range]

        range, ranges = [head | tail] ->
          case touching_range?(range, head) do
            false -> [range | ranges]
            true -> [merge_ranges(range, head) | tail]
          end
      end)

    case length(new) == length(ranges) do
      true -> new
      false -> reduce_ranges(new)
    end
  end

  defp find_non_beacon_pts(grid, y) do
    grid
    |> Enum.reduce([], fn
      {_, :beac}, ranges ->
        ranges

      {s = {sx, _}, beac}, ranges ->
        case dist(s, beac) - dist(s, {sx, y}) do
          val when val < 0 ->
            ranges

          margin ->
            [(sx - margin)..(sx + margin) | ranges]
        end
    end)
    |> reduce_ranges()
  end
end
