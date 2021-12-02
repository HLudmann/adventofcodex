defmodule AdventOfCode2021 do
  @moduledoc """
  Documentation for `AdventOfCode2021`.
  """

  def get_input(day) do
    File.read!("puzzle_inputs/day#{day}.txt") |> String.split("\n", trim: true)
  end

  def get_input_as_integer(day), do: get_input(day) |> Enum.map(&String.to_integer/1)
end
