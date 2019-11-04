defmodule GrafikWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use GrafikWeb, :controller
      use GrafikWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: GrafikWeb

      import Plug.Conn
      import GrafikWeb.Gettext
      alias GrafikWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/grafik_web/templates",
        namespace: GrafikWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import GrafikWeb.ErrorHelpers
      import GrafikWeb.Gettext
      alias GrafikWeb.Router.Helpers, as: Routes

      def form_general_error(changeset) do
        if (changeset.action) do
          {:safe, """
          <div class="alert alert-danger">
            <p>Coś poszło nie tak, popraw błędy formularza</p>
          </div>
          """}
        end
      end

      def save_button() do
        {:safe, """
        <button type="submit">
            <i class="icon icon-check"></i>
            Zapisz
        </button>
        """}
      end

      def new_button(path, text \\ "dodaj") do
        {:safe, """
        <a href="#{path}"
           class="button">
            <i class="icon icon-plus"></i>
            #{text}
        </a>
        """}
      end
      
      def list_button(path, text \\ "Lista") do
	{:safe, """
        <a href="#{path}"
           class="button">
            <i class="icon icon-laquo"></i>
            #{text}
        </a>
        """}
      end

      def edit_button(path, text \\ "Edytuj") do
        {:safe, """
        <a href="#{path}"
           class="button">
            <i class="icon icon-recycle"></i>
            #{text}
        </a>
        """}
      end

      def delete_button(path, item_name \\ "") do
        link "Usuń",
          to: path,
          method: :delete,
          data: [confirm: "Na pewno usunąć \"" <> item_name <> "\"?"]
      end
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import GrafikWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
