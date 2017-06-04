defmodule One2many.AudienceController do
    use One2many.Web, :controller

    def index(conn, _args) do
        render conn, "index.html"
    end
end