defmodule Kore.SchedulerTest do
  use ExUnit.Case

  test "run the function multiple times" do
    {:ok, agent} = Agent.start_link(fn -> 0 end)
    fun = fn -> Agent.update(agent, &(&1 + 1)) end

    {:ok, _pid} = Kore.Scheduler.start_link(fun: fun, frequency: 10)
    :timer.sleep(100)
    assert Agent.get(agent, & &1) >= 3
  end

  test "no firstrun then don't run" do
    {:ok, agent} = Agent.start_link(fn -> 0 end)
    fun = fn -> Agent.update(agent, &(&1 + 1)) end

    {:ok, _pid} = Kore.Scheduler.start_link(fun: fun, frequency: 100_000)
    :timer.sleep(35)
    assert Agent.get(agent, & &1) == 0
  end

  test "firstrun set then use as first wait" do
    {:ok, agent} = Agent.start_link(fn -> 0 end)
    fun = fn -> Agent.update(agent, &(&1 + 1)) end

    {:ok, _pid} = Kore.Scheduler.start_link(fun: fun, firstrun: 10, frequency: 100_000)
    :timer.sleep(35)
    assert Agent.get(agent, & &1) == 1
  end

  test "multiple ones" do
    {:ok, a1} = Agent.start_link(fn -> 0 end)
    fun1 = fn -> Agent.update(a1, &(&1 + 1)) end

    {:ok, a2} = Agent.start_link(fn -> 0 end)
    fun2 = fn -> Agent.update(a2, &(&1 + 2)) end

    {:ok, _pid} = Kore.Scheduler.start_link(name: :fun1, fun: fun1, frequency: 10)
    {:ok, _pid} = Kore.Scheduler.start_link(name: :fun2, fun: fun2, frequency: 10)

    :timer.sleep(100)
    assert Agent.get(a1, & &1) >= 3
    assert Agent.get(a2, & &1) >= 6
  end
end
