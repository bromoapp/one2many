defmodule One2many.RoomManager do
    use GenServer
    alias One2many.Room
    alias One2many.Member
    import Process, only: [whereis: 1]
    require Logger

    def start_link(args \\ nil) do
        GenServer.start_link(__MODULE__, %Room{}, name: __MODULE__)
    end

    def init(map) do
        {:ok, map}
    end

    def put_anchor(member) do
        pid = whereis(__MODULE__)
        GenServer.call(pid, {:put_anchor, member})
    end

    def get_anchor do
        pid = whereis(__MODULE__)
        GenServer.call(pid, :get_anchor)
    end

    def del_anchor do
        pid = whereis(__MODULE__)
        GenServer.call(pid, :del_anchor)
    end

    def add_audience(member) do
        pid = whereis(__MODULE__)
        GenServer.call(pid, {:add_audience, member})
    end

    def del_audience(member) do
        pid = whereis(__MODULE__)
        GenServer.call(pid, {:del_audience, member})
    end

    def get_audience(name) do
        pid = whereis(__MODULE__)
        GenServer.call(pid, {:get_audience, name})
    end

    def get_audiences do
        pid = whereis(__MODULE__)
        GenServer.call(pid, :get_audiences)
    end

    def handle_call({:put_anchor, member}, _from, map) do
        map = Map.put(map, :anchor, member)
        {:reply, :ok, map}
    end

    def handle_call(:get_anchor, _from, map) do
        {:reply, map.anchor, map}
    end

    def handle_call(:del_anchor, _from, map) do
        map = Map.put(map, :anchor, nil)
        {:reply, :ok, map}
    end

    def handle_call({:add_audience, member}, _from, map) do
        list = map.audiences
        map = Map.put(map, :audiences, list ++ [member])
        {:reply, :ok, map}
    end

    def handle_call({:del_audience, member}, _from, map) do
        list = map.audiences |>
            Enum.filter(fn(%Member{name: name}) -> name != member.name end)
        map = Map.put(map, :audiences, list)
        {:reply, :ok, map}
    end

    def handle_call({:get_audience, audience_name}, _from, map) do
        result = map.audiences |>
            Enum.filter(fn(%Member{name: name}) -> name == audience_name end)
        cond do
            result == [] ->
                {:reply, nil, map}
            true ->
                [audience] = result
                {:reply, audience, map}
        end
        
    end

    def handle_call(:get_audiences, _from, map) do
        {:reply, map.audiences, map}
    end
end