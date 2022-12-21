defmodule AdventOfCodex2022 do
  @moduledoc """
  Documentation for `AdventOfCodex2022`.
  """

  @days_solved 21

  @spec read_input(number) :: [String.t()]
  def read_input(day, opts \\ []) do
    File.read!("puzzle_inputs/2022/day#{day}.txt") |> String.split("\n", opts)
  end

  @spec stream_input(number, :line | number) :: File.Stream.t()
  def stream_input(day, line_or_bytes \\ :line),
    do: File.stream!("puzzle_inputs/2022/day#{day}.txt", [], line_or_bytes)

  1..@days_solved
  |> Enum.each(fn day ->
    def unquote(:"day#{day}")() do
      module = String.to_existing_atom("Elixir.AdventOfCodex2022.Day#{unquote(day)}")

      IO.puts(
        "Day#{unquote(day)}:\n\tpuzzle1: #{module.puzzle1()}\n\tpuzzle2: #{module.puzzle2()}"
      )
    end
  end)

  @spec all_days :: :ok
  def all_days() do
    for day <- 1..@days_solved do
      module = String.to_existing_atom("Elixir.AdventOfCodex2022.Day#{day}")
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
