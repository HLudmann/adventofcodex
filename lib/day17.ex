defmodule AdventOfCode2021.Day17 do
  def puzzle1 do
    get_parsed_input()
    |> Map.get("By")
    |> abs()
    |> (fn x -> x * (x - 1) / 2 end).()
    |> round()
  end

  def puzzle2 do
    target = get_parsed_input()

    for x <- 0..target["Tx"], y <- target["By"]..(abs(target["By"]) - 1) do
      {x, y}
    end
    |> Enum.uniq()
    |> Enum.filter(&good_shot(target, &1))
    |> Enum.count()
  end

  def get_parsed_input do
    regex = ~r/target area: x=(?<Bx>\d+)..(?<Tx>\d+), y=(?<By>-?\d+)..(?<Ty>-?\d+)/

    AdventOfCode2021.get_input(17)
    |> hd()
    |> (fn str -> Regex.named_captures(regex, str) end).()
    |> Enum.into(%{}, fn {k, v} -> {k, String.to_integer(v)} end)
  end

  def on_target(target, {x, y}) do
    target["Bx"] <= x and x <= target["Tx"] and
      target["By"] <= y and y <= target["Ty"]
  end

  def passed_target(target, {x, y}) do
    target["Tx"] < x or y < target["By"]
  end

  def good_shot(target, speed, pos \\ {0, 0})

  def good_shot(target, {vx, vy}, {x, y} = pos) do
    case {on_target(target, pos), passed_target(target, pos)} do
      {_, true} -> false
      {true, _} -> true
      _ -> good_shot(target, {max(vx - 1, 0), vy - 1}, {x + vx, y + vy})
    end
  end
end
