defmodule Kore.Scheduler do
  use GenServer

  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def init(opts) do
    fun = Keyword.get(opts, :fun, fn -> :ok end)
    frequency = Keyword.get(opts, :frequency, 60_000)
    firstrun = Keyword.get(opts, :firstrun, frequency)

    %{frequency: frequency, firstrun: firstrun, n: 0}
    |> schedule(fun)
    |> reply(:ok)
  end

  def handle_info({:go, fun}, state) do
    fun.()

    state
    |> schedule(fun)
    |> reply(:noreply)
  end

  def schedule(state, fun) do
    timeout = if state.n == 0, do: state.firstrun, else: state.frequency
    Process.send_after(self(), {:go, fun}, timeout)
    Map.update!(state, :n, &(&1 + 1))
  end

  defp reply(state, ok), do: {ok, state}
end
