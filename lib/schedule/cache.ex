defmodule Schedule.Cache do
  use Supervisor

  @spec lookup(atom, any) :: any
  def lookup(table, id) do
    :ets.lookup(table, id)
  end

  @spec get(atom, any, any) :: any
  def get(table, id, func) do
    case :ets.lookup(table, id) do
      [{_id, state}] ->
        state

      [] ->
        state = func.()

        if not is_nil(state) do
          :ets.insert(table, {id, state})
        end

        state
    end
  end

  @spec put(atom, any, any) :: boolean
  def put(table, key, value) do
    :ets.insert(table, {key, value})
  end

  @spec purge(atom) :: any
  def purge(table) do
    :ets.delete_all_objects(table)
  end

  def child_spec(opts) do
    name = opts[:name] || raise ArgumentError, ":name is required"

    %{
      id: name,
      type: :supervisor,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(args) do
    name = args[:name]
    Supervisor.start_link(__MODULE__, args, name: name)
  end

  def init(args) do
    name = Keyword.get(args, :name)

    ^name = :ets.new(name, [:set, :named_table, :public, read_concurrency: true])

    Supervisor.init([], strategy: :one_for_one)
  end
end
