defmodule Kore.InmemoryStore do
  use GenServer

  @me __MODULE__

  @moduledoc """
  Implement a simple key-value store as a server. This
  version creates a named server, so there is no need
  to pass the server pid to the API calls.
  """

  @doc """
  Create the key-value store. The optional parameter
  is a collection of key-value pairs which can be used to
  populate the store.
  """

  def start_link(default) when is_list(default) do
    GenServer.start_link(@me, default, name: @me)
  end

  @doc """
  Add or update the entry associated with key.
  """
  def set(key, value) do
    GenServer.cast(@me, {:set, key, value})
  end

  @doc """
  Return the value associated with `key`, or `nil`
  is there is none.
  """
  def get(key, default_if_missing \\ nil) do
    GenServer.call(@me, {:get, key, default_if_missing})
  end

  @doc """
  Update an existing value.
  """
  def update(key, first_value, update_fn) do
    GenServer.call(@me, {:update, key, first_value, update_fn})
  end

  @doc """
  Return a sorted list of keys in the store.
  """

  def keys do
    GenServer.call(@me, {:keys})
  end

  @doc """
  Delete the entry corresponding to a key from the store
  """

  def delete(key) do
    GenServer.cast(@me, {:remove, key})
  end

  def reset() do
    GenServer.call(@me, :reset)
  end

  #######################
  # Server Implemention #
  #######################

  def init(args) do
    {:ok, Enum.into(args, %{})}
  end

  def handle_cast({:set, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end

  def handle_cast({:remove, key}, state) do
    {:noreply, Map.delete(state, key)}
  end

  def handle_call({:get, key, default_if_missing}, _from, state) do
    value = if Map.has_key?(state, key), do: state[key], else: default_if_missing
    {:reply, value, state}
  end

  def handle_call({:update, key, first_value, update_fn}, _from, state) do
    value =
      if Map.has_key?(state, key) do
        update_fn.(state[key])
      else
        first_value
      end

    {:reply, value, Map.put(state, key, value)}
  end

  def handle_call({:keys}, _from, state) do
    {:reply, Map.keys(state), state}
  end

  def handle_call(:reset, _from, _state) do
    {:reply, :ok, %{}}
  end
end
