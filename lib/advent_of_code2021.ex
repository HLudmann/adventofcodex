defmodule AdventOfCode2021 do
  @moduledoc """
  Documentation for `AdventOfCode2021`.
  """

  @days_solved 9

  def get_input(day) do
    File.read!("puzzle_inputs/day#{day}.txt") |> String.split("\n", trim: true)
  end

  def get_input_as_integer(day), do: get_input(day) |> Enum.map(&String.to_integer/1)

  1..@days_solved
  |> Enum.each(fn day ->
    def unquote(:"day#{day}")() do
      module = String.to_existing_atom("Elixir.AdventOfCode2021.Day#{unquote(day)}")
      IO.puts("Day#{unquote(day)}:\n\tpuzzle1: #{module.puzzle1()}\n\tpuzzle2: #{module.puzzle2()}")
    end
  end)

  def all_days() do
    for day <- 1..@days_solved do
      module = String.to_existing_atom("Elixir.AdventOfCode2021.Day#{day}")
      IO.puts("Day#{day}:\n\tpuzzle1: #{module.puzzle1()}\n\tpuzzle2: #{module.puzzle2()}")
    end
  end
end
