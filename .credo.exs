%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["config/", "lib/", "test/"],
        excluded: [~r"/_build/", ~r"/deps/"]
      },
      requires: [],
      check_for_updates: true,
      strict: true,
      color: true
    }
  ]
}
