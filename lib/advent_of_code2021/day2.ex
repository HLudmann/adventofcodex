defmodule AdventOfCode2021.Day2 do
  def puzzle1() do
    AdventOfCode2021.get_input(2)
    |> Enum.map(&String.split/1)
    |> Enum.map(fn [cmd, value] -> {cmd, String.to_integer(value)} end)
    |> Enum.reduce({0, 0}, fn elem, {hp, vp}->
      case elem do
        {"forward", val} -> {hp + val, vp}
        {"up", val} -> {hp, vp-val}
        {"down", val} -> {hp, vp+val}
        _ -> {hp, vp}
      end
    end)
    |> Tuple.to_list()
    |> Enum.product()
  end

  def puzzle2() do
    AdventOfCode2021.get_input(2)
    |> Enum.map(&String.split/1)
    |> Enum.map(fn [cmd, value] -> {cmd, String.to_integer(value)} end)
    |> Enum.reduce({0, 0, 0}, fn elem, {hp, vp, aim}->
      case elem do
        {"forward", val} -> {hp + val, vp+val*aim, aim}
        {"up", val} -> {hp, vp, aim-val}
        {"down", val} -> {hp, vp, aim+val}
        _ -> {hp, vp, aim}
      end
    end)
    |> (fn {hp, vp, _aim} -> hp*vp end).()
  end
end
