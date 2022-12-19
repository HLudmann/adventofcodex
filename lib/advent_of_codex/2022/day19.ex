defmodule AdventOfCodex2022.Day19 do
  defmodule Blueprint do
    defstruct [:id, :or, :cl, :ob, :ge, :mxs]

    def from_line(line) do
      [id, oror, clor, obor, obcl, geor, geob] =
        line |> String.split(~r/[^\d]+/, trim: true) |> Enum.map(&String.to_integer/1)

      %Blueprint{
        id: id,
        or: [or: oror],
        cl: [or: clor],
        ob: [or: obor, cl: obcl],
        ge: [or: geor, ob: geob],
        mxs: [or: Enum.max([oror, clor, obor, geor]), cl: obcl, ob: geob, ge: 1_000_000]
      }
    end
  end

  defmodule State do
    defstruct bts: %{or: 1, cl: 0, ob: 0, ge: 0}, rcs: %{or: 0, cl: 0, ob: 0, ge: 0}, min: 0

    def geodes(state), do: state.rcs.ge

    def rm_excess(state, %{mxs: mxs}, time),
      do: %{state | rcs: Map.new(state.rcs, fn {k, v} -> {k, min(v, mxs[k] * (time - 1))} end)}

    def possible_bots(%State{bts: %{ob: ob}}) when ob >= 1, do: [:ge, :ob, :cl, :or]
    def possible_bots(%State{bts: %{cl: cl}}) when cl >= 1, do: [:ob, :cl, :or]
    def possible_bots(_), do: [:cl, :or]

    def want_bot?(state, bp, time, bot)
    def want_bot?(_, _, 1, _), do: false

    def want_bot?(%State{bts: bts, rcs: rcs}, %Blueprint{mxs: mxs}, time, bot),
      do: bts[bot] < mxs[bot] && rcs[bot] < mxs[bot] * (time - 1)

    def pass_time(state = %State{bts: bts, rcs: rcs, min: m}, time),
      do: %{state | rcs: Map.new(rcs, fn {k, v} -> {k, v + bts[k] * time} end), min: m + time}

    def time_to_bot_created(state, %Blueprint{or: cst}, :or), do: t_2_b_cr(state, cst)

    def time_to_bot_created(state, %Blueprint{cl: cst}, :cl), do: t_2_b_cr(state, cst)

    def time_to_bot_created(state, %Blueprint{ob: cst}, :ob), do: t_2_b_cr(state, cst)

    def time_to_bot_created(state, %Blueprint{ge: cst}, :ge), do: t_2_b_cr(state, cst)

    defp t_2_b_cr(%State{bts: bts, rcs: rcs}, cst) do
      (cst
       |> Enum.map(fn {k, v} -> ((v - rcs[k]) / bts[k]) |> ceil() end)
       |> Enum.max()
       |> max(0)) + 1
    end

    def create_bot(state, %Blueprint{or: cst}, :or), do: cr_b(state, cst, :or)
    def create_bot(state, %Blueprint{cl: cst}, :cl), do: cr_b(state, cst, :cl)
    def create_bot(state, %Blueprint{ob: cst}, :ob), do: cr_b(state, cst, :ob)
    def create_bot(state, %Blueprint{ge: cst}, :ge), do: cr_b(state, cst, :ge)

    defp cr_b(state = %State{bts: bts, rcs: rcs}, cst, bot),
      do: %{
        state
        | rcs: Enum.reduce(cst, rcs, fn {k, v}, nrcs -> Map.update!(nrcs, k, &(&1 - v)) end),
          bts: Map.update!(bts, bot, &(&1 + 1))
      }
  end

  def puzzle1() do
    input_to_blueprints()
    |> Enum.map(fn bp ->
      Task.async(fn ->
        IO.puts(:stderr, "#{inspect(self())} checking blueprint #{inspect(bp)}")
        {bp.id, open_geodes(bp, 24)}
      end)
    end)
    |> Task.await_many(:infinity)
    |> Enum.map(fn {id, geodes} -> id * geodes end)
    |> Enum.sum()
  end

  def puzzle2() do
    # For this part, the result for my 3rd blueprint is wrong, I don't know why
    input_to_blueprints()
    |> Enum.take(3)
    |> Enum.map(fn bp ->
      Task.async(fn ->
        IO.puts(:stderr, "#{inspect(self())} checking blueprint #{inspect(bp)}")
        open_geodes(bp, 32)
      end)
    end)
    |> Task.await_many(:infinity)
    |> IO.inspect()
    |> Enum.product()
  end

  defp input_to_blueprints,
    do: AdventOfCodex2022.read_input(19, trim: true) |> Enum.map(&Blueprint.from_line/1)

  def open_geodes(blueprint, max_time) do
    cache = :ets.new(:"cache_bp#{blueprint.id}", [:set, :named_table])

    {geodes, steps} = max_geodes(%State{}, blueprint, max_time, cache)

    :ets.delete(cache)

    Enum.with_index(steps, 1)
    |> Enum.each(fn {step, index} -> IO.inspect(step, label: "minute #{index}") end)

    geodes
  end

  defp max_geodes(state, blueprint, time, cache)
  defp max_geodes(state, _, 0, _), do: {State.geodes(state), []}

  defp max_geodes(st, bp, time, cch) do
    c_key = {st |> State.rm_excess(bp, time), time}

    case :ets.lookup(cch, c_key) do
      [{_k, val}] ->
        val

      _ ->
        dft = {st |> State.pass_time(time) |> State.geodes(), []}

        st
        |> State.possible_bots()
        |> Enum.filter(&State.want_bot?(st, bp, time, &1))
        |> Enum.map(fn bot ->
          case State.time_to_bot_created(st, bp, bot) do
            t2b when t2b >= time ->
              dft

            t2b ->

              {ge, pa} =
                st
                |> State.pass_time(t2b)
                |> State.create_bot(bp, bot)
                |> max_geodes(bp, time - t2b, cch)

              {ge, [st | pa]}
          end
        end)
        |> Enum.max_by(&elem(&1, 0), &>=/2, fn -> dft end)
        |> tap(fn mx_ge -> :ets.insert(cch, {c_key, mx_ge}) end)
    end
  end
end
