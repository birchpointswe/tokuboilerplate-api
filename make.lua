local env = require("santoku.env")

return {
  env = {

    name = "tokuboilerplate",
    version = "0.0.1-1",
    license = "MIT",

    dependencies = {
      "lua == 5.1",
    },

    server = {
      dependencies = {
        "lua == 5.1",
        "santoku >= 2.0.0, < 3.0.0",
        "santoku-sqlite >= 3.0.1, < 4.0.0",
        "santoku-sqlite-migrate >= 2.0.0, < 3.0.0",
      },
      test = {
        dependencies = {
          "luasocket >= 3.0",
        },
      },
    },

    nginx = {
      domain = env.var("DOMAIN", "localhost"),
      port = "8080",
      workers = env.var("WORKERS", "auto"),
      modules = {
        "tokuboilerplate.web.init",
        "tokuboilerplate.web.init_worker",
        "tokuboilerplate.web.items",
      },
    },

  },
}
