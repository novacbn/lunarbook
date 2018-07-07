return (function (modules, ...)
    local _G            = _G
    local error         = _G.error
    local setfenv       = _G.setfenv
    local setmetatable  = _G.setmetatable

    local moduleCache       = {}
    local packageGlobals    = {}

    local function makeEnvironment(moduleChunk)
        local exports = {}

        local moduleEnvironment = setmetatable({}, {
            __index = function (self, key)
                if exports[key] ~= nil then
                    return exports[key]
                end

                return _G[key]
            end,

            __newindex = exports
        })

        return setfenv(moduleChunk, moduleEnvironment), exports
    end

    local function makeModuleHeader(moduleName)
        return {
            name    = moduleName,
            globals = packageGlobals
        }
    end

    local function makeReadOnly(tbl)
        return setmetatable({}, {
            __index = tbl,
            __newindex = function (self, key, value) error("module 'exports' table is read only") end
        })
    end

    local import = nil
    function import(moduleName, ...)
        local moduleChunk = modules[moduleName]
        if not moduleChunk then error("bad argument #1 to 'import' (invalid module, got '"..moduleName.."')") end

        if not moduleCache[moduleName] then
            local moduleHeader                  = makeModuleHeader(moduleName)
            local moduleEnvironment, exports    = makeEnvironment(moduleChunk)

            moduleEnvironment(moduleHeader, exports, import, import, ...)

            moduleCache[moduleName] = makeReadOnly(exports)
        end

        return moduleCache[moduleName]
    end

    local loadstring = _G.loadstring

    for moduleName, assetChunk in pairs(modules) do
        modules[moduleName] = loadstring('return function (module, exports, import, dependency, ...) '..assetChunk..' end', moduleName)()
    end

    return import('novacbn/lunarbook-plugin-builtin/exports', ...)
end)({['leafo/tableshape/exports'] = "local OptionalType, TaggedType, types\
local FailedTransform = { }\
local unpack = unpack or table.unpack\
local clone_state\
clone_state = function(state_obj)\
  if type(state_obj) ~= \"table\" then\
    return { }\
  end\
  local out\
  do\
    local _tbl_0 = { }\
    for k, v in pairs(state_obj) do\
      _tbl_0[k] = v\
    end\
    out = _tbl_0\
  end\
  do\
    local mt = getmetatable(state_obj)\
    if mt then\
      setmetatable(out, mt)\
    end\
  end\
  return out\
end\
local BaseType, TransformNode, SequenceNode, FirstOfNode, DescribeNode\
local describe_literal\
describe_literal = function(val)\
  local _exp_0 = type(val)\
  if \"string\" == _exp_0 then\
    if not val:match('\"') then\
      return \"\\\"\" .. tostring(val) .. \"\\\"\"\
    elseif not val:match(\"'\") then\
      return \"'\" .. tostring(val) .. \"'\"\
    else\
      return \"`\" .. tostring(val) .. \"`\"\
    end\
  else\
    if BaseType:is_base_type(val) then\
      return val:_describe()\
    else\
      return tostring(val)\
    end\
  end\
end\
local join_names\
join_names = function(items, sep, last_sep)\
  if sep == nil then\
    sep = \", \"\
  end\
  local count = #items\
  local chunks = { }\
  for idx, name in ipairs(items) do\
    if idx > 1 then\
      local current_sep\
      if idx == count then\
        current_sep = last_sep or sep\
      else\
        current_sep = sep\
      end\
      table.insert(chunks, current_sep)\
    end\
    table.insert(chunks, name)\
  end\
  return table.concat(chunks)\
end\
do\
  local _class_0\
  local _base_0 = {\
    __eq = function(self, other)\
      if BaseType:is_base_type(other) then\
        return other(self)\
      else\
        return self(other[1])\
      end\
    end,\
    __div = function(self, fn)\
      return TransformNode(self, fn)\
    end,\
    __mod = function(self, fn)\
      do\
        local _with_0 = TransformNode(self, fn)\
        _with_0.with_state = true\
        return _with_0\
      end\
    end,\
    __mul = function(self, right)\
      return SequenceNode(self, right)\
    end,\
    __add = function(self, right)\
      if self.__class == FirstOfNode then\
        local options = {\
          unpack(self.options)\
        }\
        table.insert(options, right)\
        return FirstOfNode(unpack(options))\
      else\
        return FirstOfNode(self, right)\
      end\
    end,\
    _describe = function(self)\
      return error(\"Node missing _describe: \" .. tostring(self.__class.__name))\
    end,\
    check_value = function(self, ...)\
      local value, state_or_err = self:_transform(...)\
      if value == FailedTransform then\
        return nil, state_or_err\
      end\
      if type(state_or_err) == \"table\" then\
        return state_or_err\
      else\
        return true\
      end\
    end,\
    transform = function(self, ...)\
      local value, state_or_err = self:_transform(...)\
      if value == FailedTransform then\
        return nil, state_or_err\
      end\
      if type(state_or_err) == \"table\" then\
        return value, state_or_err\
      else\
        return value\
      end\
    end,\
    repair = function(self, ...)\
      return self:transform(...)\
    end,\
    on_repair = function(self, fn)\
      return (self + types.any / fn * self):describe(function()\
        return self:_describe()\
      end)\
    end,\
    is_optional = function(self)\
      return OptionalType(self)\
    end,\
    describe = function(self, ...)\
      return DescribeNode(self, ...)\
    end,\
    tag = function(self, name)\
      return TaggedType(self, {\
        tag = name\
      })\
    end,\
    clone_opts = function(self, merge)\
      local opts\
      if self.opts then\
        do\
          local _tbl_0 = { }\
          for k, v in pairs(self.opts) do\
            _tbl_0[k] = v\
          end\
          opts = _tbl_0\
        end\
      else\
        opts = { }\
      end\
      if merge then\
        for k, v in pairs(merge) do\
          opts[k] = v\
        end\
      end\
      return opts\
    end,\
    __call = function(self, ...)\
      return self:check_value(...)\
    end\
  }\
  _base_0.__index = _base_0\
  _class_0 = setmetatable({\
    __init = function(self)\
      if self.opts then\
        self._describe = self.opts.describe\
      end\
    end,\
    __base = _base_0,\
    __name = \"BaseType\"\
  }, {\
    __index = _base_0,\
    __call = function(cls, ...)\
      local _self_0 = setmetatable({}, _base_0)\
      cls.__init(_self_0, ...)\
      return _self_0\
    end\
  })\
  _base_0.__class = _class_0\
  local self = _class_0\
  self.is_base_type = function(self, val)\
    if not (type(val) == \"table\") then\
      return false\
    end\
    local cls = val and val.__class\
    if not (cls) then\
      return false\
    end\
    if BaseType == cls then\
      return true\
    end\
    return self:is_base_type(cls.__parent)\
  end\
  self.__inherited = function(self, cls)\
    cls.__base.__call = cls.__call\
    cls.__base.__eq = self.__eq\
    cls.__base.__div = self.__div\
    cls.__base.__mod = self.__mod\
    cls.__base.__mul = self.__mul\
    cls.__base.__add = self.__add\
    local mt = getmetatable(cls)\
    local create = mt.__call\
    mt.__call = function(cls, ...)\
      local ret = create(cls, ...)\
      if ret.opts and ret.opts.optional then\
        return ret:is_optional()\
      else\
        return ret\
      end\
    end\
  end\
  BaseType = _class_0\
end\
do\
  local _class_0\
  local _parent_0 = BaseType\
  local _base_0 = {\
    _describe = function(self)\
      return self.node:_describe()\
    end,\
    _transform = function(self, value, state)\
      local state_or_err\
      value, state_or_err = self.node:_transform(value, state)\
      if value == FailedTransform then\
        return FailedTransform, state_or_err\
      else\
        local out\
        local _exp_0 = type(self.t_fn)\
        if \"function\" == _exp_0 then\
          if self.with_state then\
            out = self.t_fn(value, state_or_err)\
          else\
            out = self.t_fn(value)\
          end\
        else\
          out = self.t_fn\
        end\
        return out, state_or_err\
      end\
    end\
  }\
  _base_0.__index = _base_0\
  setmetatable(_base_0, _parent_0.__base)\
  _class_0 = setmetatable({\
    __init = function(self, node, t_fn)\
      self.node, self.t_fn = node, t_fn\
      return assert(self.node, \"missing node for transform\")\
    end,\
    __base = _base_0,\
    __name = \"TransformNode\",\
    __parent = _parent_0\
  }, {\
    __index = function(cls, name)\
      local val = rawget(_base_0, name)\
      if val == nil then\
        local parent = rawget(cls, \"__parent\")\
        if parent then\
          return parent[name]\
        end\
      else\
        return val\
      end\
    end,\
    __call = function(cls, ...)\
      local _self_0 = setmetatable({}, _base_0)\
      cls.__init(_self_0, ...)\
      return _self_0\
    end\
  })\
  _base_0.__class = _class_0\
  local self = _class_0\
  self.transformer = true\
  if _parent_0.__inherited then\
    _parent_0.__inherited(_parent_0, _class_0)\
  end\
  TransformNode = _class_0\
end\
do\
  local _class_0\
  local _parent_0 = BaseType\
  local _base_0 = {\
    _describe = function(self)\
      local item_names\
      do\
        local _accum_0 = { }\
        local _len_0 = 1\
        local _list_0 = self.sequence\
        for _index_0 = 1, #_list_0 do\
          local i = _list_0[_index_0]\
          if type(i) == \"table\" and i._describe then\
            _accum_0[_len_0] = i:_describe()\
          else\
            _accum_0[_len_0] = describe_literal(i)\
          end\
          _len_0 = _len_0 + 1\
        end\
        item_names = _accum_0\
      end\
      return join_names(item_names, \" then \")\
    end,\
    _transform = function(self, value, state)\
      local _list_0 = self.sequence\
      for _index_0 = 1, #_list_0 do\
        local node = _list_0[_index_0]\
        value, state = node:_transform(value, state)\
        if value == FailedTransform then\
          break\
        end\
      end\
      return value, state\
    end\
  }\
  _base_0.__index = _base_0\
  setmetatable(_base_0, _parent_0.__base)\
  _class_0 = setmetatable({\
    __init = function(self, ...)\
      self.sequence = {\
        ...\
      }\
    end,\
    __base = _base_0,\
    __name = \"SequenceNode\",\
    __parent = _parent_0\
  }, {\
    __index = function(cls, name)\
      local val = rawget(_base_0, name)\
      if val == nil then\
        local parent = rawget(cls, \"__parent\")\
        if parent then\
          return parent[name]\
        end\
      else\
        return val\
      end\
    end,\
    __call = function(cls, ...)\
      local _self_0 = setmetatable({}, _base_0)\
      cls.__init(_self_0, ...)\
      return _self_0\
    end\
  })\
  _base_0.__class = _class_0\
  local self = _class_0\
  self.transformer = true\
  if _parent_0.__inherited then\
    _parent_0.__inherited(_parent_0, _class_0)\
  end\
  SequenceNode = _class_0\
end\
do\
  local _class_0\
  local _parent_0 = BaseType\
  local _base_0 = {\
    _describe = function(self)\
      local item_names\
      do\
        local _accum_0 = { }\
        local _len_0 = 1\
        local _list_0 = self.options\
        for _index_0 = 1, #_list_0 do\
          local i = _list_0[_index_0]\
          if type(i) == \"table\" and i._describe then\
            _accum_0[_len_0] = i:_describe()\
          else\
            _accum_0[_len_0] = describe_literal(i)\
          end\
          _len_0 = _len_0 + 1\
        end\
        item_names = _accum_0\
      end\
      return join_names(item_names, \", \", \", or \")\
    end,\
    _transform = function(self, value, state)\
      if not (self.options[1]) then\
        return FailedTransform, \"no options for node\"\
      end\
      local _list_0 = self.options\
      for _index_0 = 1, #_list_0 do\
        local node = _list_0[_index_0]\
        local new_val, new_state = node:_transform(value, state)\
        if not (new_val == FailedTransform) then\
          return new_val, new_state\
        end\
      end\
      return FailedTransform, \"expected \" .. tostring(self:_describe())\
    end\
  }\
  _base_0.__index = _base_0\
  setmetatable(_base_0, _parent_0.__base)\
  _class_0 = setmetatable({\
    __init = function(self, ...)\
      self.options = {\
        ...\
      }\
    end,\
    __base = _base_0,\
    __name = \"FirstOfNode\",\
    __parent = _parent_0\
  }, {\
    __index = function(cls, name)\
      local val = rawget(_base_0, name)\
      if val == nil then\
        local parent = rawget(cls, \"__parent\")\
        if parent then\
          return parent[name]\
        end\
      else\
        return val\
      end\
    end,\
    __call = function(cls, ...)\
      local _self_0 = setmetatable({}, _base_0)\
      cls.__init(_self_0, ...)\
      return _self_0\
    end\
  })\
  _base_0.__class = _class_0\
  local self = _class_0\
  self.transformer = true\
  if _parent_0.__inherited then\
    _parent_0.__inherited(_parent_0, _class_0)\
  end\
  FirstOfNode = _class_0\
end\
do\
  local _class_0\
  local _parent_0 = BaseType\
  local _base_0 = {\
    _transform = function(self, input, ...)\
      local value, state = self.node:_transform(input, ...)\
      if value == FailedTransform then\
        local err\
        if self.err_handler then\
          err = self.err_handler(input, state)\
        else\
          err = \"expected \" .. tostring(self:_describe())\
        end\
        return FailedTransform, err\
      end\
      return value, state\
    end,\
    describe = function(self, ...)\
      return DescribeNode(self.node, ...)\
    end\
  }\
  _base_0.__index = _base_0\
  setmetatable(_base_0, _parent_0.__base)\
  _class_0 = setmetatable({\
    __init = function(self, node, describe)\
      self.node = node\
      local err_message\
      if type(describe) == \"table\" then\
        describe, err_message = describe.type, describe.error\
      end\
      if type(describe) == \"string\" then\
        self._describe = function()\
          return describe\
        end\
      else\
        self._describe = describe\
      end\
      if err_message then\
        if type(err_message) == \"string\" then\
          self.err_handler = function()\
            return err_message\
          end\
        else\
          self.err_handler = err_message\
        end\
      end\
    end,\
    __base = _base_0,\
    __name = \"DescribeNode\",\
    __parent = _parent_0\
  }, {\
    __index = function(cls, name)\
      local val = rawget(_base_0, name)\
      if val == nil then\
        local parent = rawget(cls, \"__parent\")\
        if parent then\
          return parent[name]\
        end\
      else\
        return val\
      end\
    end,\
    __call = function(cls, ...)\
      local _self_0 = setmetatable({}, _base_0)\
      cls.__init(_self_0, ...)\
      return _self_0\
    end\
  })\
  _base_0.__class = _class_0\
  if _parent_0.__inherited then\
    _parent_0.__inherited(_parent_0, _class_0)\
  end\
  DescribeNode = _class_0\
end\
do\
  local _class_0\
  local _parent_0 = BaseType\
  local _base_0 = {\
    update_state = function(self, state, value, ...)\
      local out = clone_state(state)\
      if self.tag_type == \"function\" then\
        if select(\"#\", ...) > 0 then\
          self.tag_name(out, ..., value)\
        else\
          self.tag_name(out, value)\
        end\
      else\
        if self.tag_array then\
          local existing = out[self.tag_name]\
          if type(existing) == \"table\" then\
            local copy\
            do\
              local _tbl_0 = { }\
              for k, v in pairs(existing) do\
                _tbl_0[k] = v\
              end\
              copy = _tbl_0\
            end\
            table.insert(copy, value)\
            out[self.tag_name] = copy\
          else\
            out[self.tag_name] = {\
              value\
            }\
          end\
        else\
          out[self.tag_name] = value\
        end\
      end\
      return out\
    end,\
    _transform = function(self, value, state)\
      value, state = self.base_type:_transform(value, state)\
      if value == FailedTransform then\
        return FailedTransform, state\
      end\
      state = self:update_state(state, value)\
      return value, state\
    end,\
    _describe = function(self)\
      local base_description = self.base_type:_describe()\
      return tostring(base_description) .. \" tagged \" .. tostring(describe_literal(self.tag))\
    end\
  }\
  _base_0.__index = _base_0\
  setmetatable(_base_0, _parent_0.__base)\
  _class_0 = setmetatable({\
    __init = function(self, base_type, opts)\
      self.base_type = base_type\
      self.tag_name = assert(opts.tag, \"tagged type missing tag\")\
      self.tag_type = type(self.tag_name)\
      if self.tag_type == \"string\" then\
        if self.tag_name:match(\"%[%]$\") then\
          self.tag_name = self.tag_name:sub(1, -3)\
          self.tag_array = true\
        end\
      end\
    end,\
    __base = _base_0,\
    __name = \"TaggedType\",\
    __parent = _parent_0\
  }, {\
    __index = function(cls, name)\
      local val = rawget(_base_0, name)\
      if val == nil then\
        local parent = rawget(cls, \"__parent\")\
        if parent then\
          return parent[name]\
        end\
      else\
        return val\
      end\
    end,\
    __call = function(cls, ...)\
      local _self_0 = setmetatable({}, _base_0)\
      cls.__init(_self_0, ...)\
      return _self_0\
    end\
  })\
  _base_0.__class = _class_0\
  if _parent_0.__inherited then\
    _parent_0.__inherited(_parent_0, _class_0)\
  end\
  TaggedType = _class_0\
end\
local TagScopeType\
do\
  local _class_0\
  local _parent_0 = TaggedType\
  local _base_0 = {\
    create_scope_state = function(self, state)\
      return nil\
    end,\
    _transform = function(self, value, state)\
      local scope\
      value, scope = self.base_type:_transform(value, self:create_scope_state(state))\
      if value == FailedTransform then\
        return FailedTransform, scope\
      end\
      if self.tag_name then\
        state = self:update_state(state, scope, value)\
      end\
      return value, state\
    end\
  }\
  _base_0.__index = _base_0\
  setmetatable(_base_0, _parent_0.__base)\
  _class_0 = setmetatable({\
    __init = function(self, base_type, opts)\
      if opts then\
        return _class_0.__parent.__init(self, base_type, opts)\
      else\
        self.base_type = base_type\
      end\
    end,\
    __base = _base_0,\
    __name = \"TagScopeType\",\
    __parent = _parent_0\
  }, {\
    __index = function(cls, name)\
      local val = rawget(_base_0, name)\
      if val == nil then\
        local parent = rawget(cls, \"__parent\")\
        if parent then\
          return parent[name]\
        end\
      else\
        return val\
      end\
    end,\
    __call = function(cls, ...)\
      local _self_0 = setmetatable({}, _base_0)\
      cls.__init(_self_0, ...)\
      return _self_0\
    end\
  })\
  _base_0.__class = _class_0\
  if _parent_0.__inherited then\
    _parent_0.__inherited(_parent_0, _class_0)\
  end\
  TagScopeType = _class_0\
end\
do\
  local _class_0\
  local _parent_0 = BaseType\
  local _base_0 = {\
    _transform = function(self, value, state)\
      if value == nil then\
        return value, state\
      end\
      return self.base_type:_transform(value, state)\
    end,\
    is_optional = function(self)\
      return self\
    end,\
    _describe = function(self)\
      if self.base_type._describe then\
        local base_description = self.base_type:_describe()\
        return \"optional \" .. tostring(base_description)\
      end\
    end\
  }\
  _base_0.__index = _base_0\
  setmetatable(_base_0, _parent_0.__base)\
  _class_0 = setmetatable({\
    __init = function(self, base_type, opts)\
      self.base_type, self.opts = base_type, opts\
      _class_0.__parent.__init(self)\
      return assert(BaseType:is_base_type(base_type), \"expected a type checker\")\
    end,\
    __base = _base_0,\
    __name = \"OptionalType\",\
    __parent = _parent_0\
  }, {\
    __index = function(cls, name)\
      local val = rawget(_base_0, name)\
      if val == nil then\
        local parent = rawget(cls, \"__parent\")\
        if parent then\
          return parent[name]\
        end\
      else\
        return val\
      end\
    end,\
    __call = function(cls, ...)\
      local _self_0 = setmetatable({}, _base_0)\
      cls.__init(_self_0, ...)\
      return _self_0\
    end\
  })\
  _base_0.__class = _class_0\
  if _parent_0.__inherited then\
    _parent_0.__inherited(_parent_0, _class_0)\
  end\
  OptionalType = _class_0\
end\
local AnyType\
do\
  local _class_0\
  local _parent_0 = BaseType\
  local _base_0 = {\
    _transform = function(self, v, state)\
      return v, state\
    end,\
    _describe = function(self)\
      return \"anything\"\
    end,\
    is_optional = function(self)\
      return self\
    end\
  }\
  _base_0.__index = _base_0\
  setmetatable(_base_0, _parent_0.__base)\
  _class_0 = setmetatable({\
    __init = function(self, ...)\
      return _class_0.__parent.__init(self, ...)\
    end,\
    __base = _base_0,\
    __name = \"AnyType\",\
    __parent = _parent_0\
  }, {\
    __index = function(cls, name)\
      local val = rawget(_base_0, name)\
      if val == nil then\
        local parent = rawget(cls, \"__parent\")\
        if parent then\
          return parent[name]\
        end\
      else\
        return val\
      end\
    end,\
    __call = function(cls, ...)\
      local _self_0 = setmetatable({}, _base_0)\
      cls.__init(_self_0, ...)\
      return _self_0\
    end\
  })\
  _base_0.__class = _class_0\
  if _parent_0.__inherited then\
    _parent_0.__inherited(_parent_0, _class_0)\
  end\
  AnyType = _class_0\
end\
local Type\
do\
  local _class_0\
  local _parent_0 = BaseType\
  local _base_0 = {\
    _transform = function(self, value, state)\
      local got = type(value)\
      if self.t ~= got then\
        return FailedTransform, \"expected type \" .. tostring(describe_literal(self.t)) .. \", got \" .. tostring(describe_literal(got))\
      end\
      if self.length_type then\
        local len = #value\
        local res\
        res, state = self.length_type:_transform(len, state)\
        if res == FailedTransform then\
          return FailedTransform, tostring(self.t) .. \" length \" .. tostring(state) .. \", got \" .. tostring(len)\
        end\
      end\
      return value, state\
    end,\
    length = function(self, left, right)\
      local l\
      if BaseType:is_base_type(left) then\
        l = left\
      else\
        l = types.range(left, right)\
      end\
      return Type(self.t, self:clone_opts({\
        length = l\
      }))\
    end,\
    _describe = function(self)\
      local t = \"type \" .. tostring(describe_literal(self.t))\
      if self.length_type then\
        t = t .. \" length_type \" .. tostring(self.length_type:_describe())\
      end\
      return t\
    end\
  }\
  _base_0.__index = _base_0\
  setmetatable(_base_0, _parent_0.__base)\
  _class_0 = setmetatable({\
    __init = function(self, t, opts)\
      self.t, self.opts = t, opts\
      if self.opts then\
        self.length_type = self.opts.length\
      end\
      return _class_0.__parent.__init(self)\
    end,\
    __base = _base_0,\
    __name = \"Type\",\
    __parent = _parent_0\
  }, {\
    __index = function(cls, name)\
      local val = rawget(_base_0, name)\
      if val == nil then\
        local parent = rawget(cls, \"__parent\")\
        if parent then\
          return parent[name]\
        end\
      else\
        return val\
      end\
    end,\
    __call = function(cls, ...)\
      local _self_0 = setmetatable({}, _base_0)\
      cls.__init(_self_0, ...)\
      return _self_0\
    end\
  })\
  _base_0.__class = _class_0\
  if _parent_0.__inherited then\
    _parent_0.__inherited(_parent_0, _class_0)\
  end\
  Type = _class_0\
end\
local ArrayType\
do\
  local _class_0\
  local _parent_0 = BaseType\
  local _base_0 = {\
    _describe = function(self)\
      return \"an array\"\
    end,\
    _transform = function(self, value, state)\
      if not (type(value) == \"table\") then\
        return FailedTransform, \"expecting table\"\
      end\
      local k = 1\
      for i, v in pairs(value) do\
        if not (type(i) == \"number\") then\
          return FailedTransform, \"non number field: \" .. tostring(i)\
        end\
        if not (i == k) then\
          return FailedTransform, \"non array index, got \" .. tostring(describe_literal(i)) .. \" but expected \" .. tostring(describe_literal(k))\
        end\
        k = k + 1\
      end\
      return value, state\
    end\
  }\
  _base_0.__index = _base_0\
  setmetatable(_base_0, _parent_0.__base)\
  _class_0 = setmetatable({\
    __init = function(self, opts)\
      self.opts = opts\
      return _class_0.__parent.__init(self)\
    end,\
    __base = _base_0,\
    __name = \"ArrayType\",\
    __parent = _parent_0\
  }, {\
    __index = function(cls, name)\
      local val = rawget(_base_0, name)\
      if val == nil then\
        local parent = rawget(cls, \"__parent\")\
        if parent then\
          return parent[name]\
        end\
      else\
        return val\
      end\
    end,\
    __call = function(cls, ...)\
      local _self_0 = setmetatable({}, _base_0)\
      cls.__init(_self_0, ...)\
      return _self_0\
    end\
  })\
  _base_0.__class = _class_0\
  if _parent_0.__inherited then\
    _parent_0.__inherited(_parent_0, _class_0)\
  end\
  ArrayType = _class_0\
end\
local OneOf\
do\
  local _class_0\
  local _parent_0 = BaseType\
  local _base_0 = {\
    _describe = function(self)\
      local item_names\
      do\
        local _accum_0 = { }\
        local _len_0 = 1\
        local _list_0 = self.options\
        for _index_0 = 1, #_list_0 do\
          local i = _list_0[_index_0]\
          if type(i) == \"table\" and i._describe then\
            _accum_0[_len_0] = i:_describe()\
          else\
            _accum_0[_len_0] = describe_literal(i)\
          end\
          _len_0 = _len_0 + 1\
        end\
        item_names = _accum_0\
      end\
      return tostring(join_names(item_names, \", \", \", or \"))\
    end,\
    _transform = function(self, value, state)\
      if self.options_hash then\
        if self.options_hash[value] then\
          return value, state\
        end\
      else\
        local _list_0 = self.options\
        for _index_0 = 1, #_list_0 do\
          local _continue_0 = false\
          repeat\
            local item = _list_0[_index_0]\
            if item == value then\
              return value, state\
            end\
            if BaseType:is_base_type(item) then\
              local new_value, new_state = item:_transform(value, state)\
              if new_value == FailedTransform then\
                _continue_0 = true\
                break\
              end\
              return new_value, new_state\
            end\
            _continue_0 = true\
          until true\
          if not _continue_0 then\
            break\
          end\
        end\
      end\
      return FailedTransform, \"expected \" .. tostring(self:_describe())\
    end\
  }\
  _base_0.__index = _base_0\
  setmetatable(_base_0, _parent_0.__base)\
  _class_0 = setmetatable({\
    __init = function(self, options, opts)\
      self.options, self.opts = options, opts\
      _class_0.__parent.__init(self)\
      assert(type(self.options) == \"table\", \"expected table for options in one_of\")\
      local fast_opts = types.array_of(types.number + types.string)\
      if fast_opts(self.options) then\
        do\
          local _tbl_0 = { }\
          local _list_0 = self.options\
          for _index_0 = 1, #_list_0 do\
            local v = _list_0[_index_0]\
            _tbl_0[v] = true\
          end\
          self.options_hash = _tbl_0\
        end\
      end\
    end,\
    __base = _base_0,\
    __name = \"OneOf\",\
    __parent = _parent_0\
  }, {\
    __index = function(cls, name)\
      local val = rawget(_base_0, name)\
      if val == nil then\
        local parent = rawget(cls, \"__parent\")\
        if parent then\
          return parent[name]\
        end\
      else\
        return val\
      end\
    end,\
    __call = function(cls, ...)\
      local _self_0 = setmetatable({}, _base_0)\
      cls.__init(_self_0, ...)\
      return _self_0\
    end\
  })\
  _base_0.__class = _class_0\
  if _parent_0.__inherited then\
    _parent_0.__inherited(_parent_0, _class_0)\
  end\
  OneOf = _class_0\
end\
local AllOf\
do\
  local _class_0\
  local _parent_0 = BaseType\
  local _base_0 = {\
    _describe = function(self)\
      local item_names\
      do\
        local _accum_0 = { }\
        local _len_0 = 1\
        local _list_0 = self.types\
        for _index_0 = 1, #_list_0 do\
          local i = _list_0[_index_0]\
          if type(i) == \"table\" and i._describe then\
            _accum_0[_len_0] = i:_describe()\
          else\
            _accum_0[_len_0] = describe_literal(i)\
          end\
          _len_0 = _len_0 + 1\
        end\
        item_names = _accum_0\
      end\
      return join_names(item_names, \" and \")\
    end,\
    _transform = function(self, value, state)\
      local _list_0 = self.types\
      for _index_0 = 1, #_list_0 do\
        local t = _list_0[_index_0]\
        value, state = t:_transform(value, state)\
        if value == FailedTransform then\
          return FailedTransform, state\
        end\
      end\
      return value, state\
    end\
  }\
  _base_0.__index = _base_0\
  setmetatable(_base_0, _parent_0.__base)\
  _class_0 = setmetatable({\
    __init = function(self, types, opts)\
      self.types, self.opts = types, opts\
      _class_0.__parent.__init(self)\
      assert(type(self.types) == \"table\", \"expected table for first argument\")\
      local _list_0 = self.types\
      for _index_0 = 1, #_list_0 do\
        local checker = _list_0[_index_0]\
        assert(BaseType:is_base_type(checker), \"all_of expects all type checkers\")\
      end\
    end,\
    __base = _base_0,\
    __name = \"AllOf\",\
    __parent = _parent_0\
  }, {\
    __index = function(cls, name)\
      local val = rawget(_base_0, name)\
      if val == nil then\
        local parent = rawget(cls, \"__parent\")\
        if parent then\
          return parent[name]\
        end\
      else\
        return val\
      end\
    end,\
    __call = function(cls, ...)\
      local _self_0 = setmetatable({}, _base_0)\
      cls.__init(_self_0, ...)\
      return _self_0\
    end\
  })\
  _base_0.__class = _class_0\
  if _parent_0.__inherited then\
    _parent_0.__inherited(_parent_0, _class_0)\
  end\
  AllOf = _class_0\
end\
local ArrayOf\
do\
  local _class_0\
  local _parent_0 = BaseType\
  local _base_0 = {\
    _describe = function(self)\
      return \"array of \" .. tostring(describe_literal(self.expected))\
    end,\
    _transform = function(self, value, state)\
      local pass, err = types.table(value)\
      if not (pass) then\
        return FailedTransform, err\
      end\
      if self.length_type then\
        local len = #value\
        local res\
        res, state = self.length_type:_transform(len, state)\
        if res == FailedTransform then\
          return FailedTransform, \"array length \" .. tostring(state) .. \", got \" .. tostring(len)\
        end\
      end\
      local is_literal = not BaseType:is_base_type(self.expected)\
      local copy, k\
      for idx, item in ipairs(value) do\
        local skip_item = false\
        local transformed_item\
        if is_literal then\
          if self.expected ~= item then\
            return FailedTransform, \"array item \" .. tostring(idx) .. \": expected \" .. tostring(describe_literal(self.expected))\
          else\
            transformed_item = item\
          end\
        else\
          local item_val\
          item_val, state = self.expected:_transform(item, state)\
          if item_val == FailedTransform then\
            return FailedTransform, \"array item \" .. tostring(idx) .. \": \" .. tostring(state)\
          end\
          if item_val == nil and not self.keep_nils then\
            skip_item = true\
          else\
            transformed_item = item_val\
          end\
        end\
        if transformed_item ~= item or skip_item then\
          if not (copy) then\
            do\
              local _accum_0 = { }\
              local _len_0 = 1\
              local _max_0 = idx - 1\
              for _index_0 = 1, _max_0 < 0 and #value + _max_0 or _max_0 do\
                local i = value[_index_0]\
                _accum_0[_len_0] = i\
                _len_0 = _len_0 + 1\
              end\
              copy = _accum_0\
            end\
            k = idx\
          end\
        end\
        if copy and not skip_item then\
          copy[k] = transformed_item\
          k = k + 1\
        end\
      end\
      return copy or value, state\
    end\
  }\
  _base_0.__index = _base_0\
  setmetatable(_base_0, _parent_0.__base)\
  _class_0 = setmetatable({\
    __init = function(self, expected, opts)\
      self.expected, self.opts = expected, opts\
      if self.opts then\
        self.keep_nils = self.opts.keep_nils\
        self.length_type = self.opts.length\
      end\
      return _class_0.__parent.__init(self)\
    end,\
    __base = _base_0,\
    __name = \"ArrayOf\",\
    __parent = _parent_0\
  }, {\
    __index = function(cls, name)\
      local val = rawget(_base_0, name)\
      if val == nil then\
        local parent = rawget(cls, \"__parent\")\
        if parent then\
          return parent[name]\
        end\
      else\
        return val\
      end\
    end,\
    __call = function(cls, ...)\
      local _self_0 = setmetatable({}, _base_0)\
      cls.__init(_self_0, ...)\
      return _self_0\
    end\
  })\
  _base_0.__class = _class_0\
  local self = _class_0\
  self.type_err_message = \"expecting table\"\
  if _parent_0.__inherited then\
    _parent_0.__inherited(_parent_0, _class_0)\
  end\
  ArrayOf = _class_0\
end\
local MapOf\
do\
  local _class_0\
  local _parent_0 = BaseType\
  local _base_0 = {\
    _transform = function(self, value, state)\
      local pass, err = types.table(value)\
      if not (pass) then\
        return FailedTransform, err\
      end\
      local key_literal = not BaseType:is_base_type(self.expected_key)\
      local value_literal = not BaseType:is_base_type(self.expected_value)\
      local transformed = false\
      local out = { }\
      for k, v in pairs(value) do\
        local _continue_0 = false\
        repeat\
          local new_k = k\
          local new_v = v\
          if key_literal then\
            if k ~= self.expected_key then\
              return FailedTransform, \"map key expected \" .. tostring(describe_literal(self.expected_key))\
            end\
          else\
            new_k, state = self.expected_key:_transform(k, state)\
            if new_k == FailedTransform then\
              return FailedTransform, \"map key \" .. tostring(state)\
            end\
          end\
          if value_literal then\
            if v ~= self.expected_value then\
              return FailedTransform, \"map value expected \" .. tostring(describe_literal(self.expected_value))\
            end\
          else\
            new_v, state = self.expected_value:_transform(v, state)\
            if new_v == FailedTransform then\
              return FailedTransform, \"map value \" .. tostring(state)\
            end\
          end\
          if new_k ~= k or new_v ~= v then\
            transformed = true\
          end\
          if new_k == nil then\
            _continue_0 = true\
            break\
          end\
          out[new_k] = new_v\
          _continue_0 = true\
        until true\
        if not _continue_0 then\
          break\
        end\
      end\
      return transformed and out or value, state\
    end\
  }\
  _base_0.__index = _base_0\
  setmetatable(_base_0, _parent_0.__base)\
  _class_0 = setmetatable({\
    __init = function(self, expected_key, expected_value, opts)\
      self.expected_key, self.expected_value, self.opts = expected_key, expected_value, opts\
      return _class_0.__parent.__init(self)\
    end,\
    __base = _base_0,\
    __name = \"MapOf\",\
    __parent = _parent_0\
  }, {\
    __index = function(cls, name)\
      local val = rawget(_base_0, name)\
      if val == nil then\
        local parent = rawget(cls, \"__parent\")\
        if parent then\
          return parent[name]\
        end\
      else\
        return val\
      end\
    end,\
    __call = function(cls, ...)\
      local _self_0 = setmetatable({}, _base_0)\
      cls.__init(_self_0, ...)\
      return _self_0\
    end\
  })\
  _base_0.__class = _class_0\
  if _parent_0.__inherited then\
    _parent_0.__inherited(_parent_0, _class_0)\
  end\
  MapOf = _class_0\
end\
local Shape\
do\
  local _class_0\
  local _parent_0 = BaseType\
  local _base_0 = {\
    is_open = function(self)\
      return Shape(self.shape, self:clone_opts({\
        open = true\
      }))\
    end,\
    _describe = function(self)\
      local parts\
      do\
        local _accum_0 = { }\
        local _len_0 = 1\
        for k, v in pairs(self.shape) do\
          _accum_0[_len_0] = tostring(describe_literal(k)) .. \" = \" .. tostring(describe_literal(v))\
          _len_0 = _len_0 + 1\
        end\
        parts = _accum_0\
      end\
      return \"{ \" .. tostring(table.concat(parts, \", \")) .. \" }\"\
    end,\
    _transform = function(self, value, state)\
      local pass, err = types.table(value)\
      if not (pass) then\
        return FailedTransform, err\
      end\
      local check_all = self.check_all\
      local remaining_keys\
      do\
        local _tbl_0 = { }\
        for key in pairs(value) do\
          _tbl_0[key] = true\
        end\
        remaining_keys = _tbl_0\
      end\
      local errors\
      local dirty = false\
      local out = { }\
      for shape_key, shape_val in pairs(self.shape) do\
        local item_value = value[shape_key]\
        if remaining_keys then\
          remaining_keys[shape_key] = nil\
        end\
        local new_val\
        if BaseType:is_base_type(shape_val) then\
          new_val, state = shape_val:_transform(item_value, state)\
        else\
          if shape_val == item_value then\
            new_val, state = item_value, state\
          else\
            new_val, state = FailedTransform, \"expected \" .. tostring(describe_literal(shape_val))\
          end\
        end\
        if new_val == FailedTransform then\
          err = \"field \" .. tostring(describe_literal(shape_key)) .. \": \" .. tostring(state)\
          if check_all then\
            if errors then\
              table.insert(errors, err)\
            else\
              errors = {\
                err\
              }\
            end\
          else\
            return FailedTransform, err\
          end\
        else\
          if new_val ~= item_value then\
            dirty = true\
          end\
          out[shape_key] = new_val\
        end\
      end\
      if remaining_keys and next(remaining_keys) then\
        if self.open then\
          for k in pairs(remaining_keys) do\
            out[k] = value[k]\
          end\
        elseif self.extra_fields_type then\
          for k in pairs(remaining_keys) do\
            local item_value = value[k]\
            local tuple\
            tuple, state = self.extra_fields_type:_transform({\
              [k] = item_value\
            }, state)\
            if tuple == FailedTransform then\
              err = \"field \" .. tostring(describe_literal(k)) .. \": \" .. tostring(state)\
              if check_all then\
                if errors then\
                  table.insert(errors, err)\
                else\
                  errors = {\
                    err\
                  }\
                end\
              else\
                return FailedTransform, err\
              end\
            else\
              do\
                local nk = tuple and next(tuple)\
                if nk then\
                  if nk ~= k then\
                    dirty = true\
                  elseif tuple[nk] ~= item_value then\
                    dirty = true\
                  end\
                  out[nk] = tuple[nk]\
                else\
                  dirty = true\
                end\
              end\
            end\
          end\
        else\
          local names\
          do\
            local _accum_0 = { }\
            local _len_0 = 1\
            for key in pairs(remaining_keys) do\
              _accum_0[_len_0] = describe_literal(key)\
              _len_0 = _len_0 + 1\
            end\
            names = _accum_0\
          end\
          err = \"extra fields: \" .. tostring(table.concat(names, \", \"))\
          if check_all then\
            if errors then\
              table.insert(errors, err)\
            else\
              errors = {\
                err\
              }\
            end\
          else\
            return FailedTransform, err\
          end\
        end\
      end\
      if errors and next(errors) then\
        return FailedTransform, table.concat(errors, \"; \")\
      end\
      return dirty and out or value, state\
    end\
  }\
  _base_0.__index = _base_0\
  setmetatable(_base_0, _parent_0.__base)\
  _class_0 = setmetatable({\
    __init = function(self, shape, opts)\
      self.shape, self.opts = shape, opts\
      _class_0.__parent.__init(self)\
      assert(type(self.shape) == \"table\", \"expected table for shape\")\
      if self.opts then\
        self.extra_fields_type = self.opts.extra_fields\
        self.open = self.opts.open\
        self.check_all = self.opts.check_all\
        if self.open then\
          assert(not self.extra_fields_type, \"open can not be combined with extra_fields\")\
        end\
        if self.extra_fields_type then\
          return assert(not self.open, \"extra_fields can not be combined with open\")\
        end\
      end\
    end,\
    __base = _base_0,\
    __name = \"Shape\",\
    __parent = _parent_0\
  }, {\
    __index = function(cls, name)\
      local val = rawget(_base_0, name)\
      if val == nil then\
        local parent = rawget(cls, \"__parent\")\
        if parent then\
          return parent[name]\
        end\
      else\
        return val\
      end\
    end,\
    __call = function(cls, ...)\
      local _self_0 = setmetatable({}, _base_0)\
      cls.__init(_self_0, ...)\
      return _self_0\
    end\
  })\
  _base_0.__class = _class_0\
  local self = _class_0\
  self.type_err_message = \"expecting table\"\
  if _parent_0.__inherited then\
    _parent_0.__inherited(_parent_0, _class_0)\
  end\
  Shape = _class_0\
end\
local Pattern\
do\
  local _class_0\
  local _parent_0 = BaseType\
  local _base_0 = {\
    _describe = function(self)\
      return \"pattern \" .. tostring(describe_literal(self.pattern))\
    end,\
    _transform = function(self, value, state)\
      do\
        local initial = self.opts and self.opts.initial_type\
        if initial then\
          if not (type(value) == initial) then\
            return FailedTransform, \"expected \" .. tostring(describe_literal(initial))\
          end\
        end\
      end\
      if self.opts and self.opts.coerce then\
        value = tostring(value)\
      end\
      local t_res, err = types.string(value)\
      if not (t_res) then\
        return FailedTransform, err\
      end\
      if value:match(self.pattern) then\
        return value, state\
      else\
        return FailedTransform, \"doesn't match \" .. tostring(self:_describe())\
      end\
    end\
  }\
  _base_0.__index = _base_0\
  setmetatable(_base_0, _parent_0.__base)\
  _class_0 = setmetatable({\
    __init = function(self, pattern, opts)\
      self.pattern, self.opts = pattern, opts\
      return _class_0.__parent.__init(self)\
    end,\
    __base = _base_0,\
    __name = \"Pattern\",\
    __parent = _parent_0\
  }, {\
    __index = function(cls, name)\
      local val = rawget(_base_0, name)\
      if val == nil then\
        local parent = rawget(cls, \"__parent\")\
        if parent then\
          return parent[name]\
        end\
      else\
        return val\
      end\
    end,\
    __call = function(cls, ...)\
      local _self_0 = setmetatable({}, _base_0)\
      cls.__init(_self_0, ...)\
      return _self_0\
    end\
  })\
  _base_0.__class = _class_0\
  if _parent_0.__inherited then\
    _parent_0.__inherited(_parent_0, _class_0)\
  end\
  Pattern = _class_0\
end\
local Literal\
do\
  local _class_0\
  local _parent_0 = BaseType\
  local _base_0 = {\
    _describe = function(self)\
      return describe_literal(self.value)\
    end,\
    _transform = function(self, value, state)\
      if self.value ~= value then\
        return FailedTransform, \"expected \" .. tostring(self:_describe())\
      end\
      return value, state\
    end\
  }\
  _base_0.__index = _base_0\
  setmetatable(_base_0, _parent_0.__base)\
  _class_0 = setmetatable({\
    __init = function(self, value, opts)\
      self.value, self.opts = value, opts\
      return _class_0.__parent.__init(self)\
    end,\
    __base = _base_0,\
    __name = \"Literal\",\
    __parent = _parent_0\
  }, {\
    __index = function(cls, name)\
      local val = rawget(_base_0, name)\
      if val == nil then\
        local parent = rawget(cls, \"__parent\")\
        if parent then\
          return parent[name]\
        end\
      else\
        return val\
      end\
    end,\
    __call = function(cls, ...)\
      local _self_0 = setmetatable({}, _base_0)\
      cls.__init(_self_0, ...)\
      return _self_0\
    end\
  })\
  _base_0.__class = _class_0\
  if _parent_0.__inherited then\
    _parent_0.__inherited(_parent_0, _class_0)\
  end\
  Literal = _class_0\
end\
local Custom\
do\
  local _class_0\
  local _parent_0 = BaseType\
  local _base_0 = {\
    _describe = function(self)\
      return self.opts and self.opts.describe or \"custom checker \" .. tostring(self.fn)\
    end,\
    _transform = function(self, value, state)\
      local pass, err = self.fn(value, state)\
      if not (pass) then\
        return FailedTransform, err or \"failed custom check\"\
      end\
      return value, state\
    end\
  }\
  _base_0.__index = _base_0\
  setmetatable(_base_0, _parent_0.__base)\
  _class_0 = setmetatable({\
    __init = function(self, fn, opts)\
      self.fn, self.opts = fn, opts\
      return _class_0.__parent.__init(self)\
    end,\
    __base = _base_0,\
    __name = \"Custom\",\
    __parent = _parent_0\
  }, {\
    __index = function(cls, name)\
      local val = rawget(_base_0, name)\
      if val == nil then\
        local parent = rawget(cls, \"__parent\")\
        if parent then\
          return parent[name]\
        end\
      else\
        return val\
      end\
    end,\
    __call = function(cls, ...)\
      local _self_0 = setmetatable({}, _base_0)\
      cls.__init(_self_0, ...)\
      return _self_0\
    end\
  })\
  _base_0.__class = _class_0\
  if _parent_0.__inherited then\
    _parent_0.__inherited(_parent_0, _class_0)\
  end\
  Custom = _class_0\
end\
local Equivalent\
do\
  local _class_0\
  local values_equivalent\
  local _parent_0 = BaseType\
  local _base_0 = {\
    _transform = function(self, value, state)\
      if values_equivalent(self.val, value) then\
        return value, state\
      else\
        return FailedTransform, \"not equivalent to \" .. tostring(self.val)\
      end\
    end\
  }\
  _base_0.__index = _base_0\
  setmetatable(_base_0, _parent_0.__base)\
  _class_0 = setmetatable({\
    __init = function(self, val, opts)\
      self.val, self.opts = val, opts\
      return _class_0.__parent.__init(self)\
    end,\
    __base = _base_0,\
    __name = \"Equivalent\",\
    __parent = _parent_0\
  }, {\
    __index = function(cls, name)\
      local val = rawget(_base_0, name)\
      if val == nil then\
        local parent = rawget(cls, \"__parent\")\
        if parent then\
          return parent[name]\
        end\
      else\
        return val\
      end\
    end,\
    __call = function(cls, ...)\
      local _self_0 = setmetatable({}, _base_0)\
      cls.__init(_self_0, ...)\
      return _self_0\
    end\
  })\
  _base_0.__class = _class_0\
  local self = _class_0\
  values_equivalent = function(a, b)\
    if a == b then\
      return true\
    end\
    if type(a) == \"table\" and type(b) == \"table\" then\
      local seen_keys = { }\
      for k, v in pairs(a) do\
        seen_keys[k] = true\
        if not (values_equivalent(v, b[k])) then\
          return false\
        end\
      end\
      for k, v in pairs(b) do\
        local _continue_0 = false\
        repeat\
          if seen_keys[k] then\
            _continue_0 = true\
            break\
          end\
          if not (values_equivalent(v, a[k])) then\
            return false\
          end\
          _continue_0 = true\
        until true\
        if not _continue_0 then\
          break\
        end\
      end\
      return true\
    else\
      return false\
    end\
  end\
  if _parent_0.__inherited then\
    _parent_0.__inherited(_parent_0, _class_0)\
  end\
  Equivalent = _class_0\
end\
local Range\
do\
  local _class_0\
  local _parent_0 = BaseType\
  local _base_0 = {\
    _transform = function(self, value, state)\
      local res\
      res, state = self.value_type:_transform(value, state)\
      if res == FailedTransform then\
        return FailedTransform, \"range \" .. tostring(state)\
      end\
      if value < self.left then\
        return FailedTransform, \"not in \" .. tostring(self:_describe())\
      end\
      if value > self.right then\
        return FailedTransform, \"not in \" .. tostring(self:_describe())\
      end\
      return value, state\
    end,\
    _describe = function(self)\
      return \"range from \" .. tostring(self.left) .. \" to \" .. tostring(self.right)\
    end\
  }\
  _base_0.__index = _base_0\
  setmetatable(_base_0, _parent_0.__base)\
  _class_0 = setmetatable({\
    __init = function(self, left, right, opts)\
      self.left, self.right, self.opts = left, right, opts\
      _class_0.__parent.__init(self)\
      assert(self.left <= self.right, \"left range value should be less than right range value\")\
      self.value_type = assert(types[type(self.left)], \"couldn't figure out type of range boundary\")\
    end,\
    __base = _base_0,\
    __name = \"Range\",\
    __parent = _parent_0\
  }, {\
    __index = function(cls, name)\
      local val = rawget(_base_0, name)\
      if val == nil then\
        local parent = rawget(cls, \"__parent\")\
        if parent then\
          return parent[name]\
        end\
      else\
        return val\
      end\
    end,\
    __call = function(cls, ...)\
      local _self_0 = setmetatable({}, _base_0)\
      cls.__init(_self_0, ...)\
      return _self_0\
    end\
  })\
  _base_0.__class = _class_0\
  if _parent_0.__inherited then\
    _parent_0.__inherited(_parent_0, _class_0)\
  end\
  Range = _class_0\
end\
local Proxy\
do\
  local _class_0\
  local _parent_0 = BaseType\
  local _base_0 = {\
    _transform = function(self, ...)\
      return assert(self.fn(), \"proxy missing transformer\"):_transform(...)\
    end,\
    _describe = function(self, ...)\
      return assert(self.fn(), \"proxy missing transformer\"):_describe(...)\
    end\
  }\
  _base_0.__index = _base_0\
  setmetatable(_base_0, _parent_0.__base)\
  _class_0 = setmetatable({\
    __init = function(self, fn, opts)\
      self.fn, self.opts = fn, opts\
    end,\
    __base = _base_0,\
    __name = \"Proxy\",\
    __parent = _parent_0\
  }, {\
    __index = function(cls, name)\
      local val = rawget(_base_0, name)\
      if val == nil then\
        local parent = rawget(cls, \"__parent\")\
        if parent then\
          return parent[name]\
        end\
      else\
        return val\
      end\
    end,\
    __call = function(cls, ...)\
      local _self_0 = setmetatable({}, _base_0)\
      cls.__init(_self_0, ...)\
      return _self_0\
    end\
  })\
  _base_0.__class = _class_0\
  if _parent_0.__inherited then\
    _parent_0.__inherited(_parent_0, _class_0)\
  end\
  Proxy = _class_0\
end\
types = setmetatable({\
  any = AnyType(),\
  string = Type(\"string\"),\
  number = Type(\"number\"),\
  [\"function\"] = Type(\"function\"),\
  func = Type(\"function\"),\
  boolean = Type(\"boolean\"),\
  userdata = Type(\"userdata\"),\
  [\"nil\"] = Type(\"nil\"),\
  table = Type(\"table\"),\
  array = ArrayType(),\
  integer = Pattern(\"^%d+$\", {\
    coerce = true,\
    initial_type = \"number\"\
  }),\
  one_of = OneOf,\
  all_of = AllOf,\
  shape = Shape,\
  pattern = Pattern,\
  array_of = ArrayOf,\
  map_of = MapOf,\
  literal = Literal,\
  range = Range,\
  equivalent = Equivalent,\
  custom = Custom,\
  scope = TagScopeType,\
  proxy = Proxy\
}, {\
  __index = function(self, fn_name)\
    return error(\"Type checker does not exist: `\" .. tostring(fn_name) .. \"`\")\
  end\
})\
local check_shape\
check_shape = function(value, shape)\
  assert(shape.check_value, \"missing check_value method from shape\")\
  return shape:check_value(value)\
end\
local is_type\
is_type = function(val)\
  return BaseType:is_base_type(val)\
end\
local type_switch\
type_switch = function(val)\
  return setmetatable({\
    val\
  }, {\
    __eq = BaseType.__eq\
  })\
end\
do\
  local _with_0 = exports\
  _with_0.check_shape = check_shape\
  _with_0.types = types\
  _with_0.is_type = is_type\
  _with_0.type_switch = type_switch\
  _with_0.BaseType = BaseType\
  _with_0.FailedTransform = FailedTransform\
  _with_0.VERSION = \"2.0.0\"\
  return _with_0\
end",
['luapower/color/exports'] = "--color parsing, formatting and computation.\
--Written by Cosmin Apreutesei. Public Domain.\
--HSL-RGB conversions from Sputnik by Yuri Takhteyev (MIT/X License).\
\
local function clamp01(x)\
\9return math.min(math.max(x, 0), 1)\
end\
\
local function round(x)\
\9return math.floor(x + 0.5)\
end\
\
--clamping -------------------------------------------------------------------\
\
local clamps = {} --{space -> func(x, y, z, a)}\
\
local function clamp_hsx(h, s, x, a)\
\9return h % 360, clamp01(s), clamp01(x)\
end\
clamps.hsl = clamp_hsx\
clamps.hsv = clamp_hsx\
\
function clamps.rgb(r, g, b)\
\9return clamp01(r), clamp01(g), clamp01(b)\
end\
\
local function clamp(space, x, y, z, a)\
\9x, y, z = clamps[space](x, y, z)\
\9if a then return x, y, z, clamp01(a) end\
\9return x, y, z\
end\
\
--conversion -----------------------------------------------------------------\
\
--HSL <-> RGB\
\
--hsl is in (0..360, 0..1, 0..1); rgb is (0..1, 0..1, 0..1)\
local function h2rgb(m1, m2, h)\
\9if h<0 then h = h+1 end\
\9if h>1 then h = h-1 end\
\9if h*6<1 then\
\9\9return m1+(m2-m1)*h*6\
\9elseif h*2<1 then\
\9\9return m2\
\9elseif h*3<2 then\
\9\9return m1+(m2-m1)*(2/3-h)*6\
\9else\
\9\9return m1\
\9end\
end\
local function hsl_to_rgb(h, s, L)\
\9h = h / 360\
\9local m2 = L <= .5 and L*(s+1) or L+s-L*s\
\9local m1 = L*2-m2\
\9return\
\9\9h2rgb(m1, m2, h+1/3),\
\9\9h2rgb(m1, m2, h),\
\9\9h2rgb(m1, m2, h-1/3)\
end\
\
--rgb is in (0..1, 0..1, 0..1); hsl is (0..360, 0..1, 0..1)\
local function rgb_to_hsl(r, g, b)\
\9local min = math.min(r, g, b)\
\9local max = math.max(r, g, b)\
\9local delta = max - min\
\
\9local h, s, l = 0, 0, (min + max) / 2\
\
\9if l > 0 and l < 0.5 then s = delta / (max + min) end\
\9if l >= 0.5 and l < 1 then s = delta / (2 - max - min) end\
\
\9if delta > 0 then\
\9\9if max == r and max ~= g then h = h + (g-b) / delta end\
\9\9if max == g and max ~= b then h = h + 2 + (b-r) / delta end\
\9\9if max == b and max ~= r then h = h + 4 + (r-g) / delta end\
\9\9h = h / 6\
\9end\
\
\9if h < 0 then h = h + 1 end\
\9if h > 1 then h = h - 1 end\
\
\9return h * 360, s, l\
end\
\
--HSV <-> RGB\
\
local function rgb_to_hsv(r, g, b)\
\9local K = 0\
\9if g < b then\
\9\9g, b = b, g\
\9\9K = -1\
\9end\
\9if r < g then\
\9\9r, g = g, r\
\9\9K = -2 / 6 - K\
\9end\
\9local chroma = r - math.min(g, b)\
\9local h = math.abs(K + (g - b) / (6 * chroma + 1e-20))\
\9local s = chroma / (r + 1e-20)\
\9local v = r\
\9return h * 360, s, v\
end\
\
local function hsv_to_rgb(h, s, v)\
\9if s == 0 then --gray\
\9\9return v, v, v\
\9end\
\9local H = h / 60\
\9local i = math.floor(H) --which 1/6 part of hue circle\
\9local f = H - i\
\9local p = v * (1 - s)\
\9local q = v * (1 - s * f)\
\9local t = v * (1 - s * (1 - f))\
\9if i == 0 then\
\9\9return v, t, p\
\9elseif i == 1 then\
\9\9return q, v, p\
\9elseif i == 2 then\
\9\9return p, v, t\
\9elseif i == 3 then\
\9\9return p, q, v\
\9elseif i == 4 then\
\9\9return t, p, v\
\9else\
\9\9return v, p, q\
\9end\
end\
\
function hsv_to_hsl(h, s, v) --TODO: direct conversion\
\9return rgb_to_hsl(hsv_to_rgb(h, s, v))\
end\
\
function hsl_to_hsv(h, s, l) --TODO: direct conversion\
\9return rgb_to_hsv(hsl_to_rgb(h, s, l))\
end\
\
local converters = {\
\9rgb = {hsl = rgb_to_hsl, hsv = rgb_to_hsv},\
\9hsl = {rgb = hsl_to_rgb, hsv = hsl_to_hsv},\
\9hsv = {rgb = hsv_to_rgb, hsl = hsv_to_hsl},\
}\
local function convert(dest_space, space, x, y, z, ...)\
\9if space ~= dest_space then\
\9\9x, y, z = converters[space][dest_space](x, y, z)\
\9end\
\9return x, y, z, ...\
end\
\
--parsing --------------------------------------------------------------------\
\
local hex = {\
\9[4] = {'#rgb',      'rgb'},\
\9[5] = {'#rgba',     'rgb'},\
\9[7] = {'#rrggbb',   'rgb'},\
\9[9] = {'#rrggbbaa', 'rgb'},\
}\
local s3 = {\
\9hsl = {'hsl', 'hsl'},\
\9hsv = {'hsv', 'hsv'},\
\9rgb = {'rgb', 'rgb'},\
}\
local s4 = {\
\9hsla = {'hsla', 'hsl'},\
\9hsva = {'hsva', 'hsv'},\
\9rgba = {'rgba', 'rgb'},\
}\
local function string_format(s)\
\9local t\
\9if s:sub(1, 1) == '#' then\
\9\9t = hex[#s]\
\9else\
\9\9t = s4[s:sub(1, 4)] or s3[s:sub(1, 3)]\
\9end\
\9if t then\
\9\9return t[1], t[2] --format, colorspace\
\9end\
end\
\
local parsers = {}\
\
local function parse(s)\
\9local r = tonumber(s:sub(2, 2), 16)\
\9local g = tonumber(s:sub(3, 3), 16)\
\9local b = tonumber(s:sub(4, 4), 16)\
\9if not (r and g and b) then return end\
\9r = (r * 16 + r) / 255\
\9g = (g * 16 + g) / 255\
\9b = (b * 16 + b) / 255\
\9if #s == 5 then\
\9\9local a = tonumber(s:sub(5, 5), 16)\
\9\9if not a then return end\
\9\9return r, g, b, (a * 16 + a) / 255\
\9else\
\9\9return r, g, b\
\9end\
end\
parsers['#rgb']  = parse\
parsers['#rgba'] = parse\
\
local function parse(s)\
\9local r = tonumber(s:sub(2, 3), 16)\
\9local g = tonumber(s:sub(4, 5), 16)\
\9local b = tonumber(s:sub(6, 7), 16)\
\9if not (r and g and b) then return end\
\9r = r / 255\
\9g = g / 255\
\9b = b / 255\
\9if #s == 9 then\
\9\9local a = tonumber(s:sub(8, 9), 16)\
\9\9if not a then return end\
\9\9return r, g, b, a / 255\
\9else\
\9\9return r, g, b\
\9end\
end\
parsers['#rrggbb']  = parse\
parsers['#rrggbbaa'] = parse\
\
local rgb_patt = '^rgb%s*%(([^,]+),([^,]+),([^,]+)%)$'\
local rgba_patt = '^rgba%s*%(([^,]+),([^,]+),([^,]+),([^,]+)%)$'\
\
local function parse(s)\
\9local r, g, b, a = s:match(rgba_patt)\
\9r = tonumber(r)\
\9g = tonumber(g)\
\9b = tonumber(b)\
\9a = tonumber(a)\
\9if not (r and g and b and a) then return end\
\9return\
\9\9r / 255,\
\9\9g / 255,\
\9\9b / 255,\
\9\9a\
end\
parsers.rgba = parse\
\
local function parse(s)\
\9local r, g, b = s:match(rgb_patt)\
\9r = tonumber(r)\
\9g = tonumber(g)\
\9b = tonumber(b)\
\9if not (r and g and b) then return end\
\9return\
\9\9r / 255,\
\9\9g / 255,\
\9\9b / 255\
end\
parsers.rgb = parse\
\
local hsl_patt = '^hsl%s*%(([^,]+),([^,]+),([^,]+)%)$'\
local hsla_patt = '^hsla%s*%(([^,]+),([^,]+),([^,]+),([^,]+)%)$'\
\
local hsv_patt = hsl_patt:gsub('hsl', 'hsv')\
local hsva_patt = hsla_patt:gsub('hsla', 'hsva')\
\
local function np(s)\
\9local p = s and tonumber((s:match'^([^%%]+)%%%s*$'))\
\9return p and p * .01 or tonumber(s)\
end\
\
local function parser(patt)\
\9return function(s)\
\9\9local h, s, x, a = s:match(patt)\
\9\9h = tonumber(h)\
\9\9s = np(s)\
\9\9x = np(x)\
\9\9a = tonumber(a)\
\9\9if not (h and s and x and a) then return end\
\9\9return h, s, x, a\
\9end\
end\
parsers.hsla = parser(hsla_patt)\
parsers.hsva = parser(hsva_patt)\
\
local function parser(patt)\
\9return function(s)\
\9\9local h, s, x = s:match(patt)\
\9\9h = tonumber(h)\
\9\9s = np(s)\
\9\9x = np(x)\
\9\9if not (h and s and x) then return end\
\9\9return h, s, x\
\9end\
end\
parsers.hsl = parser(hsl_patt)\
parsers.hsv = parser(hsv_patt)\
\
local function parse(s, dest_space)\
\9local fmt, space = string_format(s)\
\9if not fmt then return end\
\9local parse = parsers[fmt]\
\9if not parse then return end\
\9if dest_space then\
\9\9return convert(dest_space, space, parse(s))\
\9else\
\9\9return space, parse(s)\
\9end\
end\
\
--formatting -----------------------------------------------------------------\
\
local format_spaces = {\
\9['#'] = 'rgb',\
\9['#rrggbbaa'] = 'rgb', ['#rrggbb'] = 'rgb',\
\9['#rgba'] = 'rgb', ['#rgb'] = 'rgb', rgba = 'rgb', rgb = 'rgb',\
\9hsla = 'hsl', hsl = 'hsl', ['hsla%'] = 'hsl', ['hsl%'] = 'hsl',\
\9hsva = 'hsv', hsv = 'hsv', ['hsva%'] = 'hsv', ['hsv%'] = 'hsv',\
}\
\
local function loss(x) --...of precision when converting to #rgb\
\9return math.abs(x * 15 - round(x * 15))\
end\
local threshold = math.abs(loss(0x89 / 255))\
local function short(x)\
\9return loss(x) < threshold\
end\
\
local function format(fmt, space, x, y, z, a)\
\9fmt = fmt or space --the names match\
\9local dest_space = format_spaces[fmt]\
\9if not dest_space then\
\9\9error('invalid format '..tostring(fmt))\
\9end\
\9x, y, z, a = convert(dest_space, space, x, y, z, a)\
\9if fmt == '#' then --shortest hex\
\9\9if short(x) and short(y) and short(z) and short(a or 1) then\
\9\9\9fmt = a and '#rgba' or '#rgb'\
\9\9else\
\9\9\9fmt = a and '#rrggbbaa' or '#rrggbb'\
\9\9end\
\9end\
\9a = a or 1\
\9if fmt == '#rrggbbaa' or fmt == '#rrggbb' then\
\9\9return string.format(\
\9\9\9fmt == '#rrggbbaa' and '#%02x%02x%02x%02x' or '#%02x%02x%02x',\
\9\9\9\9round(x * 255),\
\9\9\9\9round(y * 255),\
\9\9\9\9round(z * 255),\
\9\9\9\9round(a * 255))\
\9elseif fmt == '#rgba' or fmt == '#rgb' then\
\9\9return string.format(\
\9\9\9fmt == '#rgba' and '#%1x%1x%1x%1x' or '#%1x%1x%1x',\
\9\9\9\9round(x * 15),\
\9\9\9\9round(y * 15),\
\9\9\9\9round(z * 15),\
\9\9\9\9round(a * 15))\
\9elseif fmt == 'rgba' or fmt == 'rgb' then\
\9\9return string.format(\
\9\9\9fmt == 'rgba' and 'rgba(%d,%d,%d,%.2g)' or 'rgb(%d,%d,%g)',\
\9\9\9\9round(x * 255),\
\9\9\9\9round(y * 255),\
\9\9\9\9round(z * 255),\
\9\9\9\9a)\
\9elseif fmt:sub(-1) == '%' then --hsl|v(a)%\
\9\9return string.format(\
\9\9\9#fmt == 5 and '%s(%d,%d%%,%d%%,%.2g)' or '%s(%d,%d%%,%d%%)',\
\9\9\9\9fmt:sub(1, -2),\
\9\9\9\9round(x),\
\9\9\9\9round(y * 100),\
\9\9\9\9round(z * 100),\
\9\9\9\9a)\
\9else --hsl|v(a)\
\9\9return string.format(\
\9\9\9#fmt == 4 and '%s(%d,%.2g,%.2g,%.2g)' or '%s(%d,%.2g,%.2g)',\
\9\9\9\9fmt, round(x), y, z, a)\
\9end\
end\
\
--color object ---------------------------------------------------------------\
\
local color = {}\
\
--new([space, ]x, y, z[, a])\
--new([space, ]'str')\
--new([space, ]{x, y, z[, a]})\
local function new(space, x, y, z, a)\
\9if not (type(space) == 'string' and x) then --shift args\
\9\9space, x, y, z, a = 'hsl', space, x, y, z\
\9end\
\9local h, s, L\
\9if type(x) == 'string' then\
\9\9h, s, L, a = parse(x, 'hsl')\
\9else\
\9\9if type(x) == 'table' then\
\9\9\9x, y, z, a = x[1], x[2], x[3], x[4]\
\9\9end\
\9\9h, s, L, a = convert('hsl', space, clamp(space, x, y, z, a))\
\9end\
\9local c = {\
\9\9h = h, s = s, L = L, a = a,\
\9\9__index = color,\
\9\9__tostring = color.__tostring,\
\9\9__call = color.__call,\
\9}\
\9return setmetatable(c, c)\
end\
\
local function new_with(space)\
\9return function(...)\
\9\9return new(space, ...)\
\9end\
end\
\
function color:__call() return self.h, self.s, self.L, self.a end\
function color:hsl() return self.h, self.s, self.L end\
function color:hsla() return self.h, self.s, self.L, self.a or 1 end\
function color:hsv() return convert('hsv', 'hsl', self:hsl()) end\
function color:hsva() return convert('hsv', 'hsl', self:hsla()) end\
function color:rgb() return convert('rgb', 'hsl', self:hsl()) end\
function color:rgba() return convert('rgb', 'hsl', self:hsla()) end\
function color:convert(space) return convert(space, 'hsl', self:hsla()) end\
function color:format(fmt) return format(fmt, 'hsl', self()) end\
\
function color:__tostring()\
\9return self:format'#'\
end\
\
function color:hue_offset(delta)\
\9return new(self.h + delta, self.s, self.L)\
end\
\
function color:complementary()\
\9return self:hue_offset(180)\
end\
\
function color:neighbors(angle)\
\9local angle = angle or 30\
\9return self:hue_offset(angle), self:hue_offset(360-angle)\
end\
\
function color:triadic()\
\9return self:neighbors(120)\
end\
\
function color:split_complementary(angle)\
\9return self:neighbors(180-(angle or 30))\
end\
\
function color:desaturate_to(saturation)\
\9return new(self.h, saturation, self.L)\
end\
\
function color:desaturate_by(r)\
\9return new(self.h, self.s*r, self.L)\
end\
\
function color:lighten_to(lightness)\
\9return new(self.h, self.s, lightness)\
end\
\
function color:lighten_by(r)\
\9return new(self.h, self.s, self.L*r)\
end\
\
function color:bw(whiteL)\
\9return new(self.h, self.s, self.L >= (whiteL or .5) and 0 or 1)\
end\
\
function color:variations(f, n)\
\9n = n or 5\
\9local results = {}\
\9for i=1,n do\
\9  table.insert(results, f(self, i, n))\
\9end\
\9return results\
end\
\
function color:tints(n)\
\9return self:variations(function(color, i, n)\
\9\9return color:lighten_to(color.L + (1-color.L)/n*i)\
\9end, n)\
end\
\
function color:shades(n)\
\9return self:variations(function(color, i, n)\
\9\9return color:lighten_to(color.L - (color.L)/n*i)\
\9end, n)\
end\
\
function color:tint(r)\
\9return self:lighten_to(self.L + (1-self.L)*r)\
end\
\
function color:shade(r)\
\9return self:lighten_to(self.L - self.L*r)\
end\
\
--module ---------------------------------------------------------------------\
\
exports.clamp = clamp\
exports.convert = convert\
exports.parse = parse\
exports.format = format\
exports.hsl = new_with 'hsl'\
exports.hsv = new_with 'hsv'\
exports.rgb = new_with 'rgb'\
exports.new = new",
['novacbn/lunarbook-plugin-builtin/exports'] = "local getmetatable, pairs\
do\
  local _obj_0 = _G\
  getmetatable, pairs = _obj_0.getmetatable, _obj_0.pairs\
end\
local PluginConfig, setConfig\
do\
  local _obj_0 = dependency(\"novacbn/lunarbook-plugin-builtin/schemas/PluginConfig\")\
  PluginConfig, setConfig = _obj_0.PluginConfig, _obj_0.setConfig\
end\
local ENVIRONMENT_LAYOUT = {\
  dependency(\"novacbn/lunarbook-plugin-builtin/layoutenv/global\"),\
  dependency(\"novacbn/lunarbook-plugin-builtin/layoutenv/string\")\
}\
local ENVIRONMENT_STYLE = {\
  dependency(\"novacbn/lunarbook-plugin-builtin/styleenv/color\"),\
  dependency(\"novacbn/lunarbook-plugin-builtin/layoutenv/global\")\
}\
local TRANSFORMERS_FRAGMENTS = {\
  dependency(\"novacbn/lunarbook-plugin-builtin/fragments/html\"),\
  dependency(\"novacbn/lunarbook-plugin-builtin/fragments/markdown\")\
}\
configureTransformers = function(transformers)\
  do\
    local _with_0 = transformers\
    for _index_0 = 1, #TRANSFORMERS_FRAGMENTS do\
      local transformer = TRANSFORMERS_FRAGMENTS[_index_0]\
      _with_0:registerFragment(transformer.extension, transformer.transform, transformer.post)\
    end\
    return _with_0\
  end\
end\
configureLayoutEnvironment = function(environment)\
  local extensions\
  do\
    local _accum_0 = { }\
    local _len_0 = 1\
    for _index_0 = 1, #ENVIRONMENT_LAYOUT do\
      local extension = ENVIRONMENT_LAYOUT[_index_0]\
      _accum_0[_len_0] = getmetatable(extension).__index\
      _len_0 = _len_0 + 1\
    end\
    extensions = _accum_0\
  end\
  for _index_0 = 1, #extensions do\
    local extension = extensions[_index_0]\
    for key, value in pairs(extension) do\
      environment:registerVariable(key, value)\
    end\
  end\
end\
configureStyleEnvironment = function(environment)\
  local extensions\
  do\
    local _accum_0 = { }\
    local _len_0 = 1\
    for _index_0 = 1, #ENVIRONMENT_STYLE do\
      local extension = ENVIRONMENT_STYLE[_index_0]\
      _accum_0[_len_0] = getmetatable(extension).__index\
      _len_0 = _len_0 + 1\
    end\
    extensions = _accum_0\
  end\
  for _index_0 = 1, #extensions do\
    local extension = extensions[_index_0]\
    for key, value in pairs(extension) do\
      environment:registerVariable(key, value)\
    end\
  end\
end\
processConfiguration = function(config)\
  if config == nil then\
    config = { }\
  end\
  local err\
  config, err = PluginConfig:transform(config)\
  if err then\
    return err\
  end\
  return setConfig(config)\
end",
['novacbn/lunarbook-plugin-builtin/fragments/html'] = "local getConfig\
getConfig = dependency(\"novacbn/lunarbook-plugin-builtin/schemas/PluginConfig\").getConfig\
extension = \".html\"\
transform = function(inDev, contents)\
  return contents\
end\
post = function(inDev, contents)\
  return contents\
end",
['novacbn/lunarbook-plugin-builtin/fragments/markdown'] = "local parse\
parse = dependency(\"sebcat/markdown/exports\").parse\
local html = dependency(\"novacbn/lunarbook-plugin-builtin/fragments/html\")\
extension = \".md\"\
transform = function(inDev, contents)\
  return parse(contents)\
end\
post = function(inDev, contents)\
  return html.post(inDev, contents)\
end",
['novacbn/lunarbook-plugin-builtin/layoutenv/global'] = "local GLOBAL_KEYS = {\
  \"assert\",\
  \"ipairs\",\
  \"pairs\",\
  \"print\",\
  \"select\",\
  \"tonumber\",\
  \"tostring\",\
  \"type\",\
  \"unpack\",\
  \"bit\",\
  \"math\",\
  \"string\",\
  \"table\"\
}\
for _index_0 = 1, #GLOBAL_KEYS do\
  local key = GLOBAL_KEYS[_index_0]\
  exports[key] = _G[key]\
end",
['novacbn/lunarbook-plugin-builtin/layoutenv/string'] = "local slugify\
slugify = dependency(\"novacbn/lunarbook-plugin-builtin/utilities/string\").slugify\
exports.slugify = slugify",
['novacbn/lunarbook-plugin-builtin/schemas/PluginConfig'] = "local types\
types = dependency(\"leafo/tableshape/exports\").types\
local USER_CONFIG = nil\
PluginConfig = types.shape({\
  minifyFragments = types.boolean + types[\"nil\"] / false\
})\
getConfig = function()\
  return USER_CONFIG\
end\
setConfig = function(config)\
  USER_CONFIG = config\
end",
['novacbn/lunarbook-plugin-builtin/styleenv/color'] = "local type\
type = _G.type\
local new\
new = dependency(\"luapower/color/exports\").new\
alpha = function(value, alpha)\
  if not (type(value) == \"string\" or type(value) == \"table\") then\
    error(\"bad argument #1 to 'alpha' (expected string)\")\
  end\
  if not (type(alpha) == \"number\") then\
    error(\"bad argument #2 to 'alpha' (expected number)\")\
  end\
  local r, g, b = new(value):rgb()\
  r, g, b = r * 255, g * 255, b * 255\
  local color = new(\"rgb\", r, g, b, alpha)\
  return color:format(\"#rrggbbaa\")\
end\
darken = function(value, delta)\
  if not (type(value) == \"string\" or type(value) == \"table\") then\
    error(\"bad argument #1 to 'darken' (expected string)\")\
  end\
  if not (type(delta) == \"number\") then\
    error(\"bad argument #2 to 'darken' (expected number)\")\
  end\
  local color = new(value)\
  return color:shade(delta):format(\"#rrggbb\")\
end\
desaturate = function(value, delta)\
  if not (type(value) == \"string\" or type(value) == \"table\") then\
    error(\"bad argument #1 to 'desaturate' (expected string)\")\
  end\
  if not (type(delta) == \"number\") then\
    error(\"bad argument #2 to 'desaturate' (expected number)\")\
  end\
  local color = new(value)\
  return color:desaturate_by(delta):format(\"#rrggbb\")\
end\
lighten = function(value, delta)\
  if not (type(value) == \"string\" or type(value) == \"table\") then\
    error(\"bad argument #1 to 'lighten' (expected string)\")\
  end\
  if not (type(delta) == \"number\") then\
    error(\"bad argument #2 to 'lighten' (expected number)\")\
  end\
  local color = new(value)\
  return color:tint(delta):format(\"#rrggbb\")\
end\
toHex = function(value)\
  if not (type(value) == \"string\" or type(value) == \"table\") then\
    error(\"bad argument #1 to 'toHex' (expected string)\")\
  end\
  return new(value):format(\"#rrggbb\")\
end",
['novacbn/lunarbook-plugin-builtin/utilities/string'] = "local gsub, lower\
do\
  local _obj_0 = string\
  gsub, lower = _obj_0.gsub, _obj_0.lower\
end\
gsubwhile = function(value, pattern, replacement)\
  local replacements = 1\
  while replacements > 0 do\
    value, replacements = gsub(value, pattern, replacement)\
  end\
  return value\
end\
slugify = function(value)\
  value = gsubwhile(value, \"%c\", \"\")\
  value = gsubwhile(value, \"[^%w%-]\", \"-\")\
  value = gsubwhile(value, \"%-%-\", \"-\")\
  value = gsub(value, \"^%-*(.-)%-*$\", \"%1\")\
  return lower(value)\
end",
['sebcat/markdown/exports'] = "local lpeg = require \"lpeg\"\
\
local stringx = import \"novacbn/lunarbook-plugin-builtin/utilities/string\"\
\
local R = lpeg.R\
local P = lpeg.P\
local V = lpeg.V\
local S = lpeg.S\
local C = lpeg.C\
local Cc = lpeg.Cc\
local Ct = lpeg.Ct\
local Cmt = lpeg.Cmt\
\
local function markdown_grammar()\
  local trim = function(str)\
    res = str:gsub(\"^%s*(.-)%s*$\", \"%1\")\
    return res\
  end\
\
  local header_grammar = function(n)\
    prefix = string.rep(\"#\",n)\
    return P(prefix)*(((1-V\"NL\")^0)/function(str)\
          return string.format(\"<h%d id='%s'>%s</h%d>\", n, stringx.slugify(trim(str)), trim(str), n)\
        end) * (V\"NL\" + -1)\
  end\
\
  local concat_anchor = function(s, i, text, href)\
    return true, string.format(\"<a href=\\\"%s\\\">%s</a>\", href, text)\
  end\
\
  local concat_matches = function(s, i, vals)\
    return i, table.concat(vals)\
  end\
\
  local line_attr = function(sym, tagname)\
    return P(sym) * Cc(string.format(\"<%s>\", tagname)) *((1-P(sym))^1/trim) *\
        Cc(string.format(\"</%s>\", tagname)) * P(sym)\
  end\
\
  return P{\
    \"markdown\";\
    NL = (P\"\\r\"^-1 * P\"\\n\")+-1,\
    WS = S\"\\t \",\
    OPTWS = V\"WS\"^0,\
    anchortext = (1-P\"]\")^0,\
    anchorref = (1-P\")\")^0,\
    anchor = Cmt(P\"[\" * C(V\"anchortext\") * P\"]\" *\
        P\"(\" * C(V\"anchorref\") * P\")\", concat_anchor),\
    line = Cmt(Ct((V\"anchor\" + line_attr(\"**\", \"strong\") + line_attr(\"*\", \"em\")\
        + line_attr(\"`\", \"code\") + C((1-V\"NL\")))^1), concat_matches),\
    lines = ((V\"line\")*V\"NL\")^1,\
    paragraph = Cc\"<p>\" * V\"lines\" * V\"NL\" * Cc\"</p>\",\
    ulli = P\"*\" * V\"OPTWS\" * Cc\"<li>\" * (((V\"line\")^-1)/trim) * Cc\"</li>\" *\
        V\"NL\",\
    ul = Cc\"<ul>\" * V\"ulli\"^1 * Cc\"</ul>\",\
    olli = R\"09\"^1 * P\".\" * V\"OPTWS\" * Cc\"<li>\" * (((V\"line\")^-1)/trim) *\
        Cc\"</li>\" * V\"NL\",\
    ol = Cc\"<ol>\" * V\"olli\"^1 * Cc\"</ol>\",\
    codeblock = P\"````\" * V\"NL\" * Cc\"<pre><code>\" * C((1-P\"````\")^0) *\
        Cc\"</code></pre>\" * P\"````\",\
    content = V\"ul\" + V\"ol\" + V\"codeblock\" + V\"paragraph\",\
    h1 = header_grammar(1),\
    h2 = header_grammar(2),\
    h3 = header_grammar(3),\
    h4 = header_grammar(4),\
    h5 = header_grammar(5),\
    h6 = header_grammar(6),\
    header = V\"h6\" + V\"h5\" + V\"h4\" + V\"h3\" + V\"h2\" + V\"h1\",\
    markdown = (S\"\\r\\n\\t \"^1 + V\"header\" + V\"content\")^0 * V\"NL\"\
  }\
end\
\
local parser = Ct(markdown_grammar())\
exports.parse = function(str)\
  local res = parser:match(str)\
  if type(res) == \"table\" then\
    return table.concat(res)\
  end\
end\
\
\
",
}, ...)