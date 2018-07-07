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

    return import('novacbn/lunarbook/main', ...)
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
['msva/htmlparser/ElementNode'] = "-- vim: ft=lua ts=2\
local Set = {}\
Set.mt = {__index = Set}\
function Set:new(values)\
\9local instance = {}\
\9local isSet if getmetatable(values) == Set.mt then isSet = true end\
\9if type(values) == \"table\" then\
\9\9if not isSet and #values > 0 then\
\9\9\9for _,v in ipairs(values) do\
\9\9\9\9instance[v] = true\
\9\9\9end\
\9\9else\
\9\9\9for k in pairs(values) do\
\9\9\9\9instance[k] = true\
\9\9\9end\
\9\9end\
\9elseif values ~= nil then\
\9\9instance = {[values] = true}\
\9end\
\9return setmetatable(instance, Set.mt)\
end\
\
function Set:add(e)\
\9if e ~= nil then self[e] = true end\
\9return self\
end\
\
function Set:remove(e)\
\9if e ~= nil then self[e] = nil end\
\9return self\
end\
\
function Set:tolist()\
\9local res = {}\
\9for k in pairs(self) do\
\9\9table.insert(res, k)\
\9end\
\9return res\
end\
\
Set.mt.__add = function (a, b)\
\9local res, a, b = Set:new(), Set:new(a), Set:new(b)\
\9for k in pairs(a) do res[k] = true end\
\9for k in pairs(b) do res[k] = true end\
\9return res\
end\
\
-- Subtraction\
Set.mt.__sub = function (a, b)\
\9local res, a, b = Set:new(), Set:new(a), Set:new(b)\
\9for k in pairs(a) do res[k] = true end\
\9for k in pairs(b) do res[k] = nil end\
\9return res\
end\
\
-- Intersection\
Set.mt.__mul = function (a, b)\
\9local res, a, b = Set:new(), Set:new(a), Set:new(b)\
\9for k in pairs(a) do\
\9\9res[k] = b[k]\
\9end\
\9return res\
end\
\
-- String representation\
Set.mt.__tostring = function (set)\
\9local s = \"{\"\
\9local sep = \"\"\
\9for k in pairs(set) do\
\9\9s = s .. sep .. tostring(k)\
\9\9sep = \", \"\
\9end\
\9return s .. \"}\"\
end\
\
\
local ElementNode = {}\
ElementNode.mt = {__index = ElementNode}\
function ElementNode:new(index, nameortext, node, descend, openstart, openend)\
\9local instance = {\
\9\9index = index,\
\9\9name = nameortext,\
\9\9level = 0,\
\9\9parent = nil,\
\9\9root = nil,\
\9\9nodes = {},\
\9\9_openstart = openstart, _openend = openend,\
\9\9_closestart = openstart, _closeend = openend,\
\9\9attributes = {},\
\9\9id = nil,\
\9\9classes = {},\
\9\9deepernodes = Set:new(),\
\9\9deeperelements = {}, deeperattributes = {}, deeperids = {}, deeperclasses = {}\
\9}\
\9if not node then\
\9\9instance.name = \"root\"\
\9\9instance.root = instance\
\9\9instance._text = nameortext\
\9\9local length = string.len(nameortext)\
\9\9instance._openstart, instance._openend = 1, length\
\9\9instance._closestart, instance._closeend = 1, length\
\9elseif descend then\
\9\9instance.root = node.root\
\9\9instance.parent = node\
\9\9instance.level = node.level + 1\
\9\9table.insert(node.nodes, instance)\
\9else\
\9\9instance.root = node.root\
\9\9instance.parent = node.parent\
\9\9instance.level = node.level\
\9\9table.insert(node.parent.nodes, instance)\
\9end\
\9return setmetatable(instance, ElementNode.mt)\
end\
\
function ElementNode:gettext()\
\9return string.sub(self.root._text, self._openstart, self._closeend)\
end\
\
function ElementNode:settext(c)\
\9self.root._text=c\
end\
\
function ElementNode:textonly()\
\9return (self:gettext():gsub(\"<[^>]*>\",\"\"))\
end\
\
function ElementNode:getcontent()\
\9return string.sub(self.root._text, self._openend + 1, self._closestart - 1)\
end\
\
function ElementNode:addattribute(k, v)\
\9self.attributes[k] = v\
\9if string.lower(k) == \"id\" then\
\9\9self.id = v\
\9-- class attribute contains \"space-separated tokens\", each of which we'd like quick access to\
\9elseif string.lower(k) == \"class\" then\
\9\9for class in string.gmatch(v, \"%S+\") do\
\9\9\9table.insert(self.classes, class)\
\9\9end\
\9end\
end\
\
local function insert(table, name, node)\
\9table[name] = table[name] or Set:new()\
\9table[name]:add(node)\
end\
\
function ElementNode:close(closestart, closeend)\
\9if closestart and closeend then\
\9\9self._closestart, self._closeend = closestart, closeend\
\9end\
\9-- inform hihger level nodes about this element's existence in their branches\
\9local node = self\
\9while true do\
\9\9node = node.parent\
\9\9if not node then break end\
\9\9node.deepernodes:add(self)\
\9\9insert(node.deeperelements, self.name, self)\
\9\9for k in pairs(self.attributes) do\
\9\9\9insert(node.deeperattributes, k, self)\
\9\9end\
\9\9if self.id then\
\9\9\9insert(node.deeperids, self.id, self)\
\9\9end\
\9\9for _,v in ipairs(self.classes) do\
\9\9\9insert(node.deeperclasses, v, self)\
\9\9end\
\9end\
end\
\
local function escape(s)\
\9-- escape all ^, $, (, ), %, ., [, ], *, +, - , and ? with a % prefix\
\9return string.gsub(s, \"([%^%$%(%)%%%.%[%]%*%+%-%?])\", \"%%\" .. \"%1\")\
end\
\
local function select(self, s)\
\9if not s or type(s) ~= \"string\" or s == \"\" then return Set:new() end\
\9local sets = {[\"\"]\9= self.deeperelements, [\"[\"] = self.deeperattributes,\
\9\9\9\9\9\9\9\9[\"#\"] = self.deeperids,\9\9\9[\".\"] = self.deeperclasses}\
\9local function match(t, w)\
\9\9local m, e, v\
\9\9if t == \"[\" then w, m, e, v = string.match(w, \
\9\9\9\9\"([^=|%*~%$!%^]+)\" .. -- w = 1 or more characters up to a possible \"=\", \"|\", \"*\", \"~\", \"$\", \"!\", or \"^\"\
\9\9\9\9\"([|%*~%$!%^]?)\" ..   -- m = an optional \"|\", \"*\", \"~\", \"$\", \"!\", or \"^\", preceding the optional \"=\"\
\9\9\9\9\"(=?)\" ..             -- e = the optional \"=\"\
\9\9\9\9\"(.*)\"                -- v = anything following the \"=\", or else \"\"\
\9\9\9)\
\9\9end\
\9\9local matched = Set:new(sets[t][w])\
\9\9-- attribute value selectors\
\9\9if e == \"=\" then\
\9\9\9if #v < 2 then v = \"'\" .. v .. \"'\" end -- values should be quoted\
\9\9\9v = string.sub(v, 2, #v - 1) -- strip quotes\
\9\9\9if m == \"!\" then matched = Set:new(self.deepernodes) end -- include those without that attribute\
\9\9\9for node in pairs(matched) do\
\9\9\9\9local a = node.attributes[w]\
\9\9\9\9-- equals\
\9\9\9\9if m == \"\" and a ~= v then matched:remove(node)\
\9\9\9\9-- not equals\
\9\9\9\9elseif m == \"!\" and a == v then matched:remove(node)\
\9\9\9\9-- prefix\
\9\9\9\9elseif m ==\"|\" and string.match(a, \"^[^-]*\") ~= v then matched:remove(node)\
\9\9\9\9-- contains\
\9\9\9\9elseif m ==\"*\" and string.match(a, escape(v)) ~= v then matched:remove(node)\
\9\9\9\9-- word\
\9\9\9\9elseif m ==\"~\" then matched:remove(node)\
\9\9\9\9\9for word in string.gmatch(a, \"%S+\") do\
\9\9\9\9\9\9if word == v then matched:add(node) break end\
\9\9\9\9\9end\
\9\9\9\9-- starts with\
\9\9\9\9elseif m ==\"^\" and string.match(a, \"^\" .. escape(v)) ~= v then matched:remove(node)\
\9\9\9\9-- ends with\
\9\9\9\9elseif m ==\"$\" and string.match(a, escape(v) .. \"$\") ~= v then matched:remove(node)\
\9\9\9\9end\
\9\9\9end -- for node\
\9\9end -- if v\
\9\9return matched\
\9end\
\
\9local subjects, resultset, childrenonly = Set:new({self})\
\9for part in string.gmatch(s, \"%S+\") do\
\9repeat\
\9\9if part == \">\" then childrenonly = true --[[goto nextpart]] break end\
\9\9resultset = Set:new()\
\9\9for subject in pairs(subjects) do\
\9\9\9local star = subject.deepernodes\
\9\9\9if childrenonly then star = Set:new(subject.nodes) end\
\9\9\9resultset = resultset + star\
\9\9end\
\9\9childrenonly = false\
\9\9if part == \"*\" then --[[goto nextpart]] break end\
\9\9local excludes, filter = Set:new()\
\9\9local start, pos = 0, 0\
\9\9while true do\
\9\9\9local switch, stype, name, eq, quote\
\9\9\9start, pos, switch, stype, name, eq, quote = string.find(part,\
\9\9\9\9\"(%(?%)?)\" ..         -- switch = a possible ( or ) switching the filter on or off\
\9\9\9\9\"([:%[#.]?)\" ..       -- stype = a possible :, [, #, or .\
\9\9\9\9\"([%w-_\\\\]+)\" ..      -- name = 1 or more alfanumeric chars (+ hyphen, reverse slash and uderscore)\
\9\9\9\9\"([|%*~%$!%^]?=?)\" .. -- eq = a possible |=, *=, ~=, $=, !=, ^=, or =\
\9\9\9\9\"(['\\\"]?)\",           -- quote = a ' or \" delimiting a possible attribute value\
\9\9\9\9pos + 1\
\9\9\9)\
\9\9\9if not name then break end\
\9repeat\
\9\9\9if \":\" == stype then\
\9\9\9\9filter = name\
\9\9\9\9--[[goto nextname]] break\
\9\9\9end\
\9\9\9if \")\" == switch then\
\9\9\9\9filter = nil\
\9\9\9end\
\9\9\9if \"[\" == stype and \"\" ~= quote then\
\9\9\9\9local value\
\9\9\9\9start, pos, value = string.find(part, \"(%b\" .. quote .. quote .. \")]\", pos)\
\9\9\9\9name = name .. eq .. value\
\9\9\9end\
\9\9\9local matched = match(stype, name)\
\9\9\9if filter == \"not\" then\
\9\9\9\9excludes = excludes + matched\
\9\9\9else\
\9\9\9\9resultset = resultset * matched\
\9\9\9end\
\9\9\9--::nextname::\
\9break\
\9until true\
\9\9end\
\9\9resultset = resultset - excludes\
\9\9subjects = Set:new(resultset)\
\9\9--::nextpart::\
break\
until true\
\9end\
\9resultset = resultset:tolist()\
\9table.sort(resultset, function (a, b) return a.index < b.index end)\
\9return resultset\
end\
\
function ElementNode:select(s) return select(self, s) end\
ElementNode.mt.__call = select\
\
exports.ElementNode = ElementNode\
",
['msva/htmlparser/exports'] = "-- vim: ft=lua ts=2 sw=2\
\
local esc = function(s) return string.gsub(s, \"([%^%$%(%)%%%.%[%]%*%+%-%?])\", \"%%\" .. \"%1\") end\
local str = tostring\
local char = string.char\
local err = function(s) io.stderr:write(s) end\
local out = function(s) io.stdout:write(s) end\
\
local ElementNode = import(\"msva/htmlparser/ElementNode\").ElementNode\
local voidelements = import(\"msva/htmlparser/voidelements\").voidelements\
\
local tpr = {\
\9-- Here we're replacing confusing sequences\
\9-- (things looking like tags, but appearing where tags can't)\
\9-- with definitelly invalid utf sequence, and later we'll replace them back\
\9[\"<\"] = char(208,209,208,209),\
\9[\">\"] = char(209,208,209,208),\
}\
\
function exports.parse(text,limit)\
\9local text=str(text)\
\
\9local limit = limit or htmlparser_looplimit or 1000\
\
\9local tpl = false\
\
\9local function g(id,...)\
\9\9local arg={...}\
\9\9arg[id]=tpr[arg[id]]\
\9\9tpl=true\
\9\9return table.concat(arg)\
\9end\
\
\9text = text\
\9\9:gsub(\
\9\9\9\"(<)\"..\
\9\9\9\"([^>]-)\"..\
\9\9\9\"(<)\",\
\9\9\9function(...)return g(3,...)end\
\9\9):gsub(\
\9\9\9\"(\"..tpr[\"<\"]..\")\"..\
\9\9\9\"([^%w%s])\"..\
\9\9\9\"([^%2]-)\"..\
\9\9\9\"(%2)\"..\
\9\9\9\"(>)\"..\
\9\9\9\"([^>]-)\"..\
\9\9\9\"(>)\",\
\9\9\9function(...)return g(5,...)end\
\9\9):gsub(\
\9\9\9[=[(['\"])]=]..\
\9\9\9[=[([^'\">%s]-)]=]..\
\9\9\9\"(>)\"..\
\9\9\9[=[([^'\">%s]-)]=]..\
\9\9\9[=[(['\"])]=],\
\9\9\9function(...)return g(3,...)end\
\9\9)\
\
\9local index = 0\
\9local root = ElementNode:new(index, str(text))\
\
\9local node, descend, tpos, opentags = root, true, 1, {}\
\9while true do\
\9\9if index == limit then\
\9\9\9err(\"[HTMLParser] [ERR] Main loop reached loop limit (\"..limit..\"). Please, consider increasing it or check the code for errors\")\
\9\9\9break\
\9\9end\
\
\9\9local openstart, name\
\9\9openstart, tpos, name = root._text:find(\
\9\9\9\"<\" ..        -- an uncaptured starting \"<\"\
\9\9\9\"([%w-]+)\" .. -- name = the first word, directly following the \"<\"\
\9\9\9\"[^>]*>\",     -- include, but not capture everything up to the next \">\"\
\9\9tpos)\
\
\9\9if not name then break end\
\
\9\9index = index + 1\
\
\9\9local tag = ElementNode:new(index, str(name), node, descend, openstart, tpos)\
\9\9node = tag\
\
\9\9local tagloop\
\9\9local tagst, apos = tag:gettext(), 1\
\9\9while true do\
\9\9\9if tagloop == limit then\
\9\9\9\9err(\"[HTMLParser] [ERR] tag parsing loop reached loop limit (\"..limit..\"). Please, consider increasing it or check the code for errors\")\
\9\9\9\9break\
\9\9\9end\
\
\9\9\9local start, k, eq, quote, v\
\9\9\9start, apos, k, eq, quote = tagst:find(\
\9\9\9\9\"%s+\" ..         -- some uncaptured space\
\9\9\9\9\"([^%s=/>]+)\" .. -- k = an unspaced string up to an optional \"=\" or the \"/\" or \">\"\
\9\9\9\9\"(=?)\" ..        -- eq = the optional; \"=\", else \"\"\
\9\9\9\9\"(['\\\"]?)\",      -- quote = an optional \"'\" or '\"' following the \"=\", or \"\"\
\9\9\9apos)\
\
\9\9\9if not k or k == \"/>\" or k == \">\" then break end\
\
\9\9\9if eq == \"=\" then\
\9\9\9\9pattern = \"=([^%s>]*)\"\
\9\9\9\9if quote ~= \"\" then\
\9\9\9\9\9pattern = quote .. \"([^\" .. quote .. \"]*)\" .. quote\
\9\9\9\9end\
\9\9\9\9start, apos, v = tagst:find(pattern, apos)\
\9\9\9end\
\
\9\9\9v=v or \"\"\
\
\9\9\9if tpl then\
\9\9\9\9for rk,rv in pairs(tpr) do\
\9\9\9\9\9\9v = v:gsub(rv,rk)\
\9\9\9\9end\
\9\9\9end\
\
\9\9\9tag:addattribute(k, v)\
\9\9\9tagloop = (tagloop or 0) + 1\
\9\9end\
\
\9\9if voidelements[tag.name:lower()] then\
\9\9\9descend = false\
\9\9\9tag:close()\
\9\9else\
\9\9\9opentags[tag.name] = opentags[tag.name] or {}\
\9\9\9table.insert(opentags[tag.name], tag)\
\9\9end\
\
\9\9local closeend = tpos\
\9\9local closingloop\
\9\9while true do\
\9\9\9if closingloop == limit then\
\9\9\9\9err(\"[HTMLParser] [ERR] tag closing loop reached loop limit (\"..limit..\"). Please, consider increasing it or check the code for errors\")\
\9\9\9\9break\
\9\9\9end\
\
\9\9\9local closestart, closing, closename\
\9\9\9closestart, closeend, closing, closename = root._text:find(\"[^<]*<(/?)([%w-]+)\", closeend)\
\
\9\9\9if not closing or closing == \"\" then break end\
\
\9\9\9tag = table.remove(opentags[closename] or {}) or tag -- kludges for the cases of closing void or non-opened tags\
\9\9\9closestart = root._text:find(\"<\", closestart)\
\9\9\9tag:close(closestart, closeend + 1)\
\9\9\9node = tag.parent\
\9\9\9descend = true\
\9\9\9closingloop = (closingloop or 0) + 1\
\9\9end\
\9end\
\
\9if tpl then\
\9\9for k,v in pairs(tpr) do\
\9\9\9root._text = root._text:gsub(v,k)\
\9\9end\
\9end\
\
\9return root\
end\
\
",
['msva/htmlparser/voidelements'] = "-- vim: ft=lua ts=2\
voidelements = {\
\9area = true,\
\9base = true,\
\9br = true,\
\9col = true,\
\9command = true,\
\9embed = true,\
\9hr = true,\
\9img = true,\
\9input = true,\
\9keygen = true,\
\9link = true,\
\9meta = true,\
\9param = true,\
\9source = true,\
\9track = true,\
\9wbr = true\
}\
",
['novacbn/command-ops/Command'] = "local next, type, unpack\
do\
  local _obj_0 = _G\
  next, type, unpack = _obj_0.next, _obj_0.type, _obj_0.unpack\
end\
local rep\
rep = string.rep\
local concat, insert\
do\
  local _obj_0 = table\
  concat, insert = _obj_0.concat, _obj_0.insert\
end\
local Options\
Options = dependency(\"novacbn/command-ops/Options\").Options\
local TEMPLATE_EXAMPLE_TEXT\
TEMPLATE_EXAMPLE_TEXT = function(binary, command, example, spaces)\
  if spaces == nil then\
    spaces = 10\
  end\
  return tostring(rep(' ', spaces)) .. tostring(binary) .. \" \" .. tostring(command) .. \" \" .. tostring(example)\
end\
local TEMPLATE_HELP_TEXT\
TEMPLATE_HELP_TEXT = function(usage, examples, description, options)\
  return tostring(description) .. \"\\nUsage:    \" .. tostring(usage) .. tostring(examples and '\\n\\nExamples: ' .. examples or '') .. tostring(options and '\\n\\nOptions:\\n' .. options or '')\
end\
local TEMPLATE_USAGE_TEXT\
TEMPLATE_USAGE_TEXT = function(binary, command, syntax)\
  return tostring(binary) .. \" \" .. tostring(command) .. tostring(syntax and ' ' .. syntax or '')\
end\
Command = function(name, description, callback)\
  return {\
    callback = callback,\
    description = description,\
    examples = nil,\
    name = name,\
    options = Options(),\
    syntax = nil,\
    addExample = function(self, example)\
      if not (type(example) == \"string\") then\
        error(\"bad argument #1 to 'addExample' (expected string)\")\
      end\
      if not (self.examples) then\
        self.examples = { }\
      end\
      return insert(self.examples, example)\
    end,\
    exec = function(self, binary, flags, arguments)\
      local err = self.options:parse(binary, flags)\
      if err then\
        return print(err)\
      else\
        return callback(self.options, unpack(arguments))\
      end\
    end,\
    formatHelp = function(self, binary)\
      local usage = TEMPLATE_USAGE_TEXT(binary, name, self.syntax)\
      local examples\
      if self.examples then\
        local first = TEMPLATE_EXAMPLE_TEXT(binary, name, self.examples[1], 0)\
        do\
          local _accum_0 = { }\
          local _len_0 = 1\
          local _list_0 = self.examples\
          for _index_0 = 2, #_list_0 do\
            local example = _list_0[_index_0]\
            _accum_0[_len_0] = TEMPLATE_EXAMPLE_TEXT(binary, name, example)\
            _len_0 = _len_0 + 1\
          end\
          examples = _accum_0\
        end\
        insert(examples, 1, first)\
        examples = concat(examples, \"\\n\")\
      end\
      local options\
      if next(self.options.options) then\
        options = self.options:formatHelp()\
      end\
      return TEMPLATE_HELP_TEXT(usage, examples, self.description, options)\
    end,\
    setSyntax = function(self, syntax)\
      if not (type(syntax) == \"string\") then\
        error(\"bad argument #1 to 'setSyntax' (expected string)\")\
      end\
      self.syntax = syntax\
    end\
  }\
end",
['novacbn/command-ops/CommandOps'] = "local pairs, print, type\
do\
  local _obj_0 = _G\
  pairs, print, type = _obj_0.pairs, _obj_0.print, _obj_0.type\
end\
local match\
match = string.match\
local sort, remove\
do\
  local _obj_0 = table\
  sort, remove = _obj_0.sort, _obj_0.remove\
end\
local Command\
Command = dependency(\"novacbn/command-ops/Command\").Command\
local layoutText, parseArguments\
do\
  local _obj_0 = dependency(\"novacbn/command-ops/utilities\")\
  layoutText, parseArguments = _obj_0.layoutText, _obj_0.parseArguments\
end\
local PATTERN_BINARY_NAME = \"^[%w%-%.%_]+$\"\
local TEMPLATE_HELP_TEXT\
TEMPLATE_HELP_TEXT = function(name, version, binary, commands)\
  return tostring(name) .. tostring(version and ' :: ' .. version or '') .. \"\\nUsage:    \" .. tostring(binary) .. \" [flags] [command]\\n\\nCommands:\\n\" .. tostring(commands)\
end\
CommandOps = function(cliName, binary, version)\
  if not (type(cliName) == \"string\") then\
    error(\"bad argument #1 to 'CommandOps' (expected string)\")\
  end\
  if not (type(binary) == \"string\") then\
    error(\"bad argument #2 to 'CommandOps' (expected string)\")\
  end\
  if not (match(binary, PATTERN_BINARY_NAME)) then\
    error(\"bad argument #2 to 'CommandOps' (malformed binary)\")\
  end\
  if not (version == nil or type(version) == \"string\") then\
    error(\"bad argument #3 to 'CommandOps' (expected string)\")\
  end\
  return {\
    binary = binary,\
    commands = { },\
    name = name,\
    version = version,\
    command = function(self, name, description, callback)\
      if not (type(name) == \"string\") then\
        error(\"bad argument #1 to 'command' (expected string)\")\
      end\
      if self.commands[name] then\
        error(\"bad argument #1 to 'command' (existing command)\")\
      end\
      if not (type(description) == \"string\") then\
        error(\"bad argument #2 to 'command' (expected string)\")\
      end\
      if not (type(callback) == \"function\") then\
        error(\"bad argument #3 to 'command' (expected function)\")\
      end\
      local command = Command(name, description, callback)\
      self.commands[name] = command\
      return command\
    end,\
    exec = function(self, arguments)\
      local flags\
      arguments, flags = parseArguments(arguments)\
      local name = remove(arguments, 1)\
      if name == nil or name == \"help\" then\
        return self:printHelp(arguments[1])\
      elseif self.commands[name] then\
        local command = self.commands[name]\
        return command:exec(binary, flags, arguments)\
      else\
        return print(\"unknown command '\" .. tostring(name) .. \"'\")\
      end\
    end,\
    formatHelp = function(self)\
      local commands\
      do\
        local _accum_0 = { }\
        local _len_0 = 1\
        for name, command in pairs(self.commands) do\
          _accum_0[_len_0] = name\
          _len_0 = _len_0 + 1\
        end\
        commands = _accum_0\
      end\
      sort(commands)\
      do\
        local _accum_0 = { }\
        local _len_0 = 1\
        for _index_0 = 1, #commands do\
          local name = commands[_index_0]\
          _accum_0[_len_0] = \"    \" .. name .. \"\\t\" .. self.commands[name].description\
          _len_0 = _len_0 + 1\
        end\
        commands = _accum_0\
      end\
      commands = layoutText(commands, 4)\
      return TEMPLATE_HELP_TEXT(cliName, version, binary, commands)\
    end,\
    printHelp = function(self, name)\
      if not (name) then\
        print(self:formatHelp())\
        return \
      end\
      local command = self.commands[name]\
      if not (command) then\
        if name then\
          return print(\"unknown command '\" .. tostring(name) .. \"'\")\
        else\
          return print(\"missing command\")\
        end\
      else\
        return print(command:formatHelp(binary))\
      end\
    end\
  }\
end",
['novacbn/command-ops/Options'] = "local type\
type = _G.type\
local getenv\
getenv = os.getenv\
local gsub, match, sub, upper\
do\
  local _obj_0 = string\
  gsub, match, sub, upper = _obj_0.gsub, _obj_0.match, _obj_0.sub, _obj_0.upper\
end\
local concat, insert, sort\
do\
  local _obj_0 = table\
  concat, insert, sort = _obj_0.concat, _obj_0.insert, _obj_0.sort\
end\
local isAffirmative, layoutText\
do\
  local _obj_0 = dependency(\"novacbn/command-ops/utilities\")\
  isAffirmative, layoutText = _obj_0.isAffirmative, _obj_0.layoutText\
end\
local PATTERN_OPTION = \"^%l[%l%-]+$\"\
local PATTERN_OPTIONS_PART = \"%-(%l)\"\
local TEMPLATE_OPTION_TEXT\
TEMPLATE_OPTION_TEXT = function(flagMini, flagFull, description)\
  return \"    \" .. tostring(flagMini) .. \", \" .. tostring(flagFull) .. \"\\t\" .. tostring(description)\
end\
local formatEnvFull\
formatEnvFull = function(binary, option)\
  local command = gsub(binary, \"%-\", \"_\")\
  option = gsub(option, \"%-\", \"_\")\
  return upper(tostring(binary) .. \"_\" .. tostring(option))\
end\
local formatFlagMini\
formatFlagMini = function(name)\
  local parts = {\
    sub(name, 1, 1)\
  }\
  gsub(name, PATTERN_OPTIONS_PART, function(self)\
    return insert(parts, self)\
  end)\
  return \"-\" .. tostring(concat(parts))\
end\
local makeOptionType\
makeOptionType = function(typeName, defaultValue, transform)\
  return function(self, name, description, default, validate)\
    if default == nil then\
      default = defaultValue\
    end\
    if not (type(name) == \"string\") then\
      error(\"bad argument #1 to '\" .. tostring(typeName) .. \"' (expected string)\")\
    end\
    if not (type(description) == \"string\") then\
      error(\"bad argument #2 to '\" .. tostring(typeName) .. \"' (expected string)\")\
    end\
    if not (type(default) == typeName) then\
      error(\"bad argument #3 to '\" .. tostring(typeName) .. \"' (expected \" .. tostring(typeName) .. \")\")\
    end\
    if not (validate == nil or type(validate) == \"function\") then\
      error(\"bad argument #4 to '\" .. tostring(typeName) .. \"' (expected function)\")\
    end\
    if not (match(name, PATTERN_OPTION)) then\
      error(\"bad argument #1 to '\" .. tostring(typeName) .. \"' (malformed option)\")\
    end\
    if self.options[name] then\
      error(\"bad argument #1 to '\" .. tostring(typeName) .. \"' (existing option)\")\
    end\
    local flagMini = formatFlagMini(name)\
    for name, option in pairs(self.options) do\
      if option.flagMini == flagMini then\
        error(\"bad argument #1 to '\" .. tostring(typeName) .. \"' (duplicate mini CLI flag)\")\
      end\
    end\
    self.options[name] = {\
      name = name,\
      description = description,\
      default = default,\
      validate = validate,\
      transform = transform,\
      flagMini = flagMini,\
      flagFull = \"--\" .. tostring(name),\
      value = nil\
    }\
  end\
end\
Options = function()\
  return {\
    options = { },\
    formatHelp = function(self)\
      local options\
      do\
        local _accum_0 = { }\
        local _len_0 = 1\
        for name, option in pairs(self.options) do\
          _accum_0[_len_0] = name\
          _len_0 = _len_0 + 1\
        end\
        options = _accum_0\
      end\
      sort(options)\
      for index, name in ipairs(options) do\
        local option = self.options[name]\
        options[index] = TEMPLATE_OPTION_TEXT(option.flagMini, option.flagFull, option.description)\
      end\
      return layoutText(options)\
    end,\
    get = function(self, name)\
      if not (type(name) == \"string\") then\
        error(\"bad argument #1 to 'get' (expected string)\")\
      end\
      local option = self.options[name]\
      if not (self.options[name]) then\
        error(\"bad argument #1 to 'get' (unexpected option)\")\
      end\
      return option.value ~= nil and option.value or option.default\
    end,\
    parse = function(self, binary, flags)\
      for name, option in pairs(self.options) do\
        local value = flags[option.flagMini]\
        if value == nil then\
          value = flags[option.flagFull]\
        end\
        if value == nil then\
          value = getenv(formatEnvFull(binary, name))\
        end\
        if value == nil then\
          return \
        end\
        if option.transform then\
          value = option.transform(value)\
          if value == nil then\
            return \"bad option to '\" .. tostring(option.name) .. \"' (malformed value)\"\
          end\
        end\
        if option.validate then\
          local err = option.validate(value)\
          if not (err) then\
            return \"bad option to '\" .. tostring(option.name) .. \"' (\" .. tostring(err) .. \")\"\
          end\
        end\
        option.value = value\
      end\
    end,\
    boolean = makeOptionType(\"boolean\", false, isAffirmative),\
    number = makeOptionType(\"number\", 0, tonumber),\
    string = makeOptionType(\"string\", \"\")\
  }\
end",
['novacbn/command-ops/utilities'] = "local ipairs\
ipairs = _G.ipairs\
local match, lower, rep\
do\
  local _obj_0 = string\
  match, lower, rep = _obj_0.match, _obj_0.lower, _obj_0.rep\
end\
local concat, insert\
do\
  local _obj_0 = table\
  concat, insert = _obj_0.concat, _obj_0.insert\
end\
local PATTERN_FLAG_FULL = \"^%-%-[%w%-]+\"\
local PATTERN_FLAG_MINI = \"^%-[%w]+\"\
local PATTERN_FLAG_VALUE = \"(.+)%s?=%s?(.+)\"\
local TABLE_AFFIRMATIVE_VALUES\
do\
  local _tbl_0 = { }\
  local _list_0 = {\
    \"1\",\
    \"y\",\
    \"yes\",\
    \"t\",\
    \"true\",\
    true\
  }\
  for _index_0 = 1, #_list_0 do\
    local value = _list_0[_index_0]\
    _tbl_0[value] = true\
  end\
  TABLE_AFFIRMATIVE_VALUES = _tbl_0\
end\
isAffirmative = function(value)\
  if type(value) == \"string\" then\
    value = lower(value)\
  end\
  return TABLE_AFFIRMATIVE_VALUES[value] or false\
end\
layoutText = function(lines, spaces)\
  if spaces == nil then\
    spaces = 4\
  end\
  do\
    local _accum_0 = { }\
    local _len_0 = 1\
    for _index_0 = 1, #lines do\
      local line = lines[_index_0]\
      _accum_0[_len_0] = line\
      _len_0 = _len_0 + 1\
    end\
    lines = _accum_0\
  end\
  local maxLength = 0\
  for index, line in ipairs(lines) do\
    local first, second = match(line, \"^(.+)\\t(.+)$\")\
    if #first > maxLength then\
      maxLength = #first\
    end\
  end\
  for index, line in ipairs(lines) do\
    local first, second = match(line, \"^(.+)\\t(.+)$\")\
    lines[index] = first .. rep(\" \", (maxLength + spaces) - #first) .. second\
  end\
  return concat(lines, \"\\n\")\
end\
parseArguments = function(argv)\
  local arguments, flags = { }, { }\
  local firstArgument = false\
  for _index_0 = 1, #argv do\
    local _continue_0 = false\
    repeat\
      local argument = argv[_index_0]\
      if not firstArgument and (match(argument, PATTERN_FLAG_MINI) or match(argument, PATTERN_FLAG_FULL)) then\
        local flag, value = match(argument, PATTERN_FLAG_VALUE)\
        if flag and value then\
          flags[flag] = value\
        else\
          flags[argument] = true\
        end\
        _continue_0 = true\
        break\
      end\
      firstArgument = true\
      insert(arguments, argument)\
      _continue_0 = true\
    until true\
    if not _continue_0 then\
      break\
    end\
  end\
  return arguments, flags\
end",
['novacbn/lunarbook/api/Book'] = "local pairs, type\
do\
  local _obj_0 = _G\
  pairs, type = _obj_0.pairs, _obj_0.type\
end\
local lower\
lower = string.lower\
local Object\
Object = require(\"core\").Object\
local readFileSync\
readFileSync = require(\"fs\").readFileSync\
local basename, dirname, extname\
do\
  local _obj_0 = require(\"path\")\
  basename, dirname, extname = _obj_0.basename, _obj_0.dirname, _obj_0.extname\
end\
local decode\
decode = dependency(\"novacbn/properties/exports\").decode\
local VirtualFileSystem\
VirtualFileSystem = dependency(\"novacbn/luvit-extras/vfs\").VirtualFileSystem\
local FileSystemAdapter\
FileSystemAdapter = dependency(\"novacbn/luvit-extras/adapters/FileSystemAdapter\").FileSystemAdapter\
local fsx = dependency(\"novacbn/luvit-extras/fs\")\
local Theme\
Theme = dependency(\"novacbn/lunarbook/api/Theme\").Theme\
local PluginManager\
PluginManager = dependency(\"novacbn/lunarbook/api/PluginManager\").PluginManager\
local ALLOWED_FRAGMENT_TYPES, BOOK_HOME, BUILD_DIRS\
do\
  local _obj_0 = dependency(\"novacbn/lunarbook/lib/constants\")\
  ALLOWED_FRAGMENT_TYPES, BOOK_HOME, BUILD_DIRS = _obj_0.ALLOWED_FRAGMENT_TYPES, _obj_0.BOOK_HOME, _obj_0.BUILD_DIRS\
end\
local extractSections, extractTitle\
do\
  local _obj_0 = dependency(\"novacbn/lunarbook/lib/utilities\")\
  extractSections, extractTitle = _obj_0.extractSections, _obj_0.extractTitle\
end\
local endswith, slugify\
do\
  local _obj_0 = dependency(\"novacbn/lunarbook/lib/utilities/string\")\
  endswith, slugify = _obj_0.endswith, _obj_0.slugify\
end\
local isdirSync, isfileSync, join\
do\
  local _obj_0 = dependency(\"novacbn/lunarbook/lib/utilities/vfs\")\
  isdirSync, isfileSync, join = _obj_0.isdirSync, _obj_0.isfileSync, _obj_0.join\
end\
local LunarConfig\
LunarConfig = dependency(\"novacbn/lunarbook/schemas/LunarConfig\").LunarConfig\
local ProcessedFragment\
ProcessedFragment = function(render, link, title, sections)\
  return {\
    link = link,\
    render = render,\
    title = title,\
    sections = sections\
  }\
end\
do\
  local _with_0 = Object:extend()\
  _with_0.cache = nil\
  _with_0.configuration = nil\
  _with_0.layoutEnvironment = nil\
  _with_0.plugins = nil\
  _with_0.styleEnvironment = nil\
  _with_0.theme = nil\
  _with_0.vfs = nil\
  _with_0.initialize = function(self, bookDirectory, buildDirectory, themeDirectory)\
    if not (type(bookDirectory) == \"string\") then\
      error(\"bad argument #1 to 'initialize' (expected string)\")\
    end\
    if not (type(buildDirectory) == \"string\") then\
      error(\"bad argument #2 to 'initialize' (expected string)\")\
    end\
    local configuration\
    if fsx.isfileSync(BOOK_HOME.configuration) then\
      local contents = readFileSync(BOOK_HOME.configuration)\
      configuration = decode(contents, {\
        propertiesEncoder = \"moonscript\"\
      })\
    end\
    local err\
    self.configuration, err = LunarConfig:transform(configuration)\
    if err then\
      error(\"bad dispatch to 'initialize' (malformed book config)\\n\" .. tostring(err))\
    end\
    self.cache = { }\
    self.plugins = PluginManager:new()\
    self.theme = Theme:new(themeDirectory, self.configuration.theme)\
    self.vfs = VirtualFileSystem:new()\
    self.vfs:mount(\"book\", FileSystemAdapter:new(bookDirectory))\
    self.vfs:mount(\"build\", FileSystemAdapter:new(buildDirectory))\
    if not (isdirSync(self.vfs, BUILD_DIRS.assets)) then\
      self.vfs:mkdirSync(BUILD_DIRS.assets)\
    end\
    if not (isdirSync(self.vfs, BUILD_DIRS.fragments)) then\
      self.vfs:mkdirSync(BUILD_DIRS.fragments)\
    end\
    if not (isdirSync(self.vfs, BUILD_DIRS.scripts)) then\
      self.vfs:mkdirSync(BUILD_DIRS.scripts)\
    end\
    if not (isdirSync(self.vfs, BUILD_DIRS.styles)) then\
      self.vfs:mkdirSync(BUILD_DIRS.styles)\
    end\
    self:initializePlugins()\
    return self:initializeAssets()\
  end\
  _with_0.initializeAssets = function(self)\
    local _list_0 = self.theme:getIncludedAssets()\
    for _index_0 = 1, #_list_0 do\
      local asset = _list_0[_index_0]\
      self.vfs:writeFileSync(join(BUILD_DIRS.assets, asset.name), asset.contents)\
    end\
    do\
      local _accum_0 = { }\
      local _len_0 = 1\
      local _list_1 = self.theme:getIncludedAssets()\
      for _index_0 = 1, #_list_1 do\
        local asset = _list_1[_index_0]\
        if endswith(lower(asset.name), \".js\") then\
          _accum_0[_len_0] = \"assets/\" .. asset.name\
          _len_0 = _len_0 + 1\
        end\
      end\
      self.theme.configuration.environment.scripts = _accum_0\
    end\
    do\
      local _accum_0 = { }\
      local _len_0 = 1\
      local _list_1 = self.theme:getIncludedAssets()\
      for _index_0 = 1, #_list_1 do\
        local asset = _list_1[_index_0]\
        if endswith(lower(asset.name), \".css\") then\
          _accum_0[_len_0] = \"assets/\" .. asset.name\
          _len_0 = _len_0 + 1\
        end\
      end\
      self.theme.configuration.environment.styles = _accum_0\
    end\
  end\
  _with_0.initializePlugins = function(self)\
    self.plugins:processConfiguration(self.configuration.plugins)\
    self.transformers = self.plugins:configureTransformers()\
    self.layoutEnvironment = self.plugins:configureLayoutEnvironment():clone()\
    self.styleEnvironment = self.plugins:configureStyleEnvironment():clone()\
  end\
  _with_0.createFragment = function(self, file, fragments)\
    local fragment = self:processFragment(file)\
    local layout = self.theme:render(\"Index\", true, self.layoutEnvironment, {\
      fragment = fragment.render,\
      navigation = fragments\
    })\
    local link = join(BUILD_DIRS.fragments, fragment.link)\
    if not (isdirSync(self.vfs, link)) then\
      self.vfs:mkdirSync(link)\
    end\
    self.vfs:writeFileSync(join(link, \"index.html\"), fragment.render)\
    if not (isdirSync(self.vfs, BUILD_DIRS.scheme .. fragment.link)) then\
      self.vfs:mkdirSync(BUILD_DIRS.scheme .. fragment.link)\
    end\
    return self.vfs:writeFileSync(BUILD_DIRS.scheme .. join(fragment.link, \"index.html\"), layout)\
  end\
  _with_0.processBook = function(self)\
    self:processDirectory(\"\")\
    local _list_0 = self.cache\
    for _index_0 = 1, #_list_0 do\
      local fragment = _list_0[_index_0]\
      self.vfs:writeFileSync(join(BUILD_DIRS.fragments, fragment.link .. \".html\"), fragment.render)\
    end\
    return self.vfs:writeFileSync(join(BUILD_DIRS.styles, \"lunarbook.components.css\"), self.theme:getComputedStyle(true, self.styleEnvironment))\
  end\
  _with_0.processDirectory = function(self, directory)\
    local entries = self.vfs:readdirSync(\"book://\" .. directory)\
    local directories\
    do\
      local _accum_0 = { }\
      local _len_0 = 1\
      for _index_0 = 1, #entries do\
        local entry = entries[_index_0]\
        if isdirSync(self.vfs, \"book://\" .. join(directory, entry)) then\
          _accum_0[_len_0] = entry\
          _len_0 = _len_0 + 1\
        end\
      end\
      directories = _accum_0\
    end\
    local files\
    do\
      local _accum_0 = { }\
      local _len_0 = 1\
      for _index_0 = 1, #entries do\
        local entry = entries[_index_0]\
        if isfileSync(self.vfs, \"book://\" .. join(directory, entry)) and ALLOWED_FRAGMENT_TYPES[lower(extname(entry))] then\
          _accum_0[_len_0] = entry\
          _len_0 = _len_0 + 1\
        end\
      end\
      files = _accum_0\
    end\
    local fragments\
    do\
      local _accum_0 = { }\
      local _len_0 = 1\
      for _index_0 = 1, #files do\
        local fragment = files[_index_0]\
        _accum_0[_len_0] = self:processFragment(join(directory, fragment))\
        _len_0 = _len_0 + 1\
      end\
      fragments = _accum_0\
    end\
    if #directories > 0 or #files > 0 then\
      if not (isdirSync(self.vfs, \"build://\" .. tostring(directory))) then\
        self.vfs:mkdirSync(\"build://\" .. tostring(directory))\
      end\
      if not (isdirSync(self.vfs, join(BUILD_DIRS.fragments, directory))) then\
        self.vfs:mkdirSync(join(BUILD_DIRS.fragments, directory))\
      end\
    end\
    for _index_0 = 1, #directories do\
      local entry = directories[_index_0]\
      self:processDirectory(join(directory, entry))\
    end\
    local _list_0 = files\
    for _index_0 = 1, #_list_0 do\
      local entry = _list_0[_index_0]\
      self:createFragment(join(directory, entry), #fragments > 1 and fragments)\
    end\
  end\
  _with_0.processFragment = function(self, file)\
    if not (self.cache[file]) then\
      local contents = self.vfs:readFileSync(\"book://\" .. file)\
      contents = self.transformers:processFragment(file, false, contents)\
      local layout = self.theme:render(\"Fragment\", true, self.layoutEnvironment, {\
        fragment = contents\
      })\
      local link = dirname(file)\
      if link == \".\" then\
        link = \"\"\
      end\
      local title = extractTitle(layout)\
      if not (basename(file, extname(file)) == \"index\") then\
        link = join(link, slugify(title))\
        if not (#link > 0) then\
          error(\"bad argument #1 to 'processFragment' (missing or malformed title)\")\
        end\
      end\
      local sections\
      do\
        local _accum_0 = { }\
        local _len_0 = 1\
        local _list_0 = extractSections(layout)\
        for _index_0 = 1, #_list_0 do\
          local section = _list_0[_index_0]\
          _accum_0[_len_0] = {\
            title = section,\
            link = link .. \"#\" .. slugify(section)\
          }\
          _len_0 = _len_0 + 1\
        end\
        sections = _accum_0\
      end\
      self.cache[file] = ProcessedFragment(layout, link, title, sections)\
    end\
    return self.cache[file]\
  end\
  Book = _with_0\
end",
['novacbn/lunarbook/api/ChunkEnvironment'] = "local type\
type = _G.type\
local Object\
Object = require(\"core\").Object\
do\
  local _with_0 = Object:extend()\
  _with_0.environment = nil\
  _with_0.initialize = function(self)\
    self.environment = { }\
  end\
  _with_0.clone = function(self)\
    local _tbl_0 = { }\
    for key, value in pairs(self.environment) do\
      _tbl_0[key] = value\
    end\
    return _tbl_0\
  end\
  _with_0.registerVariable = function(self, name, value)\
    if not (type(name) == \"string\") then\
      error(\"bad argument #1 to 'registerVariable' (expected string)\")\
    end\
    if self.environment[name] then\
      error(\"bad argument #1 to 'registerVariable' (pre-existing name)\")\
    end\
    self.environment[name] = value\
  end\
  ChunkEnvironment = _with_0\
end",
['novacbn/lunarbook/api/PluginManager'] = "local type\
type = _G.type\
local Object\
Object = require(\"core\").Object\
local ChunkEnvironment\
ChunkEnvironment = dependency(\"novacbn/lunarbook/api/ChunkEnvironment\").ChunkEnvironment\
local Transformers\
Transformers = dependency(\"novacbn/lunarbook/api/Transformers\").Transformers\
local LOADED_PLUGINS = {\
  {\
    name = builtin,\
    exports = loadfile(dependency(\"novacbn/lunarbook/lib/constants\").BOOK_HOME.plugins .. \"/lunarbook-plugin-builtin.lua\")()\
  }\
}\
local LoadedPlugin\
LoadedPlugin = function(name, exports)\
  return {\
    exports = exports,\
    name = name\
  }\
end\
do\
  local _with_0 = Object:extend()\
  _with_0.plugins = nil\
  _with_0.initialize = function(self, plugins)\
    if plugins == nil then\
      plugins = LOADED_PLUGINS\
    end\
    self.plugins = plugins\
  end\
  _with_0.dispatch = function(self, name, ...)\
    local _list_0 = self.plugins\
    for _index_0 = 1, #_list_0 do\
      local plugin = _list_0[_index_0]\
      if plugin.exports[name] then\
        plugin.exports[name](...)\
      end\
    end\
  end\
  _with_0.configureLayoutEnvironment = function(self, environment)\
    if environment == nil then\
      environment = ChunkEnvironment:new()\
    end\
    if not (type(environment) == \"table\") then\
      error(\"bad argument #1 to 'configureLayoutEnvironment' (expected ChunkEnvironment)\")\
    end\
    self:dispatch(\"configureLayoutEnvironment\", environment)\
    return environment\
  end\
  _with_0.configureStyleEnvironment = function(self, environment)\
    if environment == nil then\
      environment = ChunkEnvironment:new()\
    end\
    if not (type(environment) == \"table\") then\
      error(\"bad argument #1 to 'configureStyleEnvironment' (expected ChunkEnvironment)\")\
    end\
    self:dispatch(\"configureStyleEnvironment\", environment)\
    return environment\
  end\
  _with_0.configureTransformers = function(self, transformers)\
    if transformers == nil then\
      transformers = Transformers:new()\
    end\
    if not (type(transformers) == \"table\") then\
      error(\"bad argument #1 to 'configureTransformers' (expected Transformers)\")\
    end\
    self:dispatch(\"configureTransformers\", transformers)\
    return transformers\
  end\
  _with_0.processConfiguration = function(self, configuration)\
    if not (type(configuration) == \"table\") then\
      error(\"bad argument #1 to 'processConfiguration' (expected table)\")\
    end\
    local err\
    local _list_0 = self.plugins\
    for _index_0 = 1, #_list_0 do\
      local plugin = _list_0[_index_0]\
      if plugin.exports.processConfiguration and configuration[plugin.name] ~= nil then\
        err = plugin.exports.processConfiguration(configuration[plugin.name])\
        if err then\
          error(\"bad dispatch to 'processConfiguration' (malformed configuration)\\n\" .. tostring(err))\
        end\
      end\
    end\
  end\
  PluginManager = _with_0\
end",
['novacbn/lunarbook/api/Theme'] = "local loadstring, pcall, setfenv, type\
do\
  local _obj_0 = _G\
  loadstring, pcall, setfenv, type = _obj_0.loadstring, _obj_0.pcall, _obj_0.setfenv, _obj_0.type\
end\
local concat, insert\
do\
  local _obj_0 = table\
  concat, insert = _obj_0.concat, _obj_0.insert\
end\
local Object\
Object = require(\"core\").Object\
local basename, extname, join\
do\
  local _obj_0 = require(\"path\")\
  basename, extname, join = _obj_0.basename, _obj_0.extname, _obj_0.join\
end\
local decode\
decode = dependency(\"novacbn/properties/exports\").decode\
local createHash\
createHash = dependency(\"novacbn/luvit-extras/crypto\").createHash\
local VirtualFileSystem\
VirtualFileSystem = dependency(\"novacbn/luvit-extras/vfs\").VirtualFileSystem\
local FileSystemAdapter\
FileSystemAdapter = dependency(\"novacbn/luvit-extras/adapters/FileSystemAdapter\").FileSystemAdapter\
local layoutViz = dependency(\"novacbn/lunarviz/layout\")\
local moonscript = require(\"moonscript/base\")\
local styleViz = dependency(\"novacbn/lunarviz/style\")\
local merge\
merge = dependency(\"novacbn/lunarbook/lib/utilities/table\").merge\
local isfileSync\
isfileSync = dependency(\"novacbn/lunarbook/lib/utilities/vfs\").isfileSync\
local ThemeConfig\
ThemeConfig = dependency(\"novacbn/lunarbook/schemas/ThemeConfig\").ThemeConfig\
local LoadedComponent\
LoadedComponent = function(hash, layout, script, style)\
  return {\
    hash = hash,\
    layout = layout,\
    script = script,\
    style = style\
  }\
end\
do\
  local _with_0 = Object:extend()\
  _with_0.cache = nil\
  _with_0.configuration = nil\
  _with_0.includedAssets = nil\
  _with_0.layoutEnvironment = nil\
  _with_0.scriptEnvironment = nil\
  _with_0.vfs = nil\
  _with_0.initialize = function(self, directory, configuration)\
    if configuration == nil then\
      configuration = { }\
    end\
    if not (type(directory) == \"string\") then\
      error(\"bad argument #1 to 'initialize' (expected string)\")\
    end\
    if not (type(configuration) == \"table\") then\
      error(\"bad argument #2 to 'initialize' (expected table)\")\
    end\
    self.vfs = VirtualFileSystem:new()\
    self.vfs:mount(\"theme\", FileSystemAdapter:new(directory))\
    if isfileSync(self.vfs, \"theme://theme.mprop\") then\
      local contents = self.vfs:readFileSync(\"theme://theme.mprop\")\
      local config = decode(contents, {\
        propertiesEncoder = \"moonscript\"\
      })\
      if config then\
        configuration = merge(configuration, config)\
      end\
    end\
    self.cache = { }\
    local err\
    self.configuration, err = ThemeConfig:transform(configuration)\
    if err then\
      return error(\"bad dispatch to 'initialize' (malformed theme config)\\n\" .. tostring(err))\
    end\
  end\
  _with_0.getIncludedAssets = function(self)\
    if not (self.includedAssets) then\
      self.includedAssets = { }\
      local _list_0 = self.configuration.assets\
      for _index_0 = 1, #_list_0 do\
        local asset = _list_0[_index_0]\
        if not (isfileSync(self.vfs, \"theme://assets/\" .. tostring(asset))) then\
          error(\"bad dispatch to 'getIncludedAssets' (missing '\" .. tostring(asset) .. \"')\")\
        end\
        insert(self.includedAssets, {\
          contents = self.vfs:readFileSync(\"theme://assets/\" .. tostring(asset)),\
          name = asset\
        })\
      end\
    end\
    return self.includedAssets\
  end\
  _with_0.getComputedStyle = function(self, format, environment)\
    local computed = { }\
    local _list_0 = self.vfs:readdirSync(\"theme://components\")\
    for _index_0 = 1, #_list_0 do\
      local file = _list_0[_index_0]\
      local component = self:loadComponent(basename(file, extname(file)))\
      if component.style then\
        insert(computed, component.style(format, environment))\
      end\
    end\
    return concat(computed, \"\\n\")\
  end\
  _with_0.loadComponent = function(self, name)\
    local file = \"theme://components/\" .. tostring(name) .. \".moon\"\
    if not (isfileSync(self.vfs, file)) then\
      error(\"bad argument #1 to 'loadComponent' (missing component)\")\
    end\
    if not (self.cache[name]) then\
      local hash = createHash(name, \"SHA1\")\
      local contents = self.vfs:readFileSync(file)\
      local component, err = moonscript.loadstring(contents, file)\
      if not (component) then\
        error(\"bad argument #1 to 'loadComponent' (failed to parse)\\n\" .. tostring(err))\
      end\
      local environment = self:makeComponentEnvironment(hash)\
      setfenv(component, environment)\
      local success\
      success, err = pcall(component)\
      if not (success) then\
        error(\"bad argument #1 to 'loadComponent' (failed to dispatch)\\n\" .. tostring(err))\
      end\
      if not (environment.layout) then\
        error(\"bad argument #1 to 'loadComponent' (component is missing layout)\")\
      end\
      self.cache[name] = LoadedComponent(hash, environment.layout, environment.script, environment.style)\
    end\
    return self.cache[name]\
  end\
  _with_0.makeComponentEnvironment = function(self, hash)\
    local environment\
    environment = {\
      include = function(name)\
        return self:loadComponent(name).layout\
      end,\
      Layout = function(chunk)\
        if environment.layout then\
          error(\"bad dispatch to 'Layout' (layout already set)\")\
        end\
        environment.layout = function(...)\
          return layoutViz.parse(chunk, hash, self.layoutEnvironment, self.configuration.environment, ...)\
        end\
      end,\
      Style = function(chunk)\
        if environment.style then\
          error(\"bad dispatch to 'Style' (style already set)\")\
        end\
        environment.style = function(format, styleEnv, ...)\
          local syntaxtree = styleViz.parse(chunk, hash, styleEnv, self.configuration.environment, ...)\
          return styleViz.compile(syntaxtree, format)\
        end\
      end\
    }\
    return environment\
  end\
  _with_0.render = function(self, name, format, environment, state)\
    if environment == nil then\
      environment = { }\
    end\
    if state == nil then\
      state = { }\
    end\
    environment = { }\
    if not (type(name) == \"string\") then\
      error(\"bad argument #1 to 'parseComponent' (expected string)\")\
    end\
    if not (type(format) == \"boolean\") then\
      error(\"bad argument #2 to 'parseComponent' (expected boolean)\")\
    end\
    if not (type(environment) == \"table\") then\
      error(\"bad argument #3 to 'parseComponent' (expected table)\")\
    end\
    if not (type(state) == \"table\") then\
      error(\"bad argument #4 to 'parseComponent' (expected table)\")\
    end\
    self.layoutEnvironment = environment\
    local component = self:loadComponent(name)\
    local syntaxtree = component.layout(state)\
    return layoutViz.compile(syntaxtree, format)\
  end\
  Theme = _with_0\
end",
['novacbn/lunarbook/api/Transformers'] = "local type\
type = _G.type\
local lower\
lower = string.lower\
local insert\
insert = table.insert\
local Object\
Object = require(\"core\").Object\
local endswith\
endswith = dependency(\"novacbn/lunarbook/lib/utilities/string\").endswith\
local pass\
pass = function(...)\
  return ...\
end\
local RegisteredTransformer\
RegisteredTransformer = function(ext, transform, post)\
  return {\
    ext = ext,\
    post = post,\
    transform = transform\
  }\
end\
do\
  local _with_0 = Object:extend()\
  _with_0.fragmentTransformers = nil\
  _with_0.initialize = function(self)\
    self.fragmentTransformers = { }\
  end\
  _with_0.registerFragment = function(self, ext, transform, post)\
    if post == nil then\
      post = pass\
    end\
    if not (type(ext) == \"string\") then\
      error(\"bad argument #1 to 'registerFragment' (expected string)\")\
    end\
    if not (type(transform) == \"function\") then\
      error(\"bad argument #2 to 'registerFragment' (expected function)\")\
    end\
    if not (type(post) == \"function\") then\
      error(\"bad argument #3 to 'registerFragment' (expected function)\")\
    end\
    ext = lower(ext)\
    if self.fragmentTransformers[ext] then\
      error(\"bad argument #1 to 'registerFragment' (pre-existing transformer)\")\
    end\
    return insert(self.fragmentTransformers, RegisteredTransformer(ext, transform, post))\
  end\
  _with_0.processFragment = function(self, file, inDev, contents)\
    if not (type(file) == \"string\") then\
      error(\"bad argument #1 to 'processFragment' (expected string)\")\
    end\
    if not (type(inDev) == \"boolean\") then\
      error(\"bad argument #2 to 'processFragment' (expected boolean)\")\
    end\
    if not (type(contents) == \"string\") then\
      error(\"bad argument #3 to 'processFragment' (expected string)\")\
    end\
    local selectedTransformer\
    file = lower(file)\
    local _list_0 = self.fragmentTransformers\
    for _index_0 = 1, #_list_0 do\
      local transformer = _list_0[_index_0]\
      if endswith(file, transformer.ext) then\
        selectedTransformer = transformer\
        break\
      end\
    end\
    if not (selectedTransformer) then\
      error(\"bad argument #1 to 'processFragment' (unexpected extension)\")\
    end\
    contents = selectedTransformer.transform(inDev, contents)\
    contents = selectedTransformer.post(inDev, contents)\
    return contents\
  end\
  Transformers = _with_0\
end",
['novacbn/lunarbook/commands/export'] = "local mkdirSync\
mkdirSync = require(\"fs\").mkdirSync\
local join\
join = require(\"path\").join\
local isfileSync, isdirSync\
do\
  local _obj_0 = dependency(\"novacbn/luvit-extras/fs\")\
  isfileSync, isdirSync = _obj_0.isfileSync, _obj_0.isdirSync\
end\
local Book\
Book = dependency(\"novacbn/lunarbook/api/Book\").Book\
local BOOK_HOME\
BOOK_HOME = dependency(\"novacbn/lunarbook/lib/constants\").BOOK_HOME\
TEXT_COMMAND_DESCRIPTION = \"Builds and exports the LunarBook\"\
TEXT_COMMAND_SYNTAX = \"[book directory] [build directory]\"\
TEXT_COMMAND_EXAMPLES = {\
  \"./book\"\
}\
executeCommand = function(options, bookDirectory, buildDirectory)\
  if bookDirectory == nil then\
    bookDirectory = \"book\"\
  end\
  if buildDirectory == nil then\
    buildDirectory = \"dist\"\
  end\
  if not (isdirSync(buildDirectory)) then\
    mkdirSync(buildDirectory)\
  end\
  local book = Book:new(bookDirectory, buildDirectory, BOOK_HOME.theme)\
  book:processBook()\
  return print(\"LunarBook was exported to '\" .. tostring(buildDirectory) .. \"'\")\
end",
['novacbn/lunarbook/commands/watch'] = "local resolve\
resolve = require(\"path\").resolve\
local Theme\
Theme = dependency(\"novacbn/lunarbook/api/Theme\").Theme\
local SERVER_ROUTES = { }\
TEXT_COMMAND_DESCRIPTION = \"Starts a hot-reloading webserver\"\
TEXT_COMMAND_SYNTAX = \"[directory]\"\
TEXT_COMMAND_EXAMPLES = {\
  \"./book\"\
}\
configureCommand = function(command, options)\
  do\
    local _with_0 = options\
    _with_0:string(\"server-host\", \"Sets the webserver's host\", \"0.0.0.0\")\
    _with_0:number(\"server-port\", \"Sets the webserver's port\", 9090)\
    return _with_0\
  end\
end\
local config = {\
  environment = {\
    title = \"LunarBook\"\
  },\
  omnibar = {\
    {\
      text = \"Guide\",\
      link = \"/\"\
    },\
    {\
      text = \"Configuration Reference\",\
      link = \"/config\"\
    },\
    {\
      text = \"Theming\",\
      link = \"/themes\"\
    }\
  }\
}\
executeCommand = function(options, directory)\
  if directory == nil then\
    directory = \"book\"\
  end\
  local theme = Theme:new(\".lunarbook/theme\", config)\
  local render = theme:parseComponent(\"Index\", { })\
  print(\"\\nIndex\")\
  for k, v in pairs(render) do\
    print(k, v)\
  end\
end",
['novacbn/lunarbook/lib/constants'] = "local cwd\
cwd = process.cwd\
local join\
join = require(\"path\").join\
do\
  local _tbl_0 = { }\
  local _list_0 = {\
    \".html\",\
    \".md\"\
  }\
  for _index_0 = 1, #_list_0 do\
    local fragmentType = _list_0[_index_0]\
    _tbl_0[fragmentType] = true\
  end\
  ALLOWED_FRAGMENT_TYPES = _tbl_0\
end\
do\
  local _with_0 = { }\
  _with_0.home = cwd()\
  _with_0.data = join(_with_0.home, \".lunarbook\")\
  _with_0.assets = join(_with_0.data, \"assets\")\
  _with_0.theme = join(_with_0.data, \"theme\")\
  _with_0.plugins = join(_with_0.data, \"plugins\")\
  _with_0.configuration = join(_with_0.data, \"configuration.mprop\")\
  BOOK_HOME = _with_0\
end\
do\
  local _with_0 = { }\
  _with_0.scheme = \"build://\"\
  _with_0.assets = _with_0.scheme .. \"assets\"\
  _with_0.fragments = _with_0.assets .. \"/fragments\"\
  _with_0.scripts = _with_0.assets .. \"/scripts\"\
  _with_0.styles = _with_0.assets .. \"/styles\"\
  BUILD_DIRS = _with_0\
end",
['novacbn/lunarbook/lib/utilities'] = "local parse\
parse = dependency(\"msva/htmlparser/exports\").parse\
PATTERN_HTML_ATTRIBUTES = \"%w%s%-='\\\"\"\
PATTERN_HTML_STRING = \"%w%s%p\"\
PATTERN_SECTION_EXTRACT = \"<h2[${PATTERN_HTML_ATTRIBUTES}]*>([\" .. tostring(PATTERN_HTML_STRING) .. \"]+)</h2>\"\
PATTERN_TITLE_EXTRACT = \"<h1[${PATTERN_HTML_ATTRIBUTES}]*>([\" .. tostring(PATTERN_HTML_STRING) .. \"]+)</h1>\"\
local TABLE_HEADER_TAGS = {\
  \"h1\",\
  \"h2\",\
  \"h3\",\
  \"h4\",\
  \"h5\",\
  \"h6\"\
}\
extractTitle = function(value)\
  local root = parse(value)\
  for _index_0 = 1, #TABLE_HEADER_TAGS do\
    local tag = TABLE_HEADER_TAGS[_index_0]\
    local elements = root:select(tag)\
    if #elements > 0 then\
      return elements[1]:getcontent()\
    end\
  end\
end\
extractSections = function(value)\
  local root = parse(value)\
  local titleSpotted = false\
  for _index_0 = 1, #TABLE_HEADER_TAGS do\
    local tag = TABLE_HEADER_TAGS[_index_0]\
    local elements = root:select(tag)\
    if titleSpotted then\
      local _accum_0 = { }\
      local _len_0 = 1\
      for _index_1 = 1, #elements do\
        local element = elements[_index_1]\
        _accum_0[_len_0] = element:getcontent()\
        _len_0 = _len_0 + 1\
      end\
      return _accum_0\
    end\
    titleSpotted = #elements > 0\
  end\
end",
['novacbn/lunarbook/lib/utilities/string'] = "local gsub, lower, sub\
do\
  local _obj_0 = string\
  gsub, lower, sub = _obj_0.gsub, _obj_0.lower, _obj_0.sub\
end\
dashcase = function(value)\
  return gsub(value, \"%u\", function(self)\
    return \"-\" .. lower(self)\
  end)\
end\
endswith = function(value, postfix)\
  return sub(value, -1 * #postfix) == postfix\
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
['novacbn/lunarbook/lib/utilities/table'] = "local pairs, type\
do\
  local _obj_0 = _G\
  pairs, type = _obj_0.pairs, _obj_0.type\
end\
merge = function(target, source)\
  for key, value in pairs(source) do\
    if type(target[key]) == \"table\" and type(value) == \"table\" then\
      merge(target[key], value)\
    elseif target[key] == nil then\
      target[key] = value\
    end\
  end\
  return target\
end",
['novacbn/lunarbook/lib/utilities/vfs'] = "local type, select\
do\
  local _obj_0 = _G\
  type, select = _obj_0.type, _obj_0.select\
end\
local match\
match = string.match\
local dirname\
dirname = require(\"path\").dirname\
isdirSync = function(vfs, path)\
  if not (type(vfs) == \"table\") then\
    error(\"bad argument #1 to 'isdirSync' (expected VirtualFileSystem)\")\
  end\
  if not (type(path) == \"string\") then\
    error(\"bad argument #2 to 'isdirSync' (expected string)\")\
  end\
  return vfs:accessSync(path) and vfs:statSync(path).type == \"directory\"\
end\
isfileSync = function(vfs, path)\
  if not (type(vfs) == \"table\") then\
    error(\"bad argument #1 to 'isfileSync' (expected VirtualFileSystem)\")\
  end\
  if not (type(path) == \"string\") then\
    error(\"bad argument #2 to 'isfileSync' (expected string)\")\
  end\
  return vfs:accessSync(path) and vfs:statSync(path).type == \"file\"\
end\
join = function(parent, path, ...)\
  if not (type(parent) == \"string\") then\
    error(\"bad argument #1 to 'join' (expected string)\")\
  end\
  if not (type(path) == \"string\") then\
    error(\"bad argument #2 to 'join' (expected string)\")\
  end\
  local result\
  if #path > 0 then\
    if #parent > 0 then\
      result = parent .. \"/\" .. path\
    else\
      result = path\
    end\
  else\
    result = parent\
  end\
  if not (select(\"#\", ...) == 0) then\
    return join(result, ...)\
  end\
  return result\
end\
mkdirpSync = function(vfs, directory)\
  if not (type(vfs) == \"table\") then\
    error(\"bad argument #1 to 'mkdirpSync' (expected VirtualFileSystem)\")\
  end\
  if not (type(directory) == \"string\") then\
    error(\"bad argument #2 to 'mkdirpSync' (expected string)\")\
  end\
  local parent = dirname(directory)\
  if match(parent, \"^[%w]+://\") then\
    if not (vfs:accessSync(parent)) then\
      mkdirpSync(vfs, parent)\
    end\
  end\
  if not (vfs:accessSync(directory)) then\
    return vfs:mkdirSync(directory)\
  end\
end",
['novacbn/lunarbook/main'] = "local CommandOps\
CommandOps = dependency(\"novacbn/command-ops/CommandOps\").CommandOps\
local APPLICATION_SUB_COMMANDS = {\
  export = dependency(\"novacbn/lunarbook/commands/export\"),\
  watch = dependency(\"novacbn/lunarbook/commands/watch\")\
}\
local commandOps = CommandOps(\"Lunarbook Documentation Generator\", \"lunarbook\", \"0.1.0\")\
for name, exports in pairs(APPLICATION_SUB_COMMANDS) do\
  local command = commandOps:command(name, exports.TEXT_COMMAND_DESCRIPTION, exports.executeCommand)\
  if exports.TEXT_COMMAND_SYNTAX then\
    command:setSyntax(exports.TEXT_COMMAND_SYNTAX)\
  end\
  if exports.TEXT_COMMAND_EXAMPLES then\
    local _list_0 = exports.TEXT_COMMAND_EXAMPLES\
    for _index_0 = 1, #_list_0 do\
      local example = _list_0[_index_0]\
      command:addExample(example)\
    end\
  end\
  if exports.configureCommand then\
    exports.configureCommand(command, command.options)\
  end\
end\
return commandOps:exec((function()\
  local _accum_0 = { }\
  local _len_0 = 1\
  local _list_0 = process.argv\
  for _index_0 = 2, #_list_0 do\
    local argument = _list_0[_index_0]\
    _accum_0[_len_0] = argument\
    _len_0 = _len_0 + 1\
  end\
  return _accum_0\
end)())",
['novacbn/lunarbook/schemas/LunarConfig'] = "local types\
types = dependency(\"leafo/tableshape/exports\").types\
local ThemeConfig\
ThemeConfig = dependency(\"novacbn/lunarbook/schemas/ThemeConfig\").ThemeConfig\
LunarConfig = types.shape({\
  theme = types.any + types[\"nil\"] / { },\
  plugins = types.map_of(types.string, types.any) + types[\"nil\"] / { }\
})",
['novacbn/lunarbook/schemas/ThemeConfig'] = "local types\
types = dependency(\"leafo/tableshape/exports\").types\
ThemeConfig = types.shape({\
  assets = types.array_of(types.string) + types[\"nil\"] / { },\
  environment = types.shape({\
    basePath = types.string + types[\"nil\"] / \"/\",\
    omnibar = types.array_of(types.shape({\
      link = types.string,\
      text = types.string\
    })) + types[\"nil\"] / { },\
    title = types.string + types[\"nil\"] / \"LunarBook\",\
    scriptPath = types.string + types[\"nil\"] / \"assets/scripts/lunarbook.components.js\",\
    stylePath = types.string + types[\"nil\"] / \"assets/styles/lunarbook.components.css\"\
  }, {\
    extra_fields = types.map_of(types.any, types.any)\
  })\
})",
['novacbn/lunarviz/constants'] = "local makeTruthyMap\
makeTruthyMap = dependency(\"novacbn/lunarviz/utilities\").makeTruthyMap\
SELECTOR_PSEUDO_CLASSES = makeTruthyMap({\
  \"active\",\
  \"checked\",\
  \"default\",\
  \"defined\",\
  \"disabled\",\
  \"empty\",\
  \"enabled\",\
  \"first\",\
  \"first-child\",\
  \"first-of-type\",\
  \"focus\",\
  \"focus-within\",\
  \"host\",\
  \"hover\",\
  \"indeterminate\",\
  \"in-range\",\
  \"invalid\",\
  \"last-child\",\
  \"last-of-type\",\
  \"left\",\
  \"link\",\
  \"only-child\",\
  \"only-of-type\",\
  \"optional\",\
  \"out-of-range\",\
  \"read-only\",\
  \"read-write\",\
  \"required\",\
  \"right\",\
  \"scope\",\
  \"target\",\
  \"valid\",\
  \"visited\"\
})\
SELECTOR_PSEUDO_ELEMENTS = makeTruthyMap({\
  \"after\",\
  \"backdrop\",\
  \"before\",\
  \"cue\",\
  \"first-letter\",\
  \"first-line\"\
})\
ELEMENT_VOID_TAGS = makeTruthyMap({\
  \"area\",\
  \"base\",\
  \"br\",\
  \"col\",\
  \"command\",\
  \"embed\",\
  \"hr\",\
  \"img\",\
  \"input\",\
  \"keygen\",\
  \"link\",\
  \"meta\",\
  \"param\",\
  \"source\",\
  \"track\",\
  \"wbr\"\
})",
['novacbn/lunarviz/layout'] = "local pairs, type\
do\
  local _obj_0 = _G\
  pairs, type = _obj_0.pairs, _obj_0.type\
end\
local rep\
rep = string.rep\
local concat, insert\
do\
  local _obj_0 = table\
  concat, insert = _obj_0.concat, _obj_0.insert\
end\
local ELEMENT_VOID_TAGS\
ELEMENT_VOID_TAGS = dependency(\"novacbn/lunarviz/constants\").ELEMENT_VOID_TAGS\
local dashcase, filter\
do\
  local _obj_0 = dependency(\"novacbn/lunarviz/utilities\")\
  dashcase, filter = _obj_0.dashcase, _obj_0.filter\
end\
local ASTRoot\
ASTRoot = function(name, nodes)\
  if nodes == nil then\
    nodes = { }\
  end\
  return {\
    name = name,\
    isRoot = true,\
    nodes = nodes\
  }\
end\
local ASTAttribute\
ASTAttribute = function(name, value)\
  return {\
    name = name,\
    value = value\
  }\
end\
local ASTElementNode\
ASTElementNode = function(tag, attributes, children, isVoidTag)\
  if attributes == nil then\
    attributes = { }\
  end\
  if children == nil then\
    children = { }\
  end\
  if isVoidTag == nil then\
    isVoidTag = false\
  end\
  return {\
    attributes = attributes,\
    isVoidTag = isVoidTag,\
    nodes = children,\
    tag = tag\
  }\
end\
local ASTTextNode\
ASTTextNode = function(text)\
  return {\
    isTextNode = true,\
    text = text\
  }\
end\
local ChunkMeta = {\
  __index = function(self, tag)\
    if tag == \"raw\" then\
      return function(value)\
        return insert(self.__nodes, ASTTextNode(value))\
      end\
    end\
    tag = dashcase(tag)\
    local astnode = ASTElementNode(tag, nil, nil, ELEMENT_VOID_TAGS[tag] or false)\
    local parentNodes = self.__nodes\
    insert(parentNodes, astnode)\
    return function(attributes, value)\
      if type(attributes) == \"function\" or type(attributes) == \"string\" then\
        value = attributes\
        attributes = nil\
      end\
      if attributes then\
        for key, avalue in pairs(attributes) do\
          if not (type(key) == \"string\") then\
            error(\"malformed attribute name '\" .. tostring(key) .. \"'\")\
          end\
          if not (type(avalue) == \"string\" or type(avalue) == \"boolean\") then\
            error(\"malformed attribute value for '\" .. tostring(key) .. \"'\")\
          end\
          key = dashcase(key)\
          insert(astnode.attributes, ASTAttribute(key, avalue))\
        end\
      end\
      if type(value) == \"string\" then\
        return insert(astnode.nodes, ASTTextNode(value))\
      elseif type(value) == \"function\" then\
        self.__nodes = astnode.nodes\
        value()\
        self.__nodes = parentNodes\
      end\
    end\
  end\
}\
local filterText\
filterText = function(value)\
  return value.isTextNode == nil\
end\
compile = function(syntaxtree, format)\
  if format == nil then\
    format = false\
  end\
  if not (type(syntaxtree) == \"table\") then\
    error(\"bad argument #1 to 'compile' (expected ASTRoot)\")\
  end\
  if not (type(format) == \"boolean\") then\
    error(\"bad argument #2 to 'compile' (expected boolean)\")\
  end\
  local buffer = { }\
  local index = 0\
  local append\
  append = function(value, next, ...)\
    index = index + 1\
    buffer[index] = value\
    if next then\
      return append(next, ...)\
    end\
  end\
  local traverse\
  traverse = function(parent, name, level)\
    local _list_0 = parent.nodes\
    for _index_0 = 1, #_list_0 do\
      local _continue_0 = false\
      repeat\
        local node = _list_0[_index_0]\
        if node.isTextNode then\
          append(node.text)\
          _continue_0 = true\
          break\
        end\
        if node.isRoot then\
          traverse(node, node.name, level)\
          _continue_0 = true\
          break\
        end\
        if format then\
          append(rep(\"\\t\", level))\
        end\
        append(\"<\", node.tag)\
        local _list_1 = node.attributes\
        for _index_1 = 1, #_list_1 do\
          local _continue_1 = false\
          repeat\
            local attribute = _list_1[_index_1]\
            if type(attribute.value) == \"boolean\" and attribute.value then\
              append(attribute.name)\
              _continue_1 = true\
              break\
            end\
            append(\" \", attribute.name, \"='\", attribute.value, \"'\")\
            _continue_1 = true\
          until true\
          if not _continue_1 then\
            break\
          end\
        end\
        append(\" data-layout='\", name, \"'\", parent.isRoot and \" data-root\")\
        if node.isVoidTag then\
          append(\" />\", format and \"\\n\")\
          _continue_0 = true\
          break\
        end\
        append(\">\", format and #filter(node.nodes, filterText) > 0 and \"\\n\")\
        traverse(node, name, format and level + 1)\
        if format and #filter(node.nodes, filterText) > 0 then\
          append(rep(\"\\t\", level))\
        end\
        append(\"</\", node.tag, \">\", format and \"\\n\")\
        _continue_0 = true\
      until true\
      if not _continue_0 then\
        break\
      end\
    end\
  end\
  traverse(syntaxtree, syntaxtree.name, 0)\
  return concat(buffer, \"\")\
end\
parse = function(chunk, name, chunkenv, ...)\
  if chunkenv == nil then\
    chunkenv = { }\
  end\
  if not (type(chunk) == \"function\") then\
    error(\"bad argument #1 to 'parse' (expected function)\")\
  end\
  if not (type(name) == \"string\") then\
    error(\"bad argument #2 to 'parse' (expected string)\")\
  end\
  if not (type(chunkenv) == \"table\") then\
    error(\"bad argument #3 to 'parse' (expected table)\")\
  end\
  local parentNodes = chunkenv.__nodes\
  name = dashcase(name)\
  local syntaxtree = ASTRoot(name)\
  if parentNodes then\
    insert(parentNodes, syntaxtree)\
  end\
  chunkenv.__nodes = syntaxtree.nodes\
  setmetatable(chunkenv, ChunkMeta)\
  setfenv(chunk, chunkenv)\
  chunk(...)\
  if parentNodes then\
    chunkenv.__nodes = parentNodes\
  else\
    return syntaxtree\
  end\
end",
['novacbn/lunarviz/style'] = "local getmetatable, ipairs, pairs, setfenv, setmetatable, type\
do\
  local _obj_0 = _G\
  getmetatable, ipairs, pairs, setfenv, setmetatable, type = _obj_0.getmetatable, _obj_0.ipairs, _obj_0.pairs, _obj_0.setfenv, _obj_0.setmetatable, _obj_0.type\
end\
local concat, insert, sort\
do\
  local _obj_0 = table\
  concat, insert, sort = _obj_0.concat, _obj_0.insert, _obj_0.sort\
end\
local SELECTOR_PSEUDO_CLASSES, SELECTOR_PSEUDO_ELEMENTS\
do\
  local _obj_0 = dependency(\"novacbn/lunarviz/constants\")\
  SELECTOR_PSEUDO_CLASSES, SELECTOR_PSEUDO_ELEMENTS = _obj_0.SELECTOR_PSEUDO_CLASSES, _obj_0.SELECTOR_PSEUDO_ELEMENTS\
end\
local dashcase\
dashcase = dependency(\"novacbn/lunarviz/utilities\").dashcase\
local ASTRoot\
ASTRoot = function(name)\
  return {\
    name = name,\
    rules = { }\
  }\
end\
local ASTProperty\
ASTProperty = function(name, value)\
  return {\
    name = name,\
    value = value\
  }\
end\
local ASTRule\
ASTRule = function(target, modifiers, parents, properties)\
  if modifiers == nil then\
    modifiers = { }\
  end\
  if parents == nil then\
    parents = { }\
  end\
  if properties == nil then\
    properties = { }\
  end\
  return {\
    modifiers = modifiers,\
    parents = parents,\
    properties = properties,\
    target = target\
  }\
end\
local sortProperties\
sortProperties = function(a, b)\
  return a.name < b.name\
end\
local RuleMeta\
RuleMeta = {\
  __call = function(self, properties)\
    if not (type(properties) == \"table\" and getmetatable(properties) == nil) then\
      error(\"malformed properties table\")\
    end\
    local sorted = { }\
    for key, value in pairs(properties) do\
      if not (type(key) == \"string\") then\
        error(\"malformed properties key '\" .. tostring(key) .. \"'\")\
      end\
      if not (type(value) == \"string\" or type(value) == \"number\") then\
        error(\"malformed properties value '\" .. tostring(key) .. \"'\")\
      end\
      key = dashcase(key)\
      insert(sorted, ASTProperty(key, value))\
    end\
    sort(sorted, sortProperties)\
    self.__ast.properties = sorted\
    insert(self.__parent, self.__ast)\
    return self\
  end,\
  __index = function(self, key)\
    if not (type(key) == \"string\") then\
      error(\"malformed modifier key '\" .. tostring(key) .. \"'\")\
    end\
    key = dashcase(key)\
    local ast = self.__ast\
    if SELECTOR_PSEUDO_CLASSES[key] then\
      insert(ast.modifiers, \":\" .. key)\
    elseif SELECTOR_PSEUDO_ELEMENTS[key] then\
      insert(ast.modifiers, \"::\" .. key)\
    else\
      insert(ast.modifiers, \".\" .. key)\
    end\
    return self\
  end,\
  __mul = function(self, rule)\
    if not (type(rule) == \"table\" and getmetatable(rule) == RuleMeta) then\
      error(\"malformed rule modifier\")\
    end\
    local modifier = \" \" .. rule.__ast.target .. concat(rule.__ast.modifiers, \"\")\
    rule.__ast.target = self.__ast.target\
    rule.__ast.modifiers = self.__ast.modifiers\
    insert(rule.__ast.modifiers, modifier)\
    return rule\
  end\
}\
compile = function(syntaxtree, format)\
  if format == nil then\
    format = false\
  end\
  if not (type(syntaxtree) == \"table\") then\
    error(\"bad argument #1 to 'compile' (expected ASTRoot)\")\
  end\
  if not (type(format) == \"boolean\") then\
    error(\"bad argument #2 to 'compile' (expected boolean)\")\
  end\
  local buffer = { }\
  local index = 0\
  local append\
  append = function(value, next, ...)\
    index = index + 1\
    buffer[index] = value\
    if next then\
      return append(next, ...)\
    end\
  end\
  local _list_0 = syntaxtree.rules\
  for _index_0 = 1, #_list_0 do\
    local rule = _list_0[_index_0]\
    if rule.target == \"root\" then\
      append(\"*[data-root]\")\
    else\
      append(rule.target)\
    end\
    append(\"[data-layout='\", syntaxtree.name, \"']\")\
    local _list_1 = rule.modifiers\
    for _index_1 = 1, #_list_1 do\
      local modifier = _list_1[_index_1]\
      append(modifier)\
    end\
    if format then\
      append(\" \")\
    end\
    append(\"{\")\
    local _list_2 = rule.properties\
    for _index_1 = 1, #_list_2 do\
      local property = _list_2[_index_1]\
      if format then\
        append(\"\\n\\t\")\
      end\
      append(property.name, \": \", property.value, \";\")\
    end\
    append(\"\\n\", \"}\", \"\\n\")\
  end\
  return concat(buffer, \"\")\
end\
parse = function(chunk, name, chunkenv, ...)\
  if chunkenv == nil then\
    chunkenv = { }\
  end\
  if not (type(chunk) == \"function\") then\
    error(\"bad argument #1 to 'parse' (expected function)\")\
  end\
  if not (type(name) == \"string\") then\
    error(\"bad argument #2 to 'parse' (expected string)\")\
  end\
  if not (type(chunkenv) == \"table\") then\
    error(\"bad argument #3 to 'parse' (expected table)\")\
  end\
  name = dashcase(name)\
  local syntaxtree = ASTRoot(name)\
  local environment = {\
    __index = function(self, key)\
      key = dashcase(key)\
      return setmetatable({\
        __ast = ASTRule(key),\
        __parent = syntaxtree.rules\
      }, RuleMeta)\
    end\
  }\
  setmetatable(chunkenv, environment)\
  setfenv(chunk, chunkenv)\
  chunk(...)\
  return syntaxtree\
end",
['novacbn/lunarviz/utilities'] = "local gsub, lower\
do\
  local _obj_0 = string\
  gsub, lower = _obj_0.gsub, _obj_0.lower\
end\
dashcase = function(value)\
  return gsub(value, \"%u\", function(self)\
    return \"-\" .. lower(self)\
  end)\
end\
makeTruthyMap = function(tbl)\
  local _tbl_0 = { }\
  for _index_0 = 1, #tbl do\
    local value = tbl[_index_0]\
    _tbl_0[value] = true\
  end\
  return _tbl_0\
end\
filter = function(tbl, predicate)\
  local _accum_0 = { }\
  local _len_0 = 1\
  for _index_0 = 1, #tbl do\
    local value = tbl[_index_0]\
    if predicate(value) then\
      _accum_0[_len_0] = value\
      _len_0 = _len_0 + 1\
    end\
  end\
  return _accum_0\
end",
['novacbn/luvit-extras/adapters/FileSystemAdapter'] = "local type\
type = _G.type\
local gsub\
gsub = string.gsub\
local access, accessSync, mkdir, mkdirSync, readdir, readdirSync, readFile, readFileSync, rename, renameSync, rmdir, rmdirSync, stat, statSync, unlink, unlinkSync, writeFile, writeFileSync, walk, walkSync\
do\
  local _obj_0 = require(\"fs\")\
  access, accessSync, mkdir, mkdirSync, readdir, readdirSync, readFile, readFileSync, rename, renameSync, rmdir, rmdirSync, stat, statSync, unlink, unlinkSync, writeFile, writeFileSync, walk, walkSync = _obj_0.access, _obj_0.accessSync, _obj_0.mkdir, _obj_0.mkdirSync, _obj_0.readdir, _obj_0.readdirSync, _obj_0.readFile, _obj_0.readFileSync, _obj_0.rename, _obj_0.renameSync, _obj_0.rmdir, _obj_0.rmdirSync, _obj_0.stat, _obj_0.statSync, _obj_0.unlink, _obj_0.unlinkSync, _obj_0.writeFile, _obj_0.writeFileSync, _obj_0.walk, _obj_0.walkSync\
end\
local normalize, normalizeSeparators, relative, resolve\
do\
  local _obj_0 = require(\"path\")\
  normalize, normalizeSeparators, relative, resolve = _obj_0.normalize, _obj_0.normalizeSeparators, _obj_0.relative, _obj_0.resolve\
end\
local isdirSync\
do\
  local _obj_0 = dependency(\"novacbn/luvit-extras/fs\")\
  isdirSync, walk, walkSync = _obj_0.isdirSync, _obj_0.walk, _obj_0.walkSync\
end\
local VirtualAdapter\
VirtualAdapter = dependency(\"novacbn/luvit-extras/vfs\").VirtualAdapter\
local PATTERN_SANITIZE_ESCAPE = \"%.%.\"\
local PATTERN_SANITIZE_SEPARATORS = \"\\\\\"\
local makeResolvedFunction\
makeResolvedFunction = function(func, isAsync, sanitizeResults)\
  if isAsync == nil then\
    isAsync = false\
  end\
  if sanitizeResults == nil then\
    sanitizeResults = false\
  end\
  if isAsync then\
    return function(self, path, callback)\
      if sanitizeResults then\
        return func(self:resolve(path), function(err, results)\
          return callback(err, self:sanitize(results))\
        end)\
      end\
      return func(self:resolve(path), callback)\
    end\
  end\
  return function(self, path, ...)\
    local results, err = func(self:resolve(path), ...)\
    if sanitizeResults then\
      results = self:sanitize(results)\
    end\
    if err then\
      error(err)\
    end\
    return results\
  end\
end\
do\
  local _with_0 = VirtualAdapter:extend()\
  _with_0.root = nil\
  _with_0.initialize = function(self, root, readOnly)\
    if readOnly == nil then\
      readOnly = false\
    end\
    if not (type(root) == \"string\") then\
      error(\"bad argument #1 to 'initialize' (expected string)\")\
    end\
    root = resolve(root)\
    if not (isdirSync(root)) then\
      error(\"bad argument #1 to 'initialize' (expected directory)\")\
    end\
    if not (type(readOnly) == \"boolean\") then\
      error(\"bad argument #2 to 'initialize' (expected boolean)\")\
    end\
    self.root = root\
    return VirtualAdapter.initialize(self, readOnly)\
  end\
  _with_0.resolve = function(self, path)\
    if gsub(path, PATTERN_SANITIZE_ESCAPE, \"\") ~= path then\
      error(\"bad argument #1 to 'resolve' (unexpected escaping path)\")\
    end\
    return resolve(self.root, normalize(path))\
  end\
  _with_0.sanitize = function(self, path)\
    if not (type(path) == \"string\" or \"table\") then\
      error(\"bad argument #1 'sanitize' (expected string)\")\
    end\
    if type(path) == \"string\" then\
      path = gsub(path, PATTERN_SANITIZE_SEPARATORS, \"/\")\
      return relative(self.root, path)\
    end\
    for index, value in ipairs(path) do\
      value = gsub(value, PATTERN_SANITIZE_SEPARATORS, \"/\")\
      path[index] = relative(self.root, value)\
    end\
    return path\
  end\
  _with_0.access = makeResolvedFunction(access, true)\
  _with_0.accessSync = makeResolvedFunction(accessSync)\
  _with_0.mkdir = makeResolvedFunction(mkdir, true)\
  _with_0.mkdirSync = makeResolvedFunction(mkdirSync)\
  _with_0.readdir = makeResolvedFunction(readdir, true)\
  _with_0.readdirSync = makeResolvedFunction(readdirSync)\
  _with_0.readFile = makeResolvedFunction(readFile, true)\
  _with_0.readFileSync = makeResolvedFunction(readFileSync)\
  _with_0.rmdir = makeResolvedFunction(rmdir, true)\
  _with_0.rmdirSync = makeResolvedFunction(rmdirSync)\
  _with_0.stat = makeResolvedFunction(stat, true)\
  _with_0.statSync = makeResolvedFunction(statSync)\
  _with_0.unlink = makeResolvedFunction(unlink, true)\
  _with_0.unlinkSync = makeResolvedFunction(unlinkSync)\
  _with_0.writeFile = makeResolvedFunction(writeFile, true)\
  _with_0.writeFileSync = makeResolvedFunction(writeFileSync)\
  _with_0.walk = makeResolvedFunction(walk, true, true)\
  _with_0.walkSync = makeResolvedFunction(walkSync, false, true)\
  FileSystemAdapter = _with_0\
end",
['novacbn/luvit-extras/crypto'] = "local type\
type = _G.type\
local lower\
lower = string.lower\
local Buffer\
Buffer = require(\"buffer\").Buffer\
local base64, digest, hex\
do\
  local _obj_0 = require(\"openssl\")\
  base64, digest, hex = _obj_0.base64, _obj_0.digest, _obj_0.hex\
end\
local ENCODING_ALGORITHMS = {\
  buffer = function(data, isEncoding)\
    if isEncoding then\
      return Buffer:new(data)\
    end\
    return data:toString()\
  end,\
  base64 = function(data, isEncoding)\
    return base64(data, isEncoding)\
  end,\
  hex = function(data, isEncoding)\
    return hex(data, isEncoding)\
  end\
}\
local HASHING_ALGORITHMS\
do\
  local _tbl_0 = { }\
  local _list_0 = digest.list()\
  for _index_0 = 1, #_list_0 do\
    local algorithm = _list_0[_index_0]\
    _tbl_0[algorithm] = true\
  end\
  HASHING_ALGORITHMS = _tbl_0\
end\
local isBuffer\
isBuffer = function(value)\
  return type(value) == \"table\" and value.meta == Buffer.meta or false\
end\
createHash = function(data, algorithm, encoding)\
  if encoding == nil then\
    encoding = \"hex\"\
  end\
  if not (isBuffer(data) or type(data) == \"string\") then\
    error(\"bad argument #1 to 'createHash' (expected string)\")\
  end\
  if not (type(data) == \"string\") then\
    error(\"bad argument #2 to 'createHash' (expected string)\")\
  end\
  if not (HASHING_ALGORITHMS[algorithm]) then\
    error(\"bad argument #2 to 'createHash' (unexpected algorithm)\")\
  end\
  if isBuffer(data) then\
    data = data:toString()\
  end\
  return encodeData(digest.digest(algorithm, data, true), encoding)\
end\
decodeData = function(data, encoding)\
  if not (isBuffer(data) or type(data) == \"string\") then\
    error(\"bad argument #1 to 'decodeData' (expected string)\")\
  end\
  if not (type(encoding) == \"string\") then\
    error(\"bad argument #2 to 'decodeData' (expected string)\")\
  end\
  encoding = lower(encoding)\
  if not (ENCODING_ALGORITHMS[encoding]) then\
    error(\"bad argument #2 to 'decodeData' (unexpected encoding)\")\
  end\
  if encoding == \"buffer\" then\
    if not (isBuffer(data)) then\
      error(\"bad argument #1 to 'decodeData' (expected Buffer)\")\
    end\
  elseif isBuffer(data) then\
    data = data:toString()\
  end\
  return ENCODING_ALGORITHMS[encoding](data, false)\
end\
encodeData = function(data, encoding)\
  if not (isBuffer(data) or type(data) == \"string\") then\
    error(\"bad argument #1 to 'encodeData' (expected string)\")\
  end\
  if not (type(encoding) == \"string\") then\
    error(\"bad argument #2 to 'encodeData' (expected string)\")\
  end\
  encoding = lower(encoding)\
  if not (ENCODING_ALGORITHMS[encoding]) then\
    error(\"bad argument #2 to 'encodeData' (unexpected encoding)\")\
  end\
  if encoding == \"buffer\" then\
    if not (type(data) == \"string\") then\
      error(\"bad argument #1 to 'encodeData' (expected string)\")\
    end\
  elseif isBuffer(data) then\
    data = data:toString()\
  end\
  return ENCODING_ALGORITHMS[encoding](data, true)\
end",
['novacbn/luvit-extras/fs'] = "local ipairs, pairs, type\
do\
  local _obj_0 = _G\
  ipairs, pairs, type = _obj_0.ipairs, _obj_0.pairs, _obj_0.type\
end\
local insert\
insert = table.insert\
local access, accessSync, readdir, readdirSync, stat, statSync\
do\
  local _obj_0 = require(\"fs\")\
  access, accessSync, readdir, readdirSync, stat, statSync = _obj_0.access, _obj_0.accessSync, _obj_0.readdir, _obj_0.readdirSync, _obj_0.stat, _obj_0.statSync\
end\
local join\
join = require(\"path\").join\
local setTimeout\
setTimeout = require(\"timer\").setTimeout\
local nextTick\
nextTick = process.nextTick\
local handleStat\
handleStat = function(path, check, callback)\
  access(path, function(err)\
    if err then\
      return callback(err, false)\
    end\
    return stat(path, function(err, stats)\
      if err or stats.type ~= check then\
        return callback(err, false)\
      end\
      return callback(nil, true)\
    end)\
  end)\
  return nil\
end\
local DirectoryPoll\
DirectoryPoll = function(directory, tickRate, callback)\
  return {\
    closed = false,\
    directory = directory,\
    files = { },\
    type = \"directory\",\
    close = function(self, reason)\
      if reason == nil then\
        reason = \"DirectoryPoll was closed\"\
      end\
      self.closed = true\
      callback(reason, nil)\
      return nil\
    end,\
    scan = function(self)\
      if self.closed then\
        return \
      end\
      return walk(directory, function(err, names)\
        if err then\
          return self:close(err)\
        end\
        for name, entry in pairs(self.files) do\
          entry.checked = false\
        end\
        local entry, lastModified\
        for _index_0 = 1, #names do\
          local _continue_0 = false\
          repeat\
            local name = names[_index_0]\
            if not (isfileSync(name)) then\
              _continue_0 = true\
              break\
            end\
            entry = self.files[name]\
            if entry then\
              entry.checked = true\
              lastModified = statSync(name).mtime.sec\
              if not (entry.lastModified == lastModified) then\
                entry.lastModified = lastModified\
                callback(nil, \"changed\", name)\
              end\
            else\
              self.files[name] = {\
                checked = true,\
                lastModified = statSync(name).mtime.sec\
              }\
              callback(nil, \"renamed\", name)\
            end\
            _continue_0 = true\
          until true\
          if not _continue_0 then\
            break\
          end\
        end\
        for name, entry in pairs(self.files) do\
          if not (entry.checked) then\
            self.files[name] = nil\
            callback(nil, \"renamed\", name)\
          end\
        end\
        if tickRate == 0 then\
          return nextTick((function()\
            local _base_0 = self\
            local _fn_0 = _base_0.scan\
            return function(...)\
              return _fn_0(_base_0, ...)\
            end\
          end)())\
        else\
          return setTimeout(tickRate, (function()\
            local _base_0 = self\
            local _fn_0 = _base_0.scan\
            return function(...)\
              return _fn_0(_base_0, ...)\
            end\
          end)())\
        end\
      end)\
    end\
  }\
end\
local FilePoll\
FilePoll = function(file, tickRate, callback)\
  return {\
    closed = false,\
    file = file,\
    lastModified = statSync(file).mtime.sec,\
    type = \"file\",\
    close = function(self, reason)\
      if reason == nil then\
        reason = \"FilePoll was closed\"\
      end\
      self.closed = true\
      callback(reason, nil)\
      return nil\
    end,\
    scan = function(self)\
      if self.closed then\
        return \
      end\
      return access(file, function(err)\
        if err then\
          return self:close(err)\
        end\
        return stat(file, function(err, stats)\
          if err then\
            return self:close(err)\
          end\
          if stats.mtime.sec ~= self.lastModified then\
            self.lastModified = stats.mtime.sec\
            callback(nil, file)\
          end\
          if tickRate == 0 then\
            return nextTick((function()\
              local _base_0 = self\
              local _fn_0 = _base_0.scan\
              return function(...)\
                return _fn_0(_base_0, ...)\
              end\
            end)())\
          else\
            return setTimeout(tickRate, (function()\
              local _base_0 = self\
              local _fn_0 = _base_0.scan\
              return function(...)\
                return _fn_0(_base_0, ...)\
              end\
            end)())\
          end\
        end)\
      end)\
    end\
  }\
end\
isdir = function(directory, callback)\
  if not (type(directory) == \"string\") then\
    error(\"bad argument #1 to 'isdir' (expected string)\")\
  end\
  if not (type(callback) == \"function\") then\
    error(\"bad argument #2 to 'isdir' (expected function)\")\
  end\
  return handleStat(directory, \"directory\", callback)\
end\
isdirSync = function(directory)\
  if not (type(directory) == \"string\") then\
    error(\"bad argument #1 to 'isdir' (expected string)\")\
  end\
  return accessSync(directory) and statSync(directory).type == \"directory\" and true or false\
end\
isfile = function(file, callback)\
  if not (type(file) == \"string\") then\
    error(\"bad argument #1 to 'isfile' (expected string)\")\
  end\
  if not (type(callback) == \"function\") then\
    error(\"bad argument #2 to 'isfile' (expected function)\")\
  end\
  return handleStat(file, \"file\", callback)\
end\
isfileSync = function(file)\
  if not (type(file) == \"string\") then\
    error(\"bad argument #1 to 'isfileSync' (expected string)\")\
  end\
  return accessSync(file) and statSync(file).type == \"file\" and true or false\
end\
walk = function(directory, callback, results)\
  if results == nil then\
    results = { }\
  end\
  if not (type(directory) == \"string\") then\
    error(\"bad argument #1 to 'walk' (expected string)\")\
  end\
  if not (type(callback) == \"function\") then\
    error(\"bad argument #2 to 'walk' (expected function)\")\
  end\
  return readdir(directory, function(err, names)\
    if err then\
      return callback(err, nil)\
    end\
    local pending = #names\
    if pending < 1 then\
      return callback(nil, results)\
    end\
    for _index_0 = 1, #names do\
      local name = names[_index_0]\
      name = join(directory, name)\
      stat(name, function(err, stats)\
        insert(results, name)\
        if stats and stats.type == \"directory\" then\
          return walk(name, function()\
            pending = pending - 1\
            if pending < 1 then\
              return callback(nil, results)\
            end\
          end, results)\
        else\
          pending = pending - 1\
          if pending < 1 then\
            return callback(nil, results)\
          end\
        end\
      end)\
    end\
  end)\
end\
walkSync = function(directory, results)\
  if results == nil then\
    results = { }\
  end\
  if not (type(directory) == \"string\") then\
    error(\"bad argument #1 to 'walkSync' (expected string)\")\
  end\
  if not (isdirSync(directory)) then\
    error(\"bad argument #1 to 'walkSync' (no such directory)\")\
  end\
  local stats\
  local _list_0 = readdirSync(directory)\
  for _index_0 = 1, #_list_0 do\
    local name = _list_0[_index_0]\
    name = join(directory, name)\
    insert(results, name)\
    stats = statSync(name)\
    if stats and stats.type == \"directory\" then\
      walkSync(name, results)\
    end\
  end\
  return results\
end\
watchPoll = function(path, tickRate, listener)\
  if type(tickRate) == \"function\" then\
    listener = tickRate\
    tickRate = 0\
  end\
  if not (type(path) == \"string\") then\
    error(\"bad argument #1 to 'watch' (expected string)\")\
  end\
  if not (isdirSync(path) or isfileSync(path)) then\
    error(\"bad argument #1 to 'watch' (expected directory or file)\")\
  end\
  if not (type(tickRate) == \"number\") then\
    error(\"bad argument #2 to 'watch' (expected number)\")\
  end\
  if not (tickRate > -1) then\
    error(\"bad argument #2 to 'watch' (expected positive tick rate)\")\
  end\
  if not (type(listener) == \"function\") then\
    error(\"bad argument #3 to 'watch' (expected function)\")\
  end\
  local entry = isdirSync(path) and DirectoryPoll(path, tickRate, listener) or FilePoll(path, tickRate, listener)\
  nextTick((function()\
    local _base_0 = entry\
    local _fn_0 = _base_0.scan\
    return function(...)\
      return _fn_0(_base_0, ...)\
    end\
  end)())\
  return entry\
end",
['novacbn/luvit-extras/vfs'] = "local type\
type = _G.type\
local match\
match = string.match\
local Emitter, Object\
do\
  local _obj_0 = require(\"core\")\
  Emitter, Object = _obj_0.Emitter, _obj_0.Object\
end\
local PATTERN_URI_SCHEME = \"^(%l[%l%d%-]*)$\"\
local PATTERN_URI_PARTS = \"^(%l[%l%d%-]*)://([%w%-%./_]*)$\"\
local PATTERN_URI_PATH = \"^([%w%-%./_]+)$\"\
local makeAdapterBind\
makeAdapterBind = function(method, isAction)\
  return function(self, uri, ...)\
    if not (type(uri) == \"string\") then\
      error(\"bad argument #1 to '\" .. tostring(method) .. \"' (expected string)\")\
    end\
    local scheme, path = match(uri, PATTERN_URI_PARTS)\
    if not (scheme) then\
      error(\"bad argument #1 to '\" .. tostring(method) .. \"' (malformed URI)\")\
    end\
    local adapter = self.adapters[scheme]\
    if not (adapter) then\
      error(\"bad argument #1 to '\" .. tostring(method) .. \"' (unknown URI scheme)\")\
    end\
    return adapter[method](adapter, path, ...)\
  end\
end\
do\
  local _with_0 = Emitter:extend()\
  _with_0.readOnly = false\
  _with_0.initialize = function(self, readOnly)\
    self.readOnly = readOnly\
  end\
  _with_0.mounted = function(self) end\
  _with_0.dismounted = function(self) end\
  _with_0.emit = function(self, event, ...)\
    if self[event] then\
      self[event](self, ...)\
    end\
    return Emitter.emit(self, event, ...)\
  end\
  VirtualAdapter = _with_0\
end\
do\
  local _with_0 = Object:extend()\
  _with_0.adapters = nil\
  _with_0.initialize = function(self)\
    self.adapters = { }\
  end\
  _with_0.mount = function(self, scheme, adapter)\
    if not (type(scheme) == \"string\") then\
      error(\"bad argument #1 to 'mount' (expected string)\")\
    end\
    if not (match(scheme, PATTERN_URI_SCHEME)) then\
      error(\"bad argument #1 to 'mount' (unexpected URI scheme)\")\
    end\
    if self.adapters[scheme] then\
      error(\"bad argument #1 to 'mount' (expected unmounted scheme)\")\
    end\
    if not (type(adapter) == \"table\") then\
      error(\"bad argument #2 to 'mount' (expected VirtualAdapter)\")\
    end\
    self.adapters[scheme] = adapter\
    adapter:emit(\"mounted\", self)\
    return self\
  end\
  _with_0.dismount = function(self, scheme)\
    if not (type(scheme) == \"string\") then\
      error(\"bad argument #1 to 'dismount' (expected string)\")\
    end\
    if not (match(scheme, PATTERN_URI_SCHEME)) then\
      error(\"bad argument #1 to 'mount' (malformed URI scheme)\")\
    end\
    if not (self.adapters[scheme]) then\
      error(\"bad argument #1 to 'dismount' (expected mounted scheme)\")\
    end\
    self.adapters[scheme] = nil\
    adapter:emit(\"dismounted\", self)\
    return self\
  end\
  _with_0.access = makeAdapterBind(\"access\")\
  _with_0.accessSync = makeAdapterBind(\"accessSync\")\
  _with_0.mkdir = makeAdapterBind(\"mkdir\")\
  _with_0.mkdirSync = makeAdapterBind(\"mkdirSync\")\
  _with_0.readdir = makeAdapterBind(\"readdir\")\
  _with_0.readdirSync = makeAdapterBind(\"readdirSync\")\
  _with_0.readFile = makeAdapterBind(\"readFile\")\
  _with_0.readFileSync = makeAdapterBind(\"readFileSync\")\
  _with_0.rmdir = makeAdapterBind(\"rmdir\", true)\
  _with_0.rmdirSync = makeAdapterBind(\"rmdirSync\", true)\
  _with_0.stat = makeAdapterBind(\"stat\")\
  _with_0.statSync = makeAdapterBind(\"statSync\")\
  _with_0.unlink = makeAdapterBind(\"unlink\", true)\
  _with_0.unlinkSync = makeAdapterBind(\"unlinkSync\", true)\
  _with_0.writeFile = makeAdapterBind(\"writeFile\", true)\
  _with_0.writeFileSync = makeAdapterBind(\"writeFileSync\", true)\
  _with_0.walk = makeAdapterBind(\"walk\")\
  _with_0.walkSync = makeAdapterBind(\"walkSync\")\
  VirtualFileSystem = _with_0\
end",
['novacbn/properties/encoders/lua'] = "local ipairs, loadstring, pairs, setmetatable, type\
do\
  local _obj_0 = _G\
  ipairs, loadstring, pairs, setmetatable, type = _obj_0.ipairs, _obj_0.loadstring, _obj_0.pairs, _obj_0.setmetatable, _obj_0.type\
end\
local stderr\
stderr = io.stderr\
local format, match, rep\
do\
  local _obj_0 = string\
  format, match, rep = _obj_0.format, _obj_0.match, _obj_0.rep\
end\
local concat, insert\
do\
  local _obj_0 = table\
  concat, insert = _obj_0.concat, _obj_0.insert\
end\
local getKeys, getSortedValues, isArray\
do\
  local _obj_0 = dependency(\"novacbn/properties/utilities\")\
  getKeys, getSortedValues, isArray = _obj_0.getKeys, _obj_0.getSortedValues, _obj_0.isArray\
end\
do\
  local _with_0 = { }\
  local options = nil\
  _with_0.stackLevel = -1\
  _with_0.new = function(self, encoderOptions)\
    return setmetatable({\
      options = encoderOptions\
    }, self)\
  end\
  _with_0.append = function(self, value, ignoreStack, appendTail)\
    if ignoreStack or self.stackLevel < 1 then\
      if not (appendTail) then\
        return insert(self, value)\
      else\
        local length = #self\
        self[length] = self[length] .. value\
      end\
    else\
      return insert(self, rep(self.options.indentationChar, self.stackLevel) .. value)\
    end\
  end\
  _with_0.boolean = function(self, value)\
    return value and \"true\" or \"false\"\
  end\
  _with_0.boolean_key = function(self, value)\
    return \"[\" .. (value and \"true\" or \"false\") .. \"]\"\
  end\
  _with_0.number = function(self, value)\
    return tostring(value)\
  end\
  _with_0.number_key = function(self, value)\
    return \"[\" .. value .. \"]\"\
  end\
  _with_0.string = function(self, value)\
    return format(\"%q\", value)\
  end\
  _with_0.string_key = function(self, value)\
    return match(value, \"^%a+$\") and value or format(\"[%q]\", value)\
  end\
  _with_0.array = function(self, arr)\
    local length = #arr\
    local encoder\
    for index, value in ipairs(arr) do\
      encoder = self[type(value)]\
      if not (encoder) then\
        error(\"bad argument #1 to 'Encoder.array' (unexpected type)\")\
      end\
      if encoder == self.table then\
        self:encoder(self, value, index < length)\
      else\
        if index < length then\
          self:append(encoder(self, value, true) .. \",\")\
        else\
          self:append(encoder(self, value, false))\
        end\
      end\
    end\
  end\
  _with_0.map = function(self, map)\
    local keys = getSortedValues(getKeys(map))\
    local length = #keys\
    local count = 0\
    local keyEncoder, value, valueEncoder\
    for _index_0 = 1, #keys do\
      local key = keys[_index_0]\
      keyEncoder = self[type(key) .. \"_key\"]\
      if not (keyEncoder) then\
        error(\"bad argument #1 to 'Encoder.map' (unexpected key type)\")\
      end\
      value = map[key]\
      valueEncoder = self[type(value)]\
      if not (valueEncoder) then\
        error(\"bad argument #1 to Encoder.map (unexpected value type)\")\
      end\
      count = count + 1\
      if valueEncoder == self.table then\
        self:append(keyEncoder(self, key) .. \" = \")\
        valueEncoder(self, value, count < length)\
      else\
        if count < length then\
          self:append(keyEncoder(self, key) .. \" = \" .. valueEncoder(self, value) .. \",\")\
        else\
          self:append(keyEncoder(self, key) .. \" = \" .. valueEncoder(self, value))\
        end\
      end\
    end\
  end\
  _with_0.table = function(self, tbl, innerMember, isRoot)\
    if not (isRoot) then\
      self:append(\"{\", true, true)\
    end\
    self.stackLevel = self.stackLevel + 1\
    if isArray(tbl) then\
      self:array(tbl)\
    else\
      self:map(tbl)\
    end\
    self.stackLevel = self.stackLevel - 1\
    if not (isRoot) then\
      return self:append(innerMember and \"},\" or \"}\")\
    end\
  end\
  _with_0.toString = function(self)\
    return concat(self, \"\\n\")\
  end\
  LuaEncoder = _with_0\
end\
LuaEncoder.__index = LuaEncoder\
encode = function(tbl, encoderOptions)\
  local encoder = LuaEncoder:new(encoderOptions)\
  encoder:table(tbl, false, true)\
  return encoder:toString()\
end\
decode = function(value, decoderOptions)\
  if not (decoderOptions.allowUnsafe) then\
    error(\"bad option 'allowUnsafe' to 'decode' (Lua AST parser not implemented)\")\
  end\
  local chunk, err = loadstring(\"return {\" .. tostring(value) .. \"}\")\
  if err then\
    stderr:write(\"bad argument #1 to 'decode' (Lua syntax error)\\n\")\
    error(err)\
  end\
  return chunk()\
end",
['novacbn/properties/encoders/moonscript'] = "local pairs, setmetatable, type\
do\
  local _obj_0 = _G\
  pairs, setmetatable, type = _obj_0.pairs, _obj_0.setmetatable, _obj_0.type\
end\
local stderr\
stderr = io.stderr\
local format, match, rep\
do\
  local _obj_0 = string\
  format, match, rep = _obj_0.format, _obj_0.match, _obj_0.rep\
end\
local insert\
insert = table.insert\
local hasMoonScript, moonscript = pcall(require, \"moonscript/base\")\
local getKeys, getSortedValues, isArray\
do\
  local _obj_0 = dependency(\"novacbn/properties/utilities\")\
  getKeys, getSortedValues, isArray = _obj_0.getKeys, _obj_0.getSortedValues, _obj_0.isArray\
end\
local LuaEncoder\
LuaEncoder = dependency(\"novacbn/properties/encoders/lua\").LuaEncoder\
do\
  local _with_0 = { }\
  _with_0.new = function(self, encoderOptions)\
    return setmetatable({\
      options = encoderOptions\
    }, self)\
  end\
  _with_0.boolean_key = function(self, value)\
    return value and \"true\" or \"false\"\
  end\
  _with_0.string_key = function(self, value)\
    return match(value, \"^%a+$\") and value or format(\"%q\", value)\
  end\
  _with_0.map = function(self, map)\
    local keys = getSortedValues(getKeys(map))\
    local length = #keys\
    local count = 0\
    local keyEncoder, value, valueEncoder\
    for _index_0 = 1, #keys do\
      local key = keys[_index_0]\
      keyEncoder = self[type(key) .. \"_key\"]\
      if not (keyEncoder) then\
        error(\"bad argument #1 to 'Encoder.map' (unexpected key type)\")\
      end\
      value = map[key]\
      valueEncoder = self[type(value)]\
      if not (valueEncoder) then\
        error(\"bad argument #1 to Encoder.map (unexpected value type)\")\
      end\
      count = count + 1\
      if valueEncoder == self.table then\
        self:append(keyEncoder(self, key) .. \": \")\
        valueEncoder(self, value, count < length)\
      else\
        self:append(keyEncoder(self, key) .. \": \" .. valueEncoder(self, value))\
      end\
    end\
  end\
  _with_0.table = function(self, tbl, innerMember, isRoot)\
    self.stackLevel = self.stackLevel + 1\
    if isArray(tbl) then\
      if not (isRoot) then\
        self:append(\"{\", true, true)\
      end\
      self:array(tbl)\
      self.stackLevel = self.stackLevel - 1\
      if not (isRoot) then\
        return self:append(\"}\")\
      end\
    else\
      self:map(tbl)\
      self.stackLevel = self.stackLevel - 1\
    end\
  end\
  MoonScriptEncoder = _with_0\
end\
setmetatable(MoonScriptEncoder, LuaEncoder)\
MoonScriptEncoder.__index = MoonScriptEncoder\
encode = function(tbl, encoderOptions)\
  local encoder = MoonScriptEncoder:new(encoderOptions)\
  encoder:table(tbl, false, true)\
  return encoder:toString()\
end\
decode = function(value, decoderOptions)\
  if not (hasMoonScript) then\
    error(\"bad dispatch to 'decode' (MoonScript library is not installed)\")\
  end\
  if not (decoderOptions.allowUnsafe) then\
    error(\"bad option 'allowUnsafe' to 'decode' (MoonScript AST parser not implemented)\")\
  end\
  local chunk, err = moonscript.loadstring(\"{\" .. tostring(value) .. \"}\")\
  if err then\
    stderr:write(\"bad argument #1 to 'decode' (MoonScript syntax error)\\n\")\
    error(err)\
  end\
  return chunk()\
end",
['novacbn/properties/exports'] = "local type\
type = _G.type\
local propertiesEncoders = {\
  lua = dependency(\"novacbn/properties/encoders/lua\"),\
  moonscript = dependency(\"novacbn/properties/encoders/moonscript\")\
}\
local EncoderOptions\
EncoderOptions = function(options)\
  do\
    local _with_0 = options or { }\
    _with_0.allowUnsafe = _with_0.allowUnsafe or true\
    _with_0.indentationChar = _with_0.indentationChar or \"\\t\"\
    _with_0.propertiesEncoder = propertiesEncoders[_with_0.propertiesEncoder or \"lua\"]\
    _with_0.sortKeys = _with_0.sortKeys == nil and true or _with_0.sortKeys\
    _with_0.sortIgnoreCase = _with_0.sortIgnoreCase == nil and true or _with_0.sortIgnoreCase\
    if not (_with_0.propertiesEncoder) then\
      error(\"bad option 'propertiesEncoder' to 'EncoderOptions' (invalid value '\" .. tostring(decoderOptions.propertiesEncoder) .. \"')\")\
    end\
    return _with_0\
  end\
end\
local DecoderOptions\
DecoderOptions = function(options)\
  do\
    local _with_0 = options or { }\
    _with_0.allowUnsafe = _with_0.allowUnsafe or true\
    _with_0.propertiesEncoder = propertiesEncoders[_with_0.propertiesEncoder or \"lua\"]\
    if not (_with_0.propertiesEncoder) then\
      error(\"bad option 'propertiesEncoder' to 'DecoderOptions' (invalid value '\" .. tostring(decoderOptions.propertiesEncoder) .. \"')\")\
    end\
    return _with_0\
  end\
end\
encode = function(value, options)\
  if not (type(value) == \"table\") then\
    error(\"bad argument #1 to 'encode' (expected table)\")\
  end\
  if not (options == nil or type(options) == \"table\") then\
    error(\"bad argument #2 to 'encode' (expected table)\")\
  end\
  local encoderOptions = EncoderOptions(options)\
  return encoderOptions.propertiesEncoder.encode(value, encoderOptions)\
end\
decode = function(value, options)\
  if not (type(value) == \"string\") then\
    error(\"bad argument #1 to 'decode' (expected string)\")\
  end\
  if not (options == nil or type(options) == \"table\") then\
    error(\"bad argument #2 to 'decode' (expected table)\")\
  end\
  local decoderOptions = DecoderOptions(options)\
  return decoderOptions.propertiesEncoder.decode(value, decoderOptions)\
end",
['novacbn/properties/utilities'] = "local pairs, type\
do\
  local _obj_0 = _G\
  pairs, type = _obj_0.pairs, _obj_0.type\
end\
local lower\
lower = string.lower\
local sort\
sort = table.sort\
local sortingWeights = {\
  boolean = 0,\
  number = 1,\
  string = 2,\
  table = 3\
}\
getKeys = function(tbl)\
  local _accum_0 = { }\
  local _len_0 = 1\
  for key, value in pairs(tbl) do\
    _accum_0[_len_0] = key\
    _len_0 = _len_0 + 1\
  end\
  return _accum_0\
end\
getSortedValues = function(tbl, isCaseSensitive)\
  local values\
  do\
    local _accum_0 = { }\
    local _len_0 = 1\
    for _index_0 = 1, #tbl do\
      local value = tbl[_index_0]\
      _accum_0[_len_0] = value\
      _len_0 = _len_0 + 1\
    end\
    values = _accum_0\
  end\
  local aWeight, bWeight, aType, bType\
  sort(values, function(a, b)\
    aType, bType = type(a), type(b)\
    if aType == \"string\" and bType == \"string\" then\
      if not (isCaseSensitive) then\
        return lower(a) < lower(b)\
      end\
      return a < b\
    elseif aType == \"boolean\" and bType == \"boolean\" then\
      if aType == true and bType == false then\
        return false\
      end\
      return true\
    elseif aType == \"number\" and bType == \"number\" then\
      return a < b\
    else\
      return sortingWeights[aType] < sortingWeights[bType]\
    end\
  end)\
  return values\
end\
isArray = function(tbl)\
  if tbl[1] == nil then\
    return false\
  end\
  local count = 0\
  for key, value in pairs(tbl) do\
    if not (type(key) == \"number\") then\
      return false\
    end\
    count = count + 1\
  end\
  if not (count == #tbl) then\
    return false\
  end\
  return true\
end",
}, ...)