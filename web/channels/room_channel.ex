defmodule One2many.RoomChannel do
    use One2many.Web, :channel
    alias One2many.RoomManager
    alias One2many.Member
    require Logger

    def join("room", _params, socket) do
        user = socket.assigns.user
        cond do
            String.contains? user, "audience" ->
                send self(), "new_audience"
            true ->
                send self(), "new_anchor"
        end
        {:ok, socket}
    end

    ##############################################################################
    # Anchor's related functions
    ##############################################################################

    def handle_info("new_anchor", socket) do
        user = socket.assigns.user
        Logger.info(">>> ANCHOR JOIN: #{user}")
        :ok = RoomManager.put_anchor(%Member{name: user, socket: socket})

        audiences = RoomManager.get_audiences()
        cond do
            audiences == [] ->
                Logger.info(">>> AUDIENCES NONE")
                :ignore
            true ->
                Enum.each(audiences, fn(%Member{name: name}) ->
                    push socket, "new_audience", %{"user" => name}
                end)
        end
        {:noreply, socket}
    end

    def handle_in("anchor_sdp", %{"to" => member, "body" => body}, socket) do
        #Logger.info(">>> TO NAME: #{inspect member}")
        %{"user" => name} = member
        audience = RoomManager.get_audience(name)
        cond do
            audience != nil ->
                #Logger.info(">>> FORWARD SDP...")
                user = socket.assigns.user
                push audience.socket, "sdp", %{"origin" => user, "body" => body}
            true ->
                Logger.info(">>> IGNORE SDP...")
                :ignore
        end
        {:noreply, socket}
    end
    
    def handle_in("anchor_candidate", %{"to" => member, "body" => body}, socket) do
        %{"user" => name} = member
        audience = RoomManager.get_audience(name)
        cond do
            audience != nil ->
                #Logger.info(">>> FORWARD CANDIDATE...")
                user = socket.assigns.user
                push audience.socket, "candidate", %{"origin" => user, "body" => body}
            true ->
                Logger.info(">>> IGNORE CANDIDATE...")
                :ignore
        end
        {:noreply, socket}
    end

    ##############################################################################
    # Audience's related functions
    ##############################################################################

    def handle_info("new_audience", socket) do
        user = socket.assigns.user
        Logger.info(">>> AUDIENCE JOIN: #{user}")
        :ok = RoomManager.add_audience(%Member{name: user, socket: socket})

        anchor = RoomManager.get_anchor()
        cond do
            anchor == nil ->
                Logger.info(">>> IGNORE NEW AUDIENCE")
                :ignore
            true ->
                Logger.info(">>> INFO NEW AUDIENCE TO ANCHOR")
                push anchor.socket, "new_audience",  %{"user" => user}
        end
        {:noreply, socket}
    end

    def handle_in("audience_sdp", %{"body" => body}, socket) do
        anchor = RoomManager.get_anchor
        cond do
            anchor != nil ->
                user = socket.assigns.user
                push anchor.socket, "sdp", %{"origin" => user, "body" => body}
            true ->
                Logger.info(">>> IGNORE SDP...")
                :ignore
        end
        {:noreply, socket}
    end

    def terminate(_reason, socket) do
        user = socket.assigns.user
        cond do
            user == "anchor" ->
                Logger.info(">>> DELETE ANCHOR")
                RoomManager.del_anchor()
            true ->
                Logger.info(">>> DELETE AUDIENCE #{user}")
                :ok = RoomManager.del_audience(%Member{name: user, socket: socket})
        end
        {:noreply, socket}
    end
end