defmodule ExapisdWeb.Router do
  use ExapisdWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ExapisdWeb do
    pipe_through :api
    get("/*path", Api, :index)
  end
end
