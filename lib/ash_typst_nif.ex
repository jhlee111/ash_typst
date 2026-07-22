defmodule AshTypst.NIF do
  @moduledoc false

  # This fork patches native/typst_nif/src/lib.rs (the 64MB-stack compile thread
  # and `set_virtual_file_binary`), so upstream's release artifacts do NOT match
  # this crate — the base_url must point at THIS repo's releases, built by
  # .github/workflows/release.yml on every `v*` tag.
  #
  # `checksum-Elixir.AshTypst.NIF.exs` is committed (unlike a hex package, where
  # it ships via `package[:files]`) because consumers pull this as a git dep and
  # rustler_precompiled reads the checksum from the dep's own directory.
  #
  # Set ASH_TYPST_BUILD=1 to compile the crate from source instead — needed when
  # editing lib.rs, and to bootstrap the checksum file for a new tag.
  use RustlerPrecompiled,
    otp_app: :ash_typst,
    crate: "typst_nif",
    base_url:
      "https://github.com/jhlee111/ash_typst/releases/download/v#{Mix.Project.config()[:version]}",
    # Passing :force_build explicitly beats rustler_precompiled's own
    # `Keyword.put_new` fallback, so the `config :rustler_precompiled,
    # :force_build, ash_typst: true` in this repo's dev/test config would go
    # dead — and editing lib.rs would silently test against the last release.
    # Fold it back in. Consumers don't set it, so they still download.
    force_build:
      System.get_env("ASH_TYPST_BUILD") in ["1", "true"] or
        Application.compile_env(:rustler_precompiled, [:force_build, :ash_typst], false),
    version: Mix.Project.config()[:version],
    # Must match release.yml's `nif:` matrix. A 2.15 artifact loads fine on
    # newer OTP (the NIF API is backward compatible), so one build covers all.
    nif_versions: ["2.15"],
    # Must match release.yml's `job:` matrix — a target listed here without a
    # published artifact turns into a 404 at compile time.
    targets: ~w(
      aarch64-apple-darwin
      aarch64-unknown-linux-gnu
      x86_64-apple-darwin
      x86_64-unknown-linux-gnu
    )

  def context_new(_opts), do: :erlang.nif_error(:not_loaded)
  def context_set_markup(_ctx, _markup), do: :erlang.nif_error(:not_loaded)
  def context_compile(_ctx), do: :erlang.nif_error(:not_loaded)
  def context_render_svg(_ctx, _page), do: :erlang.nif_error(:not_loaded)
  def context_export_pdf(_ctx, _opts), do: :erlang.nif_error(:not_loaded)
  def context_font_families(_ctx), do: :erlang.nif_error(:not_loaded)
  def context_set_virtual_file(_ctx, _path, _content), do: :erlang.nif_error(:not_loaded)
  def context_set_virtual_file_binary(_ctx, _path, _content), do: :erlang.nif_error(:not_loaded)
  def context_append_virtual_file(_ctx, _path, _chunk), do: :erlang.nif_error(:not_loaded)
  def context_clear_virtual_file(_ctx, _path), do: :erlang.nif_error(:not_loaded)
  def context_set_input(_ctx, _key, _value), do: :erlang.nif_error(:not_loaded)
  def context_set_inputs(_ctx, _inputs), do: :erlang.nif_error(:not_loaded)
  def context_export_html(_ctx), do: :erlang.nif_error(:not_loaded)
  def font_families(_opts), do: :erlang.nif_error(:not_loaded)
end
