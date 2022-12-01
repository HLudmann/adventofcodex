defmodule AdventOfCode2021.Day13 do
  def puzzle1() do
    pt_n_folds = get_parse_input()

    fold_points(hd(pt_n_folds.folds), pt_n_folds.points)
    |> Enum.count()
  end

  def puzzle2(print \\ true) do
    pt_n_folds = get_parse_input()

    points_string =
      Enum.reduce(pt_n_folds.folds, pt_n_folds.points, &fold_points(&1, &2))
      |> points_to_string()

    case print do
      true -> IO.puts(points_string)
      false -> points_string
    end
  end

  def get_parse_input() do
    AdventOfCode2021.get_input(13)
    |> Enum.group_by(
      fn
        "fold along " <> _ -> :folds
        _ -> :points
      end,
      fn
        "fold along " <> fold ->
          [axis, val] = String.split(fold, "=")
          {axis, String.to_integer(val)}

        point ->
          String.split(point, ",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
      end
    )
  end

  def fold_points(fold, points)

  def fold_points({"x", value}, points) do
    Enum.map(points, fn
      {^value, _} -> {-1, -1}
      {x, y} when x < value -> {x, y}
      {x, y} -> {2 * value - x, y}
    end)
    |> Enum.uniq()
    |> Enum.filter(&(&1 != {-1, -1}))
  end

  def fold_points({"y", value}, points) do
    Enum.map(points, fn
      {_, ^value} -> {-1, -1}
      {x, y} when y < value -> {x, y}
      {x, y} -> {x, 2 * value - y}
    end)
    |> Enum.uniq()
    |> Enum.filter(&(&1 != {-1, -1}))
  end

  def points_to_string(points) do
    {x_min, x_max} = Enum.map(points, &elem(&1, 0)) |> Enum.min_max()
    {y_min, y_max} = Enum.map(points, &elem(&1, 1)) |> Enum.min_max()

    Enum.reduce(y_min..y_max, "", fn y, rows ->
      rows <>
        Enum.reduce(x_min..x_max, "", fn x, pt ->
          pt <>
            case {x, y} in points do
              true -> "#"
              false -> "."
            end
        end) <> "\n"
    end)
  end
end
