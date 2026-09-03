local db = require("tokuboilerplate.db.loaded")
local json = require("cjson")

local method = ngx.req.get_method()

if method ~= "POST" then
  local args = ngx.req.get_uri_args()
  ngx.header.content_type = "application/json"
  ngx.say(db.list_items(tonumber(args.limit)))
  return
end

ngx.req.read_body()
local body = ngx.req.get_body_data()
local ok, req = pcall(json.decode, body or "")
if not ok or type(req) ~= "table"
  or type(req.name) ~= "string" or #req.name == 0 or #req.name > 200 then
  ngx.status = 400
  ngx.header.content_type = "application/json"
  ngx.say(json.encode({ error = "bad_body" }))
  return ngx.exit(400)
end

ngx.header.content_type = "application/json"
ngx.say(json.encode({ id = db.create_item(req.name) }))
