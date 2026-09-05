local test = require("santoku.test")
local err = require("santoku.error")
local str = require("santoku.string")
local arr = require("santoku.array")

test("db module, no server", function ()
  local db = require("tokuboilerplate.db")(":memory:")
  local id = db.create_item("first")
  err.assert(id == 1, "expected rowid 1, got " .. tostring(id))
  local out = db.list_items(10)
  err.assert(str.find(out, "\"first\"", 1, true), "created row listed")
end)

test("items endpoint", function ()
  local http = require("socket.http")
  local ltn12 = require("ltn12")
  local env = require("santoku.env")
  local port = env.var("PORT")
  local url = "http://localhost:" .. port .. "/items"
  local body = "{\"name\":\"from the spec\"}"
  local chunks = {}
  local ok, code = http.request({
    url = url,
    method = "POST",
    headers = {
      ["content-type"] = "application/json",
      ["content-length"] = tostring(#body),
    },
    source = ltn12.source.string(body),
    sink = ltn12.sink.table(chunks),
  })
  err.assert(ok, "no response on port " .. port .. " (" .. tostring(code) .. ")")
  err.assert(code == 200, "expected 200, got " .. tostring(code))
  err.assert(str.find(arr.concat(chunks), "\"id\""), "response carries id")
  chunks = {}
  ok, code = http.request({ url = url, sink = ltn12.sink.table(chunks) })
  err.assert(ok and code == 200, "list failed: " .. tostring(code))
  err.assert(str.find(arr.concat(chunks), "from the spec", 1, true),
    "posted row listed")
end)
