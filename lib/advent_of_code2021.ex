defmodule AdventOfCode2021 do
  @moduledoc """
  Documentation for `AdventOfCode2021`.
  """

  @days_solved 20

  @spec get_input(number) :: [String.t]
  def get_input(day) do
    File.read!("puzzle_inputs/day#{day}.txt") |> String.split("\n", trim: true)
  end

  @spec get_input_as_integer(number) :: [integer]
  def get_input_as_integer(day), do: get_input(day) |> Enum.map(&String.to_integer/1)

  1..@days_solved
  |> Enum.each(fn day ->
    def unquote(:"day#{day}")() do
      module = String.to_existing_atom("Elixir.AdventOfCode2021.Day#{unquote(day)}")
      IO.puts("Day#{unquote(day)}:\n\tpuzzle1: #{module.puzzle1()}\n\tpuzzle2: #{module.puzzle2()}")
    end
  end)

  @spec all_days :: :ok
  def all_days() do
    for day <- 1..@days_solved do
      module = String.to_existing_atom("Elixir.AdventOfCode2021.Day#{day}")
      IO.puts("Day#{day}:\n\tpuzzle1: #{module.puzzle1()}\n\tpuzzle2: #{module.puzzle2()}")
    end
    :ok
  end

  def time_benchmark(func) do
    func
    |> :timer.tc()
    |> elem(0)
    |> Kernel./(1_000_000)
  end
end
