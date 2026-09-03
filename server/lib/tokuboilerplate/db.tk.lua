<%
  local fs = require("santoku.fs")
  local serialize = require("santoku.serialize")
  local migrations = {}
  for fp in fs.files("res/server/migrations") do
    migrations[fs.basename(fp)] = readfile(fp)
  end
  t_migrations = serialize(migrations, true)
%>

local err = require("santoku.error")
local db_mod = require("santoku.sqlite.db")
local sqlite = require("santoku.sqlite")
local migrate = require("santoku.sqlite.migrate")

return function (db_file, opts)

  opts = opts or {}
  local M = {}
  local db = sqlite(err.assert(db_mod.open(db_file)))

  db.exec("pragma busy_timeout = 30000")
  db.exec("pragma journal_mode = WAL")
  db.exec("pragma synchronous = NORMAL")
  db.exec("pragma foreign_keys = on")

  if not opts.no_migrate then
    migrate(db, <% return t_migrations %>) -- luacheck: ignore
  end

  M.db = db

  local create_item = db.inserter([[
    insert into items (name) values (?1)
  ]])

  M.create_item = function (name)
    return create_item(name)
  end

  local list_items = db.getter([[
    select json_object('items', coalesce((
      select json_group_array(json_object(
        'id', id,
        'name', name,
        'created_at', created_at))
      from (select id, name, created_at from items order by id desc limit ?1)
    ), json_array()))
  ]])

  M.list_items = function (limit)
    return list_items(limit or 50)
  end

  return M

end
