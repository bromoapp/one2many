defmodule One2many.PageController do
  use One2many.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
