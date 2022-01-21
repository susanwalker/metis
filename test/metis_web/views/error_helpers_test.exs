defmodule MetisWeb.ErrorHelpersTest do
  use ExUnit.Case

  alias MetisWeb.ErrorHelpers

  describe "error_tag/2" do
    test "adds a `span` tag for error to the given form when no count" do
      form = %Phoenix.HTML.Form{
        errors: [field: {"some error", []}]
      }

      result = ErrorHelpers.error_tag(form, :field)

      assert "span" in result[:safe]
      assert "some error" in result[:safe]
    end

    test "adds a `span` tag for error to the given form with count" do
      form = %Phoenix.HTML.Form{
        errors: [field: {"some error", [count: 2]}]
      }

      result = ErrorHelpers.error_tag(form, :field)

      assert "span" in result[:safe]
      assert "some error" in result[:safe]
    end
  end
end
